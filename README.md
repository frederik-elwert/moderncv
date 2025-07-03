Greetings, a Lua Filter Template
==================================================================

[![GitHub build status][CI badge]][CI workflow]

Greetings is a friendly Lua filter that adds a welcoming message
to the document.

[CI badge]: https://img.shields.io/github/actions/workflow/status/frederik-elwert/moderncv/ci.yaml?branch=main
[CI workflow]: https://github.com/frederik-elwert/moderncv/actions/workflows/ci.yaml


Usage
------------------------------------------------------------------

The filter modifies the internal document representation; it can
be used with many publishing systems that are based on pandoc.

### Plain pandoc

Pass the filter to pandoc via the `--lua-filter` (or `-L`) command
line option.

    pandoc --lua-filter moderncv.lua ...

### Quarto

Users of Quarto can install this filter as an extension with

    quarto install extension tarleb/moderncv

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
  word_document:
    pandoc_args: ['--lua-filter=moderncv.lua']
---
```

License
------------------------------------------------------------------

This pandoc Lua filter is published under the MIT license, see
file `LICENSE` for details.
