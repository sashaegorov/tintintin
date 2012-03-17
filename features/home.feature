Feature: view pages
  Scenario: Home page
    Given I am on the homepage
    Then I should see "scanty blog"
    And I should not see "Hello, world!"

  Scenario: Goto Admin Auth page
    Given I am on the homepage
    Then I follow "Log in"
    Then I should see "Admin Auth"
