match_extra_args <- function(f,
                             .N_col,
                             .N_total,
                             .all_col_exprs,
                             .all_col_counts,
                             .var,
                             .ref_group = NULL,
                             .alt_df_row = NULL,
                             .alt_df = NULL,
                             .alt_df_full = NULL,
                             .ref_full = NULL,
                             .in_ref_col = NULL,
                             .spl_context = NULL,
                             .N_row,
                             .df_row,
                             extras) {
  # This list is always present
  possargs <- c(
    list(
      .N_col = .N_col,
      .N_total = .N_total,
      .N_row = .N_row,
      .df_row = .df_row,
      .all_col_exprs = .all_col_exprs,
      .all_col_counts = .all_col_counts
    ),
    extras
  )

  ## specialized arguments that must be named in formals, cannot go
  ## anonymously into ...
  if (!is.null(.var) && nzchar(.var)) {
    possargs <- c(possargs, list(.var = .var))
  }
  if (!is.null(.ref_group)) {
    possargs <- c(possargs, list(.ref_group = .ref_group))
  }
  if (!is.null(.alt_df_row)) {
    possargs <- c(possargs, list(.alt_df_row = .alt_df_row))
  }
  if (!is.null(.alt_df)) {
    possargs <- c(possargs, list(.alt_df = .alt_df))
  }

  if (!is.null(.alt_df_full)) {
    possargs <- c(possargs, list(.alt_df_full = .alt_df_full))
  }

  if (!is.null(.ref_full)) {
    possargs <- c(possargs, list(.ref_full = .ref_full))
  }
  if (!is.null(.in_ref_col)) {
    possargs <- c(possargs, list(.in_ref_col = .in_ref_col))
  }

  # Special case: .spl_context
  if (!is.null(.spl_context) && !(".spl_context" %in% names(possargs))) {
    possargs <- c(possargs, list(.spl_context = .spl_context))
  } else {
    possargs$.spl_context <- NULL
  }

  # Extra args handling
  formargs <- formals(f)
  formnms <- names(formargs)
  exnms <- names(extras)
  if (is.null(formargs)) {
    return(NULL)
  } else if ("..." %in% names(formargs)) {
    formnms <- c(formnms, exnms[nzchar(exnms)])
  }
  possargs[names(possargs) %in% formnms]
}

#' @noRd
#' @return A `RowsVerticalSection` object representing the `k x 1` section of the
#'   table being generated, with `k` the number of rows the analysis function
#'   generates.
gen_onerv <- function(csub, col, count, cextr, cpath,
                      dfpart, func, totcount, splextra,
                      all_col_exprs,
                      all_col_counts,
                      takesdf = .takes_df(func),
                      baselinedf,
                      alt_dfpart,
                      alt_df_full,
                      inclNAs,
                      col_parent_inds,
                      spl_context) {
  if (NROW(spl_context) > 0) {
    spl_context$cur_col_id <- paste(cpath[seq(2, length(cpath), 2)], collapse = ".")
    spl_context$cur_col_subset <- col_parent_inds
    spl_context$cur_col_expr <- list(csub)
    spl_context$cur_col_n <- vapply(col_parent_inds, sum, 1L)
    spl_context$cur_col_split <- list(cpath[seq(1, length(cpath), 2)])
    spl_context$cur_col_split_val <- list(cpath[seq(2, length(cpath), 2)])
  }

  # Making .alt_df from alt_dfpart (i.e. .alt_df_row)
  if (NROW(alt_dfpart) > 0) {
    alt_dfpart_fil <- alt_dfpart[eval(csub, envir = alt_dfpart), , drop = FALSE]
    if (!is.null(col) && col %in% names(alt_dfpart_fil) && !inclNAs) {
      alt_dfpart_fil <- alt_dfpart_fil[!is.na(alt_dfpart_fil[[col]]), ,
        drop = FALSE
      ]
    }
  } else {
    alt_dfpart_fil <- alt_dfpart
  }

  ## workaround for https://github.com/pharmaverse/rtables/issues/159
  if (NROW(dfpart) > 0) {
    inds <- eval(csub, envir = dfpart)
    dat <- dfpart[inds, , drop = FALSE]
  } else {
    dat <- dfpart
  }
  if (!is.null(col) && !inclNAs) {
    dat <- dat[!is.na(dat[[col]]), , drop = FALSE]
  }

  fullrefcoldat <- cextr$.ref_full
  if (!is.null(fullrefcoldat)) {
    cextr$.ref_full <- NULL
  }
  inrefcol <- cextr$.in_ref_col
  if (!is.null(fullrefcoldat)) {
    cextr$.in_ref_col <- NULL
  }

  exargs <- c(cextr, splextra)

  ## behavior for x/df and ref-data (full and group)
  ## match
  if (!is.null(col) && !takesdf) {
    dat <- dat[[col]]
    fullrefcoldat <- fullrefcoldat[[col]]
    baselinedf <- baselinedf[[col]]
  }
  args <- list(dat)

  names(all_col_counts) <- names(all_col_exprs)

  exargs <- match_extra_args(func,
    .N_col = count,
    .N_total = totcount,
    .all_col_exprs = all_col_exprs,
    .all_col_counts = all_col_counts,
    .var = col,
    .ref_group = baselinedf,
    .alt_df_row = alt_dfpart,
    .alt_df = alt_dfpart_fil,
    .alt_df_full = alt_df_full,
    .ref_full = fullrefcoldat,
    .in_ref_col = inrefcol,
    .N_row = NROW(dfpart),
    .df_row = dfpart,
    .spl_context = spl_context,
    extras = c(
      cextr,
      splextra
    )
  )

  args <- c(args, exargs)

  val <- do.call(func, args)
  if (!is(val, "RowsVerticalSection")) {
    if (!is(val, "list")) {
      val <- list(val)
    }
    ret <- in_rows(
      .list = val,
      .labels = unlist(value_labels(val)),
      .names = names(val)
    )
  } else {
    ret <- val
  }
  ret
}

strip_multivar_suffix <- function(x) {
  gsub("\\._\\[\\[[0-9]\\]\\]_\\.$", "", x)
}

## Generate all values (one for each column) for one or more rows
## by calling func once per column (as defined by cinfo)
#' @noRd
#' @return A list of `m` `RowsVerticalSection` objects, one for each (leaf) column in the table.
gen_rowvalues <- function(dfpart,
                          datcol,
                          cinfo,
                          func,
                          splextra,
                          takesdf = NULL,
                          baselines,
                          alt_dfpart,
                          alt_df_full,
                          inclNAs,
                          spl_context) {
  colexprs <- col_exprs(cinfo)
  colcounts <- col_counts(cinfo)
  colextras <- col_extra_args(cinfo, NULL)
  cpaths <- col_paths(cinfo)
  ## XXX I don't think this is used anywhere???
  ## splextra = c(splextra, list(.spl_context = spl_context))
  totcount <- col_total(cinfo)

  colleaves <- collect_leaves(cinfo@tree_layout)

  gotflist <- is.list(func)

  ## one set of named args to be applied to all columns
  if (!is.null(names(splextra))) {
    splextra <- list(splextra)
  } else {
    length(splextra) <- ncol(cinfo)
  }

  if (!gotflist) {
    func <- list(func)
  } else if (length(splextra) == 1) {
    splextra <- rep(splextra, length.out = length(func))
  }
  ## if(length(func)) == 1 && names(spl)
  ##     splextra = list(splextra)

  ## we are in analyze_colvars, so we have to match
  ## the exargs value by position for each column repeatedly
  ## across the higher level col splits.
  if (!is.null(datcol) && is.na(datcol)) {
    datcol <- character(length(colleaves))
    exargs <- vector("list", length(colleaves))
    for (i in seq_along(colleaves)) {
      x <- colleaves[[i]]

      pos <- tree_pos(x)
      spls <- pos_splits(pos)
      ## values have the suffix but we are populating datacol
      ## so it has to match var numbers so strip the suffixes back off
      splvals <- strip_multivar_suffix(rawvalues(pos))
      n <- length(spls)
      datcol[i] <- if (is(spls[[n]], "MultiVarSplit")) {
        splvals[n]
      } else {
        NA_character_
      }
      argpos <- match(datcol[i], spl_payload(spls[[n]]))
      ## single bracket here because assigning NULL into a list removes
      ## the position entirely
      exargs[i] <- if (argpos <= length(splextra)) {
        splextra[argpos]
      } else {
        list(NULL)
      }
    }
    ## })
    if (all(is.na(datcol))) {
      datcol <- list(NULL)
    } else if (any(is.na(datcol))) {
      stop("mix of var and non-var columns with NA analysis rowvara")
    }
  } else {
    exargs <- splextra
    if (is.null(datcol)) {
      datcol <- list(NULL)
    }
    datcol <- rep(datcol, length(colexprs))
    ## if(gotflist)
    ##     length(exargs) <- length(func) ## func is a list
    exargs <- rep(exargs, length.out = length(colexprs))
  }
  allfuncs <- rep(func, length.out = length(colexprs))

  if (is.null(takesdf)) {
    takesdf <- .takes_df(allfuncs)
  }

  rawvals <- mapply(gen_onerv,
    csub = colexprs,
    col = datcol,
    count = colcounts,
    cextr = colextras,
    cpath = cpaths,
    baselinedf = baselines,
    alt_dfpart = list(alt_dfpart),
    func = allfuncs,
    takesdf = takesdf,
    col_parent_inds = spl_context[, names(colexprs),
      drop = FALSE
    ],
    all_col_exprs = list(colexprs),
    all_col_counts = list(colcounts),
    splextra = exargs,
    MoreArgs = list(
      dfpart = dfpart,
      alt_df_full = alt_df_full,
      totcount = totcount,
      inclNAs = inclNAs,
      spl_context = spl_context
    ),
    SIMPLIFY = FALSE
  )

  names(rawvals) <- names(colexprs)
  rawvals
}

