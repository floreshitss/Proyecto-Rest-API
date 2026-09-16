package pe.com.claro.eai.postventa.configuracionesott.servlet.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.lookup.JndiDataSourceLookup;

import javax.sql.DataSource;

@Configuration
public class DataSourceConfig {

    @Value("${bd.iot.jndi}")
    private String iotJndiName;

    @Bean(name = "dataSourceIotDB", destroyMethod = "")
    public DataSource dataSourceIotDB() {
        return new JndiDataSourceLookup().getDataSource(iotJndiName);
    }
}
