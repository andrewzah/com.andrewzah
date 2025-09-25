---
title: "Better Anki Usage Guide"
date: "2019-05-19"
date-modified: "2024-11-13"
tags: ["languages", "memory", "memorization", "anki"]
description: "Anki is a great app, but making some modifications really makes it shine."
---

> The single biggest change that Anki brings about is that it means memory is no
> longer a haphazard event, to be left to chance. Rather, it guarantees I will
> remember something, with minimal effort. That is, Anki makes memory a choice.
>
> Michael A. Nielsen, _Augmenting Long-term Memory_

I love [Anki](https://apps.ankiweb.net/), the spaced repetition flash cards app.
I’ve been using it in my [[Korean learning
journey|korean-learning-journey-update-1.html]] for almost one and a half years
now and I’ve written about it before. It’s a good app, but you can have a much
better experience by making some modifications to it.

If you don’t know what Anki is or why it’s compelling, I recommend you read
[_Augmenting Long-term Memory_](http://augmentingcognition.com/ltm.html), a blog
post by Michael Nielsen.
[_Everything I know: Tips and Tricks for Anki_](https://web.archive.org/web/20240222104137/https://senrigan.io/blog/everything-i-know-strategies-tips-and-tricks-for-spaced-repetition-anki/)
by Jeff Shek also has a beginner’s guide.

If you’re new to Anki, the very first thing I recommend doing is
[reading the manual](https://docs.ankiweb.net), or at least the
["Getting Started" section](https://docs.ankiweb.net/getting-started.html). I
recommend using Anki for at least a week or so to get a general sense for it
before necessarily implementing the suggestions in this article.

## Changing default settings

Anki out of the box has two problematic defaults, and one default that I don’t
recommend personally.

### Resetting card progress

Let’s say you have learned a card, but when you review it you make a mistake in
recalling it, for whatever reason. Call it a brain fart, or pressing too
quickly, etc. Or you simply forgot!

By default, Anki resets your progress to that of a new card. So even if you had
worked the card up to a ~4 month interval, now you have to see it in 1 day, 2
days, 4 days, all over again…

Even if you forget a card, you still had learned it at one point. Which means
re-learning it is now significantly easier. By completely resetting the card’s
intervals, Anki is wasting your time. It slowly conditions you to be unwilling
to press `Again`, which is not desirable at all.

**Solution**: In your deck’s options group under Lapses, change `New interval`
to `70%`. This means if you forget a card, the new interval will be 70% of the
old one. As for why I chose 70%, it just felt like an appropriate amount–feel
free to play with different percentages to see what works best for you.

### Taking too long to mark Leeches

After you initially learn a card (the card reached a 1 day interval in default
anki), if you forget it 8 times, Anki marks it as a Leech and suspends the card,
not showing it to you anymore.

A card being a leech generally means its too complicated, or you’re getting it
confused with a similar one. 8 times means it’s going to take way too long to
identify cards that are problematic.

**Solution**: In your deck’s options group under Lapses, change
`Leech threshold` to `4`. You may also want to change `Leech action` to
`tag only`. This way you can easily sort for leech cards and modify or delete
them.

As for handling leech cards, you generally want to simplify the card, or delete
it outright. With the time and energy that you wasted on trying to recall a
leech you could have learned a bunch of other cards. If it’s a word that you
don’t want to delete, you can suspend the card, and practice using that word
outside of anki. When you feel more comfortable with it you can unsuspend it.

### Mixing new and review cards

By default, Anki mixes new and review cards. However, reviewing is vastly more
important than learning new cards–it’s okay if you don’t memorize new cards
every day, but missing reviews really hurts your memorization progress.

By putting reviews first, you can always do reviews daily and then choose to
learn new words or not depending on how busy you are, how tired you are, etc. If
the cards are mixed you can’t do this, making it likely you’ll just skip Anki
for that day entirely, which can can quickly snowball into not using anki at all
anymore. This happened to me.

**Solution**: In Anki’s preferences, change `Mix new cards and reviews` to
`Show new cards after reviews`.

### Making better card templates

The Basic card template in Anki has two fields: `Front` and `Back`. This is the
minimum for flashcards obviously, but as you make cards it’s likely you’ll want
to have separate information.

Over time my personal Zah Korean card template has grown to eight fields:
`english`, `korean`, `grammarType`, `samples`, `hanja`, `notes`, `image` and
`sound`. On the front I show `english`, and `grammarType` as a hint. Some people
put sample sentences but I find this leads to short-circuiting your recall;
instead of recalling the word you recognize that sentence.

I also have a **Zah Colorcard** template which has a `hexColor` field. Because I
initially tried to learn colors in Korean like regular vocabulary, which makes
no sense. Anki lets you pull in values easily in the template’s html and css
sections.

You can modify a card’s fields by going to Add or Edit, then clicking on
`Fields...`. You can add a new card type by going to Add or Edit, then click on
the type, and then click `Manage`.

### Better styling with html and css

Default anki’s styling is very plain. I recommend modifying it to show different
fields in different colors. For example, my `grammarType` field is rendered in
green while `hanja` is rendered in purple. I render my color card’s hex value
dynamically. Here’s what my cards look like; the horizontal line denotes the
front and back:

![How my template looks for a given card](https://s3.amazonaws.com/andrewzah.com/posts/017/templates.jpg)

You can go to Browse, Add, or Edit and click on `Cards...` to get to the style
dialogue. Some premade decks include nice styling for you, or default to a night
mode. For more in-depth info, you can visit
[styling in the anki manual](https://docs.ankiweb.net/templates/styling.html#card-styling).

## Why behavior-changing plugins are needed

Essentially, the way Anki treats cards is not intuitive, and actually hampers
your memorization progress. Let’s say you’re reviewing a card–you have four
options. `Again`, if you forget, and `Hard`, `Good`, or `Easy`.

You would assume this means "I (the user) had a hard/good/easy time recalling
this card today", right? Well, Anki actually sees it as "this card is
intrinsically more difficult; please modify it permanently".

Huh?

You see, every card in Anki has an individual `ease` percentage, starting at
250% by default. The algorithm that calculates a new interval goes like:

```shell
NewInterval = OldInterval × CardEase × DeckIntervalModifier

Where:
  OldInterval: 1 day is the first default value
  CardEase: 250% by default
  DeckIntervalModifier: 1.0 by default, set on a per-deck basis
```

When you hit `Again`, `Hard` or `Easy`, Anki modifies the ease by `-20%`,
`-15%`, or `+15%`, respectively… You can see now why people recommend not
hitting `Easy` at all; it quickly snowballs. Note that a card’s `ease` can’t go
lower than 130%.

![A screengrab of Hannibal Buress on The Eric Andre Show saying the word "wack"](https://s3.amazonaws.com/andrewzah.com/posts/017/wack.jpg "A screengrab of Hannibal Buress on The Eric Andre Show saying the word 'wack'.")

So you might be saying, why is seeing cards too often, aka "overlearning", an
issue? Either way, I’m seeing more difficult cards more often.. Well, research
suggests that after an initial period, the extra time spent doesn’t actually
lead to better recall.

In one study (Rohrer, Taylor, Pashler, Wixted, & Cepeda, 2005), college students
learned novel vocabulary (e.g., cicatrix–scar), cycling through a list of
word–definition pairs either 5 or 10 times. **The extra 5 cycles yielded a
substantial benefit after 1 week, but the gain was no longer apparent after 4
weeks** … From a long-term perspective, overlearning appears to be inefficient
almost to the point of wasting time.[^1]

[^1]: [Enhancing learning and retarding forgetting: Choices and consequences, Pashler, Rohrer, Cepeda, & Carpenter (2007)](https://s3.amazonaws.com/andrewzah.com/studies/Pashler.Rohrer.Cepeda.Carpenter_2007.pdf)

Now take a look at what happens in Anki if you lower the ease too much:

![Image taken from Guide to Anki Intervals and Learning Steps (1)](https://s3.amazonaws.com/andrewzah.com/posts/017/ease-example.jpg)

So even if you know a card enough to hit `Good`, if you had hit `Hard` 3-4 times
prior, the interval growth rate is permanently stunted due to how Anki works.
You would have to hit `Easy` to balance it which is counterintuitive.

Research also suggests that larger spacing is better in the long term.

In a 9-year longitudinal investigation, 4 subjects learned and relearned 300
English-foreign language word pairs. Either 13 or 26 relearning sessions were
administered at intervals of 14, 28, or 56 days. Retention was tested for 1, 2,
3, or 5 years after training terminated. **The longer intersession intervals
slowed down acquisition slightly, but this disadvantage during training was
offset hy substantially higher retention.** Thirteen retraining sessions spaced
at 56 days yielded retention comparable to 26 sessions spaced at 14 days.[^2]

[^2]: [MAINTENANCE OF FOREIGN LANGUAGE VOCABULARY AND THE SPACING EFFECT, Bahrick Et al (1993)](https://s3.amazonaws.com/andrewzah.com/studies/Bahrick-et-al-1993-spacing-effect.pdf)

Our results can be summarized as follows. We find that over substantial time
periods, spacing has powerful (and typically nonmonotonic) effects on retention,
with optimal memory occurring when spacing is some modest fraction of the final
retention interval (perhaps about 10%–20%).[^1]

With that out of the way, here are the plugins I use.

## Anki Subdecks

If you review from multiple decks daily, you can use a parent deck with subdecks
to mix reviews. This is my own personal opinion, but I think it’s better for
recall if you change contexts. This is more like recall in real life.

Making subdecks in anki is really easy–just make a parent deck, and drag decks
onto it. Or you can manually rename the deck in this format:
`Parent Deck Name::Subdeck Name`. If done right, it should appear like this:

![A picture of anki open displaying how the interface shows subdecks](https://s3.amazonaws.com/andrewzah.com/posts/017/subdecks.png)

The only issue is Anki will still do reviews one deck at a time. I tried using
the experimental V2 scheduler, but it didn’t work for me. So now we have to turn
to a plugin:
[HoochieMama: Randomize Rev Queue](https://ankiweb.net/shared/info/1460733408).
After you install this, open Anki’s preferences, and in the Muffins tab enable
`Hoochie Mama! RandRevQ w/ subdeck limit`.

That’s it! Now you can review from multiple subdecks, and new cards are still
deck by deck. If you want to mix new cards as well, there’s
[Hoochie Papa](https://ankiweb.net/shared/info/1173108619). I personally don’t
think that is as useful.

Make sure to back up your anki decks before adding behavior modification plugins
like this.

## Filtering Cards

There are times when you want to study something more specific than just cards
in a deck. For example, lets say you have a general language deck with some
cards tagged as `colors`, and you want to only study those.

### Custom Study Sessions

If you click on a deck, you should see a "Custom Study" button. This gives you
several options, which you can
[read about here](https://docs.ankiweb.net/#/filtered-decks?id=filtered-decks-amp-cramming).

- Increase today’s new card limit

- Increase today’s review card limit

- Review forgotten cards

- Review ahead

- Preview new cards

- Study by card state or tag

Choose the last one, then "All cards in random order (don’t reschedule)", unless
you only want to study cards that you’ve already seen. Then click Choose Tags,
and the tags that you want to focus on.

Once you review the card, it will go back to the main deck. You can also delete
the Custom Study Session deck.

The downside here is that the queries are per deck. What if you want to search
multiple decks, or have a more complicated query?

### Manually Filtering

The other option Anki has is to create a Filtered Deck, using Tools &gt; Create
Filtered Deck from the main menu.

This will give you a search prompt. Anki searches can get pretty advanced, so
[read about them here](https://docs.ankiweb.net/#/searching). Some useful ones:

- `deck:deckname` filters by deck.

- `-deck:deckname` adding a `-` negates the filter.

- `tag:tagname` filters by tag.

- `-deck:filtered` filters by normal (unfiltered) decks only.

You can group terms with parentheses: `(tag:tag1 or tag:tag2 and tag:tag3)`

Some of these plugins are out of date. This article is slated to be updated. The
Reset EZ & No Penalties or Boosting plugins are now part of
[Migaku](https://www.migaku.com/).

## Visual Plugins

These aren’t really necessary but I like seeing stats. Give me allll the stats.

[True Retention by Card Maturity](https://ankiweb.net/shared/info/923360400)

This is basically a fancy stats plugin. You can see a detailed breakdown by day,
week, and month, and see your true retention rate. You want roughly 80-90%
retention. \[TODO\]

[More decks stats and time left](https://ankiweb.net/shared/info/1556734708)

This addon shows extra information of the due cards and returns the expected
time to finalize (Due+New).

[Enhance main window](https://ankiweb.net/shared/info/877182321)

This adds more stats to the main window via columns. As you can see in that
link, the default config adds quite a lot, so I
[modified my config](https://gist.github.com/andrewzah/0391ce0fc3e90f3defea75ef518fd195)
to pare it down, which looks like this:

![A picture displaying how the anki main window looks different with this plugin enabled](https://s3.amazonaws.com/andrewzah.com/posts/017/enhanced.png)

Note that the stats at the bottom are from the `More decks stats and time left`
plugin.

[Progress graphs and stats for mature and learned cards](https://ankiweb.net/shared/info/266436365)

Adds two new graphs to the stats window.

[Button Colours (Good, Again)](https://ankiweb.net/shared/info/2494384865)

Simply colorizes Again to be red, Good to be green, etc. It’s a small but nice
thing to have when reviewing. There’s also
[Large and Colorful Buttons](https://ankiweb.net/shared/info/1829090218) if you
wanted even more colorful buttons.

[Kanji Grid](https://ankiweb.net/shared/info/909972618)

This is an awesome plugin that visually shows your kanji learning progress.
Simply select a deck that has a `kanji` field, and run Tools &gt;
`Generate Kanji Grid`. It looks like this:

![A grid showing kanji characters with a color background based on how long the current interval is](https://s3.amazonaws.com/andrewzah.com/posts/017/kanji-grid.png)

This was generated from my deck with the default settings.

## Behavior Plugins

This is where things get fun. These plugins change the core functionality of
Anki, so please, read about them and make sure you understand what they do
before adding them.

Make sure to back up your Anki decks before installing these.

[Search in Add Card Dialogue](https://ankiweb.net/shared/info/1781298089)

This adds a pane to the `Add Card` window, letting you quickly search through
your Anki decks for keywords. It’s very useful for finding duplicates, or
searching among sample sentences.

The only con is the search doesn’t work for non-ascii text. When I have time I
plan on fixing this.

[ResetEZ](https://massimmersionapproach.com/table-of-contents/anki/low-key-anki/low-key-anki-summary-and-installation/)

This adds a command in your Tools menu called `Reset Ease + Force Sync After`.
It resets **all** Anki cards to have the default ease value, 250%. You have to
install it manually.

[No Penalties or Boosting](https://massimmersionapproach.com/table-of-contents/anki/low-key-anki/low-key-anki-summary-and-installation/)

This changes `Again`, `Hard`, and `Easy` to not change the card’s ease value. By
default, Anki modifies it by -20%, -15%, or +15%, respectively. This is a bad
idea, and I go into more detail \[in my other anki post\]\[TODO\]. This goes
hand in hand with ResetEZ. It also needs to be manually installed.

[Hoochie Mama: Randomize Rev Queue](https://ankiweb.net/shared/info/1460733408)

See the [Making use of subdecks](#_utilizing_subdecks) section above. This
randomizes review cards in subdecks.

## Other Plugins

There may be plugins for the language(s) that you’re learning. Japanese has
several, for example. It’s worth searching "anki &lt;language&gt;"" to see
what’s available.

## Conclusion

Considering that we end up using Anki for years, it’s worth taking some time to
improve it and read the documentation closely. Is there a plugin or change that
you feel like I missed? Let me know.

## Further Reading

I have also written a companion post on
[general things to avoid while using Anki](/posts/anki-things-to-avoid) that I
recommend you check out.

- [Anki Documentation](https://docs.ankiweb.net/intro.html)
- [Anki’s Starting Ease Factor Setting](https://eshapard.github.io/anki/ankis-initial-ease-factor-setting.html)
- [Augmenting Long-term Memory](http://augmentingcognition.com/ltm.html)
- [Everything I Know: Strategies, Tips, and Tricks for Anki](http://web.archive.org/web/20240617122836/https://senrigan.io/blog/everything-i-know-strategies-tips-and-tricks-for-spaced-repetition-anki/)
- [John Baez on Research Tactics](https://intelligence.org/2014/02/21/john-baez-on-research-tactics/)
- [Supermemo Algorithm](https://www.supermemo.com/en/archives1990-2015/english/ol/sm2)
- [Supermemo Research](https://www.supermemo.com/en/archives1990-2015/english/ol/beginning#Algorithm)

## References

- [Guide to Anki Intervals and Learning Steps](https://www.youtube.com/watch?v=1XaJjbCSXT0)
- [Low-Key Anki](https://massimmersionapproach.com/table-of-contents/anki/)
- [Targeting an 80-90% Success Rate in Anki](https://eshapard.github.io/anki/target-an-80-90-percent-success-rate-in-anki.html)
- [Low-Key Anki: No Penalties or Boosting](https://massimmersionapproach.com/table-of-contents/anki/low-key-anki/low-key-anki-no-penalties-or-boosting/)
- [Low-Key Anki: ResetEZ](https://massimmersionapproach.com/table-of-contents/anki/low-key-anki/low-key-anki-no-penalties-or-boosting/)

## Citations
