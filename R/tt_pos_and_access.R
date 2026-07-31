do_recursive_replace <- function(tab, path, incontent = FALSE, value) { ## rows = NULL,
  ## cols = NULL, value) {
  ## don't want this in the recursive function
  ## so thats why we have the do_ variant
  if (is.character(path) && length(path) > 1) {
    path <- as.list(path)
  }
  if (length(path) > 0 && path[[1]] == obj_name(tab)) {
    path <- path[-1]
  }
  recursive_replace(tab, path, value) ## incontent, rows, cols,value)
}

## different cases we want to support:
## 1. Replace entire children for a particular node/position in the tree
## 2. Replace entire rows at a particular (ElementaryTable) position within the
##   tree
## 3. Replace specific cell values within a set of row x column positions within
##   an ElementaryTable at a particular position within the tree
## 3. replace entire content table at a node position
## 4. replace entire rows within the content table at a particular node position
##   in the tree
## 5. replace data cell values for specific row/col positions within the content
##   table at a particular position within the tree

## XXX This is wrong, what happens if a split (or more accurately, value)
## happens more than once in the overall tree???
recursive_replace <- function(tab, path, value) { ## incontent = FALSE, rows = NULL, cols = NULL, value) {
  if (length(path) == 0) { ## done recursing
    ## if(is.null(rows) && is.null(cols)) { ## replacing whole subtree a this position
    ##     if(incontent) {
    ##         newkid = tab
    ##         content_table(newkid) = value
    ##     } else
    newkid <- value
    ## newkid has either thee content table
    ## replaced on the old kid or is the new
    ## kid
    #  } ## else { ## rows or cols (or both)  non-null
    ##     if(incontent) {
    ##         ctab = content_table(tab)
    ##         ctab[rows, cols] = value
    ##         content_table(tab) = ctab
    ##         newkid = tab

    ##     } else {
    ##         allkids = tree_children(tab)
    ##         stopifnot(are(allkids, "TableRow"))
    ##         newkid = tab
    ##         newkid[rows, cols] = value
    ##     }
    ## }
    newkid
  } else if (path[[1]] == "@content") {
    ctb <- content_table(tab)
    ctb <- recursive_replace(ctb,
      path = path[-1],
      ## rows = rows,
      ## cols = cols,
      value = value
    )
    content_table(tab) <- ctb
    tab
  } else { ## length(path) > 1, more recursing to do
    kidel <- path[[1]]
    ## broken up for debugabiliity, could be a single complex
    ## expression
    ## for now only the last step supports selecting
    ## multiple kids
    stopifnot(
      length(kidel) == 1,
      is.character(kidel) || is.factor(kidel)
    )
    knms <- names(tree_children(tab))
    if (!(kidel %in% knms)) {
      stop(sprintf("position element %s not in names of next level children", kidel))
    } else if (sum(kidel == knms) > 1) {
      stop(sprintf("position element %s appears more than once, not currently supported", kidel))
    }
    if (is.factor(kidel)) kidel <- levels(kidel)[kidel]
    newkid <- recursive_replace(
      tree_children(tab)[[kidel]],
      path[-1],
      ## incontent = incontent,
      ## rows = rows,
      ## cols = cols,
      value
    )
    tree_children(tab)[[kidel]] <- newkid
    tab
  }
}

coltree_split <- function(ctree) ctree@split

col_fnotes_at_path <- function(ctree, path, fnotes) {
  if (length(path) == 0) {
    col_footnotes(ctree) <- fnotes
    return(ctree)
  }

  if (identical(path[1], obj_name(coltree_split(ctree)))) {
    path <- path[-1]
  } else {
    stop(paste("Path appears invalid at step:", path[1]))
  }

  kids <- tree_children(ctree)
  kidel <- path[[1]]
  knms <- names(kids)
  stopifnot(kidel %in% knms)
  newkid <- col_fnotes_at_path(kids[[kidel]],
    path[-1],
    fnotes = fnotes
  )
  kids[[kidel]] <- newkid
  tree_children(ctree) <- kids
  ctree
}

#' Insert row at path
#'
#' Insert a row into an existing table directly before or directly after an existing data (i.e., non-content and
#' non-label) row, specified by its path.
#'
#' @inheritParams gen_args
#' @param after (`flag`)\cr whether `value` should be added as a row directly before (`FALSE`, the default) or after
#'   (`TRUE`) the row specified by `path`.
#'
#' @seealso [DataRow()], [rrow()]
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_rows_by("COUNTRY", split_fun = keep_split_levels(c("CHN", "USA"))) |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, DM)
#'
#' tbl2 <- insert_row_at_path(
#'   tbl, c("COUNTRY", "CHN", "AGE", "Mean"),
#'   rrow("new row", 555)
#' )
#' tbl2
#'
#' tbl3 <- insert_row_at_path(tbl2, c("COUNTRY", "CHN", "AGE", "Mean"),
#'   rrow("new row redux", 888),
#'   after = TRUE
#' )
#' tbl3
#'
#' @export
setGeneric("insert_row_at_path",
  signature = c("tt", "value"),
  function(tt, path, value, after = FALSE) {
    standardGeneric("insert_row_at_path")
  }
)

#' @rdname insert_row_at_path
setMethod(
  "insert_row_at_path", c("VTableTree", "DataRow"),
  function(tt, path, value, after = FALSE) {
    if (no_colinfo(value)) {
      col_info(value) <- col_info(tt)
    } else {
      chk_compat_cinfos(tt, value)
    }
    ## retained for debugging
    origpath <- path # nolint
    idx_row <- tt_at_path(tt, path)
    if (!is(idx_row, "DataRow")) {
      stop(
        "path must resolve fully to a non-content data row. Insertion of ",
        "rows elsewhere in the tree is not currently supported."
      )
    }

    posnm <- tail(path, 1)

    path <- head(path, -1)

    subtt <- tt_at_path(tt, path)
    kids <- tree_children(subtt)
    ind <- which(names(kids) == posnm)
    if (length(ind) != 1L) {
      ## nocov start
      stop(
        "table children do not appear to be named correctly at this ",
        "path. This should not happen, please contact the maintainer of ",
        "rtables."
      )
      ## nocov end
    }
    if (after) {
      ind <- ind + 1
    }

    sq <- seq_along(kids)
    tree_children(subtt) <- c(
      kids[sq < ind],
      setNames(list(value), obj_name(value)),
      kids[sq >= ind]
    )
    tt_at_path(tt, path) <- subtt
    tt
  }
)

# nocov start
#' @rdname insert_row_at_path
setMethod(
  "insert_row_at_path", c("VTableTree", "ANY"),
  function(tt, path, value) {
    stop(
      "Currently only insertion of DataRow objects is supported. Got ",
      "object of class ", class(value), ". Please use rrow() or DataRow() ",
      "to construct your row before insertion."
    )
  }
)

# nocov end

