package runner;

import com.intuit.karate.junit5.Karate;  

public class TokenAuthApiRunner {
	 @Karate.Test
	    Karate testTokenAuth() {
	        return Karate.run("classpath:features/token_auth_api.feature");
	    }

}
