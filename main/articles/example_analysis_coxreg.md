# Example Complex Analysis Function: Modelling Cox Regression

## Introduction

In this vignette we will demonstrate how a complex analysis function can
be constructed in order to build highly-customized tables with
`rtables`. This example will detail the steps in creating an analysis
function to calculate a basic univariable Cox regression summary table
to analyze the treatment effect of the `ARM` variable and any
covariate/interaction effects for a survival analysis. For a Cox
regression analysis function with more customization options and the
capability of fitting multivariable Cox regression models, see the
[`summarize_coxreg()`](https://pharmaverse.github.io/tern/main/reference/cox_regression.html)
function from the
[`tern`](https://pharmaverse.github.io/tern/main/index.html) package,
which builds upon the concepts used in the construction of this example.

The packages used in this vignette are:

[`library`](https://rdrr.io/r/base/library.html)`(`[`rtables`](https://github.com/pharmaverse/rtables)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`

## Data Pre-Processing

First, we prepare the data that will be used to generate a table in this
example. We will use the example `ADTTE` (Time-To-Event Analysis)
dataset `ex_adtte` from the `formatters` package, which contains our
treatment variable `ARM`, several variables that can be chosen as
covariates, and censor variable `CNSR` from which we will derive the
event variable `EVENT` required for our model. For the purpose of this
example, we will use age (`AGE`) and race (`RACE`) as our covariates.

We prepare the data as needed to observe the desired effects in our
summary table. `PARAMCD` is filtered so that only records of overall
survival (OS) are included, and we filter and mutate to include only the
levels of interest in our covariates. The `ARM` variable is mutated to
indicate that `"B: Placebo"` should be used as the reference level of
our treatment variable, and the `EVENT` variable is derived from `CNSR`.

`adtte`` ``<-`` ``ex_adtte`` `` ``anl`` ``<-`` ``adtte`` ``|>`` `` ``dplyr``::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``PARAMCD`` ``==`` ``"OS"``)`` ``|>`` `` ``dplyr``::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``ARM`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"A: Drug X"``, ``"B: Placebo"``)``)`` ``|>`` `` ``dplyr``::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``RACE`` `[`%in%`](https://rdrr.io/r/base/match.html)` `[`c`](https://rdrr.io/r/base/c.html)`(``"ASIAN"``, ``"BLACK OR AFRICAN AMERICAN"``, ``"WHITE"``)``)`` ``|>`` `` ``dplyr``::`[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``RACE ``=`` `[`droplevels`](https://rdrr.io/r/base/droplevels.html)`(``RACE``)``)`` ``|>`` `` ``dplyr``::`[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``ARM ``=`` `[`droplevels`](https://rdrr.io/r/base/droplevels.html)`(``stats``::`[`relevel`](https://rdrr.io/r/stats/relevel.html)`(``ARM``, ``"B: Placebo"``)``)``)`` ``|>`` `` ``dplyr``::`[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``EVENT ``=`` ``1`` ``-`` ``CNSR``)`

## Creating Helper Functions: Cox Regression Model Calculations

### `tidy` Method for `summary.coxph` Objects: `tidy.summary.coxph`

This method allows the `tidy` function from the `broom` package to
operate on `summary.coxph` output, extracting the values of interest to
this analysis and returning a tidied
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
object.

`tidy.summary.coxph`` ``<-`` ``function``(``x``, ``...``)`` ``{`` `` `[`is`](https://rdrr.io/r/methods/is.html)`(``x``, ``"summary.coxph"``)`` `` ``pval`` ``<-`` ``x``$``coefficients`` `` ``confint`` ``<-`` ``x``$``conf.int`` `` ``levels`` ``<-`` `[`rownames`](https://rdrr.io/r/base/colnames.html)`(``pval``)`` `` ``pval`` ``<-`` ``tibble``::`[`as_tibble`](https://tibble.tidyverse.org/reference/as_tibble.html)`(``pval``)`` `` ``confint`` ``<-`` ``tibble``::`[`as_tibble`](https://tibble.tidyverse.org/reference/as_tibble.html)`(``confint``)`` `` `` ``ret`` ``<-`` `[`cbind`](https://rdrr.io/r/base/cbind.html)`(``pval``[``, `[`grepl`](https://rdrr.io/r/base/grep.html)`(``"Pr"``, `[`names`](https://rdrr.io/r/base/names.html)`(``pval``)``)``]``, ``confint``)`` `` ``ret``$``level`` ``<-`` ``levels`` `` ``ret``$``n`` ``<-`` ``x``[[``"n"``]``]`` `` ``ret`` ``}`

### Function to Estimate Interaction Effects: `h_coxreg_inter_effect`

The `h_coxreg_inter_effect` helper function is used within the following
helper function, `h_coxreg_extract_interaction`, to estimate interaction
effects from a given model for a given covariate. The function
calculates the desired statistics from the given model and returns a
`data.frame` with label information for each row as well as the
statistics `n`, `hr` (hazard ratio), `lcl` (CI lower bound), `ucl` (CI
upper bound), `pval` (effect p-value), and `pval_inter` (interaction
p-value). If a numeric covariate is selected, the median value is used
as the sole “level” for which an interaction effect is calculated. For
non-numeric covariates, an interaction effect is calculated for each
level of the covariate, with each result returned on a separate row.

`h_coxreg_inter_effect`` ``<-`` ``function``(``x``,`` `` ``effect``,`` `` ``covar``,`` `` ``mod``,`` `` ``label``,`` `` ``control``,`` `` ``data``)`` ``{`` `` ``if`` ``(`[`is.numeric`](https://rdrr.io/r/base/numeric.html)`(``x``)``)`` ``{`` `` ``betas`` ``<-`` ``stats``::`[`coef`](https://rdrr.io/r/stats/coef.html)`(``mod``)`` `` ``attrs`` ``<-`` `[`attr`](https://rdrr.io/r/base/attr.html)`(``stats``::`[`terms`](https://rdrr.io/r/stats/terms.html)`(``mod``)``, ``"term.labels"``)`` `` ``term_indices`` ``<-`` `[`grep`](https://rdrr.io/r/base/grep.html)`(``pattern ``=`` ``effect``, x ``=`` ``attrs``[``!`[`grepl`](https://rdrr.io/r/base/grep.html)`(``"strata\\("``, ``attrs``)``]``)`` `` ``betas`` ``<-`` ``betas``[``term_indices``]`` `` ``betas_var`` ``<-`` `[`diag`](https://rdrr.io/r/base/diag.html)`(``stats``::`[`vcov`](https://rdrr.io/r/stats/vcov.html)`(``mod``)``)``[``term_indices``]`` `` ``betas_cov`` ``<-`` ``stats``::`[`vcov`](https://rdrr.io/r/stats/vcov.html)`(``mod``)``[``term_indices``[``1``]``, ``term_indices``[``2``]``]`` `` ``xval`` ``<-`` ``stats``::`[`median`](https://rdrr.io/r/stats/median.html)`(``x``)`` `` ``effect_index`` ``<-`` ``!`[`grepl`](https://rdrr.io/r/base/grep.html)`(``covar``, `[`names`](https://rdrr.io/r/base/names.html)`(``betas``)``)`` `` ``coef_hat`` ``<-`` ``betas``[``effect_index``]`` ``+`` ``xval`` ``*`` ``betas``[``!``effect_index``]`` `` ``coef_se`` ``<-`` `[`sqrt`](https://rdrr.io/r/base/MathFun.html)`(``betas_var``[``effect_index``]`` ``+`` ``xval``^``2`` ``*`` ``betas_var``[``!``effect_index``]`` ``+`` ``2`` ``*`` ``xval`` ``*`` ``betas_cov``)`` `` ``q_norm`` ``<-`` ``stats``::`[`qnorm`](https://rdrr.io/r/stats/Normal.html)`(``(``1`` ``+`` ``control``$``conf_level``)`` ``/`` ``2``)`` `` ``}`` ``else`` ``{`` `` ``var_lvl`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``effect``, `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``effect``]``]``)``[``-``1``]``)`` ``# [-1]: reference level`` `` ``giv_lvl`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``covar``, `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``covar``]``]``)``)`` `` ``design_mat`` ``<-`` `[`expand.grid`](https://rdrr.io/r/base/expand.grid.html)`(``effect ``=`` ``var_lvl``, covar ``=`` ``giv_lvl``)`` `` ``design_mat`` ``<-`` ``design_mat``[`[`order`](https://rdrr.io/r/base/order.html)`(``design_mat``$``effect``, ``design_mat``$``covar``)``, ``]`` `` ``design_mat`` ``<-`` `[`within`](https://rdrr.io/r/base/with.html)`(``data ``=`` ``design_mat``, expr ``=`` ``{`` `` ``inter`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``effect``, ``":"``, ``covar``)`` `` ``rev_inter`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``covar``, ``":"``, ``effect``)`` `` ``}``)`` `` ``split_by_variable`` ``<-`` ``design_mat``$``effect`` `` ``interaction_names`` ``<-`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``design_mat``$``effect``, ``design_mat``$``covar``, sep ``=`` ``"/"``)`` `` ``mmat`` ``<-`` ``stats``::`[`model.matrix`](https://rdrr.io/r/stats/model.matrix.html)`(``mod``)``[``1``, ``]`` `` ``mmat``[``!``mmat`` ``==`` ``0``]`` ``<-`` ``0`` `` ``design_mat`` ``<-`` `[`apply`](https://rdrr.io/r/base/apply.html)`(``X ``=`` ``design_mat``, MARGIN ``=`` ``1``, FUN ``=`` ``function``(``x``)`` ``{`` `` ``mmat``[`[`names`](https://rdrr.io/r/base/names.html)`(``mmat``)`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``x``[``-`[`which`](https://rdrr.io/r/base/which.html)`(`[`names`](https://rdrr.io/r/base/names.html)`(``x``)`` ``==`` ``"covar"``)``]``]`` ``<-`` ``1`` `` ``mmat`` `` ``}``)`` `` `[`colnames`](https://rdrr.io/r/base/colnames.html)`(``design_mat``)`` ``<-`` ``interaction_names`` `` ``coef`` ``<-`` ``stats``::`[`coef`](https://rdrr.io/r/stats/coef.html)`(``mod``)`` `` ``vcov`` ``<-`` ``stats``::`[`vcov`](https://rdrr.io/r/stats/vcov.html)`(``mod``)`` `` ``betas`` ``<-`` `[`as.matrix`](https://rdrr.io/r/base/matrix.html)`(``coef``)`` `` ``coef_hat`` ``<-`` `[`t`](https://rdrr.io/r/base/t.html)`(``design_mat``)`` `[`%*%`](https://rdrr.io/r/base/matmult.html)` ``betas`` `` `[`dimnames`](https://rdrr.io/r/base/dimnames.html)`(``coef_hat``)``[``2``]`` ``<-`` ``"coef"`` `` ``coef_se`` ``<-`` `[`apply`](https://rdrr.io/r/base/apply.html)`(``design_mat``, ``2``, ``function``(``x``)`` ``{`` `` ``vcov_el`` ``<-`` `[`as.logical`](https://rdrr.io/r/base/logical.html)`(``x``)`` `` ``y`` ``<-`` ``vcov``[``vcov_el``, ``vcov_el``]`` `` ``y`` ``<-`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``y``)`` `` ``y`` ``<-`` `[`sqrt`](https://rdrr.io/r/base/MathFun.html)`(``y``)`` `` ``y`` `` ``}``)`` `` ``q_norm`` ``<-`` ``stats``::`[`qnorm`](https://rdrr.io/r/stats/Normal.html)`(``(``1`` ``+`` ``control``$``conf_level``)`` ``/`` ``2``)`` `` ``y`` ``<-`` `[`cbind`](https://rdrr.io/r/base/cbind.html)`(``coef_hat``` , `se(coef)`  ```=`` ``coef_se``)`` `` ``y`` ``<-`` `[`apply`](https://rdrr.io/r/base/apply.html)`(``y``, ``1``, ``function``(``x``)`` ``{`` `` ``x``[``"hr"``]`` ``<-`` `[`exp`](https://rdrr.io/r/base/Log.html)`(``x``[``"coef"``]``)`` `` ``x``[``"lcl"``]`` ``<-`` `[`exp`](https://rdrr.io/r/base/Log.html)`(``x``[``"coef"``]`` ``-`` ``q_norm`` ``*`` ``x``[``"se(coef)"``]``)`` `` ``x``[``"ucl"``]`` ``<-`` `[`exp`](https://rdrr.io/r/base/Log.html)`(``x``[``"coef"``]`` ``+`` ``q_norm`` ``*`` ``x``[``"se(coef)"``]``)`` `` ``x`` `` ``}``)`` `` ``y`` ``<-`` `[`t`](https://rdrr.io/r/base/t.html)`(``y``)`` `` ``y`` ``<-`` `[`by`](https://rdrr.io/r/base/by.html)`(``y``, ``split_by_variable``, ``identity``)`` `` ``y`` ``<-`` `[`lapply`](https://rdrr.io/r/base/lapply.html)`(``y``, ``as.matrix``)`` `` `[`attr`](https://rdrr.io/r/base/attr.html)`(``y``, ``"details"``)`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`` `` ``"Estimations of "``, ``effect``, ``" hazard ratio given the level of "``, ``covar``, ``" compared to "``,`` `` ``effect``, ``" level "``, `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``effect``]``]``)``[``1``]``, ``"."`` `` ``)`` `` ``xval`` ``<-`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``covar``]``]``)`` `` ``}`` `` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`` `` effect ``=`` ``"Covariate:"``,`` `` term ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``covar``, `[`length`](https://rdrr.io/r/base/length.html)`(``xval``)``)``,`` `` term_label ``=`` `[`as.character`](https://rdrr.io/r/base/character.html)`(`[`paste0`](https://rdrr.io/r/base/paste.html)`(``" "``, ``xval``)``)``,`` `` level ``=`` `[`as.character`](https://rdrr.io/r/base/character.html)`(``xval``)``,`` `` n ``=`` ``NA``,`` `` hr ``=`` ``if`` ``(`[`is.numeric`](https://rdrr.io/r/base/numeric.html)`(``x``)``)`` `[`exp`](https://rdrr.io/r/base/Log.html)`(``coef_hat``)`` ``else`` ``y``[[``1``]``]``[``, ``"hr"``]``,`` `` lcl ``=`` ``if`` ``(`[`is.numeric`](https://rdrr.io/r/base/numeric.html)`(``x``)``)`` `[`exp`](https://rdrr.io/r/base/Log.html)`(``coef_hat`` ``-`` ``q_norm`` ``*`` ``coef_se``)`` ``else`` ``y``[[``1``]``]``[``, ``"lcl"``]``,`` `` ucl ``=`` ``if`` ``(`[`is.numeric`](https://rdrr.io/r/base/numeric.html)`(``x``)``)`` `[`exp`](https://rdrr.io/r/base/Log.html)`(``coef_hat`` ``+`` ``q_norm`` ``*`` ``coef_se``)`` ``else`` ``y``[[``1``]``]``[``, ``"ucl"``]``,`` `` pval ``=`` ``NA``,`` `` pval_inter ``=`` ``NA``,`` `` stringsAsFactors ``=`` ``FALSE`` `` ``)`` ``}`

### Function to Extract Effect Information: `h_coxreg_extract_interaction`

Using the previous two helper functions, `h_coxreg_extract_interaction`
uses ANOVA to extract information from the given model about the given
covariate. This function will extract different information depending on
whether the effect of interest is a treatment/main effect or an
interaction effect, and returns a `data.frame` with label information
for each row (corresponding to each effect) as well as the statistics
`n`, `hr`, `lcl`, `ucl`, `pval`, and `pval_inter` (for interaction
effects only). This helper function is used directly within our analysis
function to analyze the Cox regression model and extract relevant
information to be processed and displayed within our output table.

`h_coxreg_extract_interaction`` ``<-`` ``function``(``effect``, ``covar``, ``mod``, ``data``)`` ``{`` `` ``control`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``pval_method ``=`` ``"wald"``, ties ``=`` ``"exact"``, conf_level ``=`` ``0.95``, interaction ``=`` ``FALSE``)`` `` ``test_statistic`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``wald ``=`` ``"Wald"``, likelihood ``=`` ``"LR"``)``[``control``$``pval_method``]`` `` ``mod_aov`` ``<-`` `[`withCallingHandlers`](https://rdrr.io/r/base/conditions.html)`(`` `` expr ``=`` ``car``::`[`Anova`](https://rdrr.io/pkg/car/man/Anova.html)`(``mod``, test.statistic ``=`` ``test_statistic``, type ``=`` ``"III"``)``,`` `` message ``=`` ``function``(``m``)`` `[`invokeRestart`](https://rdrr.io/r/base/conditions.html)`(``"muffleMessage"``)`` `` ``)`` `` ``msum`` ``<-`` ``if`` ``(``!`[`any`](https://rdrr.io/r/base/any.html)`(`[`attr`](https://rdrr.io/r/base/attr.html)`(``stats``::`[`terms`](https://rdrr.io/r/stats/terms.html)`(``mod``)``, ``"order"``)`` ``==`` ``2``)``)`` `[`summary`](https://rdrr.io/r/base/summary.html)`(``mod``, conf.int ``=`` ``control``$``conf_level``)`` ``else`` ``mod_aov`` `` ``sum_anova`` ``<-`` ``broom``::`[`tidy`](https://generics.r-lib.org/reference/tidy.html)`(``msum``)`` `` ``if`` ``(``!`[`any`](https://rdrr.io/r/base/any.html)`(`[`attr`](https://rdrr.io/r/base/attr.html)`(``stats``::`[`terms`](https://rdrr.io/r/stats/terms.html)`(``mod``)``, ``"order"``)`` ``==`` ``2``)``)`` ``{`` `` ``effect_aov`` ``<-`` ``mod_aov``[``effect``, , drop ``=`` ``TRUE``]`` `` ``pval`` ``<-`` ``effect_aov``[[`[`grep`](https://rdrr.io/r/base/grep.html)`(``pattern ``=`` ``"Pr"``, x ``=`` `[`names`](https://rdrr.io/r/base/names.html)`(``effect_aov``)``)``, drop ``=`` ``TRUE``]``]`` `` ``sum_main`` ``<-`` ``sum_anova``[`[`grepl`](https://rdrr.io/r/base/grep.html)`(``effect``, ``sum_anova``$``level``)``, ``]`` `` ``term_label`` ``<-`` ``if`` ``(``effect`` ``==`` ``covar``)`` ``{`` `` `[`paste0`](https://rdrr.io/r/base/paste.html)`(`[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``covar``]``]``)``[``2``]``, ``" vs control ("``, `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``covar``]``]``)``[``1``]``, ``")"``)`` `` ``}`` ``else`` ``{`` `` `[`unname`](https://rdrr.io/r/base/unname.html)`(``formatters``::`[`var_labels`](https://rdrr.io/pkg/formatters/man/var_labels.html)`(``data``, fill ``=`` ``TRUE``)``[[``covar``]``]``)`` `` ``}`` `` ``y`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`` `` effect ``=`` `[`ifelse`](https://rdrr.io/r/base/ifelse.html)`(``covar`` ``==`` ``effect``, ``"Treatment:"``, ``"Covariate:"``)``,`` `` term ``=`` ``covar``, term_label ``=`` ``term_label``,`` `` level ``=`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``data``[[``effect``]``]``)``[``2``]``,`` `` n ``=`` ``mod``[[``"n"``]``]``, hr ``=`` `[`unname`](https://rdrr.io/r/base/unname.html)`(``sum_main``[``"exp(coef)"``]``)``, lcl ``=`` `[`unname`](https://rdrr.io/r/base/unname.html)`(``sum_main``[`[`grep`](https://rdrr.io/r/base/grep.html)`(``"lower"``, `[`names`](https://rdrr.io/r/base/names.html)`(``sum_main``)``)``]``)``,`` `` ucl ``=`` `[`unname`](https://rdrr.io/r/base/unname.html)`(``sum_main``[`[`grep`](https://rdrr.io/r/base/grep.html)`(``"upper"``, `[`names`](https://rdrr.io/r/base/names.html)`(``sum_main``)``)``]``)``, pval ``=`` ``pval``,`` `` stringsAsFactors ``=`` ``FALSE`` `` ``)`` `` ``y``$``pval_inter`` ``<-`` ``NA`` `` ``y`` `` ``}`` ``else`` ``{`` `` ``pval`` ``<-`` ``sum_anova``[``sum_anova``$``term`` ``==`` ``effect``, ``]``[[``"p.value"``]``]`` `` `` ``## Test the interaction effect`` `` ``pval_inter`` ``<-`` ``sum_anova``[`[`grep`](https://rdrr.io/r/base/grep.html)`(``":"``, ``sum_anova``$``term``)``, ``]``[[``"p.value"``]``]`` `` ``covar_test`` ``<-`` `[`data.frame`](https://rdrr.io/r/base/data.frame.html)`(`` `` effect ``=`` ``"Covariate:"``,`` `` term ``=`` ``covar``, term_label ``=`` `[`unname`](https://rdrr.io/r/base/unname.html)`(``formatters``::`[`var_labels`](https://rdrr.io/pkg/formatters/man/var_labels.html)`(``data``, fill ``=`` ``TRUE``)``[[``covar``]``]``)``,`` `` level ``=`` ``""``,`` `` n ``=`` ``mod``$``n``, hr ``=`` ``NA``, lcl ``=`` ``NA``, ucl ``=`` ``NA``, pval ``=`` ``pval``,`` `` pval_inter ``=`` ``pval_inter``,`` `` stringsAsFactors ``=`` ``FALSE`` `` ``)`` `` ``## Estimate the interaction`` `` ``y`` ``<-`` ``h_coxreg_inter_effect``(`` `` ``data``[[``covar``]``]``,`` `` covar ``=`` ``covar``,`` `` effect ``=`` ``effect``,`` `` mod ``=`` ``mod``,`` `` label ``=`` `[`unname`](https://rdrr.io/r/base/unname.html)`(``formatters``::`[`var_labels`](https://rdrr.io/pkg/formatters/man/var_labels.html)`(``data``, fill ``=`` ``TRUE``)``[[``covar``]``]``)``,`` `` control ``=`` ``control``,`` `` data ``=`` ``data`` `` ``)`` `` `[`rbind`](https://pharmaverse.github.io/rtables/reference/rbind.md)`(``covar_test``, ``y``)`` `` ``}`` ``}`

## Creating a Helper Function: `cached_model`

Next, we will create a helper function, `cached_model`, which will be
used within our analysis function to cache and return the fitted Cox
regression model for the current covariate. The `df` argument will be
directly inherited from the `df` argument passed to the analysis
function, which contains the full dataset being analyzed. The `cov`
argument will be the covariate that is being analyzed depending on the
current row context. If the treatment effect is currently being
analyzed, this value will be an empty string. The `cache_env` parameter
will be an environment object which is used to store the model for the
current covariate, also passed down from the analysis function. Of
course, this function can also be run outside of the analysis function
and will still cache and return a Cox regression model.

Using these arguments, the `cached_model` function first checks if a
model for the given covariate `cov` is already stored in the caching
environment `cache_env`. If so, then this model is retrieved and
returned by `cached_model`. If not, the model must be constructed. This
is done by first constructing the model formula, `model_form`, starting
with only the treatment effect (`ARM`) and adding a covariate effect if
one is currently being analyzed. Then a Cox regression model is fit
using `df` and the model formula, and this model is both returned and
stored in the caching environment object as `cache_env[[cov]]`.

`cached_model`` ``<-`` ``function``(``df``, ``cov``, ``cache_env``)`` ``{`` `` ``## Check if a model already exists for`` `` ``` ## `cov` in the caching environment ``` `` ``if`` ``(``!`[`is.null`](https://rdrr.io/r/base/NULL.html)`(``cache_env``[[``cov``]``]``)``)`` ``{`` `` ``## If model already exists, retrieve it from cache_env`` `` ``model`` ``<-`` ``cache_env``[[``cov``]``]`` `` ``}`` ``else`` ``{`` `` ``## Build model formula`` `` ``model_form`` ``<-`` `[`paste0`](https://rdrr.io/r/base/paste.html)`(``"survival::Surv(AVAL, EVENT) ~ ARM"``)`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``cov``)`` ``>`` ``0``)`` ``{`` `` ``model_form`` ``<-`` `[`paste`](https://rdrr.io/r/base/paste.html)`(`[`c`](https://rdrr.io/r/base/c.html)`(``model_form``, ``cov``)``, collapse ``=`` ``" * "``)`` `` ``}`` ``else`` ``{`` `` ``cov`` ``<-`` ``"ARM"`` `` ``}`` `` ``## Calculate Cox regression model`` `` ``model`` ``<-`` ``survival``::`[`coxph`](https://rdrr.io/pkg/survival/man/coxph.html)`(`` `` formula ``=`` ``stats``::`[`as.formula`](https://rdrr.io/r/stats/formula.html)`(``model_form``)``,`` `` data ``=`` ``df``,`` `` ties ``=`` ``"exact"`` `` ``)`` `` ``## Store model in the caching environment`` `` ``cache_env``[[``cov``]``]`` ``<-`` ``model`` `` ``}`` `` ``model`` ``}`

## Creating the Analysis Function: `a_cox_summary`

With our data prepared and helper function created, we can proceed to
construct our analysis function `a_cox_summary`, which will be used to
populate all of the rows in our table. In order to be used to generate
both data rows (for interaction effects) and content rows (for main
effects), we must create a function that can be used as both `afun` in
`analyze` and `cfun` in `summarize_row_groups`. Therefore, our function
must accept the `labelstr` parameter.

The arguments of our analysis function will be as follows:

- `df` - a `data.frame` of the full dataset required to fit the Cox
  regression model.
- `labelstr` - the `string` label for the variable being analyzed in the
  current row/column split context.
- `.spl_context` - a `data.frame` containing the `value` column which is
  used by this analysis function to determine the name of the
  variable/covariate in the current split. For more details on the
  information stored by `.spl_context` see
  [`?analyze`](https://pharmaverse.github.io/rtables/reference/analyze.md).
- `stat` and `format` - `string`s that indicate which statistic column
  we are currently in and what format should be applied to print the
  statistic.
- `cache_env` - an `environment` object that can be used to store cached
  models so that we can prevent repeatedly fitting the same model.
  Instead, each model will be generated once per covariate and then
  reused. This argument will be passed directly to the `cached_model`
  helper function we defined previously.
- `cov_main` - a `logical` value indicating whether or not the current
  row is summarizing covariate main effects.

The analysis function works within a given row/column split context by
using the current covariate (`cov`) and the `cached_model` function to
obtain the desired Cox regression model. From this model, the
`h_coxreg_extract_interaction` function is able to extract
information/statistics relevant to the analysis and store it in a
`data.frame`. The rows in this `data.frame` that are of interest in the
current row/column split context are then extracted and the statistic to
be printed in the current column is retrieved from these rows. Finally,
the formatted cells with this statistic are returned as a
`VerticalRowsSection` object. For more detail see the commented function
code below, where the purpose of each line within `a_cox_summary` is
described.

`a_cox_summary`` ``<-`` ``function``(``df``,`` `` ``labelstr`` ``=`` ``""``,`` `` ``.spl_context``,`` `` ``stat``,`` `` ``format``,`` `` ``cache_env``,`` `` ``cov_main`` ``=`` ``FALSE``)`` ``{`` `` ``## Get current covariate (variable used in latest row split)`` `` ``cov`` ``<-`` `[`tail`](https://pharmaverse.github.io/rtables/reference/head_tail.md)`(``.spl_context``$``value``, ``1``)`` `` `` ``## If currently analyzing treatment effect (ARM) replace empty`` `` ``## value of cov with "ARM" so the correct model row is analyzed`` `` ``if`` ``(`[`length`](https://rdrr.io/r/base/length.html)`(``cov``)`` ``==`` ``0``)`` ``cov`` ``<-`` ``"ARM"`` `` `` ``## Use cached_model to get the fitted Cox regression`` `` ``## model for the current covariate`` `` ``model`` ``<-`` ``cached_model``(``df ``=`` ``df``, cov ``=`` ``cov``, cache_env ``=`` ``cache_env``)`` `` `` ``## Extract levels of cov to be used as row labels for interaction effects.`` `` ``## If cov is numeric, the median value of cov is used as a row label instead`` `` ``cov_lvls`` ``<-`` ``if`` ``(`[`is.factor`](https://rdrr.io/r/base/factor.html)`(``df``[[``cov``]``]``)``)`` `[`levels`](https://rdrr.io/r/base/levels.html)`(``df``[[``cov``]``]``)`` ``else`` `[`as.character`](https://rdrr.io/r/base/character.html)`(`[`median`](https://rdrr.io/r/stats/median.html)`(``df``[[``cov``]``]``)``)`` `` `` ``## Use function to calculate and extract information relevant to cov from the model`` `` ``cov_rows`` ``<-`` ``h_coxreg_extract_interaction``(``effect ``=`` ``"ARM"``, covar ``=`` ``cov``, mod ``=`` ``model``, data ``=`` ``df``)`` `` ``## Effect p-value is only printed for treatment effect row`` `` ``if`` ``(``!``cov`` ``==`` ``"ARM"``)`` ``cov_rows``[``, ``"pval"``]`` ``<-`` ``NA_real_`` `` ``## Extract rows containing statistics for cov from model information`` `` ``if`` ``(``!``cov_main``)`` ``{`` `` ``## Extract rows for main effect`` `` ``cov_rows`` ``<-`` ``cov_rows``[``cov_rows``$``level`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``cov_lvls``, ``]`` `` ``}`` ``else`` ``{`` `` ``## Extract all non-main effect rows`` `` ``cov_rows`` ``<-`` ``cov_rows``[`[`nchar`](https://rdrr.io/r/base/nchar.html)`(``cov_rows``$``level``)`` ``==`` ``0``, ``]`` `` ``}`` `` ``## Extract value(s) of statistic for current column and variable/levels`` `` ``stat_vals`` ``<-`` `[`as.list`](https://rdrr.io/r/base/list.html)`(`[`apply`](https://rdrr.io/r/base/apply.html)`(``cov_rows``[``stat``]``, ``1``, ``function``(``x``)`` ``x``, simplify ``=`` ``FALSE``)``)`` `` ``## Assign labels: covariate name for main effect (content) rows, ARM comparison description`` `` ``## for treatment effect (content) row, cov_lvls for interaction effect (data) rows`` `` ``nms`` ``<-`` ``if`` ``(``cov_main``)`` ``labelstr`` ``else`` ``if`` ``(``cov`` ``==`` ``"ARM"``)`` ``cov_rows``$``term_label`` ``else`` ``cov_lvls`` `` ``## Return formatted/labelled row`` `` `[`in_rows`](https://pharmaverse.github.io/rtables/reference/in_rows.md)`(`` `` .list ``=`` ``stat_vals``,`` `` .names ``=`` ``nms``,`` `` .labels ``=`` ``nms``,`` `` .formats ``=`` `[`setNames`](https://rdrr.io/r/stats/setNames.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(``format``, `[`length`](https://rdrr.io/r/base/length.html)`(``nms``)``)``, ``nms``)``,`` `` .format_na_strs ``=`` `[`setNames`](https://rdrr.io/r/stats/setNames.html)`(`[`rep`](https://rdrr.io/r/base/rep.html)`(``""``, `[`length`](https://rdrr.io/r/base/length.html)`(``nms``)``)``, ``nms``)`` `` ``)`` ``}`

## Selecting Parameters

We are able to customize our Cox regression summary using this analysis
function by selecting covariates (and their labels), statistics (and
their labels), and statistic formats to use when generating the output
table. We also initialize a new environment object to be used by the
analysis function as the caching environment to store our models in. For
the purpose of this example, we will choose all 5 of the possible
statistics to include in the table: n, hazard ratio, confidence
interval, effect p-value, and interaction p-value.

`my_covs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AGE"``, ``"RACE"``)`` ``## Covariates`` ``my_cov_labs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Age"``, ``"Race"``)`` ``## Covariate labels`` ``my_stats`` ``<-`` `[`list`](https://rdrr.io/r/base/list.html)`(``"n"``, ``"hr"``, `[`c`](https://rdrr.io/r/base/c.html)`(``"lcl"``, ``"ucl"``)``, ``"pval"``, ``"pval_inter"``)`` ``## Statistics`` ``my_stat_labs`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"n"``, ``"Hazard Ratio"``, ``"95% CI"``, ``"p-value\n(effect)"``, ``"p-value\n(interaction)"``)`` ``## Statistic labels`` ``my_formats`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(`` `` n ``=`` ``"xx"``, hr ``=`` ``"xx.xx"``, lcl ``=`` ``"(xx.xx, xx.xx)"``, pval ``=`` ``"xx.xxxx"``, pval_inter ``=`` ``"xx.xxxx"`` ``## Statistic formats`` ``)`` ``my_env`` ``<-`` `[`new.env`](https://rdrr.io/r/base/environment.html)`(``)`` ``ny_cache_env`` ``<-`` `[`replicate`](https://rdrr.io/r/base/lapply.html)`(`[`length`](https://rdrr.io/r/base/length.html)`(``my_stats``)``, `[`list`](https://rdrr.io/r/base/list.html)`(``my_env``)``)`` ``## Caching environment`

## Constructing the Table

Finally, the table layout can be constructed and used to build the
desired table.

We first split our `basic_table` using `split_cols_by_multivar` to
ensure that each statistic exists in its own column. To do so, we choose
a variable (in this case `STUDYID`) which shares the same value in every
row, and use it as the split variable for every column so that the full
dataset is used to compute the model for every column. We use the
`extra_args` argument for which each list element’s element positions
correspond to the children of (columns generated by) this split. These
arguments are inherited by all following layout elements operating
within this split, which use these elements as argument inputs. To
elaborate on this, we have three elements in `extra_args`: `stat`,
`format`, and `cache_env` - each of which are arguments of
`a_cox_summary` and have length equal to the number of columns (as
defined above). For each use of our analysis function following this
column split, depending on the current column context, the corresponding
element of each of these three list elements will be inherited from
`extra_args` and used as input. For example, if `analyze_colvars` is
called with `a_cox_summary` as `afun` and is performing calculations for
column 1, `my_stats[1]` (`"n"`) will be given as argument `stat`,
`my_formats[1]` (`"xx"`) as argument `format`, and `my_cache_env[1]`
(`my_env`) as `cache_env`. This is useful for our table since we want
each column to print out values for a different statistic and apply its
corresponding format.

Next, we can use `summarize_row_groups` to generate the content row for
treatment effect. This is the first instance where `extra_args` from the
column split will be inherited and used as argument input in `cfun`.

After generating the treatment effect row, we want to add rows for
covariates. We use `split_rows_by_multivar` to split rows by covariate
and apply appropriate labels.

Following this row split, we use `summarize_row_groups` with
`a_cox_summary` as `cfun` to generate one content row for each covariate
main effect. Once again the contents of `extra_args` from the column
split are inherited as input. Here we specify `cov_main = TRUE` in the
`extra_args` argument so that main effects rather than interactions are
considered. Since this is not a split, this instance of `extra_args` is
not inherited by any following layout elements. As `cov_main` is a
singular value, `cov_main = TRUE` will be used within every column
context.

The last part of our table is the covariate interaction effects. We use
`analyze_colvars` with `a_cox_summary` as `afun`, and again inherit
`extra_args` from the column split. Using an `rtables` “analyze”
function generates data rows, with one row corresponding to each
covariate level (or median value, for numeric covariates), nested under
the content row (main effect) for that same covariate.

`lyt`` ``<-`` `[`basic_table`](https://pharmaverse.github.io/rtables/reference/basic_table.md)`(``)`` ``|>`` `` ``## Column split: one column for each statistic`` `` `[`split_cols_by_multivar`](https://pharmaverse.github.io/rtables/reference/split_cols_by_multivar.md)`(`` `` vars ``=`` `[`rep`](https://rdrr.io/r/base/rep.html)`(``"STUDYID"``, `[`length`](https://rdrr.io/r/base/length.html)`(``my_stats``)``)``,`` `` varlabels ``=`` ``my_stat_labs``,`` `` extra_args ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(`` `` stat ``=`` ``my_stats``,`` `` format ``=`` ``my_formats``,`` `` cache_env ``=`` ``ny_cache_env`` `` ``)`` `` ``)`` ``|>`` `` ``## Create content row for treatment effect`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(``cfun ``=`` ``a_cox_summary``)`` ``|>`` `` ``## Row split: one content row for each covariate`` `` `[`split_rows_by_multivar`](https://pharmaverse.github.io/rtables/reference/split_rows_by_multivar.md)`(`` `` vars ``=`` ``my_covs``,`` `` varlabels ``=`` ``my_cov_labs``,`` `` split_label ``=`` ``"Covariate:"``,`` `` indent_mod ``=`` ``-``1`` ``## Align split label left`` `` ``)`` ``|>`` `` ``## Create content rows for covariate main effects`` `` `[`summarize_row_groups`](https://pharmaverse.github.io/rtables/reference/summarize_row_groups.md)`(`` `` cfun ``=`` ``a_cox_summary``,`` `` extra_args ``=`` `[`list`](https://rdrr.io/r/base/list.html)`(``cov_main ``=`` ``TRUE``)`` `` ``)`` ``|>`` `` ``## Create data rows for covariate interaction effects`` `` `[`analyze_colvars`](https://pharmaverse.github.io/rtables/reference/analyze_colvars.md)`(``afun ``=`` ``a_cox_summary``)`

Using our pre-processed `anl` dataset, we can now build and output our
final Cox regression summary table.

`cox_tbl`` ``<-`` `[`build_table`](https://pharmaverse.github.io/rtables/reference/build_table.md)`(``lyt``, ``anl``)`` ``cox_tbl`` ``#> p-value p-value `` ``#> n Hazard Ratio 95% CI (effect) (interaction)`` ``#> ————————————————————————————————————————————————————————————————————————————————————————————————`` ``#> A: Drug X vs control (B: Placebo) 247 0.97 (0.71, 1.32) 0.8243 `` ``#> Covariate: `` ``#> Age 247 0.7832 `` ``#> 34 0.92 (0.68, 1.26) `` ``#> Race 247 0.7441 `` ``#> ASIAN 1.03 (0.68, 1.57) `` ``#> BLACK OR AFRICAN AMERICAN 0.78 (0.41, 1.49) `` ``#> WHITE 1.06 (0.55, 2.04)`
