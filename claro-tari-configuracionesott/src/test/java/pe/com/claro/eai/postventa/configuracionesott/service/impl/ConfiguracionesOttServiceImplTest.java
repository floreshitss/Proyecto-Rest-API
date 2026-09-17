package pe.com.claro.eai.postventa.configuracionesott.service.impl;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ConsultaServiciosConfigRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.request.ListarBonosxPlanRequest;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.BonoPlan;
import pe.com.claro.eai.postventa.configuracionesott.canonical.response.ServicioConfiguracion;
import pe.com.claro.eai.postventa.configuracionesott.common.BusinessException;
import pe.com.claro.eai.postventa.configuracionesott.common.TechnicalException;
import pe.com.claro.eai.postventa.configuracionesott.common.ValidationException;
import pe.com.claro.eai.postventa.configuracionesott.repository.ConfiguracionesOttRepository;

import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.nullable;

class ConfiguracionesOttServiceImplTest {

    private ConfiguracionesOttRepository repository;
    private ConfiguracionesOttServiceImpl service;

    @BeforeEach
    void setUp() {
        repository = Mockito.mock(ConfiguracionesOttRepository.class);
        service = new ConfiguracionesOttServiceImpl(repository);
    }

    @Test
    void consultarServiciosConfig_Exito() {
        ConsultaServiciosConfigRequest request = new ConsultaServiciosConfigRequest();
        request.setIdGrupoConfig("GRUPO_OK");
        request.setCanal("WEB");
        request.setTipoCliente("POSTPAGO");

        List<ServicioConfiguracion> expected = Arrays.asList(
                new ServicioConfiguracion("SVC001", "Consulta", "ACTIVO")
        );
        Mockito.when(repository.consultarServiciosConfig(anyString(), nullable(String.class), nullable(String.class),
                nullable(String.class), nullable(String.class), nullable(String.class))).thenReturn(expected);

        List<ServicioConfiguracion> result = service.consultarServiciosConfig(request);

        assertEquals(1, result.size());
        assertEquals("SVC001", result.get(0).getCodigoServicio());
    }

    @Test
    void consultarServiciosConfig_Validacion() {
        ConsultaServiciosConfigRequest request = new ConsultaServiciosConfigRequest();
        request.setIdGrupoConfig(null);
        request.setCanal("WEB");
        request.setTipoCliente("POSTPAGO");

        assertThrows(ValidationException.class, () -> service.consultarServiciosConfig(request));
    }

    @Test
    void consultarServiciosConfig_SinDatos() {
        ConsultaServiciosConfigRequest request = new ConsultaServiciosConfigRequest();
        request.setIdGrupoConfig("GRUPO");
        Mockito.when(repository.consultarServiciosConfig(anyString(), nullable(String.class), nullable(String.class),
                nullable(String.class), nullable(String.class), nullable(String.class))).thenReturn(Arrays.asList());

        assertThrows(BusinessException.class, () -> service.consultarServiciosConfig(request));
    }

    @Test
    void consultarServiciosConfig_ErrorTecnico() {
        ConsultaServiciosConfigRequest request = new ConsultaServiciosConfigRequest();
        request.setIdGrupoConfig("GRUPO");
        Mockito.when(repository.consultarServiciosConfig(anyString(), nullable(String.class), nullable(String.class),
                nullable(String.class), nullable(String.class), nullable(String.class)))
                .thenThrow(new TechnicalException("-3", "Error técnico"));

        assertThrows(TechnicalException.class, () -> service.consultarServiciosConfig(request));
    }

    @Test
    void consultarServiciosConfig_ParamentrosOpcionales() {
        ConsultaServiciosConfigRequest request = new ConsultaServiciosConfigRequest();
        request.setIdGrupoConfig("GRUPO");
        Mockito.when(repository.consultarServiciosConfig(anyString(), nullable(String.class), nullable(String.class),
                nullable(String.class), nullable(String.class), nullable(String.class))).thenReturn(Arrays.asList(
                new ServicioConfiguracion("SVC001", "Consulta", "ACTIVO")));

        assertEquals(1, service.consultarServiciosConfig(request).size());
    }

    @Test
    void listarBonosxPlan_Exito() {
        ListarBonosxPlanRequest request = new ListarBonosxPlanRequest();
        request.setIdPlan("PLAN_10");
        request.setTipoSolicitud("ACTIVO");

        List<BonoPlan> expected = Arrays.asList(new BonoPlan("PLAN_10", "Plan Basico", "Bono 10GB", "VIGENTE"));
        Mockito.when(repository.listarBonosxPlan(anyString(), nullable(String.class))).thenReturn(expected);

        List<BonoPlan> result = service.listarBonosxPlan(request);

        assertEquals(1, result.size());
        assertEquals("PLAN_10", result.get(0).getIdPlan());
    }

    @Test
    void listarBonosxPlan_Validacion() {
        ListarBonosxPlanRequest request = new ListarBonosxPlanRequest();
        request.setIdPlan(null);
        request.setTipoSolicitud("ACTIVO");

        assertThrows(ValidationException.class, () -> service.listarBonosxPlan(request));
    }

    @Test
    void listarBonosxPlan_Negocio() {
        ListarBonosxPlanRequest request = new ListarBonosxPlanRequest();
        request.setIdPlan("PLAN_NO_EXISTE");
        Mockito.when(repository.listarBonosxPlan(anyString(), nullable(String.class))).thenReturn(Arrays.asList());

        assertThrows(BusinessException.class, () -> service.listarBonosxPlan(request));
    }
}
