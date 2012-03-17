Feature: authentification
  Scenario: Good password
    Given I am on the admin auth
    Then I should see "Admin Auth"
    Then I fill in "password" with "changeme"
      Then I press "Login"
        And I should see "Log out"

  Scenario: Bad password
    Given I am on the admin auth
    Then I should see "Admin Auth"
    Then I fill in "password" with "phucku"
      Then I press "Login"
        And I should see "Oops! You got an error!"

