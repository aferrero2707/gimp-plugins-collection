#! /bin/bash

export REPO_SLUG="aferrero2707/gimp-plugins-collection"
export RELEASE_TAG=continuous
bash ./get-assets.sh
echo "ASSETS:"
cat assets.txt

while IFS='' read -r line || [[ -n "$line" ]]; do 
	bash ./check-${line}.sh
done < plugin-list.txt