.strip_lst_rvals <- function(lst) {
  lapply(lst, rawvalues)
}

#' @noRd
#' @return A list of table rows, even when only one is generated.
.make_tablerows <- function(dfpart,
                            alt_dfpart,
                            alt_df_full,
                            func,
                            cinfo,
                            datcol = NULL,
                            lev = 1L,
                            rvlab = NA_character_,
                            format = NULL,
                            defrowlabs = NULL,
                            rowconstr = DataRow,
                            splextra = list(),
                            takesdf = NULL,
                            baselines = replicate(
                              length(col_exprs(cinfo)),
                              list(dfpart[0, ])
                            ),
                            inclNAs,
                            spl_context = context_df_row(cinfo = cinfo)) {
  if (is.null(datcol) && !is.na(rvlab)) {
    stop("NULL datcol but non-na rowvar label")
  }
  if (!is.null(datcol) && !is.na(datcol)) {
    if (!all(datcol %in% names(dfpart))) {
      stop(
        "specified analysis variable (", datcol,
        ") not present in data"
      )
    }

    rowvar <- datcol
  } else {
    rowvar <- NA_character_
  }

  rawvals <- gen_rowvalues(dfpart,
    alt_dfpart = alt_dfpart,
    alt_df_full = alt_df_full,
    datcol = datcol,
    cinfo = cinfo,
    func = func,
    splextra = splextra,
    takesdf = takesdf,
    baselines = baselines,
    inclNAs = inclNAs,
    spl_context = spl_context
  )

  ## if(is.null(rvtypes))
  ##     rvtypes = rep(NA_character_, length(rawvals))
  lens <- vapply(rawvals, length, NA_integer_)
  unqlens <- unique(lens)
  ## length 0 returns are ok to not match cause they are
  ## just empty space we can fill in as needed.
  if (length(unqlens[unqlens > 0]) != 1L) { ## length(unqlens) != 1 &&
    ## (0 %in% unqlens && length(unqlens) != 2)) {
    stop(
      "Number of rows generated by analysis function do not match ",
      "across all columns. ",
      if (!is.na(datcol) && is.character(dfpart[[datcol]])) {
        paste(
          "\nPerhaps convert analysis variable", datcol,
          "to a factor?"
        )
      }
    )
  }
  maxind <- match(max(unqlens), lens)

  ## look if we got labels, if not apply the
  ## default row labels
  ## this is guaranteed to be a RowsVerticalSection object.
  rv1col <- rawvals[[maxind]]
  ## nocov start
  if (!is(rv1col, "RowsVerticalSection")) {
    stop(
      "gen_rowvalues appears to have generated something that was not ",
      "a RowsVerticalSection object. Please contact the maintainer."
    )
  }
  # nocov end

  labels <- value_labels(rv1col)

  ncrows <- max(unqlens)
  if (ncrows == 0) {
    return(list())
  }
  stopifnot(ncrows > 0)

  if (is.null(labels)) {
    if (length(rawvals[[maxind]]) == length(defrowlabs)) {
      labels <- defrowlabs
    } else {
      labels <- rep("", ncrows)
    }
  }

  rfootnotes <- rep(list(list(), length(rv1col)))
  nms <- value_names(rv1col)
  rfootnotes <- row_footnotes(rv1col)

  imods <- indent_mod(rv1col) ## rv1col@indent_mods
  unwrapped_vals <- lapply(rawvals, as, Class = "list", strict = TRUE)

  formatvec <- NULL
  if (!is.null(format)) {
    if (is.function(format)) {
      format <- list(format)
    }
    formatvec <- rep(format, length.out = ncrows)
  }

  trows <- lapply(1:ncrows, function(i) {
    rowvals <- lapply(unwrapped_vals, function(colvals) {
      colvals[[i]]
    })
    imod <- unique(vapply(rowvals, indent_mod, 0L))
    if (length(imod) != 1) {
      stop(
        "Different cells in the same row appear to have been given ",
        "different indent_mod values"
      )
    }
    rowconstr(
      vals = rowvals,
      cinfo = cinfo,
      lev = lev,
      label = labels[i],
      name = nms[i], ## labels[i], ## XXX this is probably wrong?!
      var = rowvar,
      format = formatvec[[i]],
      indent_mod = imods[[i]] %||% 0L,
      footnotes = rfootnotes[[i]] ## one bracket so list
    )
  })
  trows
}

.make_caller <- function(parent_cfun, clabelstr = "") {
  formalnms <- names(formals(parent_cfun))
  ## note the <- here
  if (!is.na(dotspos <- match("...", formalnms))) {
    toremove <- dotspos
  } else {
    toremove <- NULL
  }

  labelstrpos <- match("labelstr", names(formals(parent_cfun)))
  if (is.na(labelstrpos)) {
    stop(
      "content function does not appear to accept the labelstr",
      "arguent"
    )
  }
  toremove <- c(toremove, labelstrpos)
  formalnms <- formalnms[-1 * toremove]

  caller <- eval(parser_helper(text = paste(
    "function() { parent_cfun(",
    paste(formalnms, "=",
      formalnms,
      collapse = ", "
    ),
    ", labelstr = clabelstr, ...)}"
  )))
  formals(caller) <- c(
    formals(parent_cfun)[-labelstrpos],
    alist("..." = )
  ) # nolint
  caller
}

# Makes content table xxx renaming
.make_ctab <- function(df,
                       lvl, ## treepos,
                       name,
                       label,
                       cinfo,
                       parent_cfun = NULL,
                       format = NULL,
                       na_str = NA_character_,
                       indent_mod = 0L,
                       cvar = NULL,
                       inclNAs,
                       alt_df,
                       alt_df_full,
                       extra_args,
                       spl_context = context_df_row(cinfo = cinfo)) {
  if (length(cvar) == 0 || is.na(cvar) || identical(nchar(cvar), 0L)) {
    cvar <- NULL
  }
  if (!is.null(parent_cfun)) {
    ## cfunc <- .make_caller(parent_cfun, label)
    cfunc <- lapply(parent_cfun, .make_caller, clabelstr = label)
    contkids <- tryCatch(
      .make_tablerows(df,
        lev = lvl,
        func = cfunc,
        cinfo = cinfo,
        rowconstr = ContentRow,
        datcol = cvar,
        takesdf = rep(.takes_df(cfunc),
          length.out = ncol(cinfo)
        ),
        inclNAs = FALSE,
        alt_dfpart = alt_df,
        alt_df_full = alt_df_full,
        splextra = extra_args,
        spl_context = spl_context
      ),
      error = function(e) e
    )
    if (is(contkids, "error")) {
      stop("Error in content (summary) function: ", contkids$message,
        "\n\toccured at path: ",
        spl_context_to_disp_path(spl_context),
        call. = FALSE
      )
    }
  } else {
    contkids <- list()
  }
  ctab <- ElementaryTable(
    kids = contkids,
    name = paste0(name, "@content"),
    lev = lvl,
    labelrow = LabelRow(),
    cinfo = cinfo,
    iscontent = TRUE,
    format = format,
    indent_mod = indent_mod,
    na_str = na_str
  )
  ctab
}

## return index in tbl that has best partial match to str
## or NA_integer_ if none do
inv_pmatch <- function(str, tbl) {
  inds <- pmatch(tbl, str, duplicates.ok = TRUE)
  found_inds <- which(!is.na(inds))
  ret <- NA_integer_
  if (length(found_inds) == 1) {
    ret <- found_inds
  } else if (length(found_inds) > 1) {
    ncs <- nchar(tbl[found_inds])
    chosen <- which.max(ncs)
    ret <- found_inds[chosen]
  }
  ret
}

