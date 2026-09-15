package pe.com.claro.eai.postventa.configuracionesott.service;

import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ConsultaServiciosConfigRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ListarBonosxPlanRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.BonoPlan;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ServicioConfiguracion;

import java.util.List;

public interface ConfiguracionesOttService {

    List<ServicioConfiguracion> consultarServiciosConfig(ConsultaServiciosConfigRequest request);

    List<BonoPlan> listarBonosxPlan(ListarBonosxPlanRequest request);
}
