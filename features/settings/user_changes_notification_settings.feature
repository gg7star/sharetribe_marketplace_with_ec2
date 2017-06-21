Feature: User changes notification settings
  In order to start or stop getting email notifications about various events in Sharetribe
  As a user
  I want to be able to change my notification settings

  Scenario: User changes notification settings successfully
    Given there are following users:
      | person |
      | kassi_testperson1 |
    And I am logged in as "kassi_testperson1"
    When I open user menu
    When I follow "Settings"
    And I follow "notifications_left_navi_link"
    And the "...someone comments on my offer or request" checkbox should be checked
    And the "...someone sends me a message" checkbox should be checked
    And the "Send me a daily newsletter if there are new listings" checkbox should be checked
    And I uncheck "...someone comments on my offer or request"
    And I choose "do_not_email_community_updates"
    And I press "Save information"
    Then I should see "Information updated"
    And the "...someone comments on my offer or request" checkbox should not be checked
    And the "Send me a daily newsletter if there are new listings" checkbox should not be checked
    And the "Don't send me newsletters" checkbox should be checked
    And the "...someone sends me a message" checkbox should be checked