.got_noname_single <- function(lst) {
  is.list(lst) && length(lst) == 1 && is.null(names(lst))
}
.apply_default_formats <- function(kidlst, fmtlst, nastrlst = character()) {
  if (length(fmtlst) == 0 && length(nastrlst) == 0) {
    return(kidlst)
  }

  if (is.null(names(kidlst))) {
    names(kidlst) <- vapply(kidlst, obj_name, "")
  }

  if (identical(nastrlst, character())) {
    nastrlst <- NA_character_
  }

  if (is.character(nastrlst) && length(nastrlst) >= 1) {
    missing_nastr_val <- nastrlst
    nastrlst <- list()
  } else if (.got_noname_single(nastrlst)) {
    missing_nastr_val <- nastrlst[[1]]
    natsrlst <- list()
  } else {
    missing_nastr_val <- NA_character_
  }

  if (!is.list(fmtlst)) { ## appears impossible??
    missing_fmt_val <- fmtlst
    fmtlst <- list()
  } else if (.got_noname_single(fmtlst)) {
    stopifnot(is(fmtlst[[1]], "FormatSpec"))
    missing_fmt_val <- fmtlst[[1]]
    fmtlst <- list()
  } else {
    missing_fmt_val <- NULL
  }

  if (length(names(fmtlst)) > 0 || length(names(nastrlst)) > 0) {
    missing_nastrs <- setdiff(names(fmtlst), names(nastrlst))
    missing_fmts <- setdiff(names(nastrlst), names(fmtlst))
  } else {
    missing_nastrs <- names(kidlst)
    missing_fmts <- names(kidlst)
  }

  if (length(missing_nastrs) > 0) {
    nastrlst[missing_nastrs] <- missing_nastr_val
  }
  if (length(missing_fmts) > 0) {
    fmtlst[missing_fmts] <- list(missing_fmt_val)
  }

  ## they may be in different orders, if so fix it
  stopifnot(intersect(names(fmtlst), names(nastrlst)) == names(fmtlst))
  nastrlst <- nastrlst[names(fmtlst)]

  ## checks for exact matches first then (inverse) partial matches
  fmt_match <- match(names(kidlst), names(fmtlst))
  no_exact_inds <- which(is.na(fmt_match))
  fmt_match[no_exact_inds] <- vapply(
    names(kidlst)[no_exact_inds],
    inv_pmatch,
    tbl = names(fmtlst),
    1L
  )

  toset <- which(!is.na(fmt_match))

  fmts <- fmtlst[fmt_match[toset]]
  na_strs <- nastrlst[names(fmts)]

  kidlst[toset] <- mapply(function(kid, fmt, na_str) {
    if (fmt_can_inherit(kid)) {
      kid <- set_format_recursive(kid, fmt, na_str, override = FALSE)
    }
    kid
  }, kid = kidlst[toset], fmt = fmts, na_str = na_strs, SIMPLIFY = FALSE)

  kidlst
}


.make_analyzed_tab <- function(df,
                               alt_df,
                               alt_df_full,
                               spl,
                               cinfo,
                               partlabel = "",
                               dolab = TRUE,
                               lvl,
                               baselines,
                               spl_context) {
  stopifnot(is(spl, "VAnalyzeSplit"))
  check_validsplit(spl, df)
  defrlabel <- spl@default_rowlabel
  if (nchar(defrlabel) == 0 && !missing(partlabel) && nchar(partlabel) > 0) {
    defrlabel <- partlabel
  }

  fmt <- obj_format(spl)
  have_fmt_lst <- FALSE
  if (is(fmt, "FormatList")) {
    ## list for diff vars but each has one format case
    if (length(fmt) == 1 && is.null(names(fmt))) {
      fmt <- unlist(fmt)
      stopifnot(is(fmt, "FormatSpec"))
    } else { ## real format list case
      fmt <- NULL
      have_fmt_lst <- TRUE
    }
  }

  kids <- tryCatch(
    .make_tablerows(df,
      func = analysis_fun(spl),
      defrowlabs = defrlabel, # XXX
      cinfo = cinfo,
      datcol = spl_payload(spl),
      lev = lvl + 1L,
      format = fmt, # obj_format(spl),
      splextra = split_exargs(spl),
      baselines = baselines,
      alt_dfpart = alt_df,
      alt_df_full = alt_df_full,
      inclNAs = avar_inclNAs(spl),
      spl_context = spl_context
    ),
    error = function(e) e
  )

  # Adding section_div for DataRows (analyze leaves)
  # kids <- .set_kids_section_div(kids, spl_section_div(spl), "DataRow")

  if (is(kids, "error")) {
    stop("Error applying analysis function (var - ",
      spl_payload(spl) %||% "colvars", "): ", kids$message,
      "\n\toccured at (row) path: ",
      spl_context_to_disp_path(spl_context),
      call. = FALSE
    )
  }

  fmtlist <- NULL
  if (!is.null(spl_formats_var(spl))) {
    if (is.null(spl_na_strs_var(spl))) {
      na_strs <- character() ## case handled in .apply_default_formats
    } else {
      na_strs <- df[[spl_na_strs_var(spl)]][[1]]
    }
    fmtlist <- df[[spl_formats_var(spl)]][[1]]
  } else if (have_fmt_lst) {
    fmtlist <- obj_format(spl)
    na_strs <- obj_na_str(spl)
    if (is.character(na_strs)) {
      na_strs <- lapply(fmtlist, function(nm) na_strs)
      names(na_strs) <- names(fmtlist)
    }
  }

  if (!is.null(fmtlist)) {
    kids <- .apply_default_formats(
      kids,
      fmtlist,
      na_strs
    )
  }

  lab <- obj_label(spl)
  if (is.character(obj_na_str(spl))) {
    final_na_str <- obj_na_str(spl)
  } else {
    final_na_str <- NA_character_
  }
  ret <- TableTree(
    kids = kids,
    name = obj_name(spl),
    label = lab,
    lev = lvl,
    cinfo = cinfo,
    format = if (is.null(fmtlist)) obj_format(spl) else NULL,
    na_str = final_na_str,
    indent_mod = indent_mod(spl),
    trailing_section_div = spl_section_div(spl)
  )

  labelrow_visible(ret) <- dolab
  ret
}

#' @param ... all arguments to `recurse_applysplit`, methods may only use some of them.
#' @return A `list` of children to place at this level.
#'
#' @noRd
setGeneric(".make_split_kids", function(spl, have_controws, make_lrow, ...) {
  standardGeneric(".make_split_kids")
})

## single AnalyzeSplit
setMethod(
  ".make_split_kids", "VAnalyzeSplit",
  function(spl,
           have_controws, ## unused here
           make_lrow, ## unused here
           ...,
           df,
           alt_df,
           alt_df_full,
           lvl,
           name,
           cinfo,
           baselines,
           spl_context,
           nsibs = 0) {
    spvis <- labelrow_visible(spl)
    if (is.na(spvis)) {
      spvis <- nsibs > 0
    }

    ret <- .make_analyzed_tab(
      df = df,
      alt_df,
      alt_df_full = alt_df_full,
      spl = spl,
      cinfo = cinfo,
      lvl = lvl + 1L,
      dolab = spvis,
      partlabel = obj_label(spl),
      baselines = baselines,
      spl_context = spl_context
    )
    indent_mod(ret) <- indent_mod(spl)

    kids <- list(ret)
    names(kids) <- obj_name(ret)
    kids
  }
)

# Adding section_divisors to TableRow
.set_kids_section_div <- function(lst, trailing_section_div_char, allowed_class = "VTableTree") {
  if (!is.na(trailing_section_div_char)) {
    lst <- lapply(
      lst,
      function(k) {
        if (is(k, allowed_class)) {
          trailing_section_div(k) <- trailing_section_div_char
        }
        k
      }
    )
  }
  lst
}

## 1 or more AnalyzeSplits
setMethod(
  ".make_split_kids", "AnalyzeMultiVars",
  function(spl,
           have_controws,
           make_lrow, ## used here
           spl_context,
           ...) { ## all passed directly down to VAnalyzeSplit method
    avspls <- spl_payload(spl)

    nspl <- length(avspls)

    kids <- unlist(lapply(avspls,
      .make_split_kids,
      nsibs = nspl - 1,
      have_controws = have_controws,
      make_lrow = make_lrow,
      spl_context = spl_context,
      ...
    ))

    kids <- .set_kids_section_div(kids, spl_section_div(spl), "VTableTree")

    ## XXX this seems like it should be identical not !identical
    ## TODO FIXME
    if (!identical(make_lrow, FALSE) && !have_controws && length(kids) == 1) {
      ## we only analyzed one var so
      ## we don't need an extra wrapper table
      ## in the structure
      stopifnot(identical(
        obj_name(kids[[1]]),
        spl_payload(spl)
      ))
      return(kids[[1]])
    }
    ## this will be the variables
    ## nms = sapply(spl_payload(spl), spl_payload)

    nms <- vapply(kids, obj_name, "")
    labs <- vapply(kids, obj_label, "")
    if (length(unique(nms)) != length(nms) && length(unique(nms)) != length(nms)) {
      warning("Non-unique sibling analysis table names. Using Labels ",
        "instead. Use the table_names argument to analyze to avoid ",
        "this when analyzing the same variable multiple times.",
        "\n\toccured at (row) path: ",
        spl_context_to_disp_path(spl_context),
        call. = FALSE
      )
      kids <- mapply(function(k, nm) {
        obj_name(k) <- nm
        k
      }, k = kids, nm = labs, SIMPLIFY = FALSE)
      nms <- labs
    }

    nms[is.na(nms)] <- ""

    names(kids) <- nms
    kids
  }
)

setMethod(
  ".make_split_kids", "SplitVectorTree",
  function(spl,
           have_controws,
           make_lrow,
           ...,
           splvec, ## passed to recursive_applysplit
           df, ## used to apply split
           alt_df, ## used to apply split for alternative df
           alt_df_full, ## passed to recursive_applysplit
           lvl, ## used to calculate innerlev
           cinfo, ## used for sanity check
           baselines, ## used to calc new baselines
           spl_context) {
   ret <- lapply(
    spl,
    function(splvecii) {
      recursive_applysplit(
        df = df,
        lvl = lvl + 1L,
        alt_df = alt_df,
        alt_df_full = alt_df_full,
        splvec = splvecii,
        name = obj_name(unlist(splvecii, recursive = TRUE)[[1]]), ## XXX I think this is wrong
        make_lrow = make_lrow,
        cinfo = cinfo,
        baselines = baselines,
        spl_context = spl_context,
        no_outer_tbl = TRUE # XXX is this always right? I think so
      )
      
  })
  ret
})

