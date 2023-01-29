#!/bin/bash

package_files=$( find ! -path "*/\.*" ! -path "*/build/*" -regextype egrep -regex ".*\.sty|.*\.tex|.*\.md" )
echo package_files: $package_files
# If a version number was supplied, replace versions and date strings:
echo "Updating version number"
if [ "$1" ] ; then
    echo "Replacing date strings and version numbers"
    echo $package_files | xargs sed --in-place "s/Date: ....-..-../Date: $(date +%Y-%m-%d)/g"
    sed --in-place "s_ProvidesPackage{spectralsequences}\[.*\]_ProvidesPackage{spectralsequences}[$(date +%Y/%m/%d) v$1]_g" src/spectralsequences.sty
    sed --in-place "s_version{.*}_version{Version $1}_g" manual/spectralsequencesmanual.tex
    echo $package_files | xargs sed -E --in-place "s/spectralsequences v[0-9]*\.[0-9]*\.[0-9]*[[:punct:]]?[a-z]* ....-..-../spectralsequences v$1 $(date +%Y-%m-%d)/g"
fi
