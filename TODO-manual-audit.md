# Metacheck Manual audit — to-do list

Generated 2026-10-02 by comparing every chapter in this book against the
current source of the metacheck package at
`C:\Users\dlakens\OneDrive - TU Eindhoven\git_repos\metacheck-new`.

**Comparison baseline — resolved.** The package repo was checked out on
branch `fix-441-shapefile-and-domain-data-extensions` (DESCRIPTION version
0.3.1) when this audit ran, not `main` (still 0.1.0) or `dev`. Confirmed with
the user: **`dev` is the intended reference** (it is about to be pushed to
`main`), and the audited branch differs from `dev` by exactly one unrelated
commit (file-extension classification rules), so the audit's findings stand.
One correction to the audit's own conclusion: `psychds_check` is not simply
"finished code the book wrongly calls unavailable" — development on it is
genuinely **paused** pending a decision on which metadata scheme to convert
to/validate against. The fix applied to that chapter's banner reflects this
(see item 1 below), not the audit's original "it's actually done" framing.

**Status:** Sections 1, 2, and 3 are done (fixed 2026-10-02), except for two
items deliberately left open per the user:
- `causal_claims` (section 2) stays undocumented — purely experimental,
  stays on `dev` only, not merged to `main`.
- The bibr/Scienceverse conversion backend (section 2) — skipped for now,
  no reason given yet; revisit when asked.

Everything else in this document is finished.

Severity key: **broken-example** (code in the book would error or silently
produce wrong output) · **outdated-info** (describes superseded behaviour) ·
**missing-content** (real feature/function not mentioned at all).

---

## 1. High-priority fixes (concrete bugs / actively misleading)

- [x] **mod-data-check.qmd — broken worked example (severe). Fixed
  2026-10-02.** Rebuilt the "File classification" section and worked
  example around the current 6-value vocabulary (`data, code,
  documentation, materials, output, unknown`), added the `doc_role`
  explanation, and rewrote the rule-order description (format rules →
  georeferenced rasters → JSON/XML name rules → category-word rules →
  coarse fallback) to match `R/data_check_helpers.R` exactly. Also fixed
  in the same pass: the two "forthcoming psychds_check/reproducibility_check"
  mentions in this chapter, the `skip_types = "asset"` example (now
  `"materials"`), and the incomplete `$traffic_light` description (red is
  a real outcome; the light is the worse of two separately computed
  halves).

- [x] **mod-psychds-check.qmd — banner needed a status correction.** ~~The
  audit agent read `inst/modules/psychds_check.R` (a complete 600-line
  file on `dev`) and concluded the module was working and just
  undocumented as such.~~ Corrected by the user: the file exists in source
  but development is **paused** — the project needs to settle on a
  metadata scheme to convert to/validate against before this can move
  forward; it is not simply "finished code waiting to be announced."
  **Fixed 2026-10-02**: rewrote the banner from "not yet available /
  forthcoming" to "development paused," explaining the metadata-scheme
  blocker and pointing readers interested in that question to Lisa
  DeBruine.

- [x] **creating-modules.qmd — template teaches a broken pattern. Fixed
  2026-10-02.** Changed the "Summary Table" example from `id` to
  `paper_id`, and added a callout explaining why the name matters
  (`module_run()` only merges a `summary_table` into the pipeline's master
  table when it finds a column named exactly `paper_id`; any other name is
  accepted silently and never merged). **Still open, package side, not
  fixed here:** `inst/templates/_module.R` in the metacheck package itself
  has the identical bug (`dplyr::count(table, id, ...)`) — flagged to the
  user; needs a decision on whether to open an issue or fix directly in
  that repo.

- [x] **mod-stat-p-nonsig.qmd — wrong boundary definition. Fixed
  2026-10-02.** Replaced "p ≥ .05" with the actual rule (significant when
  ≤ .05 *and* comparator is `<`, `=`, or `≤`/`<=`/`=<`; everything else is
  non-significant), including the `p = .05` edge case and the `≤`-as-`<`
  handling from NEWS 0.3.1.

- [x] **caching.qmd — wrong default and missing caches. Fixed
  2026-10-02.** This was a larger rewrite than the other items: fixed the
  `peek_zips` default (both `data_check` and `repo_check` are `TRUE`), and
  restructured the chapter around four on-disk caches instead of two —
  added full sections for the repository-listing cache
  (`repo_info_cache()`/`repo_info_cache_clear()`) and the zip-peek cache
  (`zip_peek_cache_clear()`), updated the opening summary, the cache
  location table, the "how the caches work together" walkthrough, and the
  closing summary table/principle paragraph throughout. Also added
  `repo_cache_clear()`'s `quiet` argument.

- [x] **llms.qmd — dead provider still listed as supported. Fixed
  2026-10-02.** Removed the `github` row from the providers table (current
  `.LLM_ALLOWED_PLATFORMS` excludes it; calling `llm_model("github")`
  errors) and added the two live providers the table was missing,
  `deepseek` and `portkey`.

