package pe.com.claro.eai.postventa.configuracionesott.canonical.response;

public class ServicioConfiguracion {

    private String servicio;
    private String descripcion;
    private String valor1;
    private String valor2;
    private String valor3;
    private String valor4;
    private String valor5;

    public ServicioConfiguracion() {
    }

    public ServicioConfiguracion(String servicio, String descripcion, String valor1) {
        this.servicio = servicio;
        this.descripcion = descripcion;
        this.valor1 = valor1;
    }

    public String getServicio() {
        return servicio;
    }

    public String getCodigoServicio() {
        return servicio;
    }

    public void setServicio(String servicio) {
        this.servicio = servicio;
    }

    public void setCodigoServicio(String codigoServicio) {
        this.servicio = codigoServicio;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getValor1() {
        return valor1;
    }

    public void setValor1(String valor1) {
        this.valor1 = valor1;
    }

    public String getValor2() {
        return valor2;
    }

    public void setValor2(String valor2) {
        this.valor2 = valor2;
    }

    public String getValor3() {
        return valor3;
    }

    public void setValor3(String valor3) {
        this.valor3 = valor3;
    }

    public String getValor4() {
        return valor4;
    }

    public void setValor4(String valor4) {
        this.valor4 = valor4;
    }

    public String getValor5() {
        return valor5;
    }

    public void setValor5(String valor5) {
        this.valor5 = valor5;
    }
}
