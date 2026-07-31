## rtables 0.6.16.9003

### New Features
 * Added `restrict_facets` function factory for use with `make_split_fun`
 * Exported previously internal `make_subset_expr` for use when constructing custom splitting behavior
 * Exported previously internal `splv_extra` and `splv_extra<-` accessors for getting and setting child-specific extra arguments on `SplitValue` objects.
 * Exported previously internal `value_expr` accessor for retrieving the subsetting expression from a `SplitValue` or `ValueWrapper` object.
 * The `.alt_df*` family of afun arguments now receive subsets of `df` when `alt_counts_df` is not specified in the `build_table` call; previously resulted in an error.

## rtables 0.6.15

### New Features
 * Allow table objects to have `round_type` instead of needing to specify on export #1040
 * New `obj_round_type` getter and setter methods.

## rtables 0.6.14

### New Features
 * Added Guided Tour section to the `pkgdown` site
 * Added vignette: Guided Tour (Intermediate)
 * Added vignette: Guided Tour (Intermediate) - Translating Shells To Layouts @gmbecker
 * Added vignette: Guided Tour (Intermediate) - Identifying Required Analysis Behavior @gmbecker
 * Added vignette: Guided Tour (Intermediate) - Identifying Required Faceting Behavior @gmbecker
 
## rtables 0.6.13

### New Features
 * All elements of a table's row structure are now guaranteed to be pathable. #1024 by @gmbecker
 * Direct siblings anywhere in a table's tree (row) structure are now guaranteed to have unique names, with a message if de-duplication (by adding "[i]" to duplicates) was required. #1024 by @gmbecker
 * Added `parent_name` argument to `split_rows_by*` and `analyze*` functions to manually control names of (and thus paths to) the subtables created. #1024 by @gmbecker
 * Added `tt_row_path_exists`, which determines whether a path exists within a table's row structure, optionally restricted to resolving to a particular type of node (row, table, elementary table). #1024 by @gmbecker
 * Added `tt_normalize_row_path` which resolves a path including the "*" wild card to all existing paths within a table, optionally restricted to resolving to a particular type. #1024 by @gmbecker
 * Added documentation of basic pathing concepts (`?pathing`) to the man page for the above functions.
 * Added new `pathing` vignette. @gmbecker
 * When `make_row_df` is called on a `VTableTree` the returned df now includes new `sect_div_from_path` and `self_section_div` columns. #1024 by @gmbecker
 * Added `section_div_info` convenience function which returns portions of `make_row_df`'s result relevant to section dividers. #1024 by @gmbecker
 * Added `section_div_at_path` and `section_div_at_path<-` for getting and setting section dividers for substructures within the table. The latter supports "*" wildcards for flexible usage. #1024 by @gmbecker
 * Documentation regarding section dividers (`?section_div`) updated and expanded. #1024 by @gmbecker
 * Updated `as_result_df` to "de-uniqify" names that were altered for pathability when determining group values in the result dataframe/ard. #1024 by @gmbecker
 * Warning given when `section_div<-` with `only_sep_sections = TRUE` more values than levels of nesting present is now more informative, and occurs regardless of whether `only_sep_sections` was set manually or automatically (`length(value) < nrow(tt)`). #1024 by @gmbecker
 
### Bug Fixes
 * `section_div<-` now works correctly on tables that include top level siblings in their row structure (e.g., when unnested structure is added via `nested = FALSE` or adding a row splitting after an `analyze` call). #1024 by @gmbecker
 * `section_div<-` with `only_sep_sections = FALSE` is now consistent regarding which value is set when `analyze` calls occur at different levels of nesting within the corresponding layout, particularly as top-level non-nested siblings. #1024 by @gmbecker
 * `section_div<-` no longer sets a section div on non-visible label rows when setting a section divider for a content row on the same group. #1024 by @gmbecker
 * `section_div<-` when given a full-length (`nrow(tt)`) vector now sets 'section dividers' on label rows and content rows correctly when both are visible for the same facet. #1024 by @gmbecker
 * Correctly exported `[` methods with signatures involving `character` and `missing`. @gmbecker
 * Updated path resolution logic for `[` methods to gracefully handle new sibling name de-duplication scheme. @gmbecker
 
### Miscellaneous
 * `subset_cols` generic and methods are now exported.
 * `has_force_pag` generic and methods are now exported.
 
## rtables 0.6.12

### New Features
 * Added `stat_string` to `as_result_df(make_ard = TRUE)` to preserve the original string representation of the statistics.
 * Added `add_tbl_name_split` to `as_result_df()` to handle split levels constituted by different table names.
 * Analysis and content functions can now accept `.alt_df_full` which will always be the full `alt_counts_df` data.frame.
 * Score and pruning functions can now optionally accept additional arguments passed to `sort_at_path` or `prune_table`, score functions can also accept `decreasing` to receive sort order.
 
