context("Analysis functions (afun)")

test_that(".spl_context contains information about the column split", {
  skip_if_not_installed("dplyr")
  require(dplyr, quietly = TRUE)

  ## Duplication hack -> This would need to use  split_cols_by_multivar(...)
  # Workaround for #690
  DM_tmp <- DM |>
    mutate(method = factor("Mean"))

  DM_tmp <- rbind(
    DM_tmp,
    DM_tmp |> mutate(method = factor("SD"))
  )

  analysis_fun_fin <- function(x, .spl_context, labelstr = "", ...) {
    # Very smart internal checks for name reconstruction from path
    stopifnot(length(.spl_context$cur_col_id[[1]]) == 1L)
    stopifnot(.spl_context$cur_col_id[[1]] %in% names(.spl_context))

    if (any(.spl_context$cur_col_split_val[[2]] == "SD")) {
      res <- list("SOMETHING" = sd(x))
    } else if (any(.spl_context$cur_col_split_val[[2]] == "Mean")) {
      res <- list("SOMETHING" = mean(x))
    }

    in_rows(.list = res)
  }

  lyt <- basic_table() |>
    split_rows_by("STRATA1") |>
    split_cols_by(var = "method") |>
    split_cols_by("SEX", split_fun = drop_split_levels) |>
    analyze(vars = "BMRKR1", afun = analysis_fun_fin, format = "xx.xxx")

  expect_silent(tbl <- lyt |> build_table(DM_tmp))

  DM_B_F <- DM |> filter(SEX == "F", STRATA1 == "B")
  expect_equal(tbl[4, 1, drop = TRUE], mean(DM_B_F$BMRKR1))
  expect_equal(tbl[4, 3, drop = TRUE], sd(DM_B_F$BMRKR1))
})

