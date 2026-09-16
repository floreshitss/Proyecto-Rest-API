package pe.com.claro.eai.postventa.configuracionesott.service.impl;

import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import lombok.extern.slf4j.Slf4j;
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
import pe.com.claro.eai.postventa.configuracionesott.common.util.Utilitarios;
import org.slf4j.Logger;
import pe.com.claro.eai.postventa.configuracionesott.common.property.PropertiesExternos;
import org.slf4j.MDC;

import java.util.List;

@Service
@Slf4j
public class ConfiguracionesOttServiceImpl implements ConfiguracionesOttService {
    private final ConfiguracionesOttRepository configuracionesOttRepository;
    private final PropertiesExternos properties;

    @Autowired
    public ConfiguracionesOttServiceImpl(ConfiguracionesOttRepository configuracionesOttRepository,
                                         PropertiesExternos properties) {
        this.configuracionesOttRepository = configuracionesOttRepository;
        this.properties = properties;
    }

    public ConfiguracionesOttServiceImpl(ConfiguracionesOttRepository configuracionesOttRepository) {
        this(configuracionesOttRepository, new PropertiesExternos());
    }

    @Override
    public List<ServicioConfiguracion> consultarServiciosConfig(ConsultaServiciosConfigRequest request) {
        String traceId = MDC.get("traceId");
        Utilitarios.logInfo(log, traceId, "Validaciones consultarServiciosConfig");
        validarRequest(request, "consultarServiciosConfig");
        validarCamposObligatorios(request.getIdGrupoConfig(), "idGrupoConfig");
        List<ServicioConfiguracion> result = configuracionesOttRepository.consultarServiciosConfig(
                request.getIdGrupoConfig(), request.getValor1(), request.getValor2(),
                request.getValor3(), request.getValor4(), request.getValor5());
        if (result.isEmpty()) {
            throw new BusinessException(properties.getConsultarSinDatos());
        }
        Utilitarios.logInfo(log, traceId, "Resultado servicio consultarServiciosConfig: filas={}", result.size());
        return result;
    }

    @Override
    public List<BonoPlan> listarBonosxPlan(ListarBonosxPlanRequest request) {
        String traceId = MDC.get("traceId");
        Utilitarios.logInfo(log, traceId, "Validaciones listarBonosxPlan");
        validarRequest(request, "listarBonosxPlan");
        validarCamposObligatorios(request.getCodigoPlan(), "codigoPlan");
        List<BonoPlan> result = configuracionesOttRepository.listarBonosxPlan(
                request.getCodigoPlan(), request.getTipoPlan());
        if (result.isEmpty()) {
            throw new BusinessException(properties.getBonosSinDatos());
        }
        Utilitarios.logInfo(log, traceId, "Resultado servicio listarBonosxPlan: filas={}", result.size());
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
