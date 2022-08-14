# documents

A collection of my personal documents typesetted in Pandoc Markdown


## Goals and Non-goals

- Goals
  - Reproducibly compile the documents
  - Support multiple output formats (see [Output Formats](#output-formats))
  - Provide sane global defaults across all the documents

- Non-goals
  - Write with fully portable markdown syntax
    - There isn't such a thing as portable markdown syntax
    - Pandoc Markdown with multiple filters is used


## Usage

- External dependencies
  - [Pandoc](https://pandoc.org)
  - [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref)
  - [pandoc-sidenote](https://github.com/jez/pandoc-sidenote)
  - GNU Make
- Each subdirectory under `src/` is a source document
  - Use `src/reference/` as a template
  - Create `src/*/defaults.yml` to override the global defaults (defined in `defaults/*.yml`)
- Compile with GNU Make
  - Example: `make reference-fancy` compiles `src/reference/` into a fancy pdf file
  - Example: `make reference-all` compiles `src/reference/` into all target formats


## Output Formats

- **Tier 1**: Self-contained output files with all features
  - pdf
  - html5
- **Tier 2**: Not fully self-contained / Some features like math may not be portable
  - docx (Problematic: math)
  - commonmark (Problematic: math)


## External Links

- [Pandoc](https://pandoc.org) ([manual](https://pandoc.org/MANUAL.html)) - The document converter used to build this project.
- [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref) ([manual](http://lierdakil.github.io/pandoc-crossref)) - A Pandoc filter for cross-references.
- [pandoc-sidenote](https://github.com/jez/pandoc-sidenote) - A Pandoc filter for template-specific sidenotes.
- [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template) - The template used for the "fancy" PDF outputs.
- [pandoc-markdown-css-theme](https://github.com/jez/pandoc-markdown-css-theme) - The template used for the Html outputs.
- [Zotero Style Repository](https://www.zotero.org/styles) - A collection of CSL citation styles.
