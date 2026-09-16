package pe.com.claro.eai.postventa.configuracionesott.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

import java.util.List;

@RestController
@RequestMapping(Constantes.BASE_PATH)
public class ConfiguracionesOttController {

    private static final Logger logger = LoggerFactory.getLogger(ConfiguracionesOttController.class);

    private final ConfiguracionesOttService configuracionesOttService;

    public ConfiguracionesOttController(ConfiguracionesOttService configuracionesOttService) {
        this.configuracionesOttService = configuracionesOttService;
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
        logger.info("Inicio Operacion - traceId={}, msgid={}, timestamp={}, canal={}, usuario={}, accept={}",
                trace, msgid, timestamp, canal, usuario, accept);

        RequestHeaders headers = new RequestHeaders(trace, canal, usuario);
        headers.setMsgid(msgid);
        headers.setTimestamp(timestamp);
        headers.setAccept(accept);
        List<ServicioConfiguracion> body = configuracionesOttService.consultarServiciosConfig(request);
        long tiempoTotal = Utilitarios.calcularTiempoTranscurridoMillis(inicioNanos);

        StandardResponse<List<ServicioConfiguracion>> response = new StandardResponse<>(
                ServiceCodes.IDF_SUCCESS,
                "0",
                "Consulta exitosa",
                body,
                null,
                new ResponseAudit(Utilitarios.obtenerFechaHoraActual(), Utilitarios.obtenerFechaHoraActual(), tiempoTotal)
        );
        logger.info("Fin Operacion - traceId={}, tiempoTotalMs={}", trace, tiempoTotal);
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
        logger.info("Inicio Operacion - traceId={}, msgid={}, timestamp={}, canal={}, usuario={}, accept={}",
                trace, msgid, timestamp, canal, usuario, accept);

        List<BonoPlan> body = configuracionesOttService.listarBonosxPlan(request);
        long tiempoTotal = Utilitarios.calcularTiempoTranscurridoMillis(inicioNanos);

        StandardResponse<List<BonoPlan>> response = new StandardResponse<>(
                ServiceCodes.IDF_SUCCESS,
                "0",
                "Consulta exitosa",
                body,
                null,
                new ResponseAudit(Utilitarios.obtenerFechaHoraActual(), Utilitarios.obtenerFechaHoraActual(), tiempoTotal)
        );
        logger.info("Fin Operacion - traceId={}, tiempoTotalMs={}", trace, tiempoTotal);
        return ResponseEntity.ok().header(Constantes.HEADER_TRACE_ID, trace).body(response);
    }
}