### Bug Fixes
 * Fixed issue with `split_cols_by_multivar()` when having more than one value. Now `as_result_df(make_ard = TRUE)` adds a predefined split name for each of the `multivar` splits.
 * Fixed a bug with `tt_at_path()` caused by the impossibility to solve multiple branches with identical names. 
 * Fixed bug happening when format functions were changing the number of printed values. Now `as_result_df(make_ard = TRUE)` uses the cell values for `stat_strings` for these exceptions.
 * `section_div` argument to `analyze` no longer sometimes applies dividers between each generated row in some cases. by @gmbecker
 * Fixed bug in `[<-` causing information to be stripped from other cells if a new `rcell` is set within a table row.
 * Fixed a bug in `as_result_df(make_ard = TRUE)` when different columns had different amounts of `""` values.
 * Fixed bug in cases where `stat_name` is `character(0)` (`as_result_df(make_ard = TRUE)`).
 * Fixed a bug dropping information from tables when indexed with `integer()`, i.e. producing an empty table.
 
### Miscellaneous
 * Added handler `add_tbl_str_decimals = TRUE` to `...` into `as_result_df(make_ard = TRUE)` to add `stat_string` column for the 
 `ARD` output.
 * As `stat_string` are more fragile than default `as_result_df(make_ard = TRUE)` calculation and are in theory optional, a warning is thrown when errors arise and the `stat_string` column is not added.
 * Improved error messaging for cases where `tt_at_path` used a path based on row labels instead of row names.
 * Added more informative error message when `keep_split_levels()` is used to keep absent values.
 * Improved error message when selecting 0 columns from a table with `[`.
 * Added safe condition for `keep_split_levels()` when branch is empty `(character(0))`.

## rtables 0.6.11

### New Features
 * Initialized vignette about quality control outputs of `as_result_df()`.
 * Completed parameter `make_ard` output for single-line statistical outputs.
 * Added `stat_names` to `rcell()` to be used by `as_result_df(make_ard = TRUE)`.

