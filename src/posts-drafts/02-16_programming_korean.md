---
title: "Korean for Programmers"
#slug = "korean\_for\_programmers"
date: "2019-02-16"
lastmod: "2020-06-22"
categories: ["korean", "programming", "languages"]
#description: "Exploring the representation of Korean in the context of various programming languages."
#toc: true
---

# Korean for Programmers

I was inspired to write this after reading [*German for Programmers*](https://wickedchicken.github.io/post/german-for-programmers/). It’s quite likely that I’m just biased to see things a certain way because I work with programming languages for a living, but I often find myself drawing comparisons between Korean and programming.

## Hangeul Basics

Before we can get into grammar, some explanation about Hangeul–the Korean alphabet–is needed. Korean is actually like English in that letters are put together, so you can read any Korean once you learn Hangeul. However, Korean letters join together in syllable blocks.

You may have seen the infamous "Learn how to read Hangeul in 10 minutes" graphic. While Hangeul is indeed very easy to learn, it does have exceptions–quite a few actually. So maybe you can read 독립 (independence), but the actual pronunciation is different from what’s written due to ㄹ following ㄱ. These are called [받침 rules](https://www.koreanwikiproject.com/wiki/%EB%B0%9B%EC%B9%A8) and one just has to memorize them.

### Grid System

Unlike Chinese or Japanese, Korean syllable blocks take the Hangeul letters and make them into grids in a particular order.

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/008/hangeul.png" alt="Hangul Grid Order" />
</figure>

Each block contains a vowel and it’s always the second character. The block are constructed depending on whether the vowel is vertical (ㅣ ㅏ ㅓ) or horizontal (ㅡㅜㅗ). If you want to say *ah*, ㅇ is used as a silent character in the first slot–which makes 아: `ㅇ` + `ㅏ`.

Some vowels can also be combined: `ㅚ` is `ㅜ` + `ㅣ`, `ㅙ` is `ㅗ`  
`ㅐ`.

For Korean fonts, all finished blocks (e.g. 쀍: ㅃㅜㅔㄹㄱ) have to be included because it’s possible to construct them via grid rules, but a fair amount are just gibberish. Hangeul is represented by [5 unicode blocks](https://en.wikipedia.org/wiki/Korean_language_and_computers#Hangul_in_Unicode) in total and I recommend reading about how they get composed together.

## Subject Elision, especially -you-

In English, we always need to specify the subject except in very casual situations. I can’t write just "Can’t write" or "Ate an apple". In Korean however, the subject isn’t necessary in every sentence. In fact, always including it isn’t natural at all! Korean is highly contextual, so if you say:

밥 먹었어요 – literally: ate.

In a lot of contexts, that would make most sense as (I) ate. However if someone asks you, "Did Charlie eat?", you can still say:

(네,) 밥 먹었어요. – (yes,) ate. –&gt; "Yes, Charlie ate."

Similarly if you ask someone else a question, it’s usually obvious if they are the subject.

이 책을 읽었어요? – lit: this book read? –&gt; "Did you read this book?"

It makes little sense to ask "Did I read this book?" in most situations. (If you want to muse to yourself like "ah, did I (already) read this book..?", that requires a specific grammar point.)

If you’re wondering, people do clarify from time to time.

"밥 먹었어요? - ate?" –&gt; ""(Did you/he) eat?"

"저요? / 저는요?" –&gt; "(were you referring to) Me?"

The subject/topic still has to be included when it changes or it’s ambiguous. If you start off by saying "저는 …" ("as for me, …"), it’s implied the following sentences will still be about you.

In this sense I *guess* one could say Korean leans toward being duck-ly typed–but that’s a tenuous comparison. Anyway, it’s different from English where the subject almost always must be specified (strongly typed…?), except in some spoken slang. Even very informal slang like "d’ya eat?" still includes the subject. We’re playing a bit fast and loose here with the comparisons.

Using the direct words for "you" (너, 네가, 당신) is also quite rude unless you are close with someone. Papago and google translate often translate "you" to 너 or 네가. Don’t use these until you know what you’re doing. 당신 has different nuances and should also be avoided. It’s really hard for English speakers to let go of "you", but you must.

## Sentences & Grammar

### Sentence Order

English is an SVO (Subject Verb Object) language. "Billy ate an apple". Korean is an SOV language. "Billy apple ate". This reversal makes thinking in Korean actually quite difficult once one gets to causation and more difficult sentences.

English: I went to the park because it was sunny out today. Korean: It was sunny out today so I went to the park.

English: I was so tired I could barely walk. Korean: To the extent that I could barely walk I was so tired.

From the perspective of a native English speaker, I find this reversal utterly fascinating. With English the last bit of the sentence usually has the important bit:

"Do you know where the {{&lt; hlw "red" "bathroom" &gt;}} is?"

You basically have to finish the whole sentence there before the other person can understand what you intend. Now with Korean:

혹시 {{&lt; hlw "red" "화장실이" &gt;}} 어디에 있는지 아세요?

I often can barely get the first half of this out before I start getting an answer. answer.

### Finally, a sentence

We made it! Let’s start with a simple sample sentence in Korean.

저는 사과를 어제 먹었어요. ~ \[As for me\], I ate an apple yesterday.

{{&lt; hlw "green" "저(는)" &gt;}} {{&lt; hlw "red" "사과(를)" &gt;}} {{&lt; hlw "pink" "어제" &gt;}} {{&lt; hll "blue" "먹" &gt;}}{{&lt; hlm "purple" "었" &gt;}}{{&lt; hlr "yellow" "어요" &gt;}}.

{{&lt; hlw "green" "subject + marker" &gt;}} {{&lt; hlw "red" "object + marker" &gt;}} {{&lt; hlw "pink" "adverb" &gt;}} {{&lt; hll "blue" "verb stem" &gt;}} {{&lt; hlm "purple" "past tense modifier" &gt;}} {{&lt; hlr "yellow" "politness conjugation" &gt;}}.

There’s already a lot going on here. The first difference you may notice is the markers. In English, one has to identify what the subject is. In Korean, topics and subjects are marked with 은/는 or 이/가, respectively. Objects get marked with 을/를. Just like the subject, these are not always necessary and get dropped in speech and texting all the time.

### Markers

Korean has a number of postpositional particles that imbue meaning, some of which vary if the last character is a vowel or not. We can easily use a pure function to model this:

    fn topic_marker(word: &str) -> &str {
      match word.last_character_type() {
        Vowel => "는",
        Consonant => "은"
      }
    }

    fn plural_marker() -> &str {
      "들"
    }

Here are a few other markers (with simplified definitions). The text inside the parentheses is used if the last character is a consonant:

-   ~에서 ⇒ from

-   ~까지 ⇒ until

-   ~(으)로 ⇒ several meanings. roughly-speaking it shows how/via what method or material something is carried out, or "toward" a place if used with "to go", etc.

### Pipelining Data Transformations

Where the previous sentence started to get interesting was at the end, with the verb, tense, and politeness. That’s not all we can transform though:

{{&lt; hlw "green" "나는" &gt;}} {{&lt; hlw "grey" "그" &gt;}} {{&lt; hlw "red" "문을" &gt;}} {{&lt; hll "blue" "닫" &gt;}}{{&lt; hlm "purple" "았" &gt;}}{{&lt; hlr "yellow" "어" &gt;}}. ~ {{&lt; hlw "green" "I" &gt;}} {{&lt; hlw "blue" "closed" &gt;}} {{&lt; hlw "grey" "the/that" &gt;}} {{&lt; hlw "red" "door" &gt;}}. ({{&lt; hlw "yellow" "impolite" &gt;}}, {{&lt; hlw "purple" "past tense marker" &gt;}})

{{&lt; hlw "green" "저는" &gt;}} {{&lt; hlw "grey" "그" &gt;}} {{&lt; hlw "red" "문을" &gt;}} {{&lt; hll "blue" "닫" &gt;}}{{&lt; hlm "purple" "았" &gt;}}{{&lt; hlr "yellow" "어요" &gt;}}. ~ {{&lt; hlw "green" "I (humble)" &gt;}} {{&lt; hlw "blue" "closed" &gt;}} {{&lt; hlw "grey" "the/that" &gt;}} {{&lt; hlw "red" "door" &gt;}}. ({{&lt; hlw "yellow" "polite" &gt;}}, {{&lt; hlw "purple" "past tense marker" &gt;}})

{{&lt; hlw "green" "우리 부모님은" &gt;}} {{&lt; hlw "grey" "그" &gt;}} {{&lt; hlw "red" "문을" &gt;}} {{&lt; hll "blue" "닫" &gt;}}{{&lt; hlm "orange" "으시" &gt;}}{{&lt; hlm "purple" "었" &gt;}}{{&lt; hlr "yellow" "습니다" &gt;}}. ~ {{&lt; hlw "green" "My parents (respectful)" &gt;}} {{&lt; hlw "blue" "closed" &gt;}} {{&lt; hlw "grey" "the/that" &gt;}} {{&lt; hlw "red" "door" &gt;}}. ({{&lt; hlw "orange" "honorific marker" &gt;}}, {{&lt; hlw "purple" "past tense marker" &gt;}}, {{&lt; hlw "yellow" "formal" &gt;}})

I’m showing {{&lt; hll "orange" "시" &gt;}}{{&lt; hlrw "purple" "었" &gt;}} here separately to break down the components but they would get merged to 셨.

The main verb here is 닫다–to close. All Korean verbs end in 다, so the first thing we need to do is get the stem by removing `다`.

Now we need the honorific level. In the first two sentences I’m talking about myself, so I can’t use honorifics. However when the actor is "my parents" it’s common to use honorifics, which is `~(으)시`.

Before we can add a tense, we need to determine what vowel to add, and if it should merge or not. 닫 ends in a consonant, so merging is not possible, but the last vowel is 아 so we append `아`. (If the verb stem ends in a vowel, like `가`, the following vowel `아` would just get merged into `가`)

One way to do past tense is `~ㅆ`, which gets merged with the previous vowel. Other tenses can depend on the last character being a vowel or not, like future tense (`~ㄹ/을`).

Finally, we need to think about our relationship to the audience and append or merge a politeness/speech level. See politeness below for more details.

We can model this as a basic pipeline à la Clojure:

    (defn conjugate-verb
      [subject verb speaker audience]
      (->> verb
        (remove-stem)
        (maybe-append-honorific subject)
        (append-or-merge-vowel)
        (append-or-merge-tense)
        (append-or-merge-politeness-level speaker audience)
      )
    )

There are even more transformations that we can apply depending on the grammar point and the nuance of what one is trying to say. Fun, isn’t it? At least it’s relatively consistent unlike English–even irregular verb rules are fairly regular.

### Adding to the Stack

In linguistics, nominalization or nominalisation is the use of a word which is not a noun (e.g., a verb, an adjective or an adverb) as a noun, … The term refers, for instance, to the process of producing a noun from another part of speech by adding a derivational affix (e.g., the noun legalization from the verb legalize).

In Korean, one can nominalize entire clauses and use them in other constructs! Korean lets you do this with the `~는 것` principle. 것 means thing, but any noun can be used in place of `것`. Based on the tense, verb type, and whether the verb ends in a vowel, `는` has variations like `~ㄴ`, and `은`. It can also combine with other grammar forms, like `던`, which is `더~ + ~ㄴ/은`. Digging into these would be beyond the scope of this post.

To give you a small example, one way to say "exit" in Korean is literally "going out place", or "a place that one goes out".

<figure>
<img src="https://s3.amazonaws.com/andrewzah.com/posts/008/exit.jpg" alt="A Korean subway exit sign." />
<figcaption>Source: Wikipedia 나가는 곳</figcaption>
</figure>

{{&lt; hlw "purple" "나가다" &gt;}} means "to go out". {{&lt; hlw "red" "곳" &gt;}} means place. Using the {{&lt; hlw "grey" "는 것" &gt;}} principle: A {{&lt; hll "purple" "나가" &gt;}}{{&lt; hlr "grey" "는" &gt;}} {{&lt; hlw "red" "곳" &gt;}} is a {{&lt; hlw "purple" "going out" &gt;}} {{&lt; hlr "red" "place" &gt;}}.

나가다 is a pure Korean word. To the right is 出口 (pronounced 출구), which also means exit, and is derived from classical Chinese. Just like English has Latin and Greek influences, Korean has Chinese and to a small extent, Japanese influences.

#### Sentence the First

So, let’s take ‘the girl walked to school’. In English and Korean this is straightfoward enough:

{{&lt; hlw "green" "여자는" &gt;}} {{&lt; hll "pink" "학교" &gt;}}{{&lt; hlr "purple" "로" &gt;}} {{&lt; hlw "blue" "걸어" &gt;}} {{&lt; hlw "blue" "갔어요" &gt;}} — {{&lt; hlw "green" "The girl" &gt;}} {{&lt; hlw "blue" "walked" &gt;}} {{&lt; hlw "purple" "to" &gt;}} {{&lt; hlrw "pink" "school" &gt;}}

But what if you wanted to talk *about* that person? You could say "the girl who walked to school". In English, this these are known as relative causes. They can begin with `who`, `which`, `that`, `where`, etc, following the noun. Korean uses the `~는 것` nominalizer *before* the noun, which leads to:

{{&lt; hll "pink" "학교" &gt;}}{{&lt; hlrw "purple" "로" &gt;}} {{&lt; hlw "blue" "걸어" &gt;}} {{&lt; hlw "orange" "간" &gt;}} {{&lt; hlrw "green" "여자" &gt;}}

`갔` changed to `간`. `갔` is 가다 (to go) + `~ㅆ` (past tense). But the past tense nominalization form uses `~ㄴ (것)`. Instead of 것 (thing) we swapped it for another noun—여자 (woman).

Not that one would only say "the girl who walked to school" by itself, but we can now use the entire construct as a noun in other sentences:

{{&lt; hlw "green" "저는" &gt;}} {{&lt; hlw "red" "학교로 걸어 간 여자를" &gt;}} {{&lt; hlrw "blue" "알았어요" &gt;}} — {{&lt; hlw "green" "I" &gt;}} {{&lt; hlw "red" "the girl who walked to school" &gt;}} {{&lt; hlrw "blue" "knew" &gt;}}

#### Sentence the Second

We can try a more complex sentence now: "That’s the place (that) I thought I went to!". First, we need to break it down in a sentence can that be nominalized. "I thought I went". Here we can use the grammar point `~ㄴ 줄 알다` which when used means the speaker thought something was true, but realized it wasn’t–due to a lapse in judgement, etc.

{{&lt; hlw "purple" "제가" &gt;}} {{&lt; hlw "red" "간 줄" &gt;}} {{&lt; hlrw "blue" "알다" &gt;}} – {{&lt; hlw "green" "I" &gt;}} {{&lt; hlw "blue" "thought" &gt;}} {{&lt; hlw "red" " that &gt;" &gt;}}{{&lt; hlw "purple" "I" &gt;}} {{&lt; hlw "red" "went" &gt;}}

You may have noticed that this grammar point itself uses `~ㄴ 것`, but with `줄` instead of 것! This 줄 is a bound noun, meaning that it can only be described by a `~는 것` clause. Outside of `~ㄴ 줄 알다`, 줄 can also be a regular noun meaning line/rope.

{{&lt; hlw "green" "그곳은" &gt;}} {{&lt; hll "red" "제가 어디에 간 줄 알았" &gt;}}{{&lt; hlrw "yellow" "던" &gt;}} {{&lt; hll "purple" "곳" &gt;}}{{&lt; hlrw "blue" "이야!" &gt;}} – {{&lt; hlw "green" "That" &gt;}} {{&lt; hlw "blue" "is" &gt;}} {{&lt; hlw "purple" "the place" &gt;}} {{&lt; hlr "red" "I thought I went to!" &gt;}}

#### Sentence the Third

Can we go even deeper?

{{&lt; hlw "green" "\[나는\]" &gt;}} (({{&lt; hll "blue" "상황이 억울하다고 말하는" &gt;}} {{&lt; hll "yellow" "불평불만" &gt;}}) {{&lt; hlrw "red" "만 하는 사람은" &gt;}}) {{&lt; hll "pink" "별로 좋아하" &gt;}}{{&lt; hlr "purple" "지 않는다" &gt;}}.

{{&lt; hlw "green" "\[I’m\]" &gt;}} {{&lt; hlw "purple" "not" &gt;}} {{&lt; hlr "pink" "keen on" &gt;}} ({{&lt; hlw "red" "people who only" &gt;}} ({{&lt; hlw "yellow" "complain" &gt;}}{{&lt; hlr "blue" "that things are unfair" &gt;}})).

This sentence doesn’t really translate 1:1 to English, as is the case with most intermediate/advanced Korean sentences.

Nominalizing with `~는 것` is my favorite aspect of Korean because it’s an important grammar point that blew my mind once I learned how it worked. It’s quite commonly used as well. In day to day usage I might say something like {{&lt; hlw "purple" "the house (that)" &gt;}} {{&lt; hlw "green" "I" &gt;}} {{&lt; hlw "red" "used to" &gt;}} {{&lt; hlw "blue" "live in &gt;" &gt;}} – {{&lt; hlw "green" "제가" &gt;}} {{&lt; hll "blue" "살" &gt;}}{{&lt; hlrw "red" "았던" &gt;}} {{&lt; hlr "purple" "집" &gt;}} et cetera.

### Language Tidbits

These are some cool traits about Korean, or things related to this post, that don’t necessarily have to deal with programming.

#### Politeness / Formality

The Korean language conjugates differently based on the status of speaker and intended audience. For example, one of the simplest ways to conjugate any verb is to add `~어/아/여` to it. This is based on the last *vowel*, not the last character.

For example, you may have seen 감사합니다 before ("thank you", formal polite). This is 감사하다, merged with `~ㅂ니다` because `하` ends in a vowel. 고마워요 is another way to say thank you(informal polite): 고맙다 + apply `irregular ㅂ` consonant ending filter + `~아/어/여요`.

    fn get_vowel_for_verb(verb: &str, formality: Formality) -> {
      // ha = 하
      if verb.stem_ends_with_ha() {
        "여"
      } else {
        match verb.last_vowel() {
          "아" => "아"
          "오" => "아"
          "어" => "어"
          "우" => "어"
          "이" => "어"
          "의" => "어"
          "위" => "어"
        }
      }
    }

Korean has [seven speech levels](https://en.wikipedia.org/wiki/Korean_speech_levels). When learning Korean, the `아/어/여요` and `~ㅂ/습니다` levels are commonly used, in that order. Using `아/어/여` (no `요`) to anyone other than close friends (who have agreed to use lowered speech) or young kids is rude. Foreigners get a pass at first but it’s still impolite.

Plain (sometimes known as diary) form is also used, such as in diaries and books/novels.

English lacks this concept, as we use the same conjugation for everyone – "the prisoner ate", "the king ate", and "a God ate". What English does have is [different registers](https://en.wikipedia.org/wiki/Register_(sociolinguistics)), such as when you text versus when you write an academic paper or a business email. This includes overly polite language like "Might you be interested in eating, sir?", but nevertheless the verb remains the same.

#### Quoting Statements

Quoting plain statements in Korean is very easy. All you need to do is take the sentence, conjugate the verb into plain form, and append `~고 (말)하다`. For verbs, `~ㄴ/는다` is the plain form. For adjectives, it’s just `다`, or the base verb.

{{&lt; hlw "green" "(저는)" &gt;}} {{&lt; hlw "blue" "먹었어요" &gt;}}. {{&lt; hlw "green" "(제가)" &gt;}} {{&lt; hll "blue" "먹었" &gt;}}{{&lt; hlrw "purple" "다고 말했다" &gt;}} – I ate. I said I ate.

Depending on the type of statement, different particles than 다 are used.

-   declarative ⇒ `다`

-   inquisitive ⇒ `냐`

-   propositive (let’s …) ⇒ `자`

-   imperative or ⇒ `라`

-   declarative with 이다 (to be) as the verb ⇒ `라`

이것을 좋아하다고? – (You said that) you like this?

Since this is used so much in speech, the (말)하다 (to say) part is often omitted. If you’re learning Korean, expect to hear this a lot from natives because Korean pronunciation is tough.

#### Lack of Romanization

Why does this article lack romanization? Because romanization is bad. English and Korean sounds do not map neatly to one another. The issue here is that Korean learners mentally map {some english sound} ⇒ {some hangeul letter} and it hurts their pronunciation skills immensely. For example, you may see this in beginner resources:

d = ㄷ

Except this is wildly wrong because only ㄷ is ㄷ. It is *close* to d, in the same sense that fresh water is *close* to salt water. Close enough, right? If you’re learning Korean, listen to videos that teach the sound, not the most approximte English letter.

I also have seen people write things like anyeonghasaeyo jal jinaeyo? or similar, and it hurts my brain and heart trying to read it.

Furthermore, romanization systems can change over time. 조 used to be romanized as Cho, now it’s Jo. So when I read older books that have romanized Korean it forces me to go and learn the older system as well. 조 isn’t Jo or Cho anyway… it’s somewhere in between.

## Contributors

-   Article – Andrew Zah

-   Editing, sentence suggestions – 웁스
