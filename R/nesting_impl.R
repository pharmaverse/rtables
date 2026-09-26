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
    if (length(obj[[l]]) > 0L &&
      !.check_if_nest(obj, nested, for_analyze, at_sibling = at_sibling)) {
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


#' @rdname int_methods
#' @export
setGeneric("get_kid_types", function(obj, type) standardGeneric("get_kid_types"))
#' @rdname int_methods
#' @export
setMethod("get_kid_types", "Split", function(obj, type) type)
#' @rdname int_methods
#' @export
setMethod(
  "get_kid_types", "SplitVector",
  function(obj, type) {
    switch(type,
      anchor = c("anchor", rep("inactive", times = length(obj) - 1)),
      inactive = c("sibling", rep("inactive", times = length(obj) - 1)),
      active = rep("active", length(obj))
    )
  }
)

#' @rdname int_methods
#' @export
setMethod(
  "get_kid_types", "SplitVectorTree",
  function(obj, type) {
    c("anchor", rep("inactive", times = length(obj) - 2), type)
  }
)
#' @rdname int_methods
#' @export
setMethod(
  "get_kid_types", "PreDataRowLayout",
  function(obj, type) {
    c(rep("inactive", times = length(obj) - 1), "active")
  }
)


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
#' @param lyt (`PreDataTableLayouts`)\cr the layout.
#' @param splvec (`PreDataTableLayouts` or internal classes)\cr The layout or partial
#' layout to list anchors for.
#' @param next_node (`integer(1)`)\cr For internal use
#' @param next_anchor_step (`integer(1)`)\cr For internal use.
#' @param parent (`integer(1)`)\cr For internal use.
#' @param depth (`integer(1)`)\cr For internal use.
#' @param node_type (`character(1)`)\cr For internal use.
#' @details
#'
#' A layout data.frame is a data.frame describing a single dimension
#' of pre-data layout structure, containing the following columns
#' (most of which are used for internal implementations and will not
#' be useful to the end-user):
#'
#' - `name`: name of the element
#' - `nodeid`: sequential numeric id of the node, for use in
#'   constructing graphs (0 is the root node)
#' - `parentid`: node id of the layout instructions direct parent
#' - `depth`: length of path from root to the current node through the
#'   implicit graph defined by the (`nodeid`, `parentid`) pairings
#' - `type`: a description of the 'type' of the node, used internally
#' - `is_toplevel`: whether the node represents a top-level split/analysis.
#' - `anchor_step`: position *along the path of eligible anchor
#'   points*, (`NA` for nodes not along that path).
#'
#' The core difference between a layout data.frame and an anchor
#' data.frame is that the anchor df has been subset to remove rows for
#' nodes not currently eligible to be anchor points (ie allowed
#' targets for a subsequent instruction's `at_sibling` argument).
#'
#' @return for `get_layout_dfs` a list with `rows` and `cols` elements
#'     containing layout data.frames (see Details) for each structural
#'     dimension; `get_anchor_dfs` returns the same, but with anchor
#'     data.frames rather than full layout ones. `get_anchor_row_df`
#'     is a convenience function that returns only the `rows` anchor
#'     data.frame. `get_row_anchor_list` returns a list, each element
#'     of which is a set of the names of one or more layout
#'     instructions that will be placed as direct siblings to
#'     each-other; i.e., anchored to the first element of the vector
#'     when the length of the element is greater than one.
#'
#' @note Instructions which are anchored in such a way that they
#'     ultimately become top-level instructions in the layout (i.e.,
#'     by being anchored as a sibling to a top-level instruction) are
#'     handled somewhat differently for implementation reasons and may
#'     present differently to those anchored to non-top-level
#'     instructions.
#' @examples
#'
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("STRATA1") |>
#'   split_rows_by("RACE") |>
#'   split_rows_by("SEX") |>
#'   analyze("AGE") |>
#'   split_rows_by("BMRKR1", at_sibling = "RACE") |>
#'   analyze("AGE")
#'
#' get_layout_dfs(lyt)
#' get_anchor_dfs(lyt)
#' get_row_anchor_df(lyt)
#'
#' @export
#' @rdname get_anchor_df
setGeneric("get_full_lyt_df", function(splvec, next_node = 1L, next_anchor_step = 1L, parent, depth, node_type) standardGeneric("get_full_lyt_df"))

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_full_lyt_df", "PreDataTableLayouts",
  function(splvec, next_node, next_anchor_step = 1, parent, depth, node_type) {
    get_full_lyt_df(rlayout(splvec),
      next_node = next_node,
      next_anchor_step = next_anchor_step,
      parent = 0, depth = 1, node_type = "active"
    )
  }
)

