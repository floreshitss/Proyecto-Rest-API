package pe.com.claro.eai.postventa.configuracionesott.canonical.common;

public class ResponseAudit {

    private String codigoRespuesta;
    private String mensajeRespuesta;
    private String idTransaccion;

    public ResponseAudit() {
    }

    public ResponseAudit(String codigoRespuesta, String mensajeRespuesta, String idTransaccion) {
        this.codigoRespuesta = codigoRespuesta;
        this.mensajeRespuesta = mensajeRespuesta;
        this.idTransaccion = idTransaccion;
    }

    public String getCodigoRespuesta() {
        return codigoRespuesta;
    }

    public void setCodigoRespuesta(String codigoRespuesta) {
        this.codigoRespuesta = codigoRespuesta;
    }

    public String getMensajeRespuesta() {
        return mensajeRespuesta;
    }

    public void setMensajeRespuesta(String mensajeRespuesta) {
        this.mensajeRespuesta = mensajeRespuesta;
    }

    public String getIdTransaccion() {
        return idTransaccion;
    }

    public void setIdTransaccion(String idTransaccion) {
        this.idTransaccion = idTransaccion;
    }
}
