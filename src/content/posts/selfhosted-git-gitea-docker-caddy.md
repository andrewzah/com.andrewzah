---
title: "Selfhosting Gitea, Docker, Caddy"
date: "2018-05-15"
date-modified: "2024-11-17"
description: "This walks through hosting a git frontend with docker, caddy, and gitea."
tags: ["selfhosting", "caddy", "docker", "gitea"]
aliases: ["/posts/2018/05-15_selfhosted_git_gitea_docker_caddy"]
---

> [!note]
> This article's Caddy v1 code has been updated to Caddy v2.

Something I’ve been doing recently is starting to self-host as much as I
can. I don’t like relying on businesses, since they can change their
services on a whim. I host an
[IRC network bouncer](https://en.wikipedia.org/wiki/ZNC),
a [rss feed reader](https://github.com/miniflux/miniflux[feed reader),
and so on. But why not a git frontend?

It also doesn’t make sense to me that **Git**hub isn’t open-source,
despite being a company built on *git*&mdash;libre software that powers the
programming industry. Gitlab is commendable for actually being open
source, but it’s fairly heavy in resource usage and it has a lot of
features I don’t really need.

So in comes [Gitea](https://gitea.io/en-US/Gitea), a community fork of
[Gogs](https://gogs.io/), which is written in go-lang and is quite
lightweight. More importantly, it can mirror with both Github and
Gitlab, giving us data redundancy. Let’s get into it!

> [!note]
> As of 2024, a new fork of Gitea called [Forgejo](https://forgejo.org/2024-02-forking-forward/) has emerged.

## Prerequisites

`docker` and `docker-compose` need to be installed on your system. In
this case, I’m running it with a bunch of other services on a
[hetzner.de](https://www.hetzner.de/) Cloud VPS for €5/month. You could
probably run it on their €2.50/month plan. (2GB vs 4GB of RAM)

## docker compose: part 1

In this case, both Gogs and Gitea provide premade docker images for us.
Handy! Thankfully they’re mindful about docker image size, with
[Gitea 1.22](https://hub.docker.com/layers/gitea/gitea/1.22-nightly/images/sha256-7d322c0628e70aca2f068942d6c7675c7a01fcc97f5f63e338dec5313cd4e1f3?context=explore)
clocking in at `68MB` (compressed).

This means all we have to do is create a `docker-compose` file:

```yaml
---
services:
  git:
    image: gitea/gitea:latest
    ports:
      - "3000"
    volumes:
      - type: bind
        source: ./data/git
        target: /data
    restart: unless-stopped
```

This file defines `git` as a service, using the mentioned gitea image.
You can use `latest` or keep it at a specific version, it’s up to you.

Next, Gitea runs on port `3000` by default, so we need to expose the
docker container’s port likewise. Note that we are _not_ doing
`3000:3000`, which would locally bind the port and expose it. Instead, we
have a tool that’ll handle the routing for us.

### Caddy

[Caddy](https://caddyserver.com) is a fantastic webserver. Its killer
feature is automatically handling HTTPS with [Let’s Encrypt](https://letsencrypt.org/).
Seriously, I cannot recommend it enough for personal projects.
Gone are the days of manually handling certificates and needing
[nginx](https://www.nginx.com) configs.

Caddy’s `Caddyfile` syntax is simple:

```txt
# the domain
https://git.example.com {
  # tls info for Let's Encrypt
  tls your@email.com

  log / stdout {combined}
  errors stderr

  # Passing all traffic to our gitea container
  reverse_proxy * http://git:3000
}
```

## docker compose: part 2

In order to run Caddy, we need to add it as a service:

```yaml
services:
  http:
    image: docker.io/library/caddy:latest
    volumes:
      - type: bind
        source: ./data/sites/
        target: /var/www/sites/
      - type: bind
        source: ./data/caddypath/
        target: /var/caddy/
      - type: bind
        source: ./Caddyfile
        target: /etc/Caddyfile
    environment:
      CADDYPATH: "/var/caddy"
    env_file: ./secret.env
    ports:
      - "xxx.xxx.xxx.xxx:443:443"
      - "xxx.xxx.xxx.xxx:80:80"
    restart: always
```

`data/sites/` and `/data/caddypath` store information related to Caddy
and the automatically generated Let’s Encrypt files. `/etc/Caddyfile` is
where Caddy looks, so we bind our caddyfile there.

`env_file: ./secret.env` is only needed if a caddy plugin requires
sensitive data, such as the `tls.dns.gandiv5` plugin.

Replace the port IP with your server’s IP. The reason we use that is
because by default, `yyy:zzz` will listen on _all_ interfaces.

## docker compose: part 3

You may have noticed by now that we’re missing one big thing… a
database. This one is simple, because Gitea is smart and runs on
Postgres:

```yaml
services:
  git_db:
    image: docker.io/library/postgres:15-alpine
    env_file: ./secret.env
    restart: always
    volumes:
      - type: bind
        source: ./data/postgres/
        target: /var/lib/postgresql/data/
```

In `secret.env`, you’ll need to set the following:

```txt
POSTGRES_USER=xxxx
POSTGRES_PASSWORD=yyyyyy
POSTGRES_DB=git
```

Now that we have a database service, we can add this to the `gitea`
service:

```yaml
services:
  git:
    depends_on:
      - git_db
```

## Editing SSHD

There’s one problem now, which is that if you actually try to run this
configuration, you’ll be refused. We never actually exposed ssh’s
default port `22`, nor did we start listening to it!

So let’s listen to `22` for git, and `2223` for regular ssh. Edit, with
sudo permissions, `/etc/ssh/sshd_config`:

```conf
# What ports, IPs and protocols we listen for
Port 2223
Port 22
```

At this time, I would also recommend disabling password login, as one
can never have enough security.

```conf
PermitRootLogin without-password
PasswordAuthentication no
```

> [!warning]
> Make sure you add your
> [ssh key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
> output to `~/.ssh/authorized_keys`! You’ll be locked out otherwise.

## docker compose: final

Lastly, now that we’re listening on port `22`, add this to the
`docker-compose.yml`:

```yaml
services:
  git:
    image: gitea/gitea:latest
    ports:
      - "22:22"
```

Now when we do `git push origin master`, with `origin` set to
`https://git.example.com/...`, it’ll reach the gitea container!

In total, it should look like this:

```yaml
----
services:
  git:
    image: gitea/gitea:latest
    ports:
      - "3000"
      - "22:22"
    volumes:
      - type: bind
        source: ./data/git
        target: /data
    restart: always

  git_db:
    image: postgres:15-alpine
    env_file: ./secret.env
    restart: always
    volumes:
      - type: bind
        source: ./data/postgres/
        target: /var/lib/postgresql/data/

  http:
    image: docker.io/library/caddy:latest
    volumes:
      - type: bind
        source: ./data/sites/
        target: /var/www/sites/
      - type: bind
        source: ./data/caddypath/
        target: /var/caddy/
      - type: bind
        source: ./Caddyfile
        target: /etc/Caddyfile
    environment:
      CADDYPATH: "/var/caddy"
    env_file: ./secret.env
    ports:
      - "xxx.xxx.xxx.xxx:443:443"
      - "xxx.xxx.xxx.xxx:80:80"
    restart: always

```

## Conclusion

If everything was done correctly, you should now have a self-hosted git
frontend. Nice!

## Further Reading

I recommend checking out
[awesome-selfhosted](https://github.com/Kickball/awesome-selfhosted) to
see a huge list of other software you can host.
[reddit.com/r/selfhosted](https://www.reddit.com/r/selfhosted/) is also a good resource.
The possibilities are endless… You could host a
[Kanban board](https://github.com/wekan/wekan) or a
[Magic: The Gathering Cockatrice server](https://cockatrice.github.io/)!

Have fun!
