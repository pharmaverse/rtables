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
    if (length(obj[[l]]) > 0L && (
      (!is.null(at_sibling) && branch_is_root(obj, at_sibling)) ||
        !.check_if_nest(obj, nested, for_analyze, at_sibling = at_sibling)
    )) {
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
      for (i in seq_along(obj)) {
        cur <- obj[[i]]
        if (is(cur, "SplitVectorTree")) {
          break
        }
      }
      last_rowsplit(cur)
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

first_spl_forcepag <- function(splvectree) {
  if (is(splvectree, "Split")) { ## could generic + methods but ... whyyyyy?
    spl <- splvectree
  } else {
    spl <- unlist(splvectree, recursive = TRUE)[[1]]
  }
  has_force_pag(spl)
}

first_spl_anchor_df <- function(splvectree, step) {
  data.frame(
    name = first_spl_name(splvectree),
    force_pag = first_spl_forcepag(splvectree),
    step = step
  )
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
## this should give: STRATA1, c(SEX, RACE), c(BMRKR2, BMRKR1) as valid at_sibling targets

#' Retrieve Info About Possible Nesting Anchors
#'
#' This function scans an existing layout's row structure and lists
#' valid `at_sibling` anchors for intermediate nesting.
#'
#' @param splvec (`PreDataTableLayouts` or internal classes)\cr The layout or partial
#' layout to list anchors for.
#' @param next_step (`integer(1)`)\cr For internal use.
#'
#' @return for `get_anchor_list` a character vector of eligible anchor
#'     names (not including any `[n]` for duplicates); for
#'     `get_anchor_df, a data.frame containing a `name` column and one
#'     or more other columns intended for internal use.
#' @examples
#'
#' lyt <- basic_table() |>
#'   split_rows_by("STRATA1") |>
#'   split_rows_by("RACE") |>
#'   split_rows_by("SEX") |>
#'   analyze("AGE") |>
#'   split_rows_by("BMRKR1", at_sibling = "RACE") |>
#'   analyze("AGE")
#'
#' get_anchor_list(lyt)
#'
#' @export
setGeneric("get_anchor_df", function(splvec, next_step = 1L) standardGeneric("get_anchor_df"))

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_anchor_df", "PreDataTableLayouts",
  function(splvec, next_step = 1) {
    get_anchor_df(rlayout(splvec), next_step = next_step)
  }
)

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_anchor_df", "PreDataRowLayout",
  function(splvec, next_step = 1L) {
    prev <- do.call(
      rbind.data.frame,
      lapply(
        splvec[-length(splvec)],
        first_spl_anchor_df,
        step = next_step
      )
    )
    #   prev$step <- seq(next_step, length.out = NROW(prev))

    active <- get_anchor_df(splvec[[length(splvec)]],
      next_step = NROW(prev) + 1
    )
    ret <- rbind(prev, active)
    nroots <- NROW(prev) + 1
    ret$is_root <- c(
      rep(TRUE, nroots),
      rep(FALSE, NROW(ret) - nroots)
    )
    ret
  }
)

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_anchor_df", "SplitVector",
  function(splvec, next_step = 1L) {
    lst <- vector("list", length(splvec))
    step <- next_step
    for (i in seq_along(lst)) {
      lst[[i]] <- get_anchor_df(splvec[[i]], next_step = step)
      step <- max(lst[[i]]$step) + 1
    }
    do.call(rbind.data.frame, lst)
  }
)

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_anchor_df", "SplitVectorTree",
  function(splvec, next_step = 1L) {
    ret <- do.call(
      rbind.data.frame,
      lapply(splvec, first_spl_anchor_df, step = next_step)
    )
    last <- splvec[[length(splvec)]]
    if (length(last) > 1) {
      active <- get_anchor_df(SplitVector(lst = splvec[[length(splvec)]][-1]), next_step = next_step + 1)
      ret <- rbind(ret, active)
    }
    ret
  }
)

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_anchor_df", "Split",
  function(splvec, next_step = 1L) first_spl_anchor_df(splvec, step = next_step)
)

