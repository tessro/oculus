Feature: Users can query the database

  Scenario: Running a new query
    When I execute "SELECT * FROM oculus_users"
    Then I should see 3 rows of results

  Scenario: Re-running a cached query
    When pending
