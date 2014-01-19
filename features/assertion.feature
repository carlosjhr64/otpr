@assertions
Feature: Assertions features

  Background:
    * Given command "ruby -I ./lib ./examples/assertion_testing"

  Scenario: No arguments, just a quick check of UsageError.
    * Given arguments ""
    * When run
    # UsageError
    * Then status is "64"

  Scenario: assert true
    * Given arguments "--assert=1,TheError"
    * When run
    * Then status is "0"
    * Then stdout is "OK"
    * Then stderr is ""

  Scenario: assert false
    * Given arguments "--assert=0,TheError"
    * When run
    * Then status is "76"
    * Then stdout is ""
    * Then stderr is "TheError"

  Scenario: refute true
    * Given arguments "--refute=1,TheError"
    * When run
    * Then status is "76"
    * Then stdout is ""
    * Then stderr is "TheError"

  Scenario: refute false
    * Given arguments "--refute=0,TheError"
    * When run
    * Then status is "0"
    * Then stdout is "OK"
    * Then stderr is ""

  Scenario: assert_equal A=A
    * Given arguments "--assert_equal=A,A,TheError"
    * When run
    * Then status is "0"
    * Then stdout is "OK"
    * Then stderr is ""

  Scenario: assert_equal A=B
    * Given arguments "--assert_equal=A,B,TheError"
    * When run
    * Then status is "76"
    * Then stdout is ""
    * Then stderr is "TheError"
