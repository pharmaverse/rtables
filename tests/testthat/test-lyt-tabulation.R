context("Tabulation framework")


test_that("summarize_row_groups works with provided funcs", {
  l1 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("RACE") |>
    summarize_row_groups() |>
    analyze("AGE", mean)

  expect_silent(
    tb1 <- build_table(l1, DM)
  )
  tbl_str <- toString(tb1)
})


## this
test_that("complex layout works", {
  lyt <- make_big_lyt()

  ## ensure print method works for predata layout
  tab <- build_table(lyt, rawdat)
  tab_str <- toString(tab)
  ## XXX TODO this assumes we want no var label on VAR3 subtable
  expect_identical(dim(tab), c(28L, 4L))
  expect_identical(row.names(tab), complx_lyt_rnames)

  tlvals <- c("Ethnicity", "Factor 2")
  lyt2 <- lyt |> append_topleft(tlvals)
  tab2 <- build_table(lyt2, rawdat)
  expect_identical(top_left(tab2), tlvals)
})


test_that("existing table in layout works", {
  thing2 <- basic_table() |>
    split_cols_by("ARM") |>
    ## add nested column split on SEX with value labels from gend_label
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    analyze(
      c("AGE", "AGE"), c("Age Analysis", "Age Analysis Redux"),
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx",
      table_names = c("AGE1", "AGE2")
    )

  tab2 <- build_table(thing2, rawdat)


  thing3 <- basic_table() |>
    split_cols_by("ARM") |>
    ## add nested column split on SEX with value labels from gend_label
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    analyze("AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx"
    ) |>
    ## stack an existing table onto the layout and thus the generated table
    add_existing_table(tab2)

  tab3 <- build_table(thing3, rawdat)
  expect_equal(nrow(tab3), 12)
  tab3
})

test_that("Nested splits in column space work", {
  dat2 <- subset(ex_adsl, SEX %in% c("M", "F"))
  tbl2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", split_fun = drop_split_levels) |>
    analyze(c("AGE", "STRATA1")) |>
    build_table(dat2)

  mf <- matrix_form(tbl2)
  expect_identical(
    unname(mf$strings[1, , drop = TRUE]),
    c(
      "", "A: Drug X", "A: Drug X", "B: Placebo", "B: Placebo",
      "C: Combination", "C: Combination"
    )
  )
  expect_identical(
    unname(mf$display[1, , drop = TRUE]),
    c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, FALSE)
  )
})


test_that("labelkids parameter works", {
  yeslabellyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label", child_labels = "visible") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label", child_labels = "visible"
    ) |>
    analyze(
      "AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx",
      show_labels = "visible"
    )

  tabyes <- build_table(yeslabellyt, rawdat)

  expect_identical(
    row.names(tabyes)[1:4],
    c("Caucasian", "Caucasian (n)", "Level A", "Age Analysis")
  )


  misslabellyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label", child_labels = "default") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label", child_labels = "default"
    ) |>
    analyze(
      "AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx"
    )

  tabmiss <- build_table(misslabellyt, rawdat)
  expect_identical(
    row.names(tabmiss)[1:4],
    c("Caucasian (n)", "Level A", "mean", "median")
  )


  nolabellyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label", child_labels = "hidden") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label", child_labels = "hidden"
    ) |>
    analyze(
      "AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx",
      show_labels = "hidden"
    )


  tabno <- build_table(nolabellyt, rawdat)
  expect_identical(
    row.names(tabno)[1:4],
    c("Caucasian (n)", "mean", "median", "mean")
  )

  mixedlyt2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label", child_labels = "hidden") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label", child_labels = "hidden"
    ) |>
    analyze(
      "AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx",
      show_labels = "visible"
    )

  tabmixed2 <- build_table(mixedlyt2, rawdat)
  expect_identical(
    row.names(tabmixed2)[1:4],
    c("Caucasian (n)", "Age Analysis", "mean", "median")
  )


  mixedlyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label", child_labels = "visible") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label", child_labels = "visible"
    ) |>
    analyze(
      "AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx",
      show_labels = "hidden"
    )

  tabmixed <- build_table(mixedlyt, rawdat)
  expect_identical(
    row.names(tabmixed)[1:4],
    c("Caucasian", "Caucasian (n)", "Level A", "mean")
  )


  varshowlyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label",
      label_pos = "visible"
    ) |>
    analyze(
      "AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx",
      show_labels = "hidden"
    )

  varshowtab <- build_table(varshowlyt, rawdat)
  expect_identical(
    row.names(varshowtab)[1:4],
    c("Caucasian (n)", "Factor2", "Level A", "mean")
  )
})


test_that("ref_group comparisons work", {
  skip_if_not_installed("tibble")
  require(tibble, quietly = TRUE)

  blthing <- basic_table() |>
    split_cols_by("ARM", ref_group = "ARM1") |>
    analyze("AGE", show_labels = "hidden") |>
    analyze("AGE", refcompmean, show_labels = "hidden", table_names = "AGE2")
  ## function(x) list(mean = mean(x)))


  bltab <- build_table(blthing, rawdat)
  expect_identical(dim(bltab), c(2L, 2L))
  expect_null(bltab[2, 1, drop = TRUE])
  c1 <- bltab[1, 1, drop = TRUE]
  c2 <- bltab[1, 2, drop = TRUE]
  c3 <- bltab[2, 2, drop = TRUE]
  expect_equivalent(c2 - c1, c3)

  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", ref_group = "F") |>
    analyze("AGE", mean, show_labels = "hidden") |>
    analyze("AGE", refcompmean,
      show_labels = "hidden",
      table_names = "AGE2a"
    ) |>
    split_rows_by("RACE",
      nested = FALSE,
      split_fun = drop_split_levels
    ) |>
    analyze("AGE", mean, show_labels = "hidden") |>
    analyze("AGE", refcompmean, show_labels = "hidden", table_names = "AGE2b")

  bltab2 <- build_table(lyt, DM)
  d1 <- bltab2[4, 1, drop = TRUE]
  d2 <- bltab2[4, 2, drop = TRUE]
  d3 <- bltab2[5, 2, drop = TRUE]

  expect_equivalent(d2 - d1, d3)
  d4 <- bltab2[1, 3, drop = TRUE]
  d5 <- bltab2[1, 4, drop = TRUE]
  d6 <- bltab2[2, 4, drop = TRUE]
  expect_equivalent(d5 - d4, d6)

  d7 <- bltab2[4, 3, drop = TRUE]
  d8 <- bltab2[4, 4, drop = TRUE]
  d9 <- bltab2[5, 4, drop = TRUE]
  expect_equivalent(d8 - d7, d9)

  ## with combo levels
  combodf <- tribble(
    ~valname, ~label, ~levelcombo, ~exargs,
    "A_", "Arm 1", c("A: Drug X"), list(),
    "B_C", "Arms B & C", c("B: Placebo", "C: Combination"), list()
  )

  l3 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by(
      "ARM",
      split_fun = add_combo_levels(combodf, keep_levels = c("A_", "B_C")),
      ref_group = "A_"
    ) |>
    analyze(c("AGE", "AGE"),
      afun = list(mean, refcompmean),
      show_labels = "hidden", table_names = c("AGE1", "AGE2")
    )
  bltab3 <- build_table(l3, DM)
  d10 <- bltab3[1, 1, drop = TRUE]
  d11 <- bltab3[1, 2, drop = TRUE]
  d12 <- bltab3[2, 2, drop = TRUE]

  expect_null(cell_values(bltab3, "AGE2", c("ARM", "A_"))[[1]])
  expect_identical(d12, d11 - d10)
})

test_that("missing vars caught", {
  misscol <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SX", "Gender") |>
    analyze("AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx"
    )

  expect_error(
    build_table(misscol, rawdat),
    "Split variable [[]SX[]] not found in data being tabulated."
  )

  missrsplit <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "gend_label") |>
    split_rows_by("RACER", "ethn_label") |>
    analyze("AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx"
    )

  expect_error(
    build_table(missrsplit, rawdat),
    "Split variable [[]RACER[]] not found in data being tabulated."
  )

  missrsplit <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "gend_label") |>
    split_rows_by("RACE", "ethnNA_label") |>
    analyze("AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx"
    )

  expect_error(
    build_table(missrsplit, rawdat),
    "Value label variable [[]ethnNA_label[]] not found in data being tabulated."
  )

  missavar <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", labels_var = "gend_label") |>
    split_rows_by("RACE", labels_var = "ethn_label") |>
    analyze("AGGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx"
    )

  expect_error(
    build_table(missavar, rawdat),
    ".*variable[(]s[)] [[]AGGE[]] not present in data. [(]AnalyzeVarSplit[)].*"
  )
})

