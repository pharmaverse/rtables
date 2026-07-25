# {rtables} Advanced Usage

## NOTE

This vignette is currently under development. Any code or prose which
appears in a version of this vignette on the `main` branch of the
repository will work/be correct, but they likely are not in their final
form.

Initialization

``` r

library(rtables)
```

## Control splitting with provided function (limited customization)

rtables provides an array of functions to control the splitting logic
without creating an entirely new split functions. By default
`split_*_by` facets data based on categorical variable.

``` r

d1 <- subset(ex_adsl, AGE < 25)
d1$AGE <- as.factor(d1$AGE)
lyt1 <- basic_table() |>
  split_cols_by("AGE") |>
  analyze("SEX")

build_table(lyt1, d1)
```

    ##                    20   21   23   24
    ## ————————————————————————————————————
    ## F                  0    2    4    5 
    ## M                  1    1    2    3 
    ## U                  0    0    0    0 
    ## UNDIFFERENTIATED   0    0    0    0

For continuous variables, the `split_*_by_cutfun` can be leveraged to
create categories and the corresponding faceting, when the break points
are dependent from the data.

``` r

sd_cutfun <- function(x) {
  cutpoints <- c(
    min(x),
    mean(x) - sd(x),
    mean(x) + sd(x),
    max(x)
  )

  names(cutpoints) <- c("", "Low", "Medium", "High")
  cutpoints
}

lyt1 <- basic_table() |>
  split_cols_by_cutfun("AGE", cutfun = sd_cutfun) |>
  analyze("SEX")

build_table(lyt1, ex_adsl)
```

    ##                    Low   Medium   High
    ## ——————————————————————————————————————
    ## F                  36     165      21 
    ## M                  21     115      30 
    ## U                   1      8       0  
    ## UNDIFFERENTIATED    0      1       2

Alternatively, `split_*_by_cuts` can be used when breakpoints are
predefined and `split_*_by_quartiles` when the data should be faceted by
quantile.

``` r

lyt1 <- basic_table() |>
  split_cols_by_cuts(
    "AGE",
    cuts = c(0, 30, 60, 100),
    cutlabels = c("0-30 y.o.", "30-60 y.o.", "60-100 y.o.")
  ) |>
  analyze("SEX")

build_table(lyt1, ex_adsl)
```

    ##                    0-30 y.o.   30-60 y.o.   60-100 y.o.
    ## ———————————————————————————————————————————————————————
    ## F                     71          150            1     
    ## M                     48          116            2     
    ## U                      2           7             0     
    ## UNDIFFERENTIATED       1           2             0

## Custom Split Functions

### Adding an Overall Column Only When The Split Would Already Define 2+ Facets

Our custom split functions can do anything, including conditionally
applying one or more other existing custom split functions.

Here we define a function constructor which accepts the variable name we
want to check, and then return a custom split function that has the
behavior you want using functions provided by rtables for both cases:

``` r

picky_splitter <- function(var) {
  function(df, spl, vals, labels, trim) {
    orig_vals <- vals
    if (is.null(vals)) {
      vec <- df[[var]]
      vals <- if (is.factor(vec)) levels(vec) else unique(vec)
    }
    if (length(vals) == 1) {
      do_base_split(spl = spl, df = df, vals = vals, labels = labels, trim = trim)
    } else {
      add_overall_level(
        "Overall",
        label = "All Obs", first = FALSE
      )(df = df, spl = spl, vals = orig_vals, trim = trim)
    }
  }
}


d1 <- subset(ex_adsl, ARM == "A: Drug X")
d1$ARM <- factor(d1$ARM)

lyt1 <- basic_table() |>
  split_cols_by("ARM", split_fun = picky_splitter("ARM")) |>
  analyze("AGE")
```

This gives us the desired behavior in both the one column corner case:

``` r

build_table(lyt1, d1)
```

    ##        A: Drug X
    ## ————————————————
    ## Mean     33.77

and the standard multi-column case:

``` r

build_table(lyt1, ex_adsl)
```

    ##        A: Drug X   B: Placebo   C: Combination   All Obs
    ## ————————————————————————————————————————————————————————
    ## Mean     33.77       35.43          35.43         34.88

Notice we use add_overall_level which is itself a function constructor,
and then immediately call the constructed function in the
more-than-one-columns case.

## Leveraging `.spl_context`

### What Is `.spl_context`?

