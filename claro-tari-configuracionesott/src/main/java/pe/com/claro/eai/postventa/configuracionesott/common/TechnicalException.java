package pe.com.claro.eai.postventa.configuracionesott.common;

public class TechnicalException extends RuntimeException {

    private final String code;

    public TechnicalException(String code, String message) {
        super(message);
        this.code = code;
    }

    public String getCode() {
        return code;
    }
}
