---
title: "Container Practices"
date: "2025-08-08"
tags: ["containers", "nix"]
keywords: "container OCI docker podman rootless distroless nix"
description: "Thoughts on OCI container practices."
stream: "draft"
---

This is meant to be a sort of living document and thought dump on container
stuff that I've learned over years of working on containers.

It's common now for open source projects to maintain a Dockerfile as well, but I
often see bad practices.

## General Docker Practices

### rootless: docker/podman daemon

Docker provides a
[rootless mode](https://docs.docker.com/engine/security/rootless/), which allows
running the docker daemon without needing to be root. Podman doesn't use a
daemon, but it also lets you run containers as a non-root user.

Rootless containers have several advantages:[^1]

- They add a new security layer; even if the container engine, runtime, or
  orchestrator is compromised, the attacker won't gain root privileges on the
  host.
- They allow multiple unprivileged users to run containers on the same machine
  (this is especially advantageous in high-performance computing environments).
- They allow for isolation inside of nested containers.

### dropping root within a container

It's common to see a container start up, do some housekeeping operations, and
then run the binary as a nonprivileged user. I see these tools a lot:
[gosu](https://github.com/tianon/gosu), and
[S6](https://github.com/just-containers/s6-overlay), although S6 is a
full-fledged init system.

```shell {title = "shell"}
$ gosu nobody:nobody bash -c 'whoami && id'
$ s6-setuidgid nobody:nobody bash -c 'whoami && id'
```

If possible, it's best to run the container itself as an unprivileged user.
However, this is not always possible. Not all programs were designed with
rootless, readonly containers in mind... so I personally use S6 for housekeeping
and reading
[secrets mounted by Vault](https://developer.hashicorp.com/vault/tutorials/kubernetes-introduction/kubernetes-secret-store-driver).

### Prefer distroless images when possible

> Minimal images, sometimes called distroless images, are container images
> stripped of unnecessary components such as package managers, shells, or even
> the underlying operating system distribution.
>
> --
> [docker docs: Minimal or distroless images](https://docs.docker.com/dhi/core-concepts/distroless/)

Most images build on top of another image using the FROM directive. It's
familiar and convenient. The problem is that now you've bundled an entire distro
to run a single program. It's wasteful in image size, and adds slight security
risks. Although container layer caching exists, it just _bothers_ me to see that
kind of bloat. I think we can do better.

> [!QUESTION]
> Are distroless images really that secure?

In theory, removing files decreases the attack surface, so yes. But in practice,
[I find the effects are a bit overstated](https://www.redhat.com/en/blog/why-distroless-containers-arent-security-solution-you-think-they-are).
I mainly view distroless as a win for dealing with bloat. Stop bundling the
world along with your tool.

> [!QUESTION]
> If I remove bash, how will I debug my image?

Use [nsenter(1)](https://man7.org/linux/man-pages/man1/nsenter.1.html). I
believe this should work in kubernetes as long as the pod's operating system
supports `nsenter`, but I'm not a kubernetes guy.

```shell {title = "shell"}
$ docker inspect -f '{{.State.Pid}}' 7c00
6353

$ sudo nsenter -n -t 6353
[inside container NS] $ curl/etc
```

Of particular note is the `-n` flag, which also enters the network namespace of
the container.

Debugging this way is far better than e.g. building a debug variant of the
image.

## Building Images

### Sign Images with [sigstore.dev](https://www.sigstore.dev/)

Using [`cosign`](https://github.com/sigstore/cosign) (and
[`rekor`](https://github.com/sigstore/rekor)/[`fulcio`](https://github.com/sigstore/fulcio)),
you can sign images in a tamper-proof log.

```
$ cosign sign --key ~/.cosign/cosign.key docker.io/me/my-image:my-tag@sha256:my-hash
$ cosign verify --key ~/.cosign/cosign.pub -o text docker.io/me/my-image:my-tag@sha256:my-hash
```

When you sign an image, cosign stores that
[oci-artifact](https://docs.docker.com/docker-hub/repos/manage/hub-images/oci-artifacts/)
in the registry and in rekor, which uses
[a cryptographically verifiable data store](https://github.com/google/trillian).
Rekor and fulcio are self-hostable.

Some registries, like [Harbor](https://github.com/goharbor/harbor), show if an
image is signed or not, and there are Kubernetes configs to prevent the running
of unsigned images.

### Use Multi Stage Builds

This should be pretty self-explanatory, but I see people messing this up a lot.
You can build what you need and copy over the output to a base, minimal or
distroless image.

For example, the `docker.io/library/rust:latest` image is 1.54gb. If you're not
using a multi stage build, you're bundling all of that along with your rust
binary!

```dockerfile {title = "dockerfile"}
## first, use AS to name your build stages
FROM quay.io/centos/centos:stream8 AS build_backend
FROM quay.io/centos/centos:stream8 AS build_frontend

## then, in your last stage, use COPY:
FROM quay.io/centos/centos:stream8 
COPY --from=build_backend --chown=foo:bar /foo/baz/ /foo/baz/
```

## try building with Nix

Delving into this deserves its own set of articles, but in short: you can build
images with the [Nix package manager](https://nixos.org/) instead of
Dockerfiles. If you've built a lot of images, you know the pain of having to
rebuild an entire image because the image it's based on, like python or java,
got updated.

Nix has
[pkgs.dockerTools](https://ryantm.github.io/nixpkgs/builders/images/dockertools/)
and [nix2container](https://github.com/nlewo/nix2container).

A short `pkgs.dockerTools` derivation might look like:

```nix
{pkgs, ...}: {
  # first, build our go binary:
  # knot = buildGoModule { ... };

  # second, define our image
  container = pkgs.dockerTools.buildImage {
    name = "docker.io/andrewzah/knot";
    tag = "${knot.version}";

    copyToRoot = pkgs.buildEnv {
      name = "knot-root";
      paths = [knot];
      pathsToLink = ["/bin"];
    };

    config = {
      Entrypoint = [ "${knot}/bin/knotserver" ];
      ExposedPorts = {
        "22" = {};
        "5555" = {};
      };
    };
  };
}
```

```shell {title = "shell"}
$ nix build -A container
$ docker load < ./result
## note: you can use skopeo to copy the tarball directly to the registry
## if you don't want to use the docker daemon
## nix2container provides helpers for this
```

The reason I love using Nix as a builder, is that I don't have to think about
build stages anymore. See `paths` inside of `copyToRoot`? I can specify whatever
needs to go into the image. For example, `[pkgs.jdk8 pkgs.python3]` will resolve
automatically. It's completely changed the game.

For about a year and a half now I haven't built images using Dockerfiles unless
strictly necessary.

## Running Images (e.g. with docker-compose)

The examples below are docker-compose oriented, but apply to kubernetes
manifests as well.

### Use a specific tag instead of `latest`

Instead of `ubuntu:latest`, it's better to specify
`docker.io/library/ubuntu:questing-20250721`. It's okay for local development,
but it's asking for trouble when deployed.

### Use Hashes

`docker.io/library/ubuntu:questing-20250721` is an improvement, but someone
could push a new image to that tag at any time. It's better to pin the image
using its registry hash:

```
docker.io/library/ubuntu:questing-20250721@sha256:fcdea13661343a0113773e1f3c481336462222a08993a9a83eae58268746d139
```

The hash used here is registry dependent. To find it for docker.io images, you
can head to `hub.docker.com`, e.g.
[hub.docker.com/_/ubuntu](https://hub.docker.com/_/ubuntu/tags), and click on
the Tags tab. As far as I know, this is the easiest way without setting up a
developer oauth token and curl'ing the v2 API.

If you've already pulled the image, you can run:

```shell {title = "shell"}
$ docker images --no-trunc --quiet debian:stretch-slim
sha256:0e23ec2ce5e621c0e8fa57a53c7781d59d57de8c139a8a351b7236530cd85ec2
```

Note: you can omit the tag if you specify the hash.

### Utilize docker networks

E.g. `internal` and `external`

### Don't expose ports directly

Use a proxy like Traefik instead.

### Don't mount the docker socket in containers

Use a proxy image that provides a readonly copy, it's insecure

## docker cli stuff

These are some commands I find myself running often.

To see a container's local IP:

```shell {title = "shell"}
$ docker inspect 7c00 | rg IPAddress

"SecondaryIPAddresses": null,
"IPAddress": "",
        "IPAddress": "172.20.0.2",
```

To clear out old build images:

```shell {title = "shell"}
$ docker image ls | grep -i none | awk '{print $3}' | xargs docker image rm

Deleted: sha256:27b70c93a991251a4f9794071936b24d4380198a231f1526064c216165840be2
Deleted: sha256:a0d2ac8d3a09aff2a641f71868e81e7c9e98bedba5ee417425b2f63a09e19274
...
```

## QnA

### What is OCI?

OCI refers to the [Open Container Initiative](https://opencontainers.org/),
which is a set of standards around container images, formats and runtimes.

## References

[^1]: [Redhat | Rootless Containers with Podman: The Basics](https://developers.redhat.com/blog/2020/09/25/rootless-containers-with-podman-the-basics#why_rootless_containers_)
