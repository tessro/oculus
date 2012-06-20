Feature: Users can query the database

  @javascript
  Scenario: Running a new query
    When I execute "SELECT * FROM oculus_users"
    Then I should see 3 rows of results

  @javascript
  Scenario: Loading a cached query
    Given a query is cached with results:
      | id | users |
      | 1  | Paul  |
      | 2  | Amy   |
      | 3  | Peter |
    When I load the cached query
    Then I should see 3 rows of results

  @javascript
  Scenario: Null result field
    Given a query is cached with results:
      | id | users |
      | 1  |       |
    When I load the cached query
    Then I should see a null result field

  @javascript
  Scenario: Deleting a query
    Given a query is cached with results:
      | id | users |
      | 1  | Paul  |
      | 2  | Amy   |
      | 3  | Peter |
    And I am on the history page
    When I click delete
    Then I should not see any queries