#' Label at path
#'
#' Accesses or sets the label at a path.
#'
#' @inheritParams gen_args
#'
#' @details
#' If `path` resolves to a single row, the label for that row is retrieved or set. If, instead, `path` resolves to a
#' subtable, the text for the row-label associated with that path is retrieved or set. In the subtable case, if the
#' label text is set to a non-`NA` value, the `labelrow` will be set to visible, even if it was not before. Similarly,
#' if the label row text for a subtable is set to `NA`, the label row will bet set to non-visible, so the row will not
#' appear at all when the table is printed.
#'
#' @note When changing the row labels for content rows, it is important to path all the way to the *row*. Paths
#' ending in `"@content"` will not exhibit the behavior you want, and are thus an error. See [row_paths()] for help
#' determining the full paths to content rows.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_rows_by("COUNTRY", split_fun = keep_split_levels(c("CHN", "USA"))) |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, DM)
#'
#' label_at_path(tbl, c("COUNTRY", "CHN"))
#'
#' label_at_path(tbl, c("COUNTRY", "USA")) <- "United States"
#' tbl
#'
#' @export
label_at_path <- function(tt, path) {
  obj_label(tt_at_path(tt, path))
}

#' @export
#' @rdname label_at_path
`label_at_path<-` <- function(tt, path, value) {
  if (!is(tt, "VTableTree")) {
    stop("tt must be a TableTree or ElementaryTable object")
  }
  if (is.null(value) || is.na(value)) {
    value <- NA_character_
  }
  subt <- tt_at_path(tt, path)
  obj_label(subt) <- value
  tt_at_path(tt, path) <- subt
  tt
}

#' Access or set table elements at specified path
#'
#' @inheritParams gen_args
#' @param ... unused.
#'
#' @export
#' @rdname ttap
setGeneric("tt_at_path", function(tt, path, ...) standardGeneric("tt_at_path"))

#' @inheritParams tt_at_path
#'
#' @export
#' @rdname int_methods
setMethod(
  "tt_at_path", "VTableTree",
  function(tt, path, ...) {
    stopifnot(
      is(path, "character"),
      length(path) > 0,
      !anyNA(path)
    )

    if (path[1] == "root" && obj_name(tt) != "root") {
      path <- path[-1]
    }
    ## handle pathing that hits the root split by name
    if (obj_name(tt) == path[1]) {
      path <- path[-1]
    }

    # Extract sub-tables from the tree
    .extract_through_path(tt, path)
  }
)

# Recursive helper function to retrieve sub-tables from the tree
## need to generalize this if we ever use it in a place other than tt_at_path
## currently tt_at_path doesn't support "*"
.extract_through_path <- function(cur_tbl, cur_path, no_stop = FALSE) {
  while (length(cur_path > 0)) {
    kids <- tree_children(cur_tbl)
    curname <- cur_path[1]
    kids_names <- sapply(kids, obj_name)
    if (curname == "@content") {
      cur_tbl <- content_table(cur_tbl)
    } else if (curname %in% kids_names) {
      ## we're now guarnateed that there will only be one match
      cur_tbl <- kids[kids_names == curname][[1]]
    } else if (!no_stop && curname == "*") {
      stop("Paths including '*' wildcards are not currently supported by tt_at_path.")
    } else if (!no_stop) {
      stop(
        "Path appears invalid for this tree at step '", curname, "'. Please use only",
        " row names and NOT row labels. You can retrieve them with `row_paths_summary()$path`."
      )
    } else {
      return(NULL)
    }
    cur_path <- cur_path[-1]
  }
  cur_tbl
}

tt_type_ok <- function(obj, type) {
  switch(type,
    any = TRUE,
    row = is(obj, "TableRow"),
    table = is(obj, "VTableTree"),
    elemtable = is(obj, "ElementaryTable")
  )
}

#' Pathing
#'
#' Pathing is a method of using known structure within a table
#' to specify elements within it in a self-describing, semantically
#' meaningful way.
#'
#' @details A Path consists of a character vector of one or more elements which
#'    will be used to descend the tree structure of a table's row or column space.
#'
#' Existing paths will match the layout used to make the table in the form of
#'    split, split-value pairs corresponding to facets generated by `split_rows_by*`
#'    and, elementary subtables generated by `analyze`, and rows generated by the
#'    afun used. Groups summaries generated by `summarize_row_groups` are represented
#'    by the 'content table' attached to a subtable representing a facet generated
#'    by a `split_rows_by` instruction, and are addressed via `@content` instead
#'    of their name.
#'
#' For example, given the code
#' \preformatted{
#' lyt <- basic_table() |>
#'   split_rows_by("ARM") |>
#'   split_rows_by("RACE") |>
#'   summarize_row_groups() |>
#'   analyze("SEX") |>
#'   analyze("AGE", nested = FALSE)
#'
#' tbl <- build_table(lyt, DM)
#' }
#'
#' We know that there will be two top-level subtables, one representing
#'   (and generated via) the split on the `ARM` variable, and one
#'   generated from the non-nested analyze on `AGE`. These can be be
#'   'pathed to' at `"ARM"` and `"AGE"`, respectively. Furthermore
#'   each value for `ARM` can be pathed to via, e.g.,  `c("ARM", "A: Drug X")`
#'   or more generally using the pathing wildcard `"*"` at `c("ARM", "*")`.
#'
#' A particular `SEX` analysis subtable, then, would be pathed to via the
#'   (row) path `c("ARM", "*", "RACE", "*", "SEX")`, e.g.
#'   `c("ARM", "B: Placebo", "RACE", "ASIAN", "SEX")`. The group-summary for
#'   Asians within the placebo group would be pathed to via
#'   `c("ARM", "B: Placebo", "RACE", "ASIAN", "@content")` for the table, and
#'   `c("ARM", "B: Placebo", "RACE", "ASIAN", "@content", "ASIAN")` for the
#'   row.
#'
#' @note some pathing-based functionality supports the "*" wildcard (typically
#'   'setters'/functionality which alters a table and returns it) while some
#'   does not (typically 'getters' which retrieve a subtable/row from a table
#'   or some attribute of that subtable/row).
#'
#' @note The `"*"` wildcard will never act as `"@content"` to step into
#'   a subtable's content table; that must be specified in the path, via
#'   e.g., `c("*", "*", "@content")` instead of `c("*", "*", "*")`.
#'
#' @description for `tt_row_path_exists`, tests whether a single path (potentially
#'    including `"*"` wildcards) resolves to at least one element satisfying
#'    `tt_type` (if specified).
#' @inheritParams gen_args
#' @return For `tt_row_path_exists`: `TRUE` if the path resolves to at least one
#'     substructure (subtable or row) that satisfies `tt_type`, or if the
#'     path is length 0; `FALSE` otherwise
#' @export
#' @examples
#' lyt <- basic_table() |>
#'   split_rows_by("ARM") |>
#'   split_rows_by("STRATA1") |>
#'   analyze("SEX") |>
#'   analyze("SEX", nested = FALSE)
#' tbl <- build_table(lyt, DM)
#' tt_row_path_exists(tbl, c("root", "ARM", "*", "*", "*", "SEX")) # TRUE
#' tt_row_path_exists(tbl, c("ARM", "*", "*", "*", "SEX")) # TRUE
#' tt_row_path_exists(tbl, c("ARM", "*", "*", "SEX")) # FALSE
#' tt_row_path_exists(tbl, "FAKE") # FALSE
#' tt_row_path_exists(tbl, c("ARM", "*", "STRATA1", "*", "SEX")) # TRUE
#' tt_row_path_exists(tbl, c("ARM", "*", "STRATA", "*", "SEX")) # FALSE
#' tt_row_path_exists(tbl, "SEX") # TRUE
#' tt_row_path_exists(tbl, "SEX", tt_type = "table") # TRUE
#' tt_row_path_exists(tbl, "SEX", tt_type = "elemtable") # TRUE
#' tt_row_path_exists(tbl, "SEX", tt_type = "row") # FALSE
#' tt_row_path_exists(tbl, c("SEX", "*")) # TRUE
tt_row_path_exists <- function(obj, path, tt_type = c("any", "row", "table", "elemtable")) {
  tt_type <- match.arg(tt_type)
  if (length(path) == 0) {
    ## we matched everything and called it again, evaluate type condition and return answer
    return(tt_type_ok(obj, tt_type))
  } else if (length(path) > 1 && (is.null(obj) || is(obj, "TableRow"))) {
    ## we got to a leaf node but still have >1 step remaining, path doesn't exist
    return(FALSE)
  }

  if (path[1] == "root") {
    path <- path[-1]
  }
  if (length(path) > 0 && path[1] == obj_name(obj)) {
    path <- path[-1] ## character()[-1] is just character() again so this is ok
  }

  ## annoying we have to do this again :-/
  if (length(path) == 0) {
    ## we matched everything and called it again, evaluate type condition and return answer
    return(tt_type_ok(obj, tt_type))
  }
  kids <- tree_children(obj)
  kidnms <- vapply(kids, obj_name, "")
  curpth <- path[1]
  nextpth <- path[-1]
  if (curpth == "*") {
    ret <- any(vapply(kids, tt_row_path_exists, path = nextpth, tt_type = tt_type, TRUE))
  } else if (curpth == "@content") {
    ctab <- content_table(obj)
    if (NROW(ctab) == 0) {
      return(FALSE)
    }
    ret <- tt_row_path_exists(ctab, nextpth, tt_type = tt_type)
  } else if (curpth %in% kidnms) {
    ret <- tt_row_path_exists(kids[[curpth]], nextpth, tt_type = tt_type)
  } else {
    ret <- FALSE
  }
  ret
}

#' @rdname tt_row_path_exists
#' @param .prev_path (`character`)\cr Internal implementation detail.
#'     Do not set manually.
#' @description Given a path with at least one wildcard (`"*"`) in it,
#'     `tt_normalize_path` walks the tree and generates the complete
#'     set of fully specified (ie no wildcards) paths which exist in
#'     the row structure of `obj`
#' @return for `tt_normalize_row_path`: a list of 0 or more fully
#'     specified paths which exist in the row structure of `obj` that
#'     match the original wildcard path, and which lead to an element
#'     of type `tt_type` (if specified other than `"any")`.
#' @export
#' @aliases pathing
#' @examples
#' tt_normalize_row_path(tbl, c("root", "ARM", "*", "*", "*", "SEX"))
#' tt_normalize_row_path(tbl, "SEX", tt_type = "row") # empty list
tt_normalize_row_path <- function(obj,
                                  path,
                                  .prev_path = character(),
                                  tt_type = c("any", "row", "table", "elemtable")) {
  if (length(path) == 0) {
    return(list(.prev_path))
  }
  tt_type <- match.arg(tt_type)
  if (!tt_row_path_exists(obj, path, tt_type = tt_type)) {
    return(list())
  }
  wcpos <- grep("^[*]$", path)
  if (length(wcpos) == 0) {
    return(list(c(.prev_path, path)))
  }

  befwc <- path[seq_len(wcpos[1] - 1)]
  if (length(befwc) > 0) {
    subtbl <- tt_at_path(obj, befwc)
  } else {
    subtbl <- obj
  }
  kids <- tree_children(subtbl)

  nextstps <- names(kids)
  aftrwc <- tail(path, -1 * wcpos[1])
  if (tt_type != "any") {
    if (length(aftrwc) > 0) {
      keep <- vapply(nextstps, function(nm) tt_row_path_exists(kids[[nm]], aftrwc, tt_type = tt_type), TRUE)
    } else {
      keep <- vapply(kids, tt_type_ok, tt_type = tt_type, TRUE)
    }
    nextstps <- nextstps[keep]
    if (length(nextstps) == 0) {
      return(list())
    }
    kids <- kids[keep]
  }
  unlist(
    recursive = FALSE,
    lapply(
      kids,
      function(kdi) {
        tt_normalize_row_path(kdi, path = aftrwc, .prev_path = c(.prev_path, befwc, obj_name(kdi)))
      }
    )
  )
}

## XXX TODO some other day tt_normalize_col_path

#' @note Setting `NULL` at a defined path removes the corresponding sub-table.
#'
#' @examples
#' # Accessing sub table.
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("SEX") |>
#'   split_rows_by("BMRKR2") |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, ex_adsl) |> prune_table()
#' sub_tbl <- tt_at_path(tbl, path = c("SEX", "F", "BMRKR2"))
#'
#' # Removing sub table.
#' tbl2 <- tbl
#' tt_at_path(tbl2, path = c("SEX", "F")) <- NULL
#' tbl2
#'
#' # Setting sub table.
#' lyt3 <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("SEX") |>
#'   analyze("BMRKR2")
#'
#' tbl3 <- build_table(lyt3, ex_adsl) |> prune_table()
#'
#' tt_at_path(tbl3, path = c("SEX", "F", "BMRKR2")) <- sub_tbl
#' tbl3
#'
#' @export
#' @rdname ttap
setGeneric(
  "tt_at_path<-",
  function(tt, path, ..., value) standardGeneric("tt_at_path<-")
)

#' @export
#' @keywords internal
#' @rdname int_methods
setMethod(
  "tt_at_path<-", c(tt = "VTableTree", value = "VTableTree"),
  function(tt, path, ..., value) {
    do_recursive_replace(tt, path = path, value = value)
  }
)

## this one removes the child at path from the parents list of children,
## because that is how lists behave.
#' @export
#' @keywords internal
#' @rdname int_methods
setMethod(
  "tt_at_path<-", c(tt = "VTableTree", value = "NULL"),
  function(tt, path, ..., value) {
    do_recursive_replace(tt, path = path, value = value)
  }
)

#' @export
#' @keywords internal
#' @rdname int_methods
setMethod(
  "tt_at_path<-", c(tt = "VTableTree", value = "TableRow"),
  function(tt, path, ..., value) {
    stopifnot(is(tt_at_path(tt = tt, path = path), "TableRow"))
    do_recursive_replace(tt, path = path, value = value)

    ## ##i <- .path_to_pos(path = path, seq_len(nrow(tt)), tt, NROW)
    ## i <- .path_to_pos(path = path, tt = tt)

    ## replace_rows(tt, i = i, value = list(value))
  }
)

