context("Printing tables")

test_that("toString method works correclty", {
  tbl <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("Species") |>
    analyze(c("Sepal.Length", "Petal.Width"), function(x) {
      in_rows(
        mean_sd = c(mean(x), sd(x)),
        var = var(x),
        min_max = range(x),
        .formats = c("xx.xx (xx.xx)", "xx.xxx", "xx.x - xx.x"),
        .labels = c("Mean (sd)", "Variance", "Min - Max")
      )
    }) |>
    build_table(iris, hsep = "=")

  capture.output(print(tbl))

  expstr_lns <- c(
    "                 setosa      versicolor     virginica ",
    "                 (N=50)        (N=50)        (N=50)   ",
    "======================================================",
    "Sepal.Length                                          ",
    "  Mean (sd)    5.01 (0.35)   5.94 (0.52)   6.59 (0.64)",
    "  Variance        0.124         0.266         0.404   ",
    "  Min - Max     4.3 - 5.8     4.9 - 7.0     4.9 - 7.9 ",
    "Petal.Width                                           ",
    "  Mean (sd)    0.25 (0.11)   1.33 (0.20)   2.03 (0.27)",
    "  Variance        0.011         0.039         0.075   ",
    "  Min - Max     0.1 - 0.6     1.0 - 1.8     1.4 - 2.5 \n"
  )

  exp_str <- paste(expstr_lns, collapse = "\n")

  expect_identical(
    toString(tbl),
    exp_str
  )
})

test_that("labels correctly used for columns rather than names", {
  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    analyze("AGE")

  tbl <- build_table(lyt, rawdat)

  matform <- matrix_form(tbl)
  expect_identical(
    matform$strings[1:2, ],
    matrix(
      c(
        "", rep(c("ARM1", "ARM2"), times = c(2, 2)),
        "", rep(c("Male", "Female"), times = 2)
      ),
      byrow = TRUE, nrow = 2, dimnames = NULL
    )
  )
  expect_identical(
    matform$spans,
    matrix(
      c(
        1, rep(2, 4),
        rep(1, 10)
      ),
      byrow = TRUE,
      nrow = 3,
      dimnames = list(NULL, c("", paste(
        rep(c("ARM1", "ARM2"),
          times = c(2, 2)
        ),
        rep(c("M", "F"),
          times = 2
        ),
        sep = "."
      )))
    )
  )

  ## multivarsplit varlabels work correctly
  tbl2 <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_multivar(c("VALUE", "PCTDIFF"), varlabels = c("Measurement", "Pct Diff")) |>
    split_rows_by("RACE", split_label = "ethnicity", split_fun = drop_split_levels) |>
    summarize_row_groups() |>
    analyze_colvars(afun = mean, format = "xx.xx") |>
    build_table(rawdat2)

  matform2 <- matrix_form(tbl2)

  expect_identical(
    matform2$strings[1:2, ],
    matrix(
      c(
        "", rep(c("ARM1", "ARM2"), times = c(2, 2)),
        "", rep(c("Measurement", "Pct Diff"), times = 2)
      ),
      byrow = TRUE, nrow = 2
    )
  )

  ## same var different labels in split_by_multivar
  vlabs <- c("Age", "SecondAge", "Gender", "Age Redux")
  lyt3 <- basic_table() |>
    split_cols_by_multivar(c("AGE", "AGE", "SEX", "AGE"),
      varlabels = vlabs
    ) |>
    analyze_colvars(list(mean, median, function(x, ...) max(table(x)), sd))

  tbl3 <- build_table(lyt3, rawdat)
  matform3 <- matrix_form(tbl3)
  expect_identical(
    matform3$strings[1, ],
    c("", vlabs)
  )
})

test_that("nested identical labels work ok", {
  df <- data.frame(
    h2 = factor(c("<Missing>")),
    x = factor(c("<Missing>"))
  )

  t2 <- basic_table() |>
    split_rows_by("h2") |>
    analyze("x") |>
    build_table(df)
  mat <- matrix_form(t2)
  expect_identical(mat$strings[, 1], c("", "<Missing>", "<Missing>"))
})


