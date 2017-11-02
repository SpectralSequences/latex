#!/bin/bash

package_files=$( /usr/bin/find  | grep -E ".sty|.tex|.md" )
echo "Compiling manual"
cd manual
texify --pdf --quiet spectralsequencesmanual.tex
#latexmk -pdf -silent spectralsequencesmanual.tex
if [ $? -ne 0 ] ; then
    echo "Manual failed, quitting."
    exit 1
fi
cd ..

echo "Compiling examples"
./compileexamples.sh | tee timetest.txt
if [ ${PIPESTATUS[0]} -gt 0 ] ; then
    echo "Examples failed; quitting."
    exit 1
fi
sed -r --in-place "s/\x1B\[([0-9]{1,3}((;[0-9]{1,3})*)?)?[m|K]//g" timetest.txt

echo "Cleanup tex output files"
/usr/bin/find -regextype egrep -regex ".*\.aux|.*\.bbl|.*\.dvi|.*\.log|.*\.synctex.*|.*\.toc|.*\.out|.*\.up.*" -delete
    

# If a version number was supplied, replace versions and date strings:
if [ "$1" ] ; then
    echo "Replacing date strings and version numbers"
    echo $package_files | xargs sed --in-place "s/Date: ....-..-../Date: $(date +%Y-%m-%d)/g"
    sed --in-place "s_ProvidesPackage{spectralsequences}\[.*\]_ProvidesPackage{spectralsequences}[$(date +%Y/%m/%d) v$1]_g" spectralsequences.sty
    sed --in-place "s_version{.*}_version{Version $1}_g" manual/spectralsequencesmanual.tex
    echo $package_files | xargs sed -E --in-place "s/spectralsequences v[0-9]*\.[0-9]*\.[0-9]*[[:punct:]]?[a-z]*/spectralsequences v$1/g"
fi

echo "Zipping files"
cd ..
powershell "Get-ChildItem -r -Path spectralsequences -Include '*.sty','*.tex','*.md','*.pdf'  | Write-Zip -OutputPath spectralsequences.zip | Out-Null"
mv spectralsequences.zip spectralsequences
cd spectralsequences

if [ -s commitmessage.txt ] ; then
    echo "Applying dos2unix"
    echo $package_files | xargs dos2unix --quiet
    
    echo "Committing" 
    git commit -a --file commitmessage.txt
    mv commitmessage.txt commitmessage.bak.txt
    printf "" > commitmessage.txt
    echo "Pushing commit"
    git push
fi

if [ "$1" ] ; then
    while true; do
        read -p $'Do you wish commit the package to CTAN?\n' yn
        case $yn in
            [Yy]es ) ./ctan-upload.sh ./ctan-upload-fields.def $1; break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi
