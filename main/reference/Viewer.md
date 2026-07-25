# Display an `rtable` object in the Viewer pane in RStudio or in a browser

The table will be displayed using bootstrap styling.

## Usage

``` r
Viewer(x, y = NULL, ...)
```

## Arguments

- x:

  (`rtable` or `shiny.tag`)\
  an object of class `rtable` or `shiny.tag` (defined in `htmltools`
  package).

- y:

  (`rtable` or `shiny.tag`)\
  optional second argument of same type as `x`.

- ...:

  arguments passed to
  [`as_html()`](https://pharmaverse.github.io/rtables/reference/as_html.md).

## Value

Not meaningful. Called for the side effect of opening a browser or
viewer pane.

## Examples

``` r
if (interactive()) {
  sl5 <- factor(iris$Sepal.Length > 5,
    levels = c(TRUE, FALSE),
    labels = c("S.L > 5", "S.L <= 5")
  )

  df <- cbind(iris, sl5 = sl5)

  lyt <- basic_table() |>
    split_cols_by("sl5") |>
    analyze("Sepal.Length")

  tbl <- build_table(lyt, df)

  Viewer(tbl)
  Viewer(tbl, tbl)


  tbl2 <- htmltools::tags$div(
    class = "table-responsive",
    as_html(tbl, class_table = "table")
  )

  Viewer(tbl, tbl2)
}
```
