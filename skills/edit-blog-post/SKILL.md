---
name: edit-blog-post
description: Edits a markdown or plain-text blog post draft for flow, consistency, grammar, spelling, readability, and structure, and flags places to add links to mentioned products/tools/resources. Use this whenever the user shares a blog post draft (or points to a .md/.txt file containing one) and asks for edits, feedback, a proofread, a review, or help polishing/tightening it before publishing — including phrasing like "can you edit this post", "proofread this", "does this flow well", "clean this up", or "is this ready to publish". Never silently changes the post's voice or tone, and never invents URLs for links — it asks or leaves a TODO instead. Produces both a lightly-corrected copy and a separate suggestions report, never a silent overwrite.
---

# Editing a blog post

You're doing a developmental + copy edit pass on someone's blog post, the way a
good editor at a publication would: fix what's objectively broken, flag what
needs the writer's judgment, and never quietly rewrite their voice.

## The core distinction: mechanical vs. judgment-call

Split every issue you find into two buckets. This split is the whole design
of this skill, so get it right:

**Mechanical fixes** — apply these silently to the edited copy. They don't
change what the writer is saying or how they sound, so they don't need
sign-off:
- Spelling and grammar errors (typos, subject-verb agreement, wrong word forms, punctuation)
- Formatting inconsistencies (mixed bullet styles, inconsistent bold/italic use, inconsistent code-span/code-block usage, heading levels that skip or are misused, e.g. `####` right after a `##`)
- Broken markdown syntax

**Judgment calls** — never apply these silently. Write them up in the
suggestions report instead and let the writer decide:
- Anything that touches voice or tone (word choice that makes the post sound more/less formal, more/less personal, etc.)
- Passive → active phrasing (this changes the rhythm of a sentence, which is a voice choice, not a correctness fix)
- Structural changes: reordering sections, cutting/expanding paragraphs, changing the intro or conclusion
- Adding a link (you don't know the right URL, and inserting one changes the reading experience)
- Flagging a claim as needing a citation (you're not verifying the claim, just noting it's unsupported)

The reasoning: a reader can't tell the difference between a fixed typo and
the writer's original intent, but they absolutely can tell when a sentence
has been rewritten in someone else's voice. When in doubt about which bucket
something belongs in, treat it as a judgment call — it's always safe to
*suggest* more than it is to *rewrite* more.

## Workflow

1. **Find the post.** If the user pointed you at a file, read it. If they
   pasted the text inline or it's ambiguous which file they mean, ask before
   guessing — don't edit the wrong draft.

2. **Read the whole thing once before touching anything.** You need the full
   arc of the post to judge flow, catch inconsistent terminology/tense/POV
   across sections, and know whether the conclusion actually pays off the
   intro. Editing section-by-section on a first pass misses exactly the kind
   of issue this skill exists to catch.

3. **Work through the checklist below**, sorting findings into the two
   buckets as you go.

4. **Produce two outputs**, next to the original file (same directory, based
   on its name — e.g. `my-post.md` → `my-post.edited.md` and
   `my-post.suggestions.md`):

   - **`<name>.edited.md`** — a copy of the post with *only* the mechanical
     fixes applied. Where you're flagging a possible link, insert an inline
     HTML comment right after the mention rather than a live link, e.g.
     `Stripe <!-- TODO: link to Stripe -->` — visible enough to spot when
     skimming the rendered file, invisible if published as-is by accident.
   - **`<name>.suggestions.md`** — the write-up of every judgment-call
     finding, using the report structure below.

   Never overwrite the original file. The writer should be able to diff
   `.edited.md` against the original and see *only* mechanical changes.

5. **Summarize in chat**: a one- or two-sentence overall impression, the
   count of mechanical fixes made, and the count of open judgment calls —
   then point at the two files. Don't paste the whole report into the chat
   too; that defeats the point of writing it to a file.

## The checklist

**Flow and consistency**
- Does each section lead logically into the next, or are there abrupt jumps that need a transition?
- Is terminology consistent (same name for the same thing throughout — don't let "sign-up" become "signup" become "registration" for the same concept)?
- Is tense and point-of-view consistent (don't let it drift from second-person "you" to first-person "we" without reason, or past tense to present)?

**Grammar and spelling**
- Standard proofreading: typos, punctuation, agreement, run-ons.

**Voice and tone (flag, never rewrite)**
- Note anywhere the writing tonally drifts from the rest of the post (e.g. one paragraph suddenly reads much more formal/casual than the rest) — that's worth flagging even though you won't fix it.

**Links for mentioned products/tools/resources**
- Any time the post names a specific product, library, company, or external resource, flag it as a link opportunity. Don't guess at or fabricate the URL — either ask the writer for the correct link, or leave the inline TODO comment described above and list it in the report.

**Passive voice**
- Point out sentences that lean on passive construction where an active rewrite would read more directly. Offer the suggested active phrasing in the report so the writer can copy it in if they agree — don't apply it yourself.

**Unsupported claims / statistics**
- Any number, statistic, or strong factual claim ("studies show...", "the fastest way to...") without a source should be flagged as needing a citation or a link to the source.

**Headings and scannability**
- Do headings/subheadings break the post into skimmable chunks? Flag long stretches of unbroken text in a post that's otherwise sectioned, or headings that are vague/inconsistent with each other in style.

**Intro and conclusion**
- Does the opening hook the reader and make clear what they'll get from the post? Does the ending land — a clear takeaway, or a call to action if the post is the kind that warrants one? Flag if either feels like it trails off.

**Paragraph and sentence length**
- Flag paragraphs or sentences that are long enough to hurt readability, especially if the post's overall style is otherwise punchy/short. This is about outliers, not a hard word-count rule — a 6-sentence paragraph might be fine in a long-form essay and too dense in a listicle.

**Formatting consistency**
- Bullet style, bold/italic usage, and code formatting (inline code spans vs. fenced blocks) should be applied the same way throughout. These are mechanical — fix them directly in the edited copy.

**Lightweight SEO sanity check**
- Is the title clear about what the post delivers? Would the opening 1-2 sentences work as a meta description if someone saw them in a search result — i.e., do they stand alone and convey the value of the post? This is a sanity check, not a full SEO audit — one or two notes, not a section with subsections.

## Suggestions report structure

Use this shape for `<name>.suggestions.md`. Skip any section with nothing to
report rather than writing "No issues found" — an empty report reads better
than a report padded with non-findings.

```markdown
# Edit suggestions: <post title>

One or two sentences: overall impression and the biggest lever for improvement, if any.

## Mechanical fixes applied
Brief bullet summary of what changed in the .edited.md copy (e.g. "Fixed 6
spelling/grammar issues, normalized bullet style in the 'Setup' section,
fixed a heading level skip after 'Getting Started'"). Point to the diff for specifics — don't relist every fix.

## Flow & structure
- [Location/quote] — issue — suggestion

## Voice & tone
- [Location/quote] — what feels inconsistent and why

## Suggested links
- "<mention>" — suggest linking to <what/where, or "needs URL from you">

## Unsupported claims
- [Location/quote] — what needs a source

## Readability
- Passive voice: [Location/quote] → suggested active phrasing
- Long paragraphs/sentences: [Location] — why it's worth tightening

## Headings & scannability
- Notes, if any

## Intro & conclusion
- Notes, if any

## SEO sanity check
- Title: note
- Opening (as meta description): note
```

For every "Location/quote" reference, quote enough of the original text (a
clause or short sentence) that the writer can find it with a search, rather
than a line number that shifts every time they edit.
