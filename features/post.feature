Feature: Blog Posts
  Scenario: No posts, I am logged out
    Given I am on the homepage
    Then I should see "Looks like this is a fresh install of Scanty."
      Then I should not see "New post"

  Scenario: I am logged in, no posts
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

  Scenario: I create posts and see correct slugs
    Given I am on the admin auth
    Then I should see "Admin Auth"
    Then I fill in "password" with "changeme"
      Then I press "Login"
    # Check slug
    Given I am on the homepage
    # Almost normal page title
    Then I follow "New post"
      Then I fill in "title" with "Object-Oriented File Manipulation"
      Then I press "Create"
        And I should have "object-oriented-file-manipulation" in path
    # Abnormal page title
    Then I follow "New post"
      Then I fill in "title" with "_Rest+Client ~0.8…"
      Then I press "Create"
        And I should have "/restclient-08/" in path
    # Non-ASCII page title
    Then I follow "New post"
      Then I fill in "title" with "_ *Привет*!"
      Then I press "Create"
        And I should have "/%D0%BF%D1%80%D0%B8%D0%B2%D0%B5%D1%82/" in path
        And I should have "/привет/" in unescaped path
    # TODO: Check Unicode normalized titles
    # Non-ASCII page title
    Given I am on the homepage
    Then I follow "New post"
      Then I fill in "title" with "Привет мир"
      Then I press "Create"
        And I should have "/привет-мир/" in unescaped path
    Given I am on the homepage
    Then I follow "New post"
      Then I fill in "title" with "Привет мир"
      Then I press "Create"
        And I should have "/привет-мир-2/" in unescaped path