#' Retrieve and assign elements of a `TableTree`
#'
#' @param x (`TableTree`)\cr a `TableTree` object.
#' @param i (`numeric(1)`)\cr index.
#' @param j (`numeric(1)`)\cr index.
#' @param drop (`flag`)\cr whether the value in the cell should be returned if one cell is selected by the
#'   combination of `i` and `j`. It is not possible to return a vector of values. To do so please consider using
#'   [cell_values()]. Defaults to `FALSE`.
#' @param ... additional arguments. Includes:
#'   \describe{
#'     \item{`keep_topleft`}{(`flag`) (`[` only) whether the top-left material for the table should be retained after
#'       subsetting. Defaults to `TRUE` if all rows are included (i.e. subsetting was by column), and drops it
#'       otherwise.}
#'     \item{`keep_titles`}{(`flag`) whether title information should be retained. Defaults to `FALSE`.}
#'     \item{`keep_footers`}{(`flag`) whether non-referential footer information should be retained. Defaults to
#'       `keep_titles`.}
#'     \item{`reindex_refs`}{(`flag`) whether referential footnotes should be re-indexed as if the resulting subset is
#'       the entire table. Defaults to `TRUE`.}
#'   }
#' @param value (`list`, `TableRow`, or `TableTree`)\cr replacement value.
#'
#' @details
#' By default, subsetting drops the information about title, subtitle, main footer, provenance footer, and `topleft`.
#' If only a column is selected and all rows are kept, the `topleft` information remains as default. Any referential
#' footnote is kept whenever the subset table contains the referenced element.
#'
#' @return A `TableTree` (or `ElementaryTable`) object, unless a single cell was selected with `drop = TRUE`, in which
#'   case the (possibly multi-valued) fully stripped raw value of the selected cell.
#'
#' @note
#' Subsetting always preserve the original order, even if provided indexes do not preserve it. If sorting is needed,
#' please consider using `sort_at_path()`. Also note that `character` indices are treated as paths, not vectors of
#' names in both `[` and `[<-`.
#'
#' @seealso
#' * [sort_at_path()] to understand sorting.
#' * [summarize_row_groups()] to understand path structure.
#'
#' @examples
#' lyt <- basic_table(
#'   title = "Title",
#'   subtitles = c("Sub", "titles"),
#'   prov_footer = "prov footer",
#'   main_footer = "main footer"
#' ) |>
#'   split_cols_by("ARM") |>
#'   split_rows_by("SEX") |>
#'   analyze(c("AGE"))
#'
#' tbl <- build_table(lyt, DM)
#' top_left(tbl) <- "Info"
#' tbl
#'
#' # As default header, footer, and topleft information is lost
#' tbl[1, ]
#' tbl[1:2, 2]
#'
#' # Also boolean filters can work
#' tbl[, c(FALSE, TRUE, FALSE)]
#'
#' # If drop = TRUE, the content values are directly retrieved
#' tbl[2, 1]
#' tbl[2, 1, drop = TRUE]
#'
#' # Drop works also if vectors are selected, but not matrices
#' tbl[, 1, drop = TRUE]
#' tbl[2, , drop = TRUE]
#' tbl[1, 1, drop = TRUE] # NULL because it is a label row
#' tbl[2, 1:2, drop = TRUE] # vectors can be returned only with cell_values()
#' tbl[1:2, 1:2, drop = TRUE] # no dropping because it is a matrix
#'
#' # If all rows are selected, topleft is kept by default
#' tbl[, 2]
#' tbl[, 1]
#'
#' # It is possible to deselect values
#' tbl[-2, ]
#' tbl[, -1]
#'
#' # Values can be reassigned
#' tbl[4, 2] <- rcell(999, format = "xx.x")
#' tbl[2, ] <- list(rrow("FFF", 888, 666, 777))
#' tbl[6, ] <- list(-111, -222, -333)
#' tbl
#'
#' # We can keep some information from the original table if we need
#' tbl[1, 2, keep_titles = TRUE]
#' tbl[1, 2, keep_footers = TRUE, keep_titles = FALSE]
#' tbl[1, 2, keep_footers = FALSE, keep_titles = TRUE]
#' tbl[1, 2, keep_footers = TRUE]
#' tbl[1, 2, keep_topleft = TRUE]
#'
#' # Keeps the referential footnotes when subset contains them
#' fnotes_at_path(tbl, rowpath = c("SEX", "M", "AGE", "Mean")) <- "important"
#' tbl[4, 1]
#' tbl[2, 1] # None present
#'
#' # We can reindex referential footnotes, so that the new table does not depend
#' #  on the original one
#' fnotes_at_path(tbl, rowpath = c("SEX", "U", "AGE", "Mean")) <- "important"
#' tbl[, 1] # both present
#' tbl[5:6, 1] # {1} because it has been indexed again
#' tbl[5:6, 1, reindex_refs = FALSE] # {2} -> not reindexed
#'
#' # Note that order can not be changed with subsetting
#' tbl[c(4, 3, 1), c(3, 1)] # It preserves order and wanted selection
#'
#' @name brackets
NULL

#' @exportMethod [<-
#' @rdname brackets
setMethod(
  "[<-", c("VTableTree", value = "list"),
  function(x, i, j, ..., value) {
    nr <- nrow(x)
    if (missing(i)) {
      i <- seq_len(NROW(x))
    } else if (is(i, "character")) {
      i <- .path_to_pos(i, x)
    } else {
      i <- .j_to_posj(i, nr)
    }

    if (missing(j)) {
      j <- seq_along(col_exprs(col_info(x)))
    } else if (is(j, "character")) {
      j <- .path_to_pos(j, x, cols = TRUE)
    } else {
      j <- .j_to_posj(j, ncol(x))
    }

    if (length(i) > 1 && length(j) < ncol(x)) {
      stop("cannot modify multiple rows in not all columns.")
    }

    if (are(value, "TableRow")) {
      value <- rep(value, length.out = length(i))
    } else {
      value <- rep(value, length.out = length(i) * length(j))
    }

    counter <- 0
    ## this has access to value, i, and j by scoping
    replace_rowsbynum <- function(x, i, valifnone = NULL) {
      maxi <- max(i)
      if (counter >= maxi) {
        return(valifnone)
      }

      if (labelrow_visible(x)) {
        counter <<- counter + 1 # nolint: assignment_linter.
        if (counter %in% i) {
          nxtval <- value[[1]]
          if (is(nxtval, "LabelRow")) {
            tt_labelrow(x) <- nxtval
          } else {
            stop(
              "can't replace label with value of class",
              class(nxtval)
            )
          }
          ## we're done with this one move to
          ## the next
          value <<- value[-1] # nolint: assignment_linter.
        }
      }
      if (is(x, "TableTree") && nrow(content_table(x)) > 0) {
        ctab <- content_table(x)

        content_table(x) <- replace_rowsbynum(ctab, i)
      }
      if (counter >= maxi) { # already done
        return(x)
      }
      kids <- tree_children(x)

      if (length(kids) > 0) {
        for (pos in seq_along(kids)) {
          curkid <- kids[[pos]]
          if (is(curkid, "TableRow")) {
            counter <<- counter + 1 # nolint: assignment_linter.
            if (counter %in% i) {
              nxtval <- value[[1]]
              if (is(nxtval, class(curkid))) {
                if (no_colinfo(nxtval) && length(row_values(nxtval)) == ncol(x)) {
                  col_info(nxtval) <- col_info(x)
                }
                stopifnot(identical(col_info(x), col_info(nxtval)))
                curkid <- nxtval
                value <- value[-1]
              } else {
                if (is(nxtval, "CellValue")) {
                  rcs <- row_cells(curkid)
                  rcs[j] <- value[seq_along(j)]
                  row_cells(curkid) <- rcs
                } else {
                  rvs <- row_values(curkid)
                  rvs[j] <- value[seq_along(j)]
                  row_values(curkid) <- rvs
                }
                value <- value[-(seq_along(j))]
              }
              kids[[pos]] <- curkid
            }
          } else {
            kids[[pos]] <- replace_rowsbynum(curkid, i)
          }
          if (counter >= maxi) {
            break
          }
        }
      }
      tree_children(x) <- kids
      x
    }
    replace_rowsbynum(x, i, ...)
  }
)