test_that("newline in column names and possibly cell values work", {
  df <- data.frame(
    n = 1,
    median = 10
  )

  lyt <- basic_table() |>
    split_cols_by_multivar(vars = c("n", "median"), varlabels = c("N", "Median\n(Days)")) |>
    analyze_colvars(afun = mean)
  tbl <- build_table(lyt, df)

  mat <- matrix_form(tbl)
  expect_identical(
    mat$strings,
    matrix(
      c(
        "", "", "Median",
        "", "N", "(Days)",
        "mean", "1", "10"
      ),
      nrow = 3, byrow = TRUE
    )
  )
  ## Test top_left preservation
  rawdat2 <- rawdat
  rawdat2$arm_label <- ifelse(rawdat2$ARM == "ARM1", "Arm\n 1 ", "Arm\n 2 ")

  lyt2 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", labels_var = "arm_label") |>
    split_cols_by("SEX", "Gender", labels_var = "gend_label") |>
    split_rows_by("RACE", "Ethnicity", labels_var = "ethn_label", label_pos = "topleft") |>
    split_rows_by("FACTOR2", "Factor2",
      split_fun = remove_split_levels("C"),
      labels_var = "fac2_label",
      label_pos = "topleft"
    ) |>
    analyze(
      "AGE", "Age Analysis",
      afun = function(x) list(mean = mean(x), median = median(x)),
      format = "xx.xx"
    )

  tbl2 <- build_table(lyt2, rawdat2)
  matform2 <- matrix_form(tbl2)
  expect_identical(
    dim(matform2$strings),
    c(18L, 5L)
  )
  expect_identical(
    mf_nlheader(matform2),
    4L
  )
  expect_identical(
    matform2$strings[1:4, 1, drop = TRUE],
    c("", "", "Ethnicity", "  Factor2")
  )

  ## cell has \n

  lyt3 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("SEX") |>
    analyze("AGE", afun = function(x) {
      mn <- round(mean(x), 2)
      if (!is.nan(mn) && mn > mean(DM$AGE)) {
        val <- paste(mn, "  ^  ", sep = "\n")
      } else {
        val <- paste(mn)
      }
      in_rows(my_row_label = rcell(val,
        format = "xx"
      ))
    })
  tbl3 <- build_table(lyt3, DM)
  matform3 <- matrix_form(tbl3)
  expect_identical(
    matform3$strings[, 1, drop = TRUE],
    c(
      "",
      "F", "my_row_label", "",
      "M", "my_row_label", "",
      "U", "my_row_label",
      "UNDIFFERENTIATED", "my_row_label"
    )
  )
  expect_identical(
    matform3$strings[, 2, drop = TRUE],
    c(
      "A: Drug X",
      "", "33.71", "",
      "", "36.55", "  ^  ",
      "", "NaN",
      "", "NaN"
    )
  )
})


test_that("alignment works", {
  lyt <- basic_table() |>
    analyze("AGE", function(x) {
      in_rows(
        left = rcell("l", align = "left"),
        right = rcell("r", align = "right"),
        center = rcell("c", align = "center")
      )
    })

  ## set the hsep so it works the same in all locales since thats not what
  ## we are testing
  aligntab <- build_table(lyt, DM, hsep = "=")

  matform <- matrix_form(aligntab)
  expect_identical(
    matform$aligns,
    cbind("left", c("center", "left", "right", "center"))
  )

  str <- toString(aligntab)
  expect_identical(
    str,
    gsub(
      "—", horizontal_sep(aligntab),
      "         all obs\n————————————————\nleft     l      \nright          r\ncenter      c   \n"
    )
  )

  lyt2 <- basic_table() |>
    analyze("AGE", function(x) {
      in_rows(
        .list = list(left = "l", right = "r", center = "c"),
        .aligns = c(left = "left", right = "right", center = "center")
      )
    })

  aligntab2 <- build_table(lyt, DM, hsep = "=")
  expect_identical(aligntab, aligntab2)
})

test_that("Decimal alignment works", {
  dec_als <- c("dec_left", "decimal", "dec_right")
  df <- data.frame(
    ARM = factor(dec_als, levels = dec_als),
    AETOXGR = factor(seq(1:3)),
    stringsAsFactors = FALSE
  )

  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    analyze("AETOXGR", afun = function(x, .spl_context, .var) {
      form_v <- list_valid_format_labels()[[1]]
      num_v <- as.list(rep(11.11111, length(form_v)))
      names(num_v) <- paste0("c", seq_along(form_v))

      # xxx to be replaced by cur_col_id
      ref_col <- .spl_context$cur_col_subset
      which_ref_col <- sapply(.spl_context, function(i) identical(i, ref_col))
      col_nm_matched <- names(which_ref_col[which_ref_col])
      stopifnot(col_nm_matched > 1)

      in_rows(
        .list = num_v,
        .formats = form_v,
        .aligns = rep(col_nm_matched[1], length(num_v))
      )
    })

  tbl <- build_table(lyt, df)

  cw <- propose_column_widths(tbl)
  cw[2:4] <- cw[2:4] + 3
  # Printed comparison with padding
  res <- strsplit(toString(tbl, widths = cw, hsep = "-"), "\\\n")[[1]]
  expected <- c(
    "         dec_left           decimal          dec_right   ",
    "---------------------------------------------------------",
    "c1       11.11111           11.11111            11.11111 ", ## xx
    "c2       11                 11                  11       ", ## xx.
    "c3       11.1               11.1                11.1     ", ## xx.x
    "c4       11.11              11.11               11.11    ", ## xx.xx
    "c5       11.111             11.111              11.111   ", ## xx.xxx
    "c6       11.1111            11.1111             11.1111  ", ## xx.xxxx
    "c7     1111.111%          1111.111%           1111.111%  ", ## xx%
    "c8     1111%              1111%               1111%      ", ## xx.%
    "c9     1111.1%            1111.1%             1111.1%    ", ## xx.x%
    "c10    1111.11%           1111.11%            1111.11%   ", ## xx.xx%
    "c11    1111.111%          1111.111%           1111.111%  ", ## xx.xxx%
    "c12   (N=11.11111)       (N=11.11111)        (N=11.11111)", ## (N=xx)
    "c13    N=11.11111         N=11.11111          N=11.11111 ", ## N=xx
    "c14      11.1               11.1                11.1     ", ## >999.9
    "c15      11.11              11.11               11.11    ", ## >999.99
    "c16      11.1111            11.1111             11.1111  ", ## x.xxxx | (<0.0001)
    "c17      11.11111           11.11111            11.11111 " ## default
  )
  expect_identical(res, expected)
})


