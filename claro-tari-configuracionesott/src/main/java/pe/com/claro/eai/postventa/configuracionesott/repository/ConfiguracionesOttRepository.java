package pe.com.claro.eai.postventa.configuracionesott.repository;

import pe.com.claro.eai.postventa.configuracionesott.canonical.response.BonoPlan;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ServicioConfiguracion;

import java.util.List;

public interface ConfiguracionesOttRepository {

    List<ServicioConfiguracion> consultarServiciosConfig(String idGrupoConfig, String valor1, String valor2,
                                                         String valor3, String valor4, String valor5);

    List<BonoPlan> listarBonosxPlan(String idPlan, String tipoPlan);
}