# https://github.com/insightsengineering/rtables/issues/329
test_that("error localization works", {
  afun <- function(x, .spl_context) {
    if (NROW(.spl_context) > 0 && .spl_context[NROW(.spl_context), "value", drop = TRUE] == "WHITE") {
      stop("error for white statistics")
    }

    in_rows(myrow = 5)
  }

  lyt <- basic_table() |>
    split_rows_by("ARM") |>
    split_rows_by("RACE") |>
    analyze("BMRKR1", afun = afun)
  # nolint start
  expect_error(
    build_table(lyt, DM),
    "Error[^)]*analysis function \\(var[^B]*BMRKR1\\): error for white statistics.*ARM\\[A: Drug X\\]->RACE\\[WHITE\\]"
  )
  # nolint end
  cfun <- function(df, labelstr) {
    if (labelstr == "B: Placebo") {
      stop("placebos are bad")
    }
    in_rows(val = 5)
  }

  lyt2 <- basic_table() |>
    split_rows_by("ARM") |>
    summarize_row_groups(cfun = cfun) |>
    split_rows_by("RACE") |>
    analyze("BMRKR1", afun = mean)

  expect_error(
    build_table(lyt2, DM),
    "Error in content.*function: placebos are bad.*path: ARM\\[B: Placebo\\]"
  )

  splfun <- function(df, spl, vals = NULL, labels = NULL, trim = FALSE) {
    stop("oopsie daisy")
  }

  lyt3 <- basic_table() |>
    split_rows_by("ARM") |>
    summarize_row_groups() |>
    split_rows_by("RACE", split_fun = splfun) |>
    analyze("BMRKR1", afun = mean)
  # nolint start
  expect_error(
    build_table(lyt3, DM),
    "Error.*custom split function: oopsie daisy.*VarLevelSplit \\(RACE\\).*path: ARM\\[A: Drug X\\]"
  )
  # nolint end
})


test_that("cfun args", {
  # first arg df
  cfun1 <- function(df, labelstr, .N_col, .N_total) {
    stopifnot(is(df, "data.frame"))
    in_rows(
      rcell(nrow(df) * c(1, 1 / .N_col), format = "xx (xx.xx%)"),
      .names = labelstr
    )
  }
  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    summarize_row_groups(cfun = cfun1)

  tbl <- build_table(lyt, rawdat)
  capture.output(prout <- print(tbl))
  expect_identical(prout, tbl)

  # first arg x
  cfun2 <- function(x, labelstr) {
    in_rows(
      c(mean(x, trim = 0.2), 0.2),
      .formats = "xx.x (xx.x%)",
      .labels = sprintf(
        "%s (Trimmed mean and trim %%)",
        labelstr
      )
    )
  }
  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    summarize_row_groups("AGE", cfun = cfun2)

  tbl <- build_table(lyt, rawdat)
  capture.output(prout <- print(tbl))
  expect_identical(prout, tbl)
})

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

test_that("at_sibling creates intermediate row nesting", {
  lyt <- basic_table() |>
    split_rows_by("RACE") |>
    split_rows_by("FACTOR2") |>
    analyze("AGE") |>
    split_rows_by("SEX", at_sibling = "FACTOR2") |>
    analyze("AGE")
  tbl <- build_table(lyt, rawdat)
  paths <- row_paths(tbl)
  has_path <- function(path) any(vapply(paths, identical, logical(1), path))

  expect_true(has_path(c("RACE", "WHITE", "FACTOR2", "A", "AGE", "Mean")))
  expect_true(has_path(c("RACE", "WHITE", "SEX", "M", "AGE", "Mean")))
  expect_false(has_path(c("RACE", "WHITE", "FACTOR2", "A", "SEX", "M", "AGE", "Mean")))
  expect_true(all(c("FACTOR2", "SEX") %in% row.names(tbl)))

  sibling_analysis <- basic_table() |>
    split_rows_by("RACE") |>
    split_rows_by("FACTOR2") |>
    analyze("AGE") |>
    analyze("AGE", at_sibling = "FACTOR2") |>
    build_table(rawdat)
  expect_true(any(vapply(
    row_paths(sibling_analysis),
    identical,
    logical(1),
    c("RACE", "WHITE", "AGE", "Mean")
  )))
})

test_that("at_sibling shows dynamic cut split labels", {
  lyt <- basic_table() |>
    split_rows_by("RACE") |>
    split_rows_by("FACTOR2") |>
    analyze("AGE") |>
    split_rows_by_cutfun("AGE", at_sibling = "FACTOR2") |>
    analyze("AGE")
  tbl <- build_table(lyt, rawdat)
  paths <- row_paths(tbl)

  expect_true(any(vapply(
    paths,
    identical,
    logical(1),
    c("RACE", "WHITE", "AGE", "1st qrtile", "AGE", "Mean")
  )))
  expect_true("AGE" %in% row.names(tbl))
})


test_that("label_var works as expected", {
  yeslblslyt <- basic_table(show_colcounts = TRUE) |>
    split_cols_by(var = "ARM") |>
    split_rows_by("SEX", labels_var = "gend_label") |>
    analyze("AGE")
  yeslbls <- build_table(yeslblslyt, rawdat)
  expect_identical(row.names(yeslbls)[1], "Male")

  nolbls <- basic_table(show_colcounts = TRUE) |>
    split_cols_by(var = "ARM") |>
    split_rows_by("SEX") |>
    analyze("AGE") |>
    build_table(rawdat)
  expect_identical(row.names(nolbls)[1], "M")

  ## create bad label col
  rawdat2 <- rawdat
  rawdat2$gend_label[5] <- "XXXXX"
  ## nolint start
  ## test check for label-value concordance.
  expect_error(
    build_table(yeslblslyt, rawdat2),
    "There does not appear to be a 1-1 correspondence between values in split var \\[SEX\\] and label var \\[gend_label\\]"
  )
  ## nolint end
})


test_that("factors with unobserved levels work as expected", {
  ## default behavior is that empty levels are NOT dropped
  ## rows
  lyt <- basic_table() |>
    split_rows_by("SEX") |>
    analyze("AGE")
  tab <- build_table(lyt, DM)

  expect_identical(dim(tab), c(8L, 1L))

  ## cols
  lyt2 <- basic_table() |>
    split_cols_by("SEX") |>
    analyze("AGE")
  tab2 <- build_table(lyt2, DM)
  expect_identical(dim(tab2), c(1L, 4L))
})


test_that(".N_row argument in afun works correctly", {
  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    analyze("AGE", afun = function(x, .N_row) .N_row)
  tab <- build_table(lyt, rawdat)
  rows <- collect_leaves(tab)
  names(rows) <- substr(names(rows), 1, 1)
  ans <- tapply(rawdat$AGE, rawdat$SEX, function(x) rep(length(x), 2))
  res <- vapply(names(rows), function(nm) isTRUE(all.equal(unname(unlist(row_values(rows[[nm]]))), ans[[nm]])), NA)
  expect_true(all(res))
})


test_that("extra args works", {
  oldop <- options(warn = 2)
  on.exit(options(oldop))
  colfuns <- list(
    function(x, add = 0, na.rm = TRUE) {
      rcell(mean(c(NA, x), na.rm = na.rm) + add, format = "xx.x")
    },
    function(x, cutoff = .5, na.rm = TRUE) {
      rcell(sum(c(NA, x > cutoff), na.rm = na.rm), format = "xx")
    }
  )

  l <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_multivar(c("VALUE", "PCTDIFF")) |>
    analyze_colvars(afun = colfuns)

  l

  tbl_noex <- build_table(l, rawdat2)

  ## one for each different function in colfuns, assigned correctly
  l2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_multivar(c("VALUE", "PCTDIFF")) |>
    analyze_colvars(afun = colfuns, extra_args = list(list(add = 5), list(cutoff = 100)))


  tbl_ex <- build_table(l2, rawdat2)

  vals_noex <- row_values(tree_children(tbl_noex)[[1]])
  vals_ex <- row_values(tree_children(tbl_ex)[[1]])

  expect_identical(
    unlist(vals_noex[c(1, 3)]) + 5,
    unlist(vals_ex[c(1, 3)])
  )
  truevals <- tapply(rawdat2$PCTDIFF,
    rawdat2$ARM,
    function(x) sum(x > 100, na.rm = TRUE),
    simplify = FALSE
  )
  expect_equal(
    unname(unlist(truevals)),
    unname(unlist(vals_ex[c(2, 4)]))
  )

  vals_noex <- row_values(tree_children(tbl_noex)[[1]])
  vals_ex <- row_values(tree_children(tbl_ex)[[1]])

  expect_identical(
    unlist(vals_noex[c(1, 3)]) + 5,
    unlist(vals_ex[c(1, 3)])
  )
  truevals <- tapply(rawdat2$PCTDIFF,
    rawdat2$ARM,
    function(x) sum(x > 100, na.rm = TRUE),
    simplify = FALSE
  )
  expect_equal(
    unname(unlist(truevals)),
    unname(unlist(vals_ex[c(2, 4)]))
  )

  ## single argument passed to all functions
  l2b <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_multivar(c("VALUE", "PCTDIFF")) |>
    analyze_colvars(afun = colfuns, extra_args = list(na.rm = FALSE))

  tbl_ex2 <- build_table(l2b, rawdat2)

  expect_true(all(is.na(unlist(rtables:::row_values(tree_children(tbl_ex2)[[1]])))))

  ## one argument for a single function.

  lyt <- basic_table() |>
    analyze("Sepal.Length", afun = function(x, a) {
      in_rows(mean_a = rcell(mean(x) + a, format = "xx"))
    }, extra_args = list(a = 1))


  tbl <- build_table(lyt, iris)
  expect_equal(tbl[1, 1, drop = TRUE], mean(iris$Sepal.Length) + 1)

  ## two arguments for a single function
  lyt2 <- basic_table() |>
    analyze("Sepal.Length", afun = function(x, a, b) {
      in_rows(mean_a = rcell(mean(x) + a + b, format = "xx"))
    }, extra_args = list(a = 1, b = 3))


  tbl2 <- build_table(lyt2, iris)
  expect_equal(tbl2[1, 1, drop = TRUE], mean(iris$Sepal.Length) + 1 + 3)
})


