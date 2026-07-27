# Generics and how they are used directly -------------------------------------

## check_validsplit - Check if the split is valid for the data, error if not

## .apply_spl_extras - Generate Extras

## .apply_spl_datapart - generate data partition

## .apply_spl_rawvals - Generate raw (i.e. non SplitValue object) partition values

setGeneric(
  ".applysplit_rawvals",
  function(spl, df) standardGeneric(".applysplit_rawvals")
)

setGeneric(
  ".applysplit_datapart",
  function(spl, df, vals) standardGeneric(".applysplit_datapart")
)

setGeneric(
  ".applysplit_extras",
  function(spl, df, vals) standardGeneric(".applysplit_extras")
)

setGeneric(
  ".applysplit_partlabels",
  function(spl, df, vals, labels) standardGeneric(".applysplit_partlabels")
)

setGeneric(
  "check_validsplit",
  function(spl, df) standardGeneric("check_validsplit")
)

setGeneric(
  ".applysplit_ref_vals",
  function(spl, df, vals) standardGeneric(".applysplit_ref_vals")
)
# Custom split fncs ------------------------------------------------------------
#' Custom split functions
#'
#' Split functions provide the work-horse for `rtables`'s generalized partitioning. These functions accept a (sub)set
#' of incoming data and a split object, and return "splits" of that data.
#'
#' @section Custom Splitting Function Details:
#'
#' User-defined custom split functions can perform any type of computation on the incoming data provided that they
#' meet the requirements for generating "splits" of the incoming data based on the split object.
#'
#' Split functions are functions that accept:
#'   \describe{
#'     \item{df}{a `data.frame` of incoming data to be split.}
#'     \item{spl}{a Split object. This is largely an internal detail custom functions will not need to worry about,
#'       but `obj_name(spl)`, for example, will give the name of the split as it will appear in paths in the resulting
#'       table.}
#'     \item{vals}{any pre-calculated values. If given non-`NULL` values, the values returned should match these.
#'       Should be `NULL` in most cases and can usually be ignored.}
#'     \item{labels}{any pre-calculated value labels. Same as above for `values`.}
#'     \item{trim}{if `TRUE`, resulting splits that are empty are removed.}
#'     \item{(optional) .spl_context}{a `data.frame` describing previously performed splits which collectively
#'       arrived at `df`.}
#'   }
#'
#' The function must then output a named `list` with the following elements:
#'
#'   \describe{
#'     \item{values}{the vector of all values corresponding to the splits of `df`.}
#'     \item{datasplit}{a list of `data.frame`s representing the groupings of the actual observations from `df`.}
#'     \item{labels}{a character vector giving a string label for each value listed in the `values` element above.}
#'     \item{(optional) extras}{if present, extra arguments are to be passed to summary and analysis functions
#'       whenever they are executed on the corresponding element of `datasplit` or a subset thereof.}
#'   }
#'
#' One way to generate custom splitting functions is to wrap existing split functions and modify either the incoming
#' data before they are called or their outputs.
#'
#' @seealso [make_split_fun()] for the API for creating custom split functions, and [split_funcs] for a variety of
#'   pre-defined split functions.
#'
#' @examples
#' # Example of a picky split function. The number of values in the column variable
#' # var decrees if we are going to print also the column with all observation
#' # or not.
#'
#' picky_splitter <- function(var) {
#'   # Main layout function
#'   function(df, spl, vals, labels, trim) {
#'     orig_vals <- vals
#'
#'     # Check for number of levels if all are selected
#'     if (is.null(vals)) {
#'       vec <- df[[var]]
#'       vals <- unique(vec)
#'     }
#'
#'     # Do a split with or without All obs
#'     if (length(vals) == 1) {
#'       do_base_split(spl = spl, df = df, vals = vals, labels = labels, trim = trim)
#'     } else {
#'       fnc_tmp <- add_overall_level("Overall", label = "All Obs", first = FALSE)
#'       fnc_tmp(df = df, spl = spl, vals = orig_vals, trim = trim)
#'     }
#'   }
#' }
#'
#' # Data sub-set
#' d1 <- subset(ex_adsl, ARM == "A: Drug X" | (ARM == "B: Placebo" & SEX == "F"))
#' d1 <- subset(d1, SEX %in% c("M", "F"))
#' d1$SEX <- factor(d1$SEX)
#'
#' # This table uses the number of values in the SEX column to add the overall col or not
#' lyt <- basic_table() |>
#'   split_cols_by("ARM", split_fun = drop_split_levels) |>
#'   split_cols_by("SEX", split_fun = picky_splitter("SEX")) |>
#'   analyze("AGE", show_labels = "visible")
#' tbl <- build_table(lyt, d1)
#' tbl
#'
#' @name custom_split_funs
NULL

