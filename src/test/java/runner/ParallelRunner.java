package runner;
import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;


public class ParallelRunner {
	@Test
    void runAllFeatures() {
		int threads = Integer.parseInt(System.getProperty("threads", "4"));
        Results results = Runner.path("classpath:features")
                .tags("~@ignore")          // skip helpers like common/login.feature
                .outputJunitXml(true)      // XML results for Jenkins
                .parallel(threads);              // 4 threads, one JVM
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

}
