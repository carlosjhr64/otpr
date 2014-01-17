@main
Feature: Main features

  Background:
    * Given command "ruby -I ./lib ./bin/otpr"

  Scenario: -v
    * Given arguments "-v"
    * When run
    * Then status is "0"
    * Then stdout is "2.0.0"
    * Then stderr is ""
