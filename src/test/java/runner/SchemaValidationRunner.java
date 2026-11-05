package runner;

import com.intuit.karate.junit5.Karate;

public class SchemaValidationRunner {
	@Karate.Test
    Karate testTokenAuth() {
        return Karate.run("classpath:features/schema_validation.feature");
    }

}
