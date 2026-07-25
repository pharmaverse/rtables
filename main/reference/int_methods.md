# Combine `SplitVector` objects

These are internal methods that are documented only to satisfy
`R CMD check`. End users should pay no attention to this documentation.

## Usage

``` r
# S4 method for class 'SplitVector'
c(x, ...)

split_rows(lyt = NULL, spl, pos, cmpnd_fun = AnalyzeMultiVars)

# S4 method for class 'NULL'
split_rows(lyt = NULL, spl, pos, cmpnd_fun = AnalyzeMultiVars)

# S4 method for class 'PreDataRowLayout'
split_rows(lyt = NULL, spl, pos, cmpnd_fun = AnalyzeMultiVars)

# S4 method for class 'SplitVector'
split_rows(lyt = NULL, spl, pos, cmpnd_fun = AnalyzeMultiVars)

# S4 method for class 'PreDataTableLayouts'
split_rows(lyt, spl, pos)

# S4 method for class 'ANY'
split_rows(lyt, spl, pos)

cmpnd_last_rowsplit(lyt, spl, constructor)

# S4 method for class 'NULL'
cmpnd_last_rowsplit(lyt, spl, constructor)

# S4 method for class 'PreDataRowLayout'
cmpnd_last_rowsplit(lyt, spl, constructor)

# S4 method for class 'SplitVector'
cmpnd_last_rowsplit(lyt, spl, constructor)

# S4 method for class 'PreDataTableLayouts'
cmpnd_last_rowsplit(lyt, spl, constructor)

# S4 method for class 'ANY'
cmpnd_last_rowsplit(lyt, spl, constructor)

split_cols(lyt = NULL, spl, pos)

# S4 method for class 'NULL'
split_cols(lyt = NULL, spl, pos)

# S4 method for class 'PreDataColLayout'
split_cols(lyt = NULL, spl, pos)

# S4 method for class 'SplitVector'
split_cols(lyt = NULL, spl, pos)

# S4 method for class 'PreDataTableLayouts'
split_cols(lyt = NULL, spl, pos)

# S4 method for class 'ANY'
split_cols(lyt = NULL, spl, pos)

.add_row_summary(
  lyt,
  label,
  cfun,
  child_labels = c("default", "visible", "hidden"),
  cformat = NULL,
  cna_str = "-",
  indent_mod = 0L,
  cvar = "",
  extra_args = list()
)

# S4 method for class 'PreDataTableLayouts'
.add_row_summary(
  lyt,
  label,
  cfun,
  child_labels = c("default", "visible", "hidden"),
  cformat = NULL,
  cna_str = "-",
  indent_mod = 0L,
  cvar = "",
  extra_args = list()
)

# S4 method for class 'PreDataRowLayout'
.add_row_summary(
  lyt,
  label,
  cfun,
  child_labels = c("default", "visible", "hidden"),
  cformat = NULL,
  cna_str = "-",
  indent_mod = 0L,
  cvar = "",
  extra_args = list()
)

# S4 method for class 'SplitVector'
.add_row_summary(
  lyt,
  label,
  cfun,
  child_labels = c("default", "visible", "hidden"),
  cformat = NULL,
  cna_str = "-",
  indent_mod = 0L,
  cvar = "",
  extra_args = list()
)

# S4 method for class 'Split'
.add_row_summary(
  lyt,
  label,
  cfun,
  child_labels = c("default", "visible", "hidden"),
  cformat = NULL,
  cna_str = "-",
  indent_mod = 0L,
  cvar = "",
  extra_args = list()
)

fix_dyncuts(spl, df)

# S4 method for class 'Split'
fix_dyncuts(spl, df)

# S4 method for class 'VarDynCutSplit'
fix_dyncuts(spl, df)

# S4 method for class 'VTableTree'
fix_dyncuts(spl, df)

# S4 method for class 'PreDataRowLayout'
fix_dyncuts(spl, df)

# S4 method for class 'PreDataColLayout'
fix_dyncuts(spl, df)

# S4 method for class 'SplitVector'
fix_dyncuts(spl, df)

# S4 method for class 'PreDataTableLayouts'
fix_dyncuts(spl, df)

summarize_rows_inner(obj, depth = 0, indent = 0)

# S4 method for class 'TableTree'
summarize_rows_inner(obj, depth = 0, indent = 0)

table_structure_inner(obj, depth = 0, indent = 0, print_indent = 0)

str(object, ...)

# S4 method for class 'VTableTree'
str(object, max.level = 3L, ...)

# S4 method for class 'TableTree'
table_structure_inner(obj, depth = 0, indent = 0, print_indent = 0)

# S4 method for class 'ElementaryTable'
table_structure_inner(obj, depth = 0, indent = 0, print_indent = 0)

# S4 method for class 'TableRow'
table_structure_inner(obj, depth = 0, indent = 0, print_indent = 0)

# S4 method for class 'LabelRow'
table_structure_inner(obj, depth = 0, indent = 0, print_indent = 0)

# S4 method for class 'TableRow'
nrow(x)

# S4 method for class 'TableRow'
ncol(x)

# S4 method for class 'LabelRow'
ncol(x)

# S4 method for class 'InstantiatedColumnInfo'
ncol(x)

# S4 method for class 'VTree'
tree_children(x)

# S4 method for class 'VTableTree'
tree_children(x)

# S4 method for class 'ANY'
tree_children(x)

# S4 method for class 'VTree'
tree_children(x) <- value

# S4 method for class 'VTableTree'
tree_children(x) <- value

# S4 method for class 'TableTree'
content_table(obj)

# S4 method for class 'ANY'
content_table(obj)

# S4 method for class 'TableTree,ElementaryTable'
content_table(obj) <- value

next_rpos(obj, nested = TRUE, for_analyze = FALSE)

# S4 method for class 'PreDataTableLayouts'
next_rpos(obj, nested = TRUE, for_analyze = FALSE)

# S4 method for class 'PreDataRowLayout'
next_rpos(obj, nested = TRUE, for_analyze = FALSE)

# S4 method for class 'ANY'
next_rpos(obj, nested)

next_cpos(obj, nested = TRUE)

# S4 method for class 'PreDataTableLayouts'
next_cpos(obj, nested = TRUE)

# S4 method for class 'PreDataColLayout'
next_cpos(obj, nested = TRUE)

# S4 method for class 'ANY'
next_cpos(obj, nested = TRUE)

last_rowsplit(obj)

# S4 method for class 'NULL'
last_rowsplit(obj)

# S4 method for class 'SplitVector'
last_rowsplit(obj)

# S4 method for class 'PreDataRowLayout'
last_rowsplit(obj)

# S4 method for class 'PreDataTableLayouts'
last_rowsplit(obj)

rlayout(obj)

# S4 method for class 'PreDataTableLayouts'
rlayout(obj)

# S4 method for class 'ANY'
rlayout(obj)

rlayout(object) <- value

# S4 method for class 'PreDataTableLayouts'
rlayout(object) <- value

tree_pos(obj)

# S4 method for class 'VLayoutNode'
tree_pos(obj)

pos_subset(obj)

# S4 method for class 'TreePos'
pos_subset(obj)

tree_pos(obj) <- value

# S4 method for class 'VLayoutNode'
tree_pos(obj) <- value

# S4 method for class 'VLayoutNode'
pos_subset(obj)

pos_splits(obj)

# S4 method for class 'TreePos'
pos_splits(obj)

# S4 method for class 'VLayoutNode'
pos_splits(obj)

pos_splits(obj) <- value

# S4 method for class 'TreePos'
pos_splits(obj) <- value

# S4 method for class 'VLayoutNode'
pos_splits(obj) <- value

pos_splvals(obj)

# S4 method for class 'TreePos'
pos_splvals(obj)

# S4 method for class 'VLayoutNode'
pos_splvals(obj)

pos_splvals(obj) <- value

# S4 method for class 'TreePos'
pos_splvals(obj) <- value

# S4 method for class 'VLayoutNode'
pos_splvals(obj) <- value

pos_splval_labels(obj)

# S4 method for class 'TreePos'
pos_splval_labels(obj)

spl_payload(obj)

# S4 method for class 'Split'
spl_payload(obj)

spl_payload(obj) <- value

# S4 method for class 'Split'
spl_payload(obj) <- value

spl_label_var(obj)

# S4 method for class 'VarLevelSplit'
spl_label_var(obj)

# S4 method for class 'Split'
spl_label_var(obj)

spl_formats_var(obj)

# S4 method for class 'VAnalyzeSplit'
spl_formats_var(obj)

spl_na_strs_var(obj)

# S4 method for class 'VAnalyzeSplit'
spl_na_strs_var(obj)

tt_labelrow(obj)

# S4 method for class 'VTableTree'
tt_labelrow(obj)

tt_labelrow(obj) <- value

# S4 method for class 'VTableTree,LabelRow'
tt_labelrow(obj) <- value

labelrow_visible(obj)

# S4 method for class 'VTableTree'
labelrow_visible(obj)

# S4 method for class 'LabelRow'
labelrow_visible(obj)

# S4 method for class 'VAnalyzeSplit'
labelrow_visible(obj)

labelrow_visible(obj) <- value

# S4 method for class 'VTableTree'
labelrow_visible(obj) <- value

# S4 method for class 'LabelRow'
labelrow_visible(obj) <- value

# S4 method for class 'VAnalyzeSplit'
labelrow_visible(obj) <- value

label_kids(spl)

# S4 method for class 'Split'
label_kids(spl)

label_kids(spl) <- value

# S4 method for class 'Split,character'
label_kids(spl) <- value

# S4 method for class 'Split,logical'
label_kids(spl) <- value

vis_label(spl)

# S4 method for class 'Split'
vis_label(spl)

label_position(spl)

# S4 method for class 'Split'
label_position(spl)

# S4 method for class 'VAnalyzeSplit'
label_position(spl)

label_position(spl) <- value

# S4 method for class 'Split'
label_position(spl) <- value

content_fun(obj)

# S4 method for class 'Split'
content_fun(obj)

content_fun(object) <- value

# S4 method for class 'Split'
content_fun(object) <- value

analysis_fun(obj)

# S4 method for class 'AnalyzeVarSplit'
analysis_fun(obj)

# S4 method for class 'AnalyzeColVarSplit'
analysis_fun(obj)

split_fun(obj)

# S4 method for class 'CustomizableSplit'
split_fun(obj)

# S4 method for class 'Split'
split_fun(obj)

split_fun(obj) <- value

# S4 method for class 'CustomizableSplit'
split_fun(obj) <- value

# S4 method for class 'Split'
split_fun(obj) <- value

content_extra_args(obj)

# S4 method for class 'Split'
content_extra_args(obj)

content_extra_args(object) <- value

# S4 method for class 'Split'
content_extra_args(object) <- value

content_var(obj)

# S4 method for class 'Split'
content_var(obj)

content_var(object) <- value

# S4 method for class 'Split'
content_var(object) <- value

avar_inclNAs(obj)

# S4 method for class 'VAnalyzeSplit'
avar_inclNAs(obj)

avar_inclNAs(obj) <- value

# S4 method for class 'VAnalyzeSplit'
avar_inclNAs(obj) <- value

spl_labelvar(obj)

# S4 method for class 'VarLevelSplit'
spl_labelvar(obj)

spl_child_order(obj)

# S4 method for class 'VarLevelSplit'
spl_child_order(obj)

spl_child_order(obj) <- value

# S4 method for class 'VarLevelSplit'
spl_child_order(obj) <- value

# S4 method for class 'ManualSplit'
spl_child_order(obj)

# S4 method for class 'MultiVarSplit'
spl_child_order(obj)

# S4 method for class 'AllSplit'
spl_child_order(obj)

# S4 method for class 'VarStaticCutSplit'
spl_child_order(obj)

root_spl(obj)

# S4 method for class 'PreDataAxisLayout'
root_spl(obj)

root_spl(obj) <- value

# S4 method for class 'PreDataAxisLayout'
root_spl(obj) <- value

spanned_values(obj)

# S4 method for class 'TableRow'
spanned_values(obj)

# S4 method for class 'LabelRow'
spanned_values(obj)

spanned_cells(obj)

# S4 method for class 'TableRow'
spanned_cells(obj)

# S4 method for class 'LabelRow'
spanned_cells(obj)

spanned_values(obj) <- value

# S4 method for class 'TableRow'
spanned_values(obj) <- value

# S4 method for class 'LabelRow'
spanned_values(obj) <- value

# S4 method for class 'CellValue'
obj_na_str(obj) <- value

# S4 method for class 'VTableNodeInfo'
obj_na_str(obj) <- value

# S4 method for class 'Split'
obj_na_str(obj) <- value

# S4 method for class 'VTableNodeInfo'
obj_na_str(obj)

set_format_recursive(obj, format, na_str, override = FALSE)

# S4 method for class 'TableRow'
set_format_recursive(obj, format, na_str, override = FALSE)

# S4 method for class 'LabelRow'
set_format_recursive(obj, format, override = FALSE)

content_format(obj)

# S4 method for class 'Split'
content_format(obj)

content_format(obj) <- value

# S4 method for class 'Split'
content_format(obj) <- value

content_na_str(obj)

# S4 method for class 'Split'
content_na_str(obj)

content_na_str(obj) <- value

# S4 method for class 'Split'
content_na_str(obj) <- value

# S4 method for class 'TableTree'
collect_leaves(tt, incl.cont = TRUE, add.labrows = FALSE)

# S4 method for class 'ElementaryTable'
collect_leaves(tt, incl.cont = TRUE, add.labrows = FALSE)

# S4 method for class 'VTree'
collect_leaves(tt, incl.cont = TRUE, add.labrows = FALSE)

# S4 method for class 'VLeaf'
collect_leaves(tt, incl.cont = TRUE, add.labrows = FALSE)

# S4 method for class 'NULL'
collect_leaves(tt, incl.cont = TRUE, add.labrows = FALSE)

# S4 method for class 'ANY'
collect_leaves(tt, incl.cont = TRUE, add.labrows = FALSE)

row_cspans(obj)

# S4 method for class 'TableRow'
row_cspans(obj)

# S4 method for class 'LabelRow'
row_cspans(obj)

row_cspans(obj) <- value

# S4 method for class 'TableRow'
row_cspans(obj) <- value

# S4 method for class 'LabelRow'
row_cspans(obj) <- value

cell_cspan(obj)

# S4 method for class 'CellValue'
cell_cspan(obj)

cell_cspan(obj) <- value

# S4 method for class 'CellValue'
cell_cspan(obj) <- value

cell_align(obj)

# S4 method for class 'CellValue'
cell_align(obj)

cell_align(obj) <- value

# S4 method for class 'CellValue'
cell_align(obj) <- value

tt_level(obj)

# S4 method for class 'VNodeInfo'
tt_level(obj)

tt_level(obj) <- value

# S4 method for class 'VNodeInfo'
tt_level(obj) <- value

# S4 method for class 'VTableTree'
tt_level(obj) <- value

indent_mod(obj)

# S4 method for class 'Split'
indent_mod(obj)

# S4 method for class 'VTableNodeInfo'
indent_mod(obj)

# S4 method for class 'ANY'
indent_mod(obj)

# S4 method for class 'RowsVerticalSection'
indent_mod(obj)

indent_mod(obj) <- value

# S4 method for class 'Split'
indent_mod(obj) <- value

# S4 method for class 'VTableNodeInfo'
indent_mod(obj) <- value

# S4 method for class 'CellValue'
indent_mod(obj) <- value

# S4 method for class 'RowsVerticalSection'
indent_mod(obj) <- value

content_indent_mod(obj)

# S4 method for class 'Split'
content_indent_mod(obj)

# S4 method for class 'VTableNodeInfo'
content_indent_mod(obj)

content_indent_mod(obj) <- value

# S4 method for class 'Split'
content_indent_mod(obj) <- value

# S4 method for class 'VTableNodeInfo'
content_indent_mod(obj) <- value

rawvalues(obj)

# S4 method for class 'ValueWrapper'
rawvalues(obj)

# S4 method for class 'LevelComboSplitValue'
rawvalues(obj)

# S4 method for class 'list'
rawvalues(obj)

# S4 method for class 'ANY'
rawvalues(obj)

# S4 method for class 'CellValue'
rawvalues(obj)

# S4 method for class 'TreePos'
rawvalues(obj)

# S4 method for class 'RowsVerticalSection'
rawvalues(obj)

value_names(obj)

# S4 method for class 'ANY'
value_names(obj)

# S4 method for class 'TreePos'
value_names(obj)

# S4 method for class 'list'
value_names(obj)

# S4 method for class 'ValueWrapper'
value_names(obj)

# S4 method for class 'LevelComboSplitValue'
value_names(obj)

# S4 method for class 'RowsVerticalSection'
value_names(obj)

value_labels(obj)

# S4 method for class 'ANY'
value_labels(obj)

# S4 method for class 'TreePos'
value_labels(obj)

# S4 method for class 'list'
value_labels(obj)

# S4 method for class 'RowsVerticalSection'
value_labels(obj)

# S4 method for class 'ValueWrapper'
value_labels(obj)

# S4 method for class 'LevelComboSplitValue'
value_labels(obj)

# S4 method for class 'MultiVarSplit'
value_labels(obj)

spl_varlabels(obj)

# S4 method for class 'MultiVarSplit'
spl_varlabels(obj)

spl_varlabels(object) <- value

# S4 method for class 'MultiVarSplit'
spl_varlabels(object) <- value

split_exargs(obj)

# S4 method for class 'Split'
split_exargs(obj)

split_exargs(obj) <- value

# S4 method for class 'Split'
split_exargs(obj) <- value

col_extra_args(obj, df = NULL)

# S4 method for class 'InstantiatedColumnInfo'
col_extra_args(obj, df = NULL)

# S4 method for class 'PreDataTableLayouts'
col_extra_args(obj, df = NULL)

# S4 method for class 'PreDataColLayout'
col_extra_args(obj, df = NULL)

# S4 method for class 'LayoutColTree'
col_extra_args(obj, df = NULL)

# S4 method for class 'LayoutColLeaf'
col_extra_args(obj, df = NULL)

disp_ccounts(obj)

# S4 method for class 'VTableTree'
disp_ccounts(obj)

# S4 method for class 'InstantiatedColumnInfo'
disp_ccounts(obj)

# S4 method for class 'PreDataTableLayouts'
disp_ccounts(obj)

# S4 method for class 'PreDataColLayout'
disp_ccounts(obj)

# S4 method for class 'LayoutColTree'
disp_ccounts(obj)

# S4 method for class 'LayoutColLeaf'
disp_ccounts(obj)

# S4 method for class 'Split'
disp_ccounts(obj)

disp_ccounts(obj) <- value

# S4 method for class 'VTableTree'
disp_ccounts(obj) <- value

# S4 method for class 'InstantiatedColumnInfo'
disp_ccounts(obj) <- value

# S4 method for class 'PreDataColLayout'
disp_ccounts(obj) <- value

# S4 method for class 'LayoutColTree'
disp_ccounts(obj) <- value

# S4 method for class 'LayoutColLeaf'
disp_ccounts(obj) <- value

# S4 method for class 'PreDataTableLayouts'
disp_ccounts(obj) <- value

coltree_at_path(obj, path, ...)

colcount_format(obj)

# S4 method for class 'InstantiatedColumnInfo'
colcount_format(obj)

# S4 method for class 'VTableNodeInfo'
colcount_format(obj)

# S4 method for class 'PreDataColLayout'
colcount_format(obj)

# S4 method for class 'PreDataTableLayouts'
colcount_format(obj)

# S4 method for class 'Split'
colcount_format(obj)

# S4 method for class 'LayoutColTree'
colcount_format(obj)

# S4 method for class 'LayoutColLeaf'
colcount_format(obj)

colcount_format(obj) <- value

# S4 method for class 'InstantiatedColumnInfo'
colcount_format(obj) <- value

# S4 method for class 'VTableNodeInfo'
colcount_format(obj) <- value

# S4 method for class 'PreDataColLayout'
colcount_format(obj) <- value

# S4 method for class 'PreDataTableLayouts'
colcount_format(obj) <- value

colcount_na_str(obj)

# S4 method for class 'InstantiatedColumnInfo'
colcount_na_str(obj)

# S4 method for class 'VTableNodeInfo'
colcount_na_str(obj)

colcount_na_str(obj) <- value

# S4 method for class 'InstantiatedColumnInfo'
colcount_na_str(obj) <- value

# S4 method for class 'VTableNodeInfo'
colcount_na_str(obj) <- value

# S4 method for class 'TableRow'
as.vector(x, mode = "any")

# S4 method for class 'ElementaryTable'
as.vector(x, mode = "any")

spl_cuts(obj)

# S4 method for class 'VarStaticCutSplit'
spl_cuts(obj)

spl_cutlabels(obj)

# S4 method for class 'VarStaticCutSplit'
spl_cutlabels(obj)

spl_cutfun(obj)

# S4 method for class 'VarDynCutSplit'
spl_cutfun(obj)

spl_cutlabelfun(obj)

# S4 method for class 'VarDynCutSplit'
spl_cutlabelfun(obj)

spl_is_cmlcuts(obj)

# S4 method for class 'VarDynCutSplit'
spl_is_cmlcuts(obj)

spl_varnames(obj)

# S4 method for class 'MultiVarSplit'
spl_varnames(obj)

spl_varnames(object) <- value

# S4 method for class 'MultiVarSplit'
spl_varnames(object) <- value

# S4 method for class 'TableRow'
row_footnotes(obj)

# S4 method for class 'RowsVerticalSection'
row_footnotes(obj)

# S4 method for class 'TableRow'
row_footnotes(obj) <- value

# S4 method for class 'VTableTree'
row_footnotes(obj)

# S4 method for class 'CellValue'
cell_footnotes(obj)

# S4 method for class 'TableRow'
cell_footnotes(obj)

# S4 method for class 'LabelRow'
cell_footnotes(obj)

# S4 method for class 'VTableTree'
cell_footnotes(obj)

# S4 method for class 'CellValue'
cell_footnotes(obj) <- value

# S4 method for class 'DataRow'
cell_footnotes(obj) <- value

# S4 method for class 'ContentRow'
cell_footnotes(obj) <- value

# S4 method for class 'ANY'
col_fnotes_here(obj) <- value

# S4 method for class 'LayoutColTree'
col_footnotes(obj)

# S4 method for class 'LayoutColLeaf'
col_footnotes(obj)

# S4 method for class 'LayoutColTree'
col_footnotes(obj) <- value

# S4 method for class 'LayoutColLeaf'
col_footnotes(obj) <- value

# S4 method for class 'VTableTree'
col_footnotes(obj)

# S4 method for class 'RefFootnote'
ref_index(obj)

# S4 method for class 'RefFootnote'
ref_index(obj) <- value

# S4 method for class 'RefFootnote'
ref_symbol(obj)

# S4 method for class 'RefFootnote'
ref_symbol(obj) <- value

# S4 method for class 'RefFootnote'
ref_msg(obj)

# S4 method for class 'VTableTree,character'
fnotes_at_path(obj, rowpath = NULL, colpath = NULL, reset_idx = TRUE) <- value

# S4 method for class 'VTableTree,NULL'
fnotes_at_path(obj, rowpath = NULL, colpath = NULL, reset_idx = TRUE) <- value

has_force_pag(obj)

# S4 method for class 'TableTree'
has_force_pag(obj)

# S4 method for class 'Split'
has_force_pag(obj)

# S4 method for class 'VTableNodeInfo'
has_force_pag(obj)

obj_stat_names(obj)

obj_stat_names(obj) <- value

# S4 method for class 'CellValue'
obj_stat_names(obj) <- value

# S4 method for class 'CellValue'
obj_stat_names(obj)

# S4 method for class 'RowsVerticalSection'
obj_stat_names(obj)

# S4 method for class 'VTableNodeInfo,missing'
rbind2(x, y)

# S4 method for class 'VTableTree'
tt_at_path(tt, path, ...)

# S4 method for class 'VTableTree,ANY,VTableTree'
tt_at_path(tt, path, ...) <- value

# S4 method for class 'VTableTree,ANY,NULL'
tt_at_path(tt, path, ...) <- value

# S4 method for class 'VTableTree,ANY,TableRow'
tt_at_path(tt, path, ...) <- value

# S4 method for class 'VTableTree,ANY,ANY,CellValue'
x[i, j, ...] <- value

# S4 method for class 'VTableTree,logical,ANY'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,logical,missing'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,ANY,logical'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,ANY,missing'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,missing,ANY'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,ANY,character'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,character,ANY'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,character,missing'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,character,character'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,missing,numeric'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree,numeric,numeric'
x[i, j, ..., drop = FALSE]

# S4 method for class 'VTableTree'
cell_values(tt, rowpath = NULL, colpath = NULL, omit_labrows = TRUE)

# S4 method for class 'TableRow'
cell_values(tt, rowpath = NULL, colpath = NULL, omit_labrows = TRUE)

# S4 method for class 'LabelRow'
cell_values(tt, rowpath = NULL, colpath = NULL, omit_labrows = TRUE)

# S4 method for class 'TableRow'
value_at(tt, rowpath = NULL, colpath = NULL)

# S4 method for class 'LabelRow'
value_at(tt, rowpath = NULL, colpath = NULL)

# S4 method for class 'VTableTree'
print(x, ...)

# S4 method for class 'VTableTree'
show(object)
```

