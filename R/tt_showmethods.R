treestruct <- function(obj, ind = 0L) {
  nc <- ncol(obj)
  cat(rep(" ", times = ind),
    sprintf("[%s] %s", class(obj), obj_name(obj)),
    sep = ""
  )
  if (!is(obj, "ElementaryTable") && nrow(obj@content) > 0) {
    crows <- nrow(content_table(obj))
    ccols <- if (crows == 0) 0 else nc
    cat(sprintf(
      " [cont: %d x %d]",
      crows, ccols
    ))
  }
  if (is(obj, "VTableTree") && length(tree_children(obj))) {
    kids <- tree_children(obj)
    if (are(kids, "TableRow")) {
      cat(sprintf(
        " (%d x %d)\n",
        length(kids), nc
      ))
    } else {
      cat("\n")
      lapply(kids, treestruct, ind = ind + 1)
    }
  }
  invisible(NULL)
}

setGeneric(
  "ploads_to_str",
  function(x, collapse = ":") standardGeneric("ploads_to_str")
)

setMethod(
  "ploads_to_str", "Split",
  function(x, collapse = ":") {
    paste(sapply(spl_payload(x), ploads_to_str),
      collapse = collapse
    )
  }
)

setMethod(
  "ploads_to_str", "SplitVectorTree",
  function(x, collapse = ":") {
    sapply(x, ploads_to_str, collapse = collapse)
  }
)

setMethod(
  "ploads_to_str", "CompoundSplit",
  function(x, collapse = ":") {
    paste(sapply(spl_payload(x), ploads_to_str),
      collapse = collapse
    )
  }
)

setMethod(
  "ploads_to_str", "list",
  function(x, collapse = ":") {
    stop("Please contact the maintainer")
  }
)

setMethod(
  "ploads_to_str", "SplitVector",
  function(x, collapse = ":") {
    sapply(x, ploads_to_str)
  }
)

setMethod(
  "ploads_to_str", "ANY",
  function(x, collapse = ":") {
    paste(x)
  }
)

setGeneric("payloadmsg", function(spl) standardGeneric("payloadmsg"))

setMethod(
  "payloadmsg", "VarLevelSplit",
  function(spl) {
    spl_payload(spl)
  }
)

setMethod(
  "payloadmsg", "MultiVarSplit",
  function(spl) "var"
)

setMethod(
  "payloadmsg", "VarLevWBaselineSplit",
  function(spl) {
    paste0(
      spl_payload(spl), "[bsl ",
      spl@ref_group_value, # XXX XXX
      "]"
    )
  }
)

setMethod(
  "payloadmsg", "ManualSplit",
  function(spl) "mnl"
)

setMethod(
  "payloadmsg", "AllSplit",
  function(spl) "all"
)

setMethod(
  "payloadmsg", "ANY",
  function(spl) {
    warning("don't know how to make payload print message for Split of class", class(spl))
    "XXX"
  }
)

spldesc <- function(spl, value = "") {
  value <- rawvalues(value)
  payloadmsg <- payloadmsg(spl)
  format <- "%s (%s)"
  sprintf(
    format,
    value,
    payloadmsg
  )
}

layoutmsg <- function(obj) {
  ## if(!is(obj, "VLayoutNode"))
  ##     stop("how did a non layoutnode object get in docatlayout??")

  pos <- tree_pos(obj)
  spllst <- pos_splits(pos)
  spvallst <- pos_splvals(pos)
  if (is(obj, "LayoutAxisTree")) {
    kids <- tree_children(obj)
    return(unlist(lapply(kids, layoutmsg)))
  }

  msg <- paste(
    collapse = " -> ",
    mapply(spldesc,
      spl = spllst,
      value = spvallst
    )
  )
  msg
}

setMethod(
  "show", "LayoutAxisTree",
  function(object) {
    msg <- layoutmsg(object)
    cat(msg, "\n")
    invisible(object)
  }
)


#' Display column tree structure
#'
#' Displays the tree structure of the columns of a
#' table or column structure object.
#'
#' @inheritParams gen_args
#'
#' @return Nothing, called for its side effect of displaying
#' a summary to the terminal.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   split_cols_by("STRATA1") |>
#'   split_cols_by("SEX", nested = FALSE) |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, ex_adsl)
#' coltree_structure(tbl)
#' @export
coltree_structure <- function(obj) {
  ctree <- coltree(obj)
  cat(layoutmsg2(ctree))
}

lastposmsg <- function(pos) {
  spls <- pos_splits(pos)
  splvals <- value_names(pos_splvals(pos))
  indiv_msgs <- unlist(mapply(function(spl, valnm) paste(obj_name(spl), valnm, sep = ": "),
    spl = spls,
    valnm = splvals,
    SIMPLIFY = FALSE
  ))
  paste(indiv_msgs, collapse = " -> ")
}

