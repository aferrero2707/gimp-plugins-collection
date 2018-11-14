#! /bin/bash

#REPO_SLUG="$1"
#RELEASE_TAG="$2"
	
rm -f assets.txt
	
echo "URL: https://api.github.com/repos/${REPO_SLUG}/releases/tags/${RELEASE_TAG}"
RESPONSE=$(curl -XGET --header "Authorization: token ${GITHUB_TOKEN}"  "https://api.github.com/repos/${REPO_SLUG}/releases/tags/${RELEASE_TAG}")
echo "RESPONSE: $RESPONSE"
RELEASE_ID=$(echo "$RESPONSE" |  grep '"id":' | head -n 1 | tr -s ' ' | cut -d':' -f 2 | tr -d ' ' | cut -d',' -f 1)
echo "RELEASE_ID: $RELEASE_ID"
	
	
RELEASE_ASSETS=$(curl -XGET "https://api.github.com/repos/${REPO_SLUG}/releases/${RELEASE_ID}/assets")
ASSET_IDS=$(echo "$RELEASE_ASSETS" | grep '^    "id":')
ASSET_NAMES=$(echo "$RELEASE_ASSETS" | grep '^    "name":')
NASSETS=$(echo "$ASSET_IDS" | wc -l)
NASSETS2=$(echo "$ASSET_NAMES" | wc -l)
echo "NASSETS:  $NASSETS"
echo "NASSETS2: $NASSETS2"

echo "$ASSET_NAMES"

rm -f assets.txt

for AID in $(seq 1 $NASSETS); do
	ID=$(echo "$ASSET_IDS" | sed -n ${AID}p | tr -s " " | cut -f 3 -d" " | cut -f 1 -d ",")
	NAME=$(echo "$ASSET_NAMES" | sed -n ${AID}p | cut -d':' -f 2 | tr -d ' ' | cut -d'"' -f 2)
	echo "$NAME"
	echo "$NAME" >> assets.txt
done