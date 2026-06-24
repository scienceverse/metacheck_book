# The metacheck Book

Source for the online book documenting the [metacheck](https://github.com/scienceverse/metacheck) R package, built with [Quarto](https://quarto.org).

The book collects the package's vignettes and documentation into a single
structured, browsable resource.

## Building locally

You need [Quarto](https://quarto.org/docs/get-started/) and an R installation
with the `metacheck` package available:

``` r
pak::pkg_install("scienceverse/metacheck")
```

Then render the book:

``` bash
quarto render
```

The rendered site is written to `docs/` (configured in `_quarto.yml`), which can
be served by GitHub Pages.

### Code execution

Chapters are configured with `execute: freeze: true`. Quarto will only re-run a
chapter's R code when that chapter's source changes, using the cached output in
`_freeze/` otherwise. This keeps routine rebuilds fast and avoids re-running
network- or LLM-dependent code on every render.

To force a full re-execution, delete the `_freeze/` directory before rendering.

## Structure

- `index.qmd` — landing page.
- `chapters/` — the polished chapters (sourced from the package vignettes).
- `drafts/` — work-in-progress and reference material from the package
  `_stuff/` folder; not guaranteed to render cleanly.
- `images/` — figures used by chapters.
- `include/book.bib` — merged bibliography for the whole book.
- `include/apa.csl` — APA 7th edition citation style.
- `theme.scss` — metacheck-branded styling.

## License

Content follows the licensing of the metacheck package and its vignettes.