layoutmsg2 <- function(obj, level = 1) {
  nm <- obj_name(obj)
  pos <- tree_pos(obj)
  nopos <- identical(pos, EmptyTreePos)

  msg <- paste0(strrep(" ", times = 2 * (level - 1)), "[", nm, "] (", if (nopos) "no pos" else lastposmsg(pos), ")\n")
  if (is(obj, "LayoutAxisTree")) {
    kids <- tree_children(obj)
    msg <- c(msg, unlist(lapply(kids, layoutmsg2, level = level + 1)))
  }
  msg
}

setGeneric("spltype_abbrev", function(obj) standardGeneric("spltype_abbrev"))

setMethod(
  "spltype_abbrev", "VarLevelSplit",
  function(obj) "lvls"
)

setMethod(
  "spltype_abbrev", "VarLevWBaselineSplit",
  function(obj) paste("ref_group", obj@ref_group_value)
)

setMethod(
  "spltype_abbrev", "MultiVarSplit",
  function(obj) "vars"
)

setMethod(
  "spltype_abbrev", "VarStaticCutSplit",
  function(obj) "scut"
)

setMethod(
  "spltype_abbrev", "VarDynCutSplit",
  function(obj) "dcut"
)
setMethod(
  "spltype_abbrev", "AllSplit",
  function(obj) "all obs"
)
## setMethod("spltype_abbrev", "NULLSplit",
##           function(obj) "no obs")

setMethod(
  "spltype_abbrev", "AnalyzeVarSplit",
  function(obj) "** analysis **"
)

setMethod(
  "spltype_abbrev", "CompoundSplit",
  function(obj) paste("compound", paste(sapply(spl_payload(obj), spltype_abbrev), collapse = " "))
)

setMethod(
  "spltype_abbrev", "AnalyzeMultiVars",
  function(obj) "** multivar analysis **"
)
setMethod(
  "spltype_abbrev", "AnalyzeColVarSplit",
  function(obj) "** col-var analysis **"
)

setMethod(
  "spltype_abbrev", "SplitVectorTree",
  function(obj) ""
)

docat_splitvec <- function(object, indent = 0) {
  if (indent > 0) {
    cat(rep(" ", times = indent), sep = "")
  }
  if (length(object) == 1L && is(object[[1]], "VTableNodeInfo")) {
    tab <- object[[1]]
    msg <- sprintf(
      "A Pre-Existing Table [%d x %d]",
      nrow(tab), ncol(tab)
    )
  } else {
    if (is(object, "SplitVectorTree")) {
      return(lapply(object, docat_splitvec))
    }
    plds <- ploads_to_str(object) ## lapply(object, spl_payload))

    tabbrev <- sapply(object, spltype_abbrev)
    msg <- paste(
      collapse = " -> ",
      paste0(plds, " (", tabbrev, ")")
    )
  }
  cat(msg, "\n")
}

setMethod(
  "show", "SplitVector",
  function(object) {
    cat("A SplitVector Pre-defining a Tree Structure\n\n")
    docat_splitvec(object)
    cat("\n")
    invisible(object)
  }
)

docat_predataxis <- function(object, indent = 0) {
  lapply(object, docat_splitvec)
}

setMethod(
  "show", "PreDataColLayout",
  function(object) {
    cat("A Pre-data Column Layout Object\n\n")
    docat_predataxis(object)
    invisible(object)
  }
)

setMethod(
  "show", "PreDataRowLayout",
  function(object) {
    cat("A Pre-data Row Layout Object\n\n")
    docat_predataxis(object)
    invisible(object)
  }
)

setMethod(
  "show", "PreDataTableLayouts",
  function(object) {
    cat("A Pre-data Table Layout\n")
    cat("\nColumn-Split Structure:\n")
    docat_predataxis(object@col_layout)
    cat("\nRow-Split Structure:\n")
    docat_predataxis(object@row_layout)
    cat("\n")
    invisible(object)
  }
)

setMethod(
  "show", "InstantiatedColumnInfo",
  function(object) {
    layoutmsg <- layoutmsg(coltree(object))
    cat("An InstantiatedColumnInfo object",
      "Columns:",
      layoutmsg,
      if (disp_ccounts(object)) {
        paste(
          "ColumnCounts:\n",
          paste(col_counts(object),
            collapse = ", "
          )
        )
      },
      "",
      sep = "\n"
    )
    invisible(object)
  }
)

#' @rdname int_methods
setMethod("print", "VTableTree", function(x, ...) {
  msg <- toString(x, ...)
  cat(msg)
  invisible(x)
})

#' @rdname int_methods
setMethod("show", "VTableTree", function(object) {
  cat(toString(object))
  invisible(object)
})

setMethod("show", "TableRow", function(object) {
  cat(sprintf(
    "[%s indent_mod %d]: %s   %s\n",
    class(object),
    indent_mod(object),
    obj_label(object),
    paste(as.vector(get_formatted_cells(object)),
      collapse = "   "
    )
  ))
  invisible(object)
})
