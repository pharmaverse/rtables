context("RowsVerticalSection Objects")
minrvs <- in_rows(y = "hi there")

min_attr_nms <- names(attributes(minrvs))

fullrvs <- in_rows(
  x = 5,
  .labels = c(x = "hi"),
  .formats = c(x = "xx.x"),
  .indent_mods = c(x = 1L),
  .aligns = c(x = "center"),
  .format_na_strs = c(x = "XXX"),
  .stat_names = list(x = "coolstat3")
)

full_attr_nms <- names(attributes(fullrvs))

check_rvs <- function(tocheck) {
  ## print method is a bit brittle but that shouldn't matter if RVS are made
  ## via in_rows or c(), so use it as a pseudo-validity check
  expect_no_error(capture.output(print(tocheck)))
  rvsattrs <- attributes(tocheck)
  rvsattrnms <- names(rvsattrs)
  ## check we have minimum specified attributes
  expect_true(
    all(min_attr_nms %in% rvsattrnms),
    "RowsVerticalSection object does not have minimum set of attributes."
  )
  ## check all attributes we have are ok
  expect_true(
    all(rvsattrnms %in% full_attr_nms),
    "RowsVerticalSection object unexpected additional attributes."
  )
  expect_true(inherits(tocheck, "RowsVerticalSection"))
  for (nm in setdiff(rvsattrnms, "class")) {
    ## ok to be brittle about handling class here
    attrval <- rvsattrs[[nm]]
    expclass <- class(attributes(fullrvs)[[nm]])
    ## row_formats sometimes a list with NULL in it, sometimes character
    if (nm != "row_formats") {
      expect_identical(
        class(attrval), expclass,
        paste(nm, "does not have class", expclass)
      )
    }
    expect_identical(
      length(attrval), length(names(tocheck)),
      paste(nm, "has incorrect length")
    )
  }
  TRUE
}


test_that("print and combine method for RVS objects work", {
  mm <- c(minrvs, minrvs)
  check_rvs(mm)
  expect_identical(names(mm), c("y", "y"))
  expect_identical(attr(mm, "row_labels"), c("y", "y"))
  expect_identical(attr(mm, "indent_mods"), c(0L, 0L))
  expect_identical(attr(mm, "row_formats"), list(NULL, NULL))
  expect_identical(attr(mm, "row_na_strs"), c(NA_character_, NA_character_))
  expect_identical(attr(mm, "row_footnotes"), list(list(), list()))

  comb <- c(minrvs, fullrvs)
  check_rvs(comb)
  expect_identical(names(comb), c("y", "x"))
  expect_identical(attr(comb, "row_labels"), c("y", "hi"))
  expect_identical(attr(comb, "indent_mods"), c(0L, 1L))
  expect_identical(attr(comb, "row_formats"), list(NULL, "xx.x"))
  ## NULL/unset gets set to NA_character_, unlike formats
  expect_identical(attr(comb, "row_na_strs"), c(NA_character_, "XXX"))
  expect_identical(attr(comb, "row_footnotes"), list(list(), list()))
  expect_identical(obj_format(comb), unname(c(obj_format(minrvs), obj_format(fullrvs))))
  expect_identical(obj_na_str(comb), c(NA_character_, "XXX"))

  fm <- c(fullrvs, minrvs)
  check_rvs(fm)
  expect_identical(names(fm), c("x", "y"))
  expect_identical(attr(fm, "row_labels"), c("hi", "y"))
  expect_identical(attr(fm, "indent_mods"), c(1L, 0L))
  expect_identical(attr(fm, "row_formats"), list("xx.x", NULL))
  expect_identical(attr(fm, "row_na_strs"), c("XXX", NA_character_))
  expect_identical(attr(fm, "row_footnotes"), list(list(), list()))

  ## unfortunately we can only catch this direction b/c c(5, minrv)
  ## never gets to our method. Fundamental limitation of custom c methods.
  expect_error(c(minrvs, 5))
})

test_that("row_cells accessor works for RowsVerticalSection", {
  cells <- row_cells(fullrvs)
  expect_identical(
    cells,
    list(rcell(5, format = "xx.x", align = "center", format_na_str = "XXX", stat_names = "coolstat3"))
  )
})

test_that("obj_format<- setter works for RowsVerticalSection", {
  rvs <- in_rows(a = 1, b = 2)
  obj_format(rvs) <- c("xx.x", "xx.x")
  expect_identical(obj_format(rvs), c("xx.x", "xx.x"))

  obj_format(rvs) <- c("xx", "xx.x")
  expect_identical(obj_format(rvs), c("xx", "xx.x"))
})

test_that("obj_na_str<- setter works for RowsVerticalSection", {
  rvs <- in_rows(a = 1, b = 2)
  obj_na_str(rvs) <- c("NA", "NA")
  expect_identical(obj_na_str(rvs), c("NA", "NA"))

  obj_na_str(rvs) <- c("N/A", "missing")
  expect_identical(obj_na_str(rvs), c("N/A", "missing"))
})

test_that("cell_values works for RowsVerticalSection", {
  rvs <- in_rows(a = 1, b = 2)
  vals <- cell_values(rvs)
  expect_identical(vals, list(a = 1, b = 2))
})

test_that("indent_mod<- recycles length-1 value for RowsVerticalSection", {
  rvs <- in_rows(a = 1, b = 2, c = 3)
  indent_mod(rvs) <- 2L
  expect_identical(attr(rvs, "indent_mods"), c(2L, 2L, 2L))

  indent_mod(rvs) <- c(0L, 1L, 2L)
  expect_identical(attr(rvs, "indent_mods"), c(0L, 1L, 2L))

  expect_error(indent_mod(rvs) <- c(1L, 2L))
})
