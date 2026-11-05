## Tech Stack

Karate 1.5.2 | JUnit 5 | Java 17 | Maven | REST API | DummyJSON | AutomationExercise | Jenkins

## Overview

Test Targets: [DummyJSON](https://dummyjson.com) and [AutomationExercise API](https://automationexercise.com/api_list)  
Testing Framework: Karate with the JUnit 5 runner  
Language: Gherkin feature files (no Java step definitions)  
Architecture: one feature file per API area, a single parallel runner for the full suite, plus one JUnit runner per feature for running features individually  
Execution: scenarios run in parallel (4 threads by default, configurable with `-Dthreads`)  
Test Organization: Karate scenarios with built-in HTTP steps, `match` assertions, and fuzzy markers  
Test Data: inline JSON in the feature files; the user account payload is shared through `Background`  
Scope: a selection of features from the REST Assured suite, chosen to show the differences between the two tools

Companion project: **[REST Assured + Cucumber version of this suite](https://github.com/jgupta-git/restapi-automation-java-restassured-junit)**

---

## Test Scenarios

### Token Authentication (DummyJSON) — `token_auth_api.feature`

|Scenario|Endpoint|Type|
|-|-|-|
|Login with valid credentials returns access and refresh tokens|POST `/auth/login`|Positive|
|Access protected endpoint with valid Bearer token|POST `/auth/login`, GET `/auth/me`|Positive|
|Refresh token returns a new access token|POST `/auth/login`, POST `/auth/refresh`|Positive|
|Login with invalid credentials returns error|POST `/auth/login`|Negative|
|Access protected endpoint without token returns 401|GET `/auth/me`|Negative|
|Access protected endpoint with invalid token returns 500|GET `/auth/me`|Negative|

### User Account CRUD (AutomationExercise) — `user_account_api.feature`

|Scenario|Endpoint|Type|
|-|-|-|
|Create a new user account|POST `/api/createAccount`|Positive|
|Get user account detail by email|GET `/api/getUserDetailByEmail`|Positive|
|Update an existing user account and verify it was saved|PUT `/api/updateAccount`, GET `/api/getUserDetailByEmail`|Positive|
|Delete a user account|DELETE `/api/deleteAccount`|Positive|
|Get user account after deletion returns not found|GET `/api/getUserDetailByEmail`|Negative|

### Schema Validation (DummyJSON) — `schema_validation.feature`

|Scenario|Endpoint|Type|
|-|-|-|
|Single product response matches the schema|GET `/products/1`|Positive|
|Product list matches the schema and response spec|GET `/products`|Positive|

### Query Parameters (DummyJSON) — `query_params.feature`

|Scenario|Endpoint|Type|
|-|-|-|
|Pagination with limit and skip|GET `/products?limit=5&skip=10`|Positive|
|Select returns only the requested fields|GET `/products?select=title,price`|Positive|
|Products by category|GET `/products/category/smartphones`|Positive|
|Search with a query parameter|GET `/products/search?q=phone`|Positive|
|Skip beyond total returns an empty list|GET `/products?limit=5&skip=9999`|Negative|
|Different pagination parameters (Scenario Outline, 4 examples)|GET `/products?limit=<limit>&skip=<skip>`|Positive|

### Fuzzy Matching (DummyJSON) — `fuzzy_matching.feature`

|Scenario|Endpoint|Type|
|-|-|-|
|Single product validated with fuzzy match markers|GET `/products/1`|Positive|
|Every product in the list validated with fuzzy match markers|GET `/products`|Positive|

---

## Project Structure

```
restapi-automation-java-karate-junit/
├── .gitignore                              # Ignores target/, IDE files and compiled classes
├── Jenkinsfile                             # Jenkins pipeline (checkout, test, publish results)
├── pom.xml                                 # Karate dependency, Java 17, regression profile
├── README.md                               # This file
└── src/
    └── test/
        ├── java/
        │   └── runner/
        │       ├── ParallelRunner.java             # Runs all features in parallel (used by Maven and Jenkins)
        │       ├── FuzzyMatchingRunner.java        # Runs fuzzy_matching.feature
        │       ├── QueryParamsRunner.java          # Runs query_params.feature
        │       ├── SchemaValidationRunner.java     # Runs schema_validation.feature
        │       ├── TokenAuthApiRunner.java         # Runs token_auth_api.feature
        │       └── UserAccountApiRunner.java       # Runs user_account_api.feature
        └── resources/
            ├── karate-config.js                    # Base URLs, loaded before every scenario
            └── features/
                ├── common/
                │   └── login.feature               # Reusable login helper, called with callonce
                ├── fuzzy_matching.feature          # Fuzzy markers and value rules
                ├── query_params.feature            # Query parameters and Scenario Outline
                ├── schema_validation.feature       # Schema checks, headers, response time
                ├── token_auth_api.feature          # JWT login, Bearer access, token refresh
                └── user_account_api.feature        # User account create, read, update, delete
```

## Key Files

### Runners (src/test/java/runner/)

**ParallelRunner.java** runs the whole suite. Maven and Jenkins use this runner:

```java
class ParallelRunner {

    @Test
    void runAllFeatures() {
        int threads = Integer.parseInt(System.getProperty("threads", "4"));
        Results results = Runner.path("classpath:features")
                .tags("~@ignore")          // skip helper features like common/login.feature
                .outputJunitXml(true)      // JUnit XML results for Jenkins
                .parallel(threads);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
```

* Runs scenarios in parallel inside one JVM, so Karate builds a single combined report
* The thread count defaults to 4 and can be changed with `-Dthreads`
* Fails the JUnit test if any scenario fails, so Maven and Jenkins report the build as failed

**Feature runners** run one feature file each, with the JUnit 5 `@Karate.Test` annotation. Use them to run a single feature from the IDE:

```java
class TokenAuthApiRunner {

    @Karate.Test
    Karate testTokenAuth() {
        return Karate.run("classpath:features/token_auth_api.feature");
    }
}
```

There are no step definition classes. Karate's HTTP, assertion and data steps are built in.

### Configuration (src/test/resources/karate-config.js)

Karate loads this file automatically before every scenario. The values it returns are available as variables in every feature:

```javascript
function fn() {
  return {
    dummyJsonUrl: 'https://dummyjson.com',
    aeUrl: 'https://automationexercise.com/api/'
  };
}
```

### Feature Files (src/test/resources/features/)

* common/login.feature — Reusable login helper (tagged `@ignore`, so it never runs as a test on its own)
* token\_auth\_api.feature — Login, Bearer token access, token refresh, and auth errors
* user\_account\_api.feature — Full account lifecycle, with the update verified by reading the account back
* schema\_validation.feature — Type checks on single and list responses, content type, response time
* query\_params.feature — Pagination, field selection, category filter, search, data-driven examples
* fuzzy\_matching.feature — Type and value rules in a single `match` (Karate equivalent of Hamcrest matchers)

---

## Test Reports

**[Karate HTML Report](https://jgupta-git.github.io/restapi-automation-java-karate-junit/karate-reports/karate-summary.html)**

* **karate-summary.html** — one combined summary of every feature, with pass/fail counts and timings
* **Tags** view — results grouped by tag (`@smoke`, `@positive`, `@negative`, ...)
* **Timeline** view — shows which scenarios ran on which thread, and when
* **Per-feature reports** — each step shows the request URL, headers, request body and response, so the report documents exactly what the API returned
* **JUnit XML** — `*.xml` files that Jenkins reads for its **Test Result** page and trend graph

## Quick Start

### 1\. Prerequisites

* ✅ Java 17+ — Required by Karate 1.5
* ✅ Maven 3.x — Build and test runner
* ✅ Internet connectivity — Tests run against DummyJSON and AutomationExercise

### 2\. Installation

```cmd
git clone https://github.com/jgupta-git/restapi-automation-java-karate-junit.git
cd restapi-automation-java-karate-junit
mvn clean compile
```

To use Eclipse: **File → Import → Maven → Existing Maven Projects**, select the repository folder, then **Maven → Update Project** (Alt+F5).

### 3\. Configure Test Data

* Base URLs — `src/test/resources/karate-config.js`
* DummyJSON login user — inline in `token_auth_api.feature`
* AutomationExercise user account — the `Background` section of `user_account_api.feature`

### 4\. Run Tests

#### Run All Features

```cmd
mvn clean test -P regression
```

The `regression` profile runs `ParallelRunner.java`, which runs every feature in parallel. Running `mvn test` without the profile runs no tests, because Maven only picks up `*Test` classes by default.

#### Change the Number of Threads

```cmd
mvn clean test -P regression -Dthreads=8
```

The default is 4. These tests call free public APIs, so a modest thread count avoids rate limiting.

#### Run One Feature

In Eclipse, right-click a runner such as `TokenAuthApiRunner.java` → **Run As → JUnit Test**.

From the command line:

```cmd
mvn clean test -Dtest=TokenAuthApiRunner
```

#### Run by Tag

```cmd
mvn clean test -P regression -Dkarate.options="--tags @smoke"
```

---

## Test Execution Flow

### Sequential Account Tests (user\_account\_api.feature)

The account scenarios run in file order and depend on each other:

1. Create — deletes any leftover account with the same email, then creates the account
2. Get — reads the account by email
3. Update — changes the name, first name and company, then reads the account back to confirm the change was saved
4. Delete — deletes the account
5. Get after delete — confirms the account no longer exists

Karate runs scenarios in parallel, so this feature is tagged `@parallel=false`:

```gherkin
@account @functional @parallel=false
Feature: User Account API
```

Its scenarios then run in order on one thread, while the other features still run in parallel. Run the feature as a whole; running one of these scenarios alone can fail if it needs the account an earlier scenario creates.

### Shared Payload with Background and `set`

The user account is defined once in `Background`. Karate runs `Background` before every scenario, so each scenario starts with a fresh copy. The update scenario changes only the fields it needs:

```gherkin
    * set user
      | path      | value         |
      | name      | 'UpdatedUser' |
      | firstname | 'Updated'     |
      | company   | 'NewCorp'     |
    Given url aeUrl + 'updateAccount'
    And form fields user
    When method put
```

### Reusable Login with `callonce`

Login lives in one helper feature. `token_auth_api.feature` calls it from `Background`:

```gherkin
  Background:
    * def auth = callonce read('classpath:features/common/login.feature') { username: 'emilys', password: 'emilyspass' }
```

`callonce` runs the login once per feature and reuses the result in every scenario. Scenarios that need a logged-in user use `auth.accessToken` and `auth.refreshToken`:

```gherkin
    Given url dummyJsonUrl + '/auth/me'
    And header Authorization = 'Bearer ' + auth.accessToken
```

The scenarios that test login itself (valid and invalid credentials) still call the login endpoint directly.

### Chaining Calls

Values from one response feed the next request through plain variables, for example the access token above, or the refresh token sent to `/auth/refresh`.

---

## Fuzzy Matching

Karate checks JSON with `match` and built-in markers instead of an assertion library:

```gherkin
    And match each response.products contains
      """
      {
        id: '#notnull',
        title: '#string? _.length > 0',
        price: '#number? _ > 0',
        rating: '#number? _ >= 0 && _ <= 5',
        brand: '##string',
        tags: '#[_ > 0]'
      }
      """
```

|Marker|Meaning|
|-|-|
|`'#number'`, `'#string'`|Value must be of this type|
|`'#notnull'`|Value must be present and not null|
|`'##string'`|Optional: may be missing, but must be a string if present|
|`'#[5]'`, `'#[_ > 0]'`|Array of exactly 5 items, or a non-empty array|
|`'#[] #string'`|Array where every item is a string|
|`'#number? _ > 0'`|A number that also passes the rule after `?`|
|`'#regex .+'`|A string matching the regular expression|

|Keyword|Meaning|
|-|-|
|`match ==`|Exact match: every field must be listed|
|`match contains`|Listed fields must match; other fields are ignored|
|`match each`|Applies the check to every item in an array|

---

## Karate vs REST Assured

The same API tests are implemented in both projects:

|Area|REST Assured + Cucumber|Karate|
|-|-|-|
|Files per test|Feature file, step definitions, service classes, models|Feature file only|
|Runner|JUnit 4 `@RunWith(Cucumber.class)` with a glue path|JUnit 5 `@Karate.Test`, no glue|
|Request payload|POJO with getters and setters, serialized by Jackson|JSON in the feature file, changed with `set`|
|Assertions|Hamcrest matchers in Java|Built-in `match` with fuzzy markers|
|Schema validation|JSON Schema files with `matchesJsonSchemaInClasspath()`|Type markers in `match`, no schema file|
|Reusable response checks|`ResponseSpecBuilder`|Plain `match` lines, or a shared feature called with `call`|
|Response time|`time(lessThan(...))`|`assert responseTime < 3000`|
|Chaining calls|Values stored in Java fields|Variables with `def`|
|Reusable steps|Shared step definition methods in Java|Helper feature called with `call` / `callonce`|
|Reports|maven-cucumber-reporting plugin merges the JSON from all runners after the run|Built-in HTML report with every request and response, built by the runner during the run|
|Parallel runs|Maven surefire forks, one runner per JVM (feature level)|`Runner.parallel()` in one JVM (scenario level); `@parallel=false` keeps dependent scenarios in order|

---

## Configuration

### pom.xml

* `karate-junit5` — the only test dependency; it brings in Karate and JUnit 5
* `maven.compiler.source` / `target` 17 — Karate 1.5 requires Java 17
* `regression` profile — runs only `ParallelRunner.java`, so the feature runners don't run a second time

```xml
<profile>
    <id>regression</id>
    ...
    <configuration>
        <includes>
            <include>**/ParallelRunner.java</include>
        </includes>
    </configuration>
</profile>
```

Parallelism comes from `Runner.parallel()` inside `ParallelRunner`, not from Maven forks. One JVM runs the whole suite, so Karate can build one combined report.

---

## Jenkins

The `Jenkinsfile` runs two stages and a post step:

1. **Checkout** — pulls the repository
2. **Run Karate tests** — runs `mvn clean test -P regression`
3. **Post** — publishes the JUnit results from `target/karate-reports/*.xml`, publishes the combined Karate report, and archives everything in `target/karate-reports`

```groovy
tools {
    jdk 'JDK17'      // must match the JDK name in Manage Jenkins > Tools
    maven 'Maven3'   // must match the Maven name in Manage Jenkins > Tools
}
```

Setup:

* Create a **Pipeline** job, set **Pipeline script from SCM** to Git, and point it at this repository
* In **Manage Jenkins → Tools**, add a JDK named `JDK17` that points to a Java 17+ JDK. Maven uses the machine's `JAVA_HOME` otherwise, which may be an older Java and fails with `invalid target release: 17`
* The Maven installation must be named `Maven3`
* The pipeline uses Windows batch steps (`bat`)
* The HTML Publisher plugin is required for the Karate report link

---

## References

* Karate: [karatelabs.github.io/karate](https://karatelabs.github.io/karate/)
* JUnit 5: [junit.org/junit5](https://junit.org/junit5/)
* DummyJSON: [dummyjson.com/docs](https://dummyjson.com/docs)
* AutomationExercise API: [automationexercise.com/api\_list](https://automationexercise.com/api_list)
* REST Assured version: [restapi-automation-java-restassured-junit](https://github.com/jgupta-git/restapi-automation-java-restassured-junit)

---

## GitHub Repository

```
https://github.com/jgupta-git/restapi-automation-java-karate-junit
```

---

Last Updated: 2026-11-04 | Built with Karate • JUnit 5 • Maven