setMethod(
  ".make_split_kids", "Split",
  function(spl,
           have_controws,
           make_lrow,
           ...,
           splvec, ## passed to recursive_applysplit
           df, ## used to apply split
           alt_df, ## used to apply split for alternative df
           alt_df_full, ## passed to recursive_applysplit
           lvl, ## used to calculate innerlev
           cinfo, ## used for sanity check
           baselines, ## used to calc new baselines
           spl_context) {
    ## do the core splitting of data into children for this split
    rawpart <- do_split(spl, df, spl_context = spl_context)
    dataspl <- rawpart[["datasplit"]]
    ## these are SplitValue objects
    splvals <- rawpart[["values"]]
    partlabels <- rawpart[["labels"]]
    if (is.factor(partlabels)) {
      partlabels <- as.character(partlabels)
    }
    nms <- unlist(value_names(splvals))
    if (is.factor(nms)) {
      nms <- as.character(nms)
    }

    ## Get new baseline values
    ##
    ## XXX this is a lot of data churn, if it proves too slow
    ## we can
    ## a) check if any of the analyses (i.e. the afuns) need the baseline in this
    ##    splitvec and not do any of this if not, or
    ## b) refactor row splitting to behave like column splitting
    ##
    ## (b) seems the better design but is a major reworking of the guts of how
    ## rtables tabulation works
    ## (a) will only help if analyses that use baseline
    ## info are mixed with those who don't.
    newbl_raw <- lapply(baselines, function(dat) {
      # If no ref_group is specified
      if (is.null(dat)) {
        return(NULL)
      }

      ## apply the same splitting on the
      bldataspl <- tryCatch(do_split(spl, dat, spl_context = spl_context)[["datasplit"]],
        error = function(e) e
      )

      # Error localization
      if (is(bldataspl, "error")) {
        stop("Following error encountered in splitting .ref_group (baselines): ",
          bldataspl$message,
          call. = FALSE
        )
      }

      ## we only keep the ones corresponding with actual data splits
      res <- lapply(
        names(dataspl),
        function(nm) {
          if (nm %in% names(bldataspl)) {
            bldataspl[[nm]]
          } else {
            dataspl[[1]][0, ]
          }
        }
      )

      names(res) <- names(dataspl)
      res
    })

    newbaselines <- lapply(names(dataspl), function(nm) {
      lapply(newbl_raw, function(rawdat) {
        if (nm %in% names(rawdat)) {
          rawdat[[nm]]
        } else {
          rawdat[[1]][0, ]
        }
      })
    })

    if (length(newbaselines) != length(dataspl)) {
      stop(
        "Baselines (ref_group) after row split does not have",
        " the same number of levels of input data split. ",
        "Contact the maintainer."
      ) # nocov
    }
    if (!(length(newbaselines) == 0 ||
      identical(
        unique(sapply(newbaselines, length)),
        length(col_exprs(cinfo))
      ))) {
      stop(
        "Baselines (ref_group) do not have the same number of columns",
        " in each split. Contact the maintainer."
      ) # nocov
    }

    # If params are not present do not do the calculation
    acdf_param <- check_afun_cfun_params(
      SplitVector(spl, splvec),
      c(".alt_df", ".alt_df_row")
    )

    # Apply same split for alt_counts_df
    if (!is.null(alt_df) && any(acdf_param)) {
      alt_dfpart <- tryCatch(
        do_split(spl, alt_df,
          spl_context = spl_context
        )[["datasplit"]],
        error = function(e) e
      )

      # Removing NA rows - to explore why this happens at all in a split
      # This would be a fix but it is done in post-processing instead of pre-proc -> xxx
      # x alt_dfpart <- lapply(alt_dfpart, function(data) {
      # x    data[!apply(is.na(data), 1, all), ]
      # x })

      # Error localization
      if (is(alt_dfpart, "error")) {
        stop("Following error encountered in splitting alt_counts_df: ",
          alt_dfpart$message,
          call. = FALSE
        )
      }
      # Error if split does not have the same values in the alt_df (and order)
      # The following breaks if there are different levels (do_split returns empty list)
      # or if there are different number of the same levels. Added handling of NAs
      # in the values of the factor when is all only NAs
      is_all_na <- all(is.na(alt_df[[spl_payload(spl)]]))

      if (!all(names(dataspl) %in% names(alt_dfpart)) || length(alt_dfpart) != length(dataspl) || is_all_na) {
        alt_df_spl_vals <- unique(alt_df[[spl_payload(spl)]])
        end_part <- ""

        if (!all(alt_df_spl_vals %in% levels(alt_df_spl_vals))) {
          end_part <- paste0(
            " and following levels: ",
            paste_vec(levels(alt_df_spl_vals))
          )
        }

        if (is_all_na) {
          end_part <- ". Found only NAs in alt_counts_df split"
        }

        stop(
          "alt_counts_df split variable(s) [", spl_payload(spl),
          "] (in split ", as.character(class(spl)),
          ") does not have the same factor levels of df.\ndf has c(", '"',
          paste(names(dataspl), collapse = '", "'), '"', ") levels while alt_counts_df has ",
          ifelse(length(alt_df_spl_vals) > 0, paste_vec(alt_df_spl_vals), ""),
          " unique values", end_part
        )
      }
    } else {
      alt_dfpart <- setNames(rep(list(NULL), length(dataspl)), names(dataspl))
    }


    innerlev <- lvl + (have_controws || is.na(make_lrow) || make_lrow)
    ## do full recursive_applysplit on each part of the split defined by spl
    inner <- unlist(mapply(
      function(dfpart, alt_dfpart, nm, label, baselines, splval) {
        rsplval <- context_df_row(
          split = obj_name(spl),
          value = value_names(splval),
          full_parent_df = list(dfpart),
          cinfo = cinfo
        )

        ## if(length(rsplval) > 0)
        ##     rsplval <- setNames(rsplval, obj_name(spl))
        recursive_applysplit(
          df = dfpart,
          alt_df = alt_dfpart,
          alt_df_full = alt_df_full,
          name = nm,
          lvl = innerlev,
          splvec = splvec,
          cinfo = cinfo,
          make_lrow = label_kids(spl),
          parent_cfun = content_fun(spl),
          cformat = content_format(spl),
          cna_str = content_na_str(spl),
          partlabel = label,
          cindent_mod = content_indent_mod(spl),
          cvar = content_var(spl),
          baselines = baselines,
          cextra_args = content_extra_args(spl),
          ## splval should still be retaining its name
          spl_context = rbind(spl_context, rsplval)
        )
      },
      dfpart = dataspl,
      alt_dfpart = alt_dfpart,
      label = partlabels,
      nm = nms,
      baselines = newbaselines,
      splval = splvals,
      SIMPLIFY = FALSE
    ))

    # Setting the kids section separator if they inherits VTableTree
    inner <- .set_kids_section_div(
      inner,
      trailing_section_div_char = spl_section_div(spl),
      allowed_class = "VTableTree"
    )

    ## This is where we need to build the structural tables
    ## even if they are invisible because their labels are not
    ## not shown.
    innertab <- TableTree(
      kids = inner,
      name = obj_name(spl),
      labelrow = LabelRow(
        label = obj_label(spl),
        vis = isTRUE(vis_label(spl))
      ),
      cinfo = cinfo,
      iscontent = FALSE,
      indent_mod = indent_mod(spl),
      page_title = ptitle_prefix(spl)
    )
    ## kids = inner
    kids <- list(innertab)
    kids
  }
)

context_df_row <- function(split = character(),
                           value = character(),
                           full_parent_df = list(),
                           cinfo = NULL) {
  ret <- data.frame(
    split = split,
    value = value,
    full_parent_df = I(full_parent_df),
    #     parent_cold_inds = I(parent_col_inds),
    stringsAsFactors = FALSE
  )
  if (nrow(ret) > 0) {
    ret$all_cols_n <- nrow(full_parent_df[[1]])
  } else {
    ret$all_cols_n <- integer() ## should this be numeric??? This never happens
  }

  if (!is.null(cinfo)) {
    if (nrow(ret) > 0) {
      colcols <- as.data.frame(lapply(col_exprs(cinfo), function(e) {
        vals <- eval(e, envir = full_parent_df[[1]])
        if (identical(vals, TRUE)) {
          vals <- rep(vals, length.out = nrow(full_parent_df[[1]]))
        }
        I(list(vals))
      }))
    } else {
      colcols <- as.data.frame(rep(list(logical()), ncol(cinfo)))
    }
    names(colcols) <- names(col_exprs(cinfo))
    ret <- cbind(ret, colcols)
  }
  ret
}

