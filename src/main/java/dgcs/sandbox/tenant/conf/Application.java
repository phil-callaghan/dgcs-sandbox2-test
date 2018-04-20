package dgcs.sandbox.tenant.conf;

import dgcs.sandbox.tenant.ComponentScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication(scanBasePackageClasses = { ComponentScan.class })
public class Application extends SpringBootServletInitializer {
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(Application.class);
    }

    @SuppressWarnings("RedundantThrows")
    public static void main(String[] args) throws Exception {
        SpringApplication.run(Application.class, args);
    }
}
