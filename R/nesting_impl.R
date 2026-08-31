#' @param for_analyze (`flag`) whether split is an analyze split.
#' @rdname int_methods
setGeneric(
  "next_rpos",
  function(obj, nested = TRUE, for_analyze = FALSE, at_sibling = NULL) standardGeneric("next_rpos")
)

#' @rdname int_methods
setMethod(
  "next_rpos", "PreDataTableLayouts",
  function(obj, nested, for_analyze = FALSE, at_sibling = NULL) {
    next_rpos(rlayout(obj), nested, for_analyze = for_analyze, at_sibling = at_sibling)
  }
)

.check_if_nest <- function(obj, nested, for_analyze, at_sibling) {
  if (!nested) {
    FALSE
  } else {
    ## can always nest analyze splits (almost? what about colvars noncolvars mixing? prolly ok?)
    for_analyze || !is.null(at_sibling) ||
      ## If its not an analyze split it can't go under an analyze split
      !(is(last_rowsplit(obj), "VAnalyzeSplit") ||
        is(last_rowsplit(obj), "AnalyzeMultiVars")) ## should this be CompoundSplit? # nolint
  }
}

#' @rdname int_methods
setMethod(
  "next_rpos", "PreDataRowLayout",
  function(obj, nested, for_analyze, at_sibling = NULL) {
    l <- length(obj)
    if (length(obj[[l]]) > 0L && !.check_if_nest(obj, nested, for_analyze, at_sibling = at_sibling)) {
      l <- l + 1L
    }
    l
  }
)

#' @rdname int_methods
setMethod("next_rpos", "ANY", function(obj, nested) 1L)

#' @rdname int_methods
setGeneric("next_cpos", function(obj, nested = TRUE) standardGeneric("next_cpos"))

#' @rdname int_methods
setMethod(
  "next_cpos", "PreDataTableLayouts",
  function(obj, nested) next_cpos(clayout(obj), nested)
)

#' @rdname int_methods
setMethod(
  "next_cpos", "PreDataColLayout",
  function(obj, nested) {
    if (nested || length(obj[[length(obj)]]) == 0) {
      length(obj)
    } else {
      length(obj) + 1L
    }
  }
)

#' @rdname int_methods
setMethod("next_cpos", "ANY", function(obj, nested) 1L)

#' @rdname int_methods
setGeneric("last_rowsplit", function(obj) standardGeneric("last_rowsplit"))

#' @rdname int_methods
setMethod(
  "last_rowsplit", "NULL",
  function(obj) NULL
)

#' @rdname int_methods
setMethod(
  "last_rowsplit", "SplitVector",
  function(obj) {
    if (length(obj) == 0) {
      NULL
    } else {
      last_rowsplit(obj[[length(obj)]])
    }
  }
)

setMethod(
  "last_rowsplit", "Split",
  function(obj) obj
)


#' @rdname int_methods
setMethod(
  "last_rowsplit", "SplitVectorTree",
  function(obj) {
    if (length(obj) == 0) {
      NULL
    } else {
      last_rowsplit(obj[[length(obj)]])
    }
  }
)


#' @rdname int_methods
setMethod(
  "last_rowsplit", "PreDataRowLayout",
  function(obj) {
    if (length(obj) == 0) {
      NULL
    } else {
      last_rowsplit(obj[[length(obj)]])
    }
  }
)

#' @rdname int_methods
setMethod(
  "last_rowsplit", "PreDataTableLayouts",
  function(obj) last_rowsplit(rlayout(obj))
)


## split_rows and split_cols are "recursive method stacks" which follow
## the general pattern of accept object -> call add_*_split on slot of object ->
## update object with value returned from slot method, return object.
##
## Thus each of the methods is idempotent, returning an updated object of the
## same class it was passed. The exception for idempotency is the NULL method
## which constructs a PreDataTableLayouts object with the specified split in the
## correct place.

## The cascading (by class) in this case is as follows for the row case:
## PreDataTableLayouts -> PreDataRowLayout -> SplitVector
#' @param cmpnd_fun (`function`)\cr intended for internal use.
#' @param pos (`numeric(1)`)\cr intended for internal use.
#' @param spl (`Split`)\cr the split.
#'
#' @rdname int_methods
setGeneric(
  "split_rows",
  function(lyt = NULL, spl, pos,
           cmpnd_fun = AnalyzeMultiVars, at_sibling = NULL) {
    standardGeneric("split_rows")
  }
)

