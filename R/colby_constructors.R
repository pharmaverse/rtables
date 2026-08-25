## default means hidden if it is by itself but visible if it has
## direct siblings due to intermediate nesting (of itself or a subsequent
## split)
label_pos_values <- c("default", "hidden", "visible", "topleft")

#' @name internal_methods
#' @rdname int_methods
NULL

#' Combine `SplitVector` objects
#'
#' @param x (`SplitVector`)\cr a `SplitVector` object.
#' @param ... splits or `SplitVector` objects.
#'
#' @return Various, but should be considered implementation details.
#'
#' @rdname int_methods
#' @exportMethod c
setMethod("c", "SplitVector", function(x, ...) {
  arglst <- list(...)
  stopifnot(all(sapply(arglst, is, "Split")))
  tmp <- c(unclass(x), arglst)
  SplitVector(lst = tmp)
})

# Constructors =====

## Pipe-able functions to add the various types of splits to the current layout
## for both row and column.  These all act as wrappers to the split_cols and
## split_rows method stacks.

#' Declaring a column-split based on levels of a variable
#'
#' Will generate children for each subset of a categorical variable.
#'
#' @inheritParams lyt_args
#' @param ref_group (`string` or `NULL`)\cr level of `var` that should be considered `ref_group`/reference.
#'
#' @return A `PreDataTableLayouts` object suitable for passing to further layouting functions, and to [build_table()].
#'
#' @inheritSection custom_split_funs Custom Splitting Function Details
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   analyze(c("AGE", "BMRKR2"))
#'
#' tbl <- build_table(lyt, ex_adsl)
#' tbl
#'
#' # Let's look at the splits in more detail
#'
#' lyt1 <- basic_table() |> split_cols_by("ARM")
#' lyt1
#'
#' # add an analysis (summary)
#' lyt2 <- lyt1 |>
#'   analyze(c("AGE", "COUNTRY"),
#'     afun = list_wrap_x(summary),
#'     format = "xx.xx"
#'   )
#' lyt2
#'
#' tbl2 <- build_table(lyt2, DM)
#' tbl2
#'
#' @examplesIf require(dplyr)
#' # By default sequentially adding layouts results in nesting
#' library(dplyr)
#'
#' DM_MF <- DM |>
#'   filter(SEX %in% c("M", "F")) |>
#'   mutate(SEX = droplevels(SEX))
#'
#' lyt3 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by("SEX") |>
#'   analyze(c("AGE", "COUNTRY"),
#'     afun = list_wrap_x(summary),
#'     format = "xx.xx"
#'   )
#' lyt3
#'
#' tbl3 <- build_table(lyt3, DM_MF)
#' tbl3
#'
#' # nested=TRUE vs not
#' lyt4 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("SEX", split_fun = drop_split_levels) |>
#'   split_rows_by("RACE", split_fun = drop_split_levels) |>
#'   analyze("AGE")
#' lyt4
#'
#' tbl4 <- build_table(lyt4, DM)
#' tbl4
#'
#' lyt5 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("SEX", split_fun = drop_split_levels) |>
#'   analyze("AGE") |>
#'   split_rows_by("RACE", nested = FALSE, split_fun = drop_split_levels) |>
#'   analyze("AGE")
#' lyt5
#'
#' tbl5 <- build_table(lyt5, DM)
#' tbl5
#'
#' @author Gabriel Becker
#' @export
split_cols_by <- function(lyt,
                          var,
                          labels_var = var,
                          split_label = var,
                          split_fun = NULL,
                          format = NULL,
                          nested = TRUE,
                          child_labels = c("default", "visible", "hidden"),
                          extra_args = list(),
                          ref_group = NULL,
                          show_colcounts = FALSE,
                          colcount_format = NULL) { ## ,
  if (is.null(ref_group)) {
    spl <- VarLevelSplit(
      var = var,
      split_label = split_label,
      labels_var = labels_var,
      split_format = format,
      child_labels = child_labels,
      split_fun = split_fun,
      extra_args = extra_args,
      show_colcounts = show_colcounts,
      colcount_format = colcount_format
    )
  } else {
    spl <- VarLevWBaselineSplit(
      var = var,
      ref_group = ref_group,
      split_label = split_label,
      split_fun = split_fun,
      labels_var = labels_var,
      split_format = format,
      show_colcounts = show_colcounts,
      colcount_format = colcount_format
    )
  }
  pos <- next_cpos(lyt, nested)
  split_cols(lyt, spl, pos)
}

## .tl_indent ====

setGeneric(".tl_indent_inner", function(lyt) standardGeneric(".tl_indent_inner"))

setMethod(
  ".tl_indent_inner", "PreDataTableLayouts",
  function(lyt) .tl_indent_inner(rlayout(lyt))
)
setMethod(
  ".tl_indent_inner", "PreDataRowLayout",
  function(lyt) {
    if (length(lyt) == 0 || length(lyt[[1]]) == 0) {
      0L
    } else {
      .tl_indent_inner(lyt[[length(lyt)]])
    }
  }
)

setMethod(
  ".tl_indent_inner", "SplitVector",
  function(lyt) {
    sum(vapply(lyt, function(x) label_position(x) == "topleft", TRUE)) - 1L
  }
) ## length(lyt) - 1L)

.tl_indent <- function(lyt, nested = TRUE) {
  if (!nested) {
    0L
  } else {
    .tl_indent_inner(lyt)
  }
}

#' Add rows according to levels of a variable
#'
#' @inheritParams lyt_args
#'
#' @inherit split_cols_by return
#'
#' @inheritSection custom_split_funs Custom Splitting Function Details
#'
#' @note
#' If `var` is a factor with empty unobserved levels and `labels_var` is specified, it must also be a factor
#' with the same number of levels as `var`. Currently the error that occurs when this is not the case is not very
#' informative, but that will change in the future.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("RACE", split_fun = drop_split_levels) |>
#'   analyze("AGE", mean, var_labels = "Age", format = "xx.xx")
#'
#' tbl <- build_table(lyt, DM)
#' tbl
#'
#' lyt2 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("RACE") |>
#'   analyze("AGE", mean, var_labels = "Age", format = "xx.xx")
#'
#' tbl2 <- build_table(lyt2, DM)
#' tbl2
#'
#' lyt3 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by("SEX") |>
#'   summarize_row_groups(label_fstr = "Overall (N)") |>
#'   split_rows_by("RACE",
#'     split_label = "Ethnicity", labels_var = "ethn_lab",
#'     split_fun = drop_split_levels
#'   ) |>
#'   summarize_row_groups("RACE", label_fstr = "%s (n)") |>
#'   analyze("AGE", var_labels = "Age", afun = mean, format = "xx.xx")
#'
#' lyt3
#'
#' @examplesIf require(dplyr)
#' library(dplyr)
#'
#' DM2 <- DM |>
#'   filter(SEX %in% c("M", "F")) |>
#'   mutate(
#'     SEX = droplevels(SEX),
#'     gender_lab = c(
#'       "F" = "Female", "M" = "Male",
#'       "U" = "Unknown",
#'       "UNDIFFERENTIATED" = "Undifferentiated"
#'     )[SEX],
#'     ethn_lab = c(
#'       "ASIAN" = "Asian",
#'       "BLACK OR AFRICAN AMERICAN" = "Black or African American",
#'       "WHITE" = "White",
#'       "AMERICAN INDIAN OR ALASKA NATIVE" = "American Indian or Alaska Native",
#'       "MULTIPLE" = "Multiple",
#'       "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER" =
#'         "Native Hawaiian or Other Pacific Islander",
#'       "OTHER" = "Other", "UNKNOWN" = "Unknown"
#'     )[RACE]
#'   )
#'
#' tbl3 <- build_table(lyt3, DM2)
#' tbl3
#'
#' @author Gabriel Becker
#' @export
split_rows_by <- function(lyt,
                          var,
                          labels_var = var,
                          split_label = var,
                          split_fun = NULL,
                          parent_name = var,
                          format = NULL,
                          na_str = NA_character_,
                          nested = TRUE,
                          at_sibling = NULL,
                          child_labels = c("default", "visible", "hidden"),
                          label_pos = if (!is.null(at_sibling)) "visible" else "default",
                          indent_mod = 0L,
                          page_by = FALSE,
                          page_prefix = split_label,
                          section_div = NA_character_) {
  label_pos <- match.arg(label_pos, label_pos_values)
  child_labels <- match.arg(child_labels)
  spl <- VarLevelSplit(
    var = var,
    split_label = split_label,
    label_pos = label_pos,
    labels_var = labels_var,
    split_fun = split_fun,
    split_format = format,
    split_na_str = na_str,
    child_labels = child_labels,
    indent_mod = indent_mod,
    page_prefix = if (page_by) page_prefix else NA_character_,
    section_div = section_div,
    split_name = parent_name
  )

  pos <- next_rpos(lyt, nested, at_sibling = at_sibling)
  ret <- split_rows(lyt, spl, pos, at_sibling = at_sibling)

  ret
}

