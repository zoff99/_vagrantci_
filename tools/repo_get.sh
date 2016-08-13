#! /bin/bash

printf '. /tmp/_git_vars.sh \n git clone $__REPO_URL \n pwd \n ls -al \n cd $__REPO_BASEDIR \n git checkout $__REPO_COMMITHASH \n pwd \n ls -al \n' | su - ubuntu

function yaml2json()
{
    ruby -ryaml -rjson -e \
         'puts JSON.pretty_generate(YAML.load(ARGF))' $*
}

yaml2json /code_base/circle.yml > /tmp/circle_yml.json

cat /tmp/circle_yml.json | jq '.test.pre[1]'
cat /tmp/circle_yml.json | jq '.test'