test_that("Various Printing things work", {
  txtcon <- textConnection("printoutput", "w")
  sink(txtcon)
  lyt <- make_big_lyt()

  ## ensure print method works for predata layout
  print(lyt)
  tab <- build_table(lyt, rawdat)
  ## treestruct(tab)

  table_structure(tab, detail = "subtable") ## treestruct(tab)
  table_structure(tab, detail = "row") ## treestruct(tab)
  coltree_structure(tab)

  ## this is not intended to be a valid layout, it just
  ## tries to hit every type of split for the print machinery
  splvec <- rtables:::SplitVector(lst = list( ## rtables:::NULLSplit(),
    rtables:::AllSplit(split_label = "MyAll"),
    rtables:::RootSplit("MyRoot"),
    ManualSplit(c("0", "1", "2"), label = LETTERS[1:3]),
    rtables:::make_static_cut_split("x", "StaticCut", c(1, 3, 5),
      cutlabels = LETTERS[1:3]
    ),
    rtables:::make_static_cut_split("x", "CumuStaticCut", c(1, 3, 5),
      cutlabels = LETTERS[1:3],
      cumulative = TRUE
    ),
    VarDynCutSplit("x", "DynCut", rtables:::qtile_cuts),
    VarLevWBaselineSplit("X", "ref", split_label = "VWBaseline"),
    AnalyzeColVarSplit(list(mean))
  ))
  splvec <- rtables:::cmpnd_last_rowsplit(splvec, AnalyzeVarSplit("x", afun = mean), AnalyzeMultiVars)
  print(splvec)

  fakelyt <- rtables:::PreDataTableLayouts(
    rlayout = rtables:::PreDataRowLayout(splvec),
    clayout = rtables:::PreDataColLayout(splvec)
  )
  print(fakelyt)
  print(rtables:::rlayout(fakelyt))
  print(rtables:::clayout(fakelyt))


  ## pos <- TreePos()
  ## print(pos)
  print(col_info(tab))
  show(col_info(tab))
  ctr <- coltree(tab)
  print(ctr)
  show(ctr)
  print(collect_leaves(tab)[[2]])
  sink(NULL)
  expect_false(any(grepl("new..AnalyzeColVarSplit., analysis_fun =", printoutput)))
})

test_that("layout printing works for cornercases", {
  adsl_lyt <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM") |>
    analyze(c("AGE", "SEX"), afun = mean)

  expect_no_error(capture.output(print(adsl_lyt)))
  expect_no_error(capture.output(print(basic_table())))
})


test_that("section_div works throughout", {
  lyt <- basic_table() |>
    split_rows_by("ARM", section_div = "-") |>
    split_rows_by("STRATA1", section_div = " ") |>
    analyze("AGE")

  tbl <- build_table(lyt, DM)

  mylns <- strsplit(toString(tbl), "\\n")[[1]]
  expect_identical(mylns[9], "                        ")
  expect_identical(mylns[12], "------------------------")
  expect_identical(length(mylns), 31L) ## sect div not printed for last one

  lyt2 <- basic_table() |>
    split_rows_by("ARM", section_div = "-") |>
    split_rows_by("STRATA1") |>
    analyze("AGE")

  tbl2 <- build_table(lyt2, DM)
  mylns2 <- strsplit(toString(tbl2), "\\n")[[1]]
  expect_true(check_all_patterns(mylns2[c(10, 18)], "-", nchar(mylns2[2])))
})

