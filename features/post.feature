Feature: posts
  Scenario: No posts, I'm logged out
    Given I am on the homepage
    Then I should see "Looks like this is a fresh install of Scanty."
      Then I should not see "New post"

  Scenario: I'm logged in, no posts
    Given I am on the admin auth
    Then I should see "Admin Auth"
    Then I fill in "password" with "changeme"
      Then I press "Login"
        And I should see "Log out"

    Given I am on the homepage
    Then I should see "Looks like this is a fresh install of Scanty."
      Then I follow "Create new post"
        And I should see "Create new post"

    # Create new simple post
    Then I follow "New post"
    And I should not see "If you want to change this blog's url to some to title"
    And I should not see "Mark post as hidden"
      Then I fill in "title" with "Test title"
      And I fill in "tags" with "supertag dupertag"
      And I fill in "content" with "  - I am a list"
      And I select "Markdown" from "format"
      Then I press "Create"
        And I should see "Test title" within "h3"
        And I should see "supertag"
        And I should see "dupertag"
        And I should see "I am a list" within "li"

    # Edit simple post
    Then I follow "Edit"
      And I should see "If you want to change this blog's url to some to title"
      And I should see "Mark post as hidden"