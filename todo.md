## immediate todo
- fixes
  - REMOVE hugo admonitions theme, replicate via render hooks + css
  - code in single backticks, aka just <p><code></code></p>
  - decide on date / no date in slug
    - research SEO ramifications
  - fix any remaining .adoc pages & links
  - double check git-lfs png/jpg etc
  - code css: table/td w/ hugo syntax highlighting
  - code css: add code block name styling
  - fix post slugs, aliases, series
  - update links to e.g. resume
- new features
  - clickable photos: use markdown render from hugo
  - AWS & just
    - add aws-cli to flake
    - add just commands to help automate bucket syncing
  - backlinks
    - https://brainbaking.com/post/2024/06/visualizing-blog-post-links-with-obsidian/
    - https://brainbaking.com/post/2022/04/true-backlink-support-in-hugo/
  - citations:
    - https://github.com/joksas/hugo-simplecite?tab=readme-ov-file

## todo
- update use, now, cats pages
- write, motherfucker. WRITE
- pic for philips review
- investigate optimized image generation + integration into nix flake

## potential alterations:
- blog comments via ssh, https://blog.haschek.at/2023/ssh-based-comment-system.html
  - special logo/color for users with verified ssh keys?
  - approve/deny via telegram / discord bot ?
- series
  - https://discourse.gohugo.io/t/previous-in-series-and-next-in-series-links/2654/7
  - series: https://digitaldrummerj.me/hugo-post-series/
- 2-col gutter style - https://edwardtufte.github.io/tufte-css/
- investigate caching
  - granular webscraper caching: https://notes.neatnik.net/2024/08/fedicache ?