test_that("Colcounts work correctly", {
  lyt1 <- basic_table(show_colcounts = TRUE) |>
    analyze("AGE")
  tbl1 <- build_table(lyt1, DM)

  expect_identical(col_counts(tbl1), nrow(DM))

  lyt2 <- lyt1 |> split_cols_by("ARM")
  tbl2 <- build_table(lyt2, DM)

  expect_identical(
    col_counts(tbl2),
    as.integer(table(DM$ARM))
  )

  DMchar <- DM
  DMchar$ARM <- as.character(DM$ARM)
  tbl2chr <- build_table(lyt2, DMchar)

  tbl3 <- build_table(lyt2, DM, col_counts = c(500L, NA, NA))
  expect_identical(
    col_counts(tbl3),
    c(500L, as.integer(table(DM$ARM))[2:3])
  )
  expect_error(build_table(lyt2, DMchar, col_counts = c(500L, NA, NA)))
  expect_error(build_table(lyt2, DM, col_counts = c(20L, 40L)))

  tbl4 <- basic_table(
    show_colcounts = TRUE,
    colcount_format = "xx (xx%)"
  ) |>
    split_cols_by("ARM") |>
    build_table(DM)
  mf_tbl4_colcounts <- matrix_form(tbl4)$strings[2, ]
  expect_identical(mf_tbl4_colcounts, c("", "121 (100%)", "106 (100%)", "129 (100%)"))

  ## setting col_counts in build_table turns on visibility for leaf col counts
  lyt5 <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("STRATA1") |>
    analyze("AGE")

  tbl5 <- build_table(lyt5, ex_adsl, col_counts = 1:9)
  mpf5 <- matrix_form(tbl5)
  expect_identical(mf_strings(mpf5)[3, 2], "(N=1)")
})

first_cont_rowvals <- function(tt) {
  row_values(
    tree_children(
      content_table(
        tree_children(tt)[[1]]
      )
    )[[1]]
  )
}

test_that("content extra args for summarize_row_groups works", {
  sfun <- function(x, labelstr, .N_col, a = 5, b = 6, c = 7) {
    in_rows(
      c(a, b),
      .formats = "xx - xx",
      .labels = labelstr
    )
  }
  ## specify single set of args for all columns
  l <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    summarize_row_groups(
      cfun = sfun,
      extra_args = list(a = 9)
    )
  tbl1 <- build_table(l, rawdat)
  expect_identical(
    first_cont_rowvals(tbl1),
    list(
      ARM1 = c(9, 6),
      ARM2 = c(9, 6)
    )
  )

  ## specify different arg for each column
  l2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    summarize_row_groups(
      cfun = sfun,
      extra_args = list(
        list(a = 9),
        list(b = 3)
      )
    )
  tbl2 <- build_table(l2, rawdat)
  expect_identical(
    first_cont_rowvals(tbl2),
    list(
      ARM1 = c(9, 6),
      ARM2 = c(5, 3)
    )
  )


  ## specify arg for only one col
  l3 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    summarize_row_groups(
      cfun = sfun,
      extra_args = list(list(a = 9))
    )
  tbl3 <- build_table(l3, rawdat)
  expect_identical(
    first_cont_rowvals(tbl3),
    list(
      ARM1 = c(9, 6),
      ARM2 = c(5, 6)
    )
  )

  ## works on root split

  l4 <- basic_table() |>
    split_cols_by("ARM") |>
    summarize_row_groups(
      cfun = sfun,
      extra_args = list(a = 9)
    )
  tbl4 <- build_table(l4, rawdat)
  expect_identical(
    row_values(tree_children(content_table(tbl4))[[1]]),
    list(
      ARM1 = c(9, 6),
      ARM2 = c(9, 6)
    )
  )
})

test_that(".df_row analysis function argument works", {
  afun <- function(x, labelstr = "", .N_col, .df_row) {
    rcell(c(nrow(.df_row), .N_col), format = "(xx.x, xx.x)")
  }

  l <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    analyze("AGE", afun)

  tbl <- build_table(l, rawdat)
  rws <- collect_leaves(tbl, add.labrows = FALSE)
  nmale <- sum(rawdat$SEX == "M")
  nfemale <- sum(rawdat$SEX == "F")
  narm1 <- sum(rawdat$ARM == "ARM1")
  narm2 <- sum(rawdat$ARM == "ARM2")

  expect_identical(
    unname(lapply(rws, row_values)),
    list(
      list(
        ARM1 = c(nmale, narm1),
        ARM2 = c(nmale, narm2)
      ),
      list(
        ARM1 = c(nfemale, narm1),
        ARM2 = c(nfemale, narm2)
      )
    )
  )
})

test_that("analysis function arguments work with NA rows in data", {
  afun <- function(x, .df_row, ...) {
    list(
      "number of rows in .df_row" = nrow(.df_row),
      "length of x" = length(x)
    )
  }

  df <- data.frame(
    a_var = factor(c("a", NA, "b", "b", "a", "a", "b", "c", "a", NA)),
    b_var = factor(c(NA, NA, "x", "x", "y", "x", "x", "y", "x", NA))
  )

  l <- basic_table() |>
    add_overall_col("all pts") |>
    split_rows_by("a_var") |>
    analyze("b_var", afun = afun)

  tbl <- build_table(l, df)
  rws <- collect_leaves(tbl, add.labrows = FALSE)

  na <- sum(!is.na(df$a_var) & df$a_var == "a")
  nb <- sum(!is.na(df$a_var) & df$a_var == "b")
  nc <- sum(!is.na(df$a_var) & df$a_var == "c")
  na_x <- length(df$b_var[!is.na(df$a_var) & df$a_var == "a" & !is.na(df$b_var)])
  nb_x <- length(df$b_var[!is.na(df$a_var) & df$a_var == "b" & !is.na(df$b_var)])
  nc_x <- length(df$b_var[!is.na(df$a_var) & df$a_var == "c" & !is.na(df$b_var)])

  expect_identical(
    unlist(lapply(rws, row_values), use.names = FALSE),
    c(na, na_x, nb, nb_x, nc, nc_x)
  )
})

test_that("analyze_colvars inclNAs works", {
  ## inclNAs
  test <- data.frame(
    a = c(1, 2),
    b = c(1, NA)
  )

  l <- basic_table() |>
    split_cols_by_multivar(c("a", "b")) |>
    analyze_colvars(afun = length, inclNAs = TRUE)

  # We expect:
  ans <- lapply(test, length)
  # a b
  # 2 2

  # But we get:
  tab <- build_table(l, test)
  res1 <- cell_values(tab)
  expect_equal(ans, res1)

  l2 <- basic_table() |>
    split_cols_by_multivar(c("a", "b")) |>
    analyze_colvars(afun = length, inclNAs = FALSE)

  ans2 <- lapply(test, function(x) sum(!is.na(x)))
  tab2 <- build_table(l2, test)
  res2 <- cell_values(tab2)
  expect_equal(ans2, res2)
})


