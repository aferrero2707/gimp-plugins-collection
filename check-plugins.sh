#! /bin/bash

export REPO_SLUG="aferrero2707/gimp-plugins-collection"
export RELEASE_TAG=continuous
bash ./get-assets.sh
echo "ASSETS:"
cat assets.txt

while IFS='' read -r line || [[ -n "$line" ]]; do
	if [ -e ./check-${line}.sh ]; then bash ./check-${line}.sh; fi
done < plugin-list.txt