#' @rdname get_anchor_df
#' @param lyt (`PreDataTableLayouts` or `PreDataRowLayout`)\cr A layout or row
#'  to identify anchors for.
#' @export
get_anchor_list <- function(lyt) {
  df <- get_anchor_df(lyt)
  unname(split(df$name, df$step))
}

## this is where all the valid anchor checks happen, and it should occur very early
## (in do_next_row_split), after that we can assume branch_pos is correct and
## anchor pt it leads to is valid
## recursive walking of tree happens once in anchordf creation
find_branch_pos_df <- function(tt, at_sibling, anchordf = get_anchor_df(tt), nofind_ok = FALSE) {
  atsib <- deuniqify_path_elements(at_sibling)
  dup_pos <- extract_dup_pos(at_sibling)
  found_lgl <- anchordf$name == atsib ## both deuniqified
  if (sum(found_lgl) < dup_pos && nofind_ok) {
    return(anchordf[NA, ])
  }
  found <- which(found_lgl)
  if (length(found) == 0) {
    stop(
      "Unable to find structural element '", at_sibling, "' to add siblings for.\n",
      "Eligible elements: ",
      paste(
        collapse = ", ",
        paste0(
          "'",
          anchordf$name,
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
  } else if (anchordf$force_pag[found[dup_pos]]) {
    stop(
      "at_sibling pointed to an element with forced pagination (page_by = TRUE). ",
      "This is not supported."
    )
  }
  anchordf[found[dup_pos], ]
}

## steps is how many (more) elements we need to walk
## to get to the anchor point with the "algorithm"
## that whenever we need to walk past the end of our vector
## we check that the last element is a SplitVectorTree and if so,
## step into the last existing branch of that tree and continue
branch_at_pos <- function(splv, steps, newspl) {
  len <- length(splv)
  if (steps > len) { ## step down into tree at end of vector and keep going
    if (!is(splv[[len]], "SplitVectorTree")) {
      stop("Bad branching position, please contact the maintainer") ## nocov
    }
    tr <- splv[[len]]
    tr[[length(tr)]] <- branch_at_pos(tr[[length(tr)]], steps - len + 1, newspl)
    splv[[len]] <- tr
  } else { ## branch somewhere along vector
    el <- splv[[steps]]
    if (is(el, "SplitVectorTree")) {
      stopifnot(steps == len) ## nocov
      splv[[steps]] <- SplitVectorTree(lst = c(el, list(SplitVector(newspl))))
    } else {
      if (label_position(el) == "default") {
        label_position(splv[[steps]]) <- "visible"
      }

      splv <- SplitVector(
        lst = c(
          if (steps > 1) splv[seq_len(steps - 1)],
          list(SplitVectorTree(
            SplitVector(lst = splv[seq(steps, len)]),
            SplitVector(newspl)
          ))
        )
      )
    }
  }
  splv
}

## **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**
## pos means different things depending on
## if it points to an anchor point or
## (!is.null(at_sibling)) or simply a place
## in the root tree (is.null(at_sibling)
## **!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!**
#' @rdname int_methods
setMethod(
  "split_rows", "PreDataRowLayout",
  function(lyt, spl, pos, cmpnd_fun = AnalyzeMultiVars, at_sibling = NULL) {
    stopifnot(is.na(pos) || (pos > 0 && (!is.null(at_sibling) || pos <= length(lyt) + 1)))
    root_branching <- FALSE
    if (!is.null(at_sibling)) {
      ## oof this is an ugly hack :(
      pos2 <- pos
      pos <- min(length(lyt), pos)
      oldval <- lyt[[pos]]
      tmp <- branch_at_pos(oldval, steps = pos2 - pos + 1, spl)
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
    ## nested is always TRUE by this point as FALSE
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
    stop("nope. can't add a row split to that (", class(lyt), "). contact the maintainer.") # nocov
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
    # nocov start
    stop(
      "nope. can't do cmpnd_last_rowsplit to that (",
      class(lyt), "). contact the maintainer."
    )
    # nocov end
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
    # nocov start
    stop(
      "nope. can't add a col split to that (", class(lyt),
      "). contact the maintainer."
    )
    # nocov end
  }
)
