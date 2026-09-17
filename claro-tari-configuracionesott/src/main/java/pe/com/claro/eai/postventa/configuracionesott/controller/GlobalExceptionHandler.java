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
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    private final ObjectMapper objectMapper;

    public GlobalExceptionHandler(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<StandardResponse<Object>> manejarValidacion(ValidationException ex) {
        log.warn("Validacion rechazada traceId={}", MDC.get("traceId"), ex);
        StandardResponse<Object> response = buildResponse(ServiceCodes.IDF_VALIDATION, null, ex.getMessage(), null);
        logResponse(response);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<StandardResponse<Object>> manejarNegocio(BusinessException ex) {
        log.warn("Regla de negocio rechazada traceId={}", MDC.get("traceId"), ex);
        String idf = ex.getCode() == null ? ServiceCodes.IDF_BUSINESS : ex.getCode();
        StandardResponse<Object> response = buildResponse(idf, null, ex.getMessage(), null);
        logResponse(response);
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    @ExceptionHandler(TechnicalException.class)
    public ResponseEntity<StandardResponse<Object>> manejarTecnico(TechnicalException ex) {
        log.error("Error tecnico traceId={}", MDC.get("traceId"), ex);
        String idt = ex.getCode() == null ? ServiceCodes.IDT_TECHNICAL : ex.getCode();
        StandardResponse<Object> response = buildResponse(ServiceCodes.IDF_TECHNICAL, idt, ex.getMessage(), null);
        logResponse(response);
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<StandardResponse<Object>> manejarGeneral(Exception ex) {
        log.error("Error inesperado traceId={} httpStatus={}", MDC.get("traceId"),
                HttpStatus.INTERNAL_SERVER_ERROR.value(), ex);
        StandardResponse<Object> response = buildResponse(ServiceCodes.IDF_TECHNICAL, ServiceCodes.IDT_TECHNICAL,
                "Error técnico inesperado", null);
        logResponse(response);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

    private StandardResponse<Object> buildResponse(String idf, String idt, String description, Object data) {
        return new StandardResponse<>(
                new ResponseAudit(idt == null ? idf : idt, description,
                        MDC.get("traceId")), data);
    }

    private void logResponse(StandardResponse<Object> response) {
        try {
            Utilitarios.logResponse(log, MDC.get("traceId"),
                    objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(response));
        } catch (JsonProcessingException serializationError) {
            log.error("No se pudo serializar la respuesta de error traceId={}",
                    MDC.get("traceId"), serializationError);
        }
    }
}
