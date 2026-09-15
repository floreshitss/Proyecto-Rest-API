package pe.com.claro.eai.postventa.configuracionesott.servlet.config;

import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import pe.com.claro.eai.postventa.configuracionesott.ConfiguracionesOttApplication;

public class ServletInitializer extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(ConfiguracionesOttApplication.class);
    }
}
