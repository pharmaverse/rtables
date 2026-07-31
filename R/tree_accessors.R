#' Internal generics and methods
#'
#' These are internal methods that are documented only to satisfy `R CMD check`. End users should pay no
#' attention to this documentation.
#'
#' @param x (`ANY`)\cr the object.
#' @param obj (`ANY`)\cr the object.
#'
#' @name internal_methods
#' @rdname int_methods
#' @aliases int_methods
NULL

#' @return The number of rows (`nrow`), columns (`ncol`), or both (`dim`) of the object.
#'
#' @rdname dimensions
#' @exportMethod nrow
setMethod(
  "nrow", "VTableTree",
  function(x) length(collect_leaves(x, TRUE, TRUE))
)

#' @rdname int_methods
#' @exportMethod nrow
setMethod(
  "nrow", "TableRow",
  function(x) 1L
)

#' Table dimensions
#'
#' @param x (`TableTree` or `ElementaryTable`)\cr a table object.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM") |>
#'   analyze(c("SEX", "AGE"))
#'
#' tbl <- build_table(lyt, ex_adsl)
#'
#' dim(tbl)
#' nrow(tbl)
#' ncol(tbl)
#'
#' NROW(tbl)
#' NCOL(tbl)
#'
#' @rdname dimensions
#' @exportMethod ncol
setMethod(
  "ncol", "VTableNodeInfo",
  function(x) {
    ncol(col_info(x))
  }
)

#' @rdname int_methods
#' @exportMethod ncol
setMethod(
  "ncol", "TableRow",
  function(x) {
    if (!no_colinfo(x)) {
      ncol(col_info(x))
    } else {
      length(spanned_values(x))
    }
  }
)

#' @rdname int_methods
#' @exportMethod ncol
setMethod(
  "ncol", "LabelRow",
  function(x) {
    ncol(col_info(x))
  }
)

#' @rdname int_methods
#' @exportMethod ncol
setMethod(
  "ncol", "InstantiatedColumnInfo",
  function(x) {
    length(col_exprs(x))
  }
)

#' @rdname dimensions
#' @exportMethod dim
setMethod(
  "dim", "VTableNodeInfo",
  function(x) c(nrow(x), ncol(x))
)

#' Retrieve or set the direct children of a tree-style object
#'
#' @param x (`TableTree` or `ElementaryTable`)\cr an object with a tree structure.
#' @param value (`list`)\cr new list of children.
#'
#' @return A list of direct children of `x`.
#'
#' @export
#' @rdname tree_children
setGeneric("tree_children", function(x) standardGeneric("tree_children"))

#' @exportMethod tree_children
#' @rdname int_methods
setMethod(
  "tree_children", c(x = "VTree"),
  function(x) x@children
)

#' @exportMethod tree_children
#' @rdname int_methods
setMethod(
  "tree_children", c(x = "VTableTree"),
  function(x) x@children
)

## this includes VLeaf but also allows for general methods
## needed for table_inset being carried around by rows and
## such.
#' @exportMethod tree_children
#' @rdname int_methods
setMethod(
  "tree_children", c(x = "ANY"), ## "VLeaf"),
  function(x) list()
)

#' @export
#' @rdname tree_children
setGeneric("tree_children<-", function(x, value) standardGeneric("tree_children<-"))

#' @exportMethod tree_children<-
#' @rdname int_methods
setMethod(
  "tree_children<-", c(x = "VTree"),
  function(x, value) {
    x@children <- value
    x
  }
)

#' @exportMethod tree_children<-
#' @rdname int_methods
setMethod(
  "tree_children<-", c(x = "VTableTree"),
  function(x, value) {
    x@children <- value
    x
  }
)

#' Retrieve or set content table from a `TableTree`
#'
#' Returns the content table of `obj` if it is a `TableTree` object, or `NULL` otherwise.
#'
#' @param obj (`TableTree`)\cr the table object.
#'
#' @return the `ElementaryTable` containing the (top level) *content rows* of `obj` (or `NULL` if `obj` is not
#'   a formal table object).
#'
#' @export
#' @rdname content_table
setGeneric("content_table", function(obj) standardGeneric("content_table"))

#' @exportMethod content_table
#' @rdname int_methods
setMethod(
  "content_table", "TableTree",
  function(obj) obj@content
)

#' @exportMethod content_table
#' @rdname int_methods
setMethod(
  "content_table", "ANY",
  function(obj) NULL
)

#' @param value (`ElementaryTable`)\cr the new content table for `obj`.
#'
#' @export
#' @rdname content_table
setGeneric("content_table<-", function(obj, value) standardGeneric("content_table<-"))

#' @exportMethod "content_table<-"
#' @rdname int_methods
setMethod(
  "content_table<-", c("TableTree", "ElementaryTable"),
  function(obj, value) {
    obj@content <- value
    obj
  }
)

#' @param for_analyze (`flag`) whether split is an analyze split.
#' @rdname int_methods
setGeneric("next_rpos", function(obj, nested = TRUE, for_analyze = FALSE) standardGeneric("next_rpos"))

#' @rdname int_methods
setMethod(
  "next_rpos", "PreDataTableLayouts",
  function(obj, nested, for_analyze = FALSE) next_rpos(rlayout(obj), nested, for_analyze = for_analyze)
)

.check_if_nest <- function(obj, nested, for_analyze) {
  if (!nested) {
    FALSE
  } else {
    ## can always nest analyze splits (almost? what about colvars noncolvars mixing? prolly ok?)
    for_analyze ||
      ## If its not an analyze split it can't go under an analyze split
      !(is(last_rowsplit(obj), "VAnalyzeSplit") ||
        is(last_rowsplit(obj), "AnalyzeMultiVars")) ## should this be CompoundSplit? # nolint
  }
}

