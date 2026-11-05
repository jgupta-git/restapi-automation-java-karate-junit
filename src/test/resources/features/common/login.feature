@ignore
Feature: Reusable login helper for DummyJSON
  Called by other features; not run on its own.
  Expects username and password to be passed in.

  Scenario: Login and return tokens
    Given url dummyJsonUrl + '/auth/login'
    And request { username: '#(username)', password: '#(password)' }
    When method post
    Then status 200
    * def accessToken = response.accessToken
    * def refreshToken = response.refreshToken