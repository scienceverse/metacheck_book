## Generates chapters/function-reference.qmd from the package's .Rd files.
## Source of truth: man/*.Rd (roxygen2-generated). Run from the metacheck_book repo root,
## with a sibling ../metacheck checkout providing NAMESPACE + man/.
##
## When metacheck gains or loses an exported function, this script's family
## sanity check will stop() rather than silently render an incomplete page:
## add the new name to the right family list below (or a new family, if it
## does not fit an existing one), then re-run.

pkg_dir  <- "../metacheck"
man_dir  <- file.path(pkg_dir, "man")
ns_file  <- file.path(pkg_dir, "NAMESPACE")

## ---- 1. exported, non-dot, non-operator function names ----
ns_lines <- readLines(ns_file)
export_lines <- grep("^export\\(", ns_lines, value = TRUE)
exported <- gsub('^export\\("?([^")]+)"?\\)$', "\\1", export_lines)
public <- exported[!grepl("^[.]", exported) & exported != "%||%"]
public <- sort(public)

## ---- 2. parse each .Rd into title/description/usage/value ----
## Some exported names are documented as an \alias on a DIFFERENT .Rd page
## (e.g. expand_text is an alias on text_expand.Rd). Build a name -> path
## lookup from every .Rd's \alias{} entries so those resolve correctly.
all_rd <- list.files(man_dir, pattern = "\\.Rd$", full.names = TRUE)
alias_index <- new.env()
for (path in all_rd) {
  txt <- readLines(path, warn = FALSE)
  aliases <- gsub("^\\\\alias\\{(.*)\\}$", "\\1", grep("^\\\\alias\\{", txt, value = TRUE))
  for (a in aliases) assign(a, path, envir = alias_index)
}

## Recursively render a parsed Rd node to Markdown, handling the tag types
## actually used in this package's \description and \value fields (\code,
## \link and \link[=target]{text}, \emph, \strong, \url, \href, \itemize/
## \item, \preformatted). A plain as.character() flatten mishandles \link,
## turning it into literal "list(...)" text, so this walks the tree instead.
rd_to_md <- function(node) {
  tag <- attr(node, "Rd_tag")
  if (is.null(tag)) tag <- ""

  render_children <- function(n) paste(vapply(n, rd_to_md, character(1)), collapse = "")

  switch(tag,
    "TEXT" = ,
    "RCODE" = ,
    "VERB" = as.character(node),
    "\\code" = paste0("`", render_children(node), "`"),
    "\\verb" = paste0("`", render_children(node), "`"),
    "\\preformatted" = paste0("\n```\n", render_children(node), "\n```\n"),
    "\\emph" = paste0("*", render_children(node), "*"),
    "\\strong" = paste0("**", render_children(node), "**"),
    "\\url" = paste0("<", render_children(node), ">"),
    "\\href" = {
      target <- rd_to_md(node[[1]])
      text <- render_children(node[[2]])
      paste0("[", text, "](", target, ")")
    },
    ## link text is usually already wrapped in \code{} at the source, so
    ## just pass the rendered text through rather than adding more backticks
    "\\link" = render_children(node),
    "\\itemize" = paste0("\n", render_children(node), "\n"),
    "\\enumerate" = paste0("\n", render_children(node), "\n"),
    "\\item" = paste0("\n- ", render_children(node)),
    "\\dontrun" = render_children(node),
    "\\if" = "",
    "\\out" = "",
    ## default: recurse into children if it has any, else drop
    if (is.list(node)) render_children(node) else ""
  )
}

rd_info <- function(name) {
  path <- if (exists(name, envir = alias_index, inherits = FALSE)) {
    get(name, envir = alias_index, inherits = FALSE)
  } else {
    file.path(man_dir, paste0(name, ".Rd"))
  }
  if (!file.exists(path)) return(NULL)
  rd <- tools::parse_Rd(path)
  tags <- vapply(rd, function(x) attr(x, "Rd_tag"), character(1))

  get_text <- function(tagname) {
    idx <- which(tags == tagname)
    if (!length(idx)) return(NA_character_)
    txt <- rd_to_md(rd[[idx[1]]])
    txt <- gsub("[ \t]+", " ", txt)
    txt <- gsub(" *\n *", "\n", txt)
    txt <- gsub("\n{3,}", "\n\n", txt)
    trimws(txt)
  }

  title <- get_text("\\title")
  description <- get_text("\\description")
  usage <- get_text("\\usage")
  value <- get_text("\\value")

  list(title = title, description = description, usage = usage, value = value)
}