test_that("section_div works when analyzing multiple variables", {
  # Regression test for #835
  lyt <- basic_table() |>
    split_rows_by("Species", section_div = "|") |>
    analyze(c("Petal.Width", "Petal.Length"),
      afun = function(x) list("m" = mean(x), "sd" = sd(x)), section_div = "-"
    )

  tbl <- build_table(lyt, iris)
  out <- strsplit(toString(tbl), "\n")[[1]]

  expect_true(check_pattern(out[11], "|", length(out[1])))
  expect_true(check_pattern(out[16], "-", length(out[1])))
})

## section_div passed to analyze works correctly in all cases #863
test_that("analyze section_div works correctly", {
  lyt1 <- basic_table() |>
    split_rows_by("STRATA1") |>
    analyze("SEX", section_div = " ")
  tbl1 <- build_table(lyt1, ex_adsl)
  lns <- capture.output(print(tbl1))
  expect_equal(grep("^[[:space:]]*$", lns), c(8, 14))

  ## analyze section_divs do NOT override split section_divs
  ## this is so users can specify a divider between multi-analyze blocks
  ## that is different than one they want between split sections
  lyt2 <- basic_table() |>
    split_rows_by("STRATA1", section_div = "*") |>
    analyze("SEX", section_div = " ")
  tbl2 <- build_table(lyt2, ex_adsl)
  lns2 <- capture.output(print(tbl2))
  expect_equal(grep("^[*]*$", lns2), c(8, 14))

  lyt3 <- basic_table() |>
    analyze("SEX", section_div = " ") |>
    analyze("STRATA1")
  tbl3 <- build_table(lyt3, ex_adsl)
  lns3 <- capture.output(print(tbl3))
  expect_equal(grep("^[ ]*$", lns3), 8)

  lyt4 <- basic_table() |>
    split_rows_by("STRATA1", section_div = "*") |>
    analyze("SEX", section_div = " ") |>
    analyze("STRATA1")
  tbl4 <- build_table(lyt4, ex_adsl)
  lns4 <- capture.output(print(tbl4))
  expect_equal(grep("^[[:space:]]*$", lns4), c(9, 21, 33))
  expect_equal(grep("^[*]*$", lns4), c(14, 26))

  lyt5 <- basic_table() |>
    split_rows_by("STRATA1", section_div = "*") |>
    analyze(c("SEX", "STRATA1"), section_div = " ")
  tbl5 <- build_table(lyt5, ex_adsl)
  lns5 <- capture.output(print(tbl5))
  expect_identical(lns4, lns5)
})

test_that("Inset works for table, ref_footnotes, and main footer", {
  general_inset <- 3

  lyt <- basic_table(
    title = paste0("Very ", paste0(rep("very", 10), collapse = " "), " long title"),
    subtitles = paste0("Very ", paste0(rep("very", 15), collapse = " "), " long subtitle"),
    main_footer = paste0("Very ", paste0(rep("very", 6), collapse = " "), " long footer"),
    prov_footer = paste0("Very ", paste0(rep("very", 15), collapse = " "), " prov footer"),
    show_colcounts = TRUE,
    inset = 2
  ) |>
    split_rows_by("SEX", page_by = TRUE) |>
    analyze("AGE")

  # Building the table and trimming NAs
  tt <- build_table(lyt, DM)
  tt <- prune_table(tt)
  # tt <- trim_rows(tt)

  # Adding references
  # row_paths(tt)
  # row_paths_summary(tt)
  # col_paths(tt)
  # col_paths_summary(tt)
  txt1 <- "Not the best but very long one, probably longer than possible."
  txt2 <- "Why trimming does not take it out?"
  fnotes_at_path(tt, rowpath = c("SEX", "F", "AGE", "Mean")) <- txt1
  fnotes_at_path(tt, rowpath = c("SEX", "M", "AGE", "Mean"), colpath = c("all obs", "all obs")) <- txt2
  # Test also assign function
  table_inset(tt) <- general_inset

  # Recreating the printed form as a vector
  cat_tt <- toString(matrix_form(tt, TRUE), hsep = "=")
  vec_tt <- strsplit(cat_tt, "\n")[[1]]

  # Taking out empty lines
  vec_tt <- vec_tt[vec_tt != ""]

  # Divide string vector in interested sectors
  sep_index <- which(grepl("==", vec_tt)) - 1
  log_v <- seq_along(vec_tt) %in% c(seq_len(sep_index[1]), length(vec_tt))
  no_inset_part <- vec_tt[log_v]
  inset_part <- vec_tt[!log_v]

  # Check indentation
  no_ins_v <- sapply(no_inset_part, function(x) substr(x, 1, general_inset), USE.NAMES = FALSE)
  ins_v <- sapply(inset_part, function(x) substr(x, 1, general_inset), USE.NAMES = FALSE)
  result <- lapply(list(no_ins_v, ins_v), function(x) all(lengths(regmatches(x, gregexpr(" ", x))) == general_inset))

  expect_false(result[[1]]) # No inset
  expect_true(result[[2]]) # Inset
  expect_true(all(vec_tt[sep_index + 1] == "   ======================"))
})

