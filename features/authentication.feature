Feature: Pluggable authentication

  Scenario: No authentication
    When I visit '/'
    Then I should see the editor

  Scenario: Not logged in
    Given authentication is enabled
    When I visit '/'
    Then I should be redirected to '/login'

  Scenario: Logged In
    Given authentication is enabled
    And I am logged in
    When I visit '/'
    Then I should see the editor
    And I should see my name