make_lyt_df_row <- function(name, nodeid, parentid, depth, type, anchor_step, force_pag = NA, spl_abbrev = NA) {
  data.frame(name = name, nodeid = nodeid, parentid = parentid, depth = depth, type = type, is_toplevel = parentid == 0, anchor_step = anchor_step, force_pag = force_pag, spl_abbrev = spl_abbrev)
}

#' @rdname get_anchor_df
#' @export
get_layout_dfs <- function(lyt) {
  stopifnot(is(lyt, "PreDataTableLayouts"))
  list(
    cols = get_full_lyt_df(clayout(lyt)),
    rows = get_full_lyt_df(rlayout(lyt))
  )
}


.gflytdf_predataaxis <- function(splvec, next_node = 1, next_anchor_step = 1L, parent = 0L, depth = 1L, node_type = "active") {
  len <- length(splvec)
  prvlst <- vector("list", length(splvec))

  for (i in seq_len(len)) {
    prvlst[[i]] <- get_full_lyt_df(splvec[[i]],
      next_node = next_node,
      next_anchor_step = next_anchor_step + i - 1,
      parent = 0L,
      depth = 1,
      node_type = ifelse(i == len, "active", "inactive")
    )
    next_node <- max(prvlst[[i]]$nodeid) + 1
  }
  ret <- do.call(rbind.data.frame, prvlst)
  ret
}

## note the different behaviors for the 0 length case below
#' @rdname get_anchor_df
#' @export
setMethod(
  "get_full_lyt_df", "PreDataRowLayout",
  function(splvec, next_node = 1, next_anchor_step = 1L, parent = 0L, depth = 1L, node_type = "active") {
    if (length(splvec) == 1 && length(splvec[[1]]) == 0) {
      return(make_lyt_df_row(NA, NA, NA, NA, NA, NA, NA)[0, ])
    }
    .gflytdf_predataaxis(splvec = splvec, next_node = next_node, next_anchor_step = next_anchor_step, parent = parent, depth = depth, node_type = node_type)
  }
)


#' @rdname get_anchor_df
#' @export
setMethod(
  "get_full_lyt_df", "PreDataColLayout",
  function(splvec, next_node = 1, next_anchor_step = 1L, parent = 0L, depth = 1L, node_type = "active") {
    if (length(splvec) == 1 && length(splvec[[1]]) == 0) {
      return(get_full_lyt_df(AllSplit("<implicit>"), 1, 1, 0, 1, NA))
    }
    .gflytdf_predataaxis(splvec = splvec, next_node = next_node, next_anchor_step = next_anchor_step, parent = parent, depth = depth, node_type = node_type)
  }
)

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_full_lyt_df", "SplitVector",
  function(splvec, next_node, next_anchor_step = 1L, parent, depth, node_type) {
    lst <- vector("list", length(splvec))
    an_step <- next_anchor_step
    nid <- next_node
    ktypes <- get_kid_types(splvec, node_type)
    for (i in seq_along(lst)) {
      if (ktypes[i] == "inactive") {
        an_step <- NA_integer_
      }
      lst[[i]] <- get_full_lyt_df(
        splvec[[i]],
        next_node = nid,
        next_anchor_step = an_step,
        depth = depth + i - 1,
        parent = parent,
        node_type = ktypes[i]
      )
      an_step <- suppressWarnings(max(next_anchor_step, lst[[i]]$anchor_step, na.rm = TRUE)) + 1
      parent <- max(lst[[i]]$nodeid)
      nid <- parent + 1
    }
    do.call(rbind.data.frame, lst)
  }
)

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_full_lyt_df", "SplitVectorTree",
  function(splvec, next_node, next_anchor_step, parent, depth, node_type) {
    len <- length(splvec)
    lst <- vector("list", length(splvec))
    ktypes <- get_kid_types(splvec, node_type)
    nid <- next_node
    for (i in seq_len(len)) {
      lst[[i]] <- get_full_lyt_df(
        splvec[[i]],
        next_anchor_step = next_anchor_step,
        next_node = nid,
        parent = parent,
        depth = depth,
        node_type = ktypes[i]
      )
      nid <- max(lst[[i]]$nodeid) + 1
    }
    ret <- do.call(rbind.data.frame, lst)
    ret
  }
)

