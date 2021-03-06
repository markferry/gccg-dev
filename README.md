gccg-dev
============
Generic Collectible Card Game dev super-project

Trees
------
*    gccg-dev/core/ - git subtree following gccg sf.net core
*    gccg-dev/mythos/ - git submodule linking to external gccg-mythos-data project

Branches
---------
*    master
*    svn-core [svn subtree tracking branch]
*    git-core [git subtree tracking branch]
*    remotes/github/master [github remote master]
*    remotes/github/svn-core [github remote svn-track]
*    remotes/svn-core [git-svn]

Tracking
----------
  master -> remotes/github/master
  svn-core -> (remotes/svn-core)
  git-core -> (remotes/github/svn-core)

  svn-core --subtree--> master:core/

Workflow
==========

Push non-core changes
----------------------
    git push github master

Pull upstream svn
----------------------
    git svn fetch svn-core
    git checkout svn-core
    git merge remotes/svn-core
    git checkout -f master # force because of mythos subtree "overwrite"
    git subtree merge -P core --squash -m "merge upstream svn to core subtree" svn-core
    git checkout git-core # warning: mythos dir not empty
    git merge svn-core    # fast forward
    git push github master
    git push github git-core:svn-core
    git checkout -f master

Push upstream svn
----------------------
    git subtree split -P core -b svn-core
    git checkout svn-core
    git svn dcommit
    git push github git-core:svn-core
    # NB! merge following dcommit
    git checkout master
    git subtree merge -P core --squash -m "merge dcommit" svn-core