## Arguments

- x:

  (`ANY`)\
  the object.

- ...:

  splits or `SplitVector` objects.

- lyt:

  (`PreDataTableLayouts`)\
  layout object pre-data used for tabulation.

- spl:

  (`Split`)\
  the split.

- pos:

  (`numeric(1)`)\
  intended for internal use.

- cmpnd_fun:

  (`function`)\
  intended for internal use.

- constructor:

  (`function`)\
  constructor function.

- label:

  (`string`)\
  a label (not to be confused with the name) for the object/structure.

- cfun:

  (`list`, `function`, or `NULL`)\
  tabulation function(s) for creating content rows. Must accept `x` or
  `df` as first parameter. Must accept `labelstr` as the second
  argument. Can optionally accept all optional arguments accepted by
  analysis functions. See
  [`analyze()`](https://pharmaverse.github.io/rtables/reference/analyze.md).

- child_labels:

  (`string`)\
  the display behavior for the labels (i.e. label rows) of the children
  of this split. Accepts `"default"`, `"visible"`, and `"hidden"`.
  Defaults to `"default"` which flags the label row as visible only if
  the child has 0 content rows.

- cformat:

  (`string`, `function`, or `list`)\
  format for content rows.

- cna_str:

  (`character`)\
  NA string for use with `cformat` for content table.

- indent_mod:

  (`numeric`)\
  modifier for the default indent position for the structure created by
  this function (subtable, content table, or row) *and all of that
  structure's children*. Defaults to 0, which corresponds to the
  unmodified default behavior.

- cvar:

  (`string`)\
  the variable, if any, that the content function should accept.
  Defaults to `NA`.

- extra_args:

  (`list`)\
  extra arguments to be passed to the tabulation function. Element
  position in the list corresponds to the children of this split. Named
  elements in the child-specific lists are ignored if they do not match
  a formal argument of the tabulation function.

- df:

  (`data.frame` or `tibble`)\
  dataset.

- obj:

  (`ANY`)\
  the object.

- depth:

  (`numeric(1)`)\
  depth in tree.

- indent:

  (`numeric(1)`)\
  indent.

- print_indent:

  (`numeric(1)`)\
  indent for printing.

- object:

  (`VTableTree`)\
  a table object.

- max.level:

  (`numeric(1)`)\
  passed to [`utils::str`](https://rdrr.io/r/utils/str.html). Defaults
  to 3 for the `VTableTree` method, unlike the underlying default of
  `NA`. `NA` is *not* appropriate for `VTableTree` objects.

- value:

  (`ANY`)\
  the new value.

- nested:

  (`logical`)\
  whether this layout instruction should be applied within the existing
  layout structure *if possible* (`TRUE`, the default) or as a new
  top-level element (`FALSE`). Ignored if it would nest a split
  underneath analyses, which is not allowed.

- for_analyze:

  (`flag`) whether split is an analyze split.

- format:

  (`string`, `function`, or `list`)\
  format associated with this split. Formats can be declared via strings
  (`"xx.x"`) or function. In cases such as `analyze` calls, they can be
  character vectors or lists of functions. See
  [`formatters::list_valid_format_labels()`](https://rdrr.io/pkg/formatters/man/list_formats.html)
  for a list of all available format strings.

- na_str:

  (`string`)\
  string that should be displayed when the value of `x` is missing.
  Defaults to `"NA"`.

- override:

  (`flag`)\
  whether to override attribute.

- tt:

  (`TableTree` or related class)\
  a `TableTree` object representing a populated table.

- incl.cont:

  (`flag`)\
  whether to include rows from content tables within the tree. Defaults
  to `TRUE`.

- add.labrows:

  (`flag`)\
  whether to include label rows. Defaults to `FALSE`.

- path:

  (`character`)\
  a vector path for a position within the structure of a `TableTree`.
  Each element represents a subsequent choice amongst the children of
  the previous choice.

- mode:

  (`string`)\
  passed on to [`as.vector()`](https://rdrr.io/r/base/vector.html).

- rowpath:

  (`character` or `NULL`)\
  path within row structure. `NULL` indicates the footnote should go on
  the column rather than cell.

- colpath:

  (`character` or `NULL`)\
  path within column structure. `NULL` indicates footnote should go on
  the row rather than cell.

- reset_idx:

  (`flag`)\
  whether the numbering for referential footnotes should be immediately
  recalculated. Defaults to `TRUE`.

- y:

  (`ANY`)\
  second element to be row-bound via `rbind2`.

- i:

  (`numeric(1)`)\
  index.

- j:

  (`numeric(1)`)\
  index.

- drop:

  (`flag`)\
  whether the value in the cell should be returned if one cell is
  selected by the combination of `i` and `j`. It is not possible to
  return a vector of values. To do so please consider using
  [`cell_values()`](https://pharmaverse.github.io/rtables/reference/cell_values.md).
  Defaults to `FALSE`.

## Value

Various, but should be considered implementation details.

## Examples

``` r
library(dplyr)

iris2 <- iris |>
  group_by(Species) |>
  mutate(group = as.factor(rep_len(c("a", "b"), length.out = n()))) |>
  ungroup()

lyt <- basic_table() |>
  split_cols_by("Species") |>
  split_cols_by("group") |>
  analyze(c("Sepal.Length", "Petal.Width"),
    afun = list_wrap_x(summary),
    format = "xx.xx"
  )

tbl <- build_table(lyt, iris2)
lyt <- basic_table() |>
  split_rows_by("RACE", split_fun = keep_split_levels(c("ASIAN", "WHITE"))) |>
  analyze("AGE")

tbl <- build_table(lyt, DM)
indent_mod(tbl)
#> [1] 0
indent_mod(tbl) <- 1L
tbl
#>            all obs
#> ——————————————————
#>   ASIAN           
#>     Mean    33.91 
#>   WHITE           
#>     Mean    36.96 
```
