package runner;

import com.intuit.karate.junit5.Karate;

public class UserAccountApiRunner {
	@Karate.Test
    Karate testTokenAuth() {
        return Karate.run("classpath:features/user_account_api.feature");
    }

}
