# Sparse Notes on {rtables} Internals

## Disclaimer

This is a collection of notes divided by issues and it is a working
document that will end up being a developer vignette one day.

## `section_div` notes

Everything in the layout is built over split objects, that reside in
`00_tabletrees.R`. There `section_div` is defined internally in each
split object as `child_section_div` and assigned to `NA_character` as
default. This needs to be in all split objects that need to have a
separator divisor. Object-wise, the virtual class `Split` contains
`section_div` and it has the following sub-classes. I tagged with “X”
constructor that allows for `section_div` to be assigned to a value
different than `NA_character`, and `"NX"` otherwise.

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`

    ## Loading required package: formatters

    ## 
    ## Attaching package: 'formatters'

    ## The following object is masked from 'package:base':
    ## 
    ##     %||%

    ## 
    ## Attaching package: 'rtables'

    ## The following object is masked from 'package:utils':
    ## 
    ##     str

[`getClass`](https://rdrr.io/r/methods/getClass.html)`(``"Split"``)`

    ## Virtual Class "Split" [package "rtables"]
    ## 
    ## Slots:
    ##                                                                               
    ## Name:                  payload                    name             split_label
    ## Class:                     ANY               character               character
    ##                                                                               
    ## Name:             split_format            split_na_str    split_label_position
    ## Class:              FormatSpec         characterOrList               character
    ##                                                                               
    ## Name:              content_fun          content_format          content_na_str
    ## Class:              listOrNULL              FormatSpec               character
    ##                                                                               
    ## Name:              content_var          label_children              extra_args
    ## Class:               character                 logical                    list
    ##                                                                               
    ## Name:          indent_modifier content_indent_modifier      content_extra_args
    ## Class:                 integer                 integer                    list
    ##                                                                               
    ## Name:        page_title_prefix       child_section_div    child_show_colcounts
    ## Class:               character               character                 logical
    ##                               
    ## Name:    child_colcount_format
    ## Class:              FormatSpec
    ## 
    ## Known Subclasses: 
    ## Class "CustomizableSplit", directly
    ## Class "AllSplit", directly
    ## Class "VarStaticCutSplit", directly
    ## Class "VarDynCutSplit", directly
    ## Class "VAnalyzeSplit", directly
    ## Class "CompoundSplit", directly
    ## Class "VarLevelSplit", by class "CustomizableSplit", distance 2
    ## Class "MultiVarSplit", by class "CustomizableSplit", distance 2
    ## Class "RootSplit", by class "AllSplit", distance 2
    ## Class "ManualSplit", by class "AllSplit", distance 2
    ## Class "CumulativeCutSplit", by class "VarStaticCutSplit", distance 2
    ## Class "AnalyzeVarSplit", by class "VAnalyzeSplit", distance 2
    ## Class "AnalyzeColVarSplit", by class "VAnalyzeSplit", distance 2
    ## Class "AnalyzeMultiVars", by class "CompoundSplit", distance 2
    ## Class "VarLevWBaselineSplit", by class "VarLevelSplit", distance 3

`# Known Subclasses:`` ``# ? Class "CustomizableSplit", directly # vclass used for grouping different split types (I guess)`` ``# Class "AllSplit", directly # NX`` ``# Class "VarStaticCutSplit", directly # X via make_static_cut_split`` ``# Class "VarDynCutSplit", directly # X`` ``# Class "VAnalyzeSplit", directly # X`` ``# ? Class "CompoundSplit", directly # Used only for AnalyzeMultiVars (maybe not needed?)`` ``# Class "VarLevelSplit", by class "CustomizableSplit", distance 2 # X`` ``# Class "MultiVarSplit", by class "CustomizableSplit", distance 2 # X`` ``# Class "RootSplit", by class "AllSplit", distance 2 # NX`` ``# Class "ManualSplit", by class "AllSplit", distance 2 # X`` ``# Class "CumulativeCutSplit", by class "VarStaticCutSplit", distance 2 # X via make_static_cut_split`` ``# Class "AnalyzeVarSplit", by class "VAnalyzeSplit", distance 2 # Virtual`` ``# Class "AnalyzeColVarSplit", by class "VAnalyzeSplit", distance 2 # X`` ``# Class "AnalyzeMultiVars", by class "CompoundSplit", distance 2 # X`` ``# Class "VarLevWBaselineSplit", by class "VarLevelSplit", distance 3 # NX`

This can be updated only by related layout functions. The most
important, that are covered by tests are `analyze` and `split_rows_by`.

