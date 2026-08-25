# Contributing to {rtables}

We welcome contributions big and small to the ongoing development of the
{rtables} package. For most, the best way to contribute to the package
is by filing issues for feature requests or bugs that you have
encountered. For those who are interested in contributing code to the
package, contributions can be made by working on current issues and
opening pull requests with code changes. Any help that you are able to
provide is greatly appreciated!

Contributions to this project are
[released](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service#6-contributions-under-repository-license)
to the public under the project’s open source license.

------------------------------------------------------------------------

## Filing Issues

Issues are used to establish a prioritized timeline and track
development progress within the package. If there is a new feature that
you feel would be enhance the experience of package users, please open a
[Feature Request
issue](https://github.com/insightsengineering/rtables/issues/new?labels=enhancement&template=feature.yml&title=%5BFeature+Request%5D%3A+%3Ctitle%3E).
If you notice a bug in the existing code, please file a [Bug Fix
issue](https://github.com/insightsengineering/rtables/issues/new?&labels=bug&template=bug.yml&title=%5BBug%5D%3A+%3Ctitle%3E)
with a description of the bug and a
[reprex](https://reprex.tidyverse.org/) (reproducible example). Other
types of issues (questions, typos you’ve noticed, improvements to
documentation, etc.) can be filed as well. Click
[here](https://github.com/insightsengineering/rtables/issues/new/choose)
to file a new issue, and
[here](https://github.com/insightsengineering/rtables/issues) to see the
list of current issues. Please utilize labels wherever possible when
creating issues for organization purposes and to narrow down the scope
of the work required.

------------------------------------------------------------------------

## Creating Pull Requests

Development of the {rtables} package relies on an *Issue → Branch → PR →
Code Review → Merge* pipeline facilitated through GitHub. If you are a
more experienced programmer interested in contributing to the package
code, please begin by filing an issue describing the changes you would
like to make. It may be the case that your idea has already been
implemented in some way, and the package maintainers can help to
determine whether the feature is necessary before you begin development.
Whether you are opening an issue or a pull request, the more detailed
your description, the easier it will be for package maintainers to help
you! To make code changes in the package, please follow the following
process.

### Pull Request Process

The {rtables} package is part of the NEST project and utilizes
[staged.dependencies](https://github.com/openpharma/staged.dependencies)
to ensure to simplify the development process and track upstream and
downstream package dependencies. We highly recommend installing and
using this package when developing within {rtables}.

#### 1. Create a branch

In order to work on a new pull request, please first create a branch off
of `main` upon which you can work and commit changes. To comply with
[`staged.dependencies`](https://github.com/openpharma/staged.dependencies)
standards, {rtables} uses the following branch naming convention:

`issue#_description_of_issue@target_merge_branch`

For example, `443_refactor_splits@main`. In most cases, the target merge
branch is the base (`main`) branch.

In some cases, a change in {rtables} may first require upstream changes
in the {formatters} package. Suppose we have branch
`100_update_fmts@main` in {formatters} containing the required upstream
changes. Then the branch created in {rtables} would be named as follows
for this example: `443_refactor_splits@100_update_fmts@main`. This
ensures that the correct branches are checked out when running tests,
etc.

For more details on `staged.dependencies` branch naming conventions,
[click
here](https://github.com/openpharma/staged.dependencies#branch-naming-convention).

#### 2. Code

Work within the {rtables} package to apply your code changes. Avoid
combining issues on a single branch - ideally, each branch should be
associated with a single issue and be prefixed by the issue number.

For information on the basics of the {rtables} package, please read the
package vignettes, which are available
[here](https://insightsengineering.github.io/rtables/latest-tag/articles/index.html).

For advanced development work within {rtables}, consider reading through
the {rtables} Developer Guide. The Developer Guide can be accessed from
the {rtables} site navigation bar, and is listed here for your
convenience:

- [Developer Guide: Split
  Machinery](https://insightsengineering.github.io/rtables/latest-tag/articles/dev-guide/dg_split_machinery.html)
- [Developer Guide:
  Tabulation](https://insightsengineering.github.io/rtables/latest-tag/articles/dev-guide/dg_tabulation.html)
- [Developer Guide: Debugging in {rtables} and
  Beyond](https://insightsengineering.github.io/rtables/latest-tag/articles/dev-guide/dg_debug_rtables.html)
- [Developer Guide: Sparse Notes on {rtables}
  Internals](https://insightsengineering.github.io/rtables/latest-tag/articles/dev-guide/dg_notes.html)

##### Code style

The {rtables} package follows the tidyverse [style
guide](https://style.tidyverse.org/index.html) so please adhere to these
guidelines in your submitted code. After making changes to a file within
the package, you can apply the package styler automatically and check
for lint by running the following two lines of code while within the
file:

`styler``:::``style_active_file``(``)`` ``lintr``:::``addin_lint``(``)`

##### Documentation

Package documentation uses
[`roxygen2`](https://roxygen2.r-lib.org/index.html). If your
contribution requires updates to documentation, ensure that the roxygen
comments are updated within the source code file. After updating roxygen
documentation, run
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
to update the accompanying `.Rd` files (do not update these files by
hand!).

##### Tests

To ensure high code coverage, we create tests using the
[`testthat`](https://testthat.r-lib.org/) package. In most cases,
changes to package code necessitate the addition of one or more tests to
ensure that any added features are working as expected and no existing
features were broken.

##### NEWS

After making updates to the package, please add a descriptive entry to
the NEWS file that reflects your changes. See the [tidyverse style
guide](https://style.tidyverse.org/news.html) for guidelines on creating
a NEWS entry.

#### 3. Make a Pull Request

Once the previous two steps are complete, you can create a pull request.
Indicate in the description which issue is addressed in the pull
request, and again utilize labels to help reviewers identify the
category of the changes contained within the pull request.

Once your pull request has been created, a series of checks will be
automatically triggered, including `R CMD check`, tests/code coverage,
auto-documentation, and more. All checks must be passing in order to
eventually merge your pull request, and further changes may be required
in order to resolve the status of these checks. All pull requests must
also be reviewed and approved by at least one of the package maintainers
before they can be merged. A review will be automatically requested from
several {rtables} maintainers upon creating your pull request. When a
maintainer reviews your pull request, please try to address the comments
in short order - the {rtables} package is updated on a regular basis and
leaving a pull request open too long is likely to result in merge
conflicts which create more work for the developer.

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://pharmaverse.github.io/rtables/CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.
