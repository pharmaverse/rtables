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
  check_rvs(c(minrvs, minrvs))
  check_rvs(c(minrvs, fullrvs))
  check_rvs(c(fullrvs, minrvs))
  comb <- c(minrvs, fullrvs)
  expect_identical(length(names(comb)), 2L)
  expect_identical(
    obj_format(comb),
    unname(c(obj_format(minrvs), obj_format(fullrvs)))
  )
  ## NULL/unset gets set to NA_character_, unlike formats
  expect_identical(
    obj_na_str(comb),
    c(NA_character_, "XXX")
  )

  ## unfortunately we can only catch this direction b/c c(5, minrv)
  ## never gets to our method. Fundamental limitation of custom c methods.
  expect_error(c(minrvs, 5))
})