test_that("Cell and column label wrapping works in printing", {
  # Set colwidths vector
  clw <- c(5, 7, 6, 6) + 12

  # Checking in detail if Cell values did wrap correctly
  result <- toString(matrix_form(tt_for_wrap[10, 1, keep_footers = TRUE], TRUE),
    widths = c(10, 8),
    col_gap = 2,
    hsep = "-"
  )
  splitted_res <- strsplit(result, "\n")[[1]]

  # First column (rownames) has widths 10 and there is colgap 2
  expect_identical(.count_chr_from_str(splitted_res[1], " "), 10L + 2L)

  # First column label is 8 char
  expect_identical(.count_chr_from_str(splitted_res[1], " ", TRUE), 8L)

  # Separator is at the right place and colnames are wrapped
  expect_identical(splitted_res[7], "--------------------")
  expected <- c(
    "            Incredib",
    "            ly long ",
    "             column ",
    "              name  ",
    "             to be  ",
    "            wrapped "
  )
  expect_identical(splitted_res[1:6], expected)

  # String replacement of NAs wider than expected works with cell wrapping
  expected <- c(
    "Mean         A very ",
    "              long  ",
    "            content ",
    "            to_be_wr",
    "            apped_an",
    "            d_splitt",
    "               ed   "
  )
  expect_identical(splitted_res[8:14], expected)

  # Testing if footers are not affected by this
  expect_identical(splitted_res[17], main_footer(tt_for_wrap))

  # Works for row names too
  result <- toString(matrix_form(tt_for_wrap[6, 1], TRUE), widths = c(10, 8), col_gap = 2)
  splitted_res2 <- strsplit(result, "\n")[[1]]
  expected <- c(
    "BLACK OR            ",
    "AFRICAN             ",
    "AMERICAN            "
  )
  expect_identical(splitted_res2[8:10], expected)

  # Test if it works with numeric values
  tt_simple <- basic_table() |>
    analyze("AGE", format = "xx.xxxx") |>
    build_table(ex_adsl)
  result <- toString(matrix_form(tt_simple, TRUE),
    widths = c(2, 3),
    col_gap = 1,
    hsep = "-"
  )
  sre3 <- strsplit(result, "\n")[[1]]
  expected <- c("   all", "   obs", "------", "Me 34.", "an 88 ")
  expect_identical(sre3, expected)

  # See if general table has the right amount of \n
  result <- toString(matrix_form(tt_for_wrap, TRUE), widths = clw)
  expect_identical(.count_chr_from_str(result, "\n"), 25L)
})


