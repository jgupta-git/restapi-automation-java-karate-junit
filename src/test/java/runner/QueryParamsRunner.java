package runner;

import com.intuit.karate.junit5.Karate;

public class QueryParamsRunner {
	@Karate.Test
    Karate testTokenAuth() {
        return Karate.run("classpath:features/query_params.feature");
    }

}
