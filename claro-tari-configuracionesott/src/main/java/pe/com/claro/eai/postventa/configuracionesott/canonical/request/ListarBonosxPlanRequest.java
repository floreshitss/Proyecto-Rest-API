package pe.com.claro.eai.postventa.configuracionesott.canonical.request;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class ListarBonosxPlanRequest {

    private String codigoPlan;
    private String tipoPlan;

    public String getCodigoPlan() {
        return codigoPlan;
    }

    public void setCodigoPlan(String codigoPlan) {
        this.codigoPlan = codigoPlan;
    }

    @JsonIgnore
    public String getIdPlan() {
        return codigoPlan;
    }

    @JsonIgnore
    public void setIdPlan(String idPlan) {
        this.codigoPlan = idPlan;
    }

    public String getTipoPlan() {
        return tipoPlan;
    }

    public void setTipoPlan(String tipoPlan) {
        this.tipoPlan = tipoPlan;
    }

    @JsonIgnore
    public String getTipoSolicitud() {
        return tipoPlan;
    }

    @JsonIgnore
    public void setTipoSolicitud(String tipoSolicitud) {
        this.tipoPlan = tipoSolicitud;
    }
}