test_that("row label indentation is kept even if there are newline characters", {
  skip_if_not_installed("dplyr")
  require(dplyr, quietly = TRUE)

  ANL <- DM |>
    mutate(value = rnorm(n()), pctdiff = runif(n())) |>
    filter(ARM == "A: Drug X")
  ANL$ARM <- factor(ANL$ARM)

  ## toy example where we take the mean of the first variable and the
  ## count of >.5 for the second.
  colfuns <- list(
    function(x) in_rows(" " = mean(x), .formats = "xx.x"), # Empty labels are introduced
    function(x) in_rows("# x > 5" = sum(x > .5), .formats = "xx")
  )

  tbl_a <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_multivar(c("value", "pctdiff"), varlabels = c("abc", "def")) |>
    split_rows_by("RACE",
      split_label = "Ethnicity",
      split_fun = drop_split_levels,
      label_pos = "topleft"
    ) |>
    summarize_row_groups(indent_mod = 2) |>
    split_rows_by("SEX",
      split_label = "Sex", label_pos = "topleft",
      split_fun = drop_and_remove_levels(c("UNDIFFERENTIATED", "U"))
    ) |>
    analyze_colvars(afun = colfuns, indent_mod = 4) |>
    build_table(ANL)

  # Decorating
  table_inset(tbl_a) <- 2
  main_title(tbl_a) <- "Summary of \nTime and \nTreatment"
  subtitles(tbl_a) <- paste("Number: ", 1:3)
  main_footer(tbl_a) <- "NE: Not Estimable"

  # Matrix form and toString
  mf_a <- matrix_form(tbl_a, TRUE, FALSE)
  expect_error(
    res_a <- toString(mf_a, widths = c(15, 12, 12)),
    regexp = "Inserted width for row label column is not wide enough"
  )
  expect_silent(res_a <- toString(mf_a, widths = c(17, 12, 12)))
  # 2 is the indentation of summarize_row_groups
  # 1 is the standard indentation
  # 1 + 1 + 4 is the standard nesting indentation (twice) + 4 manual indentation (indentation_mod)
  man_ind <- c(2, 1, 1 + 1 + 4)
  expect_equal(mf_rinfo(mf_a)$indent[1:3], table_inset(tbl_a) + man_ind)
  res_a <- strsplit(res_a, "\n")[[1]]

  # Checking indentation size propagation
  ind_s1 <- 3
  ind_s2 <- 2
  mf3_v1 <- matrix_form(tbl_a, indent_rownames = TRUE, expand_newlines = FALSE, indent_size = ind_s1)
  mf3_v2 <- matrix_form(tbl_a, indent_rownames = TRUE, expand_newlines = FALSE, indent_size = ind_s2)
  which_to_rm <- which(names(mf3_v1) %in% c("strings", "formats", "indent_size", "col_widths"))
  expect_equal(mf3_v1[-which_to_rm], mf3_v2[-which_to_rm]) # These should be the only differences

  str_v1 <- strsplit(mf3_v1$strings[3, 1], "ASIAN")[[1]]
  str_v2 <- strsplit(mf3_v2$strings[3, 1], "ASIAN")[[1]]
  expect_equal(nchar(str_v1), (2 + 2) * ind_s1) # (inset + indent of summ group) * indent_size
  expect_equal(nchar(str_v2), (2 + 2) * ind_s2) # (inset + indent of summ group) * indent_size
  expect_equal(nchar(str_v1), nchar(str_v2) + 4) # This should be the diff in indentation

  # Number of characters (so indentation) are the same when indent_size is used in mf() or toString()
  ind_tbl_v1 <- strsplit(toString(mf3_v1), "\n")[[1]]
  ind_tbl_v2 <- strsplit(toString(tbl_a, indent_size = 3), "\n")[[1]]
  expect_equal(ind_tbl_v1, ind_tbl_v2)

  tbl_b <- basic_table() |>
    split_cols_by("ARM") |>
    split_cols_by_multivar(c("value", "pctdiff"), varlabels = c("abc", "de\nf")) |>
    split_rows_by("RACE",
      split_label = "Ethnicity",
      label_pos = "topleft"
    ) |>
    summarize_row_groups(indent_mod = 2) |>
    split_rows_by("SEX",
      split_label = "Sex", label_pos = "topleft",
      split_fun = drop_and_remove_levels(c("UNDIFFERENTIATED", "U"))
    ) |>
    analyze_colvars(afun = colfuns, indent_mod = 4) |>
    build_table(ANL)

  # Decorating
  table_inset(tbl_b) <- 2
  main_title(tbl_b) <- "Summary of \nTime and \nTreatment"
  subtitles(tbl_b) <- paste("Number: ", 1:3)
  main_footer(tbl_b) <- "NE: Not Estimable"

  # These errors happen but they should not -> to fix matrix_form (in the second case)
  mf_b <- matrix_form(tbl_b, indent_rownames = TRUE, expand_newlines = FALSE)
  expect_error(
    toString(mf_b, widths = c(17, 12, 12)),
    "Found newline characters"
  )
})

test_that("Support for newline characters in all the parts", {
  out <- strsplit(toString(tt_for_nl, hsep = "-"), "\\n")[[1]]
  mf <- matrix_form(tt_for_nl, TRUE)

  # topleft is correctly aligned
  expect_equal(
    mf$strings[seq(mf_nlheader(mf)), 1],
    unlist(strsplit(paste0(top_left(tt_for_nl), collapse = "\n"), "\n"))
  )

  expected <- c(
    "why not",
    "also here",
    "",
    "---------------------------------",
    "                                 ",
    "a                        ARM     ",
    "b                                ",
    "d                         A      ",
    "                             A wo",
    "                      TWO        ",
    "c                    words    rd ",
    "---------------------------------",
    "m                                ",
    "annaggia                         ",
    "sda                              ",
    "  F                              ",
    "    Mean             5.81    6.29",
    "  M                              ",
    "    Mean             6.15    5.21",
    "  U                              ",
    "  N                              ",
    "  D                              ",
    "   {1, 2}                        ",
    "    Mean              asd    asd ",
    "                      asd    asd ",
    "  UNDIFFERENTIATED               ",
    "    Mean              asd    asd ",
    "                      asd    asd ",
    "---------------------------------",
    "",
    "{1} - a fancy footnote",
    "crazy",
    "{2} - ahahha",
    "---------------------------------",
    "",
    "main_footer: This",
    "is",
    "a",
    "",
    "weird one",
    "",
    "prov_footer: This",
    "is",
    "a",
    "",
    "weird one"
  )
  expect_identical(out, expected)

  # Resolution of footers work with tf_wrap = TRUE
  out <- strsplit(toString(tt_for_nl, tf_wrap = TRUE, hsep = "-"), "\\n")[[1]]
  expect_identical(out, expected)

  # Export_as_txt too
  out <- strsplit(export_as_txt(tt_for_nl, file = NULL, hsep = "-"), "\\n")[[1]]
  expect_identical(out, expected)
})

