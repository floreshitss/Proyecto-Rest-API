package pe.com.claro.eai.postventa.configuracionesott.common.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

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
}
