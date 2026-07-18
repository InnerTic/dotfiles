---
type: work-entry
id: 20260703-001
status: completed
confidence: high
time_spent: 3h
projects:
  - "[[Translation Pipeline]]"
daily:
  - "[[2026-07-03]]"
systems:
  - "[[llama.cpp]]"
scripts:
  - /mnt/workspace/Projects/translation/scripts/pipe.sh
  - /mnt/workspace/Projects/translation/scripts/parser.sh
  - /mnt/workspace/Projects/translation/scripts/glossary.sh
  - /mnt/workspace/Projects/translation/scripts/briefer.sh
  - /mnt/workspace/Projects/translation/scripts/translate.sh
  - /mnt/workspace/Projects/translation/scripts/stitch.sh
files:
  - /mnt/workspace/Projects/translation/Blue Magic/
  - /mnt/workspace/Projects/translation/Catastrophic Necromancer/
  - /mnt/workspace/Projects/translation/Dungeon/
  - /mnt/workspace/Projects/translation/Eerie - I Devour Without End/
  - /mnt/workspace/Projects/translation/Hyperdimensional Sorcerer/
  - /mnt/workspace/Projects/translation/The bell tolls for revenge/
  - /mnt/workspace/Projects/translation/zhys/
created_pages:
  - "[[2026-07-03]]"
  - "[[20260703-001-Translation-Library-Standardization]]"
updated_pages:
  - "[[AGENTS]]"
  - "[[Translation Pipeline]]"
tags:
  - translation
  - pipeline
  - standardization
  - web-novel
  - infrastructure
modified: 2026-07-03
---

# 20260703-001 — Translation Library Standardization

Date: 2026-07-03

## Goal

Standardize all 7 books under `/mnt/workspace/Projects/translation/` with a uniform pipeline structure so any book can be processed with the same commands and scripts.

## Approach

Each book was already at a different stage of completion — some had raw HTML, some had clean text, some had partial pipeline runs. The goal was not to process them all, but to make them all processable the same way.

## Done

### Directory structure

Created `raw/`, `clean/`, `chunks/`, `output/`, `canon/`, `work/` directories inside each of these books:

- Blue Magic (76 .htm files — Japanese, syosetu.com)
- Catastrophic Necromancer (4,851 .txt files — already analyzed and cleaned)
- Dungeon (269 .htm files)
- The bell tolls for revenge (288 .htm files)
- zhys (identified as duplicate)

Eerie and Hyperdimensional Sorcerer already had their structure from earlier work.

### Pipeline scripts

- Copied shared pipeline scripts (parser, glossary, briefer, translate, stitch) to each book's `scripts/`
- Created `pipe.sh` for each book — a role-based runner identical to Hyperdimensional Sorcerer's, using numbered role stages (0=parser, 1=glossary, 2=briefer, 3=translator, 4=editor, 5=script-checks, 6=style-auditor, 7=consistency, 8=verifier, 9=continuity)

### HTML extraction

- Added `./pipe.sh -1` role for HTML-to-text extraction, targeting books with raw .htm sources
- Moved 269 (Dungeon) + 288 (bell tolls) HTML files from book root into `raw/`

### Duplicate detection

- Identified zhys as a complete duplicate of "Eerie - I Devour Without End" — same Syosetu site IDs (80804287–83304294), same content, different filename
- Both point to same original, so zhys is redundant

## Book Inventory

| Book | raw | clean | pipe | notes |
|------|-----|-------|------|-------|
| Blue Magic | 76 .htm | — | Y | Japanese (syosetu.com), needs extract |
| Catastrophic Necromancer | 4,851 .txt | 4,851 | Y | English, already analyzed |
| Dungeon | 269 .htm | — | Y | Needs extract |
| Eerie - I Devour Without End | 567 | 566 | Y | Complete, just needs pipe.sh |
| Hyperdimensional Sorcerer | 4,436 | — | Y | Full pipeline running |
| The bell tolls for revenge | 288 .htm | — | Y | Needs extract |
| zhys | — | — | Y | Duplicate of Eerie |

## Decisions

**zhys as duplicate**: Rather than deleting zhys, left it in place with a note. Keeps the option to reference the original Eerie files if needed. No canonical mapping needed — same content.

**HTML extraction as role -1**: Added as a numbered role so it fits in the pipe.sh framework without modifying the core pipeline. `./pipe.sh -1 bookname` triggers extract before any model work.

**Per-book pipe.sh vs shared**: Chose per-book scripts so each book can override stages (e.g. skip roles for English books, change models, adjust ports). The shared `scripts/` directory holds the canonical versions; per-book copies can diverge.

## Next Steps

- Run extraction on HTML books (Blue Magic, Dungeon, The bell tolls)
- Run parser/briefer pipeline on extracted books
- Pipe.sh for Eerie (already clean, just needs the runner)
- Remove zhys or alias it formally