#' @rdname int_methods
setMethod("split_rows", "NULL", function(lyt, spl, pos, cmpnd_fun = AnalyzeMultiVars, at_sibling = NULL) {
  lifecycle::deprecate_warn(
    when = "0.3.8",
    what = I("split_rows(NULL)"),
    with = "basic_table()",
    details = "Initializing layouts via `NULL` is no longer supported."
  )
  rl <- PreDataRowLayout(SplitVector(spl))
  cl <- PreDataColLayout()
  PreDataTableLayouts(rlayout = rl, clayout = cl)
})

first_spl_name <- function(splvectree) {
  if (is(splvectree, "Split")) { ## could generic + methods but ... whyyyyy?
    spl <- splvectree
  } else {
    spl <- unlist(splvectree, recursive = TRUE)[[1]]
  }
  deuniqify_path_elements(obj_name(spl))
}


brack_regex <- "[^[]+\\[([[:digit:]]+)\\]"
extract_dup_pos <- function(str) {
  havebracks <- grepl(brack_regex, str)
  out <- gsub(brack_regex, "\\1", str)
  out[!havebracks] <- 1
  as.numeric(out)
}

## for
## split_rows_by("STRATA1") |>
## split_rows_by("SEX") |>
##   analyze("AGE") |>
##   split_rows_by("RACE", at_sibling = "SEX") |>
##   split_rows_by("BMRKR2") |>
##   analyze("AGE") |>
##   analyze("BMRKR1", at_sibling = "BMRKR2")
##
## this should give: STRATA1, list(SEX, RACE), BMRKR2, BMRKR1 as valid at_sibling targets
get_names_list <- function(splvec) {
  unlist(lapply(splvec, function(x) {
    if (is(x, "SplitVectorTree")) {
      c(
        ## use this cause it does deuniqify
        list(vapply(x, first_spl_name, "")),
        ## ignore first name of last branch, we use name from first branch for matching here
        get_names_list(x[[length(x)]][-1])
      )
    } else { ## Split case
      first_spl_name(x)
    }
  }), recursive = FALSE)
}

find_branch_pos2 <- function(splvec, at_sibling, preceding = NULL) {
  nmlst <- get_names_list(splvec)

  atsib <- deuniqify_path_elements(at_sibling)
  dup_pos <- extract_dup_pos(at_sibling)
  found_lgl <- vapply(nmlst, function(lst) atsib %in% deuniqify_path_elements(lst), FALSE)
  found <- which(found_lgl)

  if (length(found) == 0) {
    stop(
      "Unable to find structural element '", at_sibling, "' to add siblings for.\n",
      "Eligible elements: ",
      paste(
        collapse = ", ",
        paste0(
          "'",
          unlist(c(preceding, nmlst)),
          "'"
        )
      )
    )
  } else if (dup_pos > length(found)) {
    stop(
      "Found only ", length(found), " eligible elements named '",
      deuniqify_path_elements(at_sibling),
      "', but at_sibling was '", at_sibling, "'"
    )
  }
  found[dup_pos]
}

branch_is_root <- function(splv, at_sibling) find_branch_pos2(splv, at_sibling) == 1

## its recursive all the way down ... as always

branch_above_split <- function(splvec, newspl, at_sibling,
                               branch_pos = find_branch_pos2(splvec, at_sibling, preceding = preceding),
                               preceding = NULL) {
  svlen <- length(splvec)
  if (branch_pos > svlen) {
    stopifnot(is(splvec[[svlen]], "SplitVectorTree"))
    lasttree <- splvec[[svlen]]
    treelen <- length(lasttree)
    lasttree[[treelen]] <- branch_above_split(lasttree[[treelen]],
      newspl,
      at_sibling = at_sibling, ## not used in this path
      ## +1 is b/c the first split for this branch
      ## was already matched against, otherwise we
      ## are double-counting it
      branch_pos = branch_pos - svlen + 1,
      preceding = c(
        preceding,
        vapply(splvec, first_spl_name, "")
      )
    )
    splvec[[svlen]] <- lasttree
    return(splvec)
  }
  lastel <- splvec[[branch_pos]]

  len <- length(splvec)

  endontree <- is(lastel, "SplitVectorTree")
  sib_matches <- is.null(at_sibling) || at_sibling == first_spl_name(lastel)
  if (endontree && sib_matches) {
    splvec[[branch_pos]] <- SplitVectorTree(lst = c(lastel, list(SplitVector(newspl))))
  } else if (has_force_pag(lastel)) {
    stop(
      "at_sibling pointed to a split with forced pagination (page_by = TRUE).",
      " This is not supported."
    )
  } else {
    ## are_spls <- which(!vapply(splvec, is, "VAnalyzeSplit", FUN.VALUE = TRUE))
    ## branch_pos <- max(0, are_spls) ## ensure no -Inf warning
    if (branch_pos > 0 && label_position(splvec[[branch_pos]]) == "default") {
      label_position(splvec[[branch_pos]]) <- "visible"
    }
    lst <- c(
      if (branch_pos > 1) splvec[seq(1, branch_pos - 1)],
      list(SplitVectorTree(lst = list(
        SplitVector(lst = splvec[seq(branch_pos, len)]),
        SplitVector(newspl)
      )))
    )
    splvec <- SplitVector(lst = lst)
  }
  splvec
}

