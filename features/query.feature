Feature: Users can query the database

  Scenario: Running a new query
    When I execute "SELECT * FROM oculus_users"
    Then I should see 3 rows of results

  Scenario: Loading a cached query
    Given a query is cached with results:
      | id | users |
      | 1  | Paul  |
      | 2  | Amy   |
      | 3  | Peter |
    When I load the cached query
    Then I should see 3 rows of results
