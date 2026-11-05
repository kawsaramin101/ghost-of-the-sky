# Age-tier writing guide (for story, trivia and UI text)

Tier is chosen in `lib/app_state.dart` (`kYoungMaxAge = 9`). Content JSON uses the keys `young` and `older`.
Both tiers must contain the same facts; only the wording changes. Use `{name}` where we address the user.

| | `young` (age 4-9) | `older` (age 10+) |
|---|---|---|
| Sentence length | 8-12 words, 1-2 sentences per card | Up to 3-4 sentences per card |
| Words | Everyday words only; explain nothing technical | Real terms, each explained once in plain words (e.g. "regolith: the loose dust on the surface") |
| Voice | Playful, questions, sounds, first person from the craft ("I landed here in 1969!") | Still first person for key stories, but calmer, with dates, numbers and cause -> effect |
| Quiz | Pick-the-picture or 2-option questions | 3-4 option questions, one "why" question |
| Bengali | Spoken style (চলিত), "তুমি", short words | Spoken style (চলিত) with standard terms; English term in brackets the first time |

Rules for both: every fact comes from a NASA source listed in the artifact's `sources`; no invented dialogue presented as real history.
Bengali text must be reviewed by a native speaker before submission.
