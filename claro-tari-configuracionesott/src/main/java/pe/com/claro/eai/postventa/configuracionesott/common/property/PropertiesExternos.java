package pe.com.claro.eai.postventa.configuracionesott.common.property;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class PropertiesExternos {

    @Value("${bd.iot.jndi}")
    private String bdIotJndi;
    @Value("${bd.iot.owner}")
    private String bdIotOwner;
    @Value("${bd.iot.nombre}")
    private String bdIotNombre;
    @Value("${bd.iot.package}")
    private String bdIotPackage;
    @Value("${bd.iot.sp.consultar-servicios}")
    private String spConsultarServicios;
    @Value("${bd.iot.sp.bonos-plan}")
    private String spBonosPlan;
    @Value("${bd.iot.timeout.connection.max.time:1}")
    private int dbConnectionTimeout;
    @Value("${bd.iot.timeout.execution.max.time:1}")
    private int dbExecutionTimeout;
    @Value("${metodo.consultar.servicios.config.mensaje.idf0:Operacion exitosa}")
    private String consultarExito;
    @Value("${metodo.consultar.servicios.config.mensaje.idf2:Error al consultar configuraciones OTT en base de datos}")
    private String consultarSinDatos;
    @Value("${metodo.listar.bonos.plan.mensaje.idf0:Operacion exitosa}")
    private String bonosExito;
    @Value("${metodo.listar.bonos.plan.mensaje.idf2:Error al consultar bonos del plan en base de datos}")
    private String bonosSinDatos;

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

    public String getBdIotJndi() { return bdIotJndi; }
    public String getBdIotOwner() { return bdIotOwner; }
    public String getBdIotNombre() { return bdIotNombre; }
    public String getBdIotPackage() { return bdIotPackage; }
    public String getSpConsultarServicios() { return spConsultarServicios; }
    public String getSpBonosPlan() { return spBonosPlan; }
    public int getDbConnectionTimeout() { return dbConnectionTimeout; }
    public int getDbExecutionTimeout() { return dbExecutionTimeout; }
    public String getConsultarExito() { return consultarExito; }
    public String getConsultarSinDatos() { return consultarSinDatos; }
    public String getBonosExito() { return bonosExito; }
    public String getBonosSinDatos() { return bonosSinDatos; }
}
