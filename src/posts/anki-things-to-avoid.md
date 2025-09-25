---
title: "Things to avoid with Anki"
date: "2019-05-18"
date-modified: "2024-11-13"
tags: ["languages", "memorization", "anki"]
description: "Anki has some unintuitive defaults that can end up impeding your learning progress!"
---

There are some common mistakes people make when getting into flash cards and
spaced repetition for the first time. Considering that Anki is generally used
for years, correcting bad habits ends up paying large dividends.

For those unaware, [Anki](https://apps.ankiweb.net/) is a free and open source
app that implements
[Active Recall](https://docs.ankiweb.net/background.html#active-recall-testing)
with [Spaced Repetition](https://en.wikipedia.org/wiki/Spaced_repetition). If
you’re new to Anki, the very first thing I recommend doing is
[reading the manual](https://docs.ankiweb.net), or at least the
["Getting Started" section](https://docs.ankiweb.net/getting-started.html).

So with that said, let’s get into it!

## Not syncing all the time

You should always sync after every session, especially if you edit anything.

Did you know `y` is the sync shortcut?

## Studying too many new words

This is a classic mistake. Don’t go over 20 words per day unless you are
studying **at least** 1-2 hours every day. Initially it’s doable but if you miss
a day or two, it piles up so fast it’s scary.

If you have less time, I **strongly** recommend doing 10 or 5 words per day.
Some progress is better than no progress due to burnout.

|  number of words per year  | total |
| :------------------------: | :---: |
| 5 words per day, per year  | 1,825 |
| 10 words per day, per year | 3,650 |
| 20 words per day, per year | 7,300 |

For most, if not all, languages, 3-5k words will let you have basic
conversations. Around 8k words is the threshold for more advanced conversations
and reading.

Don’t understimate the power of slow and steady practice.

## Mixing reviews and new words

This is Anki’s default behavior. I personally recommend against this as
sometimes you don’t have the time or energy in a day to sit down and learn the
new cards. It’s okay if you don’t learn new words, but missing reviews is really
bad.

But you can’t only do the reviews, since they’re mixed in with the new cards! So
guess what ends up happening? Both the reviews and new cards get skipped…

By changing Anki preferences to `Show new cards after reviews`, you can always
do reviews without worry. After you wake up, while you commute, et cetera.

## Having too many concepts per card

A good anki card should have **one** concept. Avoid memorizing lists if
possible. If you do have to memorize a list, turn it into an enumeration (1. 2.
3…). It’s much better to make split concepts into multiple cards.

When memorizing foreign words it’s really tempting to put every definition into
one card. Don’t do this. Putting related definitions together is fine, but if a
word has multiple different meanings, it needs different cards.

> [!NOTE]
> One exception I make is for words that have a figurative meaning that's
> related to the literal meaning. There's no sense in making a separate card for
> that.

I see this a lot in premade decks, with 1 card having 4 or 5 totally unrelated
usages of a word–and no sentence samples either, of course.

## Only using premade decks

If you’re a beginner to studying a language, using a premade deck is fine due to
the sheer amount of time it takes to add words to a deck. However the longer you
study, the more you need your own personal deck.

If you use someone else’s deck, it’s basically a random collection of words that
you lack the context for. For your own personal deck you have to see the word
somewhere first, giving you more of a feeling for the context.

If you’re trying to mass-memorize words (say, for a language test), I recommend
using Anki’s
[parent/subdecks feature](https://docs.ankiweb.net/deck-options.html#subdecks).
That way you can use a premade deck _and_ your personal deck at the same time.
Spiffy.

I explain subdecks a bit more in my
[Better Anki Usage](/posts/anki-usage-guide#anki-subdecks) post.

## Not making use of reverse cards

If you always have your native language on the front, and target language on the
back, then you’re training yourself to think in your language, then recall the
equivalent in your target language… If you always have your target language on
the front, and your native language on the back, then you’re training
recognition more than recall…

I don’t know which way is better. (Please send research if you do know). **But**
I do know that Anki supports automatically making decks with both options!

You can also make automatically make cards that go both ways if you use the
`Basic (and reversed card)` template. So adding a card with \[library, la
biblioteca\] will make another card that’s \[la biblioteca, library\]. If you
only want -some- cards to have a reverse, you can use the provided
`Basic (optional reversed card)` template. This one only makes a reverse if you
put something in the `Add Reverse` field (it can be any input, it doesn’t show
anywhere).

See
[the manual](https://docs.ankiweb.net/templates/generation.html#reverse-cards)
for more information on reverse cards.

## Not including sample sentences

A lot of language learning decks just have the word and its translation. For
very basic words this can be fine, but for most words you really do need sample
sentences so you can see the context as well.

I include 2-3 sample sentences in all the cards I make, as well as notes, common
word pairings, and the grammar type.

## Pressing ‘easy’ too easily

It’s can be tempting to give a review card the ‘Easy’ grade, quickly giving it
large intervals. Don’t do this unless you know the word quite well (in which
case, why even have the card at all?). Otherwise the interval will increase
rapidly, and you’ll have forgotten it by then.

Actually, due to how Anki works, pressing `Easy` (or `Hard`) _permanently_
modifies that card, giving it way longer intervals than what it should be. I go
over this in detail in my
[Better Anki Usage](/posts/anki-usage-guide#why-behavior-changing-plugins-are-needed)
post. Almost all long-term Anki users that I talk to do not press `Easy` often,
or ever.

## Not doing Anki daily

If you take away only one tip from this post, let it be this one. Nothing else
here matters if you don’t consistently review cards daily.

The entire point of Anki is spaced repetition. Every time you skip a day’s
reviews, the following session will become more difficult. For non-mature words
(less than 30 day intervals) it’s crucial that you review. If you don’t review
for a long time, you will soon have hundreds of reviews stacked up, which is
super demotivating.

I used to do Anki before bed, but this sometimes led to me skipping it due to
work, friends, or life just taking up more time and energy than expected. Now I
consistently do anki either in the morning after I’ve fully woken up, or around
lunch.

If you change your study time, make sure to update your Anki Preferences, under
Basic &gt; `Next day starts at`. This tip goes hand in hand with the next one.

## Not memorizing keyboard shortcuts

Last but not least, learning a few shortcuts is useful since Anki is used so
much.

When reviewing a card:

- `ctrl/cmd-z` -> undo
- `spacebar` -> flip the card
- `1`,`2`,`3`,`4` -> the numbers follow the order of the grading buttons. So for
  a review, which has [`Again`, `Hard`, `Good`, `Easy`], those are 1,2,3,4
  respectively. A new card has [`Again`, `Good`, `Easy`] by default, which are
  1, 2, 3.
- `e` -> edit card

Other shortcuts:

- `r` -> replay audio
- `@` -> suspend a card
- `m` -> mark a card (adds a `marked` tag so you can find it easily later)
- `ctrl/cmd-1,2,3,4` -> flag a card with `red`, `orange`, `green`, or `blue`,
  respectively
- `-` -> bury a card (hide it until tomorrow)

Window/tool shortcuts:

- `y` -> sync
- `d` -> go to decks overview
- `b` -> browse cards
- `a` -> add card
- `t` -> stats
- `/` -> custom study session
- `f` -> create filter deck

Overkill, you say? Well.. yeah, probably. Aside from `spacebar`,
`1`,`2`,`3`,`4`, `r`, and `y`, you don’t really need to know the rest unless you
like being super duper efficient.

## Conclusion

These are some of the problems I’ve encountered while using Anki. Are there
other ones you think I should talk about? Let me know.

If you’re interested in Anki, I recommend reading my companion [[Better Anki
Usage Guide|better-anki-usage-guide.html]] post to fix some of Anki’s wonky
defaults and unintuitive behavior.
