package pe.com.claro.eai.postventa.configuracionesott.common.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
import org.slf4j.Logger;

public final class Utilitarios {

    private static final String SEPARATOR = "=========================================================================================";
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

    public static void inicioMetodo(Logger logger, String idTransaccion, String nombreMetodo) {
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
        logger.info(formatIdTx(idTransaccion) + " INICIO METODO: " + nombreMetodo);
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
    }

    public static void finMetodo(Logger logger, String idTransaccion, String nombreMetodo, long inicioMillis) {
        long tiempoTotal = System.currentTimeMillis() - inicioMillis;
        logger.info(formatIdTx(idTransaccion) + " Tiempo total de proceso (milisegundos): " + tiempoTotal);
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
        logger.info(formatIdTx(idTransaccion) + " FIN METODO: " + nombreMetodo);
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
    }

    public static void actividadInicial(Logger logger, String idTransaccion, String descripcion) {
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
        logger.info(formatIdTx(idTransaccion) + " INICIO ACTIVIDAD: " + descripcion);
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
    }

    public static void actividadFinal(Logger logger, String idTransaccion, String descripcion) {
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
        logger.info(formatIdTx(idTransaccion) + " FIN ACTIVIDAD: " + descripcion);
        logger.info(formatIdTx(idTransaccion) + " " + SEPARATOR);
    }

    public static void logWarn(Logger logger, String idTransaccion, String mensaje, Object... parametros) {
        logger.warn(formatIdTx(idTransaccion) + " " + mensaje, parametros);
    }

    public static void logRequest(Logger logger, String idTransaccion, String headers, String body) {
        logger.info(formatIdTx(idTransaccion) + " Header Request: \n" + headers);
        logger.info(formatIdTx(idTransaccion) + " Body Request: \n" + body);
    }

    public static void logResponse(Logger logger, String idTransaccion, String body) {
        logger.info(formatIdTx(idTransaccion) + " Body Response: \n" + body);
    }

    public static void logParametrosEntrada(Logger logger, String idTransaccion) {
        logger.info(formatIdTx(idTransaccion) + " ------ Parametros de entrada: ------");
    }

    public static void logParametrosSalida(Logger logger, String idTransaccion) {
        logger.info(formatIdTx(idTransaccion) + " ------ Parametros de salida: ------");
    }

    public static void logDebug(Logger logger, String idTransaccion, String mensaje, Object... parametros) {
        if (logger.isDebugEnabled()) {
            logger.debug(formatIdTx(idTransaccion) + " " + mensaje, parametros);
        }
    }

    private static String formatIdTx(String idTransaccion) {
        return "[idTx=" + (idTransaccion == null || idTransaccion.isEmpty() ? "N/A" : idTransaccion) + "]";
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
