@main
Feature: Main features

  Background:
    * Given command "ruby -I ./lib ./bin/otpr --media=."

  Scenario: First -cbR should be able to create
    * Then not system(test -e .otpr)
    * Given arguments "-cbR"
    * When popen(key1)
    * Then status is "0"
    * Then stdout matches "^[[:graph:]]{40}$"

  Scenario: But second -cbR should be an usage error.
    * Then system(test -e .otpr)
    * Given arguments "-cbR"
    * When popen(key1)
    * Then status is "64"

  Scenario: But I can update -ubR
    * Given arguments "-ubR"
    * When popen(key1)
    * Then status is "0"
    * Then stdout matches "^[[:graph:]]{40}$"
    * Given pwd=stdout

  Scenario: And I can read -rb
    * Given arguments "-rb"
    * When popen(key1)
    * Then status is "0"
    * Then stdout==pwd

  Scenario: But I can not read a key that is not there yet
    * Given arguments "-rb"
    * When popen(KEY2)
    * Then status is "64"

  Scenario: I can copy -Cb
    * Given arguments "-Cb"
    * When popen(key1 KEY2)
    * Then status is "0"
    * Then stdout==pwd

  Scenario: I can now read KEY2
    * Given arguments "-rb"
    * When popen(KEY2)
    * Then status is "0"
    * Then stdout==pwd

  Scenario: I can still read key1
    * Given arguments "-rb"
    * When popen(key1)
    * Then status is "0"
    * Then stdout==pwd

  Scenario: I can delete key1
    * Given arguments "-db"
    * When popen(key1)
    * Then status is "0"
    * Then stdout is "OK"

  Scenario: So now I can't read key1
    * Given arguments "-rb"
    * When popen(key1)
    * Then status is "64"

  Scenario: But I can move KEY2 to key1
    * Given arguments "-Mb"
    * When popen(KEY2 key1)
    * Then status is "0"
    * Then stdout==pwd

  Scenario: So now I can't read KEY2
    * Given arguments "-rb"
    * When popen(KEY2)
    * Then status is "64"

  Scenario: But I can read key1
    * Given arguments "-rb"
    * When popen(key1)
    * Then status is "0"
    * Then stdout==pwd

  Scenario: Finally, I can erase all
    * Given arguments "-b --erase"
    * When popen(Y)
    * Then status is "0"
    * Then stdout is "OK"

    # Cleanup
    * Then system(rm -r .otpr)
