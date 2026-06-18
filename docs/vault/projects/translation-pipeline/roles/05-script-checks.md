# Script Checks

**No GPU required** | **Deterministic only** (grep/awk/jq/sed/sort/uniq)

## Role

Runs against edited output before style audit. Catches mechanical issues that LLMs consistently miss. 100% deterministic — no model, no false positives from hallucination.

Checks against Unicode-normalized text (smart quotes → ASCII, em-dashes → hyphens, etc.):

- **Quote balance** — odd count = unclosed quote
- **Bracket balance** — `「` vs `」` mismatch
- **Japanese characters remaining** — CJK chars that weren't translated
- **Chinese characters remaining** — for JP projects, remaining CN chars
- **Repeated paragraphs** — exact duplicates
- **Name counts** — multiple variants of the same name (Alice vs Alicia)
- **Markdown code fences** — unclosed ``` blocks
- **Whitespace consistency** — mixed tabs/spaces, trailing whitespace
- **Honorific counts** — per honorific variant per character
- **Glossary term counts** — expected vs actual frequency
- **Dialogue count checks** — ratio of dialogue vs narration
- **Capitalization checks** — proper noun consistency
- **Duplicate sentence detection** — repeated sentences
- **Paragraph count** — expected vs actual

## Current Implementation

```bash
# Normalize
sed 's/[“”]/"/g; s/[‘’]/'"'"'/g; s/[—–]/-/g; s/[　]/ /g'

# Quote balance
grep -o '"' | wc -l            # expect even
grep -o "'" | wc -l            # expect even

# Japanese chars
grep -oP '[一-龯ぁ-んァ-ン]'     # expect empty

# Chinese chars (for JP projects)
grep -oP '[\u4e00-\u9fff]'    # expect empty

# Bracket balance
grep -o '「' | wc -l
grep -o '」' | wc -l           # expect equal

# Repeated paragraphs
sort | uniq -d

# Name counts
grep -oE 'Alice|Alicia|アリス' | sort | uniq -c

# Markdown code fences
grep -c '```'                  # expect even
```

## Alternatives

N/A — deterministic. Could be extended with additional checks but there's no model competition for this role.
