package pe.com.claro.eai.postventa.configuracionesott.repository.impl;

import org.springframework.dao.DataAccessException;
import org.springframework.dao.QueryTimeoutException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.CannotGetJdbcConnectionException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.BonoPlan;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ServicioConfiguracion;
import pe.com.claro.eai.postventa.configuracionesott.common.BusinessException;
import pe.com.claro.eai.postventa.configuracionesott.common.ServiceCodes;
import pe.com.claro.eai.postventa.configuracionesott.common.TechnicalException;
import pe.com.claro.eai.postventa.configuracionesott.repository.ConfiguracionesOttRepository;
import pe.com.claro.eai.postventa.configuracionesott.common.property.PropertiesExternos;

import java.sql.Types;
import java.util.ArrayList;
import java.util.Map;
import java.util.List;

@Repository
public class ConfiguracionesOttRepositoryImpl implements ConfiguracionesOttRepository {

    private final SimpleJdbcCall consultarConfiguraciones;
    private final SimpleJdbcCall consultarBonos;

    public ConfiguracionesOttRepositoryImpl(JdbcTemplate jdbcTemplate,
                                            PropertiesExternos properties) {
        RowMapper<ServicioConfiguracion> configuracionMapper = (rs, rowNum) -> {
            ServicioConfiguracion item = new ServicioConfiguracion();
            item.setServicio(rs.getString("PO_CONFV_SERVICIO"));
            item.setDescripcion(rs.getString("PO_CONFV_DESCRIP"));
            item.setValor1(rs.getString("PO_CONFV_VALOR1"));
            item.setValor2(rs.getString("PO_CONFV_VALOR2"));
            item.setValor3(rs.getString("PO_CONFV_VALOR3"));
            item.setValor4(rs.getString("PO_CONFV_VALOR4"));
            item.setValor5(rs.getString("PO_CONFV_VALOR5"));
            return item;
        };
        RowMapper<BonoPlan> bonoMapper = (rs, rowNum) -> new BonoPlan(
                rs.getString("PLNN_TMCOD"), rs.getString("PLNN_POID"),
                rs.getString("PLNV_DESCRIPCION_PLAN"), rs.getString("SERVN_SERVICEID"),
                rs.getString("SERVV_NOMBRE"), rs.getString("SERVV_TIPO"),
                rs.getString("SERVD_PRECIO"));

        consultarConfiguraciones = new SimpleJdbcCall(jdbcTemplate)
                .withSchemaName(properties.getBdIotOwner())
                .withCatalogName(properties.getBdIotPackage())
                .withProcedureName(properties.getSpConsultarServicios())
                .declareParameters(
                        new SqlParameter("PI_COD_GRUPO", Types.VARCHAR),
                        new SqlParameter("PI_VALOR1", Types.VARCHAR),
                        new SqlParameter("PI_VALOR2", Types.VARCHAR),
                        new SqlParameter("PI_VALOR3", Types.VARCHAR),
                        new SqlParameter("PI_VALOR4", Types.VARCHAR),
                        new SqlParameter("PI_VALOR5", Types.VARCHAR),
                        new SqlOutParameter("PO_CODRPTA", Types.VARCHAR),
                        new SqlOutParameter("PO_MSJRPTA", Types.VARCHAR),
                        new SqlOutParameter("PO_CURSOR_LISTA", -10, configuracionMapper));
        consultarBonos = new SimpleJdbcCall(jdbcTemplate)
                .withSchemaName(properties.getBdIotOwner())
                .withCatalogName(properties.getBdIotPackage())
                .withProcedureName(properties.getSpBonosPlan())
                .declareParameters(
                        new SqlParameter("PI_COD_PLAN", Types.VARCHAR),
                        new SqlParameter("PI_TIPO_PLAN", Types.VARCHAR),
                        new SqlOutParameter("PO_CODRPTA", Types.VARCHAR),
                        new SqlOutParameter("PO_MSJRPTA", Types.VARCHAR),
                        new SqlOutParameter("PO_CURSOR_BONOS", -10, bonoMapper));
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<ServicioConfiguracion> consultarServiciosConfig(String idGrupoConfig, String valor1, String valor2,
                                                                String valor3, String valor4, String valor5) {
        try {
            Map<String, Object> result = consultarConfiguraciones.execute(
                    idGrupoConfig, valor1, valor2, valor3, valor4, valor5);
            validarCodigo((String) result.get("PO_CODRPTA"), (String) result.get("PO_MSJRPTA"));
            List<ServicioConfiguracion> rows = (List<ServicioConfiguracion>) result.get("PO_CURSOR_LISTA");
            return rows == null ? new ArrayList<>() : rows;
        } catch (QueryTimeoutException ex) {
            throw new TechnicalException(ServiceCodes.IDT_TIMEOUT, "Error de Timeout en [IOTSS_OBTENER_SERVICIOS_CONFIG]");
        } catch (CannotGetJdbcConnectionException ex) {
            throw new TechnicalException(ServiceCodes.IDT_UNAVAILABLE, "Error de Disponibilidad en [IOTDB]");
        } catch (DataAccessException ex) {
            throw new TechnicalException(ServiceCodes.IDT_TECHNICAL, "Error técnico al consultar configuraciones OTT");
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<BonoPlan> listarBonosxPlan(String idPlan, String tipoPlan) {
        try {
            Map<String, Object> result = consultarBonos.execute(idPlan, tipoPlan);
            validarCodigo((String) result.get("PO_CODRPTA"), (String) result.get("PO_MSJRPTA"));
            List<BonoPlan> rows = (List<BonoPlan>) result.get("PO_CURSOR_BONOS");
            return rows == null ? new ArrayList<>() : rows;
        } catch (QueryTimeoutException ex) {
            throw new TechnicalException(ServiceCodes.IDT_TIMEOUT, "Error de Timeout en [IOTSS_BONOS_X_PLAN]");
        } catch (CannotGetJdbcConnectionException ex) {
            throw new TechnicalException(ServiceCodes.IDT_UNAVAILABLE, "Error de Disponibilidad en [IOTDB]");
        } catch (DataAccessException ex) {
            throw new TechnicalException(ServiceCodes.IDT_TECHNICAL, "Error técnico al consultar bonos del plan");
        }
    }

    private void validarCodigo(String codigo, String mensaje) {
        if ("1".equals(codigo)) {
            throw new BusinessException(mensaje);
        }
        if (codigo != null && codigo.startsWith("-")) {
            throw new TechnicalException(ServiceCodes.IDT_TECHNICAL, mensaje);
        }
        if (codigo != null && !"0".equals(codigo)) {
            throw new BusinessException(mensaje);
        }
    }
}