#' @rdname int_methods
setMethod(
  "split_rows", "PreDataRowLayout",
  function(lyt, spl, pos, cmpnd_fun = AnalyzeMultiVars, at_sibling = NULL) {
    stopifnot(is.na(pos) || (pos > 0 && pos <= length(lyt) + 1))
    root_branching <- FALSE
    if (!is.null(at_sibling)) {
      oldval <- lyt[[pos]]
      ## if we at_sibling a top level element we need to handle as nested = FALSE
      if (branch_is_root(oldval, at_sibling)) {
        tmp <- SplitVector(spl)
        pos <- length(lyt) + 1 ## pos when nested = FALSE
      } else if (is(oldval, "SplitVectorTree")) {
        tmp <- SplitVectorTree(lst = c(oldval, list(SplitVector(spl))))
      } else if (is(oldval, "SplitVector")) {
        tmp <- branch_above_split(oldval, spl, at_sibling)
      } else {
        stop(
          "split_rows failed with at_sibling ['", at_sibling, "'] and oldval class '",
          class(oldval),
          "'. This should not happen, contact the maintianer."
        )
      }
    } else if (pos <= length(lyt)) {
      tmp <- split_rows(lyt[[pos]], spl, pos, cmpnd_fun = cmpnd_fun, at_sibling = at_sibling)
    } else {
      if (pos != 1 && has_force_pag(spl)) {
        stop("page_by splits cannot have top-level siblings",
          call. = FALSE
        )
      }
      tmp <- SplitVector(spl)
    }
    lyt[[pos]] <- tmp
    lyt
  }
)

is_analysis_spl <- function(spl) {
  is(spl, "VAnalyzeSplit") || is(spl, "AnalyzeMultiVars")
}

## note "pos" is ignored here because it is for which nest-chain
## spl should be placed in, NOT for where in that chain it should go
#' @rdname int_methods
setMethod(
  "split_rows", "SplitVector",
  function(lyt, spl, pos, cmpnd_fun = AnalyzeMultiVars, at_sibling = NULL) {
    if (has_force_pag(spl) && length(lyt) > 0 && !has_force_pag(lyt[[length(lyt)]])) {
      stop("page_by splits cannot be nested within non-page_by splits",
        call. = FALSE
      )
    }
    len <- length(lyt)

    ## now that we have branching we need to recursively replace
    if (len > 0 && is(lyt[[len]], "SplitVectorTree")) {
      lyt[[len]] <- split_rows(lyt[[len]], spl = spl, pos = pos, cmpnd_fun = cmpnd_fun, at_sibling = at_sibling)
      lyt
    } else {
      tmp <- c(unclass(lyt), spl)
      SplitVector(lst = tmp)
    }
  }
)

setMethod(
  "split_rows", "SplitVectorTree",
  function(lyt, spl, pos, cmpnd_fun = AnalyzeMultiVars, at_sibling = NULL) {
    ## nested is always TRUE by this point as FALSE and the new NA
    ## should be captured by the pos value in the PreData*Layout
    ## methods
    len <- length(lyt)
    stopifnot(len > 0)
    lyt[[len]] <- split_rows(lyt[[len]], spl = spl, pos = pos, cmpnd_fun = cmpnd_fun, at_sibling = at_sibling)
    lyt
  }
)

#' @rdname int_methods
setMethod(
  "split_rows", "PreDataTableLayouts",
  function(lyt, spl, pos, at_sibling = NULL) {
    rlyt <- rlayout(lyt)
    addtl <- FALSE
    split_label <- obj_label(spl)
    if (
      is(spl, "Split") && ## exclude existing tables that are being tacked in
        identical(label_position(spl), "topleft") &&
        length(split_label) == 1 && nzchar(split_label)
    ) {
      addtl <- TRUE
      ##        label_position(spl) <- "hidden"
    }

    rlyt <- split_rows(rlyt, spl, pos, at_sibling = at_sibling)
    rlayout(lyt) <- rlyt
    if (addtl) {
      lyt <- append_topleft(lyt, indent_string(split_label, .tl_indent(lyt)))
    }
    lyt
  }
)

