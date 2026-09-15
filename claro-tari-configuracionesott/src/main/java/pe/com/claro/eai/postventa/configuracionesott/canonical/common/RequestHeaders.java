package pe.com.claro.eai.postventa.configuracionesott.canonical.common;

public class RequestHeaders {

    private String traceId;
    private String canal;
    private String usuario;

    public RequestHeaders() {
    }

    public RequestHeaders(String traceId, String canal, String usuario) {
        this.traceId = traceId;
        this.canal = canal;
        this.usuario = usuario;
    }

    public String getTraceId() {
        return traceId;
    }

    public void setTraceId(String traceId) {
        this.traceId = traceId;
    }

    public String getCanal() {
        return canal;
    }

    public void setCanal(String canal) {
        this.canal = canal;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }
}
