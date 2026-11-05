@dummyjson @functional @schema-validation
Feature: DummyJSON Products API - JSON Schema Validation & Response Spec
  As a QA engineer
  I want to validate DummyJSON responses against JSON schemas and response specifications
  So that contract testing, response specs, and response time assertions are demonstrated

  @Scenario-1 @positive @smoke
  Scenario: GET single product response matches JSON schema
    Given url dummyJsonUrl + '/products/1'
    When method get
    Then status 200
    And print response
    And match response contains {"id":1,"title":"Essence Mascara Lash Princess","price":9.99,"rating":2.56}
    And match response contains { id: '#number', title: '#string', price: '#number', rating: '#number', tags: '#[] #string' }
    And assert responseTime < 3000

  @Scenario-2 @positive
  Scenario: GET all products list response matches JSON schema
    Given url dummyJsonUrl + '/products'
    When method get
    Then status 200
    And print response
    And assert responseTime < 3000
    And match header Content-Type contains 'application/json'
    And match response == { "products": '#[]', "total": '#number', "skip": '#number', "limit": '#number' }
    And match response.products contains deep {"id":1,"title":"Essence Mascara Lash Princess","price":9.99,"rating":2.56}
    And match each response.products contains
      """
      {
        "id": '#number',
        "title": '#string',
        "description": '#string',
        "price": '#number',
        "rating": '#number',
        "stock": '#number',
        "tags": '#[] #string',
        "dimensions": { "width": '#number', "height": '#number', "depth": '#number' },
        "reviews": '#[]'
      }
      """
