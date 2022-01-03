#!/bin/sh

curl --silent --location --request POST 'http://localhost:3000/generate-favorites?folder=MyFolderName' \
--header 'Content-Type: text/plain' \
--data-raw \
'Los Angeles|LA
New York,The Big Apple' | \
jq -c '.favorites_json | fromjson' | jq .