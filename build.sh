#!/bin/bash
echo "Compiling manual"
cd manual
texify --pdf --quiet spectralsequencesmanual.tex
cd ..

echo "Compiling examples"
./compileexamples.sh
if [ $? -gt 0 ] ; then
    echo "Examples failed; quitting."
    exit 1
fi

echo "Cleanup tex output files"
/usr/bin/find -regextype egrep -regex \
    ".*\.aux|.*\.bbl|.*\.dvi|.*\.log|.*\.synctex.*|.*\.toc|.*\.out|.*\.up.*" \
    -delete
    
#echo "Applying dos2unix"
#/usr/bin/find . -type f | grep -vE ".git|.pdf" | xargs dos2unix --quiet

echo "Replacing date strings"
grep -lr "Package: spectralsequences.sty version" * | grep -vE "sh$" | xargs sed --in-place "s/Date: ....-..-../Date: $(date +%Y-%m-%d)/g"

# If a version number was supplied, replace versions:
#grep -l "Date: 2017-06-21" | xargs sed --in-place "s/Date: 2017-06-21/Date: $(date +%Y-%m-%d)/g"

echo "Zipping files"
powershell "Get-ChildItem . -r -Exclude ".git","*.sh","*.zip","*.txt" | Write-Zip -OutputPath spectralsequences.zip | Out-Null"

if [ -s commitmessage.txt ] ; then
    echo "Committing" 
    git commit -a --file commitmessage.txt
    mv commitmessage.txt commitmessage.bak.txt
    printf "" > commitmessage.txt
    echo "Pushing commit"
    git push
fi
