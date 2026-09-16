package pe.com.claro.eai.postventa.configuracionesott.common.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
import org.slf4j.Logger;

public final class Utilitarios {

    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    private Utilitarios() {
    }

    public static String construirTraceId() {
        return UUID.randomUUID().toString();
    }

    public static String obtenerFechaHoraActual() {
        return LocalDateTime.now().format(FORMATTER);
    }

    public static long calcularTiempoTranscurridoMillis(long inicioNanos) {
        return (System.nanoTime() - inicioNanos) / 1_000_000L;
    }

    public static void logInfo(Logger logger, String idTransaccion, String mensaje, Object... parametros) {
        logger.info("[{}] " + mensaje, combinar(idTransaccion, parametros));
    }

    public static void logError(Logger logger, String idTransaccion, String mensaje, Object... parametros) {
        logger.error("[{}] " + mensaje, combinar(idTransaccion, parametros));
    }

    private static Object[] combinar(String idTransaccion, Object[] parametros) {
        Object[] valores = new Object[parametros.length + 1];
        valores[0] = idTransaccion;
        System.arraycopy(parametros, 0, valores, 1, parametros.length);
        return valores;
    }
}
