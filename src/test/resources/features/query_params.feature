@dummyjson @functional @query-params
Feature: DummyJSON Products API - Query Parameters
  As a QA engineer
  I want to verify query parameter handling for DummyJSON Products API
  So that pagination, field selection, category filtering, and search work correctly

  @Scenario-1 @positive @smoke
  Scenario: GET products with limit and skip for pagination
    Given url dummyJsonUrl + '/products'
    And param limit = 5
    And param skip = 10
    When method get
    Then status 200
    And print 'Request URL:', karate.prevRequest.url
    And print karate.prevRequest.method
    And print karate.prevRequest.headers
    And print response
    And match response.products == '#[5]'
    And match response contains { skip: 10, limit: 5 }
    And assert responseTime < 3000

  @Scenario-2 @positive
  Scenario: GET products with select to return specific fields only
    Given url dummyJsonUrl + '/products'
    And param select = "title,price"
    When method get
    Then status 200
    And print response
    And match each response.products ==
      """
      {
        "id": '#number',
        "title": '#string',
        "price": '#number'
      }
      """

  @Scenario-3 @positive
  Scenario: GET products by category
    Given url dummyJsonUrl + '/products/category/smartphones'
    When method get
    Then status 200
    And print response
    And match each response.products contains
      """
      {
        "id": '#number',
        "title": '#string',
        "description": '#string',
        "category": "smartphones",
        "price": '#number',
        "rating": '#number',
        "stock": '#number',
        "tags": '#[] #string',
        "dimensions": { "width": '#number', "height": '#number', "depth": '#number' },
        "reviews": '#[]'
      }
      """

  @Scenario-4 @positive
  Scenario: Search products with query parameter
    Given url dummyJsonUrl + '/products/search'
    And param q = 'phone'
    When method get
    Then status 200
    And print 'Request URL:', karate.prevRequest.url
    And match each response.products contains
      """
      {
        "id": '#number',
        "title": '#string',
        "description": '#string',
        "category": "#string",
        "price": '#number',
        "rating": '#number',
        "stock": '#number',
        "tags": '#[] #string',
        "dimensions": { "width": '#number', "height": '#number', "depth": '#number' },
        "reviews": '#[]'
      }
      """
    And assert response.total > 0

  @Scenario-5 @negative
  Scenario: GET products with skip beyond total returns empty list
    Given url dummyJsonUrl + '/products'
    And param limit = 5
    And param skip = 9999
    When method get
    Then status 200
    And print response
    And match response.products == '#[0]'
    And match response contains { skip: 9999, limit: 0 }

  @Scenario-6 @positive
  Scenario Outline: GET products with different pagination parameters
    Given url dummyJsonUrl + '/products'
    And param limit = <limit>
    And param skip = <skip>
    When method get
    Then status 200
    And print response
    And match each response.products contains
      """
      {
        "id": '#number',
        "title": '#string',
        "description": '#string',
        "category": "#string",
        "price": '#number',
        "rating": '#number',
        "stock": '#number',
        "tags": '#[] #string',
        "dimensions": { "width": '#number', "height": '#number', "depth": '#number' },
        "reviews": '#[]'
      }
      """
    And match response contains { skip: <skip>, limit: <limit> }

    Examples:
      | limit | skip |
      | 3     | 0    |
      | 5     | 10   |
      | 10    | 20   |
      | 1     | 50   |
