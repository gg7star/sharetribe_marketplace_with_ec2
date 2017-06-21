Feature: User sends a new message
  In order to contact another user to ask about details related to a listing or just to chat
  As a user
  I want to be able to send a private message to another users

  @javascript
  Scenario: Sending message from the profile page
    Given there are following users:
      | person |
      | kassi_testperson1 |
      | kassi_testperson2 |
    And I am logged in as "kassi_testperson2"
    And I am on the profile page of "kassi_testperson1"
    When I follow "Contact Kassi"
    And I fill in "Message" with "Random message"
    And I press "Send message"
    And I follow inbox link
    Then I should see "Random message"
    And I should not see "Awaiting confirmation from listing author"
    When I log out
    And I log in as "kassi_testperson1"
    And I follow inbox link
    Then I should not see "Accept"
    When I follow "Random message"
    Then I should not see "Accept"