recursive_applysplit <- function(df,
                                 lvl = 0L,
                                 alt_df,
                                 alt_df_full,
                                 splvec,
                                 name,
                                 #         label,
                                 make_lrow = NA,
                                 partlabel = "",
                                 cinfo,
                                 parent_cfun = NULL,
                                 cformat = NULL,
                                 cna_str = NA_character_,
                                 cindent_mod = 0L,
                                 cextra_args = list(),
                                 cvar = NULL,
                                 baselines = lapply(
                                   col_extra_args(cinfo),
                                   function(x) x$.ref_full
                                 ),
                                 spl_context = context_df_row(cinfo = cinfo),
                                 no_outer_tbl = FALSE,
                                 parent_sect_split = NA_character_) {
  ## pre-existing table was added to the layout
  if (length(splvec) == 1L && is(splvec[[1]], "VTableNodeInfo")) {
    return(splvec[[1]])
  }

  if (is(splvec, "SplitVectorTree")) {
   return(
      unlist(
          lapply(
            seq_along(splvec),
            function(ii) {
              recursive_applysplit(
                  df = df,
                  lvl = lvl,
                  alt_df = alt_df,
                  alt_df_full = alt_df_full,
                  splvec = splvec[[ii]],
                  name = obj_name(unlist(splvec[[ii]])[[1]]),
                  make_lrow = make_lrow,
                  partlabel = partlabel,
                  cinfo = cinfo,
                  parent_cfun = parent_cfun,
                  cformat = cformat,
                  cna_str = cna_str,
                  cindent_mod = cindent_mod,
                  cextra_args = cextra_args,
                  cvar = cvar,
                  baselines = baselines,
                  spl_context = spl_context,
                  no_outer_tbl = TRUE, ## XXX is this always right???? no_outer_tbl,
                  parent_sect_split = parent_sect_split)
          }
          )
      )
    )
  }

  ## the content function is the one from the PREVIOUS
  ## split, i.e. the one whose children we are now constructing
  ## this is a bit annoying but makes the semantics for
  ## declaring layouts much more sane.
  ctab <- .make_ctab(df,
    lvl = lvl,
    name = name,
    label = partlabel,
    cinfo = cinfo,
    parent_cfun = parent_cfun,
    format = cformat,
    na_str = cna_str,
    indent_mod = cindent_mod,
    cvar = cvar,
    alt_df = alt_df,
    alt_df_full = alt_df_full,
    extra_args = cextra_args,
    spl_context = spl_context
  )

  nonroot <- lvl != 0L

  if (is.na(make_lrow)) {
    make_lrow <- if (nrow(ctab) > 0 || !nzchar(partlabel)) FALSE else TRUE
  }
  ## never print an empty row label for root.
  if (make_lrow && partlabel == "" && !nonroot) {
    make_lrow <- FALSE
  }

  if (length(splvec) == 0L) {
    kids <- list()
    imod <- 0L
    spl <- NULL
  } else {
    spl <- splvec[[1]]
    splvec <- splvec[-1]

    ## we pass this everything recursive_applysplit received and
    ## it all gets passed around through ... as needed
    ## to the various methods of .make_split_kids
    kids <- .make_split_kids(
      spl = spl,
      df = df,
      alt_df = alt_df,
      alt_df_full = alt_df_full,
      lvl = lvl,
      splvec = splvec,
      name = name,
      make_lrow = make_lrow,
      partlabel = partlabel,
      cinfo = cinfo,
      parent_cfun = parent_cfun,
      cformat = cformat,
      cindent_mod = cindent_mod,
      cextra_args = cextra_args, cvar = cvar,
      baselines = baselines,
      spl_context = spl_context,
      have_controws = nrow(ctab) > 0
    )
    imod <- 0L
  } ## end length(splvec)

  if (is.na(make_lrow)) {
    make_lrow <- if (nrow(ctab) > 0 || !nzchar(partlabel)) FALSE else TRUE
  }
  ## never print an empty row label for root.
  if (make_lrow && partlabel == "" && !nonroot) {
    make_lrow <- FALSE
  }

  ## this is only true when called from build_table and the first split
  ## in (one of the) SplitVector is NOT an AnalyzeMultiVars split.
  ## in that case we would be "double creating" the structural
  ## subtable
  if (no_outer_tbl) {
    ret <- kids[[1]]
    indent_mod(ret) <- indent_mod(spl)
  } else if (nrow(ctab) > 0L || length(kids) > 0L) {
    ## previously we checked if the child had an identical label
    ## but I don't think thats needed anymore.
    tlabel <- partlabel
    ret <- TableTree(
      cont = ctab,
      kids = kids,
      name = name,
      label = tlabel, # partlabel,
      lev = lvl,
      iscontent = FALSE,
      labelrow = LabelRow(
        lev = lvl,
        label = tlabel,
        cinfo = cinfo,
        vis = make_lrow
      ),
      cinfo = cinfo,
      indent_mod = imod
    )
  } else {
    ret <- NULL
  }

  ## if(!is.null(spl) && !is.na(spl_section_sep(spl)))
  ##     ret <- apply_kids_section_sep(ret, spl_section_sep(spl))
  ## ## message(sprintf("indent modifier: %d", indentmod))
  ## if(!is.null(ret))
  ##     indent_mod(ret) = indentmod
  ret
}

#' Create a table from a layout and data
#'
#' Layouts are used to describe a table pre-data. `build_table` is used to create a table
#' using a layout and a dataset.
#'
#' @inheritParams gen_args
#' @inheritParams lyt_args
#' @param col_counts (`numeric` or `NULL`)\cr `r lifecycle::badge("deprecated")` if non-`NULL`, column counts
#'   *for leaf-columns only* which override those calculated automatically during tabulation. Must specify
#'   "counts" for *all* leaf-columns if non-`NULL`. `NA` elements will be replaced with the automatically
#'   calculated counts. Turns on display of leaf-column counts when non-`NULL`.
#' @param col_total (`integer(1)`)\cr the total observations across all columns. Defaults to `nrow(df)`.
#' @param ... ignored.
#'
#' @details
#' When `alt_counts_df` is specified, column counts are calculated by applying the exact column subsetting
#' expressions determined when applying column splitting to the main data (`df`) to `alt_counts_df` and
#' counting the observations in each resulting subset.
#'
#' In particular, this means that in the case of splitting based on cuts of the data, any dynamic cuts will have
#' been calculated based on `df` and simply re-used for the count calculation.
#'
#' @note
#' When overriding the column counts or totals care must be taken that, e.g., `length()` or `nrow()` are not called
#' within tabulation functions, because those will NOT give the overridden counts. Writing/using tabulation
#' functions which accept `.N_col` and `.N_total` or do not rely on column counts at all (even implicitly) is the
#' only way to ensure overridden counts are fully respected.
#'
#' @return A `TableTree` or `ElementaryTable` object representing the table created by performing the tabulations
#'   declared in `lyt` to the data `df`.
#'
#' @examples
#' lyt <- basic_table() |>
#'   split_cols_by("Species") |>
#'   analyze("Sepal.Length", afun = function(x) {
#'     list(
#'       "mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
#'       "range" = diff(range(x))
#'     )
#'   })
#' lyt
#'
#' tbl <- build_table(lyt, iris)
#' tbl
#'
#' # analyze multiple variables
#' lyt2 <- basic_table() |>
#'   split_cols_by("Species") |>
#'   analyze(c("Sepal.Length", "Petal.Width"), afun = function(x) {
#'     list(
#'       "mean (sd)" = rcell(c(mean(x), sd(x)), format = "xx.xx (xx.xx)"),
#'       "range" = diff(range(x))
#'     )
#'   })
#'
#' tbl2 <- build_table(lyt2, iris)
#' tbl2
#'
#' # an example more relevant for clinical trials with column counts
#' lyt3 <- basic_table(show_colcounts = TRUE) |>
#'   split_cols_by("ARM") |>
#'   analyze("AGE", afun = function(x) {
#'     setNames(as.list(fivenum(x)), c(
#'       "minimum", "lower-hinge", "median",
#'       "upper-hinge", "maximum"
#'     ))
#'   })
#'
#' tbl3 <- build_table(lyt3, DM)
#' tbl3
#'
#' tbl4 <- build_table(lyt3, subset(DM, AGE > 40))
#' tbl4
#'
#' # with column counts calculated based on different data
#' miniDM <- DM[sample(1:NROW(DM), 100), ]
#' tbl5 <- build_table(lyt3, DM, alt_counts_df = miniDM)
#' tbl5
#'
#' tbl6 <- build_table(lyt3, DM, col_counts = 1:3)
#' tbl6
#'
#' @author Gabriel Becker
#' @export
build_table <- function(lyt, df,
                        alt_counts_df = NULL,
                        col_counts = NULL,
                        col_total = if (is.null(alt_counts_df)) nrow(df) else nrow(alt_counts_df),
                        topleft = NULL,
                        hsep = default_hsep(),
                        round_type = if (is(lyt, "PreDataTableLayouts")) obj_round_type(lyt) else valid_round_type,
                        ...) {
  if (!is(lyt, "PreDataTableLayouts")) {
    stop(
      "lyt must be a PreDataTableLayouts object. Got object of class ",
      class(lyt)
    )
  }

  ## if no columns are defined (e.g. because lyt is NULL)
  ## add a single overall column as the "most basic"
  ## table column structure that makes sense
  clyt <- clayout(lyt)
  if (length(clyt) == 1 && length(clyt[[1]]) == 0) {
    clyt[[1]] <- add_overall_col(clyt[[1]], "")
    clayout(lyt) <- clyt
  }

  ## do checks and defensive programming now that we have the data
  lyt <- fix_dyncuts(lyt, df)
  lyt <- set_def_child_ord(lyt, df)
  lyt <- fix_analyze_vis(lyt)
  df <- fix_split_vars(lyt, df, char_ok = is.null(col_counts))
  alt_params <- check_afun_cfun_params(lyt, c(".alt_df", ".alt_df_row"))
  if (any(alt_params) && is.null(alt_counts_df)) {
    stop(
      "Layout contains afun/cfun functions that have optional parameters ",
      ".alt_df and/or .alt_df_row, but no alt_counts_df was provided in ",
      "build_table()."
    )
  }

  rtpos <- TreePos()
  cinfo <- create_colinfo(lyt, df, rtpos,
    counts = col_counts,
    alt_counts_df = alt_counts_df,
    total = col_total,
    topleft
  )
  if (!is.null(col_counts)) {
    toreplace <- !is.na(col_counts)
    newccs <- col_counts(cinfo) ## old actual counts
    newccs[toreplace] <- col_counts[toreplace]
    col_counts(cinfo) <- newccs
    leaf_paths <- col_paths(cinfo)
    for (pth in leaf_paths) {
      colcount_visible(cinfo, pth) <- TRUE
    }
  }
  rlyt <- rlayout(lyt)
  rtspl <- root_spl(rlyt)
  ctab <- .make_ctab(df, 0L,
    alt_df = NULL,
    alt_df_full = alt_counts_df,
    name = "root",
    label = "",
    cinfo = cinfo, ## cexprs, ctree,
    parent_cfun = content_fun(rtspl),
    format = content_format(rtspl),
    na_str = content_na_str(rtspl),
    indent_mod = 0L,
    cvar = content_var(rtspl),
    extra_args = content_extra_args(rtspl)
  )

  kids <- lapply(seq_along(rlyt), function(i) {
    splvec <- rlyt[[i]]
    if (length(splvec) == 0) {
      return(NULL)
    }
    firstspl <- unlist(splvec, recursive = TRUE)[[1]] ## could be a SplitVecTree now...
    nm <- obj_name(firstspl)
    ## XXX unused, probably shouldn't be?
    ## this seems to be covered by grabbing the partlabel
    ## TODO confirm this
    ## lab <- obj_label(firstspl)
    recursive_applysplit(
      df = df, lvl = 0L,
      alt_df = alt_counts_df,
      alt_df_full = alt_counts_df,
      name = nm,
      splvec = splvec,
      cinfo = cinfo,
      ## XXX are these ALWAYS right?
      make_lrow = label_kids(firstspl),
      parent_cfun = NULL,
      cformat = content_format(firstspl),
      cna_str = content_na_str(firstspl),
      cvar = content_var(firstspl),
      cextra_args = content_extra_args(firstspl),
      spl_context = context_df_row(
        split = "root", value = "root",
        full_parent_df = list(df),
        cinfo = cinfo
      ),
      ## we DO want the 'outer table' if the first
      ## one is a multi-analyze
      no_outer_tbl = !is(firstspl, "AnalyzeMultiVars")
    )
  })
  ##kids <- kids[!sapply(kids, is.null)]
  kids <- unlist(kids, recursive = TRUE)
  if (length(kids) > 0) names(kids) <- sapply(kids, obj_name)

  # top level divisor
  if (!is.na(top_level_section_div(lyt))) {
    kids <- lapply(kids, function(first_level_kids) {
      trailing_section_div(first_level_kids) <- top_level_section_div(lyt)
      first_level_kids
    })
  }

  if (nrow(ctab) == 0L && length(kids) == 1L && is(kids[[1]], "VTableTree")) {
    tab <- kids[[1]]
    main_title(tab) <- main_title(lyt)
    subtitles(tab) <- subtitles(lyt)
    main_footer(tab) <- main_footer(lyt)
    prov_footer(tab) <- prov_footer(lyt)
    header_section_div(tab) <- header_section_div(lyt)
    obj_round_type(tab) <- round_type
  } else {
    tab <- TableTree(
      cont = ctab,
      kids = kids,
      lev = 0L,
      name = "root",
      label = "",
      iscontent = FALSE,
      cinfo = cinfo,
      format = obj_format(rtspl),
      na_str = obj_na_str(rtspl),
      title = main_title(lyt),
      subtitles = subtitles(lyt),
      main_footer = main_footer(lyt),
      prov_footer = prov_footer(lyt),
      header_section_div = header_section_div(lyt),
      round_type = round_type
    )
  }

  ## This seems to be unneeded, not clear what 'top_left' check it refers to
  ## but both top_left taller than column headers and very long topleft are now
  ## allowed, so this is just wasted computation.

  ## ## this is where the top_left check lives right now. refactor later maybe
  ## ## but now just call it so the error gets thrown when I want it to
  ## unused <- matrix_form(tab)
  tab <- update_ref_indexing(tab)
  horizontal_sep(tab) <- hsep
  if (table_inset(lyt) > 0) {
    table_inset(tab) <- table_inset(lyt)
  }
  tab
}

# fix_split_vars ----
# These checks guarantee that all the split variables are present in the data.
# No generic is needed because it is not dependent on the input layout but
# on the df.
fix_one_split_var <- function(spl, df, char_ok = TRUE) {
  var <- spl_payload(spl)
  if (!(var %in% names(df))) {
    stop("Split variable [", var, "] not found in data being tabulated.")
  }
  varvec <- df[[var]]
  if (!is(varvec, "character") && !is.factor(varvec)) {
    message(sprintf(
      paste(
        "Split var [%s] was not character or factor.",
        "Converting to factor"
      ),
      var
    ))
    varvec <- factor(varvec)
    df[[var]] <- varvec
  } else if (is(varvec, "character") && !char_ok) {
    stop(
      "Overriding column counts is not supported when splitting on ",
      "character variables.\n Please convert all column split variables to ",
      "factors."
    )
  }

  if (is.factor(varvec)) {
    levs <- levels(varvec)
  } else {
    levs <- unique(varvec)
  }
  if (!all(nzchar(levs))) {
    stop(
      "Got empty string level in splitting variable ", var,
      " This is not supported.\nIf display as an empty level is ",
      "desired use a value-labeling variable."
    )
  }

  ## handle label var
  lblvar <- spl_label_var(spl)
  have_lblvar <- !identical(var, lblvar)
  if (have_lblvar) {
    if (!(lblvar %in% names(df))) {
      stop(
        "Value label variable [", lblvar,
        "] not found in data being tabulated."
      )
    }
    lblvec <- df[[lblvar]]
    tab <- table(varvec, lblvec)

    if (any(rowSums(tab > 0) > 1) || any(colSums(tab > 0) > 1)) {
      stop(sprintf(
        paste(
          "There does not appear to be a 1-1",
          "correspondence between values in split var",
          "[%s] and label var [%s]"
        ),
        var, lblvar
      ))
    }

    if (!is(lblvec, "character") && !is.factor(lblvec)) {
      message(sprintf(
        paste(
          "Split label var [%s] was not character or",
          "factor. Converting to factor"
        ),
        var
      ))
      lblvec <- factor(lblvec)
      df[[lblvar]] <- lblvec
    }
  }

  df
}

fix_split_vars <- function(lyt, df, char_ok) {
  df <- fix_split_vars_inner(clayout(lyt), df, char_ok = char_ok)
  df <- fix_split_vars_inner(rlayout(lyt), df, char_ok = TRUE)
  df

  ## clyt <- clayout(lyt)
  ## rlyt <- rlayout(lyt)

  ## allspls <- unlist(list(clyt, rlyt))
  ## VarLevelSplit includes sublclass VarLevWBaselineSplit
}

fix_split_vars_inner <- function(lyt, df, char_ok) {
  stopifnot(is(lyt, "PreDataAxisLayout"))
  allspls <- unlist(lyt)
  varspls <- allspls[sapply(allspls, is, "VarLevelSplit")]
  unqvarinds <- !duplicated(sapply(varspls, spl_payload))
  unqvarspls <- varspls[unqvarinds]
  for (spl in unqvarspls) df <- fix_one_split_var(spl, df, char_ok = char_ok)

  df
}

# set_def_child_ord ----
## the table is built by recursively splitting the data and doing things to each
## piece. The order (or even values) of unique(df[[col]]) is not guaranteed to
## be the same in all the different partitions. This addresses that.
setGeneric(
  "set_def_child_ord",
  function(lyt, df) standardGeneric("set_def_child_ord")
)

setMethod(
  "set_def_child_ord", "PreDataTableLayouts",
  function(lyt, df) {
    clayout(lyt) <- set_def_child_ord(clayout(lyt), df)
    rlayout(lyt) <- set_def_child_ord(rlayout(lyt), df)
    lyt
  }
)

setMethod(
  "set_def_child_ord", "PreDataAxisLayout",
  function(lyt, df) {
    lyt@.Data <- lapply(lyt, set_def_child_ord, df = df)
    lyt
  }
)

setMethod(
  "set_def_child_ord", "SplitVector",
  function(lyt, df) {
    lyt[] <- lapply(lyt, set_def_child_ord, df = df)
    lyt
  }
)

setMethod(
  "set_def_child_ord", "SplitVectorTree",
  function(lyt, df) {
    lyt[] <- lapply(lyt, set_def_child_ord, df = df)
    lyt
  }
)
    

## for most split types, don't do anything
## becuause their ordering already isn't data-based
setMethod(
  "set_def_child_ord", "ANY",
  function(lyt, df) lyt
)

setMethod(
  "set_def_child_ord", "VarLevelSplit",
  function(lyt, df) {
    if (!is.null(spl_child_order(lyt))) {
      return(lyt)
    }

    vec <- df[[spl_payload(lyt)]]
    vals <- if (is.factor(vec)) {
      levels(vec)
    } else {
      unique(vec)
    }
    spl_child_order(lyt) <- vals
    lyt
  }
)

