test_that("split_rows_by_cutfun preserves child_labels, label_pos, and other split settings", {
  cutfun <- function(x) {
    cutpoints <- c(min(x), mean(x), max(x))
    names(cutpoints) <- c("", "Younger", "Older")
    cutpoints
  }

  lyt_hidden <- basic_table() |>
    split_rows_by_cutfun(
      "AGE",
      cutfun = cutfun,
      child_labels = "hidden",
      label_pos = "hidden"
    ) |>
    analyze("BMRKR1", mean, format = "xx.xx")

  tbl_hidden <- build_table(lyt_hidden, DM)
  rdf <- make_row_df(tbl_hidden)
  expect_identical(rdf$label, c("mean", "mean"))
  expect_identical(nrow(tbl_hidden), 2L)

  lyt_srg <- basic_table() |>
    split_rows_by_cutfun(
      "AGE",
      cutfun = cutfun,
      parent_name = "age_grp",
      section_div = "-",
      label_pos = "visible"
    ) |>
    summarize_row_groups() |>
    analyze("BMRKR1", mean, format = "xx.xx")

  tbl_srg <- build_table(lyt_srg, DM)
  expect_identical(obj_name(tbl_srg), "age_grp")
  expect_true(any(make_row_df(tbl_srg)$node_class == "ContentRow"))
  expect_identical(section_div(tbl_srg), c(NA, NA, "-", NA, "-"))
})