test_that(".spl_context and afun extra parameters contain information about combo counts", {
  skip_if_not_installed("tibble")
  require(tibble, quietly = TRUE)

  skip_if_not_installed("dplyr")
  require(dplyr, quietly = TRUE)

  ## Fix for https://github.com/insightsengineering/rtables/issues/517
  combodf <- tribble(
    ~valname, ~label, ~levelcombo, ~exargs,
    "all_X", "All Drug X", c("A: Drug X", "C: Combination"), list(),
    "all_pt", "All Patients", c("A: Drug X", "B: Placebo", "C: Combination"), list()
  )

  n_wrapper_alt_df <- function(alt_counts_df) {
    function(x,
             .spl_context,
             .N_col,
             .alt_df_row,
             .alt_df,
             .all_col_exprs,
             .all_col_counts,
             ...) {
      cur_col <- paste0(.spl_context$cur_col_split_val[[1]], collapse = ".")

      # Checks on new .spl_context content
      expect_equal(.spl_context$cur_col_id[[1]], cur_col)
      stopifnot(cur_col %in% names(.spl_context))
      if (.spl_context$cur_col_split[[1]][1] != "All Patients 2") {
        stopifnot(all(.spl_context$cur_col_split[[1]] == c("ARM", "COUNTRY")))
      }

      if (grepl("all_X", .spl_context$cur_col_id[[1]]) || .spl_context$cur_col_id[[1]] == "All Patients 2") {
        in_rows("n" = .N_col, .formats = "xx")
      } else {
        # Needed to find the names of columns we need that are not the current one
        AC_colname <- vapply(c("A: Drug X", "C: Combination"),
          function(nmi) {
            paste0(
              c(
                nmi,
                .spl_context$cur_col_split_val[[1]][2]
              ),
              collapse = "."
            )
          },
          FUN.VALUE = character(1)
        )
        # Use of cexpr
        alt_df1c <- .alt_df_row |>
          filter(eval(.all_col_exprs[[AC_colname[1]]]))
        alt_df2c <- .alt_df_row |>
          filter(eval(.all_col_exprs[[AC_colname[2]]]))

        # Normal execution - no use of cexpr
        alt_df1 <- .alt_df_row |>
          filter(
            ARM == "A: Drug X",
            COUNTRY == .spl_context$cur_col_split_val[[1]][2]
          )
        alt_df2 <- .alt_df_row |>
          filter(
            ARM == "C: Combination",
            COUNTRY == .spl_context$cur_col_split_val[[1]][2]
          )

        # Super manual extraction
        alt_df1b <- alt_counts_df |>
          filter(
            ARM == "A: Drug X",
            COUNTRY == .spl_context$cur_col_split_val[[1]][2],
            SEX == .spl_context$value[3]
          )
        alt_df2b <- alt_counts_df |>
          filter(
            ARM == "C: Combination",
            COUNTRY == .spl_context$cur_col_split_val[[1]][2],
            SEX == .spl_context$value[3]
          )

        # All strata is add_overall_level -> filter not needed
        if (.spl_context$value[[2]] != "All Strata") {
          alt_df1b <- alt_df1b |>
            filter(STRATA1 == .spl_context$value[[2]])
          alt_df2b <- alt_df2b |>
            filter(STRATA1 == .spl_context$value[[2]])
        }

        # This would break the tests if no match
        expect_equal(nrow(alt_df1), nrow(alt_df1b))
        expect_equal(nrow(alt_df1), nrow(alt_df1c))
        expect_equal(nrow(alt_df2), nrow(alt_df2b))
        expect_equal(nrow(alt_df2), nrow(alt_df2c))

        # General info
        expect_equal(.all_col_counts[[.spl_context$cur_col_id[[1]]]], .N_col)
        expect_equal(
          .all_col_exprs[[.spl_context$cur_col_id[[1]]]],
          .spl_context$cur_col_expr[[3]]
        )
        expect_silent(filtering <- eval(.spl_context$cur_col_expr[[1]], .alt_df_row))
        expect_equal(.alt_df_row[filtering, ], .alt_df) # Main check for col-filter

        # Fin needed output
        in_rows(
          "n" = c(
            nrow(alt_df1c),
            nrow(alt_df2c)
          ),
          .formats = "xx - xx"
        )
      }
    }
  }

  lyt <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("ARM", split_fun = add_combo_levels(combodf, first = TRUE)) |>
    split_cols_by("COUNTRY", split_fun = keep_split_levels(c("CHN", "USA"))) |>
    split_rows_by("STRATA1", split_fun = add_overall_level("All Strata")) |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    add_overall_col("All Patients 2") |>
    analyze(vars = "BMRKR1", afun = n_wrapper_alt_df(ex_adsl))

  # NB: If you add keep_levels = c("all_X") to add_combo_levels the other
  #     column expressions are missing -> Expected!

  tbl <- lyt |> build_table(DM, alt_counts_df = ex_adsl)

  expect_silent(cbind_rtables(tbl, tbl))
  expect_message(rbind(tbl, tbl)) # uniqify message

  spl_ctx_cnt <- lapply(seq(8, nrow(tbl), 5), function(x) tbl[x, 2, drop = TRUE])

  nrow_manual <- lapply(sort(unique(ex_adsl$STRATA1)), function(x) {
    tmp_strata <- ex_adsl |> filter(STRATA1 == x, SEX == "F", COUNTRY == "USA")
    sapply(list(
      tmp_strata |> filter(ARM == "A: Drug X"),
      tmp_strata |> filter(ARM == "C: Combination")
    ), nrow)
  })

  expect_identical(nrow_manual, spl_ctx_cnt)
})

test_that("Error localization for missing split variable when done in alt_count_df", {
  # Error we want to happen
  afun_tmp <- function(x, .alt_df_row, ...) mean(x)
  lyt_col <- basic_table() |>
    split_cols_by("ARMCD") |>
    analyze("BMRKR1", afun = afun_tmp)
  lyt_row <- basic_table() |>
    split_rows_by("ARMCD") |>
    analyze("BMRKR1", afun = afun_tmp)
  expect_error(lyt_col |> build_table(ex_adsl, alt_counts_df = DM))
  expect_error(lyt_row |> build_table(ex_adsl, alt_counts_df = DM),
    regexp = paste0(
      "Following error encountered in splitting ",
      "alt_counts_df:  variable\\(s\\) \\[ARMCD\\] ",
      "not present in data. \\(VarLevelSplit\\)"
    )
  )

  # What if it is not asked by the function?
  afun_tmp <- function(x, ...) mean(x)
  lyt_col <- basic_table() |>
    split_cols_by("ARMCD") |>
    analyze("BMRKR1", afun = afun_tmp)
  lyt_row <- basic_table() |>
    split_rows_by("STRATA1", split_fun = keep_split_levels("A")) |>
    split_rows_by("ARMCD") |>
    analyze("BMRKR1", afun = afun_tmp)

  # Error on the columns should happen because it is used for counts on column space
  expect_error(
    lyt_col |> build_table(ex_adsl, alt_counts_df = DM),
    "alt_counts_df appears incompatible with column-split structure*"
  )
  expect_silent(lyt_col |> build_table(ex_adsl)) # it is specific of alt_counts_df
  expect_silent(lyt_row |> build_table(ex_adsl, alt_counts_df = DM))
})

