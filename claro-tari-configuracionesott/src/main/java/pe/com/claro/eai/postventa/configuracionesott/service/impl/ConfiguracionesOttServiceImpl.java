package pe.com.claro.eai.postventa.configuracionesott.service.impl;

import org.springframework.stereotype.Service;
import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ConsultaServiciosConfigRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ListarBonosxPlanRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.BonoPlan;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ServicioConfiguracion;
import pe.com.claro.eai.postventa.configuracionesott.common.BusinessException;
import pe.com.claro.eai.postventa.configuracionesott.common.ServiceCodes;
import pe.com.claro.eai.postventa.configuracionesott.common.TechnicalException;
import pe.com.claro.eai.postventa.configuracionesott.common.ValidationException;
import pe.com.claro.eai.postventa.configuracionesott.repository.ConfiguracionesOttRepository;
import pe.com.claro.eai.postventa.configuracionesott.service.ConfiguracionesOttService;

import java.util.List;

@Service
public class ConfiguracionesOttServiceImpl implements ConfiguracionesOttService {

    private final ConfiguracionesOttRepository configuracionesOttRepository;

    public ConfiguracionesOttServiceImpl(ConfiguracionesOttRepository configuracionesOttRepository) {
        this.configuracionesOttRepository = configuracionesOttRepository;
    }

    @Override
    public List<ServicioConfiguracion> consultarServiciosConfig(ConsultaServiciosConfigRequest request) {
        validarRequest(request, "consultarServiciosConfig");
        validarCamposObligatorios(request.getIdGrupoConfig(), "idGrupoConfig");
        List<ServicioConfiguracion> result = configuracionesOttRepository.consultarServiciosConfig(
                request.getIdGrupoConfig(), request.getValor1(), request.getValor2(),
                request.getValor3(), request.getValor4(), request.getValor5());
        if (result.isEmpty()) {
            throw new BusinessException("No existen configuraciones para los parámetros solicitados");
        }
        return result;
    }

    @Override
    public List<BonoPlan> listarBonosxPlan(ListarBonosxPlanRequest request) {
        validarRequest(request, "listarBonosxPlan");
        validarCamposObligatorios(request.getIdPlan(), "idPlan");
        List<BonoPlan> result = configuracionesOttRepository.listarBonosxPlan(
                request.getIdPlan(), request.getTipoPlan());
        if (result.isEmpty()) {
            throw new BusinessException("No existen bonos vigentes para el plan");
        }
        return result;
    }

    private void validarRequest(Object request, String operation) {
        if (request == null) {
            throw new ValidationException("El request de " + operation + " es obligatorio");
        }
    }

    private void validarCamposObligatorios(String valor, String nombreCampo) {
        if (valor == null || valor.trim().isEmpty()) {
            throw new ValidationException("El parámetro " + nombreCampo + " es obligatorio");
        }
    }
}
