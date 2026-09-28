path_count <- function(tt, pth) length(tt_normalize_row_path(tt, pth))
keep_2_levels <- function(varnm, dat = ex_adsl) keep_split_levels(levels(dat[[varnm]])[1:2])


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


test_that("at_sibling creates intermediate row nesting", {
  path_count <- function(tt, pth) length(tt_normalize_row_path(tt, pth))

  lyt <- basic_table() |>
    split_rows_by("RACE") |>
    split_rows_by("FACTOR2") |>
    analyze("AGE") |>
    split_rows_by("SEX", at_sibling = "FACTOR2") |>
    analyze("AGE")
  tbl <- build_table(lyt, rawdat)

  expect_gt(path_count(tbl, c("RACE", "WHITE", "FACTOR2", "A", "AGE", "Mean")), 0L)
  expect_gt(path_count(tbl, c("RACE", "WHITE", "SEX", "M", "AGE", "Mean")), 0L)
  expect_equal(path_count(tbl, c("RACE", "WHITE", "FACTOR2", "A", "SEX", "M", "AGE", "Mean")), 0L)
  expect_true(all(c("FACTOR2", "SEX") %in% row.names(tbl)))

  sibling_analysis <- basic_table() |>
    split_rows_by("RACE") |>
    split_rows_by("FACTOR2") |>
    analyze("AGE") |>
    analyze("AGE", at_sibling = "FACTOR2") |>
    build_table(rawdat)
  expect_gt(path_count(sibling_analysis, c("RACE", "WHITE", "AGE", "Mean")), 0L)
})

test_that("at_sibling row split works with row summaries", {
  path_count <- function(tt, pth) length(tt_normalize_row_path(tt, pth))

  lyt <- basic_table() |>
    split_rows_by("RACE") |>
    summarize_row_groups() |>
    analyze("AGE") |>
    split_rows_by("SEX", at_sibling = "AGE") |>
    summarize_row_groups() |>
    analyze("AGE")

  tbl <- build_table(lyt, rawdat)

  expect_gt(path_count(tbl, c("RACE", "*", "@content")), 0L)
  expect_gt(path_count(tbl, c("RACE", "*", "SEX", "*", "@content")), 0L)
})

test_that("at_sibling rejects page_by splits", {
  expect_error(
    basic_table() |>
      split_rows_by("STRATA1", page_by = TRUE) |>
      split_rows_by("RACE", at_sibling = "STRATA1"),
    "at_sibling pointed to an element with forced pagination"
  )
})

test_that("at_sibling shows dynamic cut split labels", {
  path_count <- function(tt, pth) length(tt_normalize_row_path(tt, pth))

  lyt <- basic_table() |>
    split_rows_by("RACE") |>
    split_rows_by("FACTOR2") |>
    analyze("AGE") |>
    split_rows_by_cutfun("AGE", at_sibling = "FACTOR2") |>
    analyze("AGE")
  tbl <- build_table(lyt, rawdat)

  expect_gt(path_count(tbl, c("RACE", "WHITE", "AGE", "1st qrtile", "AGE", "Mean")), 0L)
  expect_true("AGE" %in% row.names(tbl))
})