test_that("Error localization for missmatch split variable when done in alt_count_df", {
  skip_if_not_installed("dplyr")
  require(dplyr, quietly = TRUE)

  afun_tmp <- function(x, .alt_df_row, .spl_context, ...) {
    # Important check that order is aligned even if source levels are not
    check_val <- unique(.alt_df_row$ARMCD)
    # This is something mysterious happening in splits for which if the values are all
    # NAs in the split column, the dataspl has the nrow of the data in NA rows. xxx ToFix
    check_val <- check_val[!is.na(check_val)]
    stopifnot(as.character(check_val) == .spl_context$value[2])
    mean(x)
  }
  lyt_row <- basic_table() |>
    split_rows_by("ARMCD") |>
    analyze("BMRKR1", afun = afun_tmp)

  # Mismatch in the number of splits (NA is 0)
  DM_tmp <- DM |> mutate("ARMCD" = NA_character_)
  expect_error(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp),
    regexp = paste0("alt_counts_df split variable\\(s\\) \\[ARMCD\\] *")
  )

  # Mismatch of levels
  armcd_col <- factor(sample(c("arm A", "arm B", "arm C"), nrow(DM), replace = TRUE))
  DM_tmp <- DM |> mutate("ARMCD" = armcd_col)
  expect_error(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp),
    regexp = paste0("alt_counts_df split variable\\(s\\) \\[ARMCD\\] *")
  )

  # Mix mismatch of levels
  armcd_col <- factor(sample(c("arm A", "ARM B", "ARM C"), nrow(DM), replace = TRUE))
  DM_tmp <- DM |> mutate("ARMCD" = armcd_col)
  expect_error(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp),
    regexp = paste0("alt_counts_df split variable\\(s\\) \\[ARMCD\\] *")
  )

  # Mismatch in the number of levels
  armcd_col2 <- factor(sample(levels(ex_adsl$ARMCD)[c(1, 2)], nrow(DM), replace = TRUE))
  DM_tmp <- DM |> mutate("ARMCD" = armcd_col2)
  expect_error(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp),
    regexp = paste0("alt_counts_df split variable\\(s\\) \\[ARMCD\\] *")
  )

  # Another order -> should work? yes, split is valid
  levels(armcd_col) <- levels(ex_adsl$ARMCD)[c(1, 3, 2)]
  DM_tmp <- DM |> mutate("ARMCD" = armcd_col)
  expect_silent(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp))

  # Mix mismatch of levels but covering them all -> valid split
  armcd_col <- factor(sample(c("arm A", levels(ex_adsl$ARMCD)), nrow(DM), replace = TRUE))
  DM_tmp <- DM |> mutate("ARMCD" = armcd_col)
  expect_silent(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp))

  # Values are all NA, but the levels are correct
  DM_tmp$ARMCD <- factor(NA, levels = levels(ex_adsl$ARMCD))
  expect_error(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp),
    regexp = paste0("alt_counts_df split variable\\(s\\) \\[ARMCD\\] *")
  )

  DM_tmp$ARMCD <- factor(NA, levels = levels(ex_adsl$ARMCD))
  DM_tmp$ARMCD[seq_along(levels(ex_adsl$ARMCD))] <- levels(ex_adsl$ARMCD)
  expect_silent(lyt_row |> build_table(ex_adsl, alt_counts_df = DM_tmp))
})

context("Content functions (cfun)")