Now it is relevant to understand where this information is saved in the
table object built by `build_table`. To do that we need to see where it
is present and how it is assigned. Let’s go back to `00tabletree.R`and
look for `trailing_section_div`. As classes definitions goes, you will
notice from the search that `trailing_section_div` is present in the
virtual classes `TableRow` and `VTableTree`. In the following is the
class hierarchy that makes \`trailing_section_div:

[`getClass`](https://rdrr.io/r/methods/getClass.html)`(``"TableRow"``)`

    ## Virtual Class "TableRow" [package "rtables"]
    ## 
    ## Slots:
    ##                                                                            
    ## Name:              leaf_value           var_analyzed                  label
    ## Class:                    ANY              character              character
    ##                                                                            
    ## Name:           row_footnotes   trailing_section_div                  level
    ## Class:                   list              character                integer
    ##                                                                            
    ## Name:                    name               col_info                 format
    ## Class:              character InstantiatedColumnInfo             FormatSpec
    ##                                                                            
    ## Name:                  na_str        indent_modifier            table_inset
    ## Class:              character                integer                integer
    ##                              
    ## Name:              round_type
    ## Class:              character
    ## 
    ## Extends: 
    ## Class "VLeaf", directly
    ## Class "VTableNodeInfo", directly
    ## Class "VNodeInfo", by class "VLeaf", distance 2
    ## 
    ## Known Subclasses: "DataRow", "ContentRow", "LabelRow"

`# Extends:`` ``# Class "VLeaf", directly`` ``# Class "VTableNodeInfo", directly`` ``# Class "VNodeInfo", by class "VLeaf", distance 2`` ``#`` ``# Known Subclasses: "DataRow", "ContentRow", "LabelRow"`` `` `[`getClass`](https://rdrr.io/r/methods/getClass.html)`(``"VTableTree"``)`

    ## Virtual Class "VTableTree" [package "rtables"]
    ## 
    ## Slots:
    ##                                                                            
    ## Name:                children               rowspans               labelrow
    ## Class:                   list             data.frame               LabelRow
    ##                                                                            
    ## Name:             page_titles         horizontal_sep     header_section_div
    ## Class:              character              character              character
    ##                                                                            
    ## Name:    trailing_section_div               col_info                 format
    ## Class:              character InstantiatedColumnInfo             FormatSpec
    ##                                                                            
    ## Name:                  na_str        indent_modifier            table_inset
    ## Class:              character                integer                integer
    ##                                                                            
    ## Name:              round_type                  level                   name
    ## Class:              character                integer              character
    ##                                                                            
    ## Name:              main_title              subtitles            main_footer
    ## Class:              character              character              character
    ##                              
    ## Name:       provenance_footer
    ## Class:              character
    ## 
    ## Extends: 
    ## Class "VTableNodeInfo", directly
    ## Class "VTree", directly
    ## Class "VTitleFooter", directly
    ## Class "VNodeInfo", by class "VTableNodeInfo", distance 2
    ## 
    ## Known Subclasses: "ElementaryTable", "TableTree"

`# Extends:`` ``# Class "VTableNodeInfo", directly`` ``# Class "VTree", directly`` ``# Class "VTitleFooter", directly`` ``# Class "VNodeInfo", by class "VTableNodeInfo", distance 2`` ``#`` ``# Known Subclasses: "ElementaryTable", "TableTree"`

Always check the constructors after finding the classes. In the above
case for example, the `DataRow` and `ContentRow` share the constructor,
so we do not need to add identical getter and setters for these two
classes but only for the virtual class `TableRow`. Different is the
story for `LabelRow` which needs to be handle differently. Now, to
understand why only these two have this feature, lets see the structure
of a table built with section dividers:

