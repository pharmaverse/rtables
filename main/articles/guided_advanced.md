# A Guided Tour of rtables - Advanced

## Scope and Audience

We saw in the previous
[intermediate](https://pharmaverse.github.io/rtables/articles/guided_intermediate.md)
portion of this tour that a well engineered library of analysis, group
summary, and split functions can combine to support a massive array of
different individual tables. Whether we are tasked with maintaining and
extending those libraries or simply with creating custom tables outside
of that supported space, we sometimes need to write new custom
functions. By the end of this portion of the tour we will have the tools
necessary to do that. While gaining those tools, we will also become
more familiar with the structure of `TableTree` objects (how `rtables`
models tables) and how to interact with them once they are created.

Upon learning the material in this portion of the training, users will
be able to fully exploit the flexibility and power of the `rtables`
layout and table engines to create virtually any desired table in cases
when their existing function library falls short.

## Chapters

- [Custom Analysis and Group Summary
  Functions](https://pharmaverse.github.io/rtables/articles/guided_advanced_afuns.md)
  Core concepts for creating custom analysis and group summary functions
  - [Structure-Conditional Behavior In `afun`s With
    `.spl_context`](https://pharmaverse.github.io/rtables/articles/guided_advanced_afuns_spl_context.md)
    Creating `afun`/`cfun` behavior conditional on location within the
    table structure using `.spl_context` and other optional arguments.
  - [Calling Existing `afun`s Within Custom
    `afun`s](https://pharmaverse.github.io/rtables/articles/guided_advanced_afuns_rowsverticalsection.md)
    Details about what `in_rows` returns and how we can use that to wrap
    or combine existing `afun`s or `cfun`s
  - [Useful Behavioral Building Blocks For Complex Custom
    `afun`s](https://pharmaverse.github.io/rtables/articles/guided_advanced_afuns_building_blocks.md)
    Examples of prototypical behaviors which can be reused and combined
    when writing custom `afun`s
- [Custom Split
  Functions](https://pharmaverse.github.io/rtables/articles/guided_advanced_split_funs.md)
  Core concepts for creating custom split functions
  - [Using `make_split_fun`
    Effectively](https://pharmaverse.github.io/rtables/articles/guided_advanced_split_funs_make_split_fun.md)
    `make_split_fun` and recognizing when to specify `pre`, `core`, and
    `post` behavior customizations
  - [Using And Combining Provided Behavior Building
    Blocks](https://pharmaverse.github.io/rtables/articles/guided_advanced_split_funs_bbbs.md)
    The split function behavior building blocks provided by `rtables`
    and how to use and combine them
  - [Writing Reusable Behavior Building
    Blocks](https://pharmaverse.github.io/rtables/articles/guided_advanced_split_funs_new_bbbs.md)
    Writing new custom split function behaviors so that they are
    reusable
  - [Some Complex Worked
    Examples](https://pharmaverse.github.io/rtables/articles/guided_advanced_split_funs_worked_ex.md)
    Combining these topics to create complex custom split functions
- [Understanding and Interacting With `TableTree`
  Objects](https://pharmaverse.github.io/rtables/articles/guided_advanced_tt.md)
  Understanding how `rtables` models tables and how to interact with
  them after creation
  - [Table Structure and
    Pathing](https://pharmaverse.github.io/rtables/articles/pathing.md)
    Table structure and describing locations within a table via pathing
    (existing vignette)
  - [Accessing Values Within A
    Table](https://pharmaverse.github.io/rtables/articles/guided_advanced_tt_access.md)
    Retrieving values from a table
  - [Writing Custom Scoring Functions For
    Sorting](https://pharmaverse.github.io/rtables/articles/guided_advanced_tt_score_funs.md)
    Writing custom scoring functions for use with `sort_at_path`
  - [Writing Custom Pruning
    Functions](https://pharmaverse.github.io/rtables/articles/guided_advanced_tt_prune_funs.md)
    Writing custom pruning functions for use with `prune_table`