test_that("basic usage of intermediate nesting works correctly", {
  ## analyze nested at "proper" (non top level) split
  lyt <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
    analyze("AGE") |>
    analyze("BMRKR2", at_sibling = "SEX")

  tbl <- build_table(lyt, ex_adsl)

  bmrkr_rpaths <- tt_normalize_row_path(tbl, c("STRATA1", "*", "BMRKR2"))

  expect_identical(
    bmrkr_rpaths,
    list(
      A = c("STRATA1", "A", "BMRKR2"),
      B = c("STRATA1", "B", "BMRKR2"),
      C = c("STRATA1", "C", "BMRKR2")
    )
  )

  expect_equal(
    length(bmrkr_rpaths),
    length(tt_normalize_row_path(tbl, c("STRATA1", "*", "SEX")))
  )

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
  expect_equal(
    length(tt_normalize_row_path(tbl2, c("STRATA1", "*", "BMRKR2", "*", "@content"))),
    9L
  )

  ## SEX didn't have a summarize row groups instruction
  ## tt_normalize_row_path says c(...,  "@content") path doesn't exist
  ## if content table is empty (no rows) or NULL
  expect_equal(
    length(tt_normalize_row_path(tbl2, c("STRATA1", "*", "SEX", "*", "@content"))),
    0L
  )


  tmpdat <- subset(ex_adsl, STRATA1 == "A" & BMRKR2 == "LOW")
  expect_identical(
    cell_values(tbl2, c("STRATA1", "A", "BMRKR2", "LOW", "AGE")),
    ## tapply insists on making an array which trips up waldo/testthat
    lapply(split(tmpdat$AGE, tmpdat$ARM), mean)
  )
})

test_that("anchoring to top-level element gives exact nested = FALSE behavior", {
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
})

test_that("bad at_sibling values give informative errors", {
  ## Useful errors for bad at_sibling
  expect_error(
    {
      basic_table() |>
        split_cols_by("ARM") |>
        split_rows_by("STRATA1") |>
        split_rows_by("SEX", split_fun = keep_split_levels(c("F", "M"))) |>
        analyze("AGE") |>
        analyze("BMRKR2", at_sibling = "whaaaaat?")
    },
    "Unable to find structural element"
  )

  expect_error(
    {
      basic_table() |>
        split_rows_by("ARM", page_by = TRUE) |>
        split_rows_by("STRATA1", page_by = TRUE) |>
        split_rows_by("SEX") |>
        analyze("AGE") |>
        split_rows_by("RACE", at_sibling = "STRATA1")
    },
    "at_sibling pointed to an element with forced pagination"
  )
  base <- basic_table() |>
    split_rows_by("SEX") |>
    split_rows_by("RACE") |>
    analyze("AGE")
  expect_error(split_rows_by(base, "STRATA1", at_sibling = 1))
  expect_error(analyze(base, "STRATA1", at_sibling = 1))
  expect_error(analyze(base, "STRATA1", at_sibling = character()))
  expect_error(split_rows_by_quartiles(base, "AGE", at_sibling = NA_character_))
})

test_that("previously placed siblings can be targeted by at_sibling", {
  ## even though this doesn't make a ton of sense, as the correct thing is for
  ## BMRKR2's at_sibling to also be "SEX", as that is the anchor point for the
  ## tree it (and RACE) is appended to,
  ## it was easier to support it than to construct a fully useful error message :-/.
  lyt_silly <- basic_table() |>
    split_rows_by("STRATA1", split_fun = keep_2_levels("STRATA1")) |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE") |>
    split_rows_by("RACE", split_fun = keep_2_levels("RACE"), at_sibling = "SEX") |>
    analyze("AGE") |>
    split_rows_by("BMRKR2", split_fun = keep_2_levels("BMRKR2"), at_sibling = "RACE") |>
    analyze("AGE")

  tbl <- build_table(lyt_silly, ex_adsl)

  ## these are fast enough that we can be a bit repetetive/redundant
  ## they're the same cause it's powers of 2 due to keep_2_levels splitfun
  expect_equal(
    path_count(tbl, c("STRATA1", "*", "SEX", "*", "AGE")),
    path_count(tbl, c("STRATA1", "*", "RACE", "*", "AGE"))
  )

  ## RACE and BMRKR2 are siblings to eachother (anchored on SEX)
  expect_equal(
    path_count(tbl, c("STRATA1", "*", "RACE", "*", "AGE")),
    path_count(tbl, c("STRATA1", "*", "BMRKR2", "*", "AGE"))
  )

  ## should not exist
  expect_equal(
    path_count(tbl, c("STRATA1", "*", "RACE", "*", "BMRKR2")),
    0L
  )
})