- [x] **function-reference.qmd — generated page is stale. Fixed
  2026-10-02.** Extended `scripts/gen_function_reference.R`'s `families`
  list with the 34 exported functions it was missing (a new "Checking
  whether shared code reproduces the paper's results" family for all 13
  `repro_*` functions; the GitLab/DSpace/DataONE/Mendeley/FSD
  repository-backend functions added into the existing archives family;
  `llm_timeout`, `code_install_packages`, `data_read_head`,
  `stat_results_long`, `dryad_auth`, `repo_info_cache`/
  `repo_info_cache_clear`, `zip_peek_cache_clear`, and the operator
  `%empty_or%` into their respective existing families) and re-ran it
  against the `dev`-equivalent checkout. The page now correctly reports
  267 functions across 20 groups. Two functions (`llm_timeout`,
  `%empty_or%`) have no `.Rd` yet in source — they render with the
  script's existing "(no documentation found)" placeholder rather than
  breaking the build; `devtools::document()` on the package would resolve
  that (not run here, since it touches the package repo).

- [x] **local-files.qmd — wrong defaults for `osf_file_download()`. Fixed
  2026-10-02.** Rewrote the "Downloading OSF files to check locally"
  section to state the real defaults (`max_file_size`/`max_download_size`
  both `NULL`/no limit; neither applies under the default `mode = "all"`)
  and explain `mode = "select"` as the way to filter by size, matching how
  archiving-osf.qmd and uploading-to-zenodo.qmd already describe the same
  function. Also fixed a second stale claim found in the same chapter
  while on this pass — the intro said GitLab/Figshare/Dataverse are
  "not yet supported automatically," which is no longer true — and added
  the `report_repository()` mention this chapter was missing (see item 2
  below).

---

## 2. Missing documentation of entire modules/features

- [x] **`funding_check_oi`** — an "overinclusive" variant of `funding_check`
  (`inst/modules/funding_check_oi.R`). **Fixed 2026-10-02**: added a
  subsection to mod-funding-check.qmd explaining the trade-off (a much
  looser two-word-list match instead of ~36 targeted patterns), a tested
  worked example, and the mechanical note that both versions define a
  function of the same name internally (`funding_check()`) — only the
  filename passed to `module_run()` decides which one runs;
  `module_list()` shows them as separate entries ("Funding Check" vs.
  "Funding Check (Overinclusive)").

- [x] **`coi_check_oi`** — same pattern, for `coi_check`
  (`inst/modules/coi_check_oi.R`). **Fixed 2026-10-02**: added the
  matching subsection to mod-coi-check.qmd, tested against the demo paper,
  with the same filename-vs-function-name clarification.

- [x] **`causal_claims`** — decided by the user: this module is purely
  experimental and will remain on `dev` only, not merged to `main`. **Not
  documenting it** — leaving `mod-marginal.qmd` as is (it already
  correctly documents only `marginal`, not `causal_claims`, and was never
  wrong about this).

- [ ] **`ref_miscitation`** — exists in `inst/modules/` with no chapter.
  Investigated and confirmed genuinely separate from `ref_accuracy`/
  `ref_consistency` (matches cited DOIs against a curated
  commonly-miscited-papers database). Its own roxygen says it's "just a
  proof of concept — the database is not yet populated with real
  examples," and it's absent from `report()`'s default module battery and
  from `mod-ref-summary.qmd`'s aggregation list. Low priority — flag as a
  known gap to revisit only once/if it's populated and promoted out of POC
  status; not currently misleading to leave undocumented.

- [x] **`report_repository()`** (added 0.2.1) — a one-line wrapper that runs
  `repo_check`/`code_check`/`data_check`/`codebook_check` on a local folder
  with no manuscript needed. Already used correctly in archiving-osf.qmd
  and uploading-to-zenodo.qmd. **Fully fixed 2026-10-02**:
  - local-files.qmd: callout near the top, plus a worked example at the
    end, right after the manual `module_run()` pattern it simplifies.
  - get-started.qmd: new "Starting from a manuscript, or from a folder"
    section right after the `report_app()` walkthrough, introducing
    `report_repository()` as the folder-based sibling entry point to
    `report()`/`report_app()`.
  - mod-repo-check.qmd, mod-data-check.qmd, mod-code-check.qmd,
    mod-codebook-check.qmd: each got a one-line pointer to
    `report_repository()` right where that chapter already discusses
    `local_path`/`local_only`, noting it bundles all four modules.

- [ ] **Deferred — skip for now, per the user (2026-10-02).**
  **bibr/Scienceverse conversion backend** (`R/import-bibr.R`,
  `convert_bibr()`) — a parallel conversion path to GROBID that also
  handles DOC/DOCX (which GROBID cannot), auto-detected as a fallback by
  `convert()`. Not mentioned in get-started.qmd or reading-a-paper.qmd,
  both of which describe `convert()` purely through the GROBID/XML lens.
  Related latent gotcha: when `convert()` dispatches to the bibr backend,
  the `crossref_lookup` argument is silently dropped (not a documented
  parameter of `convert_bibr()`) — worth a caveat if this section is added.

---

## 3. Missing coverage of specific new arguments/functions within

existing, otherwise-correct chapters