test_that("Separators and wrapping work together with getter and setters", {
  ## formatters#221 (bug with wrapping) and #762 (analyze allows it)
  df <- data.frame(
    cat = c(
      "really long thing its so ", "long"
    ),
    value = c(6, 3, 10, 1)
  )
  fast_afun <- function(x) list("m" = rcell(mean(x), format = "xx."), "m/2" = max(x) / 2)

  lyt <- basic_table() |>
    split_rows_by("cat", section_div = "~")

  lyt1 <- lyt |>
    analyze("value", afun = fast_afun, section_div = " ")

  lyt2 <- lyt |>
    summarize_row_groups() |>
    analyze("value", afun = fast_afun, section_div = " ")

  tbl1 <- build_table(lyt1, df)
  tbl2 <- build_table(lyt2, df)
  mf1 <- matrix_form(tbl1)
  mf2 <- matrix_form(tbl2)
  expect_identical(mf1$row_info$trailing_sep, mf2$row_info$trailing_sep)
  expect_identical(mf1$row_info$trailing_sep, rep(c(NA, NA, "~"), 2))

  exp1 <- c(
    "            all obs",
    "———————————————————",
    "really             ",
    "long               ",
    "thing its          ",
    "so                 ",
    "  m            8   ",
    "  m/2          5   ",
    "~~~~~~~~~~~~~~~~~~~",
    "long               ",
    "  m            2   ",
    "  m/2         1.5  "
  )

  cw <- propose_column_widths(tbl1)
  cw[1] <- ceiling(cw[1] / 3)
  expect_identical(strsplit(toString(tbl1, widths = cw), "\n")[[1]], exp1)

  # setter and getter
  a_sec_div <- section_div(tbl1)
  a_sec_div[1] <- "a"
  section_div(tbl1) <- a_sec_div
  expect_identical(
    strsplit(toString(tbl1[seq_len(2), ]), "\\n")[[1]][4],
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  )
})

test_that("horizontal separator is propagated from table to print and export", {
  # GitHub error #778
  lyt <- basic_table() |>
    split_cols_by("Species") |>
    analyze("Sepal.Length", afun = function(x) {
      list(
        "mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
        "range" = diff(range(x))
      )
    })

  tbl <- build_table(lyt, iris, hsep = "~")
  tostring_tbl <- strsplit(toString(tbl), "\n")[[1]]
  export_txt_tbl <- strsplit(export_as_txt(tbl), "\n")[[1]]
  expect_identical(tostring_tbl, export_txt_tbl)
})

## higher-level showing ncols works:

