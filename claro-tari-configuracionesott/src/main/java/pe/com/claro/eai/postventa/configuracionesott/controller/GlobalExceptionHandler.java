package pe.com.claro.eai.postventa.configuracionesott.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import pe.com.claro.eai.postventa.configuracionesott.canonical.common.ResponseAudit;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ErrorResponse;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.StandardResponse;
import pe.com.claro.eai.postventa.configuracionesott.common.BusinessException;
import pe.com.claro.eai.postventa.configuracionesott.common.ServiceCodes;
import pe.com.claro.eai.postventa.configuracionesott.common.TechnicalException;
import pe.com.claro.eai.postventa.configuracionesott.common.ValidationException;
import pe.com.claro.eai.postventa.configuracionesott.common.util.Utilitarios;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<StandardResponse<Object>> manejarValidacion(ValidationException ex) {
        log.warn("Validacion rechazada traceId={}", MDC.get("traceId"), ex);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(buildResponse(ServiceCodes.IDF_VALIDATION, null, ex.getMessage(), null));
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<StandardResponse<Object>> manejarNegocio(BusinessException ex) {
        log.warn("Regla de negocio rechazada traceId={}", MDC.get("traceId"), ex);
        return ResponseEntity.status(HttpStatus.OK)
                .body(buildResponse(ServiceCodes.IDF_BUSINESS, null, ex.getMessage(), null));
    }

    @ExceptionHandler(TechnicalException.class)
    public ResponseEntity<StandardResponse<Object>> manejarTecnico(TechnicalException ex) {
        log.error("Error tecnico traceId={}", MDC.get("traceId"), ex);
        String idt = ex.getCode() == null ? ServiceCodes.IDT_TECHNICAL : ex.getCode();
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(buildResponse(ServiceCodes.IDF_TECHNICAL, idt, ex.getMessage(), null));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<StandardResponse<Object>> manejarGeneral(Exception ex) {
        log.error("Error inesperado traceId={} httpStatus={}", MDC.get("traceId"),
                HttpStatus.INTERNAL_SERVER_ERROR.value(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(buildResponse(ServiceCodes.IDF_TECHNICAL, ServiceCodes.IDT_TECHNICAL,
                        "Error técnico inesperado", null));
    }

    private StandardResponse<Object> buildResponse(String idf, String idt, String description, Object data) {
        return new StandardResponse<>(
                idf,
                idt,
                description,
                data,
                new ErrorResponse(idt, description),
                new ResponseAudit(Utilitarios.obtenerFechaHoraActual(), Utilitarios.obtenerFechaHoraActual(), 0L)
        );
    }
}
