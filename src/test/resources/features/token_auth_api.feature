@dummyjson @token @functional
Feature: Token-based Authentication API (DummyJSON)
  As a QA engineer
  I want to verify JWT token authentication flows
  So that login, token-protected access, and token refresh work correctly

  Background:
    * def auth = callonce read('classpath:features/common/login.feature') { username: 'emilys', password: 'emilyspass' }

  @Scenario-1 @positive @smoke
  Scenario: Login with valid credentials returns access and refresh tokens
    Given url dummyJsonUrl + '/auth/login'
    And request { username: 'emilys', password: 'emilyspass' }
    When method post
    Then status 200
    And print response
    And match response.accessToken == '#regex .+'
    And match response.refreshToken == '#regex .+'
    And print responseStatus
    And print responseHeaders
    And print responseTime

  @Scenario-2 @positive
  Scenario: Access protected endpoint with valid Bearer token
    Given url dummyJsonUrl + '/auth/me'
    And header Authorization = 'Bearer ' + auth.accessToken
    When method get
    Then status 200
    And match response contains { username: 'emilys', firstName: 'Emily', lastName: 'Johnson', email: 'emily.johnson@x.dummyjson.com' }

  @Scenario-3 @positive
  Scenario: Refresh token returns a new access token
    # refresh with a different expiry so the new token can't be identical
    Given url dummyJsonUrl + '/auth/refresh'
    And request { refreshToken: '#(auth.refreshToken)', expiresInMins: 30 }
    When method post
    Then status 200
    And match response.accessToken == '#regex .+'
    And match response.refreshToken == '#regex .+'
    And match response.accessToken != auth.accessToken

  @Scenario-4 @negative
  Scenario: Login with invalid credentials returns error
    Given url dummyJsonUrl + '/auth/login'
    And request { username: 'emilys', password: 'wrongpassword' }
    When method post
    Then status 400
    And match response.message == 'Invalid credentials'

  @Scenario-5 @negative
  Scenario: Access protected endpoint without token returns 401
    Given url dummyJsonUrl + '/auth/me'
    When method get
    Then status 401
    And match response.message == 'Access Token is required'

  @Scenario-6 @negative
  Scenario: Access protected endpoint with invalid token returns 500
    Given url dummyJsonUrl + '/auth/me'
    And header Authorization = 'Bearer invalid.jwt.token'
    When method get
    Then status 500
