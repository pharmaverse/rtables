## regression test for automatically not-nesting
## when a non-analyze comes after an analyze
test_that("split under analyze", {
  dontnest <- basic_table(show_colcounts = TRUE) |>
    split_cols_by(var = "ARM") |>
    analyze("AGE") |>
    split_rows_by("VAR3") |>
    analyze("AGE") |>
    build_table(rawdat)
  expect_equal(nrow(dontnest), 5)
})

test_that("deeply nested and uneven column layouts work", {
  lyt <- basic_table(show_colcounts = TRUE) |>
    split_cols_by(var = "ARM") |>
    split_cols_by("STRATA1") |>
    split_cols_by("STRATA2") |>
    add_overall_col("All Patients") |>
    analyze("AGE")
  tbl <- build_table(lyt, ex_adsl)
  ## printing machinery works
  str <- toString(tbl)
  expect_identical(ncol(tbl), 19L)

  lyt2 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    split_cols_by("STRATA1") |>
    split_cols_by("STRATA2", nested = FALSE) |>
    add_overall_col("All Patients") |>
    analyze("AGE")
  tbl2 <- build_table(lyt2, ex_adsl)

  ## printing machinery works
  str <- toString(tbl2)
  expect_identical(ncol(tbl2), 12L)
})

test_that("intermediate nesting works correctly", {

  ## analyze nested at "proper" (non top level) split
  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    analyze("AGE") |>
    analyze("BMRKR2", at_sibling = "SEX")

  tbl <- build_table(lyt, ex_adsl)

  bmrkr_rpaths <- tt_normalize_row_path(tbl, c("STRATA1", "*", "BMRKR2"))

  expect_identical(bmrkr_rpaths,
                   list(A = c("STRATA1", "A", "BMRKR2"),
                        B = c("STRATA1", "B", "BMRKR2"),
                        C = c("STRATA1", "C", "BMRKR2")))

  expect_equal(length(bmrkr_rpaths),
               length(tt_normalize_row_path(tbl, c("STRATA1", "*", "SEX"))))

  ## split nested at "proper" (non top level) split
  ## summarize_row_groups on a nest at_sibling row split
  lyt2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    analyze("AGE") |>
    split_rows_by("BMRKR2", nested = TRUE, at_sibling = "SEX") |>
    summarize_row_groups("BMRKR2") |>
    analyze("AGE")

  tbl2 <- build_table(lyt2, ex_adsl)
  ## each facet of BMRKR2 split has (non-empty) content, ie
  ## summarize_row_groups attached to the right place
  expect_equal(length(tt_normalize_row_path(tbl2, c("STRATA1", "*", "BMRKR2", "*", "@content"))),
               9L)

  ## SEX didn't have a summarize row groups instruction
  ## tt_normalize_row_path says c(...,  "@content") path doesn't exist
  ## if content table is empty (no rows) or NULL
  expect_equal(length(tt_normalize_row_path(tbl2, c("STRATA1", "*", "SEX", "*", "@content"))),
               0L)


  tmpdat <- subset(ex_adsl, STRATA1 == "A" & BMRKR2 == "LOW")
  expect_identical(cell_values(tbl2, c("STRATA1", "A", "BMRKR2", "LOW", "AGE")),
                   ## tapply insists on making an array which trips up waldo/testthat
                   lapply(split(tmpdat$AGE, tmpdat$ARM), mean))


  ## at_sibling = <top-level-split> gracefully works as nested = FALSE
  ## we are intentionally strict using expect_identical for these  
  lyt3 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    analyze("AGE") |>
    analyze("BMRKR2", at_sibling = "STRATA1")

  tbl3 <- build_table(lyt3, ex_adsl)

  lyt3b <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    analyze("AGE") |>
    analyze("BMRKR2", nested = FALSE)

  tbl3b <- build_table(lyt3b, ex_adsl)
  expect_identical(tbl3, tbl3b)

  lyt4 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    analyze("AGE") |>
    ## NB this here, currently different default label behavior. Is that good or bad??  
    split_rows_by("BMRKR2", nested = TRUE, at_sibling = "STRATA1", label_pos = "hidden") |>
    summarize_row_groups("BMRKR2") |>
    analyze("AGE")

  tbl4 <- build_table(lyt4, ex_adsl)

  lyt4b <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    analyze("AGE") |>
    split_rows_by("BMRKR2", nested = FALSE) |>
    summarize_row_groups("BMRKR2") |>
    analyze("AGE")

  tbl4b <- build_table(lyt4b, ex_adsl)
  expect_identical(tbl4, tbl4b)

  ## Useful error for bad at_sibling
  expect_error({
    basic_table() |>
      split_cols_by("ARM") |>
      split_rows_by("STRATA1") |>
      split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
      analyze("AGE") |>
      analyze("BMRKR2", at_sibling = "whaaaaat?")
  }, "Unable to find structural element")

  expect_error({
    basic_table() |>
      split_cols_by("ARM") |>
      split_rows_by("STRATA1") |>
      split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
      analyze("AGE") |>
      split_rows_by("BMRKR2", at_sibling = "whaaaaat?")
  }, "Unable to find structural element")

  ## "Full On" INSANEO STYLE

  keep_2_levels <- function(varnm, dat = ex_adsl) keep_split_levels(levels(dat[[varnm]])[1:2])

  lyt6 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE") |>  
    split_rows_by("RACE", split_fun = keep_2_levels("RACE"), nested = TRUE, at_sibling = "AGE") |>
    analyze("AGE") |>
    split_rows_by("COUNTRY", split_fun = keep_2_levels("COUNTRY"), nested = TRUE, at_sibling = "RACE") |>
    analyze("AGE") |>
    split_rows_by("BMRKR2", split_fun = keep_2_levels("BMRKR2"), nested = TRUE, at_sibling = "SEX")
    analyze("AGE")

  build_table(lyt6, ex_adsl)
    
    


  
})
