@dummyjson @functional @fuzzy-matching
Feature: DummyJSON Products API - Fuzzy Matching & Chained Assertions
  As a QA engineer
  I want to validate DummyJSON product responses using Karate's built-in match markers
  So that type checks, value rules, and collection assertions are demonstrated
  (Karate equivalent of the Hamcrest matchers feature in the REST Assured suite)

  @Scenario-1 @positive @smoke
  Scenario: GET single product and validate with fuzzy match markers
    Given url dummyJsonUrl + '/products/1'
    When method get
    Then status 200
    And print response
    And match response contains
      """
      {
        id: '#notnull',
        title: '#string? _.length > 0',
        description: '#notnull',
        price: '#number? _ > 0',
        rating: '#number? _ >= 0 && _ <= 5',
        stock: '#notnull',
        brand: '#notnull',
        thumbnail: '#notnull',
        tags: '#[_ > 0]'
      }
      """

  @Scenario-2 @positive @smoke
  Scenario: GET all products and validate collection with fuzzy match markers
    Given url dummyJsonUrl + '/products'
    When method get
    Then status 200
    And print response
    # brand uses ## because some products (e.g. groceries) have no brand field
    And match each response.products contains
      """
      {
        id: '#notnull',
        title: '#string? _.length > 0',
        description: '#notnull',
        price: '#number? _ > 0',
        rating: '#number? _ >= 0 && _ <= 5',
        stock: '#notnull',
        brand: '##string',
        thumbnail: '#notnull',
        tags: '#[_ > 0]'
      }
      """
