package pe.com.claro.eai.postventa.configuracionesott.controller;

import lombok.extern.slf4j.Slf4j;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import pe.com.claro.eai.postventa.configuracionesott.canonical.common.RequestHeaders;
import pe.com.claro.eai.postventa.configuracionesott.canonical.common.ResponseAudit;
import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ConsultaServiciosConfigRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ListarBonosxPlanRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.BonoPlan;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ErrorResponse;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ServicioConfiguracion;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.StandardResponse;
import pe.com.claro.eai.postventa.configuracionesott.common.ServiceCodes;
import pe.com.claro.eai.postventa.configuracionesott.common.constants.Constantes;
import pe.com.claro.eai.postventa.configuracionesott.common.util.Utilitarios;
import pe.com.claro.eai.postventa.configuracionesott.service.ConfiguracionesOttService;
import pe.com.claro.eai.postventa.configuracionesott.common.property.PropertiesExternos;

import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;
import org.slf4j.MDC;

@RestController
@RequestMapping(Constantes.BASE_PATH)
@Slf4j
public class ConfiguracionesOttController {

    private final ConfiguracionesOttService configuracionesOttService;
    private final PropertiesExternos properties;
    private final ObjectMapper objectMapper;

    public ConfiguracionesOttController(ConfiguracionesOttService configuracionesOttService,
                                        PropertiesExternos properties, ObjectMapper objectMapper) {
        this.configuracionesOttService = configuracionesOttService;
        this.properties = properties;
        this.objectMapper = objectMapper;
    }

    @PostMapping(value = Constantes.CONSULTAR_SERVICIOS_CONFIG,
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<StandardResponse<List<ServicioConfiguracion>>> consultarServiciosConfig(
            @RequestHeader(value = Constantes.HEADER_TRACE_ID, required = false) String traceId,
            @RequestHeader(value = Constantes.HEADER_MSG_ID, required = false) String msgid,
            @RequestHeader(value = Constantes.HEADER_TIMESTAMP, required = false) String timestamp,
            @RequestHeader(value = Constantes.HEADER_CANAL, required = false) String canal,
            @RequestHeader(value = Constantes.HEADER_USUARIO, required = false) String usuario,
            @RequestHeader(value = Constantes.HEADER_ACCEPT, required = false) String accept,
            @RequestBody ConsultaServiciosConfigRequest request) {

        long inicioMillis = System.currentTimeMillis();
        String trace = traceId == null ? Utilitarios.construirTraceId() : traceId;
        MDC.put(Constantes.MDC_TRACE_ID, trace);
        Utilitarios.inicioMetodo(log, trace, "consultarServiciosConfig");
        Utilitarios.actividadInicial(log, trace, "Actividad 1 - [Procesar consulta de configuraciones OTT.]");
        Utilitarios.logInfo(log, trace, "Inicio Operacion - msgid={}, timestamp={}, canal={}, usuario={}, accept={}",
                msgid, timestamp, canal, usuario, accept);
        RequestHeaders headers = new RequestHeaders(trace, canal, usuario);
        headers.setMsgid(msgid);
        headers.setTimestamp(timestamp);
        headers.setAccept(accept);
        Utilitarios.logRequest(log, trace, serializarRequest(headers, request));
        List<ServicioConfiguracion> body = configuracionesOttService.consultarServiciosConfig(request);
        long tiempoTotal = System.currentTimeMillis() - inicioMillis;
        Utilitarios.actividadFinal(log, trace, "Actividad 1 - [Procesar consulta de configuraciones OTT.]");

        StandardResponse<List<ServicioConfiguracion>> response = new StandardResponse<>(
                ServiceCodes.IDF_SUCCESS,
                "0",
                properties.getConsultarExito(),
                body,
                null,
                new ResponseAudit(Utilitarios.obtenerFechaHoraActual(), Utilitarios.obtenerFechaHoraActual(), tiempoTotal)
        );
        Utilitarios.logResponse(log, trace, serializar(response));
        Utilitarios.finMetodo(log, trace, "consultarServiciosConfig", inicioMillis);
        return ResponseEntity.ok().header(Constantes.HEADER_TRACE_ID, trace).body(response);
    }

    @PostMapping(value = Constantes.LISTAR_BONOS_X_PLAN,
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<StandardResponse<List<BonoPlan>>> listarBonosxPlan(
            @RequestHeader(value = Constantes.HEADER_TRACE_ID, required = false) String traceId,
            @RequestHeader(value = Constantes.HEADER_MSG_ID, required = false) String msgid,
            @RequestHeader(value = Constantes.HEADER_TIMESTAMP, required = false) String timestamp,
            @RequestHeader(value = Constantes.HEADER_CANAL, required = false) String canal,
            @RequestHeader(value = Constantes.HEADER_USUARIO, required = false) String usuario,
            @RequestHeader(value = Constantes.HEADER_ACCEPT, required = false) String accept,
            @RequestBody ListarBonosxPlanRequest request) {

        long inicioMillis = System.currentTimeMillis();
        String trace = traceId == null ? Utilitarios.construirTraceId() : traceId;
        MDC.put(Constantes.MDC_TRACE_ID, trace);
        Utilitarios.inicioMetodo(log, trace, "listarBonosxPlan");
        Utilitarios.actividadInicial(log, trace, "Actividad 1 - [Procesar consulta de bonos por plan.]");
        Utilitarios.logInfo(log, trace, "Inicio Operacion - msgid={}, timestamp={}, canal={}, usuario={}, accept={}",
                msgid, timestamp, canal, usuario, accept);
        RequestHeaders headers = new RequestHeaders(trace, canal, usuario);
        headers.setMsgid(msgid);
        headers.setTimestamp(timestamp);
        headers.setAccept(accept);
        Utilitarios.logRequest(log, trace, serializarRequest(headers, request));
        List<BonoPlan> body = configuracionesOttService.listarBonosxPlan(request);
        long tiempoTotal = System.currentTimeMillis() - inicioMillis;
        Utilitarios.actividadFinal(log, trace, "Actividad 1 - [Procesar consulta de bonos por plan.]");

        StandardResponse<List<BonoPlan>> response = new StandardResponse<>(
                ServiceCodes.IDF_SUCCESS,
                "0",
                properties.getBonosExito(),
                body,
                null,
                new ResponseAudit(Utilitarios.obtenerFechaHoraActual(), Utilitarios.obtenerFechaHoraActual(), tiempoTotal)
        );
        Utilitarios.logResponse(log, trace, serializar(response));
        Utilitarios.finMetodo(log, trace, "listarBonosxPlan", inicioMillis);
        return ResponseEntity.ok().header(Constantes.HEADER_TRACE_ID, trace).body(response);
    }

    private String serializarRequest(RequestHeaders headers, Object body) {
        Map<String, Object> request = new LinkedHashMap<>();
        request.put("headers", headers);
        request.put("body", body);
        return serializar(request);
    }

    private String serializar(Object value) {
        try {
            return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(value);
        } catch (JsonProcessingException ex) {
            Utilitarios.logError(log, MDC.get(Constantes.MDC_TRACE_ID),
                    "No se pudo serializar el mensaje de trazabilidad", ex);
            return "{\"serializationError\":true}";
        }
    }
}