test_that(".alt_df_row appears in cfun but not in afun.", {
  skip_if_not_installed("dplyr")
  require(dplyr, quietly = TRUE)

  # Adding STRATA2 col to DM for alt_counts_df col split
  alt_tmp <- DM |> left_join(
    ex_adsl |>
      mutate(ID = paste0("S", seq_len(nrow(ex_adsl)))) |>
      select(ID, STRATA2)
  )

  afun_tmp <- function(x, ...) rcell(mean(x), label = "MeAn", format = "xx.x")
  cfun_tmp <- function(x, labelstr,
                       .alt_df_row,
                       .alt_df,
                       .N_col,
                       .spl_context,
                       .all_col_exprs,
                       .all_col_counts,
                       ...) {
    if (!missing(.alt_df_row)) {
      # .alt_df_row is only row-splitted matter
      stopifnot(nrow(alt_tmp |> filter(STRATA1 == "A")) == nrow(.alt_df_row))

      # Filtered column number of elements correspond to .N_col
      stopifnot(nrow(
        alt_tmp |>
          filter(eval(.spl_context$cur_col_expr[[1]]))
      ) == .N_col)
    } else {
      # Checking cur_col_n is the same as .N_col for root and length(x) for split
      stopifnot(identical(.spl_context$cur_col_n, c(.N_col, length(x))))
    }

    # Checking internal names for all column counts correspond to .spl_context
    stopifnot(all(names(.all_col_counts) %in% colnames(.spl_context)))

    # Checking that current col id and col counts agree with .N_col
    stopifnot(.all_col_counts[.spl_context$cur_col_id[1]] == .N_col)

    # Checking col expression
    stopifnot(identical(
      .all_col_exprs[.spl_context$cur_col_id[1]][[1]],
      .spl_context$cur_col_expr[[1]]
    )) # Uses the root one

    in_rows(c(length(x), length(x) / .N_col),
      .names = labelstr,
      .formats = c("xx (xx.xx)")
    )
  }

  lyt <- basic_table(show_colcounts = TRUE) |>
    split_cols_by("SEX", split_fun = keep_split_levels(c("F", "U"))) |>
    split_cols_by("STRATA2", split_fun = keep_split_levels("S1")) |>
    split_rows_by("STRATA1", split_fun = keep_split_levels("A")) |>
    summarize_row_groups(var = "BMRKR1", cfun = cfun_tmp) |>
    split_rows_by("ARMCD") |>
    analyze("BMRKR1", afun = afun_tmp)

  expect_error(
    lyt |> build_table(ex_adsl, alt_counts_df = DM),
    "alt_counts_df appears incompatible with column-split*"
  )
  expect_silent(lyt |> build_table(ex_adsl, alt_counts_df = alt_tmp))
})


test_that("full alt_counts_df is accessible from afun/cfun via .alt_df_full", {
  fun <- function(x, labelstr, .alt_df_full) {
    if (identical(.alt_df_full, ex_adsl)) {
      "ok"
    } else {
      "fail"
    }
  }
  ## row labels will be nonsense but we don't care about that for this check
  lyt <- basic_table() |>
    split_cols_by("SEX") |>
    split_cols_by("STRATA1") |>
    split_rows_by("AEBODSYS", split_fun = trim_levels_in_group("AEDECOD")) |>
    summarize_row_groups("AEBODSYS", cfun = fun, format = "xx") |>
    analyze("AEDECOD", afun = fun)

  tbl <- build_table(lyt, ex_adae[1:3, ], alt_counts_df = ex_adsl)
  cvals <- unlist(cell_values(tbl))
  expect_true(all(cvals == "ok"))
})

test_that(".alt_df* argument behavior is correct when alt_counts_df is not set", {

  check_alt_dfs <- function(df, .df_row, .alt_df_row, .alt_df, .alt_df_full) {
    expect_identical(df, .alt_df)
    expect_identical(.df_row, .alt_df_row)
    expect_false(is.null(.alt_df_full))
    TRUE
  }

  afun <- function(df, .df_row, .alt_df_row, .alt_df, .alt_df_full) {
    res <- check_alt_dfs(df, .df_row, .alt_df_row, .alt_df, .alt_df_full)
    in_rows("afun result" = "OK")
  }
  cfun <- function(df, labelstr, .df_row, .alt_df_row, .alt_df, .alt_df_full) {
    res <- check_alt_dfs(df, .df_row, .alt_df_row, .alt_df, .alt_df_full)
    in_rows("cfun result" = "OK", .formats = list("cfun result" = "xx"))
  }

  first_2_levs <- function(vec) levels(vec)[1:2]

  lyt <- basic_table() |>
    split_cols_by("ARM", split_fun = keep_split_levels(first_2_levs(ex_adsl$ARM))) |>
    split_rows_by("STRATA1", split_fun = keep_split_levels(first_2_levs(ex_adsl$STRATA1))) |>
    summarize_row_groups("STRATA1", cfun = cfun) |>
    analyze("AGE", afun = afun)

  expect_no_error(build_table(lyt, ex_adsl))
})