#' @rdname get_anchor_df
#' @export
setMethod(
  "get_full_lyt_df", "Split",
  function(splvec, next_node, next_anchor_step, parent, depth, node_type) make_lyt_df_row(name = obj_name(splvec), nodeid = next_node, anchor_step = next_anchor_step, parentid = parent, depth = depth, type = node_type, force_pag = has_force_pag(splvec), spl_abbrev = spltype_abbrev(splvec))
)


## the ***never*** used insert an existing table into a layout
## support that I regret deeply.
#' @rdname get_anchor_df
#' @export
setMethod(
  "get_full_lyt_df", "VTableNodeInfo",
  function(splvec, next_node, next_anchor_step, parent, depth, node_type) make_lyt_df_row(name = obj_name(splvec), nodeid = next_node, anchor_step = next_anchor_step, parentid = parent, depth = depth, type = node_type, force_pag = FALSE, spl_abbrev = paste0(nrow(splvec), "x", ncol(splvec), " table"))
)


## f-f-f-f-f-future proooooofin'
#' @rdname get_anchor_df
#' @export
get_anchor_dfs <- function(lyt) {
  fdfs <- get_layout_dfs(lyt)

  ret <- lapply(
    fdfs,
    function(curdf) {
      curdf[!is.na(curdf$anchor_step), ]
    }
  )
  names(ret) <- names(fdfs)
  ret
}

#' @rdname get_anchor_df
#' @export
get_row_anchor_df <- function(lyt) {
  get_anchor_dfs(lyt)[["rows"]]
}

#' @rdname get_anchor_df
#' @param lyt (`PreDataTableLayouts` or `PreDataRowLayout`)\cr A layout or row
#'  to identify anchors for.
#' @export
get_row_anchor_list <- function(lyt) {
  df <- get_row_anchor_df(lyt)
  unname(split(df$name, df$anchor_step))
}

## this is where all the valid anchor checks happen, and it should occur very early
## (in do_next_row_split), after that we can assume branch_pos is correct and
## anchor pt it leads to is valid
## recursive walking of tree happens once in anchordf creation
find_branch_pos_df <- function(tt, at_sibling, anchordf = get_row_anchor_df(tt), nofind_ok = FALSE) {
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
    lyt[[pos]] <- cmpnd_last_rowsplit(lyt[[pos]], spl, constructor)
    lyt
  }
)

#' @rdname int_methods
setMethod(
  "cmpnd_last_rowsplit", "CompoundSplit",
  function(lyt, spl, constructor) {
    spl_payload(lyt) <- c(
      .uncompound(spl_payload(lyt)),
      .uncompound(spl)
    )
    obj_name(lyt) <- make_ma_name(spl = lyt)
    lyt
  }
)


#' @rdname int_methods
setMethod(
  "cmpnd_last_rowsplit", "Split",
  function(lyt, spl, constructor) {
    constructor(.payload = list(lyt, spl))
  }
)


#' @rdname int_methods
setMethod(
  "cmpnd_last_rowsplit", "SplitVectorTree",
  function(lyt, spl, constructor) {
    pos <- length(lyt)
    lyt[[pos]] <- cmpnd_last_rowsplit(lyt[[pos]], spl, constructor)
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
