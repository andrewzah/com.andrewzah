---
title: "Garmin's $850 smartwatch can’t render CJK text"
date: "2020-01-11"
tags: ["i18n", "languages", "rants"]
description: "My $850 watch can’t render CJK languages because Garmin assumes people living in one region only use 1 language."
---

I recently acquired a
[Garmin Fenix 6X](https://buy.garmin.com/en-US/US/p/641435/pn/010-02157-10),
currently Garmin’s flagship model. While I did research beforehand, I forgot that my phone
was in Korean, and thus the notifications would be in Korean… Silly me.

![An example notification from my phone](https://s3.amazonaws.com/andrewzah.com/posts/2020_01_11_garmin_fenix/garmin-notification.jpg)

The 6 series is not cheap, starting at \$600, with the 6X starting at
[\$750](https://buy.garmin.com/en-US/US/p/641530/pn/010-02159-13).
The solar editions go for \$1,000 and \$1,150.
This specific variant currently retails for \$850, so
when I found it on discount for \$500 I hopped on that.

Garmin has an application called Express which has a `Language Files` section, but it’s empty (and still is as of 2021-07-08). When I spoke to customer support, they told me Korean wasn’t supported at this time. I was directed to [a page on supported languages](https://support.garmin.com/en-US/?faq=bUNm3O11dH04aqGOFtBsz6), and a page [to share ideas](https://www.garmin.com/en-US/forms/ideas/) but it errors on submission.

![A screenshot of the Utilities tab in the Tools \& Content section of the Garmin Express application.](https://s3.amazonaws.com/andrewzah.com/posts/2020_01_11_garmin_fenix/express-utilities.png)

I saw that Romanian (my mother tongue) was supported so I asked a friend who works at Garmin about that, and he mentioned that they have an office there. Cursory googling brings up a few [reddit threads](https://www.reddit.com/r/Garmin/comments/bua11v/asian_language_support_for_fenix_5_plus_series/) which mention different models are made for different regions. So if I want Korean text, I have to find a Korean/Asian version of the watch. And forget about receiving texts with Chinese or Japanese characters.

So, is there no one at Garmin who uses their flagship watch, with their phone set to a CJK language? (or any other nonsupported language that uses a different script, for that matter)? Is there no one who receives texts in Chinese, etc, from their friends? Even if the watch isn’t localized to those languages, surely it should be possible to download a relevant font file?

While this isn’t the end of the world (I like the fenix a lot!), is it really so hard to imagine a person that lives in one region but prefers using a different language?

The thing is that issues like these occur way more frequently than they should.

**Example 1**

On Netflix, there’s a show called *Hilda*. If I visit Netflix from the USA, the offered subtitle languages are: English, Spanish, French, and Simplified & Traditional Chinese. If I visit Netflix from Korea, now Korean subtitles (and audio!) are available. C’mon netflix… I know there’s some technical reason for doing this, but that’s not really relevant to me as an end user.

**Example 2**

I bought a western/North American region 3DS, and it only supported 4 languages (not Korean or Japanese)… despite also being sold in Japan and Korea. I ended up having to [jailbreak the 3ds](https://3ds.hacks.guide/) to change the language/region and allow the Korean version of games to be played.

---

All too often, people make assumptions about regions and language, if they do internationalization at all. This is understandable for open source projects with limited resources, and less understandable for large companies. Surely language support would help a product sell more?

Just give me a way to change the language!