#' @rdname int_methods
setMethod(
  "next_rpos", "PreDataRowLayout",
  function(obj, nested, for_analyze) {
    l <- length(obj)
    if (length(obj[[l]]) > 0L && !.check_if_nest(obj, nested, for_analyze)) {
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
      obj[[length(obj)]]
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

# rlayout ----
## TODO maybe export these?

#' @rdname int_methods
setGeneric("rlayout", function(obj) standardGeneric("rlayout"))

#' @rdname int_methods
setMethod(
  "rlayout", "PreDataTableLayouts",
  function(obj) obj@row_layout
)

#' @rdname int_methods
setMethod("rlayout", "ANY", function(obj) PreDataRowLayout())

#' @rdname int_methods
setGeneric("rlayout<-", function(object, value) standardGeneric("rlayout<-"))

#' @rdname int_methods
setMethod(
  "rlayout<-", "PreDataTableLayouts",
  function(object, value) {
    object@row_layout <- value
    object
  }
)

#' @rdname int_methods
setGeneric("tree_pos", function(obj) standardGeneric("tree_pos"))

## setMethod("tree_pos", "VNodeInfo",
##           function(obj) obj@pos_in_tree)

#' @rdname int_methods
setMethod(
  "tree_pos", "VLayoutNode",
  function(obj) obj@pos_in_tree
)

#' @rdname int_methods
setGeneric("pos_subset", function(obj) standardGeneric("pos_subset"))

#' @rdname int_methods
setMethod(
  "pos_subset", "TreePos",
  function(obj) obj@subset
)

#' @rdname int_methods
setGeneric("tree_pos<-", function(obj, value) standardGeneric("tree_pos<-"))

#' @rdname int_methods
setMethod(
  "tree_pos<-", "VLayoutNode",
  function(obj, value) {
    obj@pos_in_tree <- value
    obj
  }
)

## setMethod("pos_subset", "VNodeInfo",
##           function(obj) pos_subset(tree_pos(obj)))

#' @rdname int_methods
setMethod(
  "pos_subset", "VLayoutNode",
  function(obj) pos_subset(tree_pos(obj))
)

#' @rdname int_methods
setGeneric("pos_splits", function(obj) standardGeneric("pos_splits"))

#' @rdname int_methods
setMethod(
  "pos_splits", "TreePos",
  function(obj) obj@splits
)

## setMethod("pos_splits", "VNodeInfo",
##           function(obj) pos_splits(tree_pos(obj)))

#' @rdname int_methods
setMethod(
  "pos_splits", "VLayoutNode",
  function(obj) pos_splits(tree_pos(obj))
)

#' @rdname int_methods
setGeneric("pos_splits<-", function(obj, value) standardGeneric("pos_splits<-"))

#' @rdname int_methods
setMethod(
  "pos_splits<-", "TreePos",
  function(obj, value) {
    obj@splits <- value
    obj
  }
)

#' @rdname int_methods
setMethod(
  "pos_splits<-", "VLayoutNode",
  function(obj, value) {
    pos <- tree_pos(obj)
    pos_splits(pos) <- value
    tree_pos(obj) <- pos
    obj
    obj
  }
)


#' @rdname int_methods
setGeneric("pos_splvals", function(obj) standardGeneric("pos_splvals"))

#' @rdname int_methods
setMethod(
  "pos_splvals", "TreePos",
  function(obj) obj@s_values
)

## setMethod("pos_splvals", "VNodeInfo",
##           function(obj) pos_splvals(tree_pos(obj)))

#' @rdname int_methods
setMethod(
  "pos_splvals", "VLayoutNode",
  function(obj) pos_splvals(tree_pos(obj))
)

#' @rdname int_methods
setGeneric("pos_splvals<-", function(obj, value) standardGeneric("pos_splvals<-"))

#' @rdname int_methods
setMethod(
  "pos_splvals<-", "TreePos",
  function(obj, value) {
    obj@s_values <- value
    obj
  }
)

## setMethod("pos_splvals", "VNodeInfo",
##           function(obj) pos_splvals(tree_pos(obj)))

#' @rdname int_methods
setMethod(
  "pos_splvals<-", "VLayoutNode",
  function(obj, value) {
    pos <- tree_pos(obj)
    pos_splvals(pos) <- value
    tree_pos(obj) <- pos
    obj
  }
)


#' @rdname int_methods
setGeneric("pos_splval_labels", function(obj) standardGeneric("pos_splval_labels"))

#' @rdname int_methods
setMethod(
  "pos_splval_labels", "TreePos",
  function(obj) obj@sval_labels
)
## no longer used

## setMethod("pos_splval_labels", "VNodeInfo",
##            function(obj) pos_splval_labels(tree_pos(obj)))
## #' @rdname int_methods
## setMethod("pos_splval_labels", "VLayoutNode",
##            function(obj) pos_splval_labels(tree_pos(obj)))

#' @rdname int_methods
setGeneric("spl_payload", function(obj) standardGeneric("spl_payload"))

#' @rdname int_methods
setMethod("spl_payload", "Split", function(obj) obj@payload)

#' @rdname int_methods
setGeneric("spl_payload<-", function(obj, value) standardGeneric("spl_payload<-"))

#' @rdname int_methods
setMethod("spl_payload<-", "Split", function(obj, value) {
  obj@payload <- value
  obj
})

#' @rdname int_methods
setGeneric("spl_label_var", function(obj) standardGeneric("spl_label_var"))

#' @rdname int_methods
setMethod("spl_label_var", "VarLevelSplit", function(obj) obj@value_label_var)

## TODO revisit. do we want to do this? used in vars_in_layout, but only
## for convenience.
#' @rdname int_methods
setMethod("spl_label_var", "Split", function(obj) NULL)

#' @rdname int_methods
setGeneric("spl_formats_var", function(obj) standardGeneric("spl_formats_var"))

#' @rdname int_methods
setMethod("spl_formats_var", "VAnalyzeSplit", function(obj) obj@row_formats_var)

#' @rdname int_methods
setGeneric("spl_na_strs_var", function(obj) standardGeneric("spl_na_strs_var"))

#' @rdname int_methods
setMethod("spl_na_strs_var", "VAnalyzeSplit", function(obj) obj@row_na_strs_var)

### name related things
# #' @inherit formatters::formatter_methods
#' Methods for generics in the `formatters` package
#'
#' See the `formatters` documentation for descriptions of these generics.
#'
#' @inheritParams gen_args
#'
#' @return
#' * Accessor functions return the current value of the component being accessed of `obj`
#' * Setter functions return a modified copy of `obj` with the new value.
#'
#' @rdname formatters_methods
#' @aliases formatters_methods
#' @exportMethod obj_name
setMethod(
  "obj_name", "VNodeInfo",
  function(obj) obj@name
)

#' @rdname formatters_methods
#' @exportMethod obj_name
setMethod(
  "obj_name", "Split",
  function(obj) obj@name
)

#' @rdname formatters_methods
#' @exportMethod obj_name<-
setMethod(
  "obj_name<-", "VNodeInfo",
  function(obj, value) {
    obj@name <- value
    obj
  }
)

#' @rdname formatters_methods
#' @exportMethod obj_name<-
setMethod(
  "obj_name<-", "Split",
  function(obj, value) {
    obj@name <- value
    obj
  }
)

### Label related things
#' @rdname formatters_methods
#' @exportMethod obj_label
setMethod("obj_label", "Split", function(obj) obj@split_label)

#' @rdname formatters_methods
#' @exportMethod obj_label
setMethod("obj_label", "TableRow", function(obj) obj@label)

## XXX Do we want a convenience for VTableTree that
## grabs the label from the LabelRow or will
## that just muddy the waters?
#' @rdname formatters_methods
#' @exportMethod obj_label
setMethod(
  "obj_label", "VTableTree",
  function(obj) obj_label(tt_labelrow(obj))
)

#' @rdname formatters_methods
#' @exportMethod obj_label
setMethod("obj_label", "ValueWrapper", function(obj) obj@label)

#' @rdname formatters_methods
#' @exportMethod obj_label<-
setMethod(
  "obj_label<-", "Split",
  function(obj, value) {
    obj@split_label <- value
    obj
  }
)

#' @rdname formatters_methods
#' @exportMethod obj_label<-
setMethod(
  "obj_label<-", "TableRow",
  function(obj, value) {
    obj@label <- value
    obj
  }
)

#' @rdname formatters_methods
#' @exportMethod obj_label<-
setMethod(
  "obj_label<-", "ValueWrapper",
  function(obj, value) {
    obj@label <- value
    obj
  }
)

#' @rdname formatters_methods
#' @exportMethod obj_label<-
setMethod(
  "obj_label<-", "VTableTree",
  function(obj, value) {
    lr <- tt_labelrow(obj)
    obj_label(lr) <- value
    if (!is.na(value) && nzchar(value)) {
      labelrow_visible(lr) <- TRUE
    } else if (is.na(value)) {
      labelrow_visible(lr) <- FALSE
    }
    tt_labelrow(obj) <- lr
    obj
  }
)

### Label rows.
#' @rdname int_methods
setGeneric("tt_labelrow", function(obj) standardGeneric("tt_labelrow"))

#' @rdname int_methods
setMethod(
  "tt_labelrow", "VTableTree",
  function(obj) obj@labelrow
)

#' @rdname int_methods
setGeneric("tt_labelrow<-", function(obj, value) standardGeneric("tt_labelrow<-"))

#' @rdname int_methods
setMethod(
  "tt_labelrow<-", c("VTableTree", "LabelRow"),
  function(obj, value) {
    if (no_colinfo(value)) {
      col_info(value) <- col_info(obj)
    }
    obj@labelrow <- value
    obj
  }
)

#' @rdname int_methods
setGeneric("labelrow_visible", function(obj) standardGeneric("labelrow_visible"))

#' @rdname int_methods
setMethod(
  "labelrow_visible", "VTableTree",
  function(obj) {
    labelrow_visible(tt_labelrow(obj))
  }
)

#' @rdname int_methods
setMethod(
  "labelrow_visible", "LabelRow",
  function(obj) obj@visible
)

#' @rdname int_methods
setMethod(
  "labelrow_visible", "VAnalyzeSplit",
  function(obj) .labelkids_helper(obj@var_label_position)
)

#' @rdname int_methods
setGeneric("labelrow_visible<-", function(obj, value) standardGeneric("labelrow_visible<-"))

#' @rdname int_methods
setMethod(
  "labelrow_visible<-", "VTableTree",
  function(obj, value) {
    lr <- tt_labelrow(obj)
    labelrow_visible(lr) <- value
    tt_labelrow(obj) <- lr
    obj
  }
)

#' @rdname int_methods
setMethod(
  "labelrow_visible<-", "LabelRow",
  function(obj, value) {
    obj@visible <- value
    obj
  }
)

#' @rdname int_methods
setMethod(
  "labelrow_visible<-", "VAnalyzeSplit",
  function(obj, value) {
    obj@var_label_position <- value
    obj
  }
)

## TRUE is always, FALSE is never, NA is only when no
## content function (or rows in an instantiated table) is present
#' @rdname int_methods
setGeneric("label_kids", function(spl) standardGeneric("label_kids"))

#' @rdname int_methods
setMethod("label_kids", "Split", function(spl) spl@label_children)

#' @rdname int_methods
setGeneric("label_kids<-", function(spl, value) standardGeneric("label_kids<-"))

#' @rdname int_methods
setMethod("label_kids<-", c("Split", "character"), function(spl, value) {
  label_kids(spl) <- .labelkids_helper(value)
  spl
})

#' @rdname int_methods
setMethod("label_kids<-", c("Split", "logical"), function(spl, value) {
  spl@label_children <- value
  spl
})

#' @rdname int_methods
setGeneric("vis_label", function(spl) standardGeneric("vis_label"))

#' @rdname int_methods
setMethod("vis_label", "Split", function(spl) {
  .labelkids_helper(label_position(spl))
})

## #' @rdname int_methods
## setGeneric("vis_label<-", function(spl, value) standardGeneric("vis_label<-"))
## #' @rdname int_methods
## setMethod("vis_label<-", "Split", function(spl, value) {
##     stop("defunct")
##     if(is.na(value))
##         stop("split label visibility must be TRUE or FALSE, got NA")
## #    spl@split_label_visible <- value
##     spl
## })

#' @rdname int_methods
setGeneric("label_position", function(spl) standardGeneric("label_position"))

#' @rdname int_methods
setMethod("label_position", "Split", function(spl) spl@split_label_position)

#' @rdname int_methods
setMethod("label_position", "VAnalyzeSplit", function(spl) spl@var_label_position) ## split_label_position)

#' @rdname int_methods
setGeneric("label_position<-", function(spl, value) standardGeneric("label_position<-"))

#' @rdname int_methods
setMethod("label_position<-", "Split", function(spl, value) {
  value <- match.arg(value, valid_lbl_pos)
  spl@split_label_position <- value
  spl
})

### Function accessors (summary, tabulation and split) ----

#' @rdname int_methods
setGeneric("content_fun", function(obj) standardGeneric("content_fun"))

#' @rdname int_methods
setMethod("content_fun", "Split", function(obj) obj@content_fun)

#' @rdname int_methods
setGeneric("content_fun<-", function(object, value) standardGeneric("content_fun<-"))

#' @rdname int_methods
setMethod("content_fun<-", "Split", function(object, value) {
  object@content_fun <- value
  object
})

#' @rdname int_methods
setGeneric("analysis_fun", function(obj) standardGeneric("analysis_fun"))

#' @rdname int_methods
setMethod("analysis_fun", "AnalyzeVarSplit", function(obj) obj@analysis_fun)

#' @rdname int_methods
setMethod("analysis_fun", "AnalyzeColVarSplit", function(obj) obj@analysis_fun)

## not used and probably not needed
## #' @rdname int_methods
## setGeneric("analysis_fun<-", function(object, value) standardGeneric("analysis_fun<-"))

## #' @rdname int_methods
## setMethod("analysis_fun<-", "AnalyzeVarSplit", function(object, value) {
##     object@analysis_fun <- value
##     object
## })
## #' @rdname int_methods
## setMethod("analysis_fun<-", "AnalyzeColVarSplit", function(object, value) {
##     if(is(value, "function"))
##         value <- list(value)
##     object@analysis_fun <- value
##     object
## })

#' @rdname int_methods
setGeneric("split_fun", function(obj) standardGeneric("split_fun"))

#' @rdname int_methods
setMethod("split_fun", "CustomizableSplit", function(obj) obj@split_fun)

## Only that type of split currently has the slot
## this should probably change? for now  define
## an accessor that just returns NULL
#' @rdname int_methods
setMethod("split_fun", "Split", function(obj) NULL)

#' @rdname int_methods
setGeneric("split_fun<-", function(obj, value) standardGeneric("split_fun<-"))

#' @rdname int_methods
setMethod("split_fun<-", "CustomizableSplit", function(obj, value) {
  obj@split_fun <- value
  obj
})

# nocov start
## Only that type of split currently has the slot
## this should probably change? for now  define
## an accessor that just returns NULL
#' @rdname int_methods
setMethod(
  "split_fun<-", "Split",
  function(obj, value) {
    stop(
      "Attempted to set a custom split function on a non-customizable split.",
      "This should not happen, please contact the maintainers."
    )
  }
)
# nocov end

## Content specification related accessors ----

#' @rdname int_methods
setGeneric("content_extra_args", function(obj) standardGeneric("content_extra_args"))

#' @rdname int_methods
setMethod("content_extra_args", "Split", function(obj) obj@content_extra_args)

#' @rdname int_methods
setGeneric("content_extra_args<-", function(object, value) standardGeneric("content_extra_args<-"))

#' @rdname int_methods
setMethod("content_extra_args<-", "Split", function(object, value) {
  object@content_extra_args <- value
  object
})

#' @rdname int_methods
setGeneric("content_var", function(obj) standardGeneric("content_var"))

#' @rdname int_methods
setMethod("content_var", "Split", function(obj) obj@content_var)

#' @rdname int_methods
setGeneric("content_var<-", function(object, value) standardGeneric("content_var<-"))

#' @rdname int_methods
setMethod("content_var<-", "Split", function(object, value) {
  object@content_var <- value
  object
})

### Miscellaneous accessors ----

#' @rdname int_methods
setGeneric("avar_inclNAs", function(obj) standardGeneric("avar_inclNAs"))

#' @rdname int_methods
setMethod(
  "avar_inclNAs", "VAnalyzeSplit",
  function(obj) obj@include_NAs
)

#' @rdname int_methods
setGeneric("avar_inclNAs<-", function(obj, value) standardGeneric("avar_inclNAs<-"))

#' @rdname int_methods
setMethod(
  "avar_inclNAs<-", "VAnalyzeSplit",
  function(obj, value) {
    obj@include_NAs <- value
  }
)

#' @rdname int_methods
setGeneric("spl_labelvar", function(obj) standardGeneric("spl_labelvar"))

#' @rdname int_methods
setMethod("spl_labelvar", "VarLevelSplit", function(obj) obj@value_label_var)

#' @rdname int_methods
setGeneric("spl_child_order", function(obj) standardGeneric("spl_child_order"))

#' @rdname int_methods
setMethod("spl_child_order", "VarLevelSplit", function(obj) obj@value_order)

#' @rdname int_methods
setGeneric(
  "spl_child_order<-",
  function(obj, value) standardGeneric("spl_child_order<-")
)

#' @rdname int_methods
setMethod(
  "spl_child_order<-", "VarLevelSplit",
  function(obj, value) {
    obj@value_order <- value
    obj
  }
)

#' @rdname int_methods
setMethod(
  "spl_child_order",
  "ManualSplit",
  function(obj) obj@levels
)

#' @rdname int_methods
setMethod(
  "spl_child_order",
  "MultiVarSplit",
  function(obj) spl_varnames(obj)
)

#' @rdname int_methods
setMethod(
  "spl_child_order",
  "AllSplit",
  function(obj) character()
)

#' @rdname int_methods
setMethod(
  "spl_child_order",
  "VarStaticCutSplit",
  function(obj) spl_cutlabels(obj)
)

#' @rdname int_methods
setGeneric("root_spl", function(obj) standardGeneric("root_spl"))

#' @rdname int_methods
setMethod(
  "root_spl", "PreDataAxisLayout",
  function(obj) obj@root_split
)

#' @rdname int_methods
setGeneric("root_spl<-", function(obj, value) standardGeneric("root_spl<-"))

#' @rdname int_methods
setMethod(
  "root_spl<-", "PreDataAxisLayout",
  function(obj, value) {
    obj@root_split <- value
    obj
  }
)

#' Row attribute accessors
#'
#' @inheritParams gen_args
#'
#' @return Various return values depending on the accessor called.
#'
#' @export
#' @rdname row_accessors
setGeneric("obj_avar", function(obj) standardGeneric("obj_avar"))

#' @rdname row_accessors
#' @exportMethod obj_avar
setMethod("obj_avar", "TableRow", function(obj) obj@var_analyzed)

#' @rdname row_accessors
#' @exportMethod obj_avar
setMethod("obj_avar", "ElementaryTable", function(obj) obj@var_analyzed)

#' @export
#' @rdname row_accessors
setGeneric("row_cells", function(obj) standardGeneric("row_cells"))

#' @rdname row_accessors
#' @exportMethod row_cells
setMethod("row_cells", "TableRow", function(obj) obj@leaf_value)

#' @rdname row_accessors
#' @exportMethod row_cells
setMethod("row_cells", "RowsVerticalSection", function(obj) as(obj, "list", strict = TRUE))

#' @rdname row_accessors
setGeneric("row_cells<-", function(obj, value) standardGeneric("row_cells<-"))

#' @rdname row_accessors
#' @exportMethod row_cells
setMethod("row_cells<-", "TableRow", function(obj, value) {
  obj@leaf_value <- value
  obj
})

#' @export
#' @rdname row_accessors
setGeneric("row_values", function(obj) standardGeneric("row_values"))

#' @rdname row_accessors
#' @exportMethod row_values
setMethod("row_values", "TableRow", function(obj) rawvalues(obj@leaf_value))

#' @rdname row_accessors
#' @exportMethod row_values<-
setGeneric("row_values<-", function(obj, value) standardGeneric("row_values<-"))

#' @rdname row_accessors
#' @exportMethod row_values<-
setMethod(
  "row_values<-", "TableRow",
  function(obj, value) {
    obj@leaf_value <- lapply(value, rcell)
    obj
  }
)

#' @rdname row_accessors
#' @exportMethod row_values<-
setMethod(
  "row_values<-", "LabelRow",
  function(obj, value) {
    stop("LabelRows cannot have row values.")
  }
)

#' @rdname int_methods
setGeneric("spanned_values", function(obj) standardGeneric("spanned_values"))

#' @rdname int_methods
setMethod(
  "spanned_values", "TableRow",
  function(obj) {
    rawvalues(spanned_cells(obj))
  }
)

#' @rdname int_methods
setMethod(
  "spanned_values", "LabelRow",
  function(obj) {
    rep(list(NULL), ncol(obj))
  }
)

#' @rdname int_methods
setGeneric("spanned_cells", function(obj) standardGeneric("spanned_cells"))

#' @rdname int_methods
setMethod(
  "spanned_cells", "TableRow",
  function(obj) {
    sp <- row_cspans(obj)
    rvals <- row_cells(obj)
    unlist(
      mapply(function(v, s) rep(list(v), times = s),
        v = rvals, s = sp
      ),
      recursive = FALSE
    )
  }
)

#' @rdname int_methods
setMethod(
  "spanned_cells", "LabelRow",
  function(obj) {
    rep(list(NULL), ncol(obj))
  }
)

#' @rdname int_methods
setGeneric("spanned_values<-", function(obj, value) standardGeneric("spanned_values<-"))

#' @rdname int_methods
setMethod(
  "spanned_values<-", "TableRow",
  function(obj, value) {
    sp <- row_cspans(obj)
    ## this is 3 times too clever!!!
    valindices <- unlist(lapply(sp, function(x) c(TRUE, rep(FALSE, x - 1))))

    splvec <- cumsum(valindices)
    lapply(
      split(value, splvec),
      function(v) {
        if (length(unique(v)) > 1) {
          stop(
            "Got more than one unique value within a span, ",
            "new spanned values do not appear to match the ",
            "existing spanning pattern of the row (",
            paste(sp, collapse = " "), ")"
          )
        }
      }
    )
    rvals <- value[valindices]

    ## rvals = lapply(split(value, splvec),
    ##                function(v) {
    ##     if(length(v) == 1)
    ##         return(v)
    ##     stopifnot(length(unique(v)) == 1L)
    ##     rcell(unique(v), colspan<- length(v))
    ## })
    ## if(any(splvec > 1))
    ##     rvals <- lapply(rvals, function(x) x[[1]])
    row_values(obj) <- rvals
    obj
  }
)

#' @rdname int_methods
setMethod(
  "spanned_values<-", "LabelRow",
  function(obj, value) {
    if (!is.null(value)) {
      stop("Label rows can't have non-null cell values, got", value)
    }
    obj
  }
)

### Format manipulation
### obj_format<- is not recursive
## TODO export these?
#' @rdname formatters_methods
#' @export
setMethod("obj_format", "VTableNodeInfo", function(obj) obj@format)

#' @rdname formatters_methods
#' @export
setMethod("obj_format", "CellValue", function(obj) attr(obj, "format", exact = TRUE))

#' @rdname formatters_methods
#' @export
setMethod("obj_format", "Split", function(obj) obj@split_format)

#' @rdname formatters_methods
#' @export
setMethod("obj_format", "RowsVerticalSection", function(obj) attr(obj, "row_formats", exact = TRUE))

#' @rdname formatters_methods
#' @export
setMethod("obj_format<-", "VTableNodeInfo", function(obj, value) {
  obj@format <- value
  obj
})


#' @rdname formatters_methods
#' @export
setMethod("obj_format<-", "Split", function(obj, value) {
  obj@split_format <- value
  obj
})

#' @rdname formatters_methods
#' @export
setMethod("obj_format<-", "CellValue", function(obj, value) {
  attr(obj, "format") <- value
  obj
})

#' @rdname formatters_methods
#' @export
setMethod("obj_format<-", "RowsVerticalSection", function(obj, value) {
  attr(obj, "row_formats") <- value
  obj
})

#' @rdname int_methods
#' @export
setMethod("obj_na_str<-", "CellValue", function(obj, value) {
  attr(obj, "format_na_str") <- value
  obj
})

#' @rdname int_methods
#' @export
setMethod("obj_na_str<-", "RowsVerticalSection", function(obj, value) {
  attr(obj, "row_na_strs") <- value
  obj
})

#' @rdname int_methods
#' @export
setMethod("obj_na_str<-", "VTableNodeInfo", function(obj, value) {
  obj@na_str <- value
  obj
})

#' @rdname int_methods
#' @export
setMethod("obj_na_str<-", "Split", function(obj, value) {
  obj@split_na_str <- value
  obj
})

#' @rdname int_methods
#' @export
setMethod("obj_na_str", "VTableNodeInfo", function(obj) obj@na_str)

#' @rdname int_methods
#' @export
setMethod("obj_na_str", "RowsVerticalSection", function(obj) attr(obj, "row_na_strs", exact = TRUE))

#' @rdname formatters_methods
#' @export
setMethod("obj_na_str", "Split", function(obj) obj@split_na_str)

.no_na_str <- function(x) {
  if (!is.character(x)) {
    x <- obj_na_str(x)
  }
  length(x) == 0 || all(is.na(x))
}

#' @rdname int_methods
setGeneric("set_format_recursive", function(obj, format, na_str, override = FALSE) {
  standardGeneric("set_format_recursive")
})

fmt_can_inherit <- function(obj, fmt = obj_format(obj)) {
  is.null(fmt) || identical(fmt, "default")
}

#' @param override (`flag`)\cr whether to override attribute.
#'
#' @rdname int_methods
setMethod(
  "set_format_recursive", "TableRow",
  function(obj, format, na_str, override = FALSE) {
    if (is.null(format) && .no_na_str(na_str)) {
      return(obj)
    }

    if ((fmt_can_inherit(obj) && !is.null(format)) || override) {
      obj_format(obj) <- format
    }
    if ((.no_na_str(obj) && !.no_na_str(na_str)) || override) {
      obj_na_str(obj) <- na_str
    }
    lcells <- row_cells(obj)
    lvals <- lapply(lcells, function(x) {
      if (!is.null(x) && (override || fmt_can_inherit(x))) {
        obj_format(x) <- obj_format(obj)
      }
      if (!is.null(x) && (override || .no_na_str(x))) {
        obj_na_str(x) <- obj_na_str(obj)
      }
      x
    })
    row_values(obj) <- lvals
    obj
  }
)

#' @rdname int_methods
setMethod(
  "set_format_recursive", "LabelRow",
  function(obj, format, override = FALSE) obj
)

setMethod(
  "set_format_recursive", "VTableTree",
  function(obj, format, na_str, override = FALSE) {
    force(format)
    if (is.null(format) && .no_na_str(na_str)) {
      return(obj)
    }

    if ((fmt_can_inherit(obj) && !is.null(format)) || override) {
      obj_format(obj) <- format
    }
    if ((.no_na_str(obj) && !.no_na_str(na_str)) || override) {
      obj_na_str(obj) <- na_str
    }

    kids <- tree_children(obj)
    kids <- lapply(kids, function(x, format2, na_str2, oride) {
      set_format_recursive(x,
        format = format2, na_str = na_str2, override = oride
      )
    },
    format2 = obj_format(obj), na_str2 = obj_na_str(obj), oride = override
    )
    tree_children(obj) <- kids
    obj
  }
)

#' @rdname int_methods
setGeneric("content_format", function(obj) standardGeneric("content_format"))

#' @rdname int_methods
setMethod("content_format", "Split", function(obj) obj@content_format)

#' @rdname int_methods
setGeneric("content_format<-", function(obj, value) standardGeneric("content_format<-"))

#' @rdname int_methods
setMethod("content_format<-", "Split", function(obj, value) {
  obj@content_format <- value
  obj
})

#' @rdname int_methods
setGeneric("content_na_str", function(obj) standardGeneric("content_na_str"))

#' @rdname int_methods
setMethod("content_na_str", "Split", function(obj) obj@content_na_str)

#' @rdname int_methods
setGeneric("content_na_str<-", function(obj, value) standardGeneric("content_na_str<-"))

#' @rdname int_methods
setMethod("content_na_str<-", "Split", function(obj, value) {
  obj@content_na_str <- value
  obj
})

#' Value formats
#'
#' Returns a matrix of formats for the cells in a table.
#'
#' @param obj (`VTableTree` or `TableRow`)\cr a table or row object.
#' @param default (`string`, `function`, or `list`)\cr default format.
#'
#' @return Matrix (storage mode list) containing the effective format for each cell position in the table
#'   (including 'virtual' cells implied by label rows, whose formats are always `NULL`).
#'
#' @seealso [table_shell()] and [table_shell_str()] for information on the table format structure.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_rows_by("RACE", split_fun = keep_split_levels(c("ASIAN", "WHITE"))) |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, DM)
#' value_formats(tbl)
#'
#' @export
setGeneric("value_formats", function(obj, default = obj_format(obj)) standardGeneric("value_formats"))

#' @rdname value_formats
setMethod(
  "value_formats", "ANY",
  function(obj, default) {
    obj_format(obj) %||% default
  }
)

#' @rdname value_formats
setMethod(
  "value_formats", "TableRow",
  function(obj, default) {
    if (!is.null(obj_format(obj))) {
      default <- obj_format(obj)
    }
    formats <- lapply(row_cells(obj), function(x) value_formats(x) %||% default)
    formats
  }
)

#' @rdname value_formats
setMethod(
  "value_formats", "LabelRow",
  function(obj, default) {
    rep(list(NULL), ncol(obj))
  }
)

#' @rdname value_formats
setMethod(
  "value_formats", "VTableTree",
  function(obj, default) {
    if (!is.null(obj_format(obj))) {
      default <- obj_format(obj)
    }
    rws <- collect_leaves(obj, TRUE, TRUE)
    formatrws <- lapply(rws, value_formats, default = default)
    mat <- do.call(rbind, formatrws)
    row.names(mat) <- row.names(obj)
    mat
  }
)

### Collect all leaves of a current tree
### This is a workhorse function in various
### places
### NB this is written generally enought o
### be used on all tree-based structures in the
### framework.

#' Collect leaves of a `TableTree`
#'
#' @inheritParams gen_args
#' @param incl.cont (`flag`)\cr whether to include rows from content tables within the tree. Defaults to `TRUE`.
#' @param add.labrows (`flag`)\cr whether to include label rows. Defaults to `FALSE`.
#'
#' @return A list of `TableRow` objects for all rows in the table.
#'
#' @export
setGeneric("collect_leaves",
  function(tt, incl.cont = TRUE, add.labrows = FALSE) {
    standardGeneric("collect_leaves")
  },
  signature = "tt"
)

#' @inheritParams collect_leaves
#'
#' @rdname int_methods
#' @exportMethod collect_leaves
setMethod(
  "collect_leaves", "TableTree",
  function(tt, incl.cont = TRUE, add.labrows = FALSE) {
    ret <- c(
      if (add.labrows && labelrow_visible(tt)) {
        tt_labelrow(tt)
      },
      if (incl.cont) {
        tree_children(content_table(tt))
      },
      lapply(tree_children(tt),
        collect_leaves,
        incl.cont = incl.cont, add.labrows = add.labrows
      )
    )
    unlist(ret, recursive = TRUE)
  }
)

#' @rdname int_methods
#' @exportMethod collect_leaves
setMethod(
  "collect_leaves", "ElementaryTable",
  function(tt, incl.cont = TRUE, add.labrows = FALSE) {
    ret <- tree_children(tt)
    if (add.labrows && labelrow_visible(tt)) {
      ret <- c(tt_labelrow(tt), ret)
    }
    ret
  }
)

#' @rdname int_methods
#' @exportMethod collect_leaves
setMethod(
  "collect_leaves", "VTree",
  function(tt, incl.cont, add.labrows) {
    ret <- lapply(
      tree_children(tt),
      collect_leaves
    )
    unlist(ret, recursive = TRUE)
  }
)

#' @rdname int_methods
#' @exportMethod collect_leaves
setMethod(
  "collect_leaves", "VLeaf",
  function(tt, incl.cont, add.labrows) {
    list(tt)
  }
)

#' @rdname int_methods
#' @exportMethod collect_leaves
setMethod(
  "collect_leaves", "NULL",
  function(tt, incl.cont, add.labrows) {
    list()
  }
)

#' @rdname int_methods
#' @exportMethod collect_leaves
setMethod(
  "collect_leaves", "ANY",
  function(tt, incl.cont, add.labrows) {
    stop("class ", class(tt), " does not inherit from VTree or VLeaf")
  }
)

n_leaves <- function(tt, ...) {
  length(collect_leaves(tt, ...))
}

### Spanning information ----

#' @rdname int_methods
setGeneric("row_cspans", function(obj) standardGeneric("row_cspans"))

#' @rdname int_methods
setMethod("row_cspans", "TableRow", function(obj) obj@colspans)

#' @rdname int_methods
setMethod(
  "row_cspans", "LabelRow",
  function(obj) rep(1L, ncol(obj))
)

#' @rdname int_methods
setGeneric("row_cspans<-", function(obj, value) standardGeneric("row_cspans<-"))

#' @rdname int_methods
setMethod("row_cspans<-", "TableRow", function(obj, value) {
  obj@colspans <- value
  obj
})

#' @rdname int_methods
setMethod("row_cspans<-", "LabelRow", function(obj, value) {
  stop("attempted to set colspans for LabelRow") # nocov
})

## XXX TODO colapse with above?
#' @rdname int_methods
setGeneric("cell_cspan", function(obj) standardGeneric("cell_cspan"))

#' @rdname int_methods
setMethod(
  "cell_cspan", "CellValue",
  function(obj) attr(obj, "colspan", exact = TRUE)
) ## obj@colspan)

#' @rdname int_methods
setGeneric(
  "cell_cspan<-",
  function(obj, value) standardGeneric("cell_cspan<-")
)

#' @rdname int_methods
setMethod("cell_cspan<-", "CellValue", function(obj, value) {
  ##  obj@colspan <- value
  attr(obj, "colspan") <- value
  obj
})

#' @rdname int_methods
setGeneric("cell_align", function(obj) standardGeneric("cell_align"))

#' @rdname int_methods
setMethod(
  "cell_align", "CellValue",
  function(obj) attr(obj, "align", exact = TRUE) %||% "center"
) ## obj@colspan)

#' @rdname int_methods
setGeneric(
  "cell_align<-",
  function(obj, value) standardGeneric("cell_align<-")
)

#' @rdname int_methods
setMethod("cell_align<-", "CellValue", function(obj, value) {
  ##  obj@colspan <- value
  if (is.null(value)) {
    value <- "center"
  } else {
    value <- tolower(value)
  }
  check_aligns(value)
  attr(obj, "align") <- value
  obj
})

### Level (indent) in tree structure ----

#' @rdname int_methods
setGeneric("tt_level", function(obj) standardGeneric("tt_level"))

## this will hit everything via inheritence
#' @rdname int_methods
setMethod("tt_level", "VNodeInfo", function(obj) obj@level)

#' @rdname int_methods
setGeneric("tt_level<-", function(obj, value) standardGeneric("tt_level<-"))

## this will hit everyhing via inheritence
#' @rdname int_methods
setMethod("tt_level<-", "VNodeInfo", function(obj, value) {
  obj@level <- as.integer(value)
  obj
})

#' @rdname int_methods
setMethod(
  "tt_level<-", "VTableTree",
  function(obj, value) {
    obj@level <- as.integer(value)
    tree_children(obj) <- lapply(tree_children(obj),
      `tt_level<-`,
      value = as.integer(value) + 1L
    )
    obj
  }
)

#' @rdname int_methods
#' @export
setGeneric("indent_mod", function(obj) standardGeneric("indent_mod"))

#' @rdname int_methods
setMethod(
  "indent_mod", "Split",
  function(obj) obj@indent_modifier
)

#' @rdname int_methods
setMethod(
  "indent_mod", "VTableNodeInfo",
  function(obj) obj@indent_modifier
)

#' @rdname int_methods
setMethod(
  "indent_mod", "ANY",
  function(obj) attr(obj, "indent_mod", exact = TRUE) %||% 0L
)

#' @rdname int_methods
setMethod(
  "indent_mod", "RowsVerticalSection",
  ##          function(obj) setNames(obj@indent_mods,names(obj)))
  function(obj) {
    val <- attr(obj, "indent_mods", exact = TRUE) %||%
      vapply(obj, indent_mod, 1L) ## rep(0L, length(obj))
    setNames(val, names(obj))
  }
)

#' @examples
#' lyt <- basic_table() |>
#'   split_rows_by("RACE", split_fun = keep_split_levels(c("ASIAN", "WHITE"))) |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, DM)
#' indent_mod(tbl)
#' indent_mod(tbl) <- 1L
#' tbl
#'
#' @rdname int_methods
#' @export
setGeneric("indent_mod<-", function(obj, value) standardGeneric("indent_mod<-"))

#' @rdname int_methods
setMethod(
  "indent_mod<-", "Split",
  function(obj, value) {
    obj@indent_modifier <- as.integer(value)
    obj
  }
)

#' @rdname int_methods
setMethod(
  "indent_mod<-", "VTableNodeInfo",
  function(obj, value) {
    obj@indent_modifier <- as.integer(value)
    obj
  }
)

#' @rdname int_methods
setMethod(
  "indent_mod<-", "CellValue",
  function(obj, value) {
    attr(obj, "indent_mod") <- as.integer(value)
    obj
  }
)

#' @rdname int_methods
setMethod(
  "indent_mod<-", "RowsVerticalSection",
  function(obj, value) {
    if (length(value) != 1 && length(value) != length(obj)) {
      stop(
        "When setting indent mods on a RowsVerticalSection the value ",
        "must have length 1 or the number of rows"
      )
    }
    attr(obj, "indent_mods") <- rep(as.integer(value), length.out = length(obj))
    obj

    ## obj@indent_mods <- value
    ## obj
  }
)

#' @rdname int_methods
setGeneric(
  "content_indent_mod",
  function(obj) standardGeneric("content_indent_mod")
)

#' @rdname int_methods
setMethod(
  "content_indent_mod", "Split",
  function(obj) obj@content_indent_modifier
)

#' @rdname int_methods
setMethod(
  "content_indent_mod", "VTableNodeInfo",
  function(obj) obj@content_indent_modifier
)

#' @rdname int_methods
setGeneric(
  "content_indent_mod<-",
  function(obj, value) standardGeneric("content_indent_mod<-")
)

#' @rdname int_methods
setMethod(
  "content_indent_mod<-", "Split",
  function(obj, value) {
    obj@content_indent_modifier <- as.integer(value)
    obj
  }
)

#' @rdname int_methods
setMethod(
  "content_indent_mod<-", "VTableNodeInfo",
  function(obj, value) {
    obj@content_indent_modifier <- as.integer(value)
    obj
  }
)

## TODO export these?
#' @rdname int_methods
#' @export
setGeneric("rawvalues", function(obj) standardGeneric("rawvalues"))

#' @rdname int_methods
setMethod("rawvalues", "ValueWrapper", function(obj) obj@value)

#' @rdname int_methods
setMethod("rawvalues", "LevelComboSplitValue", function(obj) obj@combolevels)

#' @rdname int_methods
setMethod("rawvalues", "list", function(obj) lapply(obj, rawvalues))

#' @rdname int_methods
setMethod("rawvalues", "ANY", function(obj) obj)

#' @rdname int_methods
setMethod("rawvalues", "CellValue", function(obj) obj[[1]])

#' @rdname int_methods
setMethod(
  "rawvalues", "TreePos",
  function(obj) rawvalues(pos_splvals(obj))
)

#' @rdname int_methods
setMethod(
  "rawvalues", "RowsVerticalSection",
  function(obj) unlist(obj, recursive = FALSE)
)

#' @rdname int_methods
#' @export
setGeneric("value_names", function(obj) standardGeneric("value_names"))

#' @rdname int_methods
setMethod(
  "value_names", "ANY",
  function(obj) as.character(rawvalues(obj))
)

#' @rdname int_methods
setMethod(
  "value_names", "TreePos",
  function(obj) value_names(pos_splvals(obj))
)

#' @rdname int_methods
setMethod(
  "value_names", "list",
  function(obj) lapply(obj, value_names)
)

#' @rdname int_methods
setMethod(
  "value_names", "ValueWrapper",
  function(obj) rawvalues(obj)
)

#' @rdname int_methods
setMethod(
  "value_names", "LevelComboSplitValue",
  function(obj) obj@value
) ## obj@comboname)

#' @rdname int_methods
setMethod(
  "value_names", "RowsVerticalSection",
  function(obj) attr(obj, "row_names", exact = TRUE)
) ## obj@row_names)

## not sure if I need these anywhere
## XXX
#' @rdname int_methods
setGeneric("value_labels", function(obj) standardGeneric("value_labels"))

#' @rdname int_methods
setMethod("value_labels", "ANY", function(obj) as.character(obj_label(obj)))

#' @rdname int_methods
setMethod(
  "value_labels", "TreePos",
  function(obj) sapply(pos_splvals(obj), obj_label)
)

#' @rdname int_methods
setMethod("value_labels", "list", function(obj) {
  ret <- lapply(obj, obj_label)
  if (!is.null(names(obj))) {
    inds <- vapply(ret, function(x) length(x) == 0, NA)
    ret[inds] <- names(obj)[inds]
  }
  ret
})

#' @rdname int_methods
setMethod(
  "value_labels",
  "RowsVerticalSection",
  function(obj) setNames(attr(obj, "row_labels", exact = TRUE), value_names(obj))
)

#' @rdname int_methods
setMethod("value_labels", "ValueWrapper", function(obj) obj_label(obj))

#' @rdname int_methods
setMethod(
  "value_labels", "LevelComboSplitValue",
  function(obj) obj_label(obj)
)

#' @rdname int_methods
setMethod("value_labels", "MultiVarSplit", function(obj) obj@var_labels)

#' Retrieve the subset expression from a split value
#'
#' Returns the subsetting expression associated with a `SplitValue` (or
#' `ValueWrapper`) object, or `NULL` for objects without one.  This expression
#' is used internally to subset data when tabulating.
#'
#' @param obj (`ValueWrapper` or `ANY`)\cr a split value object, typically a
#'   `SplitValue` constructed by [SplitValue()].  Any other object returns
#'   `NULL`.
#'
#' @return An `expression` object, or `NULL`.
#'
#' @examples
#' sv <- SplitValue("A", sub_expr = expression(ARM == "A"))
#' value_expr(sv)
#'
#' value_expr("not a SplitValue") # NULL
#'
#' @export
#' @rdname value_expr
setGeneric("value_expr", function(obj) standardGeneric("value_expr"))
#' @exportMethod value_expr
#' @rdname value_expr
setMethod("value_expr", "ValueWrapper", function(obj) obj@subset_expression)
#' @exportMethod value_expr
#' @rdname value_expr
setMethod("value_expr", "ANY", function(obj) NULL)
## no setters for now, we'll see about that.

#' @rdname int_methods
setGeneric("spl_varlabels", function(obj) standardGeneric("spl_varlabels"))

#' @rdname int_methods
setMethod("spl_varlabels", "MultiVarSplit", function(obj) obj@var_labels)

#' @rdname int_methods
setGeneric(
  "spl_varlabels<-",
  function(object, value) standardGeneric("spl_varlabels<-")
)

#' @rdname int_methods
setMethod("spl_varlabels<-", "MultiVarSplit", function(object, value) {
  object@var_labels <- value
  object
})

## These two are similar enough we could probably combine
## them but conceptually they are pretty different
## split_exargs is a list of extra arguments that apply
## to *all the chidlren*,
## while splv_extra is for *child-specific* extra arguments,
## associated with specific values of the split

#' Access or set child-specific extra arguments on a split value
#'
#' `splv_extra` retrieves the named list of *child-specific* extra arguments
#' stored on a `SplitValue` object.  These arguments are forwarded to the
#' analysis or content function only for the facet represented by that
#' particular split value, making them distinct from [split_exargs()] which
#' applies to *all* children of a split.
#'
#' @param obj (`SplitValue`)\cr a split value object, typically produced by
#'   [SplitValue()] or as a result of a splitting operation.
#' @param value (`list`)\cr named list of extra arguments to store on `obj`.
#'
#' @return
#' * `splv_extra` returns the current `list` of child-specific extra args.
#' * `splv_extra<-` returns `obj` with the extra arguments replaced.
#'
#' @seealso [split_exargs()] for split-level (all-children) extra arguments.
#'
#' @examples
#' sv <- SplitValue("A", extr = list(my_arg = 1))
#' splv_extra(sv)
#'
#' splv_extra(sv) <- list(my_arg = 99)
#' splv_extra(sv)
#'
#' @export
#' @rdname splv_extra
setGeneric("splv_extra", function(obj) standardGeneric("splv_extra"))

#' @exportMethod splv_extra
#' @rdname splv_extra
setMethod(
  "splv_extra", "SplitValue",
  function(obj) obj@extra
)

#' @export
#' @rdname splv_extra
setGeneric(
  "splv_extra<-",
  function(obj, value) standardGeneric("splv_extra<-")
)
#' @exportMethod splv_extra<-
#' @rdname splv_extra
setMethod(
  "splv_extra<-", "SplitValue",
  function(obj, value) {
    obj@extra <- value
    obj
  }
)

#' @rdname int_methods
setGeneric("split_exargs", function(obj) standardGeneric("split_exargs"))

#' @rdname int_methods
setMethod(
  "split_exargs", "Split",
  function(obj) obj@extra_args
)

#' @rdname int_methods
setGeneric(
  "split_exargs<-",
  function(obj, value) standardGeneric("split_exargs<-")
)

#' @rdname int_methods
setMethod(
  "split_exargs<-", "Split",
  function(obj, value) {
    obj@extra_args <- value
    obj
  }
)

is_labrow <- function(obj) is(obj, "LabelRow")

spl_ref_group <- function(obj) {
  stopifnot(is(obj, "VarLevWBaselineSplit"))
  obj@ref_group_value
}

### column info

#' Column information/structure accessors
#'
#' @inheritParams gen_args
#' @param df (`data.frame` or `NULL`)\cr data to use if the column information is being
#'   generated from a pre-data layout object.
#' @param path (`character` or `NULL`)\cr `col_counts` accessor and setter only.
#'   Path (in column structure).
#' @param rtpos (`TreePos`)\cr root position.
#'
#' @return A `LayoutColTree` object.
#'
#' @rdname col_accessors
#' @export
setGeneric("clayout", function(obj) standardGeneric("clayout"))

#' @rdname col_accessors
#' @exportMethod clayout
setMethod(
  "clayout", "VTableNodeInfo",
  function(obj) coltree(col_info(obj))
)

#' @rdname col_accessors
#' @exportMethod clayout
setMethod(
  "clayout", "PreDataTableLayouts",
  function(obj) obj@col_layout
)

## useful convenience for the cascading methods in colby_constructors
#' @rdname col_accessors
#' @exportMethod clayout
setMethod("clayout", "ANY", function(obj) PreDataColLayout())

#' @rdname col_accessors
#' @export
setGeneric("clayout<-", function(object, value) standardGeneric("clayout<-"))

#' @rdname col_accessors
#' @exportMethod clayout<-
setMethod(
  "clayout<-", "PreDataTableLayouts",
  function(object, value) {
    object@col_layout <- value
    object
  }
)

#' @rdname col_accessors
#' @export
setGeneric("col_info", function(obj) standardGeneric("col_info"))

#' @rdname col_accessors
#' @exportMethod col_info
setMethod(
  "col_info", "VTableNodeInfo",
  function(obj) obj@col_info
)

### XXX I've made this recursive. Do we ALWAYS want it to be?
###
### I think we do.
#' @rdname col_accessors
#' @export
setGeneric("col_info<-", function(obj, value) standardGeneric("col_info<-"))

#' @return Returns various information about columns, depending on the accessor used.
#'
#' @exportMethod col_info<-
#' @rdname col_accessors
setMethod(
  "col_info<-", "TableRow",
  function(obj, value) {
    obj@col_info <- value
    obj
  }
)

.set_cinfo_kids <- function(obj) {
  kids <- lapply(
    tree_children(obj),
    function(x) {
      col_info(x) <- col_info(obj)
      x
    }
  )
  tree_children(obj) <- kids
  obj
}

#' @rdname col_accessors
#' @exportMethod col_info<-
setMethod(
  "col_info<-", "ElementaryTable",
  function(obj, value) {
    obj@col_info <- value
    .set_cinfo_kids(obj)
  }
)

#' @rdname col_accessors
#' @exportMethod col_info<-
setMethod(
  "col_info<-", "TableTree",
  function(obj, value) {
    obj@col_info <- value
    if (nrow(content_table(obj))) {
      ct <- content_table(obj)
      col_info(ct) <- value
      content_table(obj) <- ct
    }
    .set_cinfo_kids(obj)
  }
)

#' @rdname col_accessors
#' @param ccount_format (`FormatSpec`)\cr The format to be used by default for column
#' counts throughout this column tree (i.e. if not overridden by a more specific format
#' specification).
#' @export
setGeneric(
  "coltree",
  function(obj, df = NULL, rtpos = TreePos(), alt_counts_df = df, ccount_format = "(N=xx)") standardGeneric("coltree")
)

#' @rdname col_accessors
#' @exportMethod coltree
setMethod(
  "coltree", "InstantiatedColumnInfo",
  function(obj, df = NULL, rtpos = TreePos(), alt_counts_df = df, ccount_format) {
    if (!is.null(df)) {
      warning("Ignoring df argument and retrieving already-computed LayoutColTree")
    }
    obj@tree_layout
  }
)

#' @rdname col_accessors
#' @export coltree
setMethod(
  "coltree", "PreDataTableLayouts",
  function(obj, df, rtpos, alt_counts_df = df, ccount_format) {
    coltree(clayout(obj), df, rtpos, alt_counts_df = alt_counts_df, ccount_format = ccount_format)
  }
)

#' @rdname col_accessors
#' @export coltree
setMethod(
  "coltree", "PreDataColLayout",
  function(obj, df, rtpos, alt_counts_df = df, ccount_format) {
    obj <- set_def_child_ord(obj, df)
    kids <- lapply(
      obj,
      function(x) {
        splitvec_to_coltree(
          df = df,
          splvec = x,
          pos = rtpos,
          alt_counts_df = alt_counts_df,
          global_cc_format = ccount_format
        )
      }
    )
    if (length(kids) == 1) {
      res <- kids[[1]]
    } else {
      res <- LayoutColTree(
        lev = 0L,
        kids = kids,
        tpos = rtpos,
        spl = RootSplit(),
        colcount = NROW(alt_counts_df),
        colcount_format = ccount_format
      )
    }
    disp_ccounts(res) <- disp_ccounts(obj)
    res
  }
)

#' @rdname col_accessors
#' @export coltree
setMethod(
  "coltree", "LayoutColTree",
  function(obj, df, rtpos, alt_counts_df, ccount_format) obj
)

#' @rdname col_accessors
#' @export coltree
setMethod(
  "coltree", "VTableTree",
  function(obj, df, rtpos, alt_counts_df, ccount_format) coltree(col_info(obj))
)

#' @rdname col_accessors
#' @export coltree
setMethod(
  "coltree", "TableRow",
  function(obj, df, rtpos, alt_counts_df, ccount_format) coltree(col_info(obj))
)

setGeneric("coltree<-", function(obj, value) standardGeneric("coltree<-"))
setMethod(
  "coltree<-", c("InstantiatedColumnInfo", "LayoutColTree"),
  function(obj, value) {
    obj@tree_layout <- value
    obj
  }
)

setMethod(
  "coltree<-", c("VTableTree", "LayoutColTree"),
  function(obj, value) {
    cinfo <- col_info(obj)
    coltree(cinfo) <- value
    col_info(obj) <- cinfo
    obj
  }
)

#' @rdname col_accessors
#' @export
setGeneric("col_exprs", function(obj, df = NULL) standardGeneric("col_exprs"))

#' @rdname col_accessors
#' @export col_exprs
setMethod(
  "col_exprs", "PreDataTableLayouts",
  function(obj, df = NULL) col_exprs(clayout(obj), df)
)

#' @rdname col_accessors
#' @export col_exprs
setMethod(
  "col_exprs", "PreDataColLayout",
  function(obj, df = NULL) {
    if (is.null(df)) {
      stop("can't determine col_exprs without data")
    }
    ct <- coltree(obj, df = df)
    make_col_subsets(ct, df = df)
  }
)

#' @rdname col_accessors
#' @export col_exprs
setMethod(
  "col_exprs", "InstantiatedColumnInfo",
  function(obj, df = NULL) {
    if (!is.null(df)) {
      warning("Ignoring df method when extracted precomputed column subsetting expressions.")
    }
    obj@subset_exprs
  }
)

#' @rdname int_methods
setGeneric("col_extra_args", function(obj, df = NULL) standardGeneric("col_extra_args"))

#' @rdname int_methods
setMethod(
  "col_extra_args", "InstantiatedColumnInfo",
  function(obj, df) {
    if (!is.null(df)) {
      warning("Ignorning df when retrieving already-computed column extra arguments.")
    }
    obj@cextra_args
  }
)

#' @rdname int_methods
setMethod(
  "col_extra_args", "PreDataTableLayouts",
  function(obj, df) col_extra_args(clayout(obj), df)
)

#' @rdname int_methods
setMethod(
  "col_extra_args", "PreDataColLayout",
  function(obj, df) {
    col_extra_args(coltree(obj, df), NULL)
  }
)

#' @rdname int_methods
setMethod(
  "col_extra_args", "LayoutColTree",
  function(obj, df) {
    if (!is.null(df)) {
      warning("Ignoring df argument and returning already calculated extra arguments")
    }
    get_col_extras(obj)
  }
)

#' @rdname int_methods
setMethod(
  "col_extra_args", "LayoutColLeaf",
  function(obj, df) {
    if (!is.null(df)) {
      warning("Ignoring df argument and returning already calculated extra arguments")
    }

    get_pos_extra(pos = tree_pos(obj))
  }
)

#' @seealso [facet_colcount()]
#' @export
#' @rdname col_accessors
setGeneric("col_counts", function(obj, path = NULL) standardGeneric("col_counts"))

#' @export
#' @rdname col_accessors
setMethod(
  "col_counts", "InstantiatedColumnInfo",
  function(obj, path = NULL) {
    if (is.null(path)) {
      lfs <- collect_leaves(coltree(obj))
      ret <- vapply(lfs, facet_colcount, 1L, path = NULL)
    } else {
      ret <- facet_colcount(obj, path)
    }
    ## required for strict backwards compatibility,
    ## even though its undesirable behavior.
    unname(ret)
  }
)

#' @export
#' @rdname col_accessors
setMethod(
  "col_counts", "VTableNodeInfo",
  function(obj, path = NULL) col_counts(col_info(obj), path = path)
)

#' @export
#' @rdname col_accessors
setGeneric("col_counts<-", function(obj, path = NULL, value) standardGeneric("col_counts<-"))

#' @export
#' @rdname col_accessors
setMethod(
  "col_counts<-", "InstantiatedColumnInfo",
  function(obj, path = NULL, value) {
    ## obj@counts[.path_to_pos(path, obj, cols = TRUE)] <- value
    ## obj
    if (!is.null(path)) {
      all_paths <- list(path)
    } else {
      all_paths <- make_col_df(obj, visible_only = TRUE)$path
    }
    if (length(value) != length(all_paths)) {
      stop(
        "Got ", length(value), " values for ",
        length(all_paths), " column paths",
        if (is.null(path)) " (from path = NULL)",
        "."
      )
    }
    ctree <- coltree(obj)
    for (i in seq_along(all_paths)) {
      facet_colcount(ctree, all_paths[[i]]) <- value[i]
    }
    coltree(obj) <- ctree
    obj
  }
)

#' @export
#' @rdname col_accessors
setMethod(
  "col_counts<-", "VTableNodeInfo",
  function(obj, path = NULL, value) {
    cinfo <- col_info(obj)
    col_counts(cinfo, path = path) <- value
    col_info(obj) <- cinfo
    obj
  }
)

#' @export
#' @rdname col_accessors
setGeneric("col_total", function(obj) standardGeneric("col_total"))

#' @export
#' @rdname col_accessors
setMethod(
  "col_total", "InstantiatedColumnInfo",
  function(obj) obj@total_count
)

#' @export
#' @rdname col_accessors
setMethod(
  "col_total", "VTableNodeInfo",
  function(obj) col_total(col_info(obj))
)

#' @export
#' @rdname col_accessors
setGeneric("col_total<-", function(obj, value) standardGeneric("col_total<-"))

#' @export
#' @rdname col_accessors
setMethod(
  "col_total<-", "InstantiatedColumnInfo",
  function(obj, value) {
    ## all methods funnel to this one so ensure integer-ness here.
    obj@total_count <- as.integer(value)
    obj
  }
)

#' @export
#' @rdname col_accessors
setMethod(
  "col_total<-", "VTableNodeInfo",
  function(obj, value) {
    cinfo <- col_info(obj)
    col_total(cinfo) <- value
    col_info(obj) <- cinfo
    obj
  }
)

#' @rdname int_methods
setGeneric("disp_ccounts", function(obj) standardGeneric("disp_ccounts"))

#' @rdname int_methods
setMethod(
  "disp_ccounts", "VTableTree",
  function(obj) disp_ccounts(col_info(obj))
)

#' @rdname int_methods
setMethod(
  "disp_ccounts", "InstantiatedColumnInfo",
  function(obj) obj@display_columncounts
)

#' @rdname int_methods
setMethod(
  "disp_ccounts", "PreDataTableLayouts",
  function(obj) disp_ccounts(clayout(obj))
)

#' @rdname int_methods
setMethod(
  "disp_ccounts", "PreDataColLayout",
  function(obj) obj@display_columncounts
)

#' @rdname int_methods
setMethod(
  "disp_ccounts", "LayoutColTree",
  function(obj) obj@display_columncounts
)

#' @rdname int_methods
setMethod(
  "disp_ccounts", "LayoutColLeaf",
  function(obj) obj@display_columncounts
)

#' @rdname int_methods
setMethod(
  "disp_ccounts", "Split",
  function(obj) obj@child_show_colcounts
)

#' @rdname int_methods
setGeneric("disp_ccounts<-", function(obj, value) standardGeneric("disp_ccounts<-"))

#' @rdname int_methods
setMethod(
  "disp_ccounts<-", "VTableTree",
  function(obj, value) {
    cinfo <- col_info(obj)
    disp_ccounts(cinfo) <- value
    col_info(obj) <- cinfo
    obj
  }
)

#' @rdname int_methods
setMethod(
  "disp_ccounts<-", "InstantiatedColumnInfo",
  function(obj, value) {
    obj@display_columncounts <- value
    obj
  }
)

#' @rdname int_methods
setMethod(
  "disp_ccounts<-", "PreDataColLayout",
  function(obj, value) {
    obj@display_columncounts <- value
    obj
  }
)

#' @rdname int_methods
setMethod(
  "disp_ccounts<-", "LayoutColTree",
  function(obj, value) {
    obj@display_columncounts <- value
    obj
  }
)

#' @rdname int_methods
setMethod(
  "disp_ccounts<-", "LayoutColLeaf",
  function(obj, value) {
    obj@display_columncounts <- value
    obj
  }
)

#' @rdname int_methods
setMethod(
  "disp_ccounts<-", "PreDataTableLayouts",
  function(obj, value) {
    clyt <- clayout(obj)
    disp_ccounts(clyt) <- value
    clayout(obj) <- clyt
    obj
  }
)


## this is a horrible hack but when we have non-nested siblings at the top level
## the beginning of the "path <-> position" relationship breaks down.
## we probably *should* have e.g., c("root", "top_level_splname_1",
## "top_level_splname_1, "top_level_splname_1_value", ...)
## but its pretty clear why no one will be happy with that, I think
## so we punt on the problem for now with an explicit workaround
##
## those first non-nested siblings currently have (incorrect)
## empty tree_pos elements so we just look at the obj_name

pos_singleton_path <- function(obj) {
  pos <- tree_pos(obj)
  splvals <- pos_splvals(pos)
  length(splvals) == 0 ||
    (length(splvals) == 1 && is.na(unlist(value_names(splvals))))
}

## close to a duplicate of tt_at_path, but... not quite :(
#' @rdname int_methods
coltree_at_path <- function(obj, path, ...) {
  if (length(path) == 0) {
    return(obj)
  }
  stopifnot(
    is(path, "character"),
    length(path) > 0
  )
  if (any(grepl("@content", path, fixed = TRUE))) {
    stop("@content token is not valid for column paths.")
  }

  cur <- obj
  curpath <- pos_to_path(tree_pos(obj)) # path
  num_consume_path <- 2
  while (!identical(curpath, path) && !is(cur, "LayoutColLeaf")) { # length(curpath) > 0) {
    kids <- tree_children(cur)
    kidmatch <- find_kid_path_match(kids, path)
    if (length(kidmatch) == 0) {
      stop(
        "unable to match full path: ", paste(path, sep = "->"),
        "\n path of last match: ", paste(curpath, sep = "->")
      )
    }
    cur <- kids[[kidmatch]]
    curpath <- pos_to_path(tree_pos(cur))
  }
  cur
}

find_kid_path_match <- function(kids, path) {
  if (length(kids) == 0) {
    return(integer())
  }
  kidpaths <- lapply(kids, function(k) pos_to_path(tree_pos(k)))

  matches <- vapply(kidpaths, function(kpth) identical(path[seq_along(kpth)], kpth), NA)
  firstkidpos <- tree_pos(kids[[1]])
  if (all(matches) && pos_singleton_path(kids[[1]])) {
    kidpaths <- lapply(seq_along(kidpaths), function(i) c(kidpaths[[i]], obj_name(kids[[i]])))
    matches <- vapply(kidpaths, function(kpth) identical(path[seq_along(kpth)], kpth), NA)
  }
  which(matches)
}


## almost a duplicate of recursive_replace, but I spent a bunch
## of time ramming my head against the different way pathing happens
## in column space (unfortunately) before giving up building
## coltree_at_path around recursive_replace, so here we are.

ct_recursive_replace <- function(ctree, path, value, pos = 1) {
  pos <- tree_pos(ctree)
  curpth <- pos_to_path(pos)
  if (identical(path, curpth)) {
    return(value)
  } else if (is(ctree, "LayoutColLeaf")) {
    stop(
      "unable to match full path: ", paste(path, sep = "->"),
      "\n path at leaf: ", paste(curpth, sep = "->")
    )
  }
  kids <- tree_children(ctree)
  kids_singl <- pos_singleton_path(kids[[1]])
  kidind <- find_kid_path_match(kids, path)

  if (length(kidind) == 0) {
    stop("Path appears invalid for this tree at step ", path[1])
  } else if (length(kidind) > 1) {
    stop(
      "singleton step (root, cbind_root, etc) in path appears to have matched multiple children. ",
      "This shouldn't happen, please contact the maintainers."
    )
  }

  kids[[kidind]] <- ct_recursive_replace(
    kids[[kidind]],
    path, value
  )
  tree_children(ctree) <- kids
  ctree
}

`coltree_at_path<-` <- function(obj, path, value) {
  obj <- ct_recursive_replace(obj, path, value)
  obj
}

#' Set visibility of column counts for a group of sibling facets
#'
#' @inheritParams gen_args
#' @param path (`character`)\cr the path *to the parent of the
#'   desired siblings*. The last element in the path should
#'   be a split name.
#' @return obj, modified with the desired column count.
#'   display behavior
#'
#' @seealso [colcount_visible()]
#'
#' @export
`facet_colcounts_visible<-` <- function(obj, path, value) {
  coldf <- make_col_df(obj, visible_only = FALSE)
  allpaths <- coldf$path
  lenpath <- length(path)
  match_paths <- vapply(allpaths, function(path_i) {
    (length(path_i) == lenpath + 1) &&
      (all(head(path_i, -1) == path))
  }, TRUE)
  for (curpath in allpaths[match_paths]) {
    colcount_visible(obj, curpath) <- value
  }
  obj
}

#' Get or set column count for a facet in column space
#'
#' @inheritParams gen_args
#' @param path character. This path must end on a
#' split value, e.g., the level of a categorical variable
#' that was split on in column space, but it need not
#' be the path to an individual column.
#'
#' @return for `facet_colcount` the current count associated
#' with that facet in column space, for `facet_colcount<-`,
#' `obj` modified with the new column count for the specified
#' facet.
#'
#' @note Updating a lower-level (more specific)
#' column count manually **will not** update the
#' counts for its parent facets. This cannot be made
#' automatic because the rtables framework does not
#' require sibling facets to be mutually exclusive
#' (e.g., total "arm", faceting into cumulative
#' quantiles, etc) and thus the count of a parent facet
#' will not always be simply the sum of the counts for
#' all of its children.
#'
#' @seealso [col_counts()]
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("ARM", show_colcounts = TRUE) |>
#'   split_cols_by("SEX",
#'     split_fun = keep_split_levels(c("F", "M")),
#'     show_colcounts = TRUE
#'   ) |>
#'   split_cols_by("STRATA1", show_colcounts = TRUE) |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, ex_adsl)
#'
#' facet_colcount(tbl, c("ARM", "A: Drug X"))
#' facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F"))
#' facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F", "STRATA1", "A"))
#'
#' ## modify specific count after table creation
#' facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F", "STRATA1", "A")) <- 25
#'
#' ## show black space for certain counts by assign NA
#'
#' facet_colcount(tbl, c("ARM", "A: Drug X", "SEX", "F", "STRATA1", "C")) <- NA
#'
#' @export
setGeneric(
  "facet_colcount",
  function(obj, path) standardGeneric("facet_colcount")
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount", "LayoutColTree",
  function(obj, path = NULL) {
    ## if(length(path) == 0L)
    ##   stop("face_colcount requires a non-null path") #nocov
    subtree <- coltree_at_path(obj, path)
    subtree@column_count
  }
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount", "LayoutColLeaf",
  function(obj, path = NULL) {
    ## not sure if we should check for null here as above
    obj@column_count
  }
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount", "VTableTree",
  function(obj, path) facet_colcount(coltree(obj), path = path)
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount", "InstantiatedColumnInfo",
  function(obj, path) facet_colcount(coltree(obj), path = path)
)

#' @rdname facet_colcount
#' @export
setGeneric(
  "facet_colcount<-",
  function(obj, path, value) standardGeneric("facet_colcount<-")
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount<-", "LayoutColTree",
  function(obj, path, value) {
    ct <- coltree_at_path(obj, path)
    ct@column_count <- as.integer(value)
    coltree_at_path(obj, path) <- ct
    obj
  }
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount<-", "LayoutColLeaf",
  function(obj, path, value) {
    obj@column_count <- as.integer(value)
    obj
  }
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount<-", "VTableTree",
  function(obj, path, value) {
    cinfo <- col_info(obj)
    facet_colcount(cinfo, path) <- value
    col_info(obj) <- cinfo
    obj
  }
)

#' @rdname facet_colcount
#' @export
setMethod(
  "facet_colcount<-", "InstantiatedColumnInfo",
  function(obj, path, value) {
    ct <- coltree(obj)
    facet_colcount(ct, path) <- value
    coltree(obj) <- ct
    obj
  }
)

#' Value and Visibility of specific column counts by path
#'
#' @inheritParams gen_args
#'
#' @return for `colcount_visible` a logical scalar
#' indicating whether the specified position in
#' the column hierarchy is set to display its column count;
#' for `colcount_visible<-`, `obj` updated with
#' the specified count displaying behavior set.
#'
#' @note Users generally should not call `colcount_visible`
#' directly, as setting sibling facets to have differing
#' column count visibility will result in an error when
#' printing or paginating the table.
#'
#' @export
setGeneric("colcount_visible", function(obj, path) standardGeneric("colcount_visible"))

#' @rdname colcount_visible
#' @export
setMethod(
  "colcount_visible", "VTableTree",
  function(obj, path) colcount_visible(coltree(obj), path)
)

#' @rdname colcount_visible
#' @export
setMethod(
  "colcount_visible", "InstantiatedColumnInfo",
  function(obj, path) colcount_visible(coltree(obj), path)
)

#' @rdname colcount_visible
#' @export
setMethod(
  "colcount_visible", "LayoutColTree",
  function(obj, path) {
    subtree <- coltree_at_path(obj, path)
    disp_ccounts(subtree)
  }
)

#' @rdname colcount_visible
#' @export
setGeneric("colcount_visible<-", function(obj, path, value) standardGeneric("colcount_visible<-"))

#' @rdname colcount_visible
#' @export
setMethod(
  "colcount_visible<-", "VTableTree",
  function(obj, path, value) {
    ctree <- coltree(obj)
    colcount_visible(ctree, path) <- value
    coltree(obj) <- ctree
    obj
  }
)

#' @rdname colcount_visible
#' @export
setMethod(
  "colcount_visible<-", "InstantiatedColumnInfo",
  function(obj, path, value) {
    ctree <- coltree(obj)
    colcount_visible(ctree, path) <- value
    coltree(obj) <- ctree
    obj
  }
)


#' @rdname colcount_visible
#' @export
setMethod(
  "colcount_visible<-", "LayoutColTree",
  function(obj, path, value) {
    subtree <- coltree_at_path(obj, path)
    disp_ccounts(subtree) <- value
    coltree_at_path(obj, path) <- subtree
    obj
  }
)

#' @rdname int_methods
#' @export
setGeneric("colcount_format", function(obj) standardGeneric("colcount_format"))

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format", "InstantiatedColumnInfo",
  function(obj) obj@columncount_format
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format", "VTableNodeInfo",
  function(obj) colcount_format(col_info(obj))
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format", "PreDataColLayout",
  function(obj) obj@columncount_format
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format", "PreDataTableLayouts",
  function(obj) colcount_format(clayout(obj))
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format", "Split",
  function(obj) obj@child_colcount_format
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format", "LayoutColTree",
  function(obj) obj@columncount_format
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format", "LayoutColLeaf",
  function(obj) obj@columncount_format
)


#' @rdname int_methods
#' @export
setGeneric(
  "colcount_format<-",
  function(obj, value) standardGeneric("colcount_format<-")
)

#' @export
#' @rdname int_methods
setMethod(
  "colcount_format<-", "InstantiatedColumnInfo",
  function(obj, value) {
    obj@columncount_format <- value
    obj
  }
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format<-", "VTableNodeInfo",
  function(obj, value) {
    cinfo <- col_info(obj)
    colcount_format(cinfo) <- value
    col_info(obj) <- cinfo
    obj
  }
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format<-", "PreDataColLayout",
  function(obj, value) {
    obj@columncount_format <- value
    obj
  }
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_format<-", "PreDataTableLayouts",
  function(obj, value) {
    clyt <- clayout(obj)
    colcount_format(clyt) <- value
    clayout(obj) <- clyt
    obj
  }
)

## It'd probably be better if this had the full set of methods as above
## but its not currently modelled in the class and probably isn't needed
## super much
#' @rdname int_methods
#' @export
setGeneric("colcount_na_str", function(obj) standardGeneric("colcount_na_str"))

#' @rdname int_methods
#' @export
setMethod(
  "colcount_na_str", "InstantiatedColumnInfo",
  function(obj) obj@columncount_na_str
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_na_str", "VTableNodeInfo",
  function(obj) colcount_na_str(col_info(obj))
)

#' @rdname int_methods
#' @export
setGeneric(
  "colcount_na_str<-",
  function(obj, value) standardGeneric("colcount_na_str<-")
)

#' @export
#' @rdname int_methods
setMethod(
  "colcount_na_str<-", "InstantiatedColumnInfo",
  function(obj, value) {
    obj@columncount_na_str <- value
    obj
  }
)

#' @rdname int_methods
#' @export
setMethod(
  "colcount_na_str<-", "VTableNodeInfo",
  function(obj, value) {
    cinfo <- col_info(obj)
    colcount_na_str(cinfo) <- value
    col_info(obj) <- cinfo
    obj
  }
)

#' Exported for use in `tern`
#'
#' Does the `table`/`row`/`InstantiatedColumnInfo` object contain no column structure information?
#'
#' @inheritParams gen_args
#'
#' @return `TRUE` if the object has no/empty instantiated column information, `FALSE` otherwise.
#'
#' @rdname no_info
#' @export
setGeneric("no_colinfo", function(obj) standardGeneric("no_colinfo"))

#' @exportMethod no_colinfo
#' @rdname no_info
setMethod(
  "no_colinfo", "VTableNodeInfo",
  function(obj) no_colinfo(col_info(obj))
)

#' @exportMethod no_colinfo
#' @rdname no_info
setMethod(
  "no_colinfo", "InstantiatedColumnInfo",
  function(obj) length(obj@subset_exprs) == 0
) ## identical(obj, EmptyColInfo))

#' Names of a `TableTree`
#'
#' @param x (`TableTree`)\cr the object.
#'
#' @details
#' For `TableTree`s with more than one level of splitting in columns, the names are defined to be the top-level
#' split values repped out across the columns that they span.
#'
#' @return The column names of `x`, as defined in the details above.
#'
#' @exportMethod names
#' @rdname names
setMethod(
  "names", "VTableNodeInfo",
  function(x) names(col_info(x))
)

#' @rdname names
#' @exportMethod names
setMethod(
  "names", "InstantiatedColumnInfo",
  function(x) names(coltree(x))
)

#' @rdname names
#' @exportMethod names
setMethod(
  "names", "LayoutColTree",
  function(x) {
    unname(unlist(lapply(
      tree_children(x),
      function(obj) {
        nm <- obj_name(obj)
        rep(nm, n_leaves(obj))
      }
    )))
  }
)

#' @rdname names
#' @exportMethod row.names
setMethod(
  "row.names", "VTableTree",
  function(x) {
    unname(sapply(collect_leaves(x, add.labrows = TRUE),
      obj_label,
      USE.NAMES = FALSE
    )) ## XXXX this should probably be obj_name???
  }
)

#' Convert to a vector
#'
#' Convert an `rtables` framework object into a vector, if possible. This is unlikely to be useful in
#' realistic scenarios.
#'
#' @param x (`ANY`)\cr the object to be converted to a vector.
#' @param mode (`string`)\cr passed on to [as.vector()].
#'
#' @return A vector of the chosen mode (or an error is raised if more than one row was present).
#'
#' @note This only works for a table with a single row or a row object.
#'
#' @name asvec
#' @aliases as.vector,VTableTree-method
#' @exportMethod as.vector
setMethod("as.vector", "VTableTree", function(x, mode) {
  stopifnot(nrow(x) == 1L)
  if (nrow(content_table(x)) == 1L) {
    tab <- content_table(x)
  } else {
    tab <- x
  }
  as.vector(tree_children(tab)[[1]], mode = mode)
})

#' @inheritParams asvec
#'
#' @rdname int_methods
#' @exportMethod as.vector
setMethod("as.vector", "TableRow", function(x, mode) as.vector(unlist(row_values(x)), mode = mode))

#' @rdname int_methods
#' @exportMethod as.vector
setMethod("as.vector", "ElementaryTable", function(x, mode) {
  stopifnot(nrow(x) == 1L)
  as.vector(tree_children(x)[[1]], mode = mode)
})

## cuts ----

#' @rdname int_methods
setGeneric("spl_cuts", function(obj) standardGeneric("spl_cuts"))

#' @rdname int_methods
setMethod(
  "spl_cuts", "VarStaticCutSplit",
  function(obj) obj@cuts
)

#' @rdname int_methods
setGeneric("spl_cutlabels", function(obj) standardGeneric("spl_cutlabels"))

#' @rdname int_methods
setMethod(
  "spl_cutlabels", "VarStaticCutSplit",
  function(obj) obj@cut_labels
)

#' @rdname int_methods
setGeneric("spl_cutfun", function(obj) standardGeneric("spl_cutfun"))

#' @rdname int_methods
setMethod(
  "spl_cutfun", "VarDynCutSplit",
  function(obj) obj@cut_fun
)

#' @rdname int_methods
setGeneric("spl_cutlabelfun", function(obj) standardGeneric("spl_cutlabelfun"))

#' @rdname int_methods
setMethod(
  "spl_cutlabelfun", "VarDynCutSplit",
  function(obj) obj@cut_label_fun
)

#' @rdname int_methods
setGeneric("spl_is_cmlcuts", function(obj) standardGeneric("spl_is_cmlcuts"))

#' @rdname int_methods
setMethod(
  "spl_is_cmlcuts", "VarDynCutSplit",
  function(obj) obj@cumulative_cuts
)

#' @rdname int_methods
setGeneric(
  "spl_varnames",
  function(obj) standardGeneric("spl_varnames")
)

#' @rdname int_methods
setMethod(
  "spl_varnames", "MultiVarSplit",
  function(obj) obj@var_names
)

#' @rdname int_methods
setGeneric(
  "spl_varnames<-",
  function(object, value) standardGeneric("spl_varnames<-")
)

#' @rdname int_methods
setMethod(
  "spl_varnames<-", "MultiVarSplit",
  function(object, value) {
    oldvnms <- spl_varnames(object)
    oldvlbls <- spl_varlabels(object)
    object@var_names <- value
    if (identical(oldvnms, oldvlbls)) {
      spl_varlabels(object) <- value
    }
    object
  }
)

#' Top left material
#'
#' A `TableTree` object can have *top left material* which is a sequence of strings which are printed in the
#' area of the table between the column header display and the label of the first row. These functions access
#' and modify that material.
#'
#' @inheritParams gen_args
#'
#' @return A character vector representing the top-left material of `obj` (or `obj` after modification, in the
#'   case of the setter).
#'
#' @export
#' @rdname top_left
setGeneric("top_left", function(obj) standardGeneric("top_left"))

#' @export
#' @rdname top_left
setMethod("top_left", "VTableTree", function(obj) top_left(col_info(obj)))

#' @export
#' @rdname top_left
setMethod("top_left", "InstantiatedColumnInfo", function(obj) obj@top_left)

#' @export
#' @rdname top_left
setMethod("top_left", "PreDataTableLayouts", function(obj) obj@top_left)

#' @export
#' @rdname top_left
setGeneric("top_left<-", function(obj, value) standardGeneric("top_left<-"))

#' @export
#' @rdname top_left
setMethod("top_left<-", "VTableTree", function(obj, value) {
  cinfo <- col_info(obj)
  top_left(cinfo) <- value
  col_info(obj) <- cinfo
  obj
})

#' @export
#' @rdname top_left
setMethod("top_left<-", "InstantiatedColumnInfo", function(obj, value) {
  obj@top_left <- value
  obj
})

#' @export
#' @rdname top_left
setMethod("top_left<-", "PreDataTableLayouts", function(obj, value) {
  obj@top_left <- value
  obj
})

vil_collapse <- function(x) {
  x <- unlist(x)
  x <- x[!is.na(x)]
  x <- unique(x)
  x[nzchar(x)]
}

#' List variables required by a pre-data table layout
#'
#' @param lyt (`PreDataTableLayouts`)\cr the layout (or a component thereof).
#'
#' @details
#' This will walk the layout declaration and return a vector of the names of the unique variables that are used
#' in any of the following ways:
#'
#'   * Variable being split on (directly or via cuts)
#'   * Element of a Multi-variable column split
#'   * Content variable
#'   * Value-label variable
#'
#' @return A character vector containing the unique variables explicitly used in the layout (see the notes below).
#'
#' @note
#' * This function will not detect dependencies implicit in analysis or summary functions which accept `x`
#'   or `df` and then rely on the existence of particular variables not being split on/analyzed.
#' * The order these variable names appear within the return vector is undefined and should not be relied upon.
#'
#' @examples
#' lyt <- basic_table() |>
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
#' vars_in_layout(lyt)
#'
#' @export
#' @rdname vil
setGeneric("vars_in_layout", function(lyt) standardGeneric("vars_in_layout"))

#' @rdname vil
setMethod(
  "vars_in_layout", "PreDataTableLayouts",
  function(lyt) {
    vil_collapse(c(
      vars_in_layout(clayout(lyt)),
      vars_in_layout(rlayout(lyt))
    ))
  }
)

#' @rdname vil
setMethod(
  "vars_in_layout", "PreDataAxisLayout",
  function(lyt) {
    vil_collapse(lapply(lyt, vars_in_layout))
  }
)

#' @rdname vil
setMethod(
  "vars_in_layout", "SplitVector",
  function(lyt) {
    vil_collapse(lapply(lyt, vars_in_layout))
  }
)

#' @rdname vil
setMethod(
  "vars_in_layout", "Split",
  function(lyt) {
    vil_collapse(c(
      spl_payload(lyt),
      ## for an AllSplit/RootSplit
      ## doesn't have to be same as payload
      content_var(lyt),
      spl_label_var(lyt)
    ))
  }
)

#' @rdname vil
setMethod(
  "vars_in_layout", "CompoundSplit",
  function(lyt) vil_collapse(lapply(spl_payload(lyt), vars_in_layout))
)

#' @rdname vil
setMethod(
  "vars_in_layout", "ManualSplit",
  function(lyt) character()
)

## Titles and footers ----

# ##' Titles and Footers
# ##'
# ##' Get or set the titles and footers on an object
# ##'
# ##' @inheritParams gen_args
# ##'
# ##' @rdname title_footer
# ##' @export
#' @rdname formatters_methods
#' @export
setMethod(
  "main_title", "VTitleFooter",
  function(obj) obj@main_title
)

##' @rdname formatters_methods
##' @export
setMethod(
  "main_title<-", "VTitleFooter",
  function(obj, value) {
    stopifnot(length(value) == 1)
    obj@main_title <- value
    obj
  }
)

# Getters for TableRow is here for convenience for binding (no need of setters)
#' @rdname formatters_methods
#' @export
setMethod(
  "main_title", "TableRow",
  function(obj) ""
)

#' @rdname formatters_methods
#' @export
setMethod(
  "subtitles", "VTitleFooter",
  function(obj) obj@subtitles
)

#' @rdname formatters_methods
#' @export
setMethod(
  "subtitles<-", "VTitleFooter",
  function(obj, value) {
    obj@subtitles <- value
    obj
  }
)

#' @rdname formatters_methods
#' @export
setMethod(
  "subtitles", "TableRow", # Only getter: see main_title for TableRow
  function(obj) character()
)

#' @rdname formatters_methods
#' @export
setMethod(
  "main_footer", "VTitleFooter",
  function(obj) obj@main_footer
)

#' @rdname formatters_methods
#' @export
setMethod(
  "main_footer<-", "VTitleFooter",
  function(obj, value) {
    obj@main_footer <- value
    obj
  }
)

#' @rdname formatters_methods
#' @export
setMethod(
  "main_footer", "TableRow", # Only getter: see main_title for TableRow
  function(obj) character()
)

#' @rdname formatters_methods
#' @export
setMethod(
  "prov_footer", "VTitleFooter",
  function(obj) obj@provenance_footer
)

#' @rdname formatters_methods
#' @export
setMethod(
  "prov_footer<-", "VTitleFooter",
  function(obj, value) {
    obj@provenance_footer <- value
    obj
  }
)

#' @rdname formatters_methods
#' @export
setMethod(
  "prov_footer", "TableRow", # Only getter: see main_title for TableRow
  function(obj) character()
)

make_ref_value <- function(value) {
  if (is(value, "RefFootnote")) {
    value <- list(value)
  } else if (!is.list(value) || any(!sapply(value, is, "RefFootnote"))) {
    value <- lapply(value, RefFootnote)
  }
  value
}

#' Referential footnote accessors
#'
#' Access and set the referential footnotes aspects of a built table.
#'
#' @inheritParams gen_args
#'
#' @export
#' @rdname ref_fnotes
setGeneric("row_footnotes", function(obj) standardGeneric("row_footnotes"))

#' @export
#' @rdname int_methods
setMethod(
  "row_footnotes", "TableRow",
  function(obj) obj@row_footnotes
)

#' @export
#' @rdname int_methods
setMethod(
  "row_footnotes", "RowsVerticalSection",
  function(obj) attr(obj, "row_footnotes", exact = TRUE) %||% list()
)

#' @export
#' @rdname ref_fnotes
setGeneric("row_footnotes<-", function(obj, value) standardGeneric("row_footnotes<-"))

#' @export
#' @rdname int_methods
setMethod(
  "row_footnotes<-", "TableRow",
  function(obj, value) {
    obj@row_footnotes <- make_ref_value(value)
    obj
  }
)

#' @export
#' @rdname int_methods
setMethod(
  "row_footnotes", "VTableTree",
  function(obj) {
    rws <- collect_leaves(obj, TRUE, TRUE)
    cells <- lapply(rws, row_footnotes)
    cells
  }
)

#' @export
#' @rdname ref_fnotes
setGeneric("cell_footnotes", function(obj) standardGeneric("cell_footnotes"))

#' @export
#' @rdname int_methods
setMethod(
  "cell_footnotes", "CellValue",
  function(obj) attr(obj, "footnotes", exact = TRUE) %||% list()
)

#' @export
#' @rdname int_methods
setMethod(
  "cell_footnotes", "TableRow",
  function(obj) {
    ret <- lapply(row_cells(obj), cell_footnotes)
    if (length(ret) != ncol(obj)) {
      ret <- rep(ret, row_cspans(obj))
    }
    ret
  }
)

#' @export
#' @rdname int_methods
setMethod(
  "cell_footnotes", "LabelRow",
  function(obj) {
    rep(list(list()), ncol(obj))
  }
)

#' @export
#' @rdname int_methods
setMethod(
  "cell_footnotes", "VTableTree",
  function(obj) {
    rws <- collect_leaves(obj, TRUE, TRUE)
    cells <- lapply(rws, cell_footnotes)
    do.call(rbind, cells)
  }
)

#' @export
#' @rdname ref_fnotes
setGeneric("cell_footnotes<-", function(obj, value) standardGeneric("cell_footnotes<-"))

#' @export
#' @rdname int_methods
setMethod(
  "cell_footnotes<-", "CellValue",
  function(obj, value) {
    attr(obj, "footnotes") <- make_ref_value(value)
    obj
  }
)

.cfn_set_helper <- function(obj, value) {
  if (length(value) != ncol(obj)) {
    stop("Did not get the right number of footnote ref values for cell_footnotes<- on a full row.")
  }

  row_cells(obj) <- mapply(
    function(cell, fns) {
      if (is.list(fns)) {
        cell_footnotes(cell) <- lapply(fns, RefFootnote)
      } else {
        cell_footnotes(cell) <- list(RefFootnote(fns))
      }
      cell
    },
    cell = row_cells(obj),
    fns = value, SIMPLIFY = FALSE
  )
  obj
}

#' @export
#' @rdname int_methods
setMethod("cell_footnotes<-", "DataRow",
  definition = .cfn_set_helper
)

#' @export
#' @rdname int_methods
setMethod("cell_footnotes<-", "ContentRow",
  definition = .cfn_set_helper
)

# Deprecated methods ----

#' @export
#' @rdname ref_fnotes
setGeneric("col_fnotes_here", function(obj) standardGeneric("col_fnotes_here"))

#' @export
#' @rdname ref_fnotes
setMethod("col_fnotes_here", "ANY", function(obj) {
  lifecycle::deprecate_warn(
    when = "0.6.6",
    what = "col_fnotes_here()",
    with = "col_footnotes()"
  )
  col_footnotes(obj)
})

#' @export
#' @rdname ref_fnotes
setGeneric("col_fnotes_here<-", function(obj, value) standardGeneric("col_fnotes_here<-"))

#' @export
#' @rdname int_methods
setMethod("col_fnotes_here<-", "ANY", function(obj, value) {
  lifecycle::deprecate_warn(
    when = "0.6.6",
    what = I("col_fnotes_here()<-"),
    with = I("col_footnotes()<-")
  )
  col_footnotes(obj) <- value
})

#' @export
#' @rdname ref_fnotes
setGeneric("col_footnotes", function(obj) standardGeneric("col_footnotes"))

#' @export
#' @rdname int_methods
setMethod("col_footnotes", "LayoutColTree", function(obj) obj@col_footnotes)

#' @export
#' @rdname int_methods
setMethod("col_footnotes", "LayoutColLeaf", function(obj) obj@col_footnotes)

#' @export
#' @rdname ref_fnotes
setGeneric("col_footnotes<-", function(obj, value) standardGeneric("col_footnotes<-"))

#' @export
#' @rdname int_methods
setMethod("col_footnotes<-", "LayoutColTree", function(obj, value) {
  obj@col_footnotes <- make_ref_value(value)
  obj
})

#' @export
#' @rdname int_methods
setMethod("col_footnotes<-", "LayoutColLeaf", function(obj, value) {
  obj@col_footnotes <- make_ref_value(value)
  obj
})

#' @export
#' @rdname int_methods
setMethod(
  "col_footnotes", "VTableTree",
  function(obj) {
    ctree <- coltree(obj)
    cols <- tree_children(ctree)
    while (all(sapply(cols, is, "LayoutColTree"))) {
      cols <- lapply(cols, tree_children)
      cols <- unlist(cols, recursive = FALSE)
    }
    all_col_fnotes <- lapply(cols, col_footnotes)
    if (is.null(unlist(all_col_fnotes))) {
      return(NULL)
    }

    all_col_fnotes
  }
)

#' @export
#' @rdname ref_fnotes
setGeneric("ref_index", function(obj) standardGeneric("ref_index"))

#' @export
#' @rdname int_methods
setMethod(
  "ref_index", "RefFootnote",
  function(obj) obj@index
)

#' @export
#' @rdname ref_fnotes
setGeneric("ref_index<-", function(obj, value) standardGeneric("ref_index<-"))

#' @export
#' @rdname int_methods
setMethod(
  "ref_index<-", "RefFootnote",
  function(obj, value) {
    obj@index <- value
    obj
  }
)

#' @export
#' @rdname ref_fnotes
setGeneric("ref_symbol", function(obj) standardGeneric("ref_symbol"))

#' @export
#' @rdname int_methods
setMethod(
  "ref_symbol", "RefFootnote",
  function(obj) obj@symbol
)

#' @export
#' @rdname ref_fnotes
setGeneric("ref_symbol<-", function(obj, value) standardGeneric("ref_symbol<-"))

#' @export
#' @rdname int_methods
setMethod(
  "ref_symbol<-", "RefFootnote",
  function(obj, value) {
    obj@symbol <- value
    obj
  }
)

#' @export
#' @rdname ref_fnotes
setGeneric("ref_msg", function(obj) standardGeneric("ref_msg"))

#' @export
#' @rdname int_methods
setMethod(
  "ref_msg", "RefFootnote",
  function(obj) obj@value
)

setGeneric(".fnote_set_inner<-", function(ttrp, colpath, value) standardGeneric(".fnote_set_inner<-"))

setMethod(
  ".fnote_set_inner<-", c("TableRow", "NULL"),
  function(ttrp, colpath, value) {
    row_footnotes(ttrp) <- value
    ttrp
  }
)

setMethod(
  ".fnote_set_inner<-", c("TableRow", "character"),
  function(ttrp, colpath, value) {
    ind <- .path_to_pos(path = colpath, tt = ttrp, cols = TRUE)
    cfns <- cell_footnotes(ttrp)
    cfns[[ind]] <- value
    cell_footnotes(ttrp) <- cfns
    ttrp
  }
)

setMethod(
  ".fnote_set_inner<-", c("InstantiatedColumnInfo", "character"),
  function(ttrp, colpath, value) {
    ctree <- col_fnotes_at_path(coltree(ttrp), colpath, fnotes = value)
    coltree(ttrp) <- ctree
    ttrp
  }
)

setMethod(
  ".fnote_set_inner<-", c("VTableTree", "ANY"),
  function(ttrp, colpath, value) {
    if (labelrow_visible(ttrp) && !is.null(value)) {
      lblrw <- tt_labelrow(ttrp)
      row_footnotes(lblrw) <- value
      tt_labelrow(ttrp) <- lblrw
    } else if (NROW(content_table(ttrp)) == 1L) {
      ctbl <- content_table(ttrp)
      pth <- make_row_df(ctbl)$path[[1]]
      fnotes_at_path(ctbl, pth, colpath) <- value
      content_table(ttrp) <- ctbl
    } else {
      stop("an error occurred. this shouldn't happen. please contact the maintainer") # nocov
    }
    ttrp
  }
)

#' @param rowpath (`character` or `NULL`)\cr path within row structure. `NULL` indicates the footnote should
#'   go on the column rather than cell.
#' @param colpath (`character` or `NULL`)\cr path within column structure. `NULL` indicates footnote should go
#'   on the row rather than cell.
#' @param reset_idx (`flag`)\cr whether the numbering for referential footnotes should be immediately
#'   recalculated. Defaults to `TRUE`.
#'
#' @examples
#' # How to add referencial footnotes after having created a table
#' lyt <- basic_table() |>
#'   split_rows_by("SEX", page_by = TRUE) |>
#'   analyze("AGE")
#'
#' tbl <- build_table(lyt, DM)
#' tbl <- trim_rows(tbl)
#' # Check the row and col structure to add precise references
#' # row_paths(tbl)
#' # col_paths(t)
#' # row_paths_summary(tbl)
#' # col_paths_summary(tbl)
#'
#' # Add the citation numbers on the table and relative references in the footnotes
#' fnotes_at_path(tbl, rowpath = c("SEX", "F", "AGE", "Mean")) <- "Famous paper 1"
#' fnotes_at_path(tbl, rowpath = c("SEX", "UNDIFFERENTIATED")) <- "Unfamous paper 2"
#' # tbl
#'
#' @seealso [row_paths()], [col_paths()], [row_paths_summary()], [col_paths_summary()]
#'
#' @export
#' @rdname ref_fnotes
setGeneric("fnotes_at_path<-", function(obj,
                                        rowpath = NULL,
                                        colpath = NULL,
                                        reset_idx = TRUE,
                                        value) {
  standardGeneric("fnotes_at_path<-")
})

## non-null rowpath, null or non-null colpath
#' @inheritParams fnotes_at_path<-
#'
#' @export
#' @rdname int_methods
setMethod(
  "fnotes_at_path<-", c("VTableTree", "character"),
  function(obj,
           rowpath = NULL,
           colpath = NULL,
           reset_idx = TRUE,
           value) {
    rw <- tt_at_path(obj, rowpath)
    .fnote_set_inner(rw, colpath) <- value
    tt_at_path(obj, rowpath) <- rw
    if (reset_idx) {
      obj <- update_ref_indexing(obj)
    }
    obj
  }
)

#' @export
#' @rdname int_methods
setMethod(
  "fnotes_at_path<-", c("VTableTree", "NULL"),
  function(obj, rowpath = NULL, colpath = NULL, reset_idx = TRUE, value) {
    cinfo <- col_info(obj)
    .fnote_set_inner(cinfo, colpath) <- value
    col_info(obj) <- cinfo
    if (reset_idx) {
      obj <- update_ref_indexing(obj)
    }
    obj
  }
)

#' @export
#' @rdname int_methods
setGeneric("has_force_pag", function(obj) standardGeneric("has_force_pag"))

#' @exportMethod has_force_pag
#' @rdname int_methods
setMethod("has_force_pag", "TableTree", function(obj) !is.na(ptitle_prefix(obj)))

#' @exportMethod has_force_pag
#' @rdname int_methods
setMethod("has_force_pag", "Split", function(obj) !is.na(ptitle_prefix(obj)))

#' @exportMethod has_force_pag
#' @rdname int_methods
setMethod("has_force_pag", "VTableNodeInfo", function(obj) FALSE)

setGeneric("ptitle_prefix", function(obj) standardGeneric("ptitle_prefix"))

setMethod("ptitle_prefix", "TableTree", function(obj) obj@page_title_prefix)

setMethod("ptitle_prefix", "Split", function(obj) obj@page_title_prefix)

setMethod("ptitle_prefix", "ANY", function(obj) NULL)

setMethod("page_titles", "VTableTree", function(obj) obj@page_titles)

setMethod("page_titles<-", "VTableTree", function(obj, value) {
  obj@page_titles <- value
  obj
})

## Horizontal separator --------------------------------------------------------

#' Access or recursively set header-body separator for tables
#'
#' @inheritParams gen_args
#' @param value (`string`)\cr string to use as new header/body separator.
#'
#' @return
#' * `horizontal_sep` returns the string acting as the header separator.
#' * `horizontal_sep<-` returns `obj`, with the new header separator applied recursively to it and all its
#'   subtables.
#'
#' @export
setGeneric("horizontal_sep", function(obj) standardGeneric("horizontal_sep"))

#' @rdname horizontal_sep
#' @export
setMethod(
  "horizontal_sep", "VTableTree",
  function(obj) obj@horizontal_sep
)

#' @rdname horizontal_sep
#' @export
setGeneric("horizontal_sep<-", function(obj, value) standardGeneric("horizontal_sep<-"))

#' @rdname horizontal_sep
#' @export
setMethod(
  "horizontal_sep<-", "VTableTree",
  function(obj, value) {
    cont <- content_table(obj)
    if (NROW(cont) > 0) {
      horizontal_sep(cont) <- value
      content_table(obj) <- cont
    }

    kids <- lapply(tree_children(obj),
      `horizontal_sep<-`,
      value = value
    )

    tree_children(obj) <- kids
    obj@horizontal_sep <- value
    obj
  }
)

#' @rdname horizontal_sep
#' @export
setMethod(
  "horizontal_sep<-", "TableRow",
  function(obj, value) obj
)

## Section dividers ------------------------------------------------------------

# Used for splits
setGeneric("spl_section_div", function(obj) standardGeneric("spl_section_div"))

setMethod(
  "spl_section_div", "Split",
  function(obj) obj@child_section_div
)

setGeneric("spl_section_div<-", function(obj, value) standardGeneric("spl_section_div<-"))

setMethod(
  "spl_section_div<-", "Split",
  function(obj, value) {
    obj@child_section_div <- value
    obj
  }
)

# Used for table object parts
setGeneric("trailing_section_div", function(obj) standardGeneric("trailing_section_div"))
setMethod("trailing_section_div", "VTableTree", function(obj) obj@trailing_section_div)
setMethod("trailing_section_div", "LabelRow", function(obj) obj@trailing_section_div)
setMethod("trailing_section_div", "TableRow", function(obj) obj@trailing_section_div)

setGeneric("trailing_section_div<-", function(obj, value) standardGeneric("trailing_section_div<-"))
setMethod("trailing_section_div<-", "VTableTree", function(obj, value) {
  obj@trailing_section_div <- value
  obj
})
setMethod("trailing_section_div<-", "LabelRow", function(obj, value) {
  obj@trailing_section_div <- value
  obj
})
setMethod("trailing_section_div<-", "TableRow", function(obj, value) {
  obj@trailing_section_div <- value
  obj
})

#' Section dividers accessor and setter
#'
#' `section_div` can be used to set or get the section divider for a table object
#' produced by [build_table()]. When assigned in post-processing (`section_div<-`)
#' the table can have a section divider after every row, each assigned independently.
#' If assigning during layout creation, only [split_rows_by()] (and its related row-wise
#' splits) and [analyze()] have a `section_div` parameter that will produce separators
#' between split sections and data subgroups, respectively. These two approaches
#' generally should not be mixed (see Details).
#'
#' @inheritParams gen_args
#' @param obj (`VTableTree`)\cr table object. This can be of any class that inherits from `VTableTree`
#'   or `TableRow`/`LabelRow`.
#' @param only_sep_sections (`flag`)\cr defaults to `FALSE` for `section_div<-`. Allows
#'   you to set the section divider only for sections that are splits or analyses if the number of
#'   values is less than the number of rows in the table. If `TRUE`, the section divider will
#'   be set for all rows of the table.
#' @param value (`character`)\cr vector of strings to use as section dividers
#'   (a single string for `section_div_at_path<-`). Each string's character(s)
#'   are repeated to the full width of the printed table. Non-`NA` strings
#'   will result in a trailing separator at the associated location (see Details);
#'   values of `NA_character_` result in no visible divider when the table is printed/exported.
#'   For `section_div<-`, `value`'s length should the number of rows in `obj`,
#'   when    `only_sep_sections` is `FALSE` and should be less than or equal to
#'   the maximum number of nested split/analyze steps anywhere in the
#'   layout corresponding to the table when `only_sep_sections` is `TRUE`.
#'   See the Details section below for more information.
#'
#' @return The section divider string. Each line that does not have a trailing separator
#'   will have `NA_character_` as section divider.
#'
#' @seealso [basic_table()] parameter `header_section_div` and `top_level_section_div` for global
#'   section dividers.
#'
#' @details
#'
#' Section dividers provide visual breaks between structural elements
#'   of a table in row space. They are repeated to fill a full line of
#'   the table and printed after the element (row, subtable) they are
#'   associated with. Use a value of `" "` to display a blank line
#'   section divider in the table. A section divider of
#'   `NA_character_` indicates no visible divider (i.e., no line at all)
#'   should be printed for that row or section when rendering the table.
#'
#' When multiple section dividers would appear consecutively with no
#'  rows between them (e.g., a subtable and its last row both having a
#'  section divider set), only the *least specific* section divider
#'  (the subtable divider in this example) will be displayed when
#'  rendering the table. This is to avoid multiple non-informative
#'  lines of consecutive dividers when there is nested splitting in
#'  the row structure of a table.
#'
#' `section_div_at_path<-` accepts a single path (which can include
#'   the `'*'` wildcard), and a single string in `value` and sets the
#'   section divider on the element(s) of `obj` that the path resolve
#'   to.
#'
#' For `section_div<-` `value` should be a character vector. When you
#'   want to only affect sections or splits, please use
#'   `only_sep_sections` or provide a shorter vector than the number
#'   of rows.  Ideally, the length of the vector should be less than
#'   the number of splits with, eventually, the leaf-level,
#'   i.e. `DataRow` where analyze results are. Note that if only one
#'   value is inserted, only the first split will be affected.  If
#'   `only_sep_sections = TRUE`, which is the default for
#'   `section_div()` produced from the table construction, the section
#'   divider will be set for all the splits and eventually analyses,
#'   but not for the header or each row of the table. This can be set
#'   with `header_section_div` in [basic_table()] or, eventually, with
#'   `hsep` in [build_table()]. If `only_sep_sections` is `FALSE`,
#'   "section" dividers will be set for each row in the table
#'   *including content and label rows*.
#'
#' In `section_div<-`, when `only_sep_sections` is `FALSE`
#'   *all higher order section divs are removed, even when new value
#'   for a row that they would apply to is `NA`*.
#'
#' @note Section dividers which would appear after the last row of the
#'     table (ie those on the last row or last elementary subtable in
#'     the table) are never printed when rendering the table.
#'
#' @note when called on an individual row object, `section_div` and
#'   `section_div<-` get and set the trialing divider for that row.
#'   In generally this is to be avoided; when manually constructing
#'   row objects, the `trailing_section_div` argument can set the
#'   trailing divider directly during creation.
#'
#' @examples
#' # Data
#' df <- data.frame(
#'   cat = c(
#'     "really long thing its so ", "long"
#'   ),
#'   value = c(6, 3, 10, 1)
#' )
#' fast_afun <- function(x) list("m" = rcell(mean(x), format = "xx."), "m/2" = max(x) / 2)
#'
#' tbl <- basic_table() |>
#'   split_rows_by("cat", section_div = "~") |>
#'   analyze("value", afun = fast_afun, section_div = " ") |>
#'   build_table(df)
#'
#' # Getter
#' section_div(tbl)
#'
#' # Setter
#' section_div(tbl) <- letters[seq_len(nrow(tbl))]
#' tbl
#'
#' # last letter can appear if there is another table
#' rbind(tbl, tbl)
#'
#' # header_section_div
#' header_section_div(tbl) <- "+"
#' tbl
#'
#' @docType methods
#' @rdname section_div
#' @export
setGeneric("section_div", function(obj) standardGeneric("section_div"))

#' @rdname section_div
#' @aliases section_div,VTableTree-method
setMethod("section_div", "VTableTree", function(obj) {
  ## simpler but slower because it currently calls make_row_df then subsets
  ## section_div_info(obj)$trailing_sep
  ## TODO reimplement section_div_info based on logic here then
  ## replace code below with single call above
  content_row_tbl <- content_table(obj)
  is_content_table <- isS4(content_row_tbl) && nrow(content_row_tbl) > 0 # otherwise NA or NULL
  if (labelrow_visible(obj)) {
    lrdiv <- trailing_section_div(tt_labelrow(obj))
  } else {
    lrdiv <- NULL
  }

  if (is_content_table) {
    ctdivs <- section_div(content_row_tbl)
  } else {
    ctdivs <- NULL
  }
  section_div <- trailing_section_div(obj)
  rest_of_tree <- section_div(tree_children(obj))
  ## Case it is the section itself and not the labels to have a trailing sep
  if (!is.na(section_div)) {
    rest_of_tree[length(rest_of_tree)] <- section_div
  }
  unname(c(lrdiv, ctdivs, rest_of_tree))
})

#' @rdname section_div
#' @aliases section_div,list-method
setMethod("section_div", "list", function(obj) {
  unlist(lapply(obj, section_div))
})

#' @rdname section_div
#' @aliases section_div,TableRow-method
setMethod("section_div", "TableRow", function(obj) {
  trailing_section_div(obj)
})


# section_div setter from table object
#' @rdname section_div
#' @export
setGeneric("section_div<-", function(obj, only_sep_sections = FALSE, value) {
  standardGeneric("section_div<-")
})

#' @rdname section_div
#' @aliases section_div<-,VTableTree-method
setMethod("section_div<-", "VTableTree", function(obj, only_sep_sections = FALSE, value) {
  sdf <- section_div_info(obj)
  value <- as.character(value)
  pths <- sdf$path
  if (length(value) < length(pths)) {
    only_sep_sections <- TRUE
  }
  ## I really don't like this but it should be the correct generalization
  ## of the previous behavior :(
  if (only_sep_sections) {
    curpth <- c(if (grepl("root", obj_name(obj))) "*", "*") # root split and val)
    for (i in seq_along(value)) {
      v <- value[i]
      found <- FALSE
      ## split-value pairs (or multi-analysis analysis pairs...)
      if (tt_row_path_exists(obj, curpth, tt_type = "table")) {
        section_div_at_path(obj, curpth, tt_type = "table") <- v
        found <- TRUE
      }
      ## last step was an analysis instead of another split_value pair
      ## remember, currently only analyze and summarize_row_groups
      ## create elementary tables, and an odd number of *s will never
      ## resolve to a content table, so this tt_type means analysis
      ## table in this context
      if (tt_row_path_exists(obj, head(curpth, -1), tt_type = "elemtable")) {
        section_div_at_path(obj, head(curpth, -1), tt_type = "elemtable") <- v
        found <- TRUE
      }
      if (!found) {
        warning(
          "Unable to find ", ceiling(length(curpth) / 2), " levels of nesting",
          " in table structure. Ignoring remaining ", length(value) - i,
          " section_div values."
        )
        break
      }
      curpth <- c(curpth, "*", "*") ## add another split/value pair level of nesting
    }
  } else { ## guaranteed length(value) >= nrow(obj)
    if (length(value) > nrow(obj)) {
      warning(
        "Got more section_div values than rows. Ignoring ",
        nrow(obj) - length(value), " values."
      )
      value <- value[seq_len(nrow(obj))]
    }
    ## clear out the structural (ie from layout) section divs so all
    ## the row divs take effect. Not sure this is right but its the existing behavior
    obj <- clear_subtable_sectdivs(obj)
    for (i in seq_along(pths)) {
      section_div_at_path(obj, labelrow = TRUE, pths[[i]], tt_type = "row") <- value[i]
    }
  }
  obj
})

#' @rdname section_div
#' @aliases section_div<-,TableRow-method
setMethod("section_div<-", "TableRow", function(obj, only_sep_sections = FALSE, value) {
  trailing_section_div(obj) <- value
  obj
})

#' @rdname section_div
#' @export
setGeneric("header_section_div", function(obj) standardGeneric("header_section_div"))

#' @rdname section_div
#' @aliases header_section_div,PreDataTableLayouts-method
setMethod(
  "header_section_div", "PreDataTableLayouts",
  function(obj) obj@header_section_div
)

#' @rdname section_div
#' @aliases header_section_div,PreDataTableLayouts-method
setMethod(
  "header_section_div", "VTableTree",
  function(obj) obj@header_section_div
)

#' @rdname section_div
#' @export
setGeneric("header_section_div<-", function(obj, value) standardGeneric("header_section_div<-"))

#' @rdname section_div
#' @aliases header_section_div<-,PreDataTableLayouts-method
setMethod(
  "header_section_div<-", "PreDataTableLayouts",
  function(obj, value) {
    .check_header_section_div(value)
    obj@header_section_div <- value
    obj
  }
)

#' @rdname section_div
#' @aliases header_section_div<-,PreDataTableLayouts-method
setMethod(
  "header_section_div<-", "VTableTree",
  function(obj, value) {
    .check_header_section_div(value)
    obj@header_section_div <- value
    obj
  }
)

.check_header_section_div <- function(chr) {
  if (!is.na(chr) && (!is.character(chr) || length(chr) > 1 || nchar(chr) > 1 || nchar(chr) == 0)) {
    stop("header_section_div must be a single character or NA_character_ if not used")
  }
  invisible(TRUE)
}

#' @rdname section_div
#' @export
setGeneric("top_level_section_div", function(obj) standardGeneric("top_level_section_div"))

#' @rdname section_div
#' @aliases top_level_section_div,PreDataTableLayouts-method
setMethod(
  "top_level_section_div", "PreDataTableLayouts",
  function(obj) obj@top_level_section_div
)

#' @rdname section_div
#' @export
setGeneric("top_level_section_div<-", function(obj, value) standardGeneric("top_level_section_div<-"))

#' @rdname section_div
#' @aliases top_level_section_div<-,PreDataTableLayouts-method
setMethod(
  "top_level_section_div<-", "PreDataTableLayouts",
  function(obj, value) {
    checkmate::assert_character(value, len = 1, n.chars = 1)
    obj@top_level_section_div <- value
    obj
  }
)

#' @rdname section_div
#' @details A `section_div` -> modify -> `section_div<-` workflow will
#'     not work to modify section dividers declared in a layout (i.e.,
#'     with `split_rows_by*(., section_div=)` or
#'     `analyze(.,section_div=)`) after the table has been built. In
#'     that case a row 'inherits' its section divider behavior from
#'     the largest subtable that has a section divider set and for
#'     which it is the final row. Instead it clears the higher-order
#'     section dividers and sets an individual divider on each row
#'     (setting `NA_character_` for rows that had no divider after them
#'     when rendering). This means that if pruning is done after
#'     the above process and the last row in a "section" is pruned,
#'     the last remaining row *will not inherit the section's divider*
#'     the way it would before the modification by `section_div<-`.
#'
#' Generally it is advisable to use `section_div_at_path<-` - often
#'    with `"*"` wildcards in the path - to modify
#'    dividers declared in the layout instead of `section_div<-`.
#'    Alternatively, pruning should be done *before* calling
#'    `section_div<-` (when passing a a vector of length `nrow(tt)`),
#'    when a script or function will do both operations on a table.
#'
#' Setting section_dividers for rows which do not currently inherit
#'     section divider behavior from a containing subtable will work
#'     as expected.
#'
#' `section_div_info` returns a data.frame of section divider
#'     info (a subset of the result of `make_row_df` when called on a
#'     table tree or row object).  This information can be used to reset
#'     section dividers at the correct path via `section_div_at_path` for
#'     tables which have section dividers deriving from their layout (
#'     which will be attached to subtables, rather than rows).
#' @return For `section_div_info`, a dataframe containing `label`,
#'     `name`, "node_class", `path`, `trailing_sep` (the effective divider, whether
#'     inherited or not), `self_section_div` (the divider set on the
#'     row itself), and `sect_div_from_path` (the path to the table
#'     element the value in `trailing_sep` is inherited from, or
#'     `NA_character_` for label rows, which are not pathable).
#' @export
section_div_info <- function(obj) {
  ## default fontspec is already NULL so no speedup here
  make_row_df(obj)[, c(
    "label",
    "name",
    "node_class",
    "path",
    "trailing_sep",
    "self_section_div",
    "sect_div_from_path"
  )]
}

#' @rdname section_div
#' @param path (`character`)\cr The path of the element(s) to
#' set section_div(s) on. Can include `'*'` wildcards for
#' `section_div_at_path<-` only.
#' @param labelrow (`logical(1)`)\cr For `section_div_at_path`,
#' when `path` leads to a subtable, indicates whether the section
#' div be set/retrieved for the subtable (`FALSE`, the default) or the
#' subtable's label row (`TRUE`). Ignored when `path` resolves to an
#' individual row.
#' @export
section_div_at_path <- function(obj, path, labelrow = FALSE) {
  tt <- tt_at_path(obj, path)
  if (is(tt, "VTableTree") && labelrow) {
    tt <- tt_labelrow(tt)
  }
  trailing_section_div(tt)
}

clear_subtable_sectdivs <- function(obj) {
  rdf <- make_row_df(obj, visible_only = FALSE)
  rdf <- rdf[grepl("Table", rdf$node_class), ]
  for (pth in rdf$path) {
    section_div_at_path(obj, pth, labelrow = FALSE, tt_type = "table") <- NA_character_
  }
  obj
}

#' @rdname section_div
#' @param .prev_path (`character`)\cr Internal detail, do not manually set.
#' @export
`section_div_at_path<-` <- function(obj,
                                    path,
                                    .prev_path = character(),
                                    labelrow = FALSE,
                                    tt_type = c("any", "row", "table", "elemtable"),
                                    value = " ") {
  tt_type <- match.arg(tt_type)
  if (labelrow && tt_type == "any") {
    tt_type <- "table"
  }
  if (NROW(obj) == 0) {
    return(character())
  }

  if (path[1] == "root") {
    if (obj_name(obj) == "root") {
      .prev_path <- c(.prev_path, path[1])
    }
    path <- path[-1]
  }
  if (identical(obj_name(obj), path[1])) {
    .prev_path <- c(.prev_path, path[1])
    path <- path[-1]
  }
  curpath <- path
  subtree <- obj
  backpath <- c()
  count <- 0
  while (length(curpath) > 0) {
    curname <- curpath[1]
    if (!is(subtree, "VTableTree")) {
      stop(
        "Path continues after resolving to individual row.\n\tOccurred at path: ",
        paste(c(.prev_path, path[seq_len(count)]), collapse = " -> "),
        "\n\tRemaining unresolved path: ",
        paste(tail(path, -1 * count), collapse = "->"),
        "\nUse 'make_row_df(obj, visible_only = TRUE)[, c(\"label\", \"path\", \"node_class\")]' or \n",
        "'table_structure(obj)' to explore valid paths."
      )
    }
    oldkids <- tree_children(subtree)
    if (curname == "*") {
      oldnames <- vapply(oldkids, obj_name, "")
      if (length(curpath) > 1) {
        ## look ahead and only step into kids where the remaining path will
        ## successfully resolve
        kidmatches <- which(vapply(oldkids, tt_row_path_exists, TRUE, path = curpath[-1], tt_type = tt_type))
        if (length(kidmatches) == 0) {
          stop(
            "Unable to resolve * in path. \n\tOccurred at path: ",
            paste(c(.prev_path, path[seq_len(count + 1)]), collapse = " -> "),
            "\n\tLookahead found no matches (type ", tt_type, ") for the remaining path: ",
            paste(path[-1 * seq_len(count + 1)], collapse = "->"),
            "\nUse 'make_row_df(obj, visible_only = TRUE)[, c(\"label\", \"path\", \"node_class\")]' or \n",
            "'table_structure(obj)' to explore valid paths."
          )
        }
        newkids <- lapply(seq_along(oldkids), function(i) {
          kid <- oldkids[[i]]
          if (i %in% kidmatches) {
            new_prev_path <- c(
              .prev_path, backpath,
              paste0("* (", oldnames[i], ")")
            )
            section_div_at_path(kid,
              path = curpath[-1],
              .prev_path = new_prev_path
            ) <- value
          }
          kid
        })
      } else {
        newkids <- lapply(oldkids, function(kdi) {
          trailing_section_div(kdi) <- value
          kdi
        })
      }
      names(newkids) <- oldnames
      newtab <- subtree
      tree_children(newtab) <- newkids
      if (length(backpath) > 0) {
        ret <- recursive_replace(obj, backpath, value = newtab)
      } else {
        ret <- newtab
      }
      return(ret)
    } else if (curname == "@content") {
      ctab <- content_table(subtree)
      # curpath is just 'content' resolve to content table
      if (length(curpath) == 1) {
        trailing_section_div(ctab) <- value
        ## weird to set section divs on content rows but that is what the
        ## section_div()<- <full vector> behavior calls for
      } else if (length(curpath) == 2 && tt_row_path_exists(ctab, curpath[2])) {
        section_div_at_path(ctab, curpath[2], tt_type = "row") <- value
      } else {
        stop(
          "Unable to resolve path step involving @content \n\t occurred at path: ",
          paste(c(.prev_path, path[seq_len(count)]), collapse = " -> "),
          "\nUse 'make_row_df(obj, visible_only = TRUE)[, c(\"label\", \"path\", \"node_class\")]' or \n",
          "'table_structure(obj)' to explore valid paths."
        )
      }
      content_table(subtree) <- ctab
      if (length(backpath) > 0) {
        ret <- recursive_replace(obj, backpath, value = subtree)
      } else {
        ret <- subtree
      }
      return(ret)
    } else if (!(curname %in% names(oldkids))) {
      stop(
        "Unable to find child(ren) '", curname, "'\n\t occurred at path: ",
        paste(c(.prev_path, path[seq_len(count)]), collapse = " -> "),
        "\n  Use 'make_row_df(obj, visible_only = TRUE)[, c(\"label\", \"path\", \"node_class\")]' or \n",
        "'table_structure(obj)' to explore valid paths."
      )
    }
    subtree <- tree_children(subtree)[[curname]]
    backpath <- c(backpath, curpath[1])
    curpath <- curpath[-1]
    count <- count + 1
  }
  ## ElementaryTables have 2 modes, label row which
  ## puts the section div after the label row (weird
  ## but necessary for the replacing every row's section div
  ## case), or tree, where we set trailing div
  ## **on the subtable itself**
  ##
  ## womp womp. tt_type_ok fails for subtables when we want their label row.
  if (!tt_type_ok(subtree, tt_type) && !(labelrow && is(subtree, "VTableTree") && tt_type == "row")) {
    stop(
      "Path ",
      paste(c(.prev_path, path[seq_len(count)]), collapse = " -> "),
      " lead to an element of the wrong tt_type (got ", class(subtree),
      " expected ", tt_type
    )
  } else if (is(subtree, "TableRow") || !labelrow) {
    ## rows can only set it on themselves
    ## if its a table (and tables are allowed by tt_type) it sets it on
    ## itself iff labelrow is FALSE

    trailing_section_div(subtree) <- value
    newtree <- subtree
  } else if (labelrow && is(subtree, "VTableTree")) {
    lr <- tt_labelrow(subtree)
    trailing_section_div(lr) <- value
    tt_labelrow(subtree) <- lr
    newtree <- subtree
  }
  tt_at_path(obj, path) <- newtree
  obj
}

## table_inset ----------------------------------------------------------

#' @rdname formatters_methods
#' @export
setMethod(
  "table_inset", "VTableNodeInfo", ## VTableTree",
  function(obj) obj@table_inset
)

#' @rdname formatters_methods
#' @export
setMethod(
  "table_inset", "PreDataTableLayouts",
  function(obj) obj@table_inset
)

## #' @rdname formatters_methods
## #' @export
## setMethod("table_inset", "InstantiatedColumnInfo",
##           function(obj) obj@table_inset)

#' @rdname formatters_methods
#' @export
setMethod(
  "table_inset<-", "VTableNodeInfo", ## "VTableTree",
  function(obj, value) {
    if (!is.integer(value)) {
      value <- as.integer(value)
    }
    if (is.na(value) || value < 0) {
      stop("Got invalid table_inset value, must be an integer > 0")
    }
    cont <- content_table(obj)
    if (NROW(cont) > 0) {
      table_inset(cont) <- value
      content_table(obj) <- cont
    }

    if (length(tree_children(obj)) > 0) {
      kids <- lapply(tree_children(obj),
        `table_inset<-`,
        value = value
      )
      tree_children(obj) <- kids
    }
    obj@table_inset <- value
    obj
  }
)

#' @rdname formatters_methods
#' @export
setMethod(
  "table_inset<-", "PreDataTableLayouts",
  function(obj, value) {
    if (!is.integer(value)) {
      value <- as.integer(value)
    }
    if (is.na(value) || value < 0) {
      stop("Got invalid table_inset value, must be an integer > 0")
    }

    obj@table_inset <- value
    obj
  }
)

#' @rdname formatters_methods
#' @export
setMethod(
  "table_inset<-", "InstantiatedColumnInfo",
  function(obj, value) {
    if (!is.integer(value)) {
      value <- as.integer(value)
    }
    if (is.na(value) || value < 0) {
      stop("Got invalid table_inset value, must be an integer > 0")
    }
    obj@table_inset <- value
    obj
  }
)

# stat_names for ARD -----------------------------------------------------------
#
#' @rdname int_methods
#' @export
setGeneric("obj_stat_names", function(obj) standardGeneric("obj_stat_names"))
#
#' @rdname int_methods
#' @export
setGeneric("obj_stat_names<-", function(obj, value) standardGeneric("obj_stat_names<-"))

#' @rdname int_methods
#' @export
setMethod("obj_stat_names<-", "CellValue", function(obj, value) {
  attr(obj, "stat_names") <- value
  obj
})

#' @rdname int_methods
#' @export
setMethod("obj_stat_names", "CellValue", function(obj) attr(obj, "stat_names"))

#' @rdname int_methods
#' @export
setMethod(
  "obj_stat_names", "RowsVerticalSection",
  function(obj) lapply(obj, obj_stat_names)
)

# obj_round_type getter ---------------------------------------------------------------
#' @rdname formatters_methods
#' @exportMethod obj_round_type
setMethod("obj_round_type", "ANY", function(obj) attr(obj, "round_type", exact = TRUE))

#' generics and methods for obj_round_type
#'
#' These are internal methods that are documented only to satisfy `R CMD check`. End users should pay no
#' attention to this documentation, except for the few exported methods.
#'
#' @rdname formatters_methods
#' @exportMethod obj_round_type
#' @export
setMethod("obj_round_type", "PreDataTableLayouts", function(obj) obj@round_type)

#' @rdname formatters_methods
#' @exportMethod obj_round_type
#' @export
setMethod("obj_round_type", "VTableTree", function(obj) obj@round_type)

#' @rdname formatters_methods
#' @exportMethod obj_round_type
setMethod("obj_round_type", "TableRow", function(obj) obj@round_type)

#' @rdname formatters_methods
#' @exportMethod obj_round_type
setMethod("obj_round_type", "CellValue", function(obj) attr(obj, "round_type", exact = TRUE))

# obj_round_type setter ---------------------------------------------------------------
#' @rdname formatters_methods
#' @exportMethod obj_round_type<-
#' @export
setMethod("obj_round_type<-", "VTableTree", function(obj, value) {
  stopifnot(length(value) == 1)
  checkmate::assert_subset(value, valid_round_type)
  obj@round_type <- value
  # also set round_type to slot in children class
  tree_children(obj) <- lapply(tree_children(obj), `obj_round_type<-`, value = value)
  if (!is.null(content_table(obj))) {
    ctab <- content_table(obj)
    obj_round_type(ctab) <- value
  }
  obj
})

#' @rdname formatters_methods
#' @exportMethod obj_round_type<-
# not useful for end user, needed for recursive approach
setMethod("obj_round_type<-", "TableRow", function(obj, value) {
  obj@round_type <- value
  row_cells(obj) <- lapply(row_cells(obj), `obj_round_type<-`, value = value)
  obj
})


#' @rdname formatters_methods
#' @exportMethod obj_round_type<-
# not useful for end user, needed for recursive approach
setMethod("obj_round_type<-", "LabelRow", function(obj, value) {
  obj
})


#' @rdname formatters_methods
#' @exportMethod obj_round_type<-
setMethod("obj_round_type<-", "CellValue", function(obj, value) {
  attr(obj, "round_type") <- value
  obj
})