test_that("analyze_colvars works generally", {
  op <- options(warn = 2)
  on.exit(options(op))
  test <- data.frame(
    a = 1,
    b = 2,
    c = 3,
    d = 4,
    e = 5
  )
  l1 <- basic_table() |>
    split_cols_by_multivar(c("a", "b", "c", "d")) |>
    analyze_colvars(afun = identity)
  tab1 <- build_table(l1, test)
  l2 <- basic_table() |>
    split_cols_by_multivar(c("a", "b", "c", "d", "e")) |>
    analyze_colvars(afun = identity)
  tab2 <- build_table(l2, test)

  colfuns <- list(
    function(x, labelstr) in_rows(summary = 5, .labels = "My Summary Row"),
    function(x, labelstr) 6,
    function(x, labelstr) 7,
    function(x, labelstr) 8
  )

  l3 <- basic_table() |>
    split_cols_by_multivar(c("a", "b", "c", "d")) |>
    summarize_row_groups(cfun = colfuns, format = "xx") |>
    analyze_colvars(afun = identity)
  tab3 <- build_table(l3, test)
  expect_identical(
    cell_values(content_table(tab3)),
    list(a = 5, b = 6, c = 7, d = 8)
  )
  expect_identical(
    obj_label(collect_leaves(tab3, TRUE, TRUE)[[1]]),
    c(summary = "My Summary Row")
  )

  l4 <- basic_table() |>
    split_cols_by_multivar(c("a", "b", "c", "d")) |>
    summarize_row_groups() |>
    analyze_colvars(afun = identity)
  tab4 <- build_table(l4, test)
  ## this broke before due to formatting missmatches
  toString(tab4)
  rws4 <- collect_leaves(tab4, TRUE, TRUE)
  expect_identical(obj_format(rws4[[1]]), "xx (xx.x%)")
  expect_identical(obj_format(rws4[[2]]), NULL)

  l5 <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_multivar(c("AGE", "BMRKR1")) |>
    split_rows_by("RACE") |>
    summarize_row_groups(
      cfun = list(
        function(x, labelstr) "first fun",
        function(x, labelstr) "second fun"
      ),
      format = "xx"
    )
  tab5 <- build_table(l5, DM)
  toString(tab5)
  rws5 <- collect_leaves(tab5, TRUE, TRUE)
  expect_true(
    all(vapply(rws5, function(x) identical(x, rws5[[1]]), NA))
  )
  expect_identical(
    unname(cell_values(tab5)[[1]]),
    rep(list("first fun", "second fun"), length.out = ncol(tab5))
  )


  ## single column in split_cols_by_multivar and analyze_colvars
  one_col_lyt <- basic_table() |>
    split_cols_by_multivar(vars = "Sepal.Width") |>
    analyze_colvars(afun = mean)
  one_col_tbl <- build_table(one_col_lyt, iris)

  expect_identical(
    cell_values(one_col_tbl),
    list(Sepal.Width = mean(iris$Sepal.Width))
  )

  # na_str argument works
  test$d <- NA
  l2 <- basic_table() |>
    split_cols_by_multivar(c("a", "b", "c", "d")) |>
    analyze_colvars(afun = mean, na_str = "no data")
  tab2 <- build_table(l2, test)
  expect_identical(
    toString(tab2[1, 4]),
    "          d   \n——————————————\nmean   no data\n"
  )
})