`.spl_context` (see
[`?spl_context`](https://pharmaverse.github.io/rtables/reference/spl_context.md))
is a mechanism by which the `rtables` tabulation machinery gives custom
split, analysis or content (row-group summary) functions information
about the overarching facet-structure the splits or cells they generate
will reside in.

In particular `.spl_context` ensures that your functions know (and thus
do computations based on) the following types of information:

- 

### Different Formats For Different Values Within A Row-Split

``` r

dta_test <- data.frame(
  USUBJID = rep(1:6, each = 3),
  PARAMCD = rep("lab", 6 * 3),
  AVISIT = rep(paste0("V", 1:3), 6),
  ARM = rep(LETTERS[1:3], rep(6, 3)),
  AVAL = c(9:1, rep(NA, 9)),
  CHG = c(1:9, rep(NA, 9))
)

my_afun <- function(x, .spl_context) {
  n <- sum(!is.na(x))
  meanval <- mean(x, na.rm = TRUE)
  sdval <- sd(x, na.rm = TRUE)

  ## get the split value of the most recent parent
  ## (row) split above this analyze
  val <- .spl_context[nrow(.spl_context), "value"]
  ## do a silly thing to decide the different format precisiosn
  ## your real logic would go here
  valnum <- min(2L, as.integer(gsub("[^[:digit:]]*", "", val)))
  fstringpt <- paste0("xx.", strrep("x", valnum))
  fmt_mnsd <- sprintf("%s (%s)", fstringpt, fstringpt)
  in_rows(
    n = n,
    "Mean, SD" = c(meanval, sdval),
    .formats = c(n = "xx", "Mean, SD" = fmt_mnsd)
  )
}

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("AVISIT") |>
  split_cols_by_multivar(vars = c("AVAL", "CHG")) |>
  analyze_colvars(my_afun)

build_table(lyt, dta_test)
```

    ##                          A                         B                 C     
    ##                 AVAL           CHG         AVAL         CHG      AVAL   CHG
    ## ———————————————————————————————————————————————————————————————————————————
    ## V1                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD    7.5 (2.1)     2.5 (2.1)    3.0 (NA)    7.0 (NA)     NA    NA 
    ## V2                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   6.50 (2.12)   3.50 (2.12)   2.00 (NA)   8.00 (NA)    NA    NA 
    ## V3                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   5.50 (2.12)   4.50 (2.12)   1.00 (NA)   9.00 (NA)    NA    NA

### Simulating ‘Baseline Comparison’ In Row Space

``` r

my_afun <- function(x, .var, .spl_context) {
  n <- sum(!is.na(x))
  meanval <- mean(x, na.rm = TRUE)
  sdval <- sd(x, na.rm = TRUE)

  ## get the split value of the most recent parent
  ## (row) split above this analyze
  val <- .spl_context[nrow(.spl_context), "value"]
  ## we show it if its not a CHG within V1
  show_it <- val != "V1" || .var != "CHG"
  ## do a silly thing to decide the different format precisiosn
  ## your real logic would go here
  valnum <- min(2L, as.integer(gsub("[^[:digit:]]*", "", val)))
  fstringpt <- paste0("xx.", strrep("x", valnum))
  fmt_mnsd <- if (show_it) sprintf("%s (%s)", fstringpt, fstringpt) else "xx"
  in_rows(
    n = if (show_it) n, ## NULL otherwise
    "Mean, SD" = if (show_it) c(meanval, sdval), ## NULL otherwise
    .formats = c(n = "xx", "Mean, SD" = fmt_mnsd)
  )
}

lyt <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("AVISIT") |>
  split_cols_by_multivar(vars = c("AVAL", "CHG")) |>
  analyze_colvars(my_afun)

build_table(lyt, dta_test)
```

    ##                          A                         B                 C     
    ##                 AVAL           CHG         AVAL         CHG      AVAL   CHG
    ## ———————————————————————————————————————————————————————————————————————————
    ## V1                                                                         
    ##   n               2                          1                    0        
    ##   Mean, SD    7.5 (2.1)                  3.0 (NA)                 NA       
    ## V2                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   6.50 (2.12)   3.50 (2.12)   2.00 (NA)   8.00 (NA)    NA    NA 
    ## V3                                                                         
    ##   n               2             2            1           1        0      0 
    ##   Mean, SD   5.50 (2.12)   4.50 (2.12)   1.00 (NA)   9.00 (NA)    NA    NA

We can further simulate the formal modeling of reference row(s) using
the `extra_args` machinery

``` r

my_afun <- function(x, .var, ref_rowgroup, .spl_context) {
  n <- sum(!is.na(x))
  meanval <- mean(x, na.rm = TRUE)
  sdval <- sd(x, na.rm = TRUE)

  ## get the split value of the most recent parent
  ## (row) split above this analyze
  val <- .spl_context[nrow(.spl_context), "value"]
  ## we show it if its not a CHG within V1
  show_it <- val != ref_rowgroup || .var != "CHG"
  fmt_mnsd <- if (show_it) "xx.x (xx.x)" else "xx"
  in_rows(
    n = if (show_it) n, ## NULL otherwise
    "Mean, SD" = if (show_it) c(meanval, sdval), ## NULL otherwise
    .formats = c(n = "xx", "Mean, SD" = fmt_mnsd)
  )
}

lyt2 <- basic_table() |>
  split_cols_by("ARM") |>
  split_rows_by("AVISIT") |>
  split_cols_by_multivar(vars = c("AVAL", "CHG")) |>
  analyze_colvars(my_afun, extra_args = list(ref_rowgroup = "V1"))

build_table(lyt2, dta_test)
```

    ##                        A                      B                C     
    ##                AVAL         CHG        AVAL       CHG      AVAL   CHG
    ## —————————————————————————————————————————————————————————————————————
    ## V1                                                                   
    ##   n              2                      1                   0        
    ##   Mean, SD   7.5 (2.1)               3.0 (NA)               NA       
    ## V2                                                                   
    ##   n              2           2          1          1        0      0 
    ##   Mean, SD   6.5 (2.1)   3.5 (2.1)   2.0 (NA)   8.0 (NA)    NA    NA 
    ## V3                                                                   
    ##   n              2           2          1          1        0      0 
    ##   Mean, SD   5.5 (2.1)   4.5 (2.1)   1.0 (NA)   9.0 (NA)    NA    NA
