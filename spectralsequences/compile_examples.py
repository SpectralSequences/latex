import os
import pathlib
import subprocess
import sys

from time import perf_counter

RED = "\033[0;31m"
GREEN = "\033[0;32m"
NC = "\033[0m"

LATEX_FLAGS = ["--quiet", "-halt-on-error", "-output-directory", "../examples_output"]


def main():
    os.chdir("examples")
    for example in sorted(pathlib.Path(".").glob("*.tex")):
        print(example.name, end="")
        sys.stdout.flush()
        t0 = perf_counter()
        res = subprocess.run(["pdflatex", *LATEX_FLAGS, example], capture_output=True)
        t1 = perf_counter()
        if res.returncode == 0:
            print(f"{GREEN} passed in {t1 - t0:.2f}s{NC}")
        else:
            print(f"{RED} failed in {t1 - t0:.2f}s{NC}")


if __name__ == "__main__":
    main()
