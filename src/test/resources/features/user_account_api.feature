@account @functional
Feature: User Account API
  As a QA engineer
  I want to verify the CRUD operations for user accounts
  So that account creation, retrieval, update, and deletion work correctly

  Background:
    * def user =
      """
      {
          name: 'TestUser',
          email: 'jg_qa_create@testmail.com',
          password: 'Pass1234!',
          title: 'Mr',
          birth_date: '15',
          birth_month: '6',
          birth_year: '1990',
          firstname: 'Test',
          lastname: 'User',
          company: 'TestCorp',
          address1: '123 Test Street',
          address2: 'Suite 100',
          country: 'United States',
          zipcode: '10001',
          state: 'New York',
          city: 'New York',
          mobile_number: '5551234567'
      }
      """

  @Scenario-1 @positive @smoke
  Scenario: POST to create a new user account
    Given url aeUrl + 'deleteAccount'
    And form field email = user.email
    And form field password = user.password
    When method delete
    Given url aeUrl +'createAccount'
    And form fields user
    When method post
    Then status 200
    And print response
    And match response.responseCode == 201
    And match response.message == "User created!"

  @Scenario-2 @positive
  Scenario: GET user account detail by email
    Given url aeUrl + 'getUserDetailByEmail'
    And param email = user.email
    When method get
    Then status 200
    And print response
    And match response.responseCode == 200
    And match response.user.email == "jg_qa_create@testmail.com"

  @Scenario-3 @positive
  Scenario: PUT to update an existing user account
    * set user
      | path      | value         |
      | name      | 'UpdatedUser' |
      | firstname | 'Updated'     |
      | company   | 'NewCorp'     |
    Given url aeUrl + 'updateAccount'
    And form fields user
    When method put
    Then status 200
    And print response
    And match response.responseCode == 200
    And match response.message == "User updated!"
    # check that user values were updated succesfully
    Given url aeUrl + 'getUserDetailByEmail'
    And param email = user.email
    When method get
    Then status 200
    And print response
    And match response.user contains { name: 'UpdatedUser', company: 'NewCorp' }

  @Scenario-4 @positive
  Scenario: DELETE to remove a user account
    Given url aeUrl + 'deleteAccount'
    And form field email = user.email
    And form field password =  user.password
    When method delete
    Then status 200
    And print response
    And match response.responseCode == 200
    And match response.message == "Account deleted!"

  @Scenario-5 @negative
  Scenario: GET user account after deletion returns not found
    Given url aeUrl + 'getUserDetailByEmail'
    And param email = user.email
    When method get
    Then status 200
    And print response
    And match response.responseCode == 404
    And match response.message == "Account not found with this email, try another email!"