`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"ARM"``, section_div ``=`` ``"+"``)`` ``|>`` `` `[`split_rows_by`](https://pharmaverse.github.io/rtables/reference/split_rows_by.md)`(``"STRATA1"``, section_div ``=`` ``""``)`` ``|>`` `` `[`analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md)`(``"AGE"``,`` `` afun ``=`` ``function``(``x``)`` `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean"`` ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``x``)``, ``"Standard deviation"`` ``=`` `[`sd`](https://rdrr.io/r/stats/sd.html)`(``x``)``)``,`` `` format ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``"Mean"`` ``=`` ``"xx."``, ``"Standard deviation"`` ``=`` ``"xx."``)``,`` `` section_div ``=`` ``"~"`` `` ``)`` `` ``tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``DM``)`` `` `[`print`](https://rdrr.io/r/base/print.html)`(``tbl``)`

    ##                          all obs
    ## ————————————————————————————————
    ## A: Drug X                       
    ##   A                             
    ##     Mean                   33   
    ##     Standard deviation      7   
    ## 
    ##   B                             
    ##     Mean                   35   
    ##     Standard deviation      7   
    ## 
    ##   C                             
    ##     Mean                   36   
    ##     Standard deviation      9   
    ## ++++++++++++++++++++++++++++++++
    ## B: Placebo                      
    ##   A                             
    ##     Mean                   32   
    ##     Standard deviation      6   
    ## 
    ##   B                             
    ##     Mean                   32   
    ##     Standard deviation      6   
    ## 
    ##   C                             
    ##     Mean                   34   
    ##     Standard deviation      7   
    ## ++++++++++++++++++++++++++++++++
    ## C: Combination                  
    ##   A                             
    ##     Mean                   36   
    ##     Standard deviation      7   
    ## 
    ##   B                             
    ##     Mean                   34   
    ##     Standard deviation      6   
    ## 
    ##   C                             
    ##     Mean                   34   
    ##     Standard deviation      6

[`print`](https://rdrr.io/r/base/print.html)`(`[`class`](https://rdrr.io/r/base/class.html)`(``tbl``)``)`` ``# TableTree`

    ## [1] "TableTree"
    ## attr(,"package")
    ## [1] "rtables"

`# methods("trailing_section_div") # to see this please do devtools::load_all()`` ``# [1] trailing_section_div,LabelRow-method`` ``# trailing_section_div,TableRow-method`` ``# trailing_section_div,VTableTree-method`

In the above, we show that `trailing_section_div` has methods for
`TableRow` virtual object, `LabelRow`, and `VTableTree`. These three
make the whole `section_div` structure as the `VTableTree` is present in
`TableTree` and `ElementaryTable` that are the two main table objects.
If these are not `NA_character_` then the `section_div` is printed at
split divisions. The `LabelRow` and `TableRow` are different as their
assignment allows the row-wise modification of separators. When we have
a special case for a `ContentRow`, as it is represented as
`content_table(obj)` which is a one-line `ElementaryTable`, while label
row is turned off. Please take a moment to check the following setter:

[`setMethod`](https://rdrr.io/r/methods/setMethod.html)`(``"section_div<-"``, ``"VTableTree"``, ``function``(``obj``, ``value``, ``only_sep_sections`` ``=`` ``FALSE``)`` ``{`` `` ``char_v`` ``<-`` `[`as.character`](https://rdrr.io/r/base/character.html)`(``value``)`` `` ``tree_depths`` ``<-`` `[`unname`](https://rdrr.io/r/base/unname.html)`(`[`vapply`](https://rdrr.io/r/base/lapply.html)`(`[`collect_leaves`](https://pharmaverse.github.io/rtables/reference/collect_leaves.md)`(``obj``)``, ``tt_level``, `[`numeric`](https://rdrr.io/r/base/numeric.html)`(``1``)``)``)`` `` ``max_tree_depth`` ``<-`` `[`max`](https://rdrr.io/r/base/Extremes.html)`(``tree_depths``)`` `` `[`stopifnot`](https://rdrr.io/r/base/stopifnot.html)`(`[`is.logical`](https://rdrr.io/r/base/logical.html)`(``only_sep_sections``)``)`` `` ``.check_char_vector_for_section_div``(``char_v``, ``max_tree_depth``, `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``obj``)``)`` `` `` ``# Automatic establishment of intent`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``char_v``)`` ``<`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``obj``)``)`` ``{`` `` ``only_sep_sections`` ``<-`` ``TRUE`` `` ``}`` `` `` ``# Case where only separators or splits need to change externally`` `` ``if`` ``(``only_sep_sections`` ``&&`` `[`length`](https://rdrr.io/r/base/length.html)`(``char_v``)`` ``<`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``obj``)``)`` ``{`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``char_v``)`` ``==`` ``1``)`` ``{`` `` ``char_v`` ``<-`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``char_v``, ``max_tree_depth`` ``-`` ``1``)`` ``# -1 is the data row`` `` ``}`` `` ``# Case where char_v is longer than the max depth`` `` ``char_v`` ``<-`` ``char_v``[`[`seq_len`](https://rdrr.io/r/base/seq.html)`(`[`min`](https://rdrr.io/r/base/Extremes.html)`(``max_tree_depth``, `[`length`](https://rdrr.io/r/base/length.html)`(``char_v``)``)``)``]`` `` ``# Filling up with NAs the rest of the tree depth section div chr vector`` `` ``missing_char_v_len`` ``<-`` ``max_tree_depth`` ``-`` `[`length`](https://rdrr.io/r/base/length.html)`(``char_v``)`` `` ``char_v`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``char_v``, `[`rep`](https://rdrr.io/r/base/rep.html)`(``NA_character_``, ``missing_char_v_len``)``)`` `` ``# char_v <- unlist(`` `` ``# lapply(tree_depths, function(tree_depth_i) char_v[seq_len(tree_depth_i)]),`` `` ``# use.names = FALSE`` `` ``# )`` `` ``}`` `` `` ``# Retrieving if it is a contentRow (no need for labelrow to be visible in this case)`` `` ``content_row_tbl`` ``<-`` `[`content_table`](https://pharmaverse.github.io/rtables/reference/content_table.md)`(``obj``)`` `` ``is_content_table`` ``<-`` `[`isS4`](https://rdrr.io/r/base/isS4.html)`(``content_row_tbl``)`` ``&&`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``content_row_tbl``)`` ``>`` ``0`` `` `` ``# Main table structure change`` `` ``if`` ``(`[`labelrow_visible`](https://pharmaverse.github.io/rtables/reference/int_methods.md)`(``obj``)`` ``||`` ``is_content_table``)`` ``{`` `` ``if`` ``(``only_sep_sections``)`` ``{`` `` ``# Only tables are modified`` `` ``trailing_section_div``(`[`tt_labelrow`](https://pharmaverse.github.io/rtables/reference/int_methods.md)`(``obj``)``)`` ``<-`` ``NA_character_`` `` ``trailing_section_div``(``obj``)`` ``<-`` ``char_v``[``1``]`` `` `[`section_div`](https://pharmaverse.github.io/rtables/reference/section_div.md)`(`[`tree_children`](https://pharmaverse.github.io/rtables/reference/tree_children.md)`(``obj``)``, only_sep_sections ``=`` ``only_sep_sections``)`` ``<-`` ``char_v``[``-``1``]`` `` ``}`` ``else`` ``{`` `` ``# All leaves are modified`` `` ``trailing_section_div``(`[`tt_labelrow`](https://pharmaverse.github.io/rtables/reference/int_methods.md)`(``obj``)``)`` ``<-`` ``char_v``[``1``]`` `` ``trailing_section_div``(``obj``)`` ``<-`` ``NA_character_`` `` `[`section_div`](https://pharmaverse.github.io/rtables/reference/section_div.md)`(`[`tree_children`](https://pharmaverse.github.io/rtables/reference/tree_children.md)`(``obj``)``, only_sep_sections ``=`` ``only_sep_sections``)`` ``<-`` ``char_v``[``-``1``]`` `` ``}`` `` ``}`` ``else`` ``{`` `` `[`section_div`](https://pharmaverse.github.io/rtables/reference/section_div.md)`(`[`tree_children`](https://pharmaverse.github.io/rtables/reference/tree_children.md)`(``obj``)``, only_sep_sections ``=`` ``only_sep_sections``)`` ``<-`` ``char_v`` `` ``}`` `` ``obj`` ``}``)`

`only_sep_sections` is a parameter that is used to change only the
separators (between splits) and not the data rows. It is happening
forcefully if set to `TRUE`, but it is automatically activated when
`section_div(tbl) <- char_v` is a character vector of length
`< nrow(tbl)`. Notice that the exception for `ContentRow` is activated
by the switcher `is_content_table`. This is because content rows do not
have visible label row. You see that in the main table structure change
we have two blocks depending on `only_sep_sections`. If `TRUE` only the
`VTableTree` are modified leading to only split section separators to be
modified. Also consider looking at `section_div` getter and tests in
`test-accessors.R` to have more insights on the structure. Also to
understand exactly how this is bound to output, please check the result
of
[`make_row_df()`](https://rdrr.io/pkg/formatters/man/make_row_df.html)
for the column `trailing_sep`. Indeed, an alternative and iterative
method is used by `make_row_df` to retrieve the information about the
separators for each table row. Being it a trailing separator by
definition, we added `header_section_div` as a function and a parameter
of `basic_table`, so to possibly add an empty line after the header
(e.g. `header_section_div(tbl) = " "`). This is not a trailing
separator, but it is a separator that is added after the header. To
close the circle, please check how `trailing_sep` and
`header_section_div` is propagated and printed/used in
[`formatters::toString`](https://rdrr.io/pkg/formatters/man/tostring.html).
