#! /bin/bash

rm -rf gmic-qt ;git clone https://github.com/c-koi/gmic-qt.git || exit 1
cd gmic-qt || exit 1
git rev-parse --verify HEAD > /tmp/commit-GMIC-new.hash
rm -rf gmic-clone; git clone https://github.com/dtschump/gmic.git gmic-clone || exit 1
cd gmic-clone
git rev-parse --verify HEAD >> /tmp/commit-GMIC-new.hash
cd ../../

HASH=$(cat assets.txt | grep "^GMIC-" | grep '.hash$')
echo "Commit HASH: \"$HASH\""

if [ -n "$HASH" ]; then
	echo "curl -L https://github.com/${REPO_SLUG}/releases/tag/${RELEASE_TAG}/$HASH"
	curl -L https://github.com/${REPO_SLUG}/releases/tag/${RELEASE_TAG}/$HASH > /tmp/commit-GMIC-old.hash 
	result=$?
	if [ x"$result"	= "x0" ]; then
		echo "commit-GMIC-old.hash:"; cat /tmp/commit-GMIC-old.hash
		echo "commit-GMIC-new.hash:"; cat /tmp/commit-GMIC-new.hash
		diff -q /tmp/commit-GMIC-new.hash /tmp/commit-GMIC-old.hash
		result=$?
		if [ x"$result"	= "x0" ]; then exit; fi
	fi
fi

echo "Triggering rebuild of GMIC"

git clone -b master https://github.com/aferrero2707/gimp-plugins-collection.git /tmp/gimp-plugins-collection
cd /tmp/gimp-plugins-collection
git checkout -b GMIC
git pull origin GMIC
git merge master
cat travis.yml.template | sed -e 's|%OS%|osx|g' | sed -e 's|%PLUGIN%|GMIC|g' > .travis.yml
echo "$RANDOM" > random.txt
git add -A
git commit -m "Updated Travis configuration"
git push https://aferrero2707:${GITHUB_TOKEN}@github.com/${REPO_SLUG}.git GMIC