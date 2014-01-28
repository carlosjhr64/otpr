@edge
Feature: Edge Cases

  Background:
    * Given command "ruby -I ./lib ./bin/otpr -t --media=."

  # First Create A Pin
  Scenario: First -cbR should be able to create
    * Then not system(test -e .otpr)
    * Given arguments "-cbR"
    * When popen(key1)
    * Then status is "0"
    * Then stdout matches "^[[:graph:]]{40}$"
    * Given pwd=stdout

  # Verify The Pin
  Scenario: And I can read -rb
    * Given arguments "-rb"
    * When popen(key1)
    * Then status is "0"
    * Then stdout==pwd

  # Status OK?
  Scenario: -b --status
    * Given arguments "-b --status"
    * When popen(key1)
    * Then status is "0"
    * Then stdout is "OK"

  # Status NOT FOUND?
  Scenario: -b --status
    * Given arguments "-b --status"
    * When popen(key2)
    * Then status is "66"
    * Then stdout is "NOT FOUND"

  # Status NOT INCONSISTENT?
  Scenario: -b --status
    * Given system(rm .otpr/`ls .otpr | grep -v salt`)
    * Given arguments "-b --status"
    * When popen(key1)
    * Then status is "76"
    * Then stdout is "INCONSISTENT"

  # Protocol Error
  Scenario: And now I can't read -rb
    * Given arguments "-rb"
    * When popen(key1)
    * Then status is "76"
    * Then stdout is ""
    * Then stderr is "pin_inconsistent"

    # Cleanup
    * Then system(rm -r .otpr)
