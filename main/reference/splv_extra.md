# Access or set child-specific extra arguments on a split value

`splv_extra` retrieves the named list of *child-specific* extra
arguments stored on a `SplitValue` object. These arguments are forwarded
to the analysis or content function only for the facet represented by
that particular split value, making them distinct from
[`split_exargs()`](https://pharmaverse.github.io/rtables/reference/int_methods.md)
which applies to *all* children of a split.

## Usage

``` r
splv_extra(obj)

# S4 method for class 'SplitValue'
splv_extra(obj)

splv_extra(obj) <- value

# S4 method for class 'SplitValue'
splv_extra(obj) <- value
```

## Arguments

- obj:

  (`SplitValue`)\
  a split value object, typically produced by
  [`SplitValue()`](https://pharmaverse.github.io/rtables/reference/SplitValue.md)
  or as a result of a splitting operation.

- value:

  (`list`)\
  named list of extra arguments to store on `obj`.

## Value

- `splv_extra` returns the current `list` of child-specific extra args.

- `splv_extra<-` returns `obj` with the extra arguments replaced.

## See also

[`split_exargs()`](https://pharmaverse.github.io/rtables/reference/int_methods.md)
for split-level (all-children) extra arguments.

## Examples

``` r
sv <- SplitValue("A", extr = list(my_arg = 1))
splv_extra(sv)
#> $my_arg
#> [1] 1
#> 

splv_extra(sv) <- list(my_arg = 99)
splv_extra(sv)
#> $my_arg
#> [1] 99
#> 
```