- [x] **text-search.qmd — Fixed 2026-10-02.** Added `"header"`/`"paper_id"`
  to the documented `return` values, and a new "What gets searched"
  subsection covering `search_header` and `include_refs`, each tested
  against `demopaper()` before writing.

- [x] **llms.qmd — Fixed 2026-10-02.** Added a "Request timeout" section
  for `llm_timeout()` (between "Rate limiting" and "Response length") and
  a paragraph on `capture_reasoning` in the "Reasoning effort" section.

- [x] **ollama.qmd — Fixed 2026-10-02.** Added an `llm_timeout()` bullet
  directly under "The model seems to freeze or takes very long"
  (previously gave only generic wait-and-see advice), plus a new
  "Quick reference" subsection covering `llm_reasoning()`'s Ollama-specific
  `think` mapping and `llm_max_tokens()`.

- [x] **mod-power.qmd — Fixed 2026-10-02.** Added a clarifying note at the
  chapter's first worked example (confirmed by running it: `complete` is
  `NA` for every row with no LLM enabled) and corrected the later claim
  that `complete` "flags" incomplete analyses to note the LLM
  prerequisite.

- [x] **mod-stat-check.qmd — Fixed 2026-10-02.** Added the module's own
  documented running-text-only limitation.

- [x] **mod-stat-p-exact.qmd — Fixed 2026-10-02.** Added the
  case-insensitive upper-case "P" note.

- [x] **mod-stat-effect-size.qmd — Fixed 2026-10-02.** Added a parenthetical
  noting the unused `d_implied_paired_drm_r05` column.

- [x] **mod-code-check.qmd** and **importing-exporting.qmd** — "forthcoming
  reproducibility_check" wording. **Already fixed** as a side effect of
  section 1's mod-data-check.qmd rebuild (both changed to present tense).

- [x] **mod-reproducibility-check.qmd — Fully fixed 2026-10-02.** "~650" →
  "~750"; `collect_module_tables()` call now correctly prefixed
  `metacheck:::` with an explanatory note; added `cache`, `download`,
  `skip_types`, `peek_zips`, `max_file_size`, `max_download_size`,
  `skip_on_api_limit`, and `tables_dir` to the Options table (with a
  callout on the LLM-cache-key interaction); added `$modifications` to
  "What you get back"; added the Bioconductor (`"bioc"`) source tag to the
  `repro_dependencies()` description.

- [x] **mod-codebook-check.qmd — Fixed 2026-10-02.** Replaced the single
  `"conflicted"` value with the two real ones (`conflicting_definition`,
  `ambiguous_experiment`), with an explicit note that code filtering on
  `"conflicted"` alone will match nothing; replaced `scale_source ==
  "dictionary"` with `"matched"` and added the related `"task_matched"`
  value.

- [x] **mod-data-check.qmd / mod-psychds-check.qmd** — `skip_types =
  "asset"` → `"materials"`. **Already fixed** in section 1.

- [x] **mod-data-check.qmd** — `$traffic_light` red/worst-of-both-halves
  nuance. **Already fixed** in section 1.

- [x] **osf-schemas.qmd — Fixed 2026-10-02.** Rewrote the `q25`-heuristic
  sentence in the past tense, as an explanation of why `schema_id`
  dispatch was adopted, rather than describing it as a live bug the
  switch would fix. (The separate suggestion of adding a regeneration
  script for this page, or keeping its snapshot date more prominent, was
  not acted on — flagged here as a possible future improvement, not a
  correctness issue.)

---

## 4. Confirmed clean (no action needed)

For completeness — these were audited in full and found to already match
current source exactly, so they do not need to be in the work queue:

- intro.qmd (pure narrative, no technical claims)
- reading-a-paper.qmd (aside from the bibr-backend gap above)
- papers-databases.qmd
- mod-prereg-check.qmd, mod-reg-check.qmd, mod-ethics-check.qmd,
  mod-open-practices.qmd, mod-marginal.qmd
- mod-stat-p-exact.qmd (aside from the very minor note above)
- mod-ref-consistency.qmd, mod-ref-pubpeer.qmd, mod-ref-retraction.qmd,
  mod-ref-replication.qmd, mod-ref-accuracy.qmd, mod-ref-summary.qmd
- creating-a-report.qmd
- mod-repo-check.qmd
- mod-data-validate.qmd
- importing-exporting.qmd (aside from the "forthcoming" wording fix above)
- archiving-osf.qmd, uploading-to-zenodo.qmd

---

## Suggested order of attack

1. Section 1 (high-priority: the broken example, the misleading psychds
   banner, the template bug, the boundary error, the cache/provider/
   reference-page staleness, the OSF-download defaults) — these are
   concrete, checkable, and either produce wrong output or actively
   mislead a reader.
2. Section 2's `report_repository()` and bibr-backend additions — these
   are the missing-content items most likely to actually help a reader
   doing real work, not just plug a documentation gap.
3. Section 2's two "_oi" module variants and `causal_claims` — each is a
   self-contained new subsection, not a rewrite.
4. Section 3, chapter by chapter, roughly in the order listed.
5. Revisit `ref_miscitation` and the FSD repo-platform note only if/when
   those features graduate out of proof-of-concept status in the package.
