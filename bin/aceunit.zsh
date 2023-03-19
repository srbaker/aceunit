#!/usr/bin/env zsh

declare -g prefix
declare -g binary
declare -g tool
declare -g name
declare -g -A beforeAll afterAll beforeEach afterEach testcases
declare -g symbols
declare -g fixtures
declare -g -A tools

setopt shwordsplit

tool=objdump
name=fixtures

loadToolPlugins() {
    for ac in $(readlink -f $(dirname $ZSH_SCRIPT))/../share/aceunit/*.ac ; do
        source $ac
    done
}

usage() {
    echo "Usage: $ZSH_SCRIPT [OPTION]... OBJECT_FILE..." 1>&2
}

version() {
    echo "$ZSH_SCRIPT version 1.0"
}

setTool() {
    if [[ -n "${tools[$1]}" ]] ; then
        tool=$1
    else
        echo "$ZSH_SCRIPT: error: unsupported symbol table tool '$1'" >&2 ; exit 1
    fi
}

help() {
    usage
    cat <<END
Generate AceUnit fixture list from compiled testcase object files.
The generated test suite is written to STDOUT.

Options:
  -b BINARY   Use BINARY instead of the default for the selected tool.
              Example: -b m68k-amigaos-objdump
  -h          Display this help text and stop.
  -n NAME     Use NAME instead of fixtures for the fixture table.
  -p PATTERN  Prefix test functions with the specified regex PATTERN;
              PATTERN needs to be understood by grep.
              Example: -p '[^_]\+_' to allow any pattern prefix followed by an underscore.
  -s PATTERN  Strip this prefix PATTERN from symbols before using them;
              PATTERN needs to be understood by grep.
              Example: -s _ to strip a leading underscore from the symbol names.
  -t TOOL     Use TOOL for displaying the symbol table.
              Defaults to objdump.
              Supported tools: ${(k)tools}.
  -v          Print version information and stop.

Examples:
  $ZSH_SCRIPT leapyear_test.o >testcases.c
    Scans leapyear_test.o for test functions and generates the test fixtures in testcases.c.

  $ZSH_SCRIPT -t nm -b m68k-amigaos-nm -s _ leapyear_test.o >testcases.c
    Scans leapyear_test.o for test functions and generates the test fixtures in testcase.c.
    Uses nm to get the symbol table, with m68k-amigaos-nm as the binary of nm, and stripping leading underscores from the symbol names.

  $ZSH_SCRIPT -t readelf a.o b.o c.o >testcases.c
    Scans a.o, b.o, and c.o for test functions and generates the test fixtures in testcases.c.
    Uses readelf to get the symbol table.
END
    exit 0
}

getSymbols() {
    if ! which "$binary" >/dev/null ; then
        echo "$binary: File not found." 1>&2
        exit 2
    fi
    if typeset -f getSymbols_${tool} >/dev/null ; then
        getSymbols_${tool} $1 $2 $3
    else
        echo "$ZSH_SCRIPT: internal error: Unsupported tool ${tool}" 1>&2 ; exit 2
    fi
}

loadFixtures() {
    for file in $fixtures ; do loadFixture $file ; done
}

loadFixture() {
    file=$1
    basename=${file%.o}
    symbols=( $(getSymbols $file $prefix) )
     beforeAll[$basename]=$( printf '%s\n' "${symbols[@]}" | grep "^${prefix}beforeAll" )
      afterAll[$basename]=$( printf '%s\n' "${symbols[@]}" | grep "^${prefix}afterAll" )
    beforeEach[$basename]=$( printf '%s\n' "${symbols[@]}" | grep "^${prefix}beforeEach" )
     afterEach[$basename]=$( printf '%s\n' "${symbols[@]}" | grep "^${prefix}afterEach" )
     testcases[$basename]=$( printf '%s\n' "${symbols[@]}" | grep "^${prefix}test" )
}

generateHeader() {
    cat << END
#include <aceunit.h>

END
}

generateExterns() {
    for file in $fixtures; do
        basename=${file%.o}
        if [ -z "${testcases[$basename]}" ]; then echo "$file: warning: No test cases found." 1>&2; fi
        for extern in ${beforeAll[$basename]} ${afterAll[$basename]} ${beforeEach[$basename]} ${afterEach[$basename]} ${testcases[$basename]}; do
            echo "extern void $extern(void);"
        done
    done
}

generateFxitureStructures() {
    for file in $fixtures; do
        basename=${file%.o}
        echo
        echo "const aceunit_func_t testcases_${basename}[] = {"
        for testcase in ${testcases[$basename]}; do echo "    $testcase,"; done
        cat << END
    NULL,
};

const AceUnit_Fixture_t fixture_$basename = {
    ${beforeAll[$basename]:-NULL},
    ${afterAll[$basename]:-NULL},
    ${beforeEach[$basename]:-NULL},
    ${afterEach[$basename]:-NULL},
    testcases_$basename,
};

END
    done
}

generateFixtureTable() {
    cat <<END
const AceUnit_Fixture_t *${name}[] = {
END
    for file in $fixtures; do
        basename=${file%.o}
        echo "    &fixture_$basename,"
    done
    cat <<END
    NULL,
};
END
}

generateFixtures() {
    generateHeader
    generateExterns
    generateFxitureStructures
    generateFixtureTable
}

loadToolPlugins

while getopts "b:hn:p:s:t:v" o; do
    case "${o}" in
    b) binary="$OPTARG" ;;
    h) help ;;
    n) name="$OPTARG" ;;
    p) prefix="$OPTARG" ;;
    s) strip="$OPTARG" ;;
    t) setTool "$OPTARG" ;;
    v) version; exit 0 ;;
    *) usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
fixtures=$@
if [[ -z "$binary" ]] ; then
    binary=$tool
fi

loadFixtures
generateFixtures