#' @rdname int_methods
setMethod(
  "split_rows", "ANY",
  function(lyt, spl, pos, at_sibling = NULL) {
    stop("nope. can't add a row split to that (", class(lyt), "). contact the maintaner.")
  }
)

## cmpnd_last_rowsplit =====

#' @rdname int_methods
#'
#' @param constructor (`function`)\cr constructor function.
setGeneric("cmpnd_last_rowsplit", function(lyt, spl, constructor) standardGeneric("cmpnd_last_rowsplit"))

#' @rdname int_methods
setMethod("cmpnd_last_rowsplit", "NULL", function(lyt, spl, constructor) {
  stop("no existing splits to compound with. contact the maintainer") # nocov
})

#' @rdname int_methods
setMethod(
  "cmpnd_last_rowsplit", "PreDataRowLayout",
  function(lyt, spl, constructor) {
    pos <- length(lyt)
    tmp <- cmpnd_last_rowsplit(lyt[[pos]], spl, constructor)
    lyt[[pos]] <- tmp
    lyt
  }
)
#' @rdname int_methods
setMethod(
  "cmpnd_last_rowsplit", "SplitVector",
  function(lyt, spl, constructor) {
    pos <- length(lyt)
    lst <- lyt[[pos]]
    tmp <- if (is(lst, "CompoundSplit")) {
      spl_payload(lst) <- c(
        .uncompound(spl_payload(lst)),
        .uncompound(spl)
      )
      obj_name(lst) <- make_ma_name(spl = lst)
      lst
      ## XXX never reached because AnalzyeMultiVars inherits from
      ## CompoundSplit???
    } else {
      constructor(.payload = list(lst, spl))
    }
    lyt[[pos]] <- tmp
    lyt
  }
)

#' @rdname int_methods
setMethod(
  "cmpnd_last_rowsplit", "PreDataTableLayouts",
  function(lyt, spl, constructor) {
    rlyt <- rlayout(lyt)
    rlyt <- cmpnd_last_rowsplit(rlyt, spl, constructor)
    rlayout(lyt) <- rlyt
    lyt
  }
)
#' @rdname int_methods
setMethod(
  "cmpnd_last_rowsplit", "ANY",
  function(lyt, spl, constructor) {
    stop(
      "nope. can't do cmpnd_last_rowsplit to that (",
      class(lyt), "). contact the maintaner."
    )
  }
)

## split_cols ====

#' @rdname int_methods
setGeneric(
  "split_cols",
  function(lyt = NULL, spl, pos) {
    standardGeneric("split_cols")
  }
)

#' @rdname int_methods
setMethod("split_cols", "NULL", function(lyt, spl, pos) {
  lifecycle::deprecate_warn(
    when = "0.3.8",
    what = I("split_cols(NULL)"),
    with = "basic_table()",
    details = "Initializing layouts via `NULL` is no longer supported."
  )
  cl <- PreDataColLayout(SplitVector(spl))
  rl <- PreDataRowLayout()
  PreDataTableLayouts(rlayout = rl, clayout = cl)
})

#' @rdname int_methods
setMethod(
  "split_cols", "PreDataColLayout",
  function(lyt, spl, pos) {
    stopifnot(pos > 0 && pos <= length(lyt) + 1)
    tmp <- if (pos <= length(lyt)) {
      split_cols(lyt[[pos]], spl, pos)
    } else {
      SplitVector(spl)
    }

    lyt[[pos]] <- tmp
    lyt
  }
)

#' @rdname int_methods
setMethod(
  "split_cols", "SplitVector",
  function(lyt, spl, pos) {
    tmp <- c(lyt, spl)
    SplitVector(lst = tmp)
  }
)

#' @rdname int_methods
setMethod(
  "split_cols", "PreDataTableLayouts",
  function(lyt, spl, pos) {
    rlyt <- lyt@col_layout
    rlyt <- split_cols(rlyt, spl, pos)
    lyt@col_layout <- rlyt
    lyt
  }
)

#' @rdname int_methods
setMethod(
  "split_cols", "ANY",
  function(lyt, spl, pos) {
    stop(
      "nope. can't add a col split to that (", class(lyt),
      "). contact the maintaner."
    )
  }
)
