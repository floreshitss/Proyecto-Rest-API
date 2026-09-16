package pe.com.claro.eai.postventa.configuracionesott.canonical.request;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class ListarBonosxPlanRequest {

    private String idPlan;
    private String tipoPlan;

    public String getIdPlan() {
        return idPlan;
    }

    public void setIdPlan(String idPlan) {
        this.idPlan = idPlan;
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