## do various cleaning, and naming, plus
## ensure partinfo$values contains SplitValue objects only
.fixupvals <- function(partinfo) {
  if (is.factor(partinfo$labels)) {
    partinfo$labels <- as.character(partinfo$labels)
  }

  vals <- partinfo$values
  if (is.factor(vals)) {
    vals <- levels(vals)[vals]
  }
  extr <- partinfo$extras
  dpart <- partinfo$datasplit
  labels <- partinfo$labels
  if (is.null(labels)) {
    if (!is.null(names(vals))) {
      labels <- names(vals)
    } else if (!is.null(names(dpart))) {
      labels <- names(dpart)
    } else if (!is.null(names(extr))) {
      labels <- names(extr)
    }
  }

  subsets <- partinfo$subset_exprs
  if (is.null(subsets)) {
    subsets <- vector(mode = "list", length = length(vals))
    ## use labels here cause we already did all that work
    ## to get the names on the labels vector right
    names(subsets) <- names(labels)
  }

  if (is.null(vals) && !is.null(extr)) {
    vals <- seq_along(extr)
  }

  if (length(vals) == 0) {
    stopifnot(length(extr) == 0)
    return(partinfo)
  }
  ## length(vals) > 0 from here down

  if (are(vals, "SplitValue") && !are(vals, "LevelComboSplitValue")) {
    if (!is.null(extr)) {
      ## in_ref_cols is in here for some reason even though its already in the SplitValue object.
      ## https://github.com/pharmaverse/rtables/issues/707#issuecomment-1678810598
      ## the if is a bandaid.
      ## XXX FIXME RIGHT
      sq <- seq_along(vals)
      if (any(vapply(sq, function(i) !all(names(extr[[i]]) %in% names(splv_extra(vals[[i]]))), TRUE))) {
        warning(
          "Got a partinfo list with values that are ",
          "already SplitValue objects and non-null extras ",
          "element. This shouldn't happen"
        )
      }
    }
  } else {
    if (is.null(extr)) {
      extr <- rep(list(list()), length(vals))
    }
    vals <- make_splvalue_vec(vals, extr, labels = labels, subset_exprs = subsets)
  }
  ## we're done with this so take it off
  partinfo$extras <- NULL

  vnames <- value_names(vals)
  names(vals) <- vnames
  partinfo$values <- vals

  if (!identical(names(dpart), vnames)) {
    names(dpart) <- vnames
    partinfo$datasplit <- dpart
  }

  partinfo$labels <- labels

  stopifnot(length(unique(sapply(partinfo, NROW))) == 1)
  partinfo
}

.add_ref_extras <- function(spl, df, partinfo) {
  ## this is only the .in_ref_col booleans
  refvals <- .applysplit_ref_vals(spl, df, partinfo$values)
  ref_ind <- which(unlist(refvals))
  stopifnot(length(ref_ind) == 1)

  vnames <- value_names(partinfo$values)
  if (is.null(partinfo$extras)) {
    names(refvals) <- vnames
    partinfo$extras <- refvals
  } else {
    newextras <- mapply(
      function(old, incol, ref_full) {
        c(old, list(
          .in_ref_col = incol,
          .ref_full = ref_full
        ))
      },
      old = partinfo$extras,
      incol = unlist(refvals),
      MoreArgs = list(ref_full = partinfo$datasplit[[ref_ind]]),
      SIMPLIFY = FALSE
    )
    names(newextras) <- vnames
    partinfo$extras <- newextras
  }
  partinfo
}

