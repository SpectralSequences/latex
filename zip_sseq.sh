rm spectralsequences.zip
zip -r spectralsequences.zip spectralsequences/ \
    -i '*.sty' \
    -i '*.cls' \
    -i '*.tex' \
    -i '*.pdf' \
    -i '*.md' \
    -x '*build*' \
    -x '*test*' \
    -x '*pgfmanual-en-macros.tex' 