#' @inheritParams brackets
#'
#' @exportMethod [<-
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[<-", c("VTableTree", value = "CellValue"),
  function(x, i, j, ..., value) {
    x[i = i, j = j, ...] <- list(value)
    x
  }
)

## this is going to be hard :( :( :(

### selecting/removing columns

## we have two options here: path like we do with rows and positional
## in leaf space.
#' Subset a table or row to particular columns
#' @inheritParams gen_args
#' @inheritParams brackets
#' @inheritParams head
#' @param j (`integer`, `logical` or `character`)\cr The column(s) to subset `tt`
#'   down to. Character vectors are interpreted as a *column path*, not as names.
#'   Path can include `"*"` wildcards.
#' @param newcinfo (`NULL` or `InstantiatedColumnInfo`)\cr The new column info,
#'   if precomputed. Generally should not be manually set by users.
#' @param ... Ignored.
#'
#' @examples
#' lyt <- basic_table(
#'   title = "Title",
#'   subtitles = c("Sub", "titles"),
#'   prov_footer = "prov footer",
#'   main_footer = "main footer"
#' ) |>
#'   split_cols_by("ARM") |>
#'   split_cols_by("SEX") |>
#'   analyze(c("AGE"))
#'
#' tbl <- build_table(lyt, DM)
#'
#' subset_cols(tbl, c(1, 3))
#' subset_cols(tbl, c("ARM", "*", "SEX", "F"))
#' @export
setGeneric(
  "subset_cols",
  function(tt,
           j,
           newcinfo = NULL,
           keep_topleft = TRUE,
           keep_titles = TRUE,
           keep_footers = keep_titles,
           ...) {
    standardGeneric("subset_cols")
  }
)

#' @exportMethod subset_cols
#' @rdname subset_cols
setMethod(
  "subset_cols", c("TableTree", "numeric"),
  function(tt, j, newcinfo = NULL,
           keep_topleft, keep_titles, keep_footers, ...) {
    j <- .j_to_posj(j, ncol(tt))
    if (is.null(newcinfo)) {
      cinfo <- col_info(tt)
      newcinfo <- subset_cols(cinfo, j,
        keep_topleft = keep_topleft, ...
      )
    }
    ## topleft taken care of in creation of newcinfo
    kids <- tree_children(tt)
    newkids <- lapply(kids, subset_cols, j = j, newcinfo = newcinfo, ...)
    cont <- content_table(tt)
    newcont <- subset_cols(cont, j, newcinfo = newcinfo, ...)
    tt2 <- tt
    col_info(tt2) <- newcinfo
    content_table(tt2) <- newcont
    tree_children(tt2) <- newkids
    tt_labelrow(tt2) <- subset_cols(tt_labelrow(tt2), j, newcinfo, ...)

    tt2 <- .h_copy_titles_footers_topleft(
      tt2, tt,
      keep_titles,
      keep_footers,
      keep_topleft
    )
    tt2
  }
)

#' @exportMethod subset_cols
#' @rdname subset_cols
setMethod(
  "subset_cols", c("ElementaryTable", "numeric"),
  function(tt, j, newcinfo = NULL,
           keep_topleft, keep_titles, keep_footers, ...) {
    j <- .j_to_posj(j, ncol(tt))
    if (is.null(newcinfo)) {
      cinfo <- col_info(tt)
      newcinfo <- subset_cols(cinfo, j,
        keep_topleft = keep_topleft,
        keep_titles = keep_titles,
        keep_footers = keep_footers, ...
      )
    }
    ## topleft handled in creation of newcinfo
    kids <- tree_children(tt)
    newkids <- lapply(kids, subset_cols, j = j, newcinfo = newcinfo, ...)
    tt2 <- tt
    col_info(tt2) <- newcinfo
    tree_children(tt2) <- newkids
    tt_labelrow(tt2) <- subset_cols(tt_labelrow(tt2), j, newcinfo, ...)
    tt2 <- .h_copy_titles_footers_topleft(
      tt2, tt,
      keep_titles,
      keep_footers,
      keep_topleft
    )
    tt2
  }
)

## small utility to transform any negative
## indices into positive ones, given j
## and total length

.j_to_posj <- function(j, n) {
  ## This will work for logicals, numerics, integers
  j <- seq_len(n)[j]
  j
}

path_collapse_sep <- "`"
escape_name_padding <- function(x) {
  ## ret <- gsub("[", "\\[", x, fixed = TRUE)
  ## ret <- gsub("]", "\\]", ret, fixed = TRUE)
  ## ret <- gsub(".", "\\.", ret, fixed = TRUE)
  chars <- strsplit(x, "")[[1]]
  ret <- paste0("[", chars, "]", collapse = "")
  ret
}

path_to_regex <- function(path) {
  paste(vapply(path, function(x) {
    if (identical(x, "*")) {
      paste0("[^", path_collapse_sep, "]+")
    } else {
      escape_name_padding(x)
    }
  }, ""), collapse = path_collapse_sep)
}

.path_to_pos <- function(path, tt, distinct_ok = TRUE, cols = FALSE) {
  path <- path[!grepl("^(|root)$", path)]
  if (cols) {
    rowdf <- make_col_df(tt)
  } else {
    rowdf <- make_row_df(tt)
  }
  if (length(path) == 0 || identical(path, "*") || identical(path, "root")) {
    return(seq(1, nrow(rowdf)))
  }

  paths <- rowdf$path
  pathregex <- path_to_regex(path)
  pathstrs <- vapply(paths, paste, "", collapse = path_collapse_sep)
  allmatchs <- grep(pathregex, pathstrs)
  if (length(allmatchs) == 0) {
    stop(
      if (cols) "column path [" else "row path [",
      paste(path, collapse = "->"),
      "] does not appear valid for this table"
    )
  }

  idxdiffs <- diff(allmatchs)
  if (!distinct_ok && length(idxdiffs) > 0 && any(idxdiffs > 1)) {
    firstnon <- min(which(idxdiffs > 1))
    ## its firstnon here because we would want firstnon-1 but
    ## the diffs are actually shifted 1 so they cancel out
    allmatchs <- allmatchs[seq(1, firstnon)]
  }
  allmatchs
}

## fix column spans that would be invalid
## after some columns are no longer there
.fix_rowcspans <- function(rw, j) {
  cspans <- row_cspans(rw)
  nc <- sum(cspans)
  j <- .j_to_posj(j, nc)
  ## this is overly complicated
  ## we need the starting indices
  ## but the first span might not be 1, so
  ## we pad with 1 and then take off the last
  start <- cumsum(c(1, head(cspans, -1)))
  ends <- c(tail(start, -1) - 1, nc)
  res <- mapply(function(st, en) {
    sum(j >= st & j <= en)
  }, st = start, en = ends)
  res <- res[res > 0]
  stopifnot(sum(res) == length(j))
  res
}

select_cells_j <- function(cells, j) {
  if (length(j) != length(unique(j))) {
    stop("duplicate column selections is not currently supported")
  }
  spans <- vapply(
    cells, function(x) cell_cspan(x),
    integer(1)
  )
  inds <- rep(seq_along(cells), times = spans)
  selinds <- inds[j]
  retcells <- cells[selinds[!duplicated(selinds)]]
  newspans <- vapply(
    split(selinds, selinds),
    length,
    integer(1)
  )

  mapply(function(cl, sp) {
    cell_cspan(cl) <- sp
    cl
  }, cl = retcells, sp = newspans, SIMPLIFY = FALSE)
}

#' @exportMethod subset_cols
#' @rdname subset_cols
setMethod(
  "subset_cols", c("ANY", "character"),
  function(tt, j, newcinfo = NULL, keep_topleft = TRUE, ...) {
    j <- .path_to_pos(path = j, tt = tt, cols = TRUE)
    subset_cols(tt, j, newcinfo = newcinfo, keep_topleft = keep_topleft, ...)
  }
)

#' @exportMethod subset_cols
#' @rdname subset_cols
setMethod(
  "subset_cols", c("TableRow", "numeric"),
  function(tt, j, newcinfo = NULL, keep_topleft = TRUE, ...) {
    j <- .j_to_posj(j, ncol(tt))
    if (is.null(newcinfo)) {
      cinfo <- col_info(tt)
      newcinfo <- subset_cols(cinfo, j, keep_topleft = keep_topleft, ...)
    }
    tt2 <- tt
    row_cells(tt2) <- select_cells_j(row_cells(tt2), j)

    if (length(row_cspans(tt2)) > 0) {
      row_cspans(tt2) <- .fix_rowcspans(tt2, j)
    }
    col_info(tt2) <- newcinfo
    tt2
  }
)

#' @exportMethod subset_cols
#' @rdname subset_cols
setMethod(
  "subset_cols", c("LabelRow", "numeric"),
  function(tt, j, newcinfo = NULL, keep_topleft = TRUE, ...) {
    j <- .j_to_posj(j, ncol(tt))
    if (is.null(newcinfo)) {
      cinfo <- col_info(tt)
      newcinfo <- subset_cols(cinfo, j, keep_topleft = keep_topleft, ...)
    }
    col_info(tt) <- newcinfo
    tt
  }
)

#' @exportMethod subset_cols
#' @rdname subset_cols
setMethod(
  "subset_cols", c("InstantiatedColumnInfo", "numeric"),
  function(tt, j, newcinfo = NULL, keep_topleft = TRUE, ...) {
    if (!is.null(newcinfo)) {
      return(newcinfo)
    }
    j <- .j_to_posj(j, length(col_exprs(tt)))
    newctree <- subset_cols(coltree(tt), j, NULL)
    newcextra <- col_extra_args(tt)[j]
    newcsubs <- col_exprs(tt)[j]
    newcounts <- col_counts(tt)[j]
    tl <- if (keep_topleft) top_left(tt) else character()
    InstantiatedColumnInfo(
      treelyt = newctree,
      csubs = newcsubs,
      extras = newcextra,
      cnts = newcounts,
      dispcounts = disp_ccounts(tt),
      countformat = colcount_format(tt),
      topleft = tl
    )
  }
)

#' @exportMethod subset_cols
#' @rdname subset_cols
setMethod(
  "subset_cols", c("LayoutColTree", "numeric"),
  function(tt, j, newcinfo = NULL, ...) {
    lst <- collect_leaves(tt)
    j <- .j_to_posj(j, length(lst))

    ## j has only non-negative values from
    ## this point on
    counter <- 0
    prune_children <- function(x, j) {
      kids <- tree_children(x)
      newkids <- kids
      for (i in seq_along(newkids)) {
        if (is(newkids[[i]], "LayoutColLeaf")) {
          counter <<- counter + 1 # nolint: assignment_linter.
          if (!(counter %in% j)) {
            newkids[[i]] <- list()
          } ## NULL removes the position entirely
        } else {
          newkids[[i]] <- prune_children(newkids[[i]], j)
        }
      }

      newkids <- newkids[sapply(newkids, function(thing) length(thing) > 0)]
      if (length(newkids) > 0) {
        tree_children(x) <- newkids
        x
      } else {
        list()
      }
    }
    prune_children(tt, j)
  }
)

## label rows ARE included in the count
subset_by_rownum <- function(tt,
                             i,
                             keep_topleft = FALSE,
                             keep_titles = TRUE,
                             keep_footers = keep_titles,
                             ...) {
  stopifnot(is(tt, "VTableNodeInfo"))
  counter <- 0
  nr <- nrow(tt)
  i <- .j_to_posj(i, nr)
  if (length(i) == 0) {
    ret <- TableTree(cinfo = col_info(tt))
    if (isTRUE(keep_topleft)) {
      top_left(ret) <- top_left(tt)
    }
    if (isTRUE(keep_titles)) {
      main_title(ret) <- main_title(tt)
      subtitles(ret) <- subtitles(tt)
    }
    if (isTRUE(keep_footers)) {
      main_footer(ret) <- main_footer(tt)
      prov_footer(ret) <- prov_footer(tt)
    }
    return(ret)
  }

  prune_rowsbynum <- function(x, i, valifnone = NULL) {
    maxi <- max(i)
    if (counter > maxi) {
      return(valifnone)
    }

    if (labelrow_visible(x)) {
      counter <<- counter + 1 # nolint: assignment_linter.
      if (!(counter %in% i)) {
        ## XXX this should do whatever
        ## is required to 'remove' the Label Row
        ## (currently implicit based on
        ## the value of the label but
        ## that shold really probably change)
        labelrow_visible(x) <- FALSE
      }
    }
    if (is(x, "TableTree") && nrow(content_table(x)) > 0) {
      ctab <- content_table(x)

      content_table(x) <- prune_rowsbynum(ctab, i,
        valifnone = ElementaryTable(
          cinfo = col_info(ctab),
          iscontent = TRUE
        )
      )
    }
    kids <- tree_children(x)
    if (counter > maxi) { # already done
      kids <- list()
    } else if (length(kids) > 0) {
      for (pos in seq_along(kids)) {
        if (is(kids[[pos]], "TableRow")) {
          counter <<- counter + 1 # nolint: assignment_linter.
          if (!(counter %in% i)) {
            kids[[pos]] <- list()
          }
        } else {
          kids[[pos]] <- prune_rowsbynum(kids[[pos]], i, list())
        }
      }
      kids <- kids[sapply(kids, function(x) NROW(x) > 0)]
    }
    ## avoid lintr styler disagreement
    nokids <- length(kids) == 0 &&
      NROW(content_table(x)) == 0 &&
      !labelrow_visible(x)
    if (nokids) {
      valifnone
    } else {
      tree_children(x) <- kids
      x
    }
  }
  ret <- prune_rowsbynum(tt, i)

  ret <- .h_copy_titles_footers_topleft(
    ret, tt,
    keep_titles,
    keep_footers,
    keep_topleft
  )

  ret
}

