package pe.com.claro.eai.postventa.configuracionesott.canonical.response;

public class ErrorResponse {

    private String codigo;
    private String descripcion;

    public ErrorResponse() {
    }

    public ErrorResponse(String codigo, String descripcion) {
        this.codigo = codigo;
        this.descripcion = descripcion;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}
