Feature: Start and stop MySQL

  Scenario: Start MySQL
    Given that MySQL did not already start
    When I successfully run `mamp start mysql`
    Then the stdout should contain "Starting MySQL..."
    And MySQL should be running
