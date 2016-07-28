# Contributing to cordova-plugin-vuforia
### Workflow for contributing
1. Create a branch directly in this repo or a fork (if you don't have push access). Please name branches within this repository `<github username>/<description>`. For example, something like mattrayner/add-contributing-file.
1. Create an issue or open a PR. If you aren't sure your PR will solve the issue, or may be controversial, we commend opening an issue separately and linking to it in your PR, so that if the PR is not accepted, the issue will remain and be tracked.
1. Close (and reference) issues by the `closes #XXX` or `fixes #XXX` notation in the commit message. Please use a descriptive, useful commit message that could be used to understand why a particular change was made.
1. Keep pushing commits to the initial branch, `--amend`-ing if necessary. Please don't mix fixing unrelated issues in a single branch.
1. When everything is ready for merge, clean up the branch (rebase with master to synchronize, squash, edit commits, etc) to prepare for it to be merged.


### Merging contributions
We'll merge any approriate contributions after reviewing for the following:

1. Documentation.
1. Has been tested on both Android and iOS (add your plugin to the Vuforia example repo and check everything still works).
1. Passing CI tests.
1. Consistent code style. **Note:** We use BitHound and a decreasing score will block a PR.
1. Good descriptive commit messages.


### Releasing
We use SEMVER and will REV as appropriate.