#' Associate multiple variables with columns
#'
#' In some cases, the variable to be ultimately analyzed is most naturally defined on a column, not a row, basis.
#' When we need columns to reflect different variables entirely, rather than different levels of a single
#' variable, we use `split_cols_by_multivar`.
#'
#' @inheritParams lyt_args
#'
#' @inherit split_cols_by return
#'
#' @seealso [analyze_colvars()]
#'
#' @examplesIf require(dplyr)
#' library(dplyr)
#'
#' ANL <- DM |> mutate(value = rnorm(n()), pctdiff = runif(n()))
#'
#' ## toy example where we take the mean of the first variable and the
#' ## count of >.5 for the second.
#' colfuns <- list(
#'   function(x) in_rows(mean = mean(x), .formats = "xx.x"),
#'   function(x) in_rows("# x > 5" = sum(x > .5), .formats = "xx")
#' )
#'
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by_multivar(c("value", "pctdiff")) |>
#'   split_rows_by("RACE",
#'     split_label = "ethnicity",
#'     split_fun = drop_split_levels
#'   ) |>
#'   summarize_row_groups() |>
#'   analyze_colvars(afun = colfuns)
#' lyt
#'
#' tbl <- build_table(lyt, ANL)
#' tbl
#'
#' @author Gabriel Becker
#' @export
split_cols_by_multivar <- function(lyt,
                                   vars,
                                   split_fun = NULL,
                                   varlabels = vars,
                                   varnames = NULL,
                                   nested = TRUE,
                                   extra_args = list(),
                                   ## for completeness even though it doesn't make sense
                                   show_colcounts = FALSE,
                                   colcount_format = NULL) {
  spl <- MultiVarSplit(
    vars = vars, split_label = "",
    varlabels = varlabels,
    varnames = varnames,
    split_fun = split_fun,
    extra_args = extra_args,
    show_colcounts = show_colcounts,
    colcount_format = colcount_format
  )
  pos <- next_cpos(lyt, nested)
  split_cols(lyt, spl, pos)
}

#' Associate multiple variables with rows
#'
#' When we need rows to reflect different variables rather than different
#' levels of a single variable, we use `split_rows_by_multivar`.
#'
#' @inheritParams lyt_args
#'
#' @inherit split_rows_by return
#'
#' @seealso [split_rows_by()] for typical row splitting, and [split_cols_by_multivar()] to perform the same type of
#'   split on a column basis.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by_multivar(c("SEX", "STRATA1")) |>
#'   summarize_row_groups() |>
#'   analyze(c("AGE", "SEX"))
#'
#' tbl <- build_table(lyt, DM)
#' tbl
#'
#' @export
split_rows_by_multivar <- function(lyt,
                                   vars,
                                   split_fun = NULL,
                                   split_label = "",
                                   varlabels = vars,
                                   parent_name = "multivars",
                                   format = NULL,
                                   na_str = NA_character_,
                                   nested = TRUE,
                                   at_sibling = NULL,
                                   child_labels = c("default", "visible", "hidden"),
                                   indent_mod = 0L,
                                   section_div = NA_character_,
                                   extra_args = list()) {
  child_labels <- match.arg(child_labels)
  spl <- MultiVarSplit(
    vars = vars, split_label = split_label, varlabels,
    split_format = format,
    split_na_str = na_str,
    child_labels = child_labels,
    indent_mod = indent_mod,
    split_fun = split_fun,
    section_div = section_div,
    extra_args = extra_args,
    split_name = parent_name
  )
  pos <- next_rpos(lyt, nested, at_sibling = at_sibling)
  split_rows(lyt, spl, pos, at_sibling = at_sibling)
}

