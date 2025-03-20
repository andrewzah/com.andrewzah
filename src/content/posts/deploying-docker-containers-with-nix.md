---
title: "Deploying Docker Containers with Nix"
date: "2025-02-25"
tags: ["nix", "docker", "selfhosting", "traefik"]
description: "Nix's virtualisation and oci-containers options let us bridge Nix deployments with oci-compliant containers."
---

I've slowly been migrating my ansible-based homelab provisioning setup to NixOS.

I was worried at first since I wasn't sure how well it'd support
docker and docker-compose, but it's been almost\* flawless so far.

The magic lies in [`virtualisation.oci-containers.containers`](https://search.nixos.org/options?channel=24.11&from=0&size=50&sort=relevance&type=packages&query=virtualisation.oci-containers.containers).

## Setup

The first thing we need to do is enable an oci backend, either `docker` or `podman`.
I'm used to docker so I went with the rootless version.

```nix { title = "virtualisation.nix" }
{...}: {
    virtualisation = {
        docker.rootless.enable = true;
        docker.rootless.setSocketVariable = true;
        docker.autoPrune.enable = true;
        containerd.enable = true;

        oci-containers.backend = "docker"; # defaults to podman
    };

    environment.sessionVariables = {
        DOCKER_HOST = "unix:///run/docker.sock"; # fix for rootless docker
    };
}
```

> [!note]
> There is the `virtualisation.docker.rootless.setSocketVariable` option but it didn't work for me, so I set `DOCKER_HOST` manually.

## Our First Container
```nix { title = "./containers/whoami.nix" }
{...}: {
  virtualisation.oci-containers.containers.whoami = {
    autoStart = true;
    ports = ["8080"];
    image = "docker.io/andrewzah/whoami";
  };
}
```

The options available here map to docker compose options.
I just looked at the old docker-compose.yml and translated it over to Nix's syntax.

With this and the above docker setup, you should be able to run
`nixos-rebuild switch <...>` and have a `whoami` container.

Now this is all well and good, but I imagine most selfhosters
want to make services available. This is where docker networks and traefik come in.

## Traefik
```nix { title = "./containers/traefik.nix" }
{config, ...}: {
    sops.secrets."traefik/env" = {};

    virtualisation.oci-containers.containers.traefik = {
        autoStart = true;
        image = "docker.io/library/traefik:v3.1.4@sha256:6215528042906b25f23fcf51cc5bdda29e078c6e84c237d4f59c00370cb68440";
        cmd = [
        "--api.insecure=false"
        "--api.dashboard=false"

        "--log.level=INFO" # ERROR default

        ## providers
        "--providers.docker=true"
        "--providers.docker.exposedbydefault=false"

        ## entrypoints
        "--entrypoints.web.address=:80"
        "--entrypoints.websecure.address=:443"
        "--entrypoints.ssh.address=:22"
        "--entrypoints.web.forwardedHeaders.insecure"
        "--entrypoints.websecure.forwardedHeaders.insecure"

        ## entrypoint redirections
        "--entrypoints.web.http.redirections.entryPoint.to=websecure"
        "--entrypoints.web.http.redirections.entryPoint.scheme=https"
        "--entrypoints.web.http.redirections.entrypoint.permanent=true"

        ## generic resolver
        "--certificatesresolvers.generic.acme.tlschallenge=true"
        "--certificatesresolvers.generic.acme.email=admin@andrewzah.com"
        "--certificatesresolvers.generic.acme.storage=/letsencrypt/acme.json"
        #"--certificatesResolvers.generic.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory"

        ## cloudflare resolver
        "--certificatesresolvers.cloudflare.acme.storage=/letsencrypt/cloudflare-acme.json"
        "--certificatesresolvers.cloudflare.acme.email=admin@andrewzah.com"
        "--certificatesresolvers.cloudflare.acme.dnschallenge=true"
        "--certificatesresolvers.cloudflare.acme.dnsChallenge.provider=cloudflare"
        "--certificatesresolvers.cloudflare.acme.dnsChallenge.delayBeforeCheck=0"
        "--certificatesresolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53"
        #"--certificatesResolvers.cloudflare.acme.caServer=https://acme-staging-v02.api.letsencrypt.org/directory"
        ];
        ports = [
        "80:80"
        "443:443"
        "8080:8080"
        ];
        extraOptions = ["--net=external"];
        environmentFiles = [config.sops.secrets."traefik/env".path];
        labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.http-catchall.rule" = "hostregexp(`{host:.+}`)";
        "traefik.http.routers.http-catchall.entrypoints" = "web";
        "traefik.http.routers.http-catchall.middlewares" = "redirect-to-https@docker";
        "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme" = "https";
        "traefik.http.middlewares.redir.redirectScheme.scheme" = "https";
        };
        volumes = [
        "/your/data/dir/traefik/letsencrypt/:/letsencrypt/:rw"
        "/run/docker.sock:/var/run/docker.sock:ro"
        ];
    };
}
```

> [!note]
> The full context can be found
[in my github repository](https://github.com/andrewzah/homelab-nix/blob/47dddab00bd3ba8c7e4cc2659f080beb3540562b/hosts/falcon/containers/traefik.nix).
> Traefik also [has comprehensive documentation](https://doc.traefik.io/traefik/).

Notice the line with `extraOptions = ["--net=external"];`.
Nix won't automatically make docker networks for us, so I ended up adding a system oneshot service to do so.

Depending on your traefik configuration, you may need to pass credentials.
I use dns authentication with Cloudflare so I encrypted the env vars with [sops-nix](https://github.com/Mic92/sops-nix)
and pointed to a file with `virtualisation.oci-containers.containers.<name>.environmentFiles`.
Dealing with secrets (sops + nix-sops) will be a separate article in the future.

```nix { title = "virtualisation.nix" }
{pkgs, ...}: {
    systemd.services.create-docker-networks = {
        description = "Create docker networks manually";
        after = ["docker.service"];
        wants = ["docker.service"];
        wantedBy = [
        "docker-traefik.service"
        "docker-postgres.service"
        ];

        serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        };

        script = ''
        ${pkgs.docker}/bin/docker network inspect internal || ${pkgs.docker}/bin/docker network create internal
        ${pkgs.docker}/bin/docker network inspect external || ${pkgs.docker}/bin/docker network create external
        '';
    };
}
```

Containers deployed with `oci-containers.containers.<name>`
will have a corresponding `docker-<name>.service` definition. So here we can
run the oneshot before e.g. traefik and postgres.

## Our First Container (Again)

Now that Traefik is running and we have our networks,
we can link up the `whoami` container.

```nix { title = "virtualisation.nix" }
{...}: let
  fqdn = "whoami.example.com";
  router = "whoami";
in {
    virtualisation.oci-containers.containers.whoami = {
        autoStart = true;
        ports = ["8080"];
        image = "docker.io/andrewzah/whoami";
        dependsOn = ["traefik"];
        extraOptions = ["--net=external"];
        labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.authentik.rule" = "Host(`${fqdn}`) && PathPrefix(`/outpost.goauthentik.io/`)";
            "traefik.http.routers.${router}.rule" = "Host(`${fqdn}`)";
        };
    };
}
```

And that's it! Soon I'll have some articles on managing secrets with sops/nix-sops, and OIDC with Forward Auth via Keycloak / Authentik.
