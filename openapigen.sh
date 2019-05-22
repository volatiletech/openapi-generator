#!/bin/sh 

format_elm() {
   echo "module OpenApi.Data exposing ("

   grep --no-filename --extended-regexp '^module' OpenApi/Data/*.elm \
        | sed --regexp-extended 's@^.* exposing \((.*)\).*$@\1@' \
        | awk '{ if (NR != 1) printf "    , %s\n", $0; else printf "    %s\n", $0 }'

   echo "    )"
   echo

   grep --no-filename --extended-regexp '^import' OpenApi/Data/*.elm \
        | grep --no-filename --extended-regexp --invert-match '^import OpenApi\.Data\.' \
        | sort --unique

   grep --no-filename --extended-regexp --invert-match '^module' OpenApi/Data/*.elm \
        | grep --extended-regexp --invert-match '^import'
}

cd ~/openapi/openapi-generator/ &&
rm -rf out/src/OpenApi/* && \
      ./run-in-docker.sh mvn package -DskipTests && \
      ./run-in-docker.sh generate -i /gen/petstore.yaml -o out/src -g elm-lib && \
      cd out/src && format_elm > OpenApi/Data.elm && rm -rf OpenApi/Data

