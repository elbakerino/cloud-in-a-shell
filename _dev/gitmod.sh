#!/bin/bash

find . -type f -name "*.sh" -print0 | xargs -0 git update-index --chmod=+x

git add *
git commit --author="bemitbot <bot@bemit.codes>" -m "chmod"

git rm --cached -r .

git reset --hard
