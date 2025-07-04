ModernCV, a Lua Filter for Academic CVs
==========================================

[![GitHub build status][CI badge]][CI workflow]

ModernCV is a Lua filter for pandoc that converts markdown CVs to PDF using the moderncv LaTeX package. It allows you to write academic CVs in markdown format with YAML metadata for personal information and definition lists for CV entries.

[CI badge]: https://img.shields.io/github/actions/workflow/status/frederik-elwert/moderncv/ci.yaml?branch=main
[CI workflow]: https://github.com/frederik-elwert/moderncv/actions/workflows/ci.yaml


Usage
------------------------------------------------------------------

The filter converts markdown CVs to LaTeX using the moderncv package. Personal information is specified in the YAML header, and CV entries are written as definition lists.

### Writing Your CV

Create a markdown file with your personal information in the YAML header and your CV content in markdown:

```yaml
---
name: "_Dr._ Jane Smith"
title: "Curriculum Vitae"
address:
  - "456 Research Blvd"
  - "Academic City, AC 12345"
phone: "+1 555 123 4567"
email: "jane.smith@university.edu"
homepage: "https://janesmith.me"
photo: "profile.jpg"
social:
  github: jane-doe
  orcid: 0000-0000-0000-0000
cvcolor: green
---

# Academic Positions

2020-present
:   **Associate Professor**, Department of Mathematics
    University of Excellence

2015-2020
:   **Assistant Professor**, Department of Mathematics
    University of Technology

# Education

2015
:   **PhD in Mathematics**, Institute of Advanced Studies
    Dissertation: "Complex Analysis in Modern Applications"

2010
:   **MSc in Mathematics**, State University
```

#### Personal Information

Add your personal details in the YAML header. All fields are optional, and you can use markdown formatting (like `_italic_` or `**bold**`) in any field:

- `name`: Your name
- `title`: Document title 
- `address`: Your address (can be a single line or a list for multi-line formatting)
- `phone`: Phone number (or multiple numbers - see advanced usage below)
- `email`: Email address
- `homepage`: Personal website
- `photo`: Photo filename
- `social`: Social media accounts (see examples below)
- `born`: Birth date (optional)
- `quote`: Personal quote (optional)
- `extrainfo`: Any additional information

#### CV Content

Write your CV sections using standard markdown. Use definition lists (with `:`) for dated entries:

```markdown
# Section Name

Date or period
:   **Position or degree**, Institution or organization
    
    Optional description or details
```

#### Advanced Features

**Multiple addresses or phone numbers:**
```yaml
address:
  - "Street address"
  - "City, State ZIP"
  - "Country"

phone:
  mobile: "+1 555 123 4567"
  office: "+1 555 987 6543"
```

**Social media accounts:**
```yaml
social:
  github: your-username
  orcid: 0000-0000-0000-0000
  linkedin: your-profile
  twitter: your-handle
```

**Styling options:**
You can customize the appearance by setting `cvstyle` and `cvcolor`. See the [moderncv documentation](https://ctan.org/pkg/moderncv) for available options.

```yaml
cvstyle: classic    # casual, classic, banking, oldstyle, fancy, contemporary
cvcolor: blue       # blue, green, red, purple, grey, orange, burgundy, black
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
