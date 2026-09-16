package pe.com.claro.eai.postventa.configuracionesott.servlet.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.lookup.JndiDataSourceLookup;
import pe.com.claro.eai.postventa.configuracionesott.common.property.PropertiesExternos;

import javax.sql.DataSource;

@Configuration
public class DataSourceConfig {

    @Bean(name = "dataSourceIotDB", destroyMethod = "")
    public DataSource dataSourceIotDB(PropertiesExternos properties) {
        return new JndiDataSourceLookup().getDataSource(properties.getBdIotJndi());
    }
}
