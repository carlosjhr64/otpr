@options
Feature: Options and Usage Errors

  Background:
    * Given command "ruby -I ./lib ./bin/otpr"

  Scenario: -v
    * Given arguments "-v"
    * When run
    * Then status is "0"
    * Then stdout is "2.0.0.alpha"
    * Then stderr is ""

  Scenario: --version
    * Given arguments "--version"
    * When run
    * Then status is "0"
    * Then stdout is "2.0.0.alpha"
    * Then stderr is ""

  Scenario: -h
    * Given arguments "-h"
    * When run
    * Then status is "0"
    * Then stdout matches "^Usage:\s+otpr"
    * Then stderr is ""

  Scenario: --help
    * Given arguments "--help"
    * When run
    * Then status is "0"
    * Then stdout matches "^Usage:\s+otpr"
    * Then stderr is ""

  Scenario:  --
    * Given arguments ""
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is not ""

  Scenario:  -t
    * Given arguments "-t"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -cr
    * Given arguments "-cr"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is not ""

  Scenario:  -t -cr
    * Given arguments "-t -cr"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -t -c -r
    * Given arguments "-t -c -r"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -t --create --read
    * Given arguments "-t --create --read"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -t -c -u
    * Given arguments "-t -c -u"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -t -u -d
    * Given arguments "-t -u -d"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -t -s -C
    * Given arguments "-t -s -C"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -t -M --erase
    * Given arguments "-t -M --erase"
    * When run
    * Then status is "64"
    * Then stdout is ""
    * Then stderr is "choose_one"

  Scenario:  -t -r --media='/nosuchmedia/'
    * Given arguments "-t -r --media='/nosuchmedia/'"
    * When run
    * Then status is "75"
    * Then stdout is ""
    * Then stderr is "media_not_found"

  Scenario:  -t -r --media='/dev/null'
    * Given arguments "-t -r --media='/dev/null'"
    * When run
    * Then status is "75"
    * Then stdout is ""
    * Then stderr is "media_not_a_directory"

  Scenario:  with .otpr a file: -r --media=.
    * Then not system(test -e .otpr)
    * Given system(touch .otpr)
    * Then system(test -e .otpr)
    * Given arguments "-r --media=."
    * When run
    * Then status is "76"
    * Then stdout is ""
    * Then stderr matches "^Not a directory:"
    * Then system(rm .otpr)
    * Then not system(test -e .otpr)
