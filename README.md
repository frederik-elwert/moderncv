ModernCV, a Lua Filter for Academic CVs
==========================================

[![GitHub build status][CI badge]][CI workflow]

ModernCV is a Lua filter for pandoc that converts markdown CVs to PDF using the moderncv LaTeX package. It allows you to write academic CVs in markdown format with YAML metadata for personal information and definition lists for CV entries.

[CI badge]: https://img.shields.io/github/actions/workflow/status/frederik-elwert/moderncv/ci.yaml?branch=main
[CI workflow]: https://github.com/frederik-elwert/moderncv/actions/workflows/ci.yaml


Usage
------------------------------------------------------------------

The filter converts markdown CVs to LaTeX using the moderncv package. Personal information is specified in the YAML header, and CV entries are written as definition lists.

### Input Format

Create a markdown file with YAML metadata for personal information:

```yaml
---
name: "John Doe"
title: "Academic CV"
address: "123 University Ave, City, Country"
phone: "+1 234 567 8900"
email: "john.doe@university.edu"
homepage: "https://johndoe.com"
photo: "photo.jpg"
extrainfo: "Additional information"
---

# Education

2020-2024
:   PhD in Computer Science, University of Excellence
    Dissertation: "Advanced Topics in AI"

2018-2020
:   MSc in Computer Science, University of Technology

# Experience

2024-present
:   Assistant Professor, Department of Computer Science
    Research focus on machine learning and data analysis
```

### Plain pandoc

Pass the filter to pandoc via the `--lua-filter` (or `-L`) command
line option.

    pandoc --lua-filter moderncv.lua input.md -o output.pdf

### Quarto

Users of Quarto can install this filter as an extension with

    quarto install extension frederik-elwert/moderncv

and use it by adding `moderncv` to the `filters` entry
in their YAML header.

``` yaml
---
filters:
  - moderncv
---
```

### R Markdown

Use `pandoc_args` to invoke the filter. See the [R Markdown
Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/lua-filters.html)
for details.

``` yaml
---
output:
  pdf_document:
    pandoc_args: ['--lua-filter=moderncv.lua']
---
```

### Features

- **YAML metadata support**: Personal information like name, address, phone, email, homepage, photo, and extra info
- **Definition lists**: CV entries are written as markdown definition lists and converted to `\cvitem` commands
- **Section headers**: Markdown headers are automatically converted to LaTeX sections by pandoc
- **Template integration**: Uses pandoc's built-in LaTeX template with moderncv document class
- **Automatic styling**: Applies classic blue moderncv theme by default

License
------------------------------------------------------------------

This pandoc Lua filter is published under the MIT license, see
file `LICENSE` for details.
