#!/usr/bin/python3
import argparse
import re
import git
from typing import Optional
from typing import Sequence

MODULE_PATTERN = (
    r'source\s*=\s*"(?:(?:git::https:\/\/)?|(?:git\@)?)?'
    r'([./-0-9a-zA-Z:_]*)(\?ref=)?([\w.-]+)?"'
)
IGNORE_CHECK = "#disable-module-check"


def git_repo_check(module, file, linenum):
    if ".git" in module:
        git_url = "git://" + module.split(".git")[0] + ".git"
    else:
        if "//" in module:
            git_url = "https://" + module.split("//")[0]
        else:
            git_url = "https://" + module
    g = git.cmd.Git()
    try:
        g.ls_remote("--tags", git_url).split("\n")
    except Exception as e:
        print(
            f"{file}:{linenum}: Incorrect URL for module "
            f'"{module}". Error: {e}'
        )
        return False
    return True


def check_file(file, pattern):
    retv = 0
    readfile = open(file, "r")

    for num, line in enumerate(readfile, 1):
        if IGNORE_CHECK in line:
            continue
        else:
            matches = re.findall(rf"{pattern}", line, re.I | re.M)
            if len(matches) > 0:
                for module in matches:
                    if (len(module[1]) > 0) and (len(module[2]) > 0):
                        if module[2] == "master" or module[2] == "main":
                            print(
                                f'{file}:{num}: Module "{module[0]}" references master'
                            )
                            retv = 1
                        else:
                            if not git_repo_check(module[0], file, num):
                                retv = 1
                    else:
                        print(
                            f'{file}:{num}: Module "{module[0]}" is '
                            f"not pinned with a version"
                        )
                        retv = 1
    return retv


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Checks for incorrect source module usage."
    )
    parser.add_argument("filenames", nargs="*", help="Filenames to check")
    args = parser.parse_args(argv)

    return_value = 0

    for filename in args.filenames:
        if (str(filename))[-3:] == ".tf" or (str(filename))[-4:] == ".hcl":
            return_value = return_value + check_file(filename, MODULE_PATTERN)

    return return_value


if __name__ == "__main__":
    exit(main())
