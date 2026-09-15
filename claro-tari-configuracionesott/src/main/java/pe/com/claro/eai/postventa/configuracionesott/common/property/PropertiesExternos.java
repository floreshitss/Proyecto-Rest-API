package pe.com.claro.eai.postventa.configuracionesott.common.property;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class PropertiesExternos {

    @Value("${idf0.codigo:0}")
    private String idf0Codigo;
    @Value("${idf1.codigo:1}")
    private String idf1Codigo;
    @Value("${idf2.codigo:2}")
    private String idf2Codigo;

    @Value("${idt1.codigo:-1}")
    private String idt1Codigo;
    @Value("${idt2.codigo:-2}")
    private String idt2Codigo;
    @Value("${idt3.codigo:-3}")
    private String idt3Codigo;

    public String getIdf0Codigo() {
        return idf0Codigo;
    }

    public String getIdf1Codigo() {
        return idf1Codigo;
    }

    public String getIdf2Codigo() {
        return idf2Codigo;
    }

    public String getIdt1Codigo() {
        return idt1Codigo;
    }

    public String getIdt2Codigo() {
        return idt2Codigo;
    }

    public String getIdt3Codigo() {
        return idt3Codigo;
    }
}
