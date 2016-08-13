#! /bin/bash

printf '. /tmp/_git_vars.sh \n git clone $__REPO_URL \n pwd \n ls -al \n cd $__REPO_BASEDIR \n pwd \n ls -al \n' | su - ubuntu
