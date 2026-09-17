package pe.com.claro.eai.postventa.configuracionesott.canonical.response;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class BonoPlan {

    private String tmcode;
    private String poid;
    private String descripcionPlan;
    private String serviceId;
    private String nombreServicio;
    private String tipoServicio;
    private String precio;

    public BonoPlan() {
    }

    public BonoPlan(String tmcode, String poid, String descripcionPlan, String serviceId,
                    String nombreServicio, String tipoServicio, String precio) {
        this.tmcode = tmcode;
        this.poid = poid;
        this.descripcionPlan = descripcionPlan;
        this.serviceId = serviceId;
        this.nombreServicio = nombreServicio;
        this.tipoServicio = tipoServicio;
        this.precio = precio;
    }

    public BonoPlan(String idPlan, String nombrePlan, String descripcion, String estado) {
        this.tmcode = idPlan;
        this.nombreServicio = nombrePlan;
        this.descripcionPlan = descripcion;
        this.tipoServicio = estado;
    }

    @JsonIgnore
    public String getIdPlan() {
        return tmcode;
    }

    @JsonIgnore
    public String getNombrePlan() {
        return nombreServicio;
    }

    @JsonIgnore
    public String getDescripcion() {
        return descripcionPlan;
    }

    public String getTmcode() {
        return tmcode;
    }

    public void setTmcode(String tmcode) {
        this.tmcode = tmcode;
    }

    public String getPoid() {
        return poid;
    }

    public void setPoid(String poid) {
        this.poid = poid;
    }

    public String getDescripcionPlan() {
        return descripcionPlan;
    }

    public void setDescripcionPlan(String descripcionPlan) {
        this.descripcionPlan = descripcionPlan;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getNombreServicio() {
        return nombreServicio;
    }

    public void setNombreServicio(String nombreServicio) {
        this.nombreServicio = nombreServicio;
    }

    public String getTipoServicio() {
        return tipoServicio;
    }

    public void setTipoServicio(String tipoServicio) {
        this.tipoServicio = tipoServicio;
    }

    public String getPrecio() {
        return precio;
    }

    public void setPrecio(String precio) {
        this.precio = precio;
    }
}