### Miscellaneous
 * Split `docx` document generation to the new package [`rtables.officer`](https://github.com/insightsengineering/rtables.officer).
 * Refactored  `as_result_df()` parameters `as_strings` and `as_viewer` into `data_format = c("full_precision", "strings", "numeric")` following the same outputs.
 * Refactored `as_result_df()` to have a standard behavior, with all the relevant parameters, and a possibility to add personalized `spec`.
 * Removed `result_df_specs()`, because `as_result_df()` was a too shallow wrapper.
 * Merged behavior of  `as_result_df()` parameters `as_is` and `simplify` parameters to remove structural information.

### Bug Fixes
 * Fixed bug that was keeping indentation space characters in top left information when making a `flextable` from a `TableTree` object.
 * Fixed bug in `analyze` that was causing an error when passing a single `NA` value to the
`var_labels` parameter.
 * Fixed bugs for multiple `analyze` calls in `as_result_df`.

## rtables 0.6.10

### New Features
 * Added top left information handling (now bold and bottom aligned).
 * Added `section_properties_default()` function to define standard portrait properties for tables.
 * Added default theme for `.html` outputs.
 * Added parameter `bold_titles` to `tt_to_flextable()` to bold titles.
 * Now users can add more than one theme to `tt_to_flextable()`, and/or extend themes.
 
### Enhancements
 * Modified `reorder_split_levels()` to cover more edge cases and be more stringent in the allowed inputs.
 * Removed table tree `tt` input from `theme_docx_default()` and added code to handle row classes and number of columns internally.
 * Reworked padding and spacing in default theme `theme_docx_default()`.
 * Added parameter `bold_titles` to `tt_to_flextable()` to bold titles.

### Bug Fixes
 * Fixed `"\n"` newline issues in `as_html` by relying onto output devices for newline handling. Added `expand_newlines = FALSE` default to allow previous behavior.
 * `keep_split_levels()` throws now an error if the user requests to keep levels that are not present in data.
 * Fixed issue with removal of horizontal lines in `tt_as_flextable()` header when title was added.
 * Fixed multiple counts in header issue when exporting to `flextable`.
 * Fixed issue with empty cells `""` having larger imposed margins than filled cell. They are transformed into `" "` before rendering.
 * Fixed issue with borders appearing in `theme_docx_default()` when only one line of column names is present, but top left information is on multiple lines.

### Miscellaneous
 * Added option to change `sep = "\t"` and set other parameters via `...` parameter propagation in `export_as_tsv`.
 * Added developer's guide vignette. New materials are focused on printing methods, specifically `matrix_form` and `toString`.
 * Grouped split functions documentation into one page with precise descriptions of each function and relative examples.
 * Moved `simple_analysis` into utils file.
 * Added examples to `theme_docx_default()` showing how to extend the default theme.
 * Added the possibility to remove internal borders from label rows in `theme_html_default()`.
 * Split export functions into separate source files. Similarly for test files.

## rtables 0.6.9
### Miscellaneous
 * Update `col_counts` vignette wording, as CRAN `macOS` check failed. Raised the issue with the R-core team already. 

## rtables 0.6.8
### New Features
 * Add support for `truetype` fonts based on `formatters` version `>= 0.5.8`. Nearly all functions related to pagination or export now accept `fontspec` argument and pass it around accordingly, by @gmbecker.
 * Core splitting machinery can now be overridden in column space via `make_split_fun` provided that `core_split` associates the generated facets with subsetting expressions. Subsetting expressions remain unnecessary for splits in row space. By @gmbecker.
 * ValueWrapper objects now carry around subsetting expressions for use during tabulation, by @gmbecker.
 * `make_split_res`, `add_to_split_result` now accept a list of subsetting expressions which will be attached to the values, by @gmbecker.
 * New `value_expr` internal getter and setter methods, by @gmbecker.
 * All tables are now guaranteed to have fully path-traversable column structures (all facets in column space uniquely reachable via pathing) @gmbecker.
 * Display of higher order (non-leaf) column counts is now supported (#135) @gmbecker.
 * Column count visibility and format can be set independently for each block of sibling facets (#752) @gmbecker.
 * `split_cols_by*` functions now accept `show_colcounts` and `colcount_format` arguments.
 * New (column-) path based `colcount_visible` getter and setter for changing column count visibility in an already built table @gmbecker.
 * New (column-) path based `facet_colcount` getter and setter column count value at arbitrary point in column structure of built table @gmbecker.
 * New `facet_colcounts_visible` setter to conveniently set the column count visibility of a set of sibling facets in column space
 * New `rm_all_colcounts` convenience function for turning off visibility all column counts throughout the column structure @gmbecker.
 
### Bug Fixes
 * Fixed bug in `as_html` preventing indentation from being applied in `Viewer` output.
 * `col_counts<-` and `col_total<-` methods now explicitly convert `value` to integer, by @gmbecker.
 * `col_gap` is now respected in `nlines` row methods, and thus by `make_row_df`, by @gmbecker.

### Miscellaneous
 * Added `lifecycle` badge files for deprecated documentation.
 * Deprecated the `gap` and `check_headers` arguments to `rbindl_rtables` using `lifecycle`.

## rtables 0.6.7
### New Features
 * Added `top_level_section_div` for `basic_table` to set section dividers for top level rows.
 * Added `keep_label_rows` to `as_result_df` to have these lines visible.
 * `sort_at_path` now gives informative error messages when the given path does not exist.

### Bug Fixes
 * Fixed `rlistings` decoration (e.g. titles and footers) expansion when there are new lines. Moved relevant handling from `rtables`' `matrix_form` function to `formatters`' dedicated `mform_handle_newlines` function.
 * Fixed issue with `rtables_root` not being removed when using `as_result_df`.
 * Fixed edge case bug in `as_result_df` where rows of the table have only `"root"` as path index.
 * Fixed `sort_at_path` pathing to ignore leading `"root"` element (regardless of actual root element name) to match current `tt_at_path` behavior.
 * Fixed `section_div` for analysis of multiple variables (`AnalyzeMultiVars`).
 * Fixed mismatch between indentation declared in row info (`mf_rinfo(mf)`) and actual selected indentation from `matrix_form(mf, indent_rownames = FALSE)`.
 * Fixed bug in `as_html` preventing indentation from being applied in `Viewer` output.
 * `col_counts<-` and `col_total<-` methods now explicitly convert `value` to integer, by @gmbecker.
 * `col_gap` is now respected in `nlines` row methods, and thus by `make_row_df`, by @gmbecker.
 * Updated `as_html` to accommodate `\n` characters.

### Miscellaneous
 * Removed deprecated functions `add_analyzed_var` and `trim_zero_rows`.

## rtables 0.6.6
### New Features
 * Removed `ref_group` reordering in column splits so not to change the order.
 * Added `bold` argument to `as_html` to bold specified elements, and `header_sep_line`
   argument to print a horizontal line under the table header in rendered HTML output.
 * Duplicate referential footnotes are consolidated when tables are rendered.
 * Section divisors can be set for analysis rows.
 * Added setter and getter for section dividers (`section_div` and `section_div<-`). They also accept
   split section structure assignment.
 * Added `header_section_div` setters and getters for layout and table objects along with
   related `basic_table` parameter.
 * Added `na_str` argument to `analyze_colvars` to set custom string to print in place of missing values.
 * Added flat `data.frame` outputs for `as_result_df()` via flag parameters `as_viewer`, `as_strings`, and
   `expand_colnames`.
 * Migrated `export_as_pdf` function to `formatters`.

### Bug Fixes
 * Fixed a bug that was failing when wrapping and section dividers were used at the same time.
 * Fixed a bug in `as_result_df` causing misalignment of column names.
 * Fixed a bug that was not allowing path indexing as `row_paths()` was giving a different path due to it being made of
   named values.
 * Fixed a bug in `as_result_df` when called on tables with less than 3 rows.

### Miscellaneous
 * Applied `styler` and resolved package lint. Changed default indentation from 4 spaces to 2.
 * Added Developer Guide with Debugging, Split Machinery, and Tabulation sections.
 * Whitespace is not trimmed when rendering tables with `as_html`.
 * Started deprecation cycle for `col_fnotes_here` to be replaced with `col_footnotes`.
 * Exported `section_div` methods now have a dedicated documentation page that is visible to users.
 * When tables are exported as `txt`, they preserve the horizontal separator of the table.
 * Added imports on `stringi` and `checkmate` as they are fundamental packages for string handling and
   argument checking.
 * Updated introduction vignette and split it into two. Section on introspecting tables is now located in a separate vignette.

## rtables 0.6.5
### New Features
 * Added support for white spaces in all labels and text by redesigning of wrapping functions in `formatters`.
 * Added support for new line characters across rtables (titles, column names, row names, footers, and `na_str`).
 * Modified top left information vertical alignment to stay at the bottom of the header.

### Bug Fixes
 * Fixed a bug causing `Viewer` and `as_html` to fail when new line characters were added.

### Miscellaneous
 * Added slide decks for advanced training as internal files.

## rtables 0.6.4
### New Features
 * Added support for `.docx` exports with `export_as_docx()`.
 * Expanded support for `flextable` customization with theme function specific for word documents (`theme_docx_default()`).

### Bug Fixes
* Fixed bug causing all-`NA` rows to be included in every `.df_row` split.

### Miscellaneous
 * Specified minimal version of package dependencies.

## rtables 0.6.3
### New Features
 * Analysis functions (`cfun/afun`) can use new parameters to extend analysis calculations: `.alt_df_row` and `.alt_df` give access to `alt_counts_df` across columns, while `.all_col_exprs` and `.all_col_counts` contains global information about all columns.
 * Binding objects via `rbind` will retain titles/footer information if identical in all objects or only present in the first object being bound.

### Enhancements
 * Analysis functions (`cfun/afun`) have more information about current column split; `.spl_context` has access to `cur_col_id`, `cur_col_expr`, `cur_col_split`, and `cur_col_split_val`.
 * Added vignette on exploratory analysis with `qtable`.
 * Extracted `qtable_layout` from `qtable`.

### Bug Fixes
 * Page-by splits which generate zero facets (and thus tables which would have zero pages when rendered) now throw an informative error at table build time.
 * Removed superfluous warning which arose for custom split functions when reference group is is set (https://github.com/insightsengineering/rtables/issues/707#issuecomment-1678810598).
 * Fixed `qtable` labeling via `row_labels` ([#698](https://github.com/insightsengineering/rtables/issues/698)).
 * Error catching and test coverage for cases where `alt_counts_df` presents different splits from `df`.

### Miscellaneous
 * Cleaned up spelling in documentation ([#685](https://github.com/insightsengineering/rtables/issues/685))
 * Custom appearance vignette updated with decimal alignment support.
 * Alignment checks have been moved into `formatters`: `formatters::check_aligns` superseded internal function `chk_rtables_align` and `formatters::list_valid_aligns` superseded `rtables_aligns`.

## rtables 0.6.2
 * Fixed major regressions for `page_by` machinery caused by migration to `formatters` 0.5.1 pagination framework.
 * Fixed `page_by` labels become missing when only one level exist in the `split_rows_by`.
 * Fixed a bug when dropping `var` levels but not `lblvar` levels.
 * Added checks to catch bad labels (with {}) and throw informative error.
 * Added `qtable` function to create a table with a single top-level structure in both row and column dimensions  involving faceting by 0 or more variables in each.
 * Added `as_result_df` function to flatten a table into a dataframe.
 * Added `sanitize_table_struct`, `validate_table_struct`, `find_degen_struct` to support degenerative table rendering.

## rtables 0.6.1
 * Improved resilience of pagination machinery (`paginate_table`) by generalizing parameters' defaults (`cpp`, `lpp`, and `font_size`).
 * Moved `export_as_txt` to `formatters`. Added to reexports.
 * Migrated `export_as_rtf` to `formatters`. Not re-exported.
 * add `r2rtf` to Suggests
 * pagination logic has been migrated completely (excepting page_by splits) to `formatters` and is now invoked from there. paginate_table remains as a convenience function.
 * Removed warning in `str` method when called upon table objects.
 * Provide `str` method for `VTableTree` objects with a default `max.level` of 3, as the infinite default from base is not
   useful or informative.
 * default `font_size` value is now `8` across pagination and export machinery
 * `margins` argument in pagination and export machinery now (correctly) interpreted as inches. This change is inherited from `formatters`
 * `lpp` and `cpp` now default to `NA_integer_`, which is interpreted as inferring their value from the physical page size specified.
 * Horizontal pagination now occurs by default due to the above (because there is a default page type - `"letter"`. Pagination can still be turned off in either direction by setting `l/cpp` to `NULL` explicitly.
 * Referential footnotes now have both a `symbol` and an `index`. Messages associated with symbols will only appear once per page in the footer materials regardless of number of elements referenced in the page with that symbol. Matches and inherits from changes in `formatters`
 * Started deprecation cycle for `trim_zero_rows`.
 * Fixed bug occurring when extracting `cell_values` after sorting.
 * Removed deprecated function `vpaginate_table`.
 * Added examples and details for `sort_at_path`.
 * Added `split_label` to function `split_rows_by_multivar` and `extra_args` to function `split_cols_by_multivar`.
 * Added `split_rows_by_multivar` documentation.

## rtables 0.6.0
 * added `make_split_fun` function for creation of custom split functions
 * `basic_table` now accepts `colcount_format`
 * 2d formats are now allowed for column counts provided one element is a percent, which will be automatically set to 100%
 * `spl_context` now includes root row in row-split contexts.
 * Added vignette on format precedence
 * Added vignette on split functions
 * Added custom appearance vignette
 * Significant overhaul of sorting vignette
 * extended and clarified documentation
 * `export_as_pdf` now correctly takes `margins` into account when calculating `lpp` and `cpp` from page size.
 * exporters now pass down non-default `colwidths` values correctly
 * `nlines` `TableRow` method (used for both rows and column label extent in pagination) now correctly handles column spanning
 * pagination with `verbose = TRUE` now includes original and adjusted lines-per page information
 * `cont_n_allcols` and `cont_n_onecol` score functions now throw errors when they are applied to subtables that
   have no content table, instead of the previously returned `NA`
 * `sort_at_path` now emits an informative error message when score functions fail.
 * `paginate_table` now accepts `colwidths` and paginates assuming column label and
   cell values are wrapped to those widths.
 * `make_row_df` now accepts `colwidths` and calculates row extents assuming cell values
   are wrapped to those widths
 * `nlines` `TableRow` method now uses provided `colwidths` to assume cell-value wrapping
 * `export_to_txt` now automatically paginates when any form of page dimension is provided
   (previously the default was unconditionally not paginating).
 * Versioned dependency on `formatters` increased to `>=0.4.0`

## rtables 0.5.3
 * `[<-` now treats character `i` and `j` values as paths, the same as `[` always has.
 * `[<-` `CellValue` method now preserves `CellValue` attributes (e.g., format)
 * More detailed subsetting and modification vignette
 * `nlines` methods now accept both `colwidths` and `max_width`
 * `max_width` is now used during pagination to determine lines taken up by referential footnotes
 * `make_col_df` now accepts `colwidths` argument, and can be called directly on `InstantiatedColumnInfo` objects
 * versioned dependency on `formatters` increase to `>0.3.3.12`
 * word wrapping title/footer materials no longer fails in the presence of `""` values.
 * versioned dependency on `formatters` increase to `>0.3.3.11`
 * `paginate_table` now accepts `tf_wrap` and `max_width` and respects title/footer word wrapping when present
 * export functions now accepts `tf_wrap` and `max_width` and use them in both pagination (when turned on) *and* `toString` when used (pdf, txt exporters).
 * versioned dependency on `formatters` increased to `>0.3.3.10`
 * `export_as_pdf` now accepts standard page/font size parameters
 * original parameters (`width`, `height`, `fontsize` are soft deprecated (no warning) and
   will be fully deprecated and then removed in the future.
 * `toString` method for `VTableTree` now accepts `tf_wrap` and `max_width`
 * `export_as_txt` and `export_as_pdf` now accept `cpp`, as well as `tf_wrap` and `max_width` and
    default to `tf_wrap` being on and `max_width = cpp` when `cpp` is non-NULL.
 * `basic_table` now accepts `inset` argument for declaring table inset
 * Table and Layout object classes now have a `table_inset` slot, with accessor functions.
 * `matrix_form` method for `VTableTree` sets `table_inset` value
 * Increase versioned dependency on `formatters` to `>0.3.3.5` for `table_inset` support
 * Use `exact=TRUE` in all calls to `attr` within access functions
 * Increase versioned dependency on `formatters` to `>0.3.3.4`
 * layouting instructions now accept `na_str` argument, which specifies `na` string with the same
   inheritance rules as formats
 * (pre-data) Split and (post tabulation) Table/row S4 classes now carry around `na_str` information
 * Increase versioned dependency on `formatters` to `>= 0.3.3.3` for support of `na_str`s with `NA_character_` values
 * `paginate_table` now takes page dimension and font information and uses `formatters::page_lcpp` to
   calculate `lpp` and `cpp` automatically when those are provided.
 * Increase versioned dependency on `formatters` to `>= 0.3.3.2` for `page_lcpp`

## rtables 0.5.2
 * `paginate_table` now accepts `cpp` and will perform vertical pagination when it is non-null
 * `vpaginate_table` is now deprecated
 * Increased versioned dependency on `formatters` to `>=0.3.2.4`

## rtables 0.5.1.5
 * Support for section dividers (`section_div` argument in `split_rows_by*` function)
 * Updated versioned dependency on `formatters` to `>=0.3.2.3`
 * Equivalent split functions with different enclosing environments (e.g., 2 identical calls to `add_combo_levels` [#340](https://github.com/insightsengineering/rtables/issues/304)) no longer block `rbind`ing
 * Fixed various documentation bugs where description section was being added to header.

## rtables 0.5.1.4
 * empty level check for splitting variables reinstated.

## rtables 0.5.1.3
 * Throw informative error messages when custom analysis, content or split functions fail ([#329](https://github.com/insightsengineering/rtables/issues/329))

## rtables 0.5.1.2
 * empty level check for splitting variables temporarily removed. It is very likely to be reinstated in a future release.

## rtables 0.5.1.1
 * `col_counts` getter and setter now accept `path` argument.
 * empty levels of a splitting variable now result in an informative error message (character and factor cases).
 * fixed bug in handling of column extra arguments that was preventing `cbind`ing tables from working correctly ([#324]](https://github.com/insightsengineering/rtables/issues/324))

## rtables 0.5.1
 * empty factor levels are now *not* dropped for column splits when ref_group is set ([#323](https://github.com/insightsengineering/rtables/issues/323))
 * `linesep` argument to `toString` and related functions renamed to `hsep`
 * Increase versioned dependency on `formatters` to `>=0.3.0`
 * Default "line separator" between header and body now falls back to "-" non-UTF charset locales.
 * New `hsep` argument to `build_table` which sets the horizontal separator for the constructed table (and subtables thereof)
 * New `horizontal_sep` and `horizontal_sep<-` accessors for constructed tables, the latter of which is mandatorily recursive.
 * `split_rows_by(var, child_labels="hidden")` no longer removes the structural subtable corresponding to levels of `var` ([#314](https://github.com/insightsengineering/rtables/issues/314))

## rtables 0.5.0
 * `formatable` dependency renamed to `formatters` for suitability of release to CRAN
 * Update versioned dependency of `formatters` (previously `formatable`) to `>=0.2.0`

## rtables 0.4.1.0004
 * Fix bug when function format combined with NULL `cfun` caused error ([#307](https://github.com/insightsengineering/rtables/issues/307))
 * Fix bug in `path_enriched_df` (which powers `tsv` export), related to ([#308](https://github.com/insightsengineering/rtables/issues/308))

## rtables 0.4.1.0002
 * added `table_shell` to display shell of table with formats

## rtables 0.4.1.0001
 * added `linesep` argument to `toString` to specify a character to create the line separator. Previously we used the en dash as the line separator character, now we changed the default to the em dash reducing the gap between the dash line elements.

## rtables 0.4.0
 * Initializing layouts with `NULL` is now deprecated
 * `insert_rrow` is deprecated in favor of new `insert_row_at_path` and `label_at_path<-` functions
 * split and analysis/content functions can now depend on values of splits they are nested inside by accepting and using the new `.spl_context` optional argument
 * new `trim_levels_to_map` split function  for dictating exact combinations of values which should appear across splits
 * `value_formats` function now exported which returns/displays the effective formats of all cells in a table
 * `compare_rtables` is now *much* faster for tables with many cells
 * `compare_rtables` now accepts `structure` argument which adds comparison of structure (by way of row- and column-path positions)
 * new `tt_to_flextable` coercion function
 * new `export_as_pdf` exporter function
 * `value_at` and `cell_values` functions now have methods for `TableRow` objects making them usable in sorting/pruning functions

## rtables 0.3.8.9001
 * new `trim_levels_to_map` split function based on `[@wwojciech](https://github.com/wwojciech)`'s work in [#203](https://github.com/insightsengineering/rtables/issues/203)
 * support for column referential footnotes
 * support for adding footnotes to existing table via `fnotes_at_path<-` function
 * `trim_levels_in_group` now trims empty levels of outer (split) variable by default
 * `value_at` and `cell_values` now work for `tablerow` objects
 * Fixed `as_html` bug in `multivar` split columns case
 * Fixed pagination off-by-one error


## rtables 0.3.8.9000

## rtables 0.3.8
 * Add experimental support for newlines in column names, row labels, and cell values (not supported in top-left annotations)
 * `as_html` refactored to support newlines while respecting table structure
 * self_extent column of `df` returned by `make_row_df` now reflects extent *in lines*, thus will return larger values if the row-label or any cell values contain newlines.
 * Fix bug where tables output using `as_html` (or viewed in `Viewer`) were missing the table class attribute ([#194](https://github.com/insightsengineering/rtables/issues/194))
 * inserting a `DataRow` with incorrect number of columns is now an error ([#199](https://github.com/insightsengineering/rtables/issues/199))
 * Referential footer machinery now works in `colspan` case.
 * Fix extraneous footnote attribute bug ([#198](https://github.com/insightsengineering/rtables/issues/198))
 * Fix max -Inf warning when content rows appear at positions whose children have 0 visible rows ([#200](https://github.com/insightsengineering/rtables/issues/200))
 * Resync `NEWS.md` file
 * Introduce titles and footnotes
 * Support automatic population of top-left
 * Introduce referential footnote support for cells and row labels
 * Added `vars_in_layout` to list (explicitly named only) variables used in a layout
 * Fix column label ordering bug when value label variable is a factor ([#173](https://github.com/insightsengineering/rtables/issues/173))

## rtables 0.3.7

Synchronize release with GitHub commit `sha`.

## rtables 0.3.6

Documentation revisions as requested by CRAN. No change to package code.

## rtables 0.3.5

Documentation-text only changes to introduction vignette to pass CRAN's URL checks. All package, example, test, and vignette code fully identical to that in tagged GitHub release 0.3.4

## rtables 0.3.4

Minor changes to the 0.3.3 version in order to submit `rtables` to CRAN.

## rtables 0.3.3

This version completely refactors the `rtables` package. We do provide a backwards compatibility layer with the
`rtable`, `rcell`, `rrow`, `rheader`, and `rtabulate` family of functions. However the table data structure and main
tabulation framework have changed. We provide extensive documentation in the manuals `help(package = "rtables")` and
vignettes `vignette(package = "rtables")` of the package.

The changes to `rtables` have been undertaken to better meet the requirements of creating and analyzing & reporting
tables in the context of clinical trials.


## rtables 0.3.2.17.9046

* `make_afun` now `force()`s all customization arguments immediately, which prevents problems when called within loop/`lapply` constructs.

## rtables 0.3.2.17.9045

* Tabulation machinery no longer removes NAs mandatorily in some cases, including `multivar` column splits
* `analyze_colvars`'s `inclNAs` argument now respected.

## rtables 0.3.2.17.9044

* Fix indent modifier propagation during tabulation
* Fix indent calculation in `make_pagdf`
* Add significant testing to ensure `make_pagdf` indent calculation remains correct

## rtables 0.3.2.17.9043

* Rework how reference columns are handled so analyses which use `.in_ref_col` and `.ref_group` work correctly when custom splitting is used (including the provided combination-levels mechanism)

## rtables 0.3.2.17.9042

* Fix naming/pathing for columns in `multivar` case (split itself now has default name `"multivars"`)
* Fix labeling bug when same variable appears multiple times in `MultiVarSplit` with different associated levels


## rtables 0.3.2.17.9041

* Allow single variable to be used within `split_cols_by_multivar`
* Various removal of defunct

## rtables 0.3.2.17.9040

* Fix regression caused by 0.3.2.17.9039 where column split values were displayed by name rather than label.

## rtables 0.3.2.17.9039

* Fix bug in display of column information when column structure is not symmetric, as with recursive `cbind`s.

## rtables 0.3.2.17.9036

* Fixed bug in row subsetting when table has only content rows.
* Basic compare_rtables function now works as in previous versions, no awareness of row or column structure.

## rtables 0.3.2.17.9036

* `summarize_row_groups` can now accept a list of functions for the `cfun` argument as `analyze_colvars` does.

## rtables 0.3.2.17.9035

* Fix bug unearthed by change in 0.3.2.17.9034 where cell formats not retained during column subsetting

## rtables 0.3.2.17.9034

* Fix internal `value_formats` accessor so it operates on `CellValue`s rather than the raw contained values (thus always returning NULL)
* `rrow` constructor no longer interprets cell formats a row format when they are the same across all cells. Fixes bug in  "correct way" code discussed in [#112](https://github.com/insightsengineering/rtables/issues/112)

## rtables 0.3.2.17.9033

* Interpret .formats in `in_rows` as *cell* formats rather than row formats.

## rtables 0.3.2.17.9031

* `cbind_rtables` can now take more than 2 tables.

## rtables 0.3.2.17.9029

* Fix issue underlying spurious length-mismatch warning in some cases when using `analyze_colvars`

## rtables 0.3.2.17.9028

* `analyze_colvars` now takes and adheres to `inclNAs` argument

## rtables 0.3.2.17.9027

* issues with no news:

## rtables 0.1.7

* added format `xx.xx (xx.xx - xx.xx)` and `x.xxxx | (<0.0001)`

## rtables 0.1.6

* Minor changes.

## rtables 0.1.5

* Changed testing approach to fit internal pipelines.

## rtables 0.1.4

* Replaced dots to underscore in class checking functions.

## rtables 0.1.3

* `col_by` in `rtabulate` now accepts matrices:
  - `col_by_to_matrix`, `col_by_to_factor`, `by_factor_to_matrix`.
  - `by_add_total`, `by_all`, `by_combine`, `by_quartile`, `by_compare_subset`,  `by_hierarchical`, `by_drop_empty_cols`.

* New utility functions to deal with variable labels:
  - `label`, `var_labels<-`, `var_labels`, `var_labels_remove`, `var_relabel`, `with_label`.

* Other new functions:
  - `cbing_rtables`.
  - `empty_rtables`, `is_empty_rtable`, `is_non_empty_rtable`, `is_rtable`.
  - `header_indent`, `header_indent<-`, `header_row.names`, `header_row.names<-`.
  - `insert_rrow`.

## rtables 0.1.2

* `rbind.rtable` now supports binding rtables with rows, e.g. `rbind(tbl1, rrow(), tbl2)` or `rbind(tbl1, rrow("row name"), tbl2)`.
* `rbindl_rtables` supports `NULL` objects in the list (except for the first element).
* Add `indent` function.
* `header_add_N` deals gracefully with `NULL` objects.

## rtables 0.1.1

* `rtablulate` family of functions do not support the `row_*_data_args` arguments anymore. Instead, the `col_wise_args` argument is introduced.
* Functions `order_rrows`, `sort_rrows`, `order_rtables`, and `sort_rtables` are introduced.
* Prevent `rtables` from being unlisted with `unlist.rtables`.


## rtables 0.1.0.6

* `Viewer` now also accepts objects of class `shiny.tag` (defined in package `htmltools`).
* `as.html` accepts `class.table`, `class.tr`, `class.th`, and `class.td` as an argument.

## rtables 0.1.0.5

* Added `sprintf_format` for formatting `rcell`s (thanks to Doug Kelkhoff for the suggestion).
* Added `"(N=xx)"` and `">999.9"` format labels.
* `rtabulate` has now an argument `col_N` and the function `col_N()`.

## rtables 0.1.0

* Version `0.1.0` is a major re-design with lots of internal refactoring and the following API changes:
  - Redesign: `rtable` has now `header` argument instead of `col.names`. A `header` can be created with `rheader` and is a collection of `rrow`s. If `header` is set to `c("A", "B")` then `rtable` will create the `rheader` with a single `rrow`  and by setting `row.name` to `NULL`.
  - `header` and `header<-` function added.
  - Renamed `get_rcell_formats` to `list_rcell_format_labels`.
  - If `rcell` format is `NULL` then the cell content will be converted to a string with `paste(as.character(x), collapse = ', ')`.
  - Accessor `[i,]` works now to subset a table.
  - `rbind` method for rtables.
  - `row.names<-.rtable` method.
  - `rtabulate` added for creating tables.
  - `indented_row.names` function added.

## rtables 0.0.1

* Initial public release
