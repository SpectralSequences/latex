which python3 # > /dev/null
RESULT=$?

mkdir -p examples_output

# On texlive docker images, we have Python but no /usr/bin/time. On my docker
# images, we have /usr/bin/time but no Python. If Python is available, use
# Python script otherwise fall back to the bash code.
if [ $RESULT -eq 0 ]; then
  python3 compile_examples.py
  exit $?
fi

allPassed=1

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

l3build install
LATEX_FLAGS="--quiet -halt-on-error -output-directory ../examples_output"

cd "examples"
for file in $(ls -1 *.tex); do
  printf "$file"
  out=( $( ( /usr/bin/timeout 100 /usr/bin/time -f %e pdflatex $LATEX_FLAGS $file 2>&1; echo $? ) | tr -d '\0' ) )
  if [ -z ${out[0]+x} ]; then
      allPassed=0
      printf " ${RED}timed out${NC}\n"
  else
      if ((${out[-1]} > 0)); then
        printf " ${RED}failed${NC}\n"
        allPassed=0
      else
        printf " ${GREEN}passed${NC} in ${out[-2]}s\n"
      fi
  fi
done
if [ $allPassed == 1 ]; then
  printf "${GREEN}All tests passed.${NC}\n"
else
    exit 1
fi

