Feature: Command Line Processing
  As a newsletter author I want to be able to send a newsletter

  Scenario: Help can be printed
    When I run bin/rumble with "-h"
    Then Exit code is zero
    And Stdout contains "--help"

  Scenario: Version can be printed
    When I run bin/rumble with "--version"
    Then Exit code is zero

  Scenario: Sending test email
    Given I have a "a.liquid" file with content:
    """
    Hi, {{ first }}
    How are you?

    """
    When I run bin/rumble with "--test yegor256@gmail.com --letter a.liquid --from me@example.com"
    Then Stdout contains "Sent 1 email"
    And Exit code is zero