#' Split on static or dynamic cuts of the data
#'
#' Create columns (or row splits) based on values (such as quartiles) of `var`.
#'
#' @inheritParams lyt_args
#'
#' @details For dynamic cuts, the cut is transformed into a static cut by [build_table()] *based on the full dataset*,
#' before proceeding. Thus even when nested within another split in column/row space, the resulting split will reflect
#' the overall values (e.g., quartiles) in the dataset, NOT the values for subset it is nested under.
#'
#' @inherit split_cols_by return
#'
#' @examplesIf require(dplyr)
#' library(dplyr)
#'
#' # split_cols_by_cuts
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by_cuts("AGE",
#'     split_label = "Age",
#'     cuts = c(0, 25, 35, 1000),
#'     cutlabels = c("young", "medium", "old")
#'   ) |>
#'   analyze(c("BMRKR2", "STRATA2")) |>
#'   append_topleft("counts")
#'
#' tbl <- build_table(lyt, ex_adsl)
#' tbl
#'
#' # split_rows_by_cuts
#' lyt2 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by_cuts("AGE",
#'     split_label = "Age",
#'     cuts = c(0, 25, 35, 1000),
#'     cutlabels = c("young", "medium", "old")
#'   ) |>
#'   analyze(c("BMRKR2", "STRATA2")) |>
#'   append_topleft("counts")
#'
#'
#' tbl2 <- build_table(lyt2, ex_adsl)
#' tbl2
#'
#' # split_cols_by_quartiles
#'
#' lyt3 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by_quartiles("AGE", split_label = "Age") |>
#'   analyze(c("BMRKR2", "STRATA2")) |>
#'   append_topleft("counts")
#'
#' tbl3 <- build_table(lyt3, ex_adsl)
#' tbl3
#'
#' # split_rows_by_quartiles
#' lyt4 <- basic_table(show_colcounts = TRUE) |>
#'   split_cols_by("ARM") |>
#'   split_rows_by_quartiles("AGE", split_label = "Age") |>
#'   analyze("BMRKR2") |>
#'   append_topleft(c("Age Quartiles", " Counts BMRKR2"))
#'
#' tbl4 <- build_table(lyt4, ex_adsl)
#' tbl4
#'
#' # split_cols_by_cutfun
#' cutfun <- function(x) {
#'   cutpoints <- c(
#'     min(x),
#'     mean(x),
#'     max(x)
#'   )
#'
#'   names(cutpoints) <- c("", "Younger", "Older")
#'   cutpoints
#' }
#'
#' lyt5 <- basic_table() |>
#'   split_cols_by_cutfun("AGE", cutfun = cutfun) |>
#'   analyze("SEX")
#'
#' tbl5 <- build_table(lyt5, ex_adsl)
#' tbl5
#'
#' # split_rows_by_cutfun
#' lyt6 <- basic_table() |>
#'   split_cols_by("SEX") |>
#'   split_rows_by_cutfun("AGE", cutfun = cutfun) |>
#'   analyze("BMRKR2")
#'
#' tbl6 <- build_table(lyt6, ex_adsl)
#' tbl6
#'
#' @author Gabriel Becker
#' @export
#' @rdname varcuts
split_cols_by_cuts <- function(lyt, var, cuts,
                               cutlabels = NULL,
                               split_label = var,
                               nested = TRUE,
                               cumulative = FALSE,
                               show_colcounts = FALSE,
                               colcount_format = NULL) {
  spl <- make_static_cut_split(
    var = var,
    split_label = split_label,
    cuts = cuts,
    cutlabels = cutlabels,
    cumulative = cumulative,
    show_colcounts = show_colcounts,
    colcount_format = colcount_format
  )
  ## if(cumulative)
  ##     spl = as(spl, "CumulativeCutSplit")
  pos <- next_cpos(lyt, nested)
  split_cols(lyt, spl, pos)
}

#' @export
#' @rdname varcuts
split_rows_by_cuts <- function(lyt, var, cuts,
                               cutlabels = NULL,
                               split_label = var,
                               parent_name = var,
                               format = NULL,
                               na_str = NA_character_,
                               nested = TRUE,
                               at_sibling = NULL,
                               cumulative = FALSE,
                               label_pos = if (!is.null(at_sibling)) "visible" else "default",
                               section_div = NA_character_) {
  label_pos <- match.arg(label_pos, label_pos_values)
  ##    VarStaticCutSplit(
  spl <- make_static_cut_split(var, split_label,
    cuts = cuts,
    cutlabels = cutlabels,
    split_format = format,
    split_na_str = na_str,
    label_pos = label_pos,
    cumulative = cumulative,
    section_div = section_div,
    split_name = parent_name
  )
  ## if(cumulative)
  ##     spl = as(spl, "CumulativeCutSplit")
  pos <- next_rpos(lyt, nested, at_sibling = at_sibling)
  split_rows(lyt, spl, pos, at_sibling = at_sibling)
}

#' @export
#' @rdname varcuts
split_cols_by_cutfun <- function(lyt, var,
                                 cutfun = qtile_cuts,
                                 cutlabelfun = function(x) NULL,
                                 split_label = var,
                                 nested = TRUE,
                                 extra_args = list(),
                                 cumulative = FALSE,
                                 show_colcounts = FALSE,
                                 colcount_format = NULL) {
  spl <- VarDynCutSplit(var, split_label,
    cutfun = cutfun,
    cutlabelfun = cutlabelfun,
    extra_args = extra_args,
    cumulative = cumulative,
    label_pos = "hidden",
    show_colcounts = show_colcounts,
    colcount_format = colcount_format
  )
  pos <- next_cpos(lyt, nested)
  split_cols(lyt, spl, pos)
}

#' @export
#' @rdname varcuts
split_cols_by_quartiles <- function(lyt, var, split_label = var,
                                    nested = TRUE,
                                    extra_args = list(),
                                    cumulative = FALSE,
                                    show_colcounts = FALSE,
                                    colcount_format = NULL) {
  split_cols_by_cutfun(
    lyt = lyt,
    var = var,
    split_label = split_label,
    cutfun = qtile_cuts,
    cutlabelfun = function(x) {
      c(
        "[min, Q1]",
        "(Q1, Q2]",
        "(Q2, Q3]",
        "(Q3, max]"
      )
    },
    nested = nested,
    extra_args = extra_args,
    cumulative = cumulative,
    show_colcounts = show_colcounts,
    colcount_format = colcount_format
  )
  ## spl = VarDynCutSplit(var, split_label, cutfun = qtile_cuts,
  ##                      cutlabelfun = function(x) c("[min, Q1]",
  ##                                                "(Q1, Q2]",
  ##                                                "(Q2, Q3]",
  ##                                                "(Q3, max]"),
  ##                      split_format = format,
  ##                      extra_args = extra_args,
  ##                      cumulative = cumulative,
  ##                      label_pos = "hidden")
  ## pos = next_cpos(lyt, nested)
  ## split_cols(lyt, spl, pos)
}

#' @export
#' @rdname varcuts
split_rows_by_quartiles <- function(lyt, var, split_label = var,
                                    parent_name = var,
                                    format = NULL,
                                    na_str = NA_character_,
                                    nested = TRUE,
                                    at_sibling = NULL,
                                    child_labels = c("default", "visible", "hidden"),
                                    extra_args = list(),
                                    cumulative = FALSE,
                                    indent_mod = 0L,
                                    label_pos = if (!is.null(at_sibling)) "visible" else "default",
                                    section_div = NA_character_) {
  split_rows_by_cutfun(
    lyt = lyt,
    var = var,
    split_label = split_label,
    parent_name = parent_name,
    format = format,
    na_str = na_str,
    cutfun = qtile_cuts,
    cutlabelfun = function(x) {
      c(
        "[min, Q1]",
        "(Q1, Q2]",
        "(Q2, Q3]",
        "(Q3, max]"
      )
    },
    nested = nested,
    at_sibling = at_sibling,
    child_labels = child_labels,
    extra_args = extra_args,
    cumulative = cumulative,
    indent_mod = indent_mod,
    label_pos = label_pos,
    section_div = section_div
  )
}

qtile_cuts <- function(x) {
  ret <- quantile(x)
  names(ret) <- c(
    "",
    "1st qrtile",
    "2nd qrtile",
    "3rd qrtile",
    "4th qrtile"
  )
  ret
}

#' @export
#' @rdname varcuts
split_rows_by_cutfun <- function(lyt, var,
                                 cutfun = qtile_cuts,
                                 cutlabelfun = function(x) NULL,
                                 split_label = var,
                                 parent_name = var,
                                 format = NULL,
                                 na_str = NA_character_,
                                 nested = TRUE,
                                 at_sibling = NULL,
                                 child_labels = c("default", "visible", "hidden"),
                                 extra_args = list(),
                                 cumulative = FALSE,
                                 indent_mod = 0L,
                                 label_pos = if (!is.null(at_sibling)) "visible" else "default",
                                 section_div = NA_character_) {
  label_pos <- match.arg(label_pos, label_pos_values)
  child_labels <- match.arg(child_labels)
  spl <- VarDynCutSplit(var, split_label,
    cutfun = cutfun,
    cutlabelfun = cutlabelfun,
    split_format = format,
    split_na_str = na_str,
    child_labels = child_labels,
    extra_args = extra_args,
    cumulative = cumulative,
    indent_mod = indent_mod,
    label_pos = label_pos,
    section_div = section_div,
    split_name = parent_name
  )
  pos <- next_rpos(lyt, nested, at_sibling = at_sibling)
  split_rows(lyt, spl, pos, at_sibling = at_sibling)
}

#' .spl_context within analysis and split functions
#'
#' `.spl_context` is an optional parameter for any of rtables' special functions, i.e. `afun` (analysis function
#' in [analyze()]), `cfun` (content or label function in [summarize_row_groups()]), or `split_fun` (e.g. for
#' [split_rows_by()]).
#'
#' @details
#' The `.spl_context` `data.frame` gives information about the subsets of data corresponding to the splits within
#' which the current `analyze` action is nested. Taken together, these correspond to the path that the resulting (set
#' of) rows the analysis function is creating, although the information is in a slightly different form. Each split
#' (which correspond to groups of rows in the resulting table), as well as the initial 'root' "split", is represented
#' via the following columns:
#'
#' \describe{
#'   \item{split}{The name of the split (often the variable being split).}
#'   \item{value}{The string representation of the value at that split (`split`).}
#'   \item{full_parent_df}{A `data.frame` containing the full data (i.e. across all columns) corresponding to the path
#'     defined by the combination of `split` and `value` of this row *and all rows above this row*.}
#'   \item{all_cols_n}{The number of observations corresponding to the row grouping (union of all columns).}
#'   \item{column for each column in the table structure (*row-split and analyze contexts only*)}{These list columns
#'     (named the same as `names(col_exprs(tab))`) contain logical vectors corresponding to the subset of this row's
#'     `full_parent_df` corresponding to the column.}
#'   \item{cur_col_id}{Identifier of the current column. This may be an internal name, constructed by pasting the
#'     column path together.}
#'   \item{cur_col_subset}{List column containing logical vectors indicating the subset of this row's `full_parent_df`
#'     for the column currently being created by the analysis function.}
#'   \item{cur_col_expr}{List of current column expression. This may be used to filter `.alt_df_row`, or any external
#'     data, by column. Filtering `.alt_df_row` by columns produces `.alt_df`.}
#'   \item{cur_col_n}{Integer column containing the observation counts for that split.}
#'   \item{cur_col_split}{Current column split names. This is recovered from the current column path.}
#'   \item{cur_col_split_val}{Current column split values. This is recovered from the current column path.}
#' }
#'
#' @note
#' Within analysis functions that accept `.spl_context`, the `all_cols_n` and `cur_col_n` columns of the data frame
#' will contain the 'true' observation counts corresponding to the row-group and row-group x column subsets of the
#' data. These numbers will not, and currently cannot, reflect alternate column observation counts provided by the
#' `alt_counts_df`, `col_counts` or `col_total` arguments to [build_table()].
#'
#' @name spl_context
NULL

#' Additional parameters within analysis and content functions (`afun`/`cfun`)
#'
#' @description
#' It is possible to add specific parameters to `afun` and `cfun`, in [analyze()] and [summarize_row_groups()],
#' respectively. These parameters grant access to relevant information like the row split structure (see
#' [spl_context]) and the predefined baseline (`.ref_group`).
#'
#' @details
#' We list and describe all the parameters that can be added to a custom analysis function below:
#'
#' \describe{
#'   \item{.N_col}{Column-wise N (column count) for the full column being tabulated within.}
#'   \item{.N_total}{Overall N (all observation count, defined as sum of column counts) for the tabulation.}
#'   \item{.N_row}{Row-wise N (row group count) for the group of observations being analyzed (i.e. with no
#'     column-based subsetting).}
#'   \item{.df_row}{`data.frame` for observations in the row group being analyzed (i.e. with no column-based
#'     subsetting).}
#'   \item{.var}{Variable being analyzed.}
#'   \item{.ref_group}{`data.frame` or vector of subset corresponding to the `ref_group` column including subsetting
#'     defined by row-splitting. Only required/meaningful if a `ref_group` column has been defined.}
#'   \item{.ref_full}{`data.frame` or vector of subset corresponding to the `ref_group` column without subsetting
#'     defined by row-splitting. Only required/meaningful if a `ref_group` column has been defined.}
#'   \item{.in_ref_col}{Boolean indicating if calculation is done for cells within the reference column.}
#'   \item{.spl_context}{`data.frame` where each row gives information about a previous 'ancestor' split state.
#'     See [spl_context].}
#'   \item{.alt_df_row}{`data.frame`, i.e. the `alt_counts_df` after row splitting. It can be used with
#'     `.all_col_exprs` and `.spl_context` information to retrieve current faceting, but for `alt_count_df`.
#'     It can be an empty table if all the entries are filtered out.}
#'   \item{.alt_df}{`data.frame`, `.alt_df_row` but filtered by columns expression. This data present the same
#'     faceting of main data `df`. This also filters `NA`s out if related parameters are set to do so (e.g. `inclNAs`
#'     in [analyze()]). Similarly to `.alt_df_row`, it can be an empty data.frame if all the entries are filtered out.}
#'   \item{.alt_df_full}{`data.frame`, the full `alt_counts_df` as passed into `build_table`.
#'     Unlike `.alt_df` and `.alt_df_row`, this parameter can be used in cases
#'     where the variables required for row splitting are not present in `alt_counts_df`.}
#'   \item{.all_col_exprs}{List of expressions. Each of them represents a different column splitting.}
#'   \item{.all_col_counts}{Vector of integers. Each of them represents the global count for each column. It differs
#'     if `alt_counts_df` is used (see [build_table()]).}
#' }
#'
#' @note If any of these formals is specified incorrectly or not present in the tabulation machinery, it will be
#'   treated as if missing. For example, `.ref_group` will be missing if no baseline is previously defined during
#'   data splitting (via `ref_group` parameters in, e.g., [split_rows_by()]). Similarly, if no `alt_counts_df` is
#'   provided to [build_table()], `.alt_df_row` and `.alt_df` will not be present.
#'
#' @name additional_fun_params
NULL

#' Generate rows analyzing variables across columns
#'
#' Adding *analyzed variables* to our table layout defines the primary tabulation to be performed. We do this by
#' adding calls to `analyze` and/or [analyze_colvars()] into our layout pipeline. As with adding further splitting,
#' the tabulation will occur at the current/next level of nesting by default.
#'
#' @inheritParams lyt_args
#' @param section_div (`string`)\cr string which should be repeated as a section divider after the set of rows  defined
#'   by (each sub-analysis/variable) of this analyze instruction, or
#'   `NA_character_` (the default) for no section divider. This section
#'   divider will be overridden by a split-level section divider when
#'   both apply to the same position in the rendered output.
#'
#' @details When `length(vars) > 1` and when two calls to `analyze`
#'     are done in sequence (the second with the default `nested =
#'     TRUE`), the analyses will be combined into a multi-variable
#'     analysis that will be reflected in the row structure of the
#'     resulting table. In these cases, the default is to show the
#'     label describing the variable analyzed for each of the
#'     resulting subtables, while that is hidden by default in
#'     one-variable cases.
#'
#' # Specifying Default Formatting Behavior
#'
#' *Default* formatting behavior for rows generated by `afun` can be
#' specified by one of `format` or `formats_var`. In both cases, these
#' default formatting instructions *will not* supersede formatting
#' specified from within `afun` at either the `rcell` or `in_rows`
#' call levels; They will only apply to rows/cells whose formatting as
#' returned by `afun` is either `NULL` or `"default"`.  When
#' non-`NULL`, `format` is used to specify formats for all generated
#' rows, and can be a character vector, a function, or a list of
#' functions. It will be repped out to the number of rows once this is
#' calculated during the tabulation process, but will be overridden by
#' formats specified within `rcell` calls in `afun`.
#'
#' `format` can accept a format label string (see
#' [formatters::list_valid_format_labels()]), a formatting function, an
#' unnamed list, or a named list.
#'
#' When `format` is an unnamed list - or a named list where not all
#' values of `vars` appear in the names - its elements will be repped
#' out to the number of rows generated by `afun` (separately) within
#' each row facet `afun` is applied within. **This includes recycling
#' behavior, even in the case where the number of rows is not cleanly
#' divisible by the number of specified formats**. This behavior is
#' retained largely for legacy reasons and switching to the new
#' named-list behavior is advised where applicable.
#'
#' When `format` is a named list whose names contain all values in
#' `vars`, the elements of `format` are taken to be specific to the
#' analysis of the corresponding variable; this allows us to specify a
#' multi-variable analysis where e.g., the different variables are
#' analyzed by the same `afun` but have different levels of
#' measurement precision (and thus different formatting needs). In
#' this case the var-specific formatting can be a single format (label
#' string or function) or can be a named list whose names will be
#' matched up to those of the rows generated by applying `afun` in
#' each row facet. Matching of formats to rows is performed the same
#' as in the `formats_var` case and is described below.
#'
#' When `formats_var` is non-`NULL`, it specifies the name of a list
#' column containing formatting instructions for one or more rows
#' `afun` will generate when applied within a row facet. This can be
#' used when the analysis results for a single variable (e.g., `value`
#' or `AVAL` in long-form data) should be formatted differently within
#' different row facets (e.g., when faceting on `statistic` or
#' `PARAMCD`). The value of `df[[formats_var]]` is assumed without
#' verification to be constant within each row facet `afun` is applied
#' within, and the first (list) value of the column within the row
#' facet data will be used.
#'
#' In the `formats_var` case as well as the case of `format` being a
#' named list containing the values of `vars`, after rows are created
#' during tabulation, the default formats are matched and applied to
#' them as follows:
#'
#' 1. When the generated row's name (as given by `obj_name`) matches
#'   a name in the list, the corresponding default format is applied,
#' 2. for those without exact matches, the default format whose name
#'   provides *the best partial match* to each row name is applied,
#' 3. For those without default format names that partially match
#'   the row name, no default format is applied.
#'
#' Note carefully that in (2), it is the names of the list of formats
#' that are partially matching the row names not the other way around.
#'
#' # The Analysis Function
#'
#' The analysis function (`afun`) should take as its first parameter either `x` or `df`. Whichever of these the
#' function accepts will change the behavior when tabulation is performed as follows:
#'
#' - If `afun`'s first parameter is `x`, it will receive the corresponding subset *vector* of data from the relevant
#'   column (from `var` here) of the raw data being used to build the table.
#' - If `afun`'s first parameter is `df`, it will receive the corresponding subset *data frame* (i.e. all columns) of
#'   the raw data being tabulated.
#'
#' In addition to differentiation on the first argument, the analysis function can optionally accept a number of
#' other parameters which, *if and only if* present in the formals, will be passed to the function by the tabulation
#' machinery. These are listed and described in [additional_fun_params].
#'
#' @inherit split_cols_by return
#'
#' @note None of the arguments described in [additional_fun_params] can be overridden via `extra_args` or when calling
#'   [make_afun()]. `.N_col` and `.N_total` can be overridden via the `col_counts` argument to [build_table()].
#'   Alternative values for the others must be calculated within `afun` based on a combination of extra arguments and
#'   the unmodified values provided by the tabulation framework.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   analyze("AGE", afun = list_wrap_x(summary), format = "xx.xx")
#' lyt
#'
#' tbl <- build_table(lyt, DM)
#' tbl
#'
#' lyt2 <- basic_table() |>
#'   split_cols_by("Species") |>
#'   analyze(head(names(iris), -1), afun = function(x) {
#'     list(
#'       "mean / sd" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
#'       "range" = rcell(diff(range(x)), format = "xx.xx")
#'     )
#'   })
#' lyt2
#'
#' tbl2 <- build_table(lyt2, iris)
#' tbl2
#'
#' @author Gabriel Becker
#' @export
analyze <- function(lyt,
                    vars,
                    afun = simple_analysis,
                    var_labels = vars,
                    ## really wish I hadn't named this table_names
                    ## but can't break backwards compat :(
                    table_names = vars,
                    parent_name = NULL,
                    format = NULL,
                    formats_var = NULL,
                    na_str = NA_character_,
                    na_strs_var = NULL,
                    nested = TRUE,
                    at_sibling = NULL,
                    ## can't name this na_rm symbol conflict with possible afuns!!
                    inclNAs = FALSE,
                    extra_args = list(),
                    show_labels = c("default", "visible", "hidden"),
                    indent_mod = 0L,
                    section_div = NA_character_) {
  show_labels <- match.arg(show_labels)
  subafun <- substitute(afun)
  if (!is.null(format) && !is.null(formats_var)) {
    stop(
      "Cannot use 'format' and 'formats_var' arguments at ",
      "the same time. Please choose one method for specifying ",
      "default formatting."
    )
  } else if (is.null(formats_var) && !is.null(na_strs_var)) {
    stop(
      "Cannot use 'na_strs_var' (got ",
      na_strs_var,
      ") without using 'formats_var'."
    )
  }
  # R treats a single NA value as a logical atomic. The below
  # maps all the NAs in `var_labels` to NA_character_ required by `Split`
  # and avoids the error when `var_labels` is just c(NA).
  var_labels <- vapply(var_labels, function(label) ifelse(is.na(label), NA_character_, label), character(1))
  if (
    is.name(subafun) &&
      is.function(afun) &&
      ## this is gross. basically testing
      ## if the symbol we have corresponds
      ## in some meaningful way to the function
      ## we will be calling.
      identical(
        mget(
          as.character(subafun),
          mode = "function",
          ifnotfound = list(NULL),
          inherits = TRUE
        )[[1]], afun
      )
  ) {
    defrowlab <- as.character(subafun)
  } else {
    defrowlab <- var_labels
  }

  ## hook up the new hotness
  var_format_lists <- length(vars) > 1 &&
    is.list(format) &&
    all(vars %in% names(format))

  if (var_format_lists) {
    format <- lapply(format, function(x) FormatList(.list = x))
    if (is.character(na_str)) {
      na_str <- lapply(format, function(x) na_str)
    }
  }
  spl <- AnalyzeMultiVars(vars, var_labels,
    afun = afun,
    split_format = format,
    split_na_str = na_str,
    defrowlab = defrowlab,
    inclNAs = inclNAs,
    extra_args = extra_args,
    indent_mod = indent_mod,
    child_names = table_names,
    child_labels = show_labels,
    section_div = section_div,
    split_name = parent_name,
    formats_var = formats_var,
    na_strs_var = na_strs_var
  )

  if (nested && is.null(at_sibling) &&
      (is(last_rowsplit(lyt), "VAnalyzeSplit") || is(last_rowsplit(lyt), "AnalyzeMultiVars"))) {
    cmpnd_last_rowsplit(lyt, spl, AnalyzeMultiVars)
  } else {
    ## analysis compounding now done in split_rows
    pos <- next_rpos(lyt, nested, at_sibling = at_sibling)
    split_rows(lyt, spl, pos, at_sibling = at_sibling)
  }
}

get_acolvar_name <- function(lyt) {
  ## clyt <- clayout(lyt)
  ## stopifnot(length(clyt) == 1L)
  ## vec = clyt[[1]]
  ## vcls = vapply(vec, class, "")
  ## pos = max(which(vcls ==  "MultiVarSplit"))
  paste(c("ac", get_acolvar_vars(lyt)), collapse = "_")
}

get_acolvar_vars <- function(lyt) {
  clyt <- clayout(lyt)
  stopifnot(length(clyt) == 1L)
  vec <- clyt[[1]]
  vcls <- vapply(vec, class, "")
  pos <- which(vcls == "MultiVarSplit")
  if (length(pos) > 0) {
    spl_payload(vec[[pos]])
  } else {
    "non_multivar"
  }
}

#' Generate rows analyzing different variables across columns
#'
#' @inheritParams lyt_args
#' @param afun (`function` or `list`)\cr function(s) to be used to calculate the values in each column. The list
#'   will be repped out as needed and matched by position with the columns during tabulation. This functions
#'   accepts the same parameters as [analyze()] like `afun` and `format`. For further information see
#'   [additional_fun_params].
#'
#' @inherit split_cols_by return
#'
#' @seealso [split_cols_by_multivar()]
#'
#' @examplesIf require(dplyr)
#' library(dplyr)
#'
#' ANL <- DM |> mutate(value = rnorm(n()), pctdiff = runif(n()))
#'
#' ## toy example where we take the mean of the first variable and the
#' ## count of >.5 for the second.
#' colfuns <- list(
#'   function(x) rcell(mean(x), format = "xx.x"),
#'   function(x) rcell(sum(x > .5), format = "xx")
#' )
#'
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by_multivar(c("value", "pctdiff")) |>
#'   split_rows_by("RACE",
#'     split_label = "ethnicity",
#'     split_fun = drop_split_levels
#'   ) |>
#'   summarize_row_groups() |>
#'   analyze_colvars(afun = colfuns)
#' lyt
#'
#' tbl <- build_table(lyt, ANL)
#' tbl
#'
#' lyt2 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by_multivar(c("value", "pctdiff"),
#'     varlabels = c("Measurement", "Pct Diff")
#'   ) |>
#'   split_rows_by("RACE",
#'     split_label = "ethnicity",
#'     split_fun = drop_split_levels
#'   ) |>
#'   summarize_row_groups() |>
#'   analyze_colvars(afun = mean, format = "xx.xx")
#'
#' tbl2 <- build_table(lyt2, ANL)
#' tbl2
#'
#' @author Gabriel Becker
#' @export
analyze_colvars <- function(lyt,
                            afun,
                            parent_name = get_acolvar_name(lyt),
                            format = NULL,
                            na_str = NA_character_,
                            nested = TRUE,
                            at_sibling = NULL,
                            extra_args = list(),
                            indent_mod = 0L,
                            inclNAs = FALSE) {
  if (is.function(afun)) {
    subafun <- substitute(afun)
    if (
      is.name(subafun) &&
        is.function(afun) &&
        ## this is gross. basically testing
        ## if the symbol we have corresponds
        ## in some meaningful way to the function
        ## we will be calling.
        identical(
          mget(
            as.character(subafun),
            mode = "function",
            ifnotfound = list(NULL),
            inherits = TRUE
          )[[1]],
          afun
        )
    ) {
      defrowlab <- as.character(subafun)
    } else {
      defrowlab <- ""
    }
    afun <- lapply(
      get_acolvar_vars(lyt),
      function(x) afun
    )
  } else {
    defrowlab <- ""
  }
  spl <- AnalyzeColVarSplit(
    afun = afun,
    defrowlab = defrowlab,
    split_format = format,
    split_na_str = na_str,
    split_name = parent_name,
    indent_mod = indent_mod,
    extra_args = extra_args,
    inclNAs = inclNAs
  )
  pos <- next_rpos(lyt, nested, for_analyze = TRUE, at_sibling = at_sibling)
  split_rows(lyt, spl, pos, at_sibling = at_sibling)
}

## Add a total column at the next **top level** spot in
## the column layout.

#' Add overall column
#'
#' This function will *only* add an overall column at the *top* level of splitting, NOT within existing column splits.
#' See [add_overall_level()] for the recommended way to add overall columns more generally within existing splits.
#'
#' @inheritParams lyt_args
#'
#' @inherit split_cols_by return
#'
#' @seealso [add_overall_level()]
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   add_overall_col("All Patients") |>
#'   analyze("AGE")
#' lyt
#'
#' tbl <- build_table(lyt, DM)
#' tbl
#'
#' @export
add_overall_col <- function(lyt, label) {
  spl <- AllSplit(label)
  split_cols(
    lyt,
    spl,
    next_cpos(lyt, FALSE)
  )
}

## add_row_summary ====

#' @inheritParams lyt_args
#'
#' @export
#'
#' @rdname int_methods
setGeneric(
  ".add_row_summary",
  function(lyt,
           label,
           cfun,
           child_labels = c("default", "visible", "hidden"),
           cformat = NULL,
           cna_str = "-",
           indent_mod = 0L,
           cvar = "",
           extra_args = list()) {
    standardGeneric(".add_row_summary")
  }
)

#' @rdname int_methods
setMethod(
  ".add_row_summary", "PreDataTableLayouts",
  function(lyt,
           label,
           cfun,
           child_labels = c("default", "visible", "hidden"),
           cformat = NULL,
           cna_str = "-",
           indent_mod = 0L,
           cvar = "",
           extra_args = list()) {
    child_labels <- match.arg(child_labels)
    tmp <- .add_row_summary(rlayout(lyt), label, cfun,
      child_labels = child_labels,
      cformat = cformat,
      cna_str = cna_str,
      indent_mod = indent_mod,
      cvar = cvar,
      extra_args = extra_args
    )
    rlayout(lyt) <- tmp
    lyt
  }
)

#' @rdname int_methods
setMethod(
  ".add_row_summary", "PreDataRowLayout",
  function(lyt,
           label,
           cfun,
           child_labels = c("default", "visible", "hidden"),
           cformat = NULL,
           cna_str = "-",
           indent_mod = 0L,
           cvar = "",
           extra_args = list()) {
    child_labels <- match.arg(child_labels)
    if (length(lyt) == 0 || (length(lyt) == 1 && length(lyt[[1]]) == 0)) {
      ## XXX ignoring indent mod here
      rt <- root_spl(lyt)
      rt <- .add_row_summary(rt,
        label,
        cfun,
        child_labels = child_labels,
        cformat = cformat,
        cna_str = cna_str,
        cvar = cvar,
        extra_args = extra_args
      )
      root_spl(lyt) <- rt
    } else {
      ind <- length(lyt)
      tmp <- .add_row_summary(lyt[[ind]], label, cfun,
        child_labels = child_labels,
        cformat = cformat,
        cna_str = cna_str,
        indent_mod = indent_mod,
        cvar = cvar,
        extra_args = extra_args
      )
      lyt[[ind]] <- tmp
    }
    lyt
  }
)

#' @rdname int_methods
setMethod(
  ".add_row_summary", "SplitVector",
  function(lyt,
           label,
           cfun,
           child_labels = c("default", "visible", "hidden"),
           cformat = NULL,
           cna_str = "-",
           indent_mod = 0L,
           cvar = "",
           extra_args = list()) {
    child_labels <- match.arg(child_labels)
    ind <- length(lyt)
    if (ind == 0) stop("no split to add content rows at")
    spl <- lyt[[ind]]
    # if(is(spl, "AnalyzeVarSplit"))
    #     stop("can't add content rows to analyze variable split")
    tmp <- .add_row_summary(spl,
      label,
      cfun,
      child_labels = child_labels,
      cformat = cformat,
      cna_str = cna_str,
      indent_mod = indent_mod,
      cvar = cvar,
      extra_args = extra_args
    )
    lyt[[ind]] <- tmp
    lyt
  }
)

#' @rdname int_methods
setMethod(
  ".add_row_summary", "SplitVectorTree",
  function(lyt,
           label,
           cfun,
           child_labels = c("default", "visible", "hidden"),
           cformat = NULL,
           cna_str = "-",
           indent_mod = 0L,
           cvar = "",
           extra_args = list()) {
    len <- length(lyt)
    lyt[[len]] <- .add_row_summary(lyt[[len]],
      label = label,
      cfun = cfun,
      child_labels = child_labels,
      cformat = cformat,
      cna_str = cna_str,
      indent_mod = indent_mod,
      cvar = cvar,
      extra_args = extra_args
    )
    lyt
  }
)

#' @rdname int_methods
setMethod(
  ".add_row_summary", "Split",
  function(lyt,
           label,
           cfun,
           child_labels = c("default", "visible", "hidden"),
           cformat = NULL,
           cna_str = "-",
           indent_mod = 0L,
           cvar = "",
           extra_args = list()) {
    child_labels <- match.arg(child_labels)
    #   lbl_kids = .labelkids_helper(child_labels)
    content_fun(lyt) <- cfun
    content_indent_mod(lyt) <- indent_mod
    content_var(lyt) <- cvar
    ## obj_format(lyt) = cformat
    content_format(lyt) <- cformat
    if (!identical(child_labels, "default") && !identical(child_labels, label_kids(lyt))) {
      label_kids(lyt) <- child_labels
    }
    content_na_str <- cna_str
    content_extra_args(lyt) <- extra_args
    lyt
  }
)

.count_raw_constr <- function(var, format, label_fstr) {
  function(df, labelstr = "") {
    if (grepl("%s", label_fstr, fixed = TRUE)) {
      label <- sprintf(label_fstr, labelstr)
    } else {
      label <- label_fstr
    }
    if (is(df, "data.frame")) {
      if (!is.null(var) && nzchar(var)) {
        cnt <- sum(!is.na(df[[var]]))
      } else {
        cnt <- nrow(df)
      }
    } else { # df is the data column vector
      cnt <- sum(!is.na(df))
    }
    ret <- rcell(cnt,
      format = format,
      label = label,
      stat_names = "n"
    )
    ret
  }
}

.count_wpcts_constr <- function(var, format, label_fstr) {
  function(df, labelstr = "", .N_col) {
    if (grepl("%s", label_fstr, fixed = TRUE)) {
      label <- sprintf(label_fstr, labelstr)
    } else {
      label <- label_fstr
    }
    if (is(df, "data.frame")) {
      if (!is.null(var) && nzchar(var)) {
        cnt <- sum(!is.na(df[[var]]))
      } else {
        cnt <- nrow(df)
      }
    } else { # df is the data column vector
      cnt <- sum(!is.na(df))
    }
    ## the formatter does the *100 so we don't here.
    ## Elements are named with stat_names so that ARD generation has access to them
    ret <- rcell(c(cnt, cnt / .N_col),
      format = format,
      label = label,
      stat_names = c("n", "p")
    )
    ret
  }
}

.validate_cfuns <- function(fun) {
  if (is.list(fun)) {
    return(unlist(lapply(fun, .validate_cfuns)))
  }

  frmls <- formals(fun)
  ls_pos <- match("labelstr", names(frmls))
  if (is.na(ls_pos)) {
    stop("content functions must explicitly accept a 'labelstr' argument")
  }

  list(fun)
}

#' Analysis function to count levels of a factor with percentage of the column total
#'
#' @param x (`factor`)\cr a vector of data, provided by rtables pagination machinery.
#' @param .N_col (`integer(1)`)\cr total count for the column, provided by rtables pagination machinery.
#'
#' @return A `RowsVerticalSection` object with counts (and percents) for each level of the factor.
#'
#' @examples
#' counts_wpcts(DM$SEX, 400)
#'
#' @export
counts_wpcts <- function(x, .N_col) {
  if (!is.factor(x)) {
    stop(
      "using the 'counts_wpcts' analysis function requires factor data ",
      "to guarantee equal numbers of rows across all collumns, got class ",
      class(x), "."
    )
  }
  ret <- table(x)
  in_rows(.list = lapply(ret, function(y) rcell(y * c(1, 1 / .N_col), format = "xx (xx.x%)")))
}

#' Add a content row of summary counts
#'
#' @inheritParams lyt_args
#'
#' @inherit split_cols_by return
#'
#' @details
#' If `format` expects 1 value (i.e. it is specified as a format string and `xx` appears for two values
#' (i.e. `xx` appears twice in the format string) or is specified as a function, then both raw and percent of
#' column total counts are calculated. If `format` is a format string where `xx` appears only one time, only
#' raw counts are used.
#'
#' `cfun` must accept `x` or `df` as its first argument. For the `df` argument `cfun` will receive the subset
#' `data.frame` corresponding with the row- and column-splitting for the cell being calculated. Must accept
#' `labelstr` as the second parameter, which accepts the `label` of the level of the parent split currently
#' being summarized. Can additionally take any optional argument supported by analysis functions. (see [analyze()]).
#'
#' In addition, if complex custom functions are needed, we suggest checking the available [additional_fun_params]
#' that can be used in `cfun`.
#'
#' @examples
#' DM2 <- subset(DM, COUNTRY %in% c("USA", "CAN", "CHN"))
#'
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("COUNTRY", split_fun = drop_split_levels) |>
#'   summarize_row_groups(label_fstr = "%s (n)") |>
#'   analyze("AGE", afun = list_wrap_x(summary), format = "xx.xx")
#' lyt
#'
#' tbl <- build_table(lyt, DM2)
#' tbl
#'
#' row_paths_summary(tbl) # summary count is a content table
#'
#' ## use a cfun and extra_args to customize summarization
#' ## behavior
#' sfun <- function(x, labelstr, trim) {
#'   in_rows(
#'     c(mean(x, trim = trim), trim),
#'     .formats = "xx.x (xx.x%)",
#'     .labels = sprintf(
#'       "%s (Trimmed mean and trim %%)",
#'       labelstr
#'     )
#'   )
#' }
#'
#' lyt2 <- basic_table(show_colcounts = TRUE) |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("COUNTRY", split_fun = drop_split_levels) |>
#'   summarize_row_groups("AGE",
#'     cfun = sfun,
#'     extra_args = list(trim = .2)
#'   ) |>
#'   analyze("AGE", afun = list_wrap_x(summary), format = "xx.xx") |>
#'   append_topleft(c("Country", "  Age"))
#'
#' tbl2 <- build_table(lyt2, DM2)
#' tbl2
#'
#' @author Gabriel Becker
#' @export
summarize_row_groups <- function(lyt,
                                 var = "",
                                 label_fstr = "%s",
                                 format = "xx (xx.x%)",
                                 na_str = "-",
                                 cfun = NULL,
                                 indent_mod = 0L,
                                 extra_args = list()) {
  if (is.null(cfun)) {
    if (is.character(format) && length(gregexpr("xx(\\.x*){0,1}", format)[[1]]) == 1) {
      cfun <- .count_raw_constr(var, format, label_fstr)
    } else {
      cfun <- .count_wpcts_constr(var, format, label_fstr)
    }
  }
  cfun <- .validate_cfuns(cfun)
  .add_row_summary(lyt,
    cfun = cfun,
    cformat = format,
    cna_str = na_str,
    indent_mod = indent_mod,
    cvar = var,
    extra_args = extra_args
  )
}

#' Add the column population counts to the header
#'
#' Add the data derived column counts.
#'
#' @details It is often the case that the the column counts derived from the
#'   input data to [build_table()] is not representative of the population counts.
#'   For example, if events are counted in the table and the header should
#'   display the number of subjects and not the total number of events.
#'
#' @inheritParams lyt_args
#'
#' @inherit split_cols_by return
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   add_colcounts() |>
#'   split_rows_by("RACE", split_fun = drop_split_levels) |>
#'   analyze("AGE", afun = function(x) list(min = min(x), max = max(x)))
#' lyt
#'
#' tbl <- build_table(lyt, DM)
#' tbl
#'
#' @author Gabriel Becker
#' @export
add_colcounts <- function(lyt, format = "(N=xx)") {
  if (is.null(lyt)) {
    lyt <- PreDataTableLayouts()
  }
  disp_ccounts(lyt) <- TRUE
  colcount_format(lyt) <- format
  lyt
}

## Currently existing tables can ONLY be added as new entries at the top level, never at any level of nesting.
#' Add an already calculated table to the layout
#'
#' @inheritParams lyt_args
#' @inheritParams gen_args
#'
#' @inherit split_cols_by return
#'
#' @examples
#' lyt1 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   analyze("AGE", afun = mean, format = "xx.xx")
#'
#' tbl1 <- build_table(lyt1, DM)
#' tbl1
#'
#' lyt2 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   analyze("AGE", afun = sd, format = "xx.xx") |>
#'   add_existing_table(tbl1)
#'
#' tbl2 <- build_table(lyt2, DM)
#' tbl2
#'
#' table_structure(tbl2)
#' row_paths_summary(tbl2)
#'
#' @author Gabriel Becker
#' @export
add_existing_table <- function(lyt, tt, indent_mod = 0) {
  indent_mod(tt) <- indent_mod
  lyt <- split_rows(
    lyt,
    tt,
    next_rpos(lyt, nested = FALSE, at_sibling = NULL)
  )
  lyt
}

## takes_coln = function(f) {
##     stopifnot(is(f, "function"))
##     forms = names(formals(f))
##     res = ".N_col" %in% forms
##     res
## }

## takes_totn = function(f) {
##     stopifnot(is(f, "function"))
##     forms = names(formals(f))
##     res = ".N_total" %in% forms
##     res
## }

## use data to transform dynamic cuts to static cuts
#' @rdname int_methods
setGeneric("fix_dyncuts", function(spl, df) standardGeneric("fix_dyncuts"))

#' @rdname int_methods
setMethod("fix_dyncuts", "Split", function(spl, df) spl)

#' @rdname int_methods
setMethod(
  "fix_dyncuts", "VarDynCutSplit",
  function(spl, df) {
    var <- spl_payload(spl)
    varvec <- df[[var]]

    cfun <- spl_cutfun(spl)
    cuts <- cfun(varvec)
    cutlabels <- spl_cutlabelfun(spl)(cuts)
    if (length(cutlabels) != length(cuts) - 1 && !is.null(names(cuts))) {
      cutlabels <- names(cuts)[-1]
    }

    ret <- make_static_cut_split(
      var = var, split_label = obj_label(spl),
      cuts = cuts, cutlabels = cutlabels,
      cumulative = spl_is_cmlcuts(spl)
    )
    ## ret = VarStaticCutSplit(var = var, split_label = obj_label(spl),
    ##                   cuts = cuts, cutlabels = cutlabels)
    ## ## classes are tthe same structurally CumulativeCutSplit
    ## ## is just a sentinal so it can hit different make_subset_expr
    ## ## method
    ## if(spl_is_cmlcuts(spl))
    ##     ret = as(ret, "CumulativeCutSplit")
    ret
  }
)

#' @rdname int_methods
setMethod(
  "fix_dyncuts", "VTableTree",
  function(spl, df) spl
)

.fd_helper <- function(spl, df) {
  lst <- lapply(spl, fix_dyncuts, df = df)
  spl@.Data <- lst
  spl
}

#' @rdname int_methods
setMethod(
  "fix_dyncuts", "PreDataRowLayout",
  function(spl, df) {
    #   rt = root_spl(spl)
    ret <- .fd_helper(spl, df)
    #    root_spl(ret) = rt
    ret
  }
)

#' @rdname int_methods
setMethod(
  "fix_dyncuts", "PreDataColLayout",
  function(spl, df) {
    #   rt = root_spl(spl)
    ret <- .fd_helper(spl, df)
    #   root_spl(ret) = rt
    #   disp_ccounts(ret) = disp_ccounts(spl)
    #   colcount_format(ret) = colcount_format(spl)
    ret
  }
)

#' @rdname int_methods
setMethod(
  "fix_dyncuts", "SplitVector",
  function(spl, df) {
    .fd_helper(spl, df)
  }
)

#' @rdname int_methods
setMethod(
  "fix_dyncuts", "SplitVectorTree",
  function(spl, df) {
    .fd_helper(spl, df)
  }
)

#' @rdname int_methods
setMethod(
  "fix_dyncuts", "PreDataTableLayouts",
  function(spl, df) {
    rlayout(spl) <- fix_dyncuts(rlayout(spl), df)
    clayout(spl) <- fix_dyncuts(clayout(spl), df)
    spl
  }
)

## Manual column construction in a simple (seeming to the user) way.
#' Manual column declaration
#'
#' @param ... one or more vectors of levels to appear in the column space. If more than one set of levels is given,
#'   the values of the second are nested within each value of the first, and so on.
#' @param .lst (`list`)\cr a list of sets of levels, by default populated via `list(...)`.
#' @param ccount_format (`FormatSpec`)\cr the format to use when counts are displayed.
#'
#' @return An `InstantiatedColumnInfo` object, suitable for declaring the column structure for a manually constructed
#'   table.
#'
#' @examples
#' # simple one level column space
#' rows <- lapply(1:5, function(i) {
#'   DataRow(rep(i, times = 3))
#' })
#' tbl <- TableTree(kids = rows, cinfo = manual_cols(split = c("a", "b", "c")))
#' tbl
#'
#' # manually declared nesting
#' tbl2 <- TableTree(
#'   kids = list(DataRow(as.list(1:4))),
#'   cinfo = manual_cols(
#'     Arm = c("Arm A", "Arm B"),
#'     Gender = c("M", "F")
#'   )
#' )
#' tbl2
#'
#' @author Gabriel Becker
#' @export
manual_cols <- function(..., .lst = list(...), ccount_format = NULL) {
  if (is.null(names(.lst))) {
    names(.lst) <- paste("colsplit", seq_along(.lst))
  }

  splvec <- SplitVector(lst = mapply(ManualSplit,
    levels = .lst,
    label = names(.lst)
  ))
  ctree <- splitvec_to_coltree(data.frame(), splvec = splvec, pos = TreePos(), global_cc_format = ccount_format)

  ret <- InstantiatedColumnInfo(treelyt = ctree)
  rm_all_colcounts(ret)
}


#' Set all column counts at all levels of nesting to NA
#'
#' @inheritParams gen_args
#'
#' @return `obj` with all column counts reset to missing
#'
#' @export
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by("SEX") |>
#'   analyze("AGE")
#' tbl <- build_table(lyt, ex_adsl)
#'
#' # before
#' col_counts(tbl)
#' tbl <- rm_all_colcounts(tbl)
#' col_counts(tbl)
setGeneric("rm_all_colcounts", function(obj) standardGeneric("rm_all_colcounts"))

#' @rdname rm_all_colcounts
#' @export
setMethod(
  "rm_all_colcounts", "VTableTree",
  function(obj) {
    cinfo <- col_info(obj)
    cinfo <- rm_all_colcounts(cinfo)
    col_info(obj) <- cinfo
    obj
  }
)

#' @rdname rm_all_colcounts
#' @export
setMethod(
  "rm_all_colcounts", "InstantiatedColumnInfo",
  function(obj) {
    ctree <- coltree(obj)
    ctree <- rm_all_colcounts(ctree)
    coltree(obj) <- ctree
    obj
  }
)

#' @rdname rm_all_colcounts
#' @export
setMethod(
  "rm_all_colcounts", "LayoutColTree",
  function(obj) {
    obj@column_count <- NA_integer_
    tree_children(obj) <- lapply(tree_children(obj), rm_all_colcounts)
    obj
  }
)

#' @rdname rm_all_colcounts
#' @export
setMethod(
  "rm_all_colcounts", "LayoutColLeaf",
  function(obj) {
    obj@column_count <- NA_integer_
    obj
  }
)

#' Returns a function that coerces the return values of a function to a list
#'
#' @param f (`function`)\cr the function to wrap.
#'
#' @details
#' `list_wrap_x` generates a wrapper which takes `x` as its first argument, while `list_wrap_df` generates an
#' otherwise identical wrapper function whose first argument is named `df`.
#'
#' We provide both because when using the functions as tabulation in [analyze()], functions which take `df` as
#' their first argument are passed the full subset data frame, while those which accept anything else notably
#' including `x` are passed only the relevant subset of the variable being analyzed.
#'
#' @return A function that returns a list of `CellValue` objects.
#'
#' @examples
#' summary(iris$Sepal.Length)
#'
#' f <- list_wrap_x(summary)
#' f(x = iris$Sepal.Length)
#'
#' f2 <- list_wrap_df(summary)
#' f2(df = iris$Sepal.Length)
#'
#' @author Gabriel Becker
#' @rdname list_wrap
#' @export
list_wrap_x <- function(f) {
  function(x, ...) {
    vs <- as.list(f(x, ...))
    ret <- mapply(
      function(v, nm) {
        rcell(v, label = nm)
      },
      v = vs,
      nm = names(vs)
    )
    ret
  }
}

#' @rdname list_wrap
#' @export
list_wrap_df <- function(f) {
  function(df, ...) {
    vs <- as.list(f(df, ...))
    ret <- mapply(
      function(v, nm) {
        rcell(v, label = nm)
      },
      v = vs,
      nm = names(vs)
    )
    ret
  }
}

#' Layout with 1 column and zero rows
#'
#' Every layout must start with a basic table.
#'
#' @inheritParams constr_args
#' @inheritParams gen_args
#' @param show_colcounts (`logical(1)`)\cr Indicates whether the lowest level of
#'   applied to data. `NA`, the default, indicates that the `show_colcounts`
#'   argument(s) passed to the relevant calls to `split_cols_by*`
#'   functions. Non-missing values will override the behavior specified in
#'   column splitting layout instructions which create the lowest level, or
#'   leaf, columns.
#' @param colcount_format (`string`)\cr format for use when displaying the column counts. Must be 1d, or 2d
#'   where one component is a percent. This will also apply to any displayed higher
#'   level column counts where an explicit format was not specified. Defaults to `"(N=xx)"`. See Details below.
#' @param top_level_section_div (`character(1)`)\cr if assigned a single character, the first (top level) split
#'   or division of the table will be highlighted by a line made of that character. See [section_div] for more
#'   information.
#'
#' @details
#' `colcount_format` is ignored if `show_colcounts` is `FALSE` (the default). When `show_colcounts` is `TRUE`,
#' and `colcount_format` is 2-dimensional with a percent component, the value component for the percent is always
#' populated with `1` (i.e. 100%). 1d formats are used to render the counts exactly as they normally would be,
#' while 2d formats which don't include a percent, and all 3d formats result in an error. Formats in the form of
#' functions are not supported for `colcount` format. See [formatters::list_valid_format_labels()] for the list
#' of valid format labels to select from.
#'
#' @inherit split_cols_by return
#'
#' @note
#' - Because percent components in `colcount_format` are *always* populated with the value 1, we can get arguably
#'   strange results, such as that individual arm columns and a combined "all patients" column all list "100%" as
#'   their percentage, even though the individual arm columns represent strict subsets of the "all patients" column.
#'
#' - Note that subtitles ([formatters::subtitles()]) and footers ([formatters::main_footer()] and
#' [formatters::prov_footer()]) that span more than one line can be supplied as a character vector to maintain
#' indentation on multiple lines.
#'
#' @examples
#' lyt <- basic_table() |>
#'   analyze("AGE", afun = mean)
#'
#' tbl <- build_table(lyt, DM)
#' tbl
#'
#' lyt2 <- basic_table(
#'   title = "Title of table",
#'   subtitles = c("a number", "of subtitles"),
#'   main_footer = "test footer",
#'   prov_footer = paste(
#'     "test.R program, executed at",
#'     Sys.time()
#'   )
#' ) |>
#'   split_cols_by("ARM") |>
#'   analyze("AGE", mean)
#'
#' tbl2 <- build_table(lyt2, DM)
#' tbl2
#'
#' lyt3 <- basic_table(
#'   show_colcounts = TRUE,
#'   colcount_format = "xx. (xx.%)"
#' ) |>
#'   split_cols_by("ARM")
#'
#' @export
basic_table <- function(title = "",
                        subtitles = character(),
                        main_footer = character(),
                        prov_footer = character(),
                        show_colcounts = NA, # FALSE,
                        colcount_format = "(N=xx)",
                        header_section_div = NA_character_,
                        top_level_section_div = NA_character_,
                        inset = 0L,
                        round_type = valid_round_type) {
  round_type <- match.arg(round_type)
  inset <- as.integer(inset)
  if (is.na(inset) || inset < 0L) {
    stop("Got invalid table_inset value, must be an integer > 0")
  }
  .check_header_section_div(header_section_div)
  checkmate::assert_character(top_level_section_div, len = 1, n.chars = 1)

  ret <- PreDataTableLayouts(
    title = title,
    subtitles = subtitles,
    main_footer = main_footer,
    prov_footer = prov_footer,
    header_section_div = header_section_div,
    top_level_section_div = top_level_section_div,
    table_inset = as.integer(inset),
    round_type = round_type
  )

  ## unconditional now, NA case is handled in cinfo construction
  disp_ccounts(ret) <- show_colcounts
  colcount_format(ret) <- colcount_format
  ## if (isTRUE(show_colcounts)) {
  ##   ret <- add_colcounts(ret, format = colcount_format)
  ## }
  ret
}

#' Append a description to the 'top-left' materials for the layout
#'
#' This function *adds* `newlines` to the current set of "top-left materials".
#'
#' @details
#' Adds `newlines` to the set of strings representing the 'top-left' materials declared in the layout (the content
#' displayed to the left of the column labels when the resulting tables are printed).
#'
#' Top-left material strings are stored and then displayed *exactly as is*, no structure or indenting is applied to
#' them either when they are added or when they are displayed.
#'
#' @inheritParams lyt_args
#' @param newlines (`character`)\cr the new line(s) to be added to the materials.
#'
#' @note
#' Currently, where in the construction of the layout this is called makes no difference, as it is independent of
#' the actual splitting keywords. This may change in the future.
#'
#' This function is experimental, its name and the details of its behavior are subject to change in future versions.
#'
#' @inherit split_cols_by return
#'
#' @seealso [top_left()]
#'
#' @examplesIf require(dplyr)
#' library(dplyr)
#'
#' DM2 <- DM |> mutate(RACE = factor(RACE), SEX = factor(SEX))
#'
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by("SEX") |>
#'   split_rows_by("RACE") |>
#'   append_topleft("Ethnicity") |>
#'   analyze("AGE") |>
#'   append_topleft("  Age")
#'
#' tbl <- build_table(lyt, DM2)
#' tbl
#'
#' @export
append_topleft <- function(lyt, newlines) {
  stopifnot(
    is(lyt, "PreDataTableLayouts"),
    is(newlines, "character")
  )
  lyt@top_left <- c(lyt@top_left, newlines)
  lyt
}