test_that("showing higher-level ncols works", {
  skip_if_not_installed("tibble")
  require(tibble, quietly = TRUE)

  mydat <- subset(ex_adsl, SEX %in% c("M", "F"))
  mydat$SEX2 <- factor(
    ifelse(
      mydat$SEX == "M",
      "males",
      "super long sentence that involves females"
    )
  )

  lyt <- basic_table() |>
    split_cols_by("ARM", show_colcounts = TRUE) |>
    split_cols_by("SEX2", show_colcounts = TRUE) |>
    split_cols_by("STRATA1") |>
    analyze("AGE")

  tbl <- build_table(lyt, mydat)
  expect_equal(colcount_na_str(tbl), "")
  colcount_na_str(tbl) <- "wut"
  expect_equal(colcount_na_str(tbl), "wut")
  colcount_na_str(tbl) <- ""
  cwds <- rep(8, ncol(tbl) + 1)
  expect_equal(nlines(col_info(tbl), colwidths = cwds, fontspec = NULL), 7)
  mpf <- matrix_form(tbl, TRUE)
  ## this is to get around complaints about ::: in the precommit rules
  dcfnw <- get("do_cell_fnotes_wrap", asNamespace("formatters"))
  mpf <- dcfnw(mpf, cwds, NULL, FALSE, fontspec = NULL)
  strs <- mf_strings(mpf)
  ## wrapping some cells and not others still works
  expect_equal(strs[3:4, 2], c("", "males"))

  expect_equal(strs[2, 2], "(N=130)")
  ## N= cells all across rows 2 (for ARM) and 5 (for SEX2), except rowlabels
  expect_true(all(grepl("(N=", strs[c(2, 5), -1], fixed = TRUE)))
  ## No N= cells elsewhere
  expect_true(all(!grepl("(N=", strs[-c(2, 5), -1], fixed = TRUE)))

  broken_tbl <- tbl
  expect_true(colcount_visible(broken_tbl, c("ARM", "A: Drug X", "SEX2", "males")))
  colcount_visible(broken_tbl, c("ARM", "A: Drug X", "SEX2", "males")) <- FALSE
  expect_error(print(broken_tbl), "different colcount visibility among sibling facets")

  ## does the old accessor still work ok

  lyt2 <- basic_table() |>
    split_cols_by("ARM", show_colcounts = TRUE) |>
    split_cols_by("SEX2", show_colcounts = TRUE) |>
    split_cols_by("STRATA1", show_colcounts = TRUE) |>
    analyze("AGE")

  tbl2 <- build_table(lyt2, mydat)
  nc <- ncol(tbl2)
  new_ccs <- seq_len(nc)

  col_counts(tbl2) <- new_ccs

  mpf2 <- matrix_form(tbl2, TRUE)
  expect_equal(
    mf_strings(mpf2)[mf_nlheader(mpf2), -1, drop = TRUE],
    sprintf("(N=%d)", new_ccs)
  )
  ## NA counts (to display blank) work correctly for higher level facets

  tbl3 <- tbl
  facet_colcount(tbl3, c("ARM", "C: Combination")) <- NA_integer_
  mpf3 <- matrix_form(tbl3, TRUE)
  ## starting at "column" 2 because topleft/row labels
  expect_equal(
    mf_strings(mpf3)[2, 2:13],
    mf_strings(mpf)[2, 2:13]
  )
  expect_equal(
    mf_strings(mpf3)[2, 14:19],
    rep("", 6)
  )

  tbl4 <- tbl2
  col_counts(tbl4)[rep(c(FALSE, TRUE), times = c(14, 4))] <- NA_integer_

  adsl <- ex_adsl

  adsl$active_trt <- factor(ifelse(grepl("Placebo", adsl$ARM), " ", "Active Treatment Group"))
  adsl$rr_header <- "Risk Difference % CI"

  combodf <- tribble(
    ~valname, ~label, ~levelcombo, ~exargs,
    "A_C", "Arms A+C", c("A: Drug X", "C: Combination"), list()
  )

  lyt5 <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("active_trt", split_fun = trim_levels_in_group("ARM")) |>
    split_cols_by("ARM", split_fun = add_combo_levels(combodf)) |>
    split_cols_by("rr_header", nested = FALSE) |>
    split_cols_by("ARM", split_fun = keep_split_levels(c("A: Drug X", "C: Combination"))) |>
    analyze("AGE")

  tbl5 <- build_table(lyt5, adsl)
  expect_silent(toString(tbl5))
  col_counts(tbl5)[c(FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE)] <- NA_integer_
  mpf5 <- matrix_form(tbl5, TRUE)
  expect_equal(
    mf_strings(mpf5)[3, c(3, 7, 8)], # cols 2, 6 and 7, remember row labels!
    c("", "", "")
  )

  ## turning counts for a facet's children off is different than setting
  ## the visible counts to NA, note alignment here, no spaces under risk diff
  ## arms
  facet_colcounts_visible(tbl5, c("rr_header", "Risk Difference % CI", "ARM")) <- FALSE
  mpf5b <- matrix_form(tbl5, TRUE)
  expect_equal(
    mf_strings(mpf5b)[3, 7:8],
    c("A: Drug X", "C: Combination")
  )
  lyt6 <- basic_table(show_colcounts = TRUE, colcount_format = "N=xx") |>
    split_cols_by("active_trt", split_fun = trim_levels_in_group("ARM")) |>
    split_cols_by("ARM", split_fun = add_combo_levels(combodf), show_colcounts = TRUE, colcount_format = "(N=xx)") |>
    split_cols_by("rr_header", nested = FALSE) |>
    split_cols_by("ARM", split_fun = keep_split_levels(c("A: Drug X", "C: Combination"))) |>
    analyze("AGE")

  tbl6 <- build_table(lyt6, adsl)

  lyt7 <- basic_table(show_colcounts = TRUE, colcount_format = "N=xx") |>
    split_cols_by("active_trt", split_fun = trim_levels_in_group("ARM")) |>
    split_cols_by("ARM", split_fun = add_combo_levels(combodf), show_colcounts = TRUE, colcount_format = "(N=xx)") |>
    split_cols_by("STRATA1") |>
    split_cols_by("rr_header", nested = FALSE) |>
    split_cols_by("ARM", split_fun = keep_split_levels(c("A: Drug X", "C: Combination"))) |>
    analyze("AGE")

  tbl7 <- build_table(lyt7, adsl)
  expect_silent(toString(tbl7))

  mpf7 <- matrix_form(tbl7)
  strs7 <- mf_strings(mpf7)
  expect_equal(length(grep("^[(]N=", strs7)), 15) ## cause of spanning, 5 visible counts, each span 3
  expect_equal(length(grep("^N=", strs7)), ncol(tbl7))
})