#' Apply basic split (for use in custom split functions)
#'
#' This function is intended for use inside custom split functions. It applies the current split *as if it had no
#' custom splitting function* so that those default splits can be further manipulated.
#'
#' @inheritParams gen_args
#' @param vals (`ANY`)\cr already calculated/known values of the split. Generally should be left as `NULL`.
#' @param labels (`character`)\cr labels associated with `vals`. Should be `NULL` whenever `vals` is, which should
#'   almost always be the case.
#' @param trim (`flag`)\cr whether groups corresponding to empty data subsets should be removed. Defaults to
#'   `FALSE`.
#'
#' @return The result of the split being applied as if it had no custom split function. See [custom_split_funs].
#'
#' @examples
#' uneven_splfun <- function(df, spl, vals = NULL, labels = NULL, trim = FALSE) {
#'   ret <- do_base_split(spl, df, vals, labels, trim)
#'   if (NROW(df) == 0) {
#'     ret <- lapply(ret, function(x) x[1])
#'   }
#'   ret
#' }
#'
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by_multivar(c("USUBJID", "AESEQ", "BMRKR1"),
#'     varlabels = c("N", "E", "BMR1"),
#'     split_fun = uneven_splfun
#'   ) |>
#'   analyze_colvars(list(
#'     USUBJID = function(x, ...) length(unique(x)),
#'     AESEQ = max,
#'     BMRKR1 = mean
#'   ))
#'
#' tbl <- build_table(lyt, subset(ex_adae, as.numeric(ARM) <= 2))
#' tbl
#'
#' @export
do_base_split <- function(spl, df, vals = NULL, labels = NULL, trim = FALSE) {
  spl2 <- spl
  split_fun(spl2) <- NULL
  do_split(spl2,
    df = df, vals = vals, labels = labels, trim = trim,
    spl_context = NULL
  )
}

### NB This is called at EACH level of recursive splitting
do_split <- function(spl,
                     df,
                     vals = NULL,
                     labels = NULL,
                     trim = FALSE,
                     spl_context) {
  ## this will error if, e.g., df doesn't have columns
  ## required by spl, or generally any time the spl
  ## can't be applied to df
  check_validsplit(spl, df)
  ## note the <- here!!!
  if (!is.null(splfun <- split_fun(spl))) {
    ## Currently the contract is that split_functions take df, vals, labels and
    ## return list(values=., datasplit=., labels = .), optionally with
    ## an additional extras element
    if (func_takes(splfun, ".spl_context")) {
      ret <- tryCatch(
        splfun(df, spl, vals, labels,
          trim = trim,
          .spl_context = spl_context
        ),
        error = function(e) e
      ) ## rawvalues(spl_context ))
    } else {
      ret <- tryCatch(splfun(df, spl, vals, labels, trim = trim),
        error = function(e) e
      )
    }
    if (is(ret, "error")) {
      stop(
        "Error applying custom split function: ", ret$message, "\n\tsplit: ",
        class(spl), " (", payloadmsg(spl), ")\n",
        "\toccured at path: ",
        spl_context_to_disp_path(spl_context), "\n"
      )
    }
  } else {
    ret <- .apply_split_inner(df = df, spl = spl, vals = vals, labels = labels, trim = trim)
  }

  ## this adds .ref_full and .in_ref_col
  if (is(spl, "VarLevWBaselineSplit")) {
    ret <- .add_ref_extras(spl, df, ret)
  }

  ## this:
  ## - guarantees that ret$values contains SplitValue objects
  ## - removes the extras element since its redundant after the above
  ## - Ensures datasplit and values lists are named according to labels
  ## - ensures labels are character not factor
  ret <- .fixupvals(ret)
  ## we didn't put this in .fixupvals because that get called withint he split functions
  ## created by make_split_fun and its not clear this check should be happening then.
  if (has_force_pag(spl) && length(ret$datasplit) == 0) { ## this means it's page_by=TRUE
    stop(
      "Page-by split resulted in zero pages (no observed values of split variable?). \n\tsplit: ",
      class(spl), " (", payloadmsg(spl), ")\n",
      "\toccured at path: ",
      spl_context_to_disp_path(spl_context), "\n"
    )
  }
  ret
}

.apply_split_inner <- function(spl, df, vals = NULL, labels = NULL, trim = FALSE) {
  if (is.null(vals)) {
    vals <- .applysplit_rawvals(spl, df)
  }
  extr <- .applysplit_extras(spl, df, vals)

  if (is.null(vals)) {
    return(list(
      values = list(),
      datasplit = list(),
      labels = list(),
      extras = list()
    ))
  }

  dpart <- .applysplit_datapart(spl, df, vals)

  if (is.null(labels)) {
    labels <- .applysplit_partlabels(spl, df, vals, labels)
  } else {
    stopifnot(names(labels) == names(vals))
  }
  ## get rid of columns that would not have any
  ## observations.
  ##
  ## But only if there were any rows to start with
  ## if not we're in a manually constructed table
  ## column tree
  if (trim) {
    hasdata <- sapply(dpart, function(x) nrow(x) > 0)
    if (nrow(df) > 0 && length(dpart) > sum(hasdata)) { # some empties
      dpart <- dpart[hasdata]
      vals <- vals[hasdata]
      extr <- extr[hasdata]
      labels <- labels[hasdata]
    }
  }

  if (is.null(spl_child_order(spl)) || is(spl, "AllSplit")) {
    vord <- seq_along(vals)
  } else {
    vord <- match(
      spl_child_order(spl),
      vals
    )
    vord <- vord[!is.na(vord)]
  }

  ## FIXME: should be an S4 object, not a list
  ret <- list(
    values = vals[vord],
    datasplit = dpart[vord],
    labels = labels[vord],
    extras = extr[vord]
  )
  ret
}

.checkvarsok <- function(spl, df) {
  vars <- spl_payload(spl)
  ## could be multiple vars in the future?
  ## no reason not to make that work here now.
  if (!all(vars %in% names(df))) {
    stop(
      " variable(s) [",
      paste(setdiff(vars, names(df)),
        collapse = ", "
      ),
      "] not present in data. (",
      class(spl), ")"
    )
  }
  invisible(NULL)
}

### Methods to verify a split appears to be valid, applicable
### to the ***current subset*** of the df.
###
### This is called at each level of recursive splitting so
### do NOT make it check, e.g., if the ref_group level of
### a factor is present in the data, because it may not be.

setMethod(
  "check_validsplit", "VarLevelSplit",
  function(spl, df) {
    .checkvarsok(spl, df)
  }
)

setMethod(
  "check_validsplit", "MultiVarSplit",
  function(spl, df) {
    .checkvarsok(spl, df)
  }
)

setMethod(
  "check_validsplit", "VAnalyzeSplit",
  function(spl, df) {
    if (!is.na(spl_payload(spl))) {
      .checkvarsok(spl, df)
    } else {
      TRUE
    }
  }
)

setMethod(
  "check_validsplit", "CompoundSplit",
  function(spl, df) {
    all(sapply(spl_payload(spl), df))
  }
)

## default does nothing, add methods as they become
## required
setMethod(
  "check_validsplit", "Split",
  function(spl, df) invisible(NULL)
)

setMethod(
  ".applysplit_rawvals", "VarLevelSplit",
  function(spl, df) {
    varvec <- df[[spl_payload(spl)]]
    if (is.factor(varvec)) {
      levels(varvec)
    } else {
      unique(varvec)
    }
  }
)

setMethod(
  ".applysplit_rawvals", "MultiVarSplit",
  function(spl, df) {
    ##    spl_payload(spl)
    spl_varnames(spl)
  }
)

setMethod(
  ".applysplit_rawvals", "AllSplit",
  function(spl, df) obj_name(spl)
) # "all obs")

setMethod(
  ".applysplit_rawvals", "ManualSplit",
  function(spl, df) spl@levels
)

## setMethod(".applysplit_rawvals", "NULLSplit",
##           function(spl, df) "")

setMethod(
  ".applysplit_rawvals", "VAnalyzeSplit",
  function(spl, df) spl_payload(spl)
)

## formfactor here is gross we're gonna have ot do this
## all again in tthe data split part :-/
setMethod(
  ".applysplit_rawvals", "VarStaticCutSplit",
  function(spl, df) {
    spl_cutlabels(spl)
  }
)

setMethod(
  ".applysplit_datapart", "VarLevelSplit",
  function(spl, df, vals) {
    if (!(spl_payload(spl) %in% names(df))) {
      stop(
        "Attempted to split on values of column (", spl_payload(spl),
        ") not present in the data"
      )
    }
    ret <- lapply(seq_along(vals), function(i) {
      spl_col <- df[[spl_payload(spl)]]
      df[!is.na(spl_col) & spl_col == vals[[i]], ]
    })
    names(ret) <- as.character(vals)
    ret
  }
)

setMethod(
  ".applysplit_datapart", "MultiVarSplit",
  function(spl, df, vals) {
    allvnms <- spl_varnames(spl)
    if (!is.null(vals) && !identical(allvnms, vals)) {
      incl <- match(vals, allvnms)
    } else {
      incl <- seq_along(allvnms)
    }
    vars <- spl_payload(spl)[incl]
    ## don't remove  nas
    ## ret = lapply(vars, function(cl) {
    ##     df[!is.na(df[[cl]]),]
    ## })
    ret <- rep(list(df), length(vars))
    names(ret) <- vals
    ret
  }
)

setMethod(
  ".applysplit_datapart", "AllSplit",
  function(spl, df, vals) list(df)
)

## ## not sure I need this
setMethod(
  ".applysplit_datapart", "ManualSplit",
  function(spl, df, vals) rep(list(df), times = length(vals))
)

## setMethod(".applysplit_datapart", "NULLSplit",
##           function(spl, df, vals) list(df[FALSE,]))

setMethod(
  ".applysplit_datapart", "VarStaticCutSplit",
  function(spl, df, vals) {
    #  lbs = spl_cutlabels(spl)
    var <- spl_payload(spl)
    varvec <- df[[var]]
    cts <- spl_cuts(spl)
    cfct <- cut(varvec, cts, include.lowest = TRUE) # , labels = lbs)
    split(df, cfct, drop = FALSE)
  }
)

setMethod(
  ".applysplit_datapart", "CumulativeCutSplit",
  function(spl, df, vals) {
    #  lbs = spl_cutlabels(spl)
    var <- spl_payload(spl)
    varvec <- df[[var]]
    cts <- spl_cuts(spl)
    cfct <- cut(varvec, cts, include.lowest = TRUE) # , labels = lbs)
    ret <- lapply(
      seq_along(levels(cfct)),
      function(i) df[as.integer(cfct) <= i, ]
    )
    names(ret) <- levels(cfct)
    ret
  }
)

## XXX TODO *CutSplit Methods

setClass("NullSentinel", contains = "NULL")
nullsentinel <- new("NullSentinel")
noarg <- function() nullsentinel

## Extras generation methods
setMethod(
  ".applysplit_extras", "Split",
  function(spl, df, vals) {
    splex <- split_exargs(spl)
    nvals <- length(vals)
    lapply(seq_len(nvals), function(vpos) {
      one_ex <- lapply(splex, function(arg) {
        if (length(arg) >= vpos) {
          arg[[vpos]]
        } else {
          noarg()
        }
      })
      names(one_ex) <- names(splex)
      one_ex <- one_ex[!sapply(one_ex, is, "NullSentinel")]
      one_ex
    })
  }
)

setMethod(
  ".applysplit_ref_vals", "Split",
  function(spl, df, vals) rep(list(NULL), length(vals))
)

setMethod(
  ".applysplit_ref_vals", "VarLevWBaselineSplit",
  function(spl, df, vals) {
    bl_level <- spl@ref_group_value # XXX XXX
    vnames <- value_names(vals)
    ret <- lapply(vnames, function(vl) {
      list(.in_ref_col = vl == bl_level)
    })
    names(ret) <- vnames
    ret
  }
)

## XXX TODO FIXME
setMethod(
  ".applysplit_partlabels", "Split",
  function(spl, df, vals, labels) as.character(vals)
)

setMethod(
  ".applysplit_partlabels", "VarLevelSplit",
  function(spl, df, vals, labels) {
    varname <- spl_payload(spl)
    vlabelname <- spl_labelvar(spl)
    varvec <- df[[varname]]
    ## we used to check if vals was NULL but
    ## this is called after a short-circuit return in .apply_split_inner in that
    ## case
    ## so vals is guaranteed to be non-null here
    if (is.null(labels)) {
      if (varname == vlabelname) {
        labels <- vals
      } else {
        labfact <- is.factor(df[[vlabelname]])
        lablevs <- if (labfact) levels(df[[vlabelname]]) else NULL
        labels <- sapply(vals, function(v) {
          vlabel <- unique(df[varvec == v, vlabelname, drop = TRUE])
          ## TODO remove this once 1-to-1 value-label map is enforced
          ## elsewhere.
          stopifnot(length(vlabel) < 2)
          if (length(vlabel) == 0) {
            vlabel <- ""
          } else if (labfact) {
            vlabel <- lablevs[vlabel]
          }
          vlabel
        })
      }
    }
    names(labels) <- as.character(vals)
    labels
  }
)

setMethod(
  ".applysplit_partlabels", "MultiVarSplit",
  function(spl, df, vals, labels) value_labels(spl)
)

make_splvalue_vec <- function(vals, extrs = list(list()), labels = vals,
                              subset_exprs) {
  if (length(vals) == 0) {
    return(vals)
  }

  if (is(extrs, "AsIs")) {
    extrs <- unclass(extrs)
  }
  ## if(are(vals, "SplitValue")) {

  ##     return(vals)
  ## }

  mapply(SplitValue,
    val = vals, extr = extrs,
    label = labels,
    sub_expr = subset_exprs,
    SIMPLIFY = FALSE
  )
}
