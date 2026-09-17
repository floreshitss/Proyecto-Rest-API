package pe.com.claro.eai.postventa.configuracionesott.canonical.response;

import pe.com.claro.eai.postventa.configuracionesott.canonical.common.ResponseAudit;

public class StandardResponse<T> {

    private ResponseAudit responseAudit;
    private T responseData;

    public StandardResponse() {
    }

    public StandardResponse(ResponseAudit responseAudit, T responseData) {
        this.responseAudit = responseAudit;
        this.responseData = responseData;
    }

    public ResponseAudit getResponseAudit() {
        return responseAudit;
    }

    public void setResponseAudit(ResponseAudit responseAudit) {
        this.responseAudit = responseAudit;
    }

    public T getResponseData() {
        return responseData;
    }

    public void setResponseData(T responseData) {
        this.responseData = responseData;
    }
}
