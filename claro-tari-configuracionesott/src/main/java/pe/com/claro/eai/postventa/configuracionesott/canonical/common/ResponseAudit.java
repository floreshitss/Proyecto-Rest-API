package pe.com.claro.eai.postventa.configuracionesott.canonical.common;

public class ResponseAudit {

    private String inicioOperacion;
    private String finOperacion;
    private Long tiempoTotal;

    public ResponseAudit() {
    }

    public ResponseAudit(String inicioOperacion, String finOperacion, Long tiempoTotal) {
        this.inicioOperacion = inicioOperacion;
        this.finOperacion = finOperacion;
        this.tiempoTotal = tiempoTotal;
    }

    public String getInicioOperacion() {
        return inicioOperacion;
    }

    public void setInicioOperacion(String inicioOperacion) {
        this.inicioOperacion = inicioOperacion;
    }

    public String getFinOperacion() {
        return finOperacion;
    }

    public void setFinOperacion(String finOperacion) {
        this.finOperacion = finOperacion;
    }

    public Long getTiempoTotal() {
        return tiempoTotal;
    }

    public void setTiempoTotal(Long tiempoTotal) {
        this.tiempoTotal = tiempoTotal;
    }
}