setMethod(
  "set_def_child_ord", "VarLevWBaselineSplit",
  function(lyt, df) {
    bline <- spl_ref_group(lyt)
    if (!is.null(spl_child_order(lyt)) && match(bline, spl_child_order(lyt), nomatch = -1) == 1L) {
      return(lyt)
    }

    if (!is.null(split_fun(lyt))) {
      ## expensive but sadly necessary, I think
      pinfo <- do_split(lyt, df, spl_context = context_df_row())
      vals <- sort(unlist(value_names(pinfo$values)))
    } else {
      vec <- df[[spl_payload(lyt)]]
      vals <- if (is.factor(vec)) {
        levels(vec)
      } else {
        unique(vec)
      }
    }
    if (!bline %in% vals) {
      stop(paste0(
        'Reference group "', bline, '"', " was not present in the levels of ", spl_payload(lyt), " in the data."
      ))
    }
    spl_child_order(lyt) <- vals
    lyt
  }
)

splitvec_to_coltree <- function(df, splvec, pos = NULL,
                                lvl = 1L, label = "",
                                spl_context = context_df_row(cinfo = NULL),
                                alt_counts_df = df,
                                global_cc_format) {
  stopifnot(
    lvl <= length(splvec) + 1L,
    is(splvec, "SplitVector")
  )


  if (lvl == length(splvec) + 1L) {
    ## XXX this should be a LayoutColree I Think.
    nm <- unlist(tail(value_names(pos), 1)) %||% ""
    spl <- tail(pos_splits(pos), 1)[[1]]
    fmt <- colcount_format(spl) %||% global_cc_format
    LayoutColLeaf(
      lev = lvl - 1L,
      label = label,
      tpos = pos,
      name = nm,
      colcount = NROW(alt_counts_df),
      disp_ccounts = disp_ccounts(spl),
      colcount_format = fmt
    )
  } else {
    spl <- splvec[[lvl]]
    nm <- if (is.null(pos) || length(pos_splits(pos)) == 0) {
      obj_name(spl)
    } else {
      unlist(tail(
        value_names(pos),
        1
      ))
    }
    rawpart <- do_split(spl, df,
      trim = FALSE,
      spl_context = spl_context
    )
    datparts <- rawpart[["datasplit"]]
    vals <- rawpart[["values"]]
    labs <- rawpart[["labels"]]

    force(alt_counts_df)
    kids <- mapply(
      function(dfpart, value, partlab) {
        ## we could pass subset expression in here but the spec
        ## currently doesn't call for it in column space
        newprev <- context_df_row(
          split = obj_name(spl),
          value = value_names(value),
          full_parent_df = list(dfpart),
          cinfo = NULL
        )
        ## subset expressions handled inside make_child_pos,
        ## value is (optionally, for the moment) carrying it around
        newpos <- make_child_pos(pos, spl, value, partlab)
        acdf_subset_expr <- make_subset_expr(spl, value)
        new_acdf_subset <- try(eval(acdf_subset_expr, alt_counts_df), silent = TRUE)
        if (is(new_acdf_subset, "try-error")) {
          stop(sprintf(
            paste(
              ifelse(identical(df, alt_counts_df), "df", "alt_counts_df"),
              "appears incompatible with column-split",
              "structure. Offending column subset",
              "expression: %s\nOriginal error",
              "message: %s"
            ), deparse(acdf_subset_expr[[1]]),
            conditionMessage(attr(new_acdf_subset, "condition"))
          ))
        }

        splitvec_to_coltree(dfpart, splvec, newpos,
          lvl + 1L, partlab,
          spl_context = rbind(spl_context, newprev),
          alt_counts_df = alt_counts_df[new_acdf_subset, , drop = FALSE],
          global_cc_format = global_cc_format
        )
      },
      dfpart = datparts, value = vals,
      partlab = labs, SIMPLIFY = FALSE
    )
    disp_cc <- FALSE
    cc_format <- global_cc_format # this doesn't matter probably, but its technically more correct
    if (lvl > 1) {
      disp_cc <- disp_ccounts(splvec[[lvl - 1]])
      cc_format <- colcount_format(splvec[[lvl - 1]]) %||% global_cc_format
    }

    names(kids) <- value_names(vals)
    LayoutColTree(
      lev = lvl, label = label,
      spl = spl,
      kids = kids, tpos = pos,
      name = nm,
      summary_function = content_fun(spl),
      colcount = NROW(alt_counts_df),
      disp_ccounts = disp_cc,
      colcount_format = cc_format
    )
  }
}

# fix_analyze_vis ----
## now that we know for sure the number of siblings
## collaplse NAs to TRUE/FALSE for whether
## labelrows should be visible for ElementaryTables
## generatead from analyzing a single variable
setGeneric("fix_analyze_vis", function(lyt) standardGeneric("fix_analyze_vis"))

setMethod(
  "fix_analyze_vis", "PreDataTableLayouts",
  function(lyt) {
    rlayout(lyt) <- fix_analyze_vis(rlayout(lyt))
    lyt
  }
)

setMethod(
  "fix_analyze_vis", "PreDataRowLayout",
  function(lyt) {
    splvecs <- lapply(lyt, fix_analyze_vis)
    PreDataRowLayout(
      root = root_spl(lyt),
      lst = splvecs
    )
  }
)

setMethod(
  "fix_analyze_vis", "SplitVector",
  function(lyt) {
    len <- length(lyt)
    if (len == 0) {
      return(lyt)
    }
    lastspl <- lyt[[len]]
    if (!(is(lastspl, "VAnalyzeSplit") || is(lastspl, "AnalyzeMultivar"))) {
      return(lyt)
    }

    if (is(lastspl, "VAnalyzeSplit") && is.na(labelrow_visible(lastspl))) {
      ##  labelrow_visible(lastspl) = FALSE
      labelrow_visible(lastspl) <- "hidden"
    } else if (is(lastspl, "AnalyzeMultiVar")) {
      pld <- spl_payload(lastspl)
      newpld <- lapply(pld, function(sp, havesibs) {
        if (is.na(labelrow_visible(sp))) {
          labelrow_visible(sp) <- havesibs
        }
      }, havesibs = len > 1)
      spl_payload(lastspl) <- newpld
      ## pretty sure this isn't needed...
      if (is.na(label_kids(lastspl))) {
        label_kids(lastspl) <- len > 1
      }
    }
    lyt[[len]] <- lastspl
    lyt
  }
)

setMethod(
  "fix_analyze_vis", "SplitVectorTree",
  function(lyt) {
    stopifnot(length(lyt) > 0)
    lst <- lapply(lyt, fix_analyze_vis)
    SplitVectorTree(lst = lst)
})

# check_afun_cfun_params ----

# This checks if the input params are used anywhere in cfun/afun
setGeneric("check_afun_cfun_params", function(lyt, params) {
  standardGeneric("check_afun_cfun_params")
})

setMethod(
  "check_afun_cfun_params", "PreDataTableLayouts",
  function(lyt, params) {
    # clayout does not have analysis functions
    check_afun_cfun_params(rlayout(lyt), params)
  }
)

setMethod(
  "check_afun_cfun_params", "PreDataRowLayout",
  function(lyt, params) {
    ro_spl_parm_l <- check_afun_cfun_params(root_spl(lyt), params)
    r_spl_parm_l <- lapply(lyt, check_afun_cfun_params, params = params)
    Reduce(`|`, c(list(ro_spl_parm_l), r_spl_parm_l))
  }
)

# Main function for checking parameters
setMethod(
  "check_afun_cfun_params", "SplitVector",
  function(lyt, params) {
    param_l <- lapply(lyt, check_afun_cfun_params, params = params)
    Reduce(`|`, param_l)
  }
)

setMethod(
  "check_afun_cfun_params", "SplitVectorTree",
  function(lyt, params) {
    param_l <- lapply(lyt, check_afun_cfun_params, params = params)
    Reduce(`|`, param_l)
})
# Helper function for check_afun_cfun_params
.afun_cfun_switch <- function(spl_i) {
  if (is(spl_i, "VAnalyzeSplit")) {
    analysis_fun(spl_i)
  } else {
    content_fun(spl_i)
  }
}

# Extreme case that happens only when using add_existing_table
setMethod(
  "check_afun_cfun_params", "VTableTree",
  function(lyt, params) {
    setNames(logical(length(params)), params) # All FALSE
  }
)

setMethod(
  "check_afun_cfun_params", "Split",
  function(lyt, params) {
    # Extract function in the split
    fnc <- .afun_cfun_switch(lyt)

    # For each parameter, check if it is called
    sapply(params, function(pai) any(unlist(func_takes(fnc, pai))))
  }
)

# Helper functions ----

count <- function(df, ...) NROW(df)

guess_format <- function(val) {
  if (length(val) == 1) {
    if (is.integer(val) || !is.numeric(val)) {
      "xx"
    } else {
      "xx.xx"
    }
  } else if (length(val) == 2) {
    "xx.x / xx.x"
  } else if (length(val) == 3) {
    "xx.x (xx.x - xx.x)"
  } else {
    stop("got value of length > 3")
  }
}