info <- setNames(lapply(public, rd_info), public)
missing_rd <- public[vapply(info, is.null, logical(1))]
if (length(missing_rd)) {
  message("No .Rd found for: ", paste(missing_rd, collapse = ", "))
}

## ---- 3. family assignment ----
## Every public export must land in exactly one family. Families mirror the
## task-oriented grouping of the hand-written appendix, extended to cover
## subsystems that appendix never documented (data checks, stat-output
## import/export, regcheck, cache management), and with the six archive
## integrations merged into one family instead of split per repository.
families <- list(
  "Getting a paper to work with" = c(
    "demopaper", "test_paper", "demofile", "read", "paper", "paperlist",
    "paper_id", "paper_table", "ref_table", "paper_validate", "paper_write",
    "fig_image_view"
  ),
  "Managing collections of papers" = c(
    "papers_load", "papers_available", "papers_metadata", "papers_remove"
  ),
  "Importing papers from PDFs and XML" = c(
    "convert", "convert_grobid", "convert_bibr", "grobid_to_bibr",
    "format_bib_authors"
  ),
  "Searching and extracting from the text" = c(
    "search_text", "text_search", "expand_text", "text_expand", "text_peek",
    "extract_eq", "extract_p_values", "extract_urls", "extract_tests",
    "stats", "json_expand", "causal_relations"
  ),
  "Running checks (modules)" = c(
    "module_list", "module_run", "module_help", "module_info",
    "module_template", "get_prev_outputs"
  ),
  "Building a report" = c(
    "report", "report_module_run", "module_report", "report_qmd",
    "report_app", "report_repository"
  ),
  "Report-building helpers" = c(
    "scroll_table", "report_table", "collapse_section", "link", "plural",
    "format_ref"
  ),
  "Looking up DOIs and bibliographic metadata" = c(
    "doi_clean", "doi_valid_format", "doi_resolves", "doi_lookup",
    "crossref_doi", "crossref_query", "openalex_doi", "openalex_query",
    "datacite_doi", "add_bib_match"
  ),
  "Databases of comments, replications, retractions" = c(
    "pubpeer_comments", "FLoRA", "FLoRA_update", "FLoRA_date",
    "retractionwatch", "rw", "rw_update", "rw_date"
  ),
  "Preregistration comparison (regcheck)" = c(
    "regcheck_compare", "regcheck_tidy", "regcheck_base_url",
    "regcheck_setup_local", "regcheck_start_local", "regcheck_stop_local"
  ),
  "Finding and downloading files from repository archives" = c(
    "osf_links", "osf_info", "osf_file_download", "osf_type",
    "osf_check_id", "osf_api_check", "osf_delay", "osf_get_all_pages",
    "osf_preprint_list", "osf_pat", "osf_app", "osf_cache_clear",
    "osf_user_projects",
    "github_links", "github_info", "github_repo", "github_files",
    "github_languages", "github_readme", "github_tree_files",
    "zenodo_links", "zenodo_info", "zenodo_file_download", "zenodo_pat",
    "zenodo_upload",
    "rbox_links", "rbox_info", "rbox_file_download",
    "aspredicted_links", "aspredicted_info",
    "dataverse_links", "dataverse_info", "dataverse_file_download",
    "dataverse_pat",
    "dryad_links", "dryad_info", "dryad_file_download", "dryad_pat",
    "figshare_links", "figshare_info", "figshare_file_download",
    "figshare_pat",
    "reshare_links", "reshare_info", "reshare_file_download",
    "researchdata4tu_links", "researchdata4tu_info",
    "researchdata4tu_file_download", "researchdata4tu_pat",
    "psycharchives_links", "psycharchives_info",
    "psycharchives_file_download",
    "local_files", "download_repo_files",
    "repo_cache_clear", "repo_cache_dir", "repo_cache_size"
  ),
  "Asking a large language model" = c(
    "llm", "llm_use", "llm_model", "llm_model_list", "llm_max_calls",
    "llm_max_tokens", "llm_reasoning", "llm_cache", "llm_cache_clear",
    "metacheck_cache_info"
  ),
  "Checking shared code" = c(
    "code_read", "code_parse_r", "code_remove_comments", "code_abs_path",
    "code_extract_py", "code_extract_qmd_py", "code_extract_r",
    "code_file_refs", "code_lang", "code_library_lines",
    "code_library_names", "code_line_stats", "code_packages", "code_setwd"
  ),
  "Checking shared data" = c(
    "data_check_case_issues", "data_check_colname",
    "data_check_colname_collisions", "data_check_constant",
    "data_check_demographic", "data_check_design_name",
    "data_check_empty", "data_check_is_behaverse",
    "data_check_is_inquisit", "data_check_is_jspsych",
    "data_check_is_psychopy", "data_check_is_qualtrics",
    "data_check_numeric_in_text", "data_check_outliers",
    "data_check_pii_freetext", "data_check_pii_geo",
    "data_check_pii_name", "data_check_pii_values",
    "data_check_scale_values", "data_check_spss_filter",
    "data_check_whitespace", "data_classify_files", "data_col_concept",
    "data_col_facets", "data_col_stats", "data_col_type", "data_format",
    "data_group_llm", "data_is_manifest", "data_promote_header_row",
    "data_strip_qualtrics_header", "data_study_roster", "parse_codebook",
    "parse_qsf", "manifest_merge", "match_column_labels"
  ),
  "Importing and exporting statistical output" = c(
    "import_jasp", "import_omv", "import_mplus_output",
    "import_stata_smcl", "import_spv", "export_jasp_html",
    "export_omv_html", "export_mplus_html", "export_stata_smcl_html",
    "export_spv_html", "read_stat_tables", "read_r_output",
    "stat_output_json", "stat_output_validate", "stat_output_write",
    "stato_type_column", "match_reported_output"
  ),
  "ORCID and contributor info" = c(
    "check_orcid", "get_orcid", "orcid_person", "credit_roles"
  ),
  "File types" = c(
    "filetype", "file_category", "txt_classify_content",
    "check_file_naming", "zip_peek", "zip_decision"
  ),
  "Validation utilities" = c(
    "validate", "accuracy", "cap_gate_count"
  ),
  "General utilities" = c(
    "email", "online", "verbose", "pb", "rep_if", "path_sanitize",
    "message", "logger", "logpath", "lastlog"
  )
)

