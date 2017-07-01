# Only difference between this and testsuite.sh is the timeout time is very large here.
allPassed=1
cd "examples"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

for file in $(ls -1 *.tex); do
  printf "$file"
  out=( $( ( /usr/bin/timeout 100 /usr/bin/time -f %e pdflatex --quiet $file 2>&1; echo $? ) | tr -d '\0' ) )
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

