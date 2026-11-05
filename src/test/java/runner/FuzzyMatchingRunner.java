package runner;

import com.intuit.karate.junit5.Karate;

public class FuzzyMatchingRunner {
	@Karate.Test
    Karate testTokenAuth() {
        return Karate.run("classpath:features/fuzzy_matching.feature");
    }

}