## sanity: every public export assigned exactly once, nothing invented
assigned <- unlist(families, use.names = FALSE)
dupes <- assigned[duplicated(assigned)]
if (length(dupes)) stop("Duplicate assignment: ", paste(dupes, collapse = ", "))
unknown <- setdiff(assigned, public)
if (length(unknown)) stop("Assigned but not exported: ", paste(unknown, collapse = ", "))
unassigned <- setdiff(public, assigned)
if (length(unassigned)) stop("Exported but not assigned to a family: ", paste(unassigned, collapse = ", "))
message("All ", length(public), " public exports assigned across ", length(families), " families. OK.")

## ---- 4. render markdown ----
esc <- function(x) {
  if (is.na(x) || !nzchar(x)) return("")
  x
}

lines <- c(
  "---",
  'title: "Function reference"',
  "---",
  "",
  "This appendix lists every exported function in Metacheck, generated directly",
  "from the package's roxygen documentation (the same source `?function_name`",
  "reads from). It is grouped by task rather than alphabetically, so functions",
  "used together stay together. Unlike a hand-written summary, this page is",
  "regenerated from source and cannot drift out of sync with the installed",
  "package's actual exports.",
  "",
  paste0("As of this build, that is **", length(public), " functions** across **",
         length(families), " groups**."),
  ""
)

for (fam in names(families)) {
  lines <- c(lines, paste0("## ", fam), "")
  fns <- families[[fam]]
  for (fn in fns) {
    x <- info[[fn]]
    if (is.null(x)) {
      lines <- c(lines, paste0("**`", fn, "()`** — *(no documentation found)*"), "")
      next
    }
    usage <- esc(x$usage)
    desc <- esc(x$description)
    title <- esc(x$title)
    value <- esc(x$value)

    ## title and description are often identical short phrases in this
    ## package's roxygen comments; showing both would just repeat the line
    same_text <- nzchar(title) && nzchar(desc) &&
      tolower(sub("[.]$", "", title)) == tolower(sub("[.]$", "", desc))

    header <- paste0("### `", fn, "`")
    lines <- c(lines, header, "")
    if (nzchar(title)) lines <- c(lines, paste0("*", title, "*"), "")
    if (nzchar(usage)) {
      lines <- c(lines, "```r", usage, "```", "")
    }
    if (nzchar(desc) && !same_text) lines <- c(lines, desc, "")
    if (nzchar(value)) lines <- c(lines, paste0("**Returns:** ", value), "")
  }
}

out_path <- "chapters/function-reference.qmd"
writeLines(lines, out_path)
message("Wrote ", out_path, " (", length(lines), " lines).")
