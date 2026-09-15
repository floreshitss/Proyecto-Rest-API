package pe.com.claro.eai.postventa.configuracionesott.canonical.response;

import pe.com.claro.eai.postventa.configuracionesott.canonical.common.ResponseAudit;

public class StandardResponse<T> {

    private String idf;
    private String idt;
    private String descripcion;
    private T data;
    private ErrorResponse error;
    private ResponseAudit audit;

    public StandardResponse() {
    }

    public StandardResponse(String idf, String idt, String descripcion, T data, ErrorResponse error, ResponseAudit audit) {
        this.idf = idf;
        this.idt = idt;
        this.descripcion = descripcion;
        this.data = data;
        this.error = error;
        this.audit = audit;
    }

    public String getIdf() {
        return idf;
    }

    public void setIdf(String idf) {
        this.idf = idf;
    }

    public String getIdt() {
        return idt;
    }

    public void setIdt(String idt) {
        this.idt = idt;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public ErrorResponse getError() {
        return error;
    }

    public void setError(ErrorResponse error) {
        this.error = error;
    }

    public ResponseAudit getAudit() {
        return audit;
    }

    public void setAudit(ResponseAudit audit) {
        this.audit = audit;
    }
}
