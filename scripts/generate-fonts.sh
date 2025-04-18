#!/bin/bash

set -e

cd packages

PACKAGES=${@:-$(ls -d */)}

for package in $PACKAGES; do
  if [ ! -f "$package/.yo-rc.json" ]; then
    continue
  fi

  echo
  echo "######################"
  echo "Building $package"
  echo "######################"
  echo

  cd $package

  if [ -n "$DIFF" ]; then
    mkdir -p "diffenator/$package"
    mkdir -p "/tmp/$package/before"
    cp fonts/*.ttf "/tmp/$package/before"
  fi

  CURRENT_VERSION=$(jq -r '.version' package.json)

  rm -rf *

  if [ "$(jq -r '."generator-react-native-vector-icons".customReadme' .yo-rc.json)" == "true" ]; then
    git restore README.md >/dev/null || true
  fi

  if [ "$(jq -r '."generator-react-native-vector-icons".customSrc' .yo-rc.json)" == "true" ]; then
    git restore src >/dev/null || true
  fi

  yo react-native-vector-icons --force --current-version=$CURRENT_VERSION

  if [ -n "$DIFF" ]; then
    mkdir -p "/tmp/$package/after"
    cp fonts/*.ttf "/tmp/$package/after"
    for font in "/tmp/$package/before/"*.ttf; do
      fontname=$(basename "$font")
      mkdir -p "diffenator/$package/$fontname"
      diffenator3 --no-tables --no-kerns --no-words --html --output "../../diffenator/$package/$fontname" "/tmp/$package/before/$fontname" "/tmp/$package/after/$fontname"
      open "../../diffenator/$package/$fontname/diffenator.html"
    done
  fi

  cd -
done

cd -
yarn
