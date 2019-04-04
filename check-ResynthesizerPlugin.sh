#! /bin/bash

PLUGIN=ResynthesizerPlugin

rm -rf resynthesizer; git clone https://github.com/bootchk/resynthesizer.git || exit 1
cd resynthesizer || exit 1
git rev-parse --verify HEAD > /tmp/commit-${PLUGIN}-new.hash
cd ..

for OS in "osx" "linux"; do
#for OS in "linux"; do

HASH=$(cat assets.txt | grep "^${PLUGIN}-" | grep "${OS}." | grep '.hash$')
echo "Commit HASH: \"$HASH\""

if [ -n "$HASH" ]; then
	echo "curl -L https://github.com/${REPO_SLUG}/releases/download/${RELEASE_TAG}/$HASH"
	curl -L https://github.com/${REPO_SLUG}/releases/download/${RELEASE_TAG}/$HASH > /tmp/commit-${PLUGIN}-old.hash 
	result=$?
	if [ x"$result"	= "x0" ]; then
		echo "commit-${PLUGIN}-old.hash:"; cat /tmp/commit-${PLUGIN}-old.hash
		echo "commit-${PLUGIN}-new.hash:"; cat /tmp/commit-${PLUGIN}-new.hash
		diff -q /tmp/commit-${PLUGIN}-new.hash /tmp/commit-${PLUGIN}-old.hash
		result=$?
		if [ x"$result"	= "x0" ]; then exit; fi
	fi
fi

echo "Triggering rebuild of Resynthesizer"

WD=$(pwd)
git clone -b master https://github.com/aferrero2707/gimp-plugins-collection.git /tmp/gimp-plugins-collection
cd /tmp/gimp-plugins-collection
git checkout -b ${PLUGIN}-${OS}
git pull origin ${PLUGIN}-${OS}
git merge master
cat travis.yml.template-${OS} | sed -e "s|%PLUGIN%|${PLUGIN}|g" > .travis.yml
echo "$RANDOM" > random.txt
git add -A
git commit -m "Updated Travis configuration"
git push https://aferrero2707:${GITHUB_TOKEN}@github.com/${REPO_SLUG}.git ${PLUGIN}-${OS}

cd "$WD" || exit 1

done