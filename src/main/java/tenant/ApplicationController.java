package tenant;

import jdk.jfr.Event;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.context.ConfigurableApplicationContext;

@Controller
@EnableAutoConfiguration
public class ApplicationController {

    @RequestMapping("/")
    @ResponseBody
    String home() {
        return "Hello World!";
    }

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = SpringApplication.run(ApplicationController.class, args);
        EventHolderBean bean = ctx.getBean(EventHolderBean.class);

    }
}