# A Guided Tour of rtables - Intermediate

## Scope and Audience

Now that we have an understanding of how the `rtables` framework behaves
mechanically from a user perspective, our next step is to build up
intuition for how to leverage `rtables`’ flexibility to create table
outputs that go beyond simple straightforward structures.

This portion of the guide is intended for users with a reasonable grasp
of what the individual layouting instructions do by default who want to
learn how to combine and customize their behavior to achieve complex
structured tables when a library of suitable analysis, group summary,
and split functions is already available. It is a good fit for users
looking to leverage, e.g., `tern` or `junco` to create tables without
writing custom functions themselves.

Taking full control of tabulation behavior by creating our own
functions, and understanding the layouting engine’s default behavior
will be covered in the upcoming advanced and introductory portions of
this guide, respectively. In the meantime we refer readers looking for
such content to the wide array of existing vignettes and documentation
available beyond this guided tour.

## Chapters

- [Translating Shells To
  Layouts](https://pharmaverse.github.io/rtables/articles/guided_intermediate_translating_shells.md) -
  Identifying key structural features in a table shell and mapping them
  to rtables concepts
- [Identifying Required Analysis
  Behavior](https://pharmaverse.github.io/rtables/articles/guided_intermediate_afun_reqs.md) -
  Reasoning about analysis behaviors and choosing an `afun`
- [Identifying Required Faceting
  Behavior](https://pharmaverse.github.io/rtables/articles/guided_intermediate_split_reqs.md) -
  Reasoning about faceting and choosing a split function
