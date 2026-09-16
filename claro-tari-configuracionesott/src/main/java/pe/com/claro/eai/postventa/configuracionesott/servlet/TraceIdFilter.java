package pe.com.claro.eai.postventa.configuracionesott.servlet;

import org.slf4j.MDC;
import org.springframework.stereotype.Component;
import pe.com.claro.eai.postventa.configuracionesott.common.constants.Constantes;
import pe.com.claro.eai.postventa.configuracionesott.common.util.Utilitarios;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

@Component
public class TraceIdFilter implements Filter {

    @Override
    public void init(javax.servlet.FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String traceId = httpRequest.getHeader(Constantes.HEADER_TRACE_ID);
        if (traceId == null || traceId.trim().isEmpty()) {
            traceId = Utilitarios.construirTraceId();
        }
        MDC.put(Constantes.MDC_TRACE_ID, traceId);
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.remove(Constantes.MDC_TRACE_ID);
        }
    }

    @Override
    public void destroy() {
    }
}