test_that("at_sibling finds and respects overridden table names", {
  ## at_sibling finds overridden table names

  lyt_ovrd <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("RACE", split_fun = keep_2_levels("RACE")) |>
    split_rows_by("BMRKR2",
      split_fun = keep_2_levels("BMRKR2"),
      parent_name = "funkytown"
    ) |>
    analyze("AGE") |>
    split_rows_by("STRATA1",
      split_fun = keep_2_levels("STRATA1"),
      at_sibling = "funkytown"
    ) |>
    analyze("BMRKR1")
  tbl_ovrd <- build_table(lyt_ovrd, ex_adsl)

  expect_equal(
    path_count(tbl_ovrd, c("RACE", "*", "funkytown", "*", "AGE")),
    path_count(tbl_ovrd, c("RACE", "*", "STRATA1", "*", "BMRKR1"))
  )

  expect_equal(
    path_count(tbl_ovrd, c("STRATA1", "*", "BMRKR1")),
    0L
  )
})

test_that("extreme/repeated usage of intermediate nesting works correctly", {
  lyt_other <- basic_table() |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX") |>
    analyze("AGE") |>
    split_rows_by("RACE", at_sibling = "SEX") |>
    split_rows_by("BMRKR2") |>
    analyze("AGE") |>
    analyze("BMRKR1", at_sibling = "BMRKR2")

  expect_identical(
    get_row_anchor_list(lyt_other),
    list(
      "STRATA1",
      c("SEX", "RACE"),
      c("BMRKR2", "BMRKR1")
    )
  )

  ## these layouts are completely ridiculous but they exercise the index resolution in
  ## anchor lookup
  ##
  ## gotta catch them all

  clowndat <- subset(ex_adsl, RACE %in% levels(RACE)[1:2])
  clowndat$RACE <- factor(clowndat$RACE)

  clown_base <- basic_table() |>
    analyze("RACE") |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    split_rows_by("RACE") |>
    split_rows_by("STRATA1", split_fun = keep_2_levels("STRATA1")) |>
    analyze("RACE") |>
    split_rows_by("BMRKR2", split_fun = keep_2_levels("BMRKR2"), at_sibling = "RACE[3]") |>
    analyze("AGE")

  expect_identical(
    get_row_anchor_list(clown_base),
    list(
      "RACE",
      "SEX",
      "RACE",
      "STRATA1",
      c(
        "RACE",
        "BMRKR2"
      ),
      "AGE"
    )
  )


  ## RACE
  ## SEX -> | RACE (2) -> STRATA1 -> | RACE (3)
  ##        |------------------------| BMRKR2 -> AGE
  ##        | COUNTRY -> BMRKR1

  clown_shoes <- clown_base |>
    split_rows_by("COUNTRY",
      split_fun = keep_2_levels("COUNTRY"),
      at_sibling = "RACE[2]"
    ) |>
    analyze("BMRKR1")

  tbl_clown <- build_table(clown_shoes, clowndat)
  expect_equal(
    path_count(tbl_clown, c("RACE", "*")),
    2L
  )
  expect_equal(
    path_count(tbl_clown, c("SEX", "*", "RACE", "*", "STRATA1", "*", "RACE", "*")),
    16L
  )

  expect_equal(
    path_count(tbl_clown, c("SEX", "*", "RACE", "*", "STRATA1", "*", "BMRKR2", "*")),
    16L
  )

  expect_equal(
    path_count(tbl_clown, c("SEX", "*", "COUNTRY", "*")),
    4L
  )

  expect_equal(
    path_count(tbl_clown, c("COUNTRY", "*")),
    0L
  )

  ## RACE
  ## SEX -> | RACE (2)-> STRATA1 -> | RACE (3)
  ##                                | BMRKR2 -> AGE
  ##                                | COUNTRY -> BMRKR1
  ##

  clown_shoes2 <- clown_base |>
    split_rows_by("COUNTRY",
      split_fun = keep_2_levels("COUNTRY"),
      at_sibling = "RACE[3]"
    ) |>
    analyze("BMRKR1")

  tbl_clown2 <- build_table(clown_shoes2, clowndat)

  expect_equal(
    path_count(tbl_clown2, c("SEX", "*", "COUNTRY", "*")),
    0L
  )

  expect_equal(
    path_count(tbl_clown2, c("SEX", "*", "RACE", "*", "STRATA1", "*", "COUNTRY", "*")),
    16L
  )

  ##
  expect_error(
    clown_base |>
      split_rows_by("COUNTRY", at_sibling = "RACE[4]"),
    regexp = "Found only 3 eligible elements named 'RACE', but at_sibling was 'RACE\\[4\\]'"
  )

  clown_nose <- basic_table() |>
    split_rows_by("STRATA1", split_fun = keep_2_levels("STRATA1")) |>
    split_rows_by("STRATA2", split_fun = keep_2_levels("STRATA2")) |>
    analyze("ARM") |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    split_rows_by("RACE") |>
    split_rows_by("STRATA1", split_fun = keep_2_levels("STRATA1")) |>
    analyze("BMRKR1") |>
    split_rows_by("BMRKR2", split_fun = keep_2_levels("BMRKR2"), at_sibling = "RACE") |>
    split_rows_by("COUNTRY", split_fun = keep_2_levels("COUNTRY")) |>
    analyze("AGE") |>
    split_rows_by("SITEID", split_fun = drop_split_levels, at_sibling = "RACE") |>
    split_rows_by("BEP01FL") |>
    analyze("AGE")

  ## this ensures STRATA2 is masked, ie only the base split of previous
  ## top-level structures are available
  expect_identical(
    get_row_anchor_list(clown_nose),
    list(
      "STRATA1",
      "SEX",
      c("RACE", "BMRKR2", "SITEID"),
      "BEP01FL",
      "AGE"
    )
  )

  expect_identical(
    vars_in_layout(clown_nose),
    c(
      "STRATA1",
      "STRATA2",
      "ARM",
      "SEX",
      "RACE",
      "BMRKR1",
      "BMRKR2",
      "COUNTRY",
      "AGE",
      "SITEID",
      "BEP01FL"
    )
  )

  ## "Full On" INSANEO STYLE
  ##  STRATA1 -> SEX -> | AGE
  ##                    | DCSREAS -> COUNTRY ->  AGE
  ##                    | Race -> | COUNTRY -> BMRKR1
  ##                              | BMRKR2 -> AGE

  lyt7 <- basic_table() |>
    split_cols_by("ARM") |>
    split_rows_by("STRATA1") |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE") |>
    split_rows_by("DCSREAS", split_fun = keep_2_levels("DCSREAS"), nested = TRUE, at_sibling = "AGE") |>
    split_rows_by("COUNTRY", split_fun = keep_2_levels("COUNTRY")) |> ## its a trap!
    analyze("AGE") |> ## its a trap redux
    ## tricky fish AGE == AGE[[1]]
    split_rows_by("RACE", split_fun = keep_2_levels("RACE"), nested = TRUE, at_sibling = "AGE") |>
    split_rows_by("COUNTRY", split_fun = keep_2_levels("COUNTRY"), nested = TRUE) |>
    analyze("BMRKR1") |>
    ## did we get the right one?
    split_rows_by("BMRKR2", split_fun = keep_2_levels("BMRKR2"), nested = TRUE, at_sibling = "COUNTRY") |>
    analyze("AGE")

  tbl_is <- build_table(lyt7, ex_adsl)

  ## should exist
  expect_equal(
    path_count(tbl_is, c("STRATA1", "*", "SEX", "*", "AGE")),
    6L
  )
  expect_equal(
    path_count(tbl_is, c("STRATA1", "*", "SEX", "*", "RACE", "*", "COUNTRY", "*", "BMRKR1")),
    24L
  ) # 3 strata 2 sex 2 race 2 country
  expect_equal(
    path_count(tbl_is, c("STRATA1", "*", "SEX", "*", "RACE", "*", "BMRKR2", "*", "AGE")),
    24L
  )

  ## should not exist
  expect_equal(
    path_count(tbl_is, c("STRATA1", "*", "SEX", "*", "RACE", "*", "AGE")),
    0L
  )

  ## trap 1: does BMRKR2 go to the right COUNTRY
  expect_equal(
    path_count(tbl_is, c("STRATA1", "*", "SEX", "*", "DCSREAS", "*", "BMRKR2")),
    0L
  )

  ## trap 2: does RACE go to the right AGE
  expect_equal(
    path_count(tbl_is, c("STRATA1", "*", "SEX", "*", "DCSREAS", "*", "COUNTRY", "*", "RACE")),
    0L
  )

  ## "Full On" INSANEO STYLE v2
  ##  STRATA1 -> SEX -> | AGE
  ##                    | DCSREAS -> COUNTRY ->  | AGE
  ##                    | ---------------------- | Race -> BMRKR2 -> BMRKR1
  ##                    | BMRKR2 -> AGE

  lyt7b <- basic_table() |>
    split_rows_by("STRATA1", split_fun = keep_2_levels("STRATA1")) |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE") |>
    split_rows_by("DCSREAS", split_fun = keep_2_levels("DCSREAS"), nested = TRUE, at_sibling = "AGE") |>
    split_rows_by("COUNTRY", split_fun = keep_2_levels("COUNTRY")) |> ## its a trap!
    analyze("AGE") |> ## its a trap redux
    ## tricky fish AGE == AGE[1]
    split_rows_by("RACE", split_fun = keep_2_levels("RACE"), nested = TRUE, at_sibling = "AGE[2]") |>
    split_rows_by("BMRKR2", split_fun = keep_2_levels("BMRKR2"), nested = TRUE) |>
    analyze("BMRKR1") |>
    ## did we get the right one?
    split_rows_by("BMRKR2", split_fun = keep_2_levels("BMRKR2"), nested = TRUE, at_sibling = "AGE") |>
    analyze("AGE")

  tbl_is2 <- build_table(lyt7b, ex_adsl)

  expect_equal(
    path_count(
      tbl_is2,
      c("STRATA1", "*", "SEX", "*", "DCSREAS", "*", "COUNTRY", "*", "AGE")
    ),
    16L
  )
  expect_equal(
    path_count(
      tbl_is2,
      c("STRATA1", "*", "SEX", "*", "DCSREAS", "*", "COUNTRY", "*", "RACE", "*", "BMRKR2", "*", "BMRKR1")
    ),
    64L
  )
  expect_equal(
    path_count(
      tbl_is2,
      c("STRATA1", "*", "SEX", "*", "BMRKR2", "*", "AGE")
    ),
    8L
  )
})

