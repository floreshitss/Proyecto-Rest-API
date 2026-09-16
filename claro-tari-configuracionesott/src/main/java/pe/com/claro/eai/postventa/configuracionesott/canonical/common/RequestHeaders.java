package pe.com.claro.eai.postventa.configuracionesott.canonical.common;

public class RequestHeaders {

    private String traceId;
    private String msgid;
    private String timestamp;
    private String canal;
    private String usuario;
    private String accept;

    public RequestHeaders() {
    }

    public RequestHeaders(String traceId, String canal, String usuario) {
        this.traceId = traceId;
        this.canal = canal;
        this.usuario = usuario;
    }

    public String getMsgid() { return msgid; }
    public void setMsgid(String msgid) { this.msgid = msgid; }
    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }
    public String getAccept() { return accept; }
    public void setAccept(String accept) { this.accept = accept; }

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
