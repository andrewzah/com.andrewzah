---
title: "Container Practices"
date: "2025-08-08"
tags: ["containers", "nix"]
keywords: "container OCI docker podman rootless distroless nix"
description: "Thoughts on OCI container practices."
---

This is meant to be a sort of living document and thought dump on container
stuff that I've learned over years of working on containers.

## General

### Be more explicit

Instead of `ubuntu:latest`, it's better to specify
`docker.io/library/ubuntu:questing-20250721`.

### Use Hashes

`docker.io/library/ubuntu:questing-20250721` is an improvement, but someone
could push a new image to that tag at any time. It's better to pin the container
using its registry hash:

```
docker.io/library/ubuntu:questing-20250721@sha256:fcdea13661343a0113773e1f3c481336462222a08993a9a83eae58268746d139
```

The hash is registry dependent. To find it for docker.io images, you can head to
`hub.docker.com`, e.g.
[hub.docker.com/_/ubuntu](https://hub.docker.com/_/ubuntu/tags), and click on
the Tags tab. As far as I know, this is the easiest way without setting up a
developer oauth token and curl'ing the v2 API.

Note: you can omit the tag if you specify the hash.

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
You can self-host rekor and fulcio as well.

I'm not sure about Docker Hub, but I know
[Harbor](https://github.com/goharbor/harbor) shows if an image is signed or not,
and there are Kubernetes configs to prevent the running of unsigned images.

### Use Multi Stage Builds

This should be pretty self-explanatory, but I see people messing this up a lot.
You can build what you need and copy over the output to a base, minimal or
distroless image.

For example, the `docker.io/library/rust:latest` image is 1.54gb. If you're not
using a multi stage build, you're bundling all of that along with your rust
program!

## QnA

### What is OCI?

OCI refers to the [Open Container Initiative](https://opencontainers.org/),
which has specifications around creating and distributing OCI-compliant images.

### What is 'distroless' and why do I care?

> Minimal images, sometimes called distroless images, are container images
> stripped of unnecessary components such as package managers, shells, or even
> the underlying operating system distribution.
>
> --
> [docker docs: Minimal or distroless images](https://docs.docker.com/dhi/core-concepts/distroless/)

Most images build on top of another image using the FROM directive. It's
familiar and convenient. The problem is that now you've bundled an entire distro
just to run a program. Although container layer caching exists, it just
_bothers_ me to see that kind of bloat.

Some proponents of distroless images might tout security risks. But
[I find that unlikely](https://www.redhat.com/en/blog/why-distroless-containers-arent-security-solution-you-think-they-are)
to be something worth worrying about, when the most important attack vector is
still your own program.

So, the main benefits of distroless images are reduced image size and dependency
bloat. But there are tradeoffs to consider.

### rootless: docker/podman daemon

Docker provides
[rootless mode](https://docs.docker.com/engine/security/rootless/), which allows
running the docker daemon without needing to be root.

### rootless: inside the container
