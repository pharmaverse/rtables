# Constructing rtables Manually

## Overview

The main functions currently associated with `rtable`s are

Tables in `rtables` can be constructed via the layout or `rtabulate`
tabulation frameworks or also manually. Currently manual table
construction is the only way to define column spans. The main functions
for manual table constructions are:

- [`rtable()`](https://pharmaverse.github.io/rtables/reference/rtable.md):
  collection of
  [`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md)
  objects, column header and default format
- [`rrow()`](https://pharmaverse.github.io/rtables/reference/rrow.md):
  collection of
  [`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md)
  objects and default format
- [`rcell()`](https://pharmaverse.github.io/rtables/reference/rcell.md):
  collection of data objects and cell format

## Simple Example

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`

`tbl`` ``<-`` `[`rtable`](https://pharmaverse.github.io/rtables/reference/rtable.md)`(`` `` header ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Treatement\nN=100"``, ``"Comparison\nN=300"``)``,`` `` format ``=`` ``"xx (xx.xx%)"``,`` `` `[`rrow`](https://pharmaverse.github.io/rtables/reference/rrow.md)`(``"A"``, `[`c`](https://rdrr.io/r/base/c.html)`(``104``, ``.2``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``100``, ``.4``)``)``,`` `` `[`rrow`](https://pharmaverse.github.io/rtables/reference/rrow.md)`(``"B"``, `[`c`](https://rdrr.io/r/base/c.html)`(``23``, ``.4``)``, `[`c`](https://rdrr.io/r/base/c.html)`(``43``, ``.5``)``)``,`` `` `[`rrow`](https://pharmaverse.github.io/rtables/reference/rrow.md)`(``)``,`` `` `[`rrow`](https://pharmaverse.github.io/rtables/reference/rrow.md)`(``"this is a very long section header"``)``,`` `` `[`rrow`](https://pharmaverse.github.io/rtables/reference/rrow.md)`(``"estimate"``, `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(``55.23``, ``"xx.xx"``, colspan ``=`` ``2``)``)``,`` `` `[`rrow`](https://pharmaverse.github.io/rtables/reference/rrow.md)`(``"95% CI"``, indent ``=`` ``1``, `[`rcell`](https://pharmaverse.github.io/rtables/reference/rcell.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``44.8``, ``67.4``)``, format ``=`` ``"(xx.x, xx.x)"``, colspan ``=`` ``2``)``)`` ``)`

Before we go into explaining the individual components used to create
this table we continue with the html conversion of the
[`rtable()`](https://pharmaverse.github.io/rtables/reference/rtable.md)
object:

[`as_html`](https://pharmaverse.github.io/rtables/reference/as_html.md)`(``tbl``, width ``=`` ``"80%"``)`