test_that("at_sibling doesn't mash 2 analyzes up all willy nilly", {
  ## also ensures the anchor lookup behavior is correct when anchor
  ## pt is a previous root split (which it wasn't when the test
  ## was written x.x)
  lyt <- basic_table() |>
    split_rows_by("RACE", split_fun = keep_2_levels("RACE")) |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE") |>
    analyze("BMRKR1", at_sibling = "RACE") |>
    analyze("AGE", at_sibling = "RACE")

  tbl <- build_table(lyt, ex_adsl)
  expect_equal(path_count(tbl, c("root", "BMRKR1")), 1L)
  expect_equal(path_count(tbl, c("root", "AGE")), 1L)
  expect_equal(path_count(tbl, c("RACE", "*", "SEX", "*", "AGE")), 4L)
  expect_equal(path_count(tbl, c("RACE", "*", "SEX", "*", "BMRKR1")), 0L)
  ## no surrounding multivar table
  expect_equal(path_count(tbl, c("ma_BMRKR1_AGE", "*")), 0L)


  ## old, ie non-at_sibling behavior remains unchanged
  ## TODO: deprecate this eventually now that we can have analyzes
  ## within row faceting (which we couldn't before, thus the creation
  ## of the ma_bla_bla_bla parent table.
  lyt2 <- basic_table() |>
    split_rows_by("RACE", split_fun = keep_2_levels("RACE")) |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE") |>
    analyze("BMRKR1", at_sibling = "SEX") |>
    analyze("AGE", at_sibling = "SEX")
  tbl2 <- build_table(lyt2, ex_adsl)
  ## no surrounding multivar table
  expect_equal(path_count(tbl2, c("RACE", "*", "ma_BMRKR1_AGE")), 0L)

  lytbad <- basic_table() |>
    split_rows_by("RACE", split_fun = keep_2_levels("RACE")) |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE") |>
    analyze("BMRKR1", nested = FALSE) |>
    analyze("AGE")
  tblbad <- build_table(lytbad, ex_adsl)
  ## no surrounding multivar table
  expect_equal(path_count(tblbad, c("ma_BMRKR1_AGE", "*")), 2L)
})