.quick_afun <- function(afun, lbls) {
  if (.takes_df(afun)) {
    function(df, .spl_context, ...) {
      if (!is.null(lbls) && length(lbls) == 1 && is.na(lbls)) {
        lbls <- tail(.spl_context$value, 1)
      }
      if (".spl_context" %in% names(formals(afun))) {
        res <- afun(df = df, .spl_context = .spl_context, ...)
      } else {
        res <- afun(df = df, ...)
      }
      if (is(res, "RowsVerticalSection")) {
        ret <- res
      } else {
        if (!is.list(res)) {
          ret <- rcell(res, label = lbls, format = guess_format(res))
        } else {
          if (!is.null(lbls) && length(lbls) == length(res) && all(!is.na(lbls))) {
            names(res) <- lbls
          }
          ret <- in_rows(.list = res, .labels = names(res), .formats = vapply(res, guess_format, ""))
        }
      }
      ret
    }
  } else {
    function(x, .spl_context, ...) {
      if (!is.null(lbls) && length(lbls) == 1 && is.na(lbls)) {
        lbls <- tail(.spl_context$value, 1)
      }
      if (".spl_context" %in% names(formals(afun))) {
        res <- afun(x = x, .spl_context = .spl_context, ...)
      } else {
        res <- afun(x = x, ...)
      }
      if (is(res, "RowsVerticalSection")) {
        ret <- res
      } else {
        if (!is.list(res)) {
          ret <- rcell(res, label = lbls, format = guess_format(res))
        } else {
          if (!is.null(lbls) && length(lbls) == length(res) && all(!is.na(lbls))) {
            names(res) <- lbls
          }
          ret <- in_rows(.list = res, .labels = names(res), .formats = vapply(res, guess_format, ""))
        }
      }
      ret
    }
  }
}

# qtable ----

n_cells_res <- function(res) {
  ans <- 1L
  if (is.list(res)) {
    ans <- length(res)
  } else if (is(res, "RowsVerticalSection")) {
    ans <- length(res$values)
  } # XXX penetrating the abstraction
  ans
}

#' Generalized frequency table
#'
#' This function provides a convenience interface for generating generalizations of a 2-way frequency table. Row and
#' column space can be facetted by variables, and an analysis function can be specified. The function then builds a
#' layout with the specified layout and applies it to the data provided.
#'
#' @inheritParams constr_args
#' @inheritParams basic_table
#' @param row_vars (`character`)\cr the names of variables to be used in row facetting.
#' @param col_vars (`character`)\cr the names of variables to be used in column facetting.
#' @param data (`data.frame`)\cr the data to tabulate.
#' @param avar (`string`)\cr the variable to be analyzed. Defaults to the first variable in `data`.
#' @param row_labels (`character` or `NULL`)\cr row label(s) which should be applied to the analysis rows. Length must
#'   match the number of rows generated by `afun`.
#' @param afun (`function`)\cr the function to generate the analysis row cell values. This can be a proper analysis
#'   function, or a function which returns a vector or list. Vectors are taken as multi-valued single cells, whereas
#'   lists are interpreted as multiple cells.
#' @param drop_levels (`flag`)\cr whether unobserved factor levels should be dropped during facetting. Defaults to
#'   `TRUE`.
#' @param summarize_groups (`flag`)\cr whether each level of nesting should include marginal summary rows. Defaults to
#'   `FALSE`.
#' @param ... additional arguments passed to `afun`.
#' @param .default_rlabel (`string`)\cr this is an implementation detail that should not be set by end users.
#'
#' @details
#' This function creates a table with a single top-level structure in both row and column dimensions involving faceting
#' by 0 or more variables in each dimension.
#'
#' The display of the table depends on certain details of the tabulation. In the case of an `afun` which returns a
#' single cell's contents (either a scalar or a vector of 2 or 3 elements), the label rows for the deepest-nested row
#' facets will be hidden and the labels used there will be used as the analysis row labels. In the case of an `afun`
#' which returns a list (corresponding to multiple cells), the names of the list will be used as the analysis row
#' labels and the deepest-nested facet row labels will be visible.
#'
#' The table will be annotated in the top-left area with an informative label displaying the analysis variable
#' (`avar`), if set, and the function used (captured via substitute) where possible, or 'count' if not. One exception
#' where the user may directly modify the top-left area (via `row_labels`) is the case of a table with row facets and
#' an `afun` which returns a single row.
#'
#' @return
#' * `qtable` returns a built `TableTree` object representing the desired table
#' * `qtable_layout` returns a `PreDataTableLayouts` object declaring the structure of the desired table, suitable for
#'   passing to [build_table()].
#'
#' @examples
#' qtable(ex_adsl)
#' qtable(ex_adsl, row_vars = "ARM")
#' qtable(ex_adsl, col_vars = "ARM")
#' qtable(ex_adsl, row_vars = "SEX", col_vars = "ARM")
#' qtable(ex_adsl, row_vars = c("COUNTRY", "SEX"), col_vars = c("ARM", "STRATA1"))
#' qtable(ex_adsl,
#'   row_vars = c("COUNTRY", "SEX"),
#'   col_vars = c("ARM", "STRATA1"), avar = "AGE", afun = mean
#' )
#' summary_list <- function(x, ...) as.list(summary(x))
#' qtable(ex_adsl, row_vars = "SEX", col_vars = "ARM", avar = "AGE", afun = summary_list)
#' suppressWarnings(qtable(ex_adsl,
#'   row_vars = "SEX",
#'   col_vars = "ARM", avar = "AGE", afun = range
#' ))
#'
#' @export
qtable_layout <- function(data,
                          row_vars = character(),
                          col_vars = character(),
                          avar = NULL,
                          row_labels = NULL,
                          afun = NULL,
                          summarize_groups = FALSE,
                          title = "",
                          subtitles = character(),
                          main_footer = character(),
                          prov_footer = character(),
                          show_colcounts = TRUE,
                          drop_levels = TRUE,
                          ...,
                          .default_rlabel = NULL) {
  subafun <- substitute(afun)
  if (!is.null(.default_rlabel)) {
    dflt_row_lbl <- .default_rlabel
  } else if (
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
          envir = parent.frame(1),
          ifnotfound = list(NULL),
          inherits = TRUE
        )[[1]],
        afun
      )
  ) {
    dflt_row_lbl <- paste(avar, as.character(subafun), sep = " - ")
  } else {
    dflt_row_lbl <- if (is.null(avar)) "count" else avar
  }

  if (is.null(afun)) {
    afun <- count
  }

  if (is.null(avar)) {
    avar <- names(data)[1]
  }
  fakeres <- afun(data[[avar]], ...)
  multirow <- is.list(fakeres) || is(fakeres, "RowsVerticalSection") || summarize_groups
  ## this is before we plug in the default so if not specified by the user
  ## explicitly, row_labels is NULL at this point.
  if (!is.null(row_labels) && length(row_labels) != n_cells_res(fakeres)) {
    stop(
      "Length of row_labels (",
      length(row_labels),
      ") does not agree with number of rows generated by analysis function (",
      n_cells_res(fakeres),
      ")."
    )
  }

  if (is.null(row_labels)) {
    row_labels <- dflt_row_lbl
  }

  lyt <- basic_table(
    title = title,
    subtitles = subtitles,
    main_footer = main_footer,
    prov_footer = prov_footer,
    show_colcounts = show_colcounts
  )

  for (var in col_vars) lyt <- split_cols_by(lyt, var)

  for (var in head(row_vars, -1)) {
    lyt <- split_rows_by(lyt, var, split_fun = if (drop_levels) drop_split_levels else NULL)
    if (summarize_groups) {
      lyt <- summarize_row_groups(lyt)
    }
  }

  tleft <- if (multirow || length(row_vars) > 0) dflt_row_lbl else character()
  if (length(row_vars) > 0) {
    if (!multirow) {
      ## in the single row in splitting case, we use the row label as the topleft
      ## and the split values as the row labels for a more compact apeparance
      tleft <- row_labels
      row_labels <- NA_character_
      lyt <- split_rows_by(
        lyt, tail(row_vars, 1),
        split_fun = if (drop_levels) drop_split_levels else NULL, child_labels = "hidden"
      )
    } else {
      lyt <- split_rows_by(lyt, tail(row_vars, 1), split_fun = if (drop_levels) drop_split_levels else NULL)
    }
    if (summarize_groups) {
      lyt <- summarize_row_groups(lyt)
    }
  }
  inner_afun <- .quick_afun(afun, row_labels)
  lyt <- analyze(lyt, avar, afun = inner_afun, extra_args = list(...))
  lyt <- append_topleft(lyt, tleft)
}

#' @rdname qtable_layout
#' @export
qtable <- function(data,
                   row_vars = character(),
                   col_vars = character(),
                   avar = NULL,
                   row_labels = NULL,
                   afun = NULL,
                   summarize_groups = FALSE,
                   title = "",
                   subtitles = character(),
                   main_footer = character(),
                   prov_footer = character(),
                   show_colcounts = TRUE,
                   drop_levels = TRUE,
                   ...) {
  ## this involves substitution so it needs to appear in both functions. Gross but true.
  subafun <- substitute(afun)
  if (
    is.name(subafun) && is.function(afun) &&
      ## this is gross. basically testing
      ## if the symbol we have corresponds
      ## in some meaningful way to the function
      ## we will be calling.
      identical(
        mget(
          as.character(subafun),
          mode = "function", envir = parent.frame(1), ifnotfound = list(NULL), inherits = TRUE
        )[[1]],
        afun
      )
  ) {
    dflt_row_lbl <- paste(avar, as.character(subafun), sep = " - ")
  } else {
    dflt_row_lbl <- if (is.null(avar)) "count" else avar
  }

  lyt <- qtable_layout(
    data = data,
    row_vars = row_vars,
    col_vars = col_vars,
    avar = avar,
    row_labels = row_labels,
    afun = afun,
    summarize_groups = summarize_groups,
    title = title,
    subtitles = subtitles,
    main_footer = main_footer,
    prov_footer = prov_footer,
    show_colcounts = show_colcounts,
    drop_levels = drop_levels,
    ...,
    .default_rlabel = dflt_row_lbl
  )
  build_table(lyt, data)
}
