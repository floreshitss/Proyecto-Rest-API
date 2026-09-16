package pe.com.claro.eai.postventa.configuracionesott.controller;

import lombok.extern.slf4j.Slf4j;
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
import org.slf4j.MDC;

@RestController
@RequestMapping(Constantes.BASE_PATH)
@Slf4j
public class ConfiguracionesOttController {

    private final ConfiguracionesOttService configuracionesOttService;
    private final PropertiesExternos properties;

    public ConfiguracionesOttController(ConfiguracionesOttService configuracionesOttService, PropertiesExternos properties) {
        this.configuracionesOttService = configuracionesOttService;
        this.properties = properties;
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

        long inicioNanos = System.nanoTime();
        String trace = traceId == null ? Utilitarios.construirTraceId() : traceId;
        MDC.put(Constantes.MDC_TRACE_ID, trace);
        Utilitarios.logInfo(log, trace, "Inicio Operacion - msgid={}, timestamp={}, canal={}, usuario={}, accept={}",
                msgid, timestamp, canal, usuario, accept);
        Utilitarios.logInfo(log, trace, "Request Completo: {}", request);

        RequestHeaders headers = new RequestHeaders(trace, canal, usuario);
        headers.setMsgid(msgid);
        headers.setTimestamp(timestamp);
        headers.setAccept(accept);
        List<ServicioConfiguracion> body = configuracionesOttService.consultarServiciosConfig(request);
        long tiempoTotal = Utilitarios.calcularTiempoTranscurridoMillis(inicioNanos);

        StandardResponse<List<ServicioConfiguracion>> response = new StandardResponse<>(
                ServiceCodes.IDF_SUCCESS,
                "0",
                properties.getConsultarExito(),
                body,
                null,
                new ResponseAudit(Utilitarios.obtenerFechaHoraActual(), Utilitarios.obtenerFechaHoraActual(), tiempoTotal)
        );
        Utilitarios.logInfo(log, trace, "Fin Operacion - tiempoTotalMs={}, httpStatus={}", tiempoTotal, 200);
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

        long inicioNanos = System.nanoTime();
        String trace = traceId == null ? Utilitarios.construirTraceId() : traceId;
        MDC.put(Constantes.MDC_TRACE_ID, trace);
        Utilitarios.logInfo(log, trace, "Inicio Operacion - msgid={}, timestamp={}, canal={}, usuario={}, accept={}",
                msgid, timestamp, canal, usuario, accept);
        Utilitarios.logInfo(log, trace, "Request Completo: {}", request);

        List<BonoPlan> body = configuracionesOttService.listarBonosxPlan(request);
        long tiempoTotal = Utilitarios.calcularTiempoTranscurridoMillis(inicioNanos);

        StandardResponse<List<BonoPlan>> response = new StandardResponse<>(
                ServiceCodes.IDF_SUCCESS,
                "0",
                properties.getBonosExito(),
                body,
                null,
                new ResponseAudit(Utilitarios.obtenerFechaHoraActual(), Utilitarios.obtenerFechaHoraActual(), tiempoTotal)
        );
        Utilitarios.logInfo(log, trace, "Fin Operacion - tiempoTotalMs={}, httpStatus={}", tiempoTotal, 200);
        return ResponseEntity.ok().header(Constantes.HEADER_TRACE_ID, trace).body(response);
    }
}