test_that("more than 2 analyzes get mashed together correctly", {
  lyt <- basic_table(show_colcounts = TRUE) |>
    ## Column faceting
    split_cols_by("ARM", ref_group = "A: Drug X") |>
    analyze("AGE") |>
    analyze("RACE") |>
    analyze("BMRKR1") |>
    analyze("BMRKR2")

  tbl <- build_table(lyt, ex_adsl)

  expect_equal(obj_name(tbl), "ma_AGE_RACE_BMRKR1_BMRKR2")
  expect_equal(path_count(tbl, c("ma_AGE_RACE_BMRKR1_BMRKR2", "*")), 4L)
})

test_that("random intermediate nesting stuff", {
  expect_error(
    {
      basic_table() |>
        split_rows_by("STRATA1", page_by = TRUE) |>
        analyze("AGE") |>
        split_rows_by("SEX", at_sibling = "STRATA1")
    },
    regexp = "at_sibling pointed to an element with forced pagination"
  )


  expect_no_error({
    basic_table() |>
      analyze("AGE") |>
      split_rows_by("STRATA1") |>
      analyze("AGE") |>
      split_rows_by("SEX", nested = FALSE, at_sibling = "STRATA1")
  })


  lyt <- basic_table() |>
    split_rows_by("SEX") |>
    split_rows_by("STRATA1") |>
    analyze("AGE") |>
    split_rows_by("SEX", nested = FALSE, at_sibling = "STRATA1")


  lyt <- basic_table() |>
    split_rows_by("SEX") |>
    analyze("AGE") |>
    split_rows_by("BMRKR2", nested = FALSE) |>
    split_rows_by("RACE") |>
    analyze("AGE")
  expect_no_error({
    lyt |> split_rows_by("STRATA1", at_sibling = "SEX")
  })
})


test_that("nested analyses are compounded correctly when on branch", {
  lyt <- basic_table() |>
    split_rows_by("STRATA1", split_fun = keep_2_levels("STRATA1")) |>
    split_rows_by("SEX", split_fun = keep_2_levels("SEX")) |>
    analyze("AGE", table_names = "a1") |>
    split_rows_by("RACE",
      split_fun = keep_2_levels("RACE"),
      at_sibling = "SEX"
    ) |>
    analyze("AGE", table_names = "a2") |>
    analyze("BMRKR1")
  tbl <- build_table(lyt, ex_adsl)

  expect_equal(
    path_count(tbl, c("STRATA1", "*", "SEX", "*")),
    4L
  )
})
