# Printing Machinery

## Disclaimer

In comparison to other entries of the developer guide, this is intended
to keep track of the general concepts and processing pipeline behind the
printing machinery. It is not intended to be a complete documentation of
the machinery itself, but rather a collection of notes that can be used
to understand the machinery and its internals. Hence, be aware that this
is a working document that captures a snapshot of the machinery at a
certain point in time. It is not meant to be fully maintained, but it
can be used as a starting point for one. Compared to other parts of the
developer guide, this will contain the current state of `rlistings`’
printing machinery, which is often a simplified version of the machinery
that is used in `rtables`.

### How `print` works

Lets track down what is going under the hood when a standard table is
printed. The following is the code that is executed when a table is
printed:

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`

    # Loading required package: formatters

    # 
    # Attaching package: 'formatters'

    # The following object is masked from 'package:base':
    # 
    #     %||%

    # 
    # Attaching package: 'rtables'

    # The following object is masked from 'package:utils':
    # 
    #     str

[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`

    # 
    # Attaching package: 'dplyr'

    # The following objects are masked from 'package:stats':
    # 
    #     filter, lag

    # The following objects are masked from 'package:base':
    # 
    #     intersect, setdiff, setequal, union

`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"SEX"``, split_fun ``=`` `[`keep_split_levels`](https://pharmaverse.github.io/rtables/reference/split_funcs.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"F"``, ``"M"``)``)``)`` ``|>`` `` `[`split_cols_by`](https://pharmaverse.github.io/rtables/reference/split_cols_by.md)`(``"ARM"``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"BMRKR1"``)`` ``|>`` `` `[`print`](https://rdrr.io/r/base/print.html)`(``)`

    # A Pre-data Table Layout
    # 
    # Column-Split Structure:
    # ARM (lvls) 
    # 
    # Row-Split Structure:
    # SEX (lvls) -> BMRKR1 (** analysis **)

`tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``ex_adsl``)`` ``|>`` `` `[`print`](https://rdrr.io/r/base/print.html)`(``)`

    #          A: Drug X   B: Placebo   C: Combination
    # ————————————————————————————————————————————————
    # F                                               
    #   Mean     5.75         5.59           5.68     
    # M                                               
    #   Mean     6.27         5.87           5.34

We see that also a layout object (`PreDataTableLayouts`) is created and
printed. This is because `print` is a generic function that dispatches
to different methods depending on the class of the object. In this case,
the S4 class of the object is `PreDataTableLayouts` and the method that
is called is `print`. In the case of {rtables} the method is dispatched
towards the `show` method of the class `PreDataTableLayouts`. It can be
found by searching `A Pre-data Table Layout` into {rtables} source code.
I think R dispatcher for `print` methods looks for `show` S4 methods
instead if there are no S3 or S4 `print` methods available. Indeed, this
is the code that is executed:

[`setMethod`](https://rdrr.io/r/methods/setMethod.html)`(`` `` ``"show"``, ``"PreDataTableLayouts"``,`` `` ``function``(``object``)`` ``{`` `` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"A Pre-data Table Layout\n"``)`` `` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nColumn-Split Structure:\n"``)`` `` ``docat_predataxis``(``object``@``col_layout``)`` `` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\nRow-Split Structure:\n"``)`` `` ``docat_predataxis``(``object``@``row_layout``)`` `` `[`cat`](https://rdrr.io/r/base/cat.html)`(``"\n"``)`` `` `[`invisible`](https://rdrr.io/r/base/invisible.html)`(``object``)`` `` ``}`` ``)`

This was evident if we searched for methods associated with the class
`PreDataTableLayouts`, where only `show` is connected to a sort of
printing machinery:

[`methods`](https://rdrr.io/r/utils/methods.html)`(``class ``=`` ``"PreDataTableLayouts"``)`

    #  [1] .add_row_summary        clayout                 clayout<-              
    #  [4] col_exprs               colcount_format         colcount_format<-      
    #  [7] coltree                 header_section_div      header_section_div<-   
    # [10] main_footer             main_footer<-           main_title             
    # [13] main_title<-            obj_round_type          prov_footer            
    # [16] prov_footer<-           show                    subtitles              
    # [19] subtitles<-             table_inset             table_inset<-          
    # [22] top_left                top_left<-              top_level_section_div  
    # [25] top_level_section_div<- vars_in_layout         
    # see '?methods' for accessing help and source code

Now, lets see the same for our result table `tbl`:

[`class`](https://rdrr.io/r/base/class.html)`(``tbl``)`` ``|>`` `[`print`](https://rdrr.io/r/base/print.html)`(``)`

    # [1] "TableTree"
    # attr(,"package")
    # [1] "rtables"

[`getClass`](https://rdrr.io/r/methods/getClass.html)`(``"TableTree"``)`` ``|>`` `[`print`](https://rdrr.io/r/base/print.html)`(``)`` ``# Main object representing a table in {rtables}`

    # Class "TableTree" [package "rtables"]
    # 
    # Slots:
    #                                                                            
    # Name:                 content      page_title_prefix               children
    # Class:        ElementaryTable              character                   list
    #                                                                            
    # Name:                rowspans               labelrow            page_titles
    # Class:             data.frame               LabelRow              character
    #                                                                            
    # Name:          horizontal_sep     header_section_div   trailing_section_div
    # Class:              character              character              character
    #                                                                            
    # Name:                col_info                 format                 na_str
    # Class: InstantiatedColumnInfo             FormatSpec              character
    #                                                                            
    # Name:         indent_modifier            table_inset             round_type
    # Class:                integer                integer              character
    #                                                                            
    # Name:                   level                   name             main_title
    # Class:                integer              character              character
    #                                                                            
    # Name:               subtitles            main_footer      provenance_footer
    # Class:              character              character              character
    # 
    # Extends: 
    # Class "VTableTree", directly
    # Class "VTableNodeInfo", by class "VTableTree", distance 2
    # Class "VTree", by class "VTableTree", distance 2
    # Class "VTitleFooter", by class "VTableTree", distance 2
    # Class "VNodeInfo", by class "VTableTree", distance 3

[`methods`](https://rdrr.io/r/utils/methods.html)`(``class ``=`` ``"TableTree"``)`` ``|>`` `[`print`](https://rdrr.io/r/base/print.html)`(``)`` ``# more than 70 methods but no print method`

    #  [1] [                    [<-                  as.vector           
    #  [4] cell_footnotes       cell_values          clayout             
    #  [7] clear_indent_mods    col_counts           col_counts<-        
    # [10] col_footnotes        col_info             col_info<-          
    # [13] col_total            col_total<-          colcount_format     
    # [16] colcount_format<-    colcount_na_str      colcount_na_str<-   
    # [19] colcount_visible     colcount_visible<-   collect_leaves      
    # [22] coltree              content_table        content_table<-     
    # [25] dim                  do_forced_paginate   facet_colcount      
    # [28] facet_colcount<-     fnotes_at_path<-     get_formatted_cells 
    # [31] has_force_pag        head                 header_section_div  
    # [34] header_section_div<- horizontal_sep       horizontal_sep<-    
    # [37] indent_mod           indent_mod<-         insert_row_at_path  
    # [40] main_footer          main_footer<-        main_title          
    # [43] main_title<-         make_row_df          matrix_form         
    # [46] names                ncol                 no_colinfo          
    # [49] nrow                 obj_format           obj_format<-        
    # [52] obj_label            obj_label<-          obj_na_str          
    # [55] obj_na_str<-         obj_name             obj_name<-          
    # [58] obj_round_type       obj_round_type<-     page_titles         
    # [61] page_titles<-        prov_footer          prov_footer<-       
    # [64] rbind                rbind2               rm_all_colcounts    
    # [67] row_footnotes        row.names            section_div         
    # [70] section_div<-        show                 str                 
    # [73] subset_cols          subtitles            subtitles<-         
    # [76] table_inset          table_inset<-        tail                
    # [79] top_left             top_left<-           toString            
    # [82] tree_children        tree_children<-      tt_at_path          
    # [85] tt_at_path<-         value_at             value_formats       
    # see '?methods' for accessing help and source code

Again, the class itself has only the `show` method. Nonetheless, if you
search for `VTableTree"` you will find the `print` method for the
`TableTree` class. This is because `VTableTree` is a virtual class that
is inherited by `TableTree` and is almost identical to the `show` method
for `TableTree` objects. All the different statements in this case
(`show` or `print`) do the same thing, i.e. they call `toString` and
`cat` on the object. Hence, we know that every table is printed by
`toString` with `\n` as separator for different lines so that `cat`
renders it in its final format.

### From `matrix_form` to `toString`

If we have source code of `formatters`, `rtables`, and `rlistings` in
our local we can search for `"toString"` S4 method definition across
these source folders. We will find generics in `formatters` and three
different `setMethod(...)`. `toString` is properly defined in
`formatters`, but it is also present in `rlistings` and`rtables`. Let’s
take a look at the latter first.

[`setMethod`](https://rdrr.io/r/methods/setMethod.html)`(``"toString"``, ``"VTableTree"``, ``function``(``x``,`` `` ``widths`` ``=`` ``NULL``,`` `` ``col_gap`` ``=`` ``3``,`` `` ``hsep`` ``=`` `[`horizontal_sep`](https://pharmaverse.github.io/rtables/reference/horizontal_sep.md)`(``x``)``,`` `` ``indent_size`` ``=`` ``2``,`` `` ``tf_wrap`` ``=`` ``FALSE``,`` `` ``max_width`` ``=`` ``NULL``)`` ``{`` `` `[`toString`](https://rdrr.io/pkg/formatters/man/tostring.html)`(`` `` `[`matrix_form`](https://rdrr.io/pkg/formatters/man/matrix_form.html)`(``x``,`` `` indent_rownames ``=`` ``TRUE``,`` `` indent_size ``=`` ``indent_size`` ``# Only modifies the rownames in matrix_form`` `` ``)``,`` `` widths ``=`` ``widths``, col_gap ``=`` ``col_gap``,`` `` hsep ``=`` ``hsep``,`` `` tf_wrap ``=`` ``tf_wrap``,`` `` max_width ``=`` ``max_width`` `` ``)`` ``}``)`

This is only a wrapper/dispatcher to the core `toString` function in
`formatters`, beside the `indent_size` specification. This is based on
the “rendering-ready” class `MatrixPrintForm` that is produced by
`matrix_form`. The latter is the first core transformation that we need
to know to understand the printing process. All exporters and printers
are based on `MatrixPrintForm` objects, hence any bug or problem needs
to tracked down to this function or `toString`. If we take a look at
`toString` for `"listing_df"` in `rlistings`, we will find a shallow
wrapper that dispatches to `MatrixPrintForm` objects:

[`setMethod`](https://rdrr.io/r/methods/setMethod.html)`(``"toString"``, ``"listing_df"``, ``function``(``x``, ``...``)`` ``{`` `` `[`toString`](https://rdrr.io/pkg/formatters/man/tostring.html)`(`[`matrix_form`](https://rdrr.io/pkg/formatters/man/matrix_form.html)`(``x``)``, ``...``)`` ``}``)`

Hence lets take a look at `"matrix_form"` (if there are quotes, it is an
S4 function from now on). Beside generics and self calls
(`setMethod("matrix_form", "MatrixPrintForm", [...] obj)`), `rlistings`
and `rtables` have their own “constructor” of `MatrixPrintForm` (the
real one can be found in `formatters`). Let’s start with the latter
`"matrix_form"` which is dispatched when dealing with `VTableTree`s.

`# Entering matrix_form for VTableTree`` `[`trace`](https://rdrr.io/r/base/trace.html)`(``"matrix_form"``, signature ``=`` ``"VTableTree"``, tracer ``=`` ``browser``, exit ``=`` ``browser``)`` `[`matrix_form`](https://rdrr.io/pkg/formatters/man/matrix_form.html)`(``tbl``)`` `[`untrace`](https://rdrr.io/r/base/trace.html)`(``"matrix_form"``, signature ``=`` ``"VTableTree"``)`

Now lets see the newly commented code for `matrix_form`. With `#->` I
will comment some suggestions for further understandings.

[`setMethod`](https://rdrr.io/r/methods/setMethod.html)`(`` `` ``"matrix_form"``, ``"VTableTree"``,`` `` ``function``(``obj``,`` `` ``indent_rownames`` ``=`` ``FALSE``,`` `` ``expand_newlines`` ``=`` ``TRUE``,`` `` ``indent_size`` ``=`` ``2``)`` ``{`` `` `[`stopifnot`](https://rdrr.io/r/base/stopifnot.html)`(`[`is`](https://rdrr.io/r/methods/is.html)`(``obj``, ``"VTableTree"``)``)`` `` `` ``#-> Read .tbl_header_mat and subfunctions (based largely on cinfo) it can help for understanding`` `` ``# column structure and how it is printed (we can add a description of this process xxx)`` `` ``# Note: it contains the display of column counts directives and specifics`` `` ``header_content`` ``<-`` ``.tbl_header_mat``(``obj``)`` ``# first col are for row.names or topleft info`` `` ``nr_header`` ``<-`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``header_content``$``body``)`` ``# colcounts were added in .tbl_header_mat`` `` `` ``#-> As before, reading this function can help understanding how the content of the table is transformed`` `` ``# in row content and how the structure of the table is preserved in a compact manner. It is complex`` `` ``# function as it is a recursive one with the different dispatcher but following how different section_div`` `` ``# are printed (with the dedicated assignment function) can help understanding the table structure and its`` `` ``# row-wise transformation.`` `` ``# Summary of row contents - reprint_inds specifies which rows to reprint (hence the grouping)`` `` ``sr`` ``<-`` `[`make_row_df`](https://rdrr.io/pkg/formatters/man/make_row_df.html)`(``obj``)`` `` `` ``# With get_formatted_cells we get relevant information inside the table tree`` `` ``body_content_strings`` ``<-`` ``if`` ``(`[`NROW`](https://rdrr.io/r/base/nrow.html)`(``sr``)`` ``==`` ``0``)`` ``{`` `` `[`character`](https://rdrr.io/r/base/character.html)`(``)`` `` ``}`` ``else`` ``{`` `` ``#-> get_formatted_cells is an interesting function to understand the structure of the table as`` `` ``# it is design to extract only the "data" of the table as strings. Note how the label rows are`` `` ``# taken from make_row_df instead. Check shell = TRUE afterwards to see how the format are retrieved.`` `` `[`cbind`](https://rdrr.io/r/base/cbind.html)`(`[`as.character`](https://rdrr.io/r/base/character.html)`(``sr``$``label``)``, `[`get_formatted_cells`](https://pharmaverse.github.io/rtables/reference/gfc.md)`(``obj``)``)`` `` ``}`` `` `` ``formats_strings`` ``<-`` ``if`` ``(`[`NROW`](https://rdrr.io/r/base/nrow.html)`(``sr``)`` ``==`` ``0``)`` ``{`` `` `[`character`](https://rdrr.io/r/base/character.html)`(``)`` `` ``}`` ``else`` ``{`` `` `[`cbind`](https://rdrr.io/r/base/cbind.html)`(``""``, `[`get_formatted_cells`](https://pharmaverse.github.io/rtables/reference/gfc.md)`(``obj``, shell ``=`` ``TRUE``)``)`` `` ``}`` `` `` ``#-> Here spans are extracted for each row. Spans are rarely modified beyond its standard values.`` `` ``# Takes the flatten spans for each row and repeats them according to the number elements`` `` ``tsptmp`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(`[`collect_leaves`](https://pharmaverse.github.io/rtables/reference/collect_leaves.md)`(``obj``, ``TRUE``, ``TRUE``)``, ``function``(``rr``)`` ``{`` `` ``sp`` ``<-`` `[`row_cspans`](https://pharmaverse.github.io/rtables/reference/int_methods.md)`(``rr``)`` `` `[`rep`](https://rdrr.io/r/base/rep.html)`(``sp``, times ``=`` ``sp``)`` `` ``}``)`` `` `` ``## the 1 is for row labels`` `` ``body_spans`` ``<-`` ``if`` ``(`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``obj``)`` ``>`` ``0``)`` ``{`` `` `[`cbind`](https://rdrr.io/r/base/cbind.html)`(``1L``, `[`do.call`](https://rdrr.io/r/base/do.call.html)`(``rbind``, ``tsptmp``)``)`` `` ``}`` ``else`` ``{`` `` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``1``, nrow ``=`` ``0``, ncol ``=`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``obj``)`` ``+`` ``1``)`` `` ``}`` `` `` ``body_aligns`` ``<-`` ``if`` ``(`[`NROW`](https://rdrr.io/r/base/nrow.html)`(``sr``)`` ``==`` ``0``)`` ``{`` `` `[`character`](https://rdrr.io/r/base/character.html)`(``)`` `` ``}`` ``else`` ``{`` `` `[`cbind`](https://rdrr.io/r/base/cbind.html)`(``"left"``, `[`get_cell_aligns`](https://pharmaverse.github.io/rtables/reference/gfc.md)`(``obj``)``)`` ``#-> extracts align values for each cell`` `` ``}`` `` `` ``body`` ``<-`` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(``header_content``$``body``, ``body_content_strings``)`` `` `` ``# Init column format for header (empty if not for column counts)`` `` ``hdr_fmt_blank`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``""``,`` `` nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``header_content``$``body``)``,`` `` ncol ``=`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``header_content``$``body``)`` `` ``)`` `` ``# If column counts are displayed, add column count format`` `` ``if`` ``(`[`disp_ccounts`](https://pharmaverse.github.io/rtables/reference/int_methods.md)`(``obj``)``)`` ``{`` `` ``hdr_fmt_blank``[`[`nrow`](https://rdrr.io/r/base/nrow.html)`(``hdr_fmt_blank``)``, ``]`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``""``, `[`rep`](https://rdrr.io/r/base/rep.html)`(`[`colcount_format`](https://pharmaverse.github.io/rtables/reference/int_methods.md)`(``obj``)``, `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``obj``)``)``)`` `` ``}`` `` `` ``formats`` ``<-`` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(``hdr_fmt_blank``, ``formats_strings``)`` `` `` ``spans`` ``<-`` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(``header_content``$``span``, ``body_spans``)`` `` `[`row.names`](https://rdrr.io/r/base/row.names.html)`(``spans``)`` ``<-`` ``NULL`` `` `` ``aligns`` ``<-`` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(`` `` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(``"center"``, `[`length`](https://rdrr.io/r/base/length.html)`(``header_content``$``body``)``)``,`` `` nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``header_content``$``body``)`` `` ``)``,`` `` ``body_aligns`` `` ``)`` `` `` ``aligns``[``, ``1``]`` ``<-`` ``"left"`` ``# row names and topleft (still needed for topleft)`` `` `` ``# Main indentation of the table rownames #-> Main indentation facility`` `` ``if`` ``(``indent_rownames``)`` ``{`` `` ``body``[``, ``1``]`` ``<-`` `[`indent_string`](https://pharmaverse.github.io/rtables/reference/indent_string.md)`(``body``[``, ``1``]``, `[`c`](https://rdrr.io/r/base/c.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(``0``, ``nr_header``)``, ``sr``$``indent``)``,`` `` incr ``=`` ``indent_size`` `` ``)`` `` ``formats``[``, ``1``]`` ``<-`` `[`indent_string`](https://pharmaverse.github.io/rtables/reference/indent_string.md)`(``formats``[``, ``1``]``, `[`c`](https://rdrr.io/r/base/c.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(``0``, ``nr_header``)``, ``sr``$``indent``)``,`` `` incr ``=`` ``indent_size`` `` ``)`` `` ``}`` `` `` ``#-> referential strings are added to the table. get_ref_matrix is the core of this process`` `` ``# along with format_fnote_ref that in this case is used to format the reference string and their`` `` ``# indices. Note that the footnotes for the header is taken from the output of .tbl_header_mat`` `` ``# Handling of references in header and body`` `` ``col_ref_strs`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`vapply`](https://rdrr.io/r/base/lapply.html)`(``header_content``$``footnotes``, ``function``(``x``)`` ``{`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``x``)`` ``==`` ``0``)`` ``{`` `` ``""`` `` ``}`` ``else`` ``{`` `` `[`paste`](https://rdrr.io/r/base/paste.html)`(`[`vapply`](https://rdrr.io/r/base/lapply.html)`(``x``, ``format_fnote_ref``, ``""``)``, collapse ``=`` ``" "``)`` `` ``}`` `` ``}``, ``""``)``, ncol ``=`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``body``)``)`` `` ``body_ref_strs`` ``<-`` ``get_ref_matrix``(``obj``)`` `` ``body`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`` `` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`` `` ``body``,`` `` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(`` `` ``col_ref_strs``, ``#-> col_ref_strs are added to the body as a separate section`` `` ``body_ref_strs`` `` ``)`` `` ``)``,`` `` nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``body``)``,`` `` ncol ``=`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``body``)`` `` ``)`` `` `` ``# Solve \n in titles # This is something that is relevant in toString - NO MORE USED HERE`` `` ``# if (any(grepl("\n", all_titles(obj)))) {`` `` ``# if (any(grepl("\n", main_title(obj)))) {`` `` ``# tmp_title_vec <- .quick_handle_nl(main_title(obj))`` `` ``# main_title(obj) <- tmp_title_vec[1]`` `` ``# subtitles(obj) <- c(tmp_title_vec[-1], .quick_handle_nl(subtitles(obj)))`` `` ``# } else {`` `` ``# subtitles(obj) <- .quick_handle_nl(subtitles(obj))`` `` ``# }`` `` ``# }`` `` ``#`` `` ``# # Solve \n in footers`` `` ``# main_footer(obj) <- .quick_handle_nl(main_footer(obj))`` `` ``# prov_footer(obj) <- .quick_handle_nl(prov_footer(obj))`` `` `` ``#-> this is still under development as indicated by xxx. The idea is to allow \n also in peculiar`` `` ``# cases, such as page titles and referential footnotes. The latter are resolved in toString (pagination`` `` ``# will not count them as more than one line each), while for the former we do not have any coverage yet.`` `` ``# xxx \n in page titles are not working atm (I think)`` `` ``# ref_fnotes <- strsplit(get_formatted_fnotes(obj), "\n", fixed = TRUE)`` `` ``ref_fnotes`` ``<-`` ``get_formatted_fnotes``(``obj``)`` ``# pagination will not count extra lines coming from here`` `` ``pag_titles`` ``<-`` `[`page_titles`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)`` `` `` `[`MatrixPrintForm`](https://rdrr.io/pkg/formatters/man/MatrixPrintForm.html)`(`` `` strings ``=`` ``body``, ``#-> FUNDAMENTAL: this is the matrix that contains all the cell strings`` `` spans ``=`` ``spans``,`` `` aligns ``=`` ``aligns``,`` `` formats ``=`` ``formats``,`` `` ``## display = display, purely a function of spans, handled in constructor now`` `` row_info ``=`` ``sr``, ``#-> FUNDAMENTAL: this is the data.frame that contains all the information about the rows`` `` ``# it is the most complex data brought forward into toString`` `` ``## line_grouping handled internally now line_grouping = 1:nrow(body),`` `` ref_fnotes ``=`` ``ref_fnotes``,`` `` nlines_header ``=`` ``nr_header``, ``## this is fixed internally`` `` nrow_header ``=`` ``nr_header``,`` `` expand_newlines ``=`` ``expand_newlines``,`` `` has_rowlabs ``=`` ``TRUE``,`` `` has_topleft ``=`` ``TRUE``, ``#-> I think topleft material is handled later in toString`` `` main_title ``=`` `[`main_title`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` subtitles ``=`` `[`subtitles`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` page_titles ``=`` ``pag_titles``,`` `` main_footer ``=`` `[`main_footer`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` prov_footer ``=`` `[`prov_footer`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` table_inset ``=`` `[`table_inset`](https://rdrr.io/pkg/formatters/man/table_inset.html)`(``obj``)``,`` `` header_section_div ``=`` `[`header_section_div`](https://pharmaverse.github.io/rtables/reference/section_div.md)`(``obj``)``,`` `` horizontal_sep ``=`` `[`horizontal_sep`](https://pharmaverse.github.io/rtables/reference/horizontal_sep.md)`(``obj``)``,`` `` indent_size ``=`` ``indent_size`` `` ``)`` `` ``}`` ``)`

Now lets see the `matrix_form` in `rlistings`:

[`library`](https://rdrr.io/r/base/library.html)`(`[`rlistings`](https://insightsengineering.github.io/rlistings/)`)`` ``lsting`` ``<-`` `[`as_listing`](https://rdrr.io/pkg/rlistings/man/listings.html)`(``mtcars``)`` `[`trace`](https://rdrr.io/r/base/trace.html)`(``"matrix_form"``, signature ``=`` ``"listing_df"``, tracer ``=`` ``browser``, exit ``=`` ``browser``)`` ``mf`` ``<-`` `[`matrix_form`](https://rdrr.io/pkg/formatters/man/matrix_form.html)`(``lsting``)`` `[`untrace`](https://rdrr.io/r/base/trace.html)`(``"matrix_form"``, signature ``=`` ``"listing_df"``)`

[`setMethod`](https://rdrr.io/r/methods/setMethod.html)`(`` `` ``"matrix_form"``, ``"listing_df"``,`` `` ``rix_form`` ``<-`` ``function``(``obj``, ``indent_rownames`` ``=`` ``FALSE``)`` ``{`` ``#-> I have no idea why here there is an assignment xxx`` `` ``## we intentionally silently ignore indent_rownames because listings have`` `` ``## no rownames, but formatters::vert_pag_indices calls matrix_form(obj, TRUE)`` `` ``## unconditionally.`` `` `` ``# Keeping only displayed columns`` `` ``cols`` ``<-`` `[`attr`](https://rdrr.io/r/base/attr.html)`(``obj``, ``"listing_dispcols"``)`` ``# this is the list of columns to be displayed`` `` ``listing`` ``<-`` ``obj``[``, ``cols``]`` `` ``atts`` ``<-`` `[`attributes`](https://rdrr.io/r/base/attributes.html)`(``obj``)`` `` ``atts``$``names`` ``<-`` ``cols`` `` `[`attributes`](https://rdrr.io/r/base/attributes.html)`(``listing``)`` ``<-`` ``atts`` `` ``keycols`` ``<-`` `[`get_keycols`](https://rdrr.io/pkg/rlistings/man/listings.html)`(``listing``)`` `` `` ``bodymat`` ``<-`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``""``,`` `` nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``listing``)``,`` `` ncol ``=`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``listing``)`` `` ``)`` `` `` `[`colnames`](https://rdrr.io/r/base/colnames.html)`(``bodymat``)`` ``<-`` `[`names`](https://rdrr.io/r/base/names.html)`(``listing``)`` `` `` ``# Print only first appearer of key columns if repeated`` `` ``curkey`` ``<-`` ``""`` `` ``for`` ``(``i`` ``in`` `[`seq_along`](https://rdrr.io/r/base/seq.html)`(``keycols``)``)`` ``{`` `` ``kcol`` ``<-`` ``keycols``[``i``]`` `` ``kcolvec`` ``<-`` ``listing``[[``kcol``]``]`` `` ``#-> format_value transforms the values of the column into strings`` `` ``kcolvec`` ``<-`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``kcolvec``, ``format_value``, ``""``, format ``=`` `[`obj_format`](https://rdrr.io/pkg/formatters/man/lab_name.html)`(``kcolvec``)``, na_str ``=`` `[`obj_na_str`](https://rdrr.io/pkg/formatters/man/lab_name.html)`(``kcolvec``)``)`` `` ``curkey`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``curkey``, ``kcolvec``)`` `` ``disp`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``TRUE``, `[`tail`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``curkey``, ``-``1``)`` ``!=`` `[`head`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``curkey``, ``-``1``)``)`` ``#-> This condition only show the first appearer of a key`` `` ``bodymat``[``disp``, ``kcol``]`` ``<-`` ``kcolvec``[``disp``]`` `` ``}`` `` `` ``# Print all other columns directly`` `` ``nonkeycols`` ``<-`` `[`setdiff`](https://generics.r-lib.org/reference/setops.html)`(`[`names`](https://rdrr.io/r/base/names.html)`(``listing``)``, ``keycols``)`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``nonkeycols``)`` ``>`` ``0``)`` ``{`` `` ``for`` ``(``nonk`` ``in`` ``nonkeycols``)`` ``{`` `` ``vec`` ``<-`` ``listing``[[``nonk``]``]`` `` ``vec`` ``<-`` `[`vapply`](https://rdrr.io/r/base/lapply.html)`(``vec``, ``format_value``, ``""``, format ``=`` `[`obj_format`](https://rdrr.io/pkg/formatters/man/lab_name.html)`(``vec``)``, na_str ``=`` `[`obj_na_str`](https://rdrr.io/pkg/formatters/man/lab_name.html)`(``vec``)``)`` `` ``bodymat``[``, ``nonk``]`` ``<-`` ``vec`` `` ``}`` `` ``}`` `` `` ``fullmat`` ``<-`` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(`` `` `[`var_labels`](https://rdrr.io/pkg/formatters/man/var_labels.html)`(``listing``, fill ``=`` ``TRUE``)``, ``# Extracts the variable labels`` `` ``bodymat`` `` ``)`` `` `` ``colaligns`` ``<-`` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(`` `` `[`rep`](https://rdrr.io/r/base/rep.html)`(``"center"``, `[`length`](https://rdrr.io/r/base/length.html)`(``cols``)``)``, ``# Col names are always centered?`` `` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(`[`sapply`](https://rdrr.io/r/base/lapply.html)`(``listing``, ``obj_align``)``,`` `` ncol ``=`` `[`length`](https://rdrr.io/r/base/length.html)`(``cols``)``,`` `` nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``fullmat``)`` ``-`` ``1``,`` `` byrow ``=`` ``TRUE`` `` ``)`` `` ``)`` `` `` `[`MatrixPrintForm`](https://rdrr.io/pkg/formatters/man/MatrixPrintForm.html)`(`` `` strings ``=`` ``fullmat``,`` `` spans ``=`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``1``,`` `` nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``fullmat``)``,`` `` ncol ``=`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``fullmat``)`` `` ``)``,`` `` ref_fnotes ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``)``,`` `` aligns ``=`` ``colaligns``,`` `` formats ``=`` `[`matrix`](https://rdrr.io/r/base/matrix.html)`(``1``,`` `` nrow ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``fullmat``)``,`` `` ncol ``=`` `[`ncol`](https://rdrr.io/r/base/nrow.html)`(``fullmat``)`` `` ``)``,`` `` row_info ``=`` `[`make_row_df`](https://rdrr.io/pkg/formatters/man/make_row_df.html)`(``obj``)``,`` `` nlines_header ``=`` ``1``, ``## XXX this is probably wrong!!!`` `` nrow_header ``=`` ``1``,`` `` has_topleft ``=`` ``FALSE``,`` `` has_rowlabs ``=`` ``FALSE``,`` `` expand_newlines ``=`` ``TRUE``, ``# Always expand newlines, but this happens later!! XXX to fix`` `` main_title ``=`` `[`main_title`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` subtitles ``=`` `[`subtitles`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` page_titles ``=`` `[`page_titles`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` main_footer ``=`` `[`main_footer`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)``,`` `` prov_footer ``=`` `[`prov_footer`](https://rdrr.io/pkg/formatters/man/title_footer.html)`(``obj``)`` `` ``)`` `` ``}`` ``)`

We device here the good developer to search and understand the various
methods associated with `MatrixPrintForm` objects. It is relevant to
remember how this printed form is meant to

`# Example quick table`` ``summary_list`` ``<-`` ``function``(``x``, ``...``)`` `[`as.list`](https://rdrr.io/r/base/list.html)`(`[`summary`](https://rdrr.io/r/base/summary.html)`(``x``)``)`` ``a_table`` ``<-`` `[`qtable`](https://pharmaverse.github.io/rtables/reference/qtable_layout.md)`(``ex_adsl``, row_vars ``=`` ``"SEX"``, col_vars ``=`` ``"ARM"``, avar ``=`` ``"AGE"``, afun ``=`` ``summary_list``)`` ``tbl_methods`` ``<-`` `[`methods`](https://rdrr.io/r/utils/methods.html)`(``class ``=`` `[`class`](https://rdrr.io/r/base/class.html)`(``a_table``)``)`` ``mpf_methods`` ``<-`` `[`methods`](https://rdrr.io/r/utils/methods.html)`(``class ``=`` `[`class`](https://rdrr.io/r/base/class.html)`(`[`matrix_form`](https://rdrr.io/pkg/formatters/man/matrix_form.html)`(``a_table``)``)``[``1``]``)`` ``# it is a list of values`` `` ``# Cleaning values`` ``tbl_methods`` ``<-`` `[`unique`](https://rdrr.io/r/base/unique.html)`(`[`sapply`](https://rdrr.io/r/base/lapply.html)`(`[`strsplit`](https://rdrr.io/r/base/strsplit.html)`(``tbl_methods``, ``","``)``, ``function``(``x``)`` ``x``[``1``]``)``)`` ``mpf_methods`` ``<-`` `[`unique`](https://rdrr.io/r/base/unique.html)`(`[`sapply`](https://rdrr.io/r/base/lapply.html)`(`[`strsplit`](https://rdrr.io/r/base/strsplit.html)`(``mpf_methods``, ``","``)``, ``function``(``x``)`` ``x``[``1``]``)``)`` `[`setdiff`](https://generics.r-lib.org/reference/setops.html)`(``tbl_methods``, ``mpf_methods``)`

    #  [1] "["                    "as.vector"            "cell_footnotes"      
    #  [4] "cell_values"          "clayout"              "clear_indent_mods"   
    #  [7] "col_counts"           "col_counts<-"         "col_footnotes"       
    # [10] "col_info"             "col_info<-"           "col_total"           
    # [13] "col_total<-"          "colcount_format"      "colcount_format<-"   
    # [16] "colcount_na_str"      "colcount_na_str<-"    "colcount_visible"    
    # [19] "colcount_visible<-"   "collect_leaves"       "coltree"             
    # [22] "content_table"        "content_table<-"      "dim"                 
    # [25] "do_forced_paginate"   "facet_colcount"       "facet_colcount<-"    
    # [28] "fnotes_at_path<-"     "get_formatted_cells"  "has_force_pag"       
    # [31] "head"                 "header_section_div"   "header_section_div<-"
    # [34] "horizontal_sep"       "horizontal_sep<-"     "indent_mod"          
    # [37] "indent_mod<-"         "insert_row_at_path"   "names"               
    # [40] "no_colinfo"           "nrow"                 "obj_format"          
    # [43] "obj_format<-"         "obj_label"            "obj_label<-"         
    # [46] "obj_na_str"           "obj_na_str<-"         "obj_name"            
    # [49] "obj_name<-"           "rbind"                "rbind2"              
    # [52] "rm_all_colcounts"     "row_footnotes"        "row.names"           
    # [55] "section_div<-"        "show"                 "str"                 
    # [58] "subset_cols"          "tail"                 "top_left"            
    # [61] "top_left<-"           "tree_children"        "tree_children<-"     
    # [64] "tt_at_path"           "tt_at_path<-"         "value_at"            
    # [67] "value_formats"

[`setdiff`](https://generics.r-lib.org/reference/setops.html)`(``mpf_methods``, ``tbl_methods``)`` ``# much less unique methods`

    # [1] "coerce"         "coerce<-"       "nlines"         "num_rep_cols"  
    # [5] "num_rep_cols<-" "Ops"            "rawvalues"      "value_names"

[`intersect`](https://generics.r-lib.org/reference/setops.html)`(``tbl_methods``, ``mpf_methods``)`` ``# interesting to discover the different behaviors of same functions`

    #  [1] "[<-"              "main_footer"      "main_footer<-"    "main_title"      
    #  [5] "main_title<-"     "make_row_df"      "matrix_form"      "ncol"            
    #  [9] "obj_round_type"   "obj_round_type<-" "page_titles"      "page_titles<-"   
    # [13] "prov_footer"      "prov_footer<-"    "section_div"      "subtitles"       
    # [17] "subtitles<-"      "table_inset"      "table_inset<-"    "toString"

Let’s now take a look at the final function of all this: `toString` from
`formatters`:

[`setMethod`](https://rdrr.io/r/methods/setMethod.html)`(``"toString"``, ``"MatrixPrintForm"``, ``function``(``x``,`` `` ``widths`` ``=`` ``NULL``,`` `` ``tf_wrap`` ``=`` ``FALSE``,`` `` ``max_width`` ``=`` ``NULL``,`` `` ``col_gap`` ``=`` `[`mf_colgap`](https://rdrr.io/pkg/formatters/man/mpf_accessors.html)`(``x``)``,`` `` ``hsep`` ``=`` ``NULL``,`` `` ``fontspec`` ``=`` `[`font_spec`](https://rdrr.io/pkg/formatters/man/font_spec.html)`(``)``,`` `` ``ttype_ok`` ``=`` ``FALSE``)`` ``{`` `` ``# part 1: checks and widths/max width estimation for columns - propose_column_widths and .handle_max_width`` `` ``#`` `` ``# part 2: wrapping for the table - do_cell_fnotes_wrap`` `` ``#`` `` ``# part 3: column gap and cell widths calculations (after wrapping) - .calc_cell_widths`` `` ``#`` `` ``# part 4: collapse text body and wrapping titles/footers`` `` ``#`` `` ``# part 5: final cat()`` ``}``)`

We rely on the future developer to fill in the blanks in the above
description and to follow up the various functions to their core
mechanics.
