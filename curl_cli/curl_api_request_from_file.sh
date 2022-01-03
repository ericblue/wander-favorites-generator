#!/bin/sh

curl --silent --location --request POST 'http://localhost:3000/generate-favorites?folder=MyFolderName' \
--header 'Content-Type: text/plain' \
--data-binary "@./locations.txt"| \
jq -c '.favorites_json | fromjson' | jq .