test_that("alt_counts_df works", {
  minidm <- DM[1, ]

  lyt <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    summarize_row_groups() |>
    analyze("AGE")

  tbl <- build_table(lyt, DM, minidm)

  ## this inherently checks both that the correct counts (0, 1, 0) are
  ## retrieved and that they propogate to the summary functions
  expect_identical(
    list(
      "A: Drug X" = c(70, Inf), ## 70/0
      "B: Placebo" = c(56, 56), ## 56/1
      "C: Combination" = c(61, Inf)
    ), ## 61/0
    cell_values(tbl[1, ])
  )

  ## breaks (with useful message) when given incompatible alt_counts_df
  expect_error(build_table(lyt, DM, iris), "Offending column subset expression")
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


test_that("topleft label position works", {
  lyt <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    ## add nested column split on SEX with value lables from gend_label
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    ## No row splits have been introduced, so this adds
    ## a root split and puts summary content on it labelled Overall (N)
    ## add_colby_total(label = "All") |>
    ##    summarize_row_groups(label = "Overall (N)", format = "(N=xx)") |>
    ## add a new subtable that splits on RACE, value labels from ethn_label
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label", label_pos = "topleft") |>
    summarize_row_groups("RACE", label_fstr = "%s (n)") |>
    ##
    ## Add nested row split within Race categories for FACTOR2
    ## using a split function that excludes level C
    ## value labels from fac2_label
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label",
      label_pos = "topleft"
    ) |>
    ## Add count summary within FACTOR2 categories
    summarize_row_groups("FACTOR2") |>
    ## Add analysis/data rows by analyzing AGE variable
    ## Note afun is a function that returns 2 values in a named list
    ## this will create 2 data rows
    analyze("AGE", "Age Analysis", afun = function(x) list(mean = mean(x), median = median(x)), format = "xx.xx")

  tab <- build_table(lyt, rawdat)
  expect_identical(
    c("Ethnicity", "  Factor2"),
    top_left(tab)
  )
  expect_identical(
    14L,
    nrow(tab)
  )

  ## https://github.com/insightsengineering/rtables/issues/657
  tab2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("RACE", split_fun = drop_split_levels, split_label = "RACE", label_pos = "hidden", page_by = TRUE) |>
    split_rows_by("STRATA1", split_fun = drop_split_levels, split_label = "Strata", label_pos = "topleft") |>
    split_rows_by("SEX", split_fun = drop_split_levels, split_label = "Gender", label_pos = "topleft") |>
    analyze("AGE", mean, var_labels = "Age", format = "xx.xx") |>
    build_table(DM)

  ptab <- paginate_table(tab2)
  expect_identical(
    top_left(ptab[[1]]),
    c("Strata", "  Gender")
  )

  ## https://github.com/insightsengineering/rtables/issues/651
  lyt2 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    split_rows_by("SEX", split_fun = drop_split_levels, page_by = TRUE) |>
    analyze("AGE")
  expect_error(build_table(lyt2, DM[0, ]), "Page-by split resulted in zero")

  lyt3 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    split_rows_by("SEX", split_fun = drop_split_levels, page_by = TRUE) |>
    split_rows_by("COUNTRY", split_fun = drop_split_levels, page_by = TRUE) |>
    analyze("AGE")

  baddm <- DM
  baddm$COUNTRY <- NA_character_
  ## brittle test because I couldn't figure out how to get the regex to handle newlines and check both the path
  ## part and primary message part
  error_msg <- paste0(
    "Page-by split resulted in zero pages (no observed values of split variable?). ",
    "\n\tsplit: VarLevelSplit (COUNTRY)\n\toccured at path: SEX[F]\n"
  )
  expect_error(build_table(lyt3, baddm), error_msg, fixed = TRUE)

  # Similar error if the problematic split is done on alt_counts_df (related to #651)
  lyt4 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    split_rows_by("SEX", split_fun = drop_split_levels, page_by = TRUE) |>
    split_rows_by("COUNTRY", split_fun = drop_split_levels, page_by = TRUE) |>
    analyze("AGE", afun = function(x, .alt_df) mean(x))

  error_msg2 <- paste0(
    "Following error encountered in splitting alt_counts_df: ",
    error_msg
  )
  expect_error(build_table(lyt4, DM, alt_counts_df = baddm), error_msg2, fixed = TRUE)
})


test_that(".spl_context works in content and analysis functions", {
  ageglobmean <- mean(DM$AGE)
  cfun <- function(df, labelstr, .spl_context) {
    stopifnot("A: Drug X.M" %in% names(.spl_context))
    lastrow <- .spl_context[nrow(.spl_context) - 1, ]
    in_rows(c(nrow(df), lastrow$cur_col_n),
      .names = labelstr,
      .labels = sprintf(
        "%s (%d)", labelstr,
        nrow(lastrow$full_parent_df[[1]])
      ),
      .formats = "xx / xx"
    )
  }

  afun <- function(x, .spl_context) {
    stopifnot("A: Drug X.M" %in% names(.spl_context))
    ## this will break if the root 'split' row isn't there
    stopifnot(nrow(.spl_context$full_parent_df[[1]]) == nrow(DM))
    lastrow <- .spl_context[nrow(.spl_context), ]
    in_rows(c(sum(x >= ageglobmean), lastrow$cur_col_n),
      .names = "age_analysis",
      .labels = sprintf(
        "counts (out of %d)",
        nrow(lastrow$full_parent_df[[1]])
      ),
      .formats = "xx / xx"
    )
  }


  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", split_fun = keep_split_levels(c("M", "F"))) |>
    split_rows_by("COUNTRY", split_fun = keep_split_levels(c("CHN", "USA"))) |>
    summarize_row_groups() |>
    split_rows_by("STRATA1") |>
    summarize_row_groups(cfun = cfun) |>
    analyze("AGE", afun = afun)

  tab <- build_table(lyt, DM)

  strmat <- matrix_form(tab)$strings

  rwcount4 <- as.integer(gsub("[^0-9]", "", strmat[4, 1]))
  crowvals <- cell_values(tab, c("COUNTRY", "CHN", "@content"))
  expect_equal(
    rwcount4,
    sum(sapply(
      crowvals,
      `[[`, 1
    ))
  )

  expect_equal(
    crowvals[[1]][[1]],
    cell_values(tab, c("COUNTRY", "CHN", "STRATA1", "A", "@content"))[[1]][[2]]
  )

  expect_equal(
    unname(sapply(
      cell_values(tab, c("COUNTRY", "USA", "STRATA1", "B", "@content")),
      `[[`, 1L
    )),
    unname(sapply(
      cell_values(tab, c("COUNTRY", "USA", "STRATA1", "B", "AGE", "age_analysis")),
      `[[`, 2L
    ))
  )
})

test_that("cut functions work", {
  ctnames <- c("young", "medium", "old")
  ## split_cols_by_cuts
  l <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_cuts("AGE",
      split_label = "Age",
      cuts = c(0, 25, 35, 1000),
      cutlabels = ctnames
    ) |>
    analyze(c("BMRKR2", "STRATA2")) |>
    append_topleft("counts")

  tbl <- build_table(l, ex_adsl)

  chkvals <- cell_values(tbl, c("BMRKR2", "LOW"), c("ARM", "A: Drug X"))
  expect_identical(
    unname(unlist(chkvals)),
    c(
      nrow(subset(ex_adsl, ARM == "A: Drug X" & BMRKR2 == "LOW" & AGE <= 25)),
      nrow(subset(ex_adsl, ARM == "A: Drug X" & BMRKR2 == "LOW" & AGE > 25 & AGE <= 35)),
      nrow(subset(ex_adsl, ARM == "A: Drug X" & BMRKR2 == "LOW" & AGE > 35))
    )
  )

  mf <- matrix_form(tbl)
  expect_identical(
    mf$strings[2, , drop = TRUE],
    c("counts", rep(ctnames, 3))
  )

  lcm <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_cuts("AGE",
      split_label = "Age",
      cuts = c(0, 25, 35, 1000),
      cutlabels = c("young", "young+medium", "all"),
      cumulative = TRUE
    ) |>
    analyze(c("BMRKR2", "STRATA2")) |>
    append_topleft("counts")

  tblcm <- build_table(lcm, ex_adsl)

  medpth <- c("BMRKR2", "MEDIUM")
  bpth <- c("ARM", "B: Placebo")
  expect_identical(
    cumsum(unname(unlist(cell_values(tbl, medpth, bpth)))),
    unname(unlist(cell_values(tblcm, medpth, bpth)))
  )
  ## split_rows_by_cuts
  l2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by_cuts("AGE",
      split_label = "Age",
      cuts = c(0, 25, 35, 1000),
      cutlabels = ctnames
    ) |>
    analyze("BMRKR2") |>
    append_topleft("counts")


  tbl2 <- build_table(l2, ex_adsl)

  mf2 <- matrix_form(tbl2)

  expect_identical(
    mf2$strings[c(2, 6, 10), 1, drop = TRUE],
    ctnames
  )


  l2cm <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by_cuts("AGE",
      split_label = "Age",
      cuts = c(0, 25, 35, 1000),
      cutlabels = ctnames, cumulative = TRUE
    ) |>
    analyze("BMRKR2") |>
    append_topleft("counts")


  tbl2cm <- build_table(l2cm, ex_adsl)

  medlow <- c("AGE", "young", "BMRKR2", "HIGH")
  cpth <- c("ARM", "C: Combination")
  getvals <- function(tt) {
    sapply(
      ctnames,
      function(pth) {
        unname(unlist(cell_values(tt, c("AGE", pth, "BMRKR2", "HIGH"), cpth)))
      }
    )
  }
  expect_identical(
    getvals(tbl2cm),
    cumsum(getvals(tbl2))
  )
  # split_cols_by_quartiles

  l3 <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_cutfun("AGE") |> ## (quartiles("AGE", split_label = "Age") |>
    analyze("BMRKR2") |>
    append_topleft("counts")

  tbl3 <- build_table(l3, ex_adsl)

  l3b <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_cuts("AGE", cuts = rtables:::qtile_cuts(ex_adsl$AGE)) |>
    analyze("BMRKR2") |>
    append_topleft("counts")

  tbl3b <- build_table(l3b, ex_adsl)

  expect_identical(tbl3, tbl3b)

  l3c <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_quartiles("AGE") |>
    analyze("BMRKR2") |>
    append_topleft("counts")

  tbl3c <- build_table(l3c, ex_adsl)

  expect_identical(
    unname(unlist(cell_values(tbl3))),
    unname(unlist(cell_values(tbl3c)))
  )


  l3c_cm <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_quartiles("AGE", cumulative = TRUE) |>
    analyze("BMRKR2") |>
    append_topleft("counts")

  tbl3c_cm <- build_table(l3c_cm, ex_adsl)
  # split_rows_by_quartiles
  l4 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    split_rows_by_quartiles("AGE", split_label = "Age") |>
    analyze("BMRKR2") |>
    append_topleft(c("Age Quartiles", " Counts BMRKR2"))

  tbl4 <- build_table(l4, ex_adsl)


  cvs4 <- unlist(cell_values(tbl4))

  valslst4 <- unlist(lapply(1:3, function(i) lapply(cvs4, function(lst) lst[i])))

  names(valslst4) <- gsub("^(.*)\\.BMRKR2\\.(.*)$", "\\2.\\1", names(valslst4))
  valslst3 <- unlist(cell_values(tbl3c))
  expect_identical(
    valslst3,
    valslst4[names(valslst3)]
  )

  l4cm <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    split_rows_by_quartiles("AGE", split_label = "Age", cumulative = TRUE) |>
    analyze("BMRKR2") |>
    append_topleft(c("Age Cumulative Quartiles", " Counts BMRKR2"))
  tbl4cm <- build_table(l4cm, ex_adsl)


  cvs4cm <- unlist(cell_values(tbl4cm))

  valslst4cm <- unlist(lapply(1:3, function(i) lapply(cvs4cm, function(lst) lst[i])))

  names(valslst4cm) <- gsub("^(.*)\\.BMRKR2\\.(.*)$", "\\2.\\1", names(valslst4cm))
  valslst3cm <- unlist(cell_values(tbl3c_cm))
  expect_identical(
    valslst3cm,
    valslst4cm[names(valslst3cm)]
  )
})

## https://github.com/insightsengineering/rtables/issues/323

test_that("empty factor levels represented correctly when ref group is set", {
  df <- data.frame(
    val = 1:10,
    grp = factor(rep("a", 10), levels = c("a", "b"))
  )


  tbl <- basic_table() |>
    split_cols_by("grp", ref_group = "a") |>
    analyze("val") |>
    build_table(df)

  expect_identical(ncol(tbl), 2L)
})

test_that("error on empty level of splitting variable", {
  mydf <- data.frame(
    x = c("hi", "", "lo"), y = c(5, 10, 20),
    stringsAsFactors = FALSE
  )

  mydf2 <- mydf
  mydf2$x <- factor(mydf2$x)

  lyt1 <- basic_table() |>
    split_cols_by("x") |>
    analyze("y")
  expect_error(
    build_table(lyt1, mydf),
    "Got empty string level in splitting variable x"
  )
  expect_error(
    build_table(lyt1, mydf2),
    "Got empty string level in splitting variable x"
  )

  lyt2 <- basic_table() |>
    split_rows_by("x") |>
    analyze("y")

  expect_error(
    build_table(lyt2, mydf),
    "Got empty string level in splitting variable x"
  )
  expect_error(
    build_table(lyt2, mydf2),
    "Got empty string level in splitting variable x"
  )
})


test_that("error when afun gives differing numbers of rows is informative", {
  afunconst <- function() {
    nr <- 1
    function(x, ...) {
      nr <<- nr + 1
      in_rows(.list = as.list(seq_len(nr)), .names = paste(seq_len(nr)))
    }
  }

  my_broken_afun <- afunconst()

  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    analyze("AGE", my_broken_afun)

  expect_error(build_table(lyt, DM), "Number of rows generated by analysis function do not match across all columns.")
})

test_that("warning when same name siblings", {
  lyt <- basic_table() |>
    analyze("AGE", mean) |>
    analyze("AGE", mean, var_labels = "AGE2")

  expect_warning(
    tbl <- build_table(lyt, DM),
    "Non-unique sibling analysis table names"
  )

  expect_identical(
    row_paths(tbl)[[3]][2],
    "AGE2"
  )
})

test_that("error when inset < 0 or non-number", {
  expect_error(
    basic_table(inset = -1),
    "invalid table_inset value"
  )
  expect_error(
    expect_warning(basic_table(inset = "haha")),
    "invalid table_inset value"
  )
})

test_that("error when ref_group value not a level of var when using split_cols_by", {
  lyt <- basic_table() |>
    split_cols_by("ARM", ref_group = "test_level")
  expect_error(
    tbl <- build_table(lyt, DM),
    'Reference group "test_level" was not present in the levels of ARM in the data.'
  )
})

test_that("counts_wpcts works as expected", {
  rows_res <- counts_wpcts(DM$SEX, 400)
  rows_exp <- in_rows(
    .list = list(
      F = rcell(c(187, 187 / 400), format = "xx (xx.x%)"),
      M = rcell(c(169, 169 / 400), format = "xx (xx.x%)"),
      U = rcell(c(0, 0), format = "xx (xx.x%)"),
      UNDIFFERENTIATED = rcell(c(0, 0), format = "xx (xx.x%)")
    )
  )
  expect_identical(rows_res, rows_exp)
})

test_that("counts_wpcts returns error correctly", {
  expect_error(
    counts_wpcts(DM$AGE, 400),
    "using the 'counts_wpcts' analysis function requires factor data to guarantee equal numbers"
  )
})


test_that("qtable works", {
  nice_comp_table <- function(t1, t2) {
    expect_identical(row_paths(t1), row_paths(t2))
    expect_identical(col_paths(t1), col_paths(t2))
    expect_equal(cell_values(t1), cell_values(t2))
    expect_identical(top_left(t1), top_left(t2))
  }
  summary_list <- function(x, ...) as.list(summary(x))
  summary_list2 <- function(x, ...) in_rows(.list = summary_list(x, ...), .formats = "xx.xx")

  t0 <- qtable(ex_adsl)
  count <- function(df, ...) rcell(NROW(df), label = "count")
  count_use_nms <- function(df, .spl_context, ...) {
    nm <- tail(.spl_context$value, 1)
    rcell(NROW(df), label = nm)
  }
  t0b <- basic_table(show_colcounts = TRUE) |>
    analyze(names(ex_adsl)[1], count) |>
    build_table(ex_adsl)
  nice_comp_table(t0, t0b)

  t1 <- qtable(ex_adsl, row_vars = "ARM")
  t1b <- basic_table(show_colcounts = TRUE) |>
    split_rows_by("ARM", child_labels = "hidden") |>
    analyze(names(ex_adsl)[1], count_use_nms) |>
    append_topleft("count") |>
    build_table(ex_adsl)
  nice_comp_table(t1, t1b)
  t2 <- qtable(ex_adsl, col_vars = "ARM")
  t2b <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", child_labels = "hidden") |>
    analyze(names(ex_adsl)[1], count) |>
    build_table(ex_adsl)
  nice_comp_table(t2, t2b)

  t3 <- qtable(ex_adsl, row_vars = "SEX", col_vars = "ARM")
  t3b <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", child_labels = "hidden") |>
    split_rows_by("SEX", child_labels = "hidden", split_fun = drop_split_levels) |>
    analyze(names(ex_adsl)[1], count_use_nms) |>
    append_topleft("count") |>
    build_table(ex_adsl)
  nice_comp_table(t3, t3b)

  t4 <- qtable(ex_adsl, row_vars = c("COUNTRY", "SEX"), col_vars = c("ARM", "STRATA1"))
  t4b <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", child_labels = "hidden") |>
    split_cols_by("STRATA1") |>
    split_rows_by("COUNTRY", split_fun = drop_split_levels) |>
    split_rows_by("SEX", split_fun = drop_split_levels, child_labels = "hidden") |>
    analyze(names(ex_adsl)[1], count_use_nms) |>
    append_topleft("count") |>
    build_table(ex_adsl)
  nice_comp_table(t4, t4b)

  t5 <- qtable(ex_adsl,
    row_vars = c("COUNTRY", "SEX"),
    col_vars = c("ARM", "STRATA1"), avar = "AGE", afun = mean
  )

  mean_use_nm <- function(x, .spl_context, ...) {
    rcell(mean(x, ...), format = "xx.xx", label = tail(.spl_context$value, 1))
  }
  t5b <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", split_fun = drop_split_levels, child_labels = "hidden") |>
    split_cols_by("STRATA1", split_fun = drop_split_levels) |>
    split_rows_by("COUNTRY", split_fun = drop_split_levels) |>
    split_rows_by("SEX", child_labels = "hidden", split_fun = drop_split_levels) |>
    analyze("AGE", mean_use_nm) |>
    append_topleft("AGE - mean") |>
    build_table(ex_adsl)
  nice_comp_table(t5, t5b)
  t6 <- qtable(ex_adsl, row_vars = "SEX", col_vars = "ARM", avar = "AGE", afun = summary_list)
  t6b <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", split_fun = drop_split_levels, child_labels = "hidden") |>
    split_rows_by("SEX", split_fun = drop_split_levels) |>
    analyze("AGE", summary_list2) |>
    append_topleft("AGE - summary_list") |>
    build_table(ex_adsl)
  nice_comp_table(t6, t6b)

  t7 <- suppressWarnings(qtable(ex_adsl,
    row_vars = "SEX",
    col_vars = "ARM", avar = "AGE", afun = range
  ))
  range_use_nms <- function(x, .spl_context, ...) {
    rcell(suppressWarnings(range(x)), label = tail(.spl_context$value, 1), format = "xx.x / xx.x")
  }

  t7b <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", split_fun = drop_split_levels, child_labels = "hidden") |>
    split_rows_by("SEX", child_labels = "hidden", split_fun = drop_split_levels) |>
    analyze("AGE", range_use_nms) |>
    append_topleft("AGE - range") |>
    build_table(ex_adsl)
  nice_comp_table(t7, t7b)

  t8 <- qtable(ex_adsl,
    row_vars = c("COUNTRY", "SEX"),
    col_vars = c("ARM"), avar = "AGE", afun = mean,
    summarize_groups = TRUE
  )

  t9 <- qtable(ex_adsl,
    row_vars = c("COUNTRY", "SEX"),
    col_vars = c("ARM"), avar = "AGE", afun = summary_list,
    summarize_groups = TRUE
  )
  t9b <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", split_fun = drop_split_levels, child_labels = "hidden") |>
    split_rows_by("COUNTRY", split_fun = drop_split_levels) |>
    summarize_row_groups() |>
    split_rows_by("SEX", split_fun = drop_split_levels) |>
    summarize_row_groups() |>
    analyze("AGE", summary_list2) |>
    append_topleft("AGE - summary_list") |>
    build_table(ex_adsl)

  nice_comp_table(t9, t9b)

  ## regressions tests for https://github.com/insightsengineering/rtables/issues/698

  fivenum3 <- function(x) {
    as.list(fivenum(x))
  }

  t10 <- qtable(ex_adsl, col_vars = "ARM", avar = "AGE", afun = fivenum3, row_labels = letters[1:5])
  expect_equal(top_left(t10), "AGE - fivenum3")

  mpf10 <- matrix_form(t10)
  expect_equal(
    mf_strings(mpf10)[3:7, 1],
    letters[1:5]
  )

  t11 <- qtable(
    ex_adsl,
    row_vars = "STRATA2", col_vars = "ARM", avar = "AGE", afun = fivenum3, row_labels = letters[1:5]
  )
  expect_equal(top_left(t11), "AGE - fivenum3")
  mpf11 <- matrix_form(t11)
  expect_equal(
    mf_strings(mpf11)[4:8, 1],
    letters[1:5]
  )


  t12 <- qtable(ex_adsl, row_vars = "STRATA2", col_vars = "ARM", avar = "AGE", afun = mean, row_labels = "mylabel")
  ## compactness
  expect_equal(top_left(t12), "mylabel")
  mpf12 <- matrix_form(t12)
  expect_equal(mf_strings(mpf12)[3:4, 1], levels(ex_adsl$STRATA2))

  t13 <- qtable(ex_adsl, col_vars = "ARM", avar = "AGE", afun = mean, row_labels = "mylabel")
  expect_identical(top_left(t13), character())
  mpf13 <- matrix_form(t13)
  expect_equal(mf_strings(mpf13)[3, 1], "mylabel")

  expect_error(
    qtable(ex_adsl,
      row_vars = "STRATA2", col_vars = "ARM", avar = "AGE",
      afun = mean, row_labels = c("ABC", "EFG", "HIJ")
    ),
    "does not agree with number of rows"
  )

  expect_error(
    qtable(ex_adsl,
      col_vars = "ARM", avar = "AGE", afun = fivenum3,
      row_labels = "ABC"
    ),
    "does not agree with number of rows"
  )
})


## https://github.com/insightsengineering/rtables/issues/671
test_that("problematic labels are caught and give informative error message", {
  lyt <- basic_table() |>
    split_rows_by("Species") |>
    analyze("Sepal.Length", afun = make_afun(simple_analysis, .labels = list(Mean = "this is {test}")))

  expect_error(build_table(lyt, iris), "Labels cannot contain [{] or [}] due to")
})

## No superfluous warning

test_that("No superfluous warning when ref group is set with custom split fun", {
  reorder_facets <- function(splret, spl, fulldf, ...) {
    # browser() if you enter here the order of splret seems already correct
    ord <- order(names(splret$values))
    make_split_result(
      splret$values[ord],
      splret$datasplit[ord],
      splret$labels[ord]
    )
  }

  lyt <- basic_table() |>
    split_cols_by("Species", ref_group = "virginica", split_fun = make_split_fun(post = list(reorder_facets))) |>
    analyze("Sepal.Length")
  expect_silent(build_table(lyt, iris))
})


test_that("path uniqueness/sibling name uniqueness is enforced correctly", {
  build_and_check_row_paths <- function(lyt, expect_message = TRUE, data = ex_adsl) {
    if (expect_message) {
      tbl <- expect_message(build_table(lyt, data), "Modifying subtable (or row) names", fixed = TRUE)
    } else {
      tbl <- expect_silent(build_table(lyt, data))
    }

    rdf <- make_row_df(tbl, visible_only = FALSE)
    rdf <- subset(rdf, node_class != "LabelRow") ## these are duplciate paths with their tables
    paths <- rdf$path
    pathkeys <- vapply(paths, paste, collapse = "xXx.xXx", "")
    expect_true(!any(duplicated(pathkeys)))
    expect_silent(lapply(paths, function(pth) tt_at_path(tbl, pth)))
    tbl
  }

  ## analyze and then split on same variable
  lyt1 <- basic_table() |>
    analyze("STRATA1") |>
    split_rows_by("STRATA1") |>
    analyze("AGE") |>
    analyze("STRATA1", nested = FALSE)

  tbl1 <- build_and_check_row_paths(lyt1, TRUE)

  lyt1b <- basic_table() |>
    analyze("STRATA1") |>
    split_rows_by("STRATA1", parent_name = "STRATA1[2]") |>
    analyze("AGE") |>
    analyze("STRATA1", table_names = "STRATA1[3]", nested = FALSE)

  tbl1b <- build_and_check_row_paths(lyt1b, FALSE)
  expect_identical(tbl1, tbl1b)

  ## badly designed a/cfun
  bad_acfun <- function(x, labelstr = NULL, ...) {
    list(
      rcell("haha", label = "bad name"),
      rcell("haha", label = "bad name")
    )
  }

  lyt2 <- basic_table() |>
    analyze("AGE", afun = bad_acfun)

  tbl2 <- build_and_check_row_paths(lyt2, TRUE)

  ## duplicate multivar analyzes (for completeness this is silly in practice)
  ## this has named content tables (even though they're empty) in the multi-var
  ## containing table, probably shouldn't because generally content tables aren't
  ## named, since you use the @content path element to get them, but for now
  ## we leave this behavior and match it in the uniqify case.
  lyt3 <- basic_table() |>
    analyze(c("STRATA1", "AGE")) |>
    analyze(c("STRATA1", "AGE"), nested = FALSE)

  tbl3 <- build_and_check_row_paths(lyt3, TRUE)

  lyt3b <- basic_table() |>
    analyze(c("STRATA1", "AGE")) |>
    analyze(c("STRATA1", "AGE"), nested = FALSE, parent_name = "ma_STRATA1_AGE[2]")
  tbl3b <- build_and_check_row_paths(lyt3b, FALSE)
  expect_identical(tbl3, tbl3b)
})


## used in both formats_var and format var list test sets below
fmts_afun <- function(x, .formats = NULL) {
  in_rows(
    n = sum(!is.na(x)),
    median = median(x, na.rm = TRUE),
    "mean (sd)" = c(mean(x, na.rm = TRUE), sd(x, na.rm = TRUE)),
    "missing_val" = NA,
    .formats = .formats
  )
}


## tern style row naming partial match support
factor_count_prepend_var <- function(x, .var) {
  stopifnot(is.factor(x))
  vals <- as.list(table(x))

  in_rows(.list = vals, .names = paste0(.var, names(vals)), .labels = levels(x))
}

alt_fmts <- list(list(
  median = "xx.x",
  "mean (sd)" = "xx.xx (xx.xxx)",
  missing_val = "xx",
  STRATA1 = "xx"
))

crp_fmts <- list(list(
  median = "xx.",
  "mean (sd)" = "xx.x (xx.xx)",
  missing_val = "xx",
  STRATA1 = "N=xx"
))

iga_fmts <- list(list(
  median = "xx.xx",
  "mean (sd)" = "xx. (xx.x)",
  missing_val = "xx",
  STRATA1 = "xx.x"
))


test_that("formats_var works in analyze()", {
  adlb <- ex_adlb

  adlb$formats <- alt_fmts
  adlb$formats[adlb$PARAMCD == "CRP"] <- crp_fmts

  adlb$formats[adlb$PARAMCD == "IGA"] <- iga_fmts

  adlb$na_strs <- list(list())
  adlb$na_strs[adlb$PARAMCD == "CRP"] <- list(list(missing_val = "n/a"))
  adlb$na_strs[adlb$PARAMCD == "IGA"] <- list(list(missing_val = "-"))


  ## works without also specifying na_strs_var
  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("AVAL", fmts_afun, formats_var = "formats")

  tbl <- build_table(lyt, adlb)

  mpf <- matrix_form(tbl)

  mpf_fmts_real <- mf_formats(mpf)[-1, -1] # no row labs, no col labs

  mpf_fmts_exp <- matrix(
    c(
      "-", "xx", unlist(alt_fmts[[1]][1:3]), ## no STRATA1 here and below
      "-", "xx", unlist(crp_fmts[[1]][1:3]),
      "-", "xx", unlist(iga_fmts[[1]][1:3])
    ),
    nrow = nrow(mpf_fmts_real),
    ncol = ncol(mpf_fmts_real)
  )

  expect_identical(
    mpf_fmts_real,
    mpf_fmts_exp
  )

  fmtcells <- get_formatted_cells(tbl)

  expect_equal(
    fmtcells[c(3:4, 8:9, 13:14), 1],
    c(
      "49.6", "49.91 (8.098)",
      "50", "50.2 (8.61)",
      "49.69", "50 (7.8)"
    )
  )

  ## can use formats_var with na_str specified the old way
  lyta <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("AVAL",
      fmts_afun,
      formats_var = "formats",
      na_str = "global na cha cha cha"
    )

  tbla <- build_table(lyta, adlb)

  expect_true(
    all(get_formatted_cells(tbla)[c(5, 10, 15), ] == "global na cha cha cha")
  )

  lytb <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("AVAL",
      fmts_afun,
      formats_var = "formats",
      na_str = list("global na cha cha cha")
    )

  tblb <- build_table(lytb, adlb)

  ## works when also specifying na_strs_var
  lyt2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("AVAL", fmts_afun, formats_var = "formats", na_strs_var = "na_strs")

  tbl2 <- build_table(lyt2, adlb)

  fmtcells2 <- get_formatted_cells(tbl2)
  expect_true(all(fmtcells2[5, ] == "NA"))
  expect_true(all(fmtcells2[10, ] == "n/a"))
  expect_true(all(fmtcells2[15, ] == "-"))

  adlb_b <- adlb
  adlb_b$na_strs <- ifelse(adlb_b$PARAMCD == "ALT", list(list("NA")),
    ifelse(adlb_b$PARAMCD == "CRP",
      list(list("n/a")),
      list(list("-"))
    )
  )

  tbl2b <- build_table(lyt2, adlb_b)
  ## tabletree objects not identical for some reason but...
  expect_identical(
    get_formatted_cells(tbl2),
    get_formatted_cells(tbl2b)
  )

  ## precendence and interaction with .formats use in in_rows

  lyt3 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("AVAL", fmts_afun,
      formats_var = "formats",
      extra_args = list(
        .formats = list(
          n = "xx",
          median = "xx.xxx",
          "mean (sd)" = "xx.x - xx.x",
          missing_val = "xx"
        )
      )
    )

  tbl3 <- build_table(lyt3, adlb)

  lyt3b <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("AVAL", fmts_afun,
      extra_args = list(
        .formats = list(
          n = "xx",
          median = "xx.xxx",
          "mean (sd)" = "xx.x - xx.x",
          missing_val = "xx"
        )
      )
    )

  tbl3b <- build_table(lyt3, adlb)

  expect_identical(tbl3, tbl3b)

  lyt3c <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("AVAL", fmts_afun,
      formats_var = "formats",
      extra_args = list(
        .formats = list(
          n = "default",
          median = "default",
          "mean (sd)" = "default",
          missing_val = "default"
        )
      )
    )

  tbl3c <- build_table(lyt3c, adlb)

  expect_identical(get_formatted_cells(tbl), get_formatted_cells(tbl3c))


  lyt4 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("PARAMCD") |>
    analyze("STRATA1", factor_count_prepend_var, formats_var = "formats")

  tbl4 <- build_table(lyt4, adlb)

  fmtcells4 <- get_formatted_cells(tbl4)

  alt_a_cnt <- with(adlb, sum(ARM == "A: Drug X" & PARAMCD == "ALT" & STRATA1 == "A"))
  crp_b_cnt <- with(adlb, sum(ARM == "B: Placebo" & PARAMCD == "CRP" & STRATA1 == "B"))
  iga_c_cnt <- with(adlb, sum(ARM == "C: Combination" & PARAMCD == "IGA" & STRATA1 == "C"))
  expect_identical(fmtcells4[2, 1], format_value(alt_a_cnt, "xx"))
  expect_identical(fmtcells4[7, 2], format_value(crp_b_cnt, "N=xx"))
  expect_identical(fmtcells4[12, 3], format_value(iga_c_cnt, "xx.x"))


  ## most specific for multiple partial matches

  adlb2 <- adlb
  ## This should do nothing because STRATA1 is an exact match
  adlb2$formats <- lapply(adlb2$formats, function(x) c(x, list(STRAT = "xx.xxx")))

  tbl4b <- build_table(lyt4, adlb2)
  expect_identical(tbl4, tbl4b)

  ## remove perfect match to make sure partial match kicks in
  adlb3 <- adlb2
  adlb3$formats <- lapply(adlb2$formats, function(x) {
    x[["STRATA1"]] <- NULL
    x$STRAT <- "xx.x"
    x
  })
  tbl4c <- build_table(lyt4, adlb3)
  expect_equal(
    get_formatted_cells(tbl4c[-c(1, 5, 9), ]),
    matrix(
      vapply(
        unlist(cell_values(tbl4c)),
        format_value,
        format = "xx.x",
        ""
      ),
      ncol = 3,
      byrow = TRUE
    )
  )

  adlb4 <- adlb3
  ## this should do nothing because STRAT is a better partial match
  adlb4$formats <- lapply(adlb3$formats, function(x) c(list(STR = "xx"), x))
  tbl4d <- build_table(lyt4, adlb4)
  expect_identical(tbl4c, tbl4d)

  adlb5 <- adlb
  adlb5$formats <- list(list())
  adlb5$na_strs <- list(list())
  tbl4e <- build_table(lyt4, adlb5)
  fmtcells4e <- get_formatted_cells(tbl4e)
  expect_equal(
    get_formatted_cells(tbl4e[-c(1, 5, 9), ]),
    matrix(
      vapply(
        unlist(cell_values(tbl4e)),
        format_value,
        format = "xx",
        ""
      ),
      ncol = 3,
      byrow = TRUE
    )
  )

  adlb6 <- adlb
  adlb6$formats <- list(list("xx.x"))
  tbl4f <- build_table(lyt4, adlb6)
  expect_identical(tbl4c, tbl4f)
})

test_that("New format as list of formats for diff vars in analyze works", {
  ## ugh apparently simple_analysis applies a format!!!!!!!!!!!! x.x

  my_stupid_afun <- function(x) {
    if (is.factor(x)) {
      vallst <- lapply(table(x), rcell)
      names(vallst) <- levels(x)
    } else if (is(x, "numeric")) {
      vallst <- list(Mean = rcell(mean(x, na.rm = TRUE)))
    } else {
      stop("no")
    }
    in_rows(.list = vallst)
  }

  ## basic case: list of individual formats, one for each var
  lyt <- basic_table() |>
    analyze(c("AGE", "BMRKR1", "STRATA1"),
      afun = my_stupid_afun,
      format = list(
        AGE = "xx.x",
        BMRKR1 = "xx.xx",
        STRATA1 = "N=xx"
      )
    )

  tbl <- build_table(lyt, ex_adsl)

  age_mean <- mean(ex_adsl$AGE, na.rm = TRUE)
  bmrkr1_mean <- mean(ex_adsl$BMRKR1, na.rm = TRUE)
  strata1_counts <- table(ex_adsl$STRATA1)
  sex_counts <- table(ex_adsl$SEX)
  exp <- matrix(
    c(
      "",
      format_value(age_mean, "xx.x"),
      "",
      format_value(bmrkr1_mean, "xx.xx"),
      "",
      vapply(strata1_counts, format_value, format = "N=xx", "")
    ),
    ncol = 1
  )

  expect_equal(get_formatted_cells(tbl), exp)

  ## preserve old stanky behavior I for some reason thought was a good idea
  ## list of formats applied to analysis of all vars and taken in order
  ## with recycling (!!!!)
  ## ... Past me was a genius of unparalleled insight /s

  lyt_old <- basic_table() |>
    analyze(c("AGE", "BMRKR1", "STRATA1", "SEX"),
      afun = my_stupid_afun,
      format = list(
        "xx.x",
        "xx.xx",
        "N=xx"
      )
    )

  tbl_old <- build_table(lyt_old, ex_adsl)

  fmtvec <- c("xx.x", "xx.xx", "N=xx")
  ## supppress **very reasonable** warnings about bad recycling
  exp_old <- suppressWarnings(matrix(
    ncol = 1,
    c(
      "",
      format_value(age_mean, "xx.x"),
      "",
      format_value(bmrkr1_mean, "xx.x"),
      "",
      mapply(format_value,
        x = strata1_counts,
        format = fmtvec
      ),
      "",
      mapply(format_value,
        x = sex_counts,
        format = fmtvec
      ) # !! insane recycling behavior. what?!?
    )
  ))

  ## confirmed this behavior on main before merge. ugh
  expect_identical(get_formatted_cells(tbl_old), exp_old)


  ## even newer extra hotness: list of formats for each var

  ## beware extra layer of listiness between list column case and this one!
  varfmts <- list(
    AGE = alt_fmts[[1]],
    BMRKR1 = crp_fmts[[1]],
    STRATA1 = crp_fmts[[1]],
    SEX = iga_fmts[[1]]
  )

  ## part one, single afun exact matches

  lyt2 <- basic_table() |>
    analyze(c("AGE", "BMRKR1"),
      afun = fmts_afun,
      format = varfmts
    )

  tbl2 <- build_table(lyt2, ex_adsl)

  fmtcells2 <- get_formatted_cells(tbl2)

  expect_identical(
    fmtcells2,
    matrix(
      ncol = 1,
      c(
        "",
        format_value(sum(!is.na(ex_adsl$AGE)), "xx"),
        format_value(median(ex_adsl$AGE), "xx.x"),
        format_value(c(mean(ex_adsl$AGE), sd(ex_adsl$AGE)), "xx.xx (xx.xxx)"),
        "NA",
        "",
        format_value(sum(!is.na(ex_adsl$BMRKR1)), "xx"),
        format_value(median(ex_adsl$BMRKR1), "xx."),
        format_value(
          c(mean(ex_adsl$BMRKR1), sd(ex_adsl$BMRKR1)),
          "xx.x (xx.xx)"
        ),
        "NA"
      )
    )
  )


  lyt2a <- basic_table() |>
    analyze(c("AGE", "BMRKR1"),
      afun = fmts_afun,
      format = varfmts,
      na_str = "eh? what?"
    )

  tbl2a <- build_table(lyt2a, ex_adsl)

  fmtcells2a <- get_formatted_cells(tbl2a)
  expect_true(all(fmtcells2a[c(5, 10), 1] == "eh? what?"))
  expect_equal(fmtcells2[-c(5, 10), ], fmtcells2a[-c(5, 10), ])

  lyt2b <- basic_table() |>
    analyze(
      c("AGE", "BMRKR1"),
      afun = fmts_afun,
      format = list(
        AGE = function(x, ...) "what?",
        BMRKR1 = function(x, ...) "nah"
      ),
      na_str = list(
        AGE = "-",
        BMRKR1 = "X"
      )
    )

  tbl2b <- build_table(lyt2b, ex_adsl)

  fmtcells2b <- get_formatted_cells(tbl2b)
  expect_equal(
    fmtcells2b,
    matrix(
      ncol = 1,
      c(
        "",
        rep("what?", 3),
        "-",
        "",
        rep("nah", 3),
        "X"
      )
    )
  )

  lyt2c <- basic_table() |>
    analyze(
      c("AGE", "BMRKR1"),
      afun = fmts_afun,
      format = list(
        AGE = list(function(x, ...) "what?"),
        BMRKR1 = list(function(x, ...) "nah")
      ),
      na_str = list(
        AGE = "-",
        BMRKR1 = "X"
      )
    )

  tbl2c <- build_table(lyt2c, ex_adsl)
  expect_identical(tbl2b, tbl2c)

  ## part two, single afun partial matches

  lyt3 <- basic_table() |>
    analyze(c("STRATA1", "SEX"),
      afun = factor_count_prepend_var,
      format = varfmts
    )

  tbl3 <- build_table(lyt3, ex_adsl)
  fmtcells3 <- get_formatted_cells(tbl3)

  expect_identical(
    fmtcells3,
    matrix(
      ncol = 1,
      c(
        "",
        vapply(strata1_counts, format_value, format = "N=xx", ""),
        "",
        vapply(sex_counts, format_value, format = "xx", "")
      )
    )
  )

  ## part 3 multiple afuns

  lyt4 <- basic_table() |>
    analyze(c("AGE", "BMRKR1", "STRATA1", "SEX"),
      afun = list(
        fmts_afun,
        fmts_afun,
        factor_count_prepend_var,
        factor_count_prepend_var
      ),
      format = varfmts
    )

  tbl4 <- build_table(lyt4, ex_adsl)

  fmtcells4 <- get_formatted_cells(tbl4)

  expect_identical(
    fmtcells4,
    rbind(fmtcells2, fmtcells3)
  )

  ## does it work with "the functions"?

  bad_fmt_factory <- function(val) function(x, ...) val

  lyt5 <- basic_table() |>
    analyze(c("AGE", "BMRKR1", "STRATA1", "SEX"),
      afun = list(
        fmts_afun,
        fmts_afun,
        factor_count_prepend_var,
        factor_count_prepend_var
      ),
      format = list(
        AGE = bad_fmt_factory("AGE"),
        BMRKR1 = bad_fmt_factory("BMRKR1"),
        STRATA1 = bad_fmt_factory("STRATA1"),
        SEX = bad_fmt_factory("SEX")
      )
    )

  tbl5 <- build_table(lyt5, ex_adsl)

  fmtcells5 <- get_formatted_cells(tbl5)

  expect_identical(
    fmtcells5,
    matrix(
      ncol = 1,
      c(
        c("", rep("AGE", 3), "NA"),
        c("", rep("BMRKR1", 3), "NA"),
        c("", rep("STRATA1", 3)),
        c("", rep("SEX", 4))
      )
    )
  )
})