#' @exportMethod [
#' @rdname brackets
setMethod(
  "[", c("VTableTree", "logical", "logical"),
  function(x, i, j, ..., drop = FALSE) {
    i <- .j_to_posj(i, nrow(x))
    j <- .j_to_posj(j, ncol(x))
    x[i, j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "logical", "ANY"),
  function(x, i, j, ..., drop = FALSE) {
    i <- .j_to_posj(i, nrow(x))
    x[i, j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "logical", "missing"),
  function(x, i, j, ..., drop = FALSE) {
    j <- seq_len(ncol(x))
    i <- .j_to_posj(i, nrow(x))
    x[i, j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "ANY", "logical"),
  function(x, i, j, ..., drop = FALSE) {
    j <- .j_to_posj(j, ncol(x))
    x[i, j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "ANY", "missing"),
  function(x, i, j, ..., drop = FALSE) {
    j <- seq_len(ncol(x))
    x[i = i, j = j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "missing", "ANY"),
  function(x, i, j, ..., drop = FALSE) {
    i <- seq_len(nrow(x))
    x[i = i, j = j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "ANY", "character"),
  function(x, i, j, ..., drop = FALSE) {
    ## j <- .colpath_to_j(j, coltree(x))
    j <- .path_to_pos(path = j, tt = x, cols = TRUE)
    x[i = i, j = j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "character", "ANY"),
  function(x, i, j, ..., drop = FALSE) {
    ## i <- .path_to_pos(i, seq_len(nrow(x)), x, NROW)
    i <- .path_to_pos(i, x)
    x[i = i, j = j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "character", "missing"),
  function(x, i, j, ..., drop = FALSE) {
    ## i <- .path_to_pos(i, seq_len(nrow(x)), x, NROW)
    j <- seq_len(ncol(x))
    i <- .path_to_pos(i, x)
    x[i = i, j = j, ..., drop = drop]
  }
)


## to avoid dispatch ambiguity. Not necessary, possibly not a good idea at all
#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "character", "character"),
  function(x, i, j, ..., drop = FALSE) {
    ## i <- .path_to_pos(i, seq_len(nrow(x)), x, NROW)
    i <- .path_to_pos(i, x)
    ## j <- .colpath_to_j(j, coltree(x))
    j <- .path_to_pos(path = j, tt = x, cols = TRUE)
    x[i = i, j = j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "missing", "numeric"),
  function(x, i, j, ..., drop = FALSE) {
    i <- seq_len(nrow(x))
    x[i, j, ..., drop = drop]
  }
)

#' @exportMethod [
#' @rdname int_methods
#' @keywords internal
setMethod(
  "[", c("VTableTree", "numeric", "numeric"),
  function(x, i, j, ..., drop = FALSE) {
    ## have to do it this way because we can't add an argument since we don't
    ## own the generic declaration
    keep_topleft <- list(...)[["keep_topleft"]] %||% NA
    keep_titles <- list(...)[["keep_titles"]] %||% FALSE
    keep_footers <- list(...)[["keep_footers"]] %||% keep_titles
    reindex_refs <- list(...)[["reindex_refs"]] %||% TRUE

    if (length(j) == 0 || (length(j) == 1 && !is.na(j) && j == 0)) {
      stop("No column selected. Please consider using rtables::row.names(<tbl>) to get the row names.")
    }

    nr <- nrow(x)
    nc <- ncol(x)
    i <- .j_to_posj(i, nr)
    j <- .j_to_posj(j, nc)

    ##  if(!missing(i) && length(i) < nr) {
    if (length(i) < nr) { ## already populated by .j_to_posj
      keep_topleft <- isTRUE(keep_topleft)
      x <- subset_by_rownum(x, i,
        keep_topleft = keep_topleft,
        keep_titles = keep_titles,
        keep_footers = keep_footers
      )
    } else if (is.na(keep_topleft)) {
      keep_topleft <- TRUE
    }

    ##  if(!missing(j) && length(j) < nc)
    if (length(j) < nc) {
      x <- subset_cols(x, j,
        keep_topleft = keep_topleft,
        keep_titles = keep_titles,
        keep_footers = keep_footers
      )
    }

    # Dropping everything
    if (drop) {
      if (length(j) == 1L && length(i) == 1L) {
        rw <- collect_leaves(x, TRUE, TRUE)[[1]]
        if (is(rw, "LabelRow")) {
          warning(
            "The value selected with drop = TRUE belongs ",
            "to a label row. NULL will be returned"
          )
          x <- NULL
        } else {
          x <- row_values(rw)[[1]]
        }
      } else {
        warning(
          "Trying to drop more than one subsetted value. ",
          "We support this only with accessor function `cell_values()`. ",
          "No drop will be done at this time."
        )
        drop <- FALSE
      }
    }
    if (!drop) {
      if (!keep_topleft) {
        top_left(x) <- character()
      }
      if (reindex_refs) {
        x <- update_ref_indexing(x)
      }
    }
    x
  }
)

#' @importFrom utils compareVersion

setGeneric("tail", tail)

setMethod(
  "tail", "VTableTree",
  function(x, n = 6L, ...) {
    if (compareVersion("4.0.0", as.character(getRversion())) <= 0) {
      tail.matrix(x, n, keepnums = FALSE)
    } else {
      tail.matrix(x, n, addrownums = FALSE)
    }
  }
)

setGeneric("head", head)

setMethod(
  "head", "VTableTree",
  function(x, n = 6L, ...) {
    head.matrix(x, n)
  }
)

#' Retrieve cell values by row and column path
#'
#' @inheritParams gen_args
#' @param rowpath (`character`)\cr path in row-split space to the desired row(s). Can include `"@content"`.
#' @param colpath (`character`)\cr path in column-split space to the desired column(s). Can include `"*"`.
#' @param omit_labrows (`flag`)\cr whether label rows underneath `rowpath` should be omitted (`TRUE`, the default),
#'   or return empty lists of cell "values" (`FALSE`).
#'
#' @return
#' * `cell_values` returns a `list` (regardless of the type of value the cells hold). If `rowpath` defines a path to
#'   a single row, `cell_values` returns the list of cell values for that row, otherwise a list of such lists, one for
#'   each row captured underneath `rowpath`. This occurs after subsetting to `colpath` has occurred.
#' * `value_at` returns the "unwrapped" value of a single cell, or an error, if the combination of `rowpath` and
#'   `colpath` do not define the location of a single cell in `tt`.
#'
#' @note `cell_values` will return a single cell's value wrapped in a list. Use `value_at` to receive the "bare" cell
#'   value.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by("SEX") |>
#'   split_rows_by("RACE") |>
#'   summarize_row_groups() |>
#'   split_rows_by("STRATA1") |>
#'   analyze("AGE")
#'
#' @examplesIf require(dplyr)
#' library(dplyr) ## for mutate
#' tbl <- build_table(lyt, DM |>
#'   mutate(SEX = droplevels(SEX), RACE = droplevels(RACE)))
#'
#' row_paths_summary(tbl)
#' col_paths_summary(tbl)
#'
#' cell_values(
#'   tbl, c("RACE", "ASIAN", "STRATA1", "B"),
#'   c("ARM", "A: Drug X", "SEX", "F")
#' )
#'
#' # it's also possible to access multiple values by being less specific
#' cell_values(
#'   tbl, c("RACE", "ASIAN", "STRATA1"),
#'   c("ARM", "A: Drug X", "SEX", "F")
#' )
#' cell_values(tbl, c("RACE", "ASIAN"), c("ARM", "A: Drug X", "SEX", "M"))
#'
#' ## any arm, male columns from the ASIAN content (i.e. summary) row
#' cell_values(
#'   tbl, c("RACE", "ASIAN", "@content"),
#'   c("ARM", "B: Placebo", "SEX", "M")
#' )
#' cell_values(
#'   tbl, c("RACE", "ASIAN", "@content"),
#'   c("ARM", "*", "SEX", "M")
#' )
#'
#' ## all columns
#' cell_values(tbl, c("RACE", "ASIAN", "STRATA1", "B"))
#'
#' ## all columns for the Combination arm
#' cell_values(
#'   tbl, c("RACE", "ASIAN", "STRATA1", "B"),
#'   c("ARM", "C: Combination")
#' )
#'
#' cvlist <- cell_values(
#'   tbl, c("RACE", "ASIAN", "STRATA1", "B", "AGE", "Mean"),
#'   c("ARM", "B: Placebo", "SEX", "M")
#' )
#' cvnolist <- value_at(
#'   tbl, c("RACE", "ASIAN", "STRATA1", "B", "AGE", "Mean"),
#'   c("ARM", "B: Placebo", "SEX", "M")
#' )
#' stopifnot(identical(cvlist[[1]], cvnolist))
#'
#' @rdname cell_values
#' @export
setGeneric("cell_values", function(tt, rowpath = NULL, colpath = NULL, omit_labrows = TRUE) {
  standardGeneric("cell_values")
})

#' @rdname int_methods
#' @keywords internal
#' @exportMethod cell_values
setMethod(
  "cell_values", "VTableTree",
  function(tt, rowpath, colpath = NULL, omit_labrows = TRUE) {
    .inner_cell_value(tt,
      rowpath = rowpath, colpath = colpath,
      omit_labrows = omit_labrows, value_at = FALSE
    )
  }
)

#' @rdname int_methods
#' @keywords internal
#' @exportMethod cell_values
setMethod(
  "cell_values", "RowsVerticalSection",
  function(tt, rowpath, colpath = NULL, omit_labrows = TRUE) rawvalues(tt)
)

#' @rdname int_methods
#' @keywords internal
#' @exportMethod cell_values
setMethod(
  "cell_values", "TableRow",
  function(tt, rowpath, colpath = NULL, omit_labrows = TRUE) {
    if (!is.null(rowpath)) {
      stop("cell_values on TableRow objects must have NULL rowpath")
    }
    .inner_cell_value(tt,
      rowpath = rowpath, colpath = colpath,
      omit_labrows = omit_labrows, value_at = FALSE
    )
  }
)

#' @rdname int_methods
#' @keywords internal
#' @exportMethod cell_values
setMethod(
  "cell_values", "LabelRow",
  function(tt, rowpath, colpath = NULL, omit_labrows = TRUE) {
    stop("calling cell_values on LabelRow is not meaningful")
  }
)

#' @rdname cell_values
#' @export
setGeneric("value_at", function(tt, rowpath = NULL, colpath = NULL) {
  standardGeneric("value_at")
})

#' @rdname cell_values
#' @exportMethod value_at
setMethod(
  "value_at", "VTableTree",
  function(tt, rowpath, colpath = NULL) {
    .inner_cell_value(tt,
      rowpath = rowpath, colpath = colpath,
      omit_labrows = FALSE, value_at = TRUE
    )
  }
)

#' @rdname int_methods
#' @keywords internal
#' @exportMethod value_at
setMethod(
  "value_at", "TableRow",
  function(tt, rowpath, colpath = NULL) {
    .inner_cell_value(tt,
      rowpath = rowpath, colpath = colpath,
      omit_labrows = FALSE, value_at = TRUE
    )
  }
)

#' @rdname int_methods
#' @keywords internal
#' @exportMethod value_at
setMethod(
  "value_at", "LabelRow",
  function(tt, rowpath, colpath = NULL) {
    stop("calling value_at for LabelRow objects is not meaningful")
  }
)

.inner_cell_value <- function(tt,
                              rowpath,
                              colpath = NULL,
                              omit_labrows = TRUE,
                              value_at = FALSE) {
  if (is.null(rowpath)) {
    subtree <- tt
  } else {
    subtree <- tt_at_path(tt, rowpath)
  }
  if (!is.null(colpath)) {
    subtree <- subset_cols(subtree, colpath)
  }

  rows <- collect_leaves(subtree, TRUE, !omit_labrows)
  if (value_at && (ncol(subtree) != 1 || length(rows) != 1)) {
    stop("Combination of rowpath and colpath does not select individual cell.\n",
      "  To retrieve more than one cell value at a time use cell_values().",
      call. = FALSE
    )
  }
  if (length(rows) == 1) {
    ret <- row_values(rows[[1]])
    if (value_at && ncol(subtree) == 1) {
      ret <- ret[[1]]
    }
    ret
  } else {
    lapply(rows, row_values)
  }
}

## empty_table is created in onLoad because it depends on other things there.

# Helper function to copy or not header, footer, and topleft information
.h_copy_titles_footers_topleft <- function(new,
                                           old,
                                           keep_titles,
                                           keep_footers,
                                           keep_topleft,
                                           reindex_refs = FALSE,
                                           empt_tbl = empty_table) {
  ## Please note that the standard adopted come from an empty table

  # titles
  if (isTRUE(keep_titles)) {
    main_title(new) <- main_title(old)
    subtitles(new) <- subtitles(old)
  } else {
    main_title(new) <- main_title(empt_tbl)
    subtitles(new) <- subtitles(empt_tbl)
  }

  # fnotes
  if (isTRUE(keep_footers)) {
    main_footer(new) <- main_footer(old)
    prov_footer(new) <- prov_footer(old)
  } else {
    main_footer(new) <- main_footer(empt_tbl)
    prov_footer(new) <- prov_footer(empt_tbl)
  }

  # topleft
  if (isTRUE(keep_topleft)) {
    top_left(new) <- top_left(old)
  } else {
    top_left(new) <- top_left(empt_tbl)
  }

  # reindex references
  if (reindex_refs) {
    new <- update_ref_indexing(new)
  }

  new
}

#' Head and tail methods
#'
#' @inheritParams utils::head
#' @param keep_topleft (`flag`)\cr if `TRUE` (the default), top_left material for the table will be carried over to the
#'   subset.
#' @param keep_titles (`flag`)\cr if `TRUE` (the default), all title material for the table will be carried over to the
#'   subset.
#' @param keep_footers (`flag`)\cr if `TRUE`, all footer material for the table will be carried over to the subset. It
#'   defaults to `keep_titles`.
#' @param reindex_refs (`flag`)\cr defaults to `FALSE`. If `TRUE`, referential footnotes will be reindexed for the
#'   subset.
#'
#' @docType methods
#' @export
#' @rdname head_tail
setGeneric("head")

#' @docType methods
#' @export
#' @rdname head_tail
setMethod(
  "head", "VTableTree",
  function(x, n = 6, ..., keep_topleft = TRUE,
           keep_titles = TRUE,
           keep_footers = keep_titles,
           ## FALSE because this is a glance
           ## more often than a subset op
           reindex_refs = FALSE) {
    ## default
    res <- callNextMethod()
    res <- .h_copy_titles_footers_topleft(
      old = x, new = res,
      keep_topleft = keep_topleft,
      keep_titles = keep_titles,
      keep_footers = keep_footers,
      reindex_refs = reindex_refs
    )
    res
  }
)

#' @docType methods
#' @export
#' @rdname head_tail
setGeneric("tail")

#' @docType methods
#' @export
#' @rdname head_tail
setMethod(
  "tail", "VTableTree",
  function(x, n = 6, ..., keep_topleft = TRUE,
           keep_titles = TRUE,
           keep_footers = keep_titles,
           ## FALSE because this is a glance
           ## more often than a subset op
           reindex_refs = FALSE) {
    res <- callNextMethod()
    res <- .h_copy_titles_footers_topleft(
      old = x, new = res,
      keep_topleft = keep_topleft,
      keep_titles = keep_titles,
      keep_footers = keep_footers,
      reindex_refs = reindex_refs
    )
    res
  }
)
