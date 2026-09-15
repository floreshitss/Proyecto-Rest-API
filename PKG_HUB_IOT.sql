create or replace package body iot.PKG_HUB_IOT is
  /****************************************************************
  * Nombre SP          : IOTCSI_TRANSACCION
  * Proposito          : SP que registra la auditoria de las diferentes transacciones del  servicio.
  *
  * Input              : PI_CORRELATOR_ID     - Es el Id de la transaccion.
  *                      PI_SERVICE_NAME      - Nombre del metodo o API.
  *                      PI_PROVIDER_ID       - Id del vendor asignado al cliente.
  *                      PI_COUNTRY           - Nombre del pais.
  *                      PI_USUARIO           - Usuario de transaccion.
  *                      PI_FECHA_TRANSAC     - Fecha de transacciÃ³n.
  *                      PI_TELEFONO          - Telefono de usuario.
  *                      PI_SERVICIO          - Servicio.
  *                      PI_ESTADO_NOTI       - Estado de notificacion.
  *                      PI_MENSAJE           - Mensaje de error de transaccion
  *                      PI_EXT_INFO          - Parametros opcionales clave y valor.
  *
  *
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 27/11/2019 - Se elimino el campo TRANV_ESTADO_MC
  *
  REVISIONES:
  Version    Fecha        Autor           Solicitado por          Descripcion
  --------   ------       -------         ---------------         ------------
  2.0        07/08/2023   Global HITSS    Danny SÃ¡nchez        PBI000002208452 - DesactivaciÃ³n de equipos AMCO
  3.0        05/12/2024   Global HITSS    Richard Medina        IDEA-141348_PBI000002214720 ONE FIJA
  ***************************************************************/

PROCEDURE IOTSI_GEST_TRANSACT(PI_CORRELATOR_ID  IN IOTCT_TRANSACCION.TRANV_CORRELATOR_ID%TYPE,
                              PI_SERVICE_NAME   IN IOTCT_TRANSACCION.TRANV_SERVICE_NAME%TYPE,
                              PI_PROVIDER_ID    IN IOTCT_TRANSACCION.TRANV_PROVIDER_ID%TYPE,
                              PI_COUNTRY        IN IOTCT_TRANSACCION.TRANV_COUNTRY%TYPE,
                              PI_USUARIO        IN IOTCT_TRANSACCION.TRANV_USUARIO%TYPE,
                              PI_FECHA_TRANSAC  IN IOTCT_TRANSACCION.TRAND_FECHA_TRANSAC%TYPE,
                              PI_TELEFONO       IN IOTCT_TRANSACCION.TRANV_TELEFONO%TYPE,
                              PI_SERVICIO       IN IOTCT_TRANSACCION.TRANV_SERVICIO%TYPE,
                              PI_ESTADO_NOTI    IN IOTCT_TRANSACCION.TRANC_ESTADO_NOTI%TYPE,
                              PI_MENSAJE        IN IOTCT_TRANSACCION.TRANV_MENSAJE%TYPE,
                              PI_EXT_INFO       IN IOT_EXTENSIONS_TYPE,
                              PO_CODRPTA        OUT VARCHAR2,
                              PO_MSJRPTA        OUT VARCHAR2)IS

SQUTX_VALUE_CURRENT   NUMBER;
V_COUNT_ROWS_TABLE    NUMBER := 0;
V_COUNT_CORRELATOR    NUMBER := 0;

BEGIN
  PO_CODRPTA := '0';
  PO_MSJRPTA := 'Registro de transaccion exitosa.';
  SELECT COUNT(1)
    INTO V_COUNT_CORRELATOR
    FROM IOTCT_TRANSACCION T
   WHERE T.TRANV_CORRELATOR_ID = PI_CORRELATOR_ID;

   IF V_COUNT_CORRELATOR > 0 THEN
     PO_CODRPTA := '-1';
     PO_MSJRPTA := 'CorrelatorId ya se encuentra en uso. Intentar con otro.';
     RETURN;
   END IF;

   SQUTX_VALUE_CURRENT := IOTSEQ_TRANS.NEXTVAL;

      INSERT INTO IOTCT_TRANSACCION
      (TRANN_TRANSACCION_ID,
       TRANV_CORRELATOR_ID,
       TRANV_SERVICE_NAME,
       TRANV_PROVIDER_ID,
       TRANV_COUNTRY,
       TRANV_USUARIO,
       TRAND_FECHA_TRANSAC,
       TRANV_TELEFONO,
       TRANV_SERVICIO,
       TRANC_ESTADO_NOTI,
       TRANV_MENSAJE)
    VALUES
      (SQUTX_VALUE_CURRENT,
       PI_CORRELATOR_ID,
       PI_SERVICE_NAME,
       PI_PROVIDER_ID,
       PI_COUNTRY,
       PI_USUARIO,
       PI_FECHA_TRANSAC,
       PI_TELEFONO,
       PI_SERVICIO,
       PI_ESTADO_NOTI,
       PI_MENSAJE);

    SELECT COUNT(*) INTO V_COUNT_ROWS_TABLE FROM TABLE(PI_EXT_INFO);

    IF V_COUNT_ROWS_TABLE > 0 THEN
      FOR ITEM IN PI_EXT_INFO.FIRST .. PI_EXT_INFO.LAST LOOP
        INSERT INTO IOTCT_TRANSACCION_DET
          (TRANDV_CORRELATOR_ID,
           TRANDN_NUM_ORDEN,
           TRANDV_PARAMETRO,
           TRANDV_VALOR)
        VALUES
          (SQUTX_VALUE_CURRENT,
           ITEM,
           PI_EXT_INFO            (ITEM).EXINV_KEY,
           PI_EXT_INFO            (ITEM).EXINV_VALUE);
      END LOOP;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error de insercion => ' || sqlerrm;
END IOTSI_GEST_TRANSACT;
  /****************************************************************
  * Nombre SP          : IOTSI_USUARIO
  * Proposito          : SP que registra los datos del cliente que adquiere claro video.
  *
  * Input              : PI_NOMBRES           - Nombre del cliente
  *                      PI_APELLIDOS         - Apellidos del cliente.
  *                      PI_CORREO            - Corre del cliente.
  *                      PI_CUSTOMERID        - Customer ID del cliente.
  *                      PI_LINEA             - Linea del cliente.
  *                      PI_ICCID             - Fecha de transacciÃ³n.
  *                      PI_IMSI              - Imsi de la linea.
  *                      PI_DIRECCION         - Direccion del cliente
  *                      PI_PAIS              - Pais
  *                      PI_RAZON_SOCIAL      - Razon Social de cliente
  *                      PI_NRO_DOCUMENTO     - Nro de docuemnto
  *                      PI_TIPO_DOCUMENTO    - Tipo de documento
  *                      PI_TIPO_USUA         - Tipo de Usuario
  *                      PI_FECHA_NAC         - Fecha de Nacimiento
  *                      PI_ORIGEN            - Origen
  *                      PI_ESTADO            - Estado a ejecutar
  *                      PI_CREATE_USER       - Usuario de creaciÃ³n
  *
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 22/11/2019
  * Motivo             : Cambio en el campo PI_CUSTOMERID por PI_USUARIOID
  ***************************************************************/
PROCEDURE IOTSI_USUARIO         (PI_NOMBRES              IN  IOTT_CLIENTE.CLIV_NOMBRES%TYPE,
                                 PI_APELLIDOS            IN  IOTT_CLIENTE.CLIV_APELLIDOS%TYPE,
                                 PI_CORREO               IN  IOTT_CLIENTE.CLIV_CORREO%TYPE,
                                 PI_USUARIOID            IN  IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                                 PI_LINEA                IN  IOTT_CLIENTE.CLIV_LINEA%TYPE,
                                 PI_ICCID                IN  IOTT_CLIENTE.CLIV_ICCID%TYPE,
                                 PI_IMSI                 IN  IOTT_CLIENTE.CLIV_IMSI%TYPE,
                                 PI_DIRECCION            IN  IOTT_CLIENTE.CLIV_DIRECCION%TYPE,
                                 PI_PAIS                 IN  IOTT_CLIENTE.CLIV_PAIS%TYPE,
                                 PI_RAZON_SOCIAL         IN  IOTT_CLIENTE.CLIV_RAZSOC%TYPE,
                                 PI_NRO_DOCUMENTO        IN  IOTT_CLIENTE.CLIV_NRODOC%TYPE,
                                 PI_TIPO_DOCUMENTO       IN  IOTT_CLIENTE.CLIC_TIPODOC%TYPE,
                                 PI_TIPO_USUA            IN  IOTT_CLIENTE.CLIC_TIPOUSU%TYPE,
                                 PI_FECHA_NAC            IN  IOTT_CLIENTE.CLID_FECHA_NAC%TYPE,
                                 PI_ORIGEN               IN  IOTT_CLIENTE.CLIV_ORIGEN%TYPE,
                                 PI_ESTADO               IN  IOTT_CLIENTE.CLIC_ESTADO%TYPE,
                                 PI_CREATE_USER          IN  IOTT_CLIENTE.CLIV_CREATE_USER%TYPE,
                                 PO_CUSTOMERID           OUT IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                                 PO_CODRPTA              OUT VARCHAR2,
                                 PO_MSJRPTA              OUT VARCHAR2) IS

SQUTX_VALUE_USU_CURRENT NUMBER;
BEGIN
  IF PI_CORREO IS NULL THEN
    PO_CODRPTA := '1';
    PO_MSJRPTA := 'Debe ingresar un correo electrÃ³nico de usuario';
    RETURN;
  END IF;
  IF PI_USUARIOID IS NULL THEN
    SQUTX_VALUE_USU_CURRENT:=IOTSEQ_USUARIO.NEXTVAL;
  ELSE
    SQUTX_VALUE_USU_CURRENT:=PI_USUARIOID;
  END IF;

  INSERT INTO IOTT_CLIENTE
       (CLIN_USUARIOID,
        CLIC_TIPOUSU,
        CLIV_RAZSOC,
        CLIV_NOMBRES,
        CLIV_APELLIDOS,
        CLIV_CORREO,
        CLIC_TIPODOC,
        CLIV_NRODOC,
        CLIV_LINEA,
        CLIV_ICCID,
        CLIV_IMSI,
        CLIV_DIRECCION,
        CLIV_PAIS,
        CLID_FECHA_NAC,
        CLIV_ORIGEN,
        CLIC_ESTADO,
        CLIV_CREATE_USER,
        CLID_CREATE_DATE,
        CLIV_MODIFI_USER,
        CLID_MODIFI_DATE)
       VALUES
        (SQUTX_VALUE_USU_CURRENT,
         PI_TIPO_USUA,
         PI_RAZON_SOCIAL,
         PI_NOMBRES,
         PI_APELLIDOS,
         PI_CORREO,
         PI_TIPO_DOCUMENTO,
         PI_NRO_DOCUMENTO,
         PI_LINEA,
         PI_ICCID,
         PI_IMSI,
         PI_DIRECCION,
         PI_PAIS,
         PI_FECHA_NAC,
         PI_ORIGEN,
         PI_ESTADO,
         PI_CREATE_USER,
         SYSDATE,
         NULL,
         NULL);

        PO_CUSTOMERID := SQUTX_VALUE_USU_CURRENT;
        PO_CODRPTA := '0';
        PO_MSJRPTA := 'Operacion Exitosa';

EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error de insercion => ' || sqlerrm;
END IOTSI_USUARIO;
  /****************************************************************
  * Nombre SP          : IOTSU_USUARIO
  * Proposito          : SP que actualiza los datos del usuario,dispositivos y id de medio de pago.
  *
  * Input               :PI_EMAIL             - Email de cliente
  *                      PI_ID_DISPOSITIVO    - Id de dispositivo.
  *                      PI_MEDIO_PAGO        - Id de Medio de Pago.
  *                      PI_NOMBRES           - Nombre del cliente
  *                      PI_APELLIDOS         - Apellidos del cliente.
  *                      PI_CUSTOMER_ID       - Customer id del cliente.
  *
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 29/05/2020 - Dar de baja a las suscripciones cuando se quita el medio de pago
  ***************************************************************/
PROCEDURE IOTSU_USUARIO (PI_EMAIL              IN IOTT_CLIENTE.CLIV_CORREO%TYPE,
                         PI_ID_DISPOSITIVO     IN IOTCT_DISPOSITIVO_CLIENTE.DISCLV_DEVICEID%TYPE,
                         PI_MEDIO_PAGO         IN IOTT_LLAVEPAGO.LLAPV_MPAGOID%TYPE,
                         PI_NOMBRES            IN IOTT_CLIENTE.CLIV_NOMBRES%TYPE,
                         PI_APELLIDOS          IN IOTT_CLIENTE.CLIV_APELLIDOS%TYPE,
                         PI_CUSTOMER_ID        IN IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                         PO_CODRPTA            OUT VARCHAR2,
                         PO_MSJRPTA            OUT VARCHAR2)IS

 V_CONTADOR             NUMBER:=0;
 V_ESTADO               IOTT_SUSCRIPCION.SUSC_ESTADO%TYPE:='B';
 v_id                   number;

 BEGIN

   IF PI_EMAIL IS NOT NULL
     OR PI_NOMBRES IS NOT NULL
     OR PI_APELLIDOS IS NOT NULL THEN

      SELECT COUNT(E.CLIN_USUARIOID)
       INTO V_CONTADOR
       FROM IOTT_CLIENTE E
      WHERE E.CLIN_USUARIOID = PI_CUSTOMER_ID;

      IF V_CONTADOR = 0 THEN
        PO_CODRPTA := '0';
        PO_MSJRPTA := 'El CUSTOMER_ID no existe';
       RETURN;
      END IF;

      UPDATE IOTT_CLIENTE
         SET CLIV_CORREO      = NVL(PI_EMAIL, CLIV_CORREO),
             CLIV_NOMBRES     = NVL(PI_NOMBRES, CLIV_NOMBRES),
             CLIV_APELLIDOS   = NVL(PI_APELLIDOS, CLIV_APELLIDOS),
             CLIV_MODIFI_USER = USER,
             CLID_MODIFI_DATE = SYSDATE
       WHERE CLIN_USUARIOID = PI_CUSTOMER_ID;

       PO_CODRPTA := '0';
       PO_MSJRPTA := 'Operacion exitosa';

    ELSIF PI_ID_DISPOSITIVO IS NOT NULL THEN
      SELECT COUNT(1)
        INTO V_CONTADOR
        FROM IOTCT_DISPOSITIVO_CLIENTE E
       WHERE DISCLV_DEVICEID  = PI_ID_DISPOSITIVO
         AND DISCLN_USUARIOID = PI_CUSTOMER_ID;

      IF V_CONTADOR = 0 THEN
        PO_CODRPTA := '0';
        PO_MSJRPTA := 'No se pudo desvincular el dispositivo del cliente en el historial.';
       RETURN;
      END IF;

      UPDATE IOTCT_DISPOSITIVO_CLIENTE
           SET DISCLC_ESTADO      = C_AMCO_DESA,
               DISCLD_FECHA_DESV  = SYSDATE,
               DISCLV_MODIFI_USER = USER,
               DISCLD_MODIFI_DATE = SYSDATE
         WHERE DISCLV_DEVICEID = PI_ID_DISPOSITIVO
           AND DISCLN_USUARIOID = PI_CUSTOMER_ID;

          begin

              v_id:=IOT.IOTSEQ_FIJA_TRANSAC.nextval;

              INSERT INTO IOT.IOTCT_FIJA_TRANSAC
                (
                    TRANN_ID,
                    TRANV_TRANSACCION,
                    TRANV_TIPO_TRANSACCION,
                    TRANN_USUARIOID,
                    TRANV_DEVICEID,
                    TRANV_TOKEN,
                    TRANC_ESTADO,
                    TRANV_MENSAJE,
                    TRANV_CREATE_USER,
                    TRAND_CREATE_DATE)
                   VALUES
                   (v_id,
                   'TRAZABILIDAD DE ESTADO DECO CLIENTE',
                   'IOTSU_USUARIO',
                     PI_CUSTOMER_ID,
                     PI_ID_DISPOSITIVO,
                     PI_CUSTOMER_ID||'0;phone-context=claro.pe',
                     'D',
                     'DesasociaciÃ³n de deco: '||PI_ID_DISPOSITIVO||' al cliente '||PI_CUSTOMER_ID,
                     USER,
                     SYSDATE
                    );

             Exception
             When Others Then
              po_codrpta    := -2;
              po_msjrpta    := 'Error de insercion: ' || Sqlerrm;

            END;

           PO_CODRPTA := '0';
           PO_MSJRPTA := 'Operacion exitosa';

    ELSIF PI_MEDIO_PAGO IS NOT NULL  THEN

        UPDATE IOTT_SUSCRIPCION
           SET SUSC_ESTADO      = V_ESTADO,
               SUSV_MODIFI_USER = USER,
               SUSD_MODIFI_DATE = SYSDATE
         WHERE SUSN_USUARIOID = PI_CUSTOMER_ID;

         PO_CODRPTA := '0';
         PO_MSJRPTA := 'Operacion exitosa';
    ELSIF PI_CUSTOMER_ID IS NOT NULL
      AND PI_EMAIL IS NULL
      AND PI_ID_DISPOSITIVO IS NULL
      AND PI_MEDIO_PAGO IS NULL
      AND PI_NOMBRES IS NULL
      AND PI_APELLIDOS IS NULL THEN

      SELECT IC.CLIC_ESTADO
        INTO V_ESTADO
        FROM IOT.IOTT_CLIENTE IC
       WHERE IC.CLIN_USUARIOID = PI_CUSTOMER_ID;

      IF (V_ESTADO <> 'A') THEN

        UPDATE IOT.IOTT_CLIENTE IC
           SET IC.CLIC_ESTADO = 'A',
           IC.CLID_MODIFI_DATE = SYSDATE
         WHERE IC.CLIN_USUARIOID = PI_CUSTOMER_ID;

        PO_CODRPTA := '0';
        PO_MSJRPTA := 'Operacion exitosa';
      ELSE

        PO_CODRPTA := '1';
        PO_MSJRPTA := 'Estado del cliente ' || PI_CUSTOMER_ID ||
                      ' no se actualizo, ya que su estado se encuentra en ' || V_ESTADO;
      END IF;

END IF;
 EXCEPTION
   WHEN OTHERS THEN
     BEGIN
       PO_CODRPTA := '-1';
       PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
     END;
END IOTSU_USUARIO;

/****************************************************************
  * Nombre SP          : IOTSD_USUARIO
  * Proposito          : SP que actualiza el estado del cliente a inactivo.
  *
  * Input               :PI_CUSTOMER_ID       - Customer Id del cliente
  *                      PI_ESTADO            - Estado de eliminaciÃ³n.
  *                      PO_METODOPAGO        - Metodo de
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 19/05/2020 - Dar de Baja al cliente y suscripciones.
  ***************************************************************/

PROCEDURE IOTSD_USUARIO (PI_CUSTOMER_ID       IN IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                         PI_ESTADO            IN IOTT_CLIENTE.CLIC_ESTADO%TYPE,
                         PO_METODOPAGO      OUT IOTT_SUSCRIPCION.SUSV_METODOPAGO%TYPE,  --NUEVO
                         PO_LINEA       OUT IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,     --NUEVO
                         PO_CODRPTA           OUT VARCHAR2,
                         PO_MSJRPTA           OUT VARCHAR2)
IS
  V_CONTADOR             NUMBER:=0;
  V_CONTADORS            NUMBER:=0;
  V_ESTADO               IOTT_SUSCRIPCION.SUSC_ESTADO%TYPE:='B';

  BEGIN
   SELECT COUNT(1)
     INTO V_CONTADOR
     FROM IOTT_CLIENTE
    WHERE CLIN_USUARIOID = PI_CUSTOMER_ID;

    IF V_CONTADOR = 0 THEN
      PO_CODRPTA := '1';
      PO_MSJRPTA := 'El id de usuario no existe';
    ELSE
      UPDATE IOTT_CLIENTE
         SET CLIC_ESTADO      = PI_ESTADO,
             CLIV_MODIFI_USER = USER,
             CLID_MODIFI_DATE = SYSDATE
         WHERE CLIN_USUARIOID = PI_CUSTOMER_ID;

      UPDATE IOTT_SUSCRIPCION
          SET SUSC_ESTADO = V_ESTADO,
              SUSV_MODIFI_USER = USER,
              SUSD_MODIFI_DATE = SYSDATE
       WHERE SUSN_USUARIOID = PI_CUSTOMER_ID;
      -- INI 2.0
      UPDATE IOT.IOTCT_DISPOSITIVO_CLIENTE
          SET DISCLC_ESTADO      = C_AMCO_DESA,
              DISCLD_FECHA_DESV  = SYSDATE,
              DISCLV_MODIFI_USER = USER,
              DISCLD_MODIFI_DATE = SYSDATE
       WHERE DISCLN_USUARIOID = PI_CUSTOMER_ID AND DISCLC_ESTADO = C_AMCO_ACTI;
      -- FIN 2.0
  SELECT COUNT(1)
     INTO V_CONTADORS
     FROM IOTT_SUSCRIPCION
    WHERE SUSN_USUARIOID = PI_CUSTOMER_ID
    AND SUSV_METODOPAGO=2;

       IF V_CONTADORS =0 THEN
      PO_CODRPTA := '0';
      PO_MSJRPTA := 'Operacion Exitosa';
      RETURN;
      END IF;

      SELECT SUSV_METODOPAGO,SUSV_LINEA
      INTO PO_METODOPAGO,PO_LINEA
      FROM IOTT_SUSCRIPCION
      WHERE SUSN_USUARIOID = PI_CUSTOMER_ID
      AND ROWNUM =1;
      PO_CODRPTA := '0';
      PO_MSJRPTA := 'Operacion Exitosa';



    END IF;
EXCEPTION
   WHEN OTHERS THEN
      BEGIN
        PO_CODRPTA := '-1';
        PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
      END;
END IOTSD_USUARIO;

/****************************************************************
  * Nombre SP          : IOTSU_SUSCRIPCION
  * Proposito          : SP que inserta, atualiza datos de la tabla suscripcion
  *                      segun el flag de busqueda PI_ESTADO.
  *
  * Input               :PI_SERVICEID         - Product Id de la suscripciÃ³n
  *                      PI_TOKEN             - Token del cliente.
  *                      PI_CUSTOMERID        - Customer Id del cliente
  *                      PI_ESTADO            - Flag que indica la accion a realizar
  *                                             (I:Insertar una suscripciÃ³n
  *                                              N:Cambio de Numero
  *                                              R:Reactivacion de la linea
  *                                              S:SuspensiÃ³n de la linea.)
  *                      PI_LINEA1            - Linea actual del cliente
  *                      PI_LINEA2            - Linea nueva del cliente
                                                (Se usa cuando PI_ESTADO='N')
  *                      PI_TIPO_LINEA        - Tipo de linea del cliente(PREPAGO
  *                                              POSTPAGO)
  *                      PI_METODO_PAGO       - Metodo de Pago (Fija o Movil)
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 27/02/2020 - Se cambio para que  inserte en historial cuando es cambio de numero.
  *                      26/06/2020 - ActualizaciÃ³n de insercion en la tabla historial
  ***************************************************************/
PROCEDURE IOTSU_SUSCRIPCION  (PI_SERVICEID         IN VARCHAR2,
                              PI_TOKEN             IN  IOTT_SUSCRIPCION.SUSV_TOKEN%TYPE,
                              PI_CUSTOMERID        IN  IOTT_SUSCRIPCION.SUSV_CUSTOMERID%TYPE,
                              PI_USUARIOID         IN  IOTT_SUSCRIPCION.SUSN_USUARIOID%TYPE,--NUEVO
                              PI_ESTADO            IN  IOTT_SUSCRIPCION.SUSC_ESTADO%TYPE,
                              PI_LINEA1            IN  IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                              PI_LINEA2            IN  IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                              PI_TIPO_LINEA        IN  IOTT_SUSCRIPCION.SUSV_TIPO_LINEA%TYPE,--Nuevo
                              PI_METODO_PAGO       IN  IOTT_SUSCRIPCION.SUSV_METODOPAGO%TYPE,--Nuevo
                              PO_CODRPTA           OUT VARCHAR2,
                              PO_MSJRPTA           OUT VARCHAR2) IS


SQUTX_VALUE_SUS_CURRENT       NUMBER;
V_COUNT                       NUMBER := 0;
V_LINEA                       NUMBER := 0;
V_TIPO_CLIENTE                CHAR(1):= '1';
V_CONTADOR_COBRO              IOTT_SUSCRIPCION.SUSN_CONTADOR_COBRO%TYPE:=0;
V_FECHA_VIGENCIA              IOTT_SUSCRIPCION.SUSD_FECHA_VIGENCIA%TYPE;
V_ESTADO_BAJA                 IOTT_SUSCRIPCION.SUSC_ESTADO%TYPE:='B';
  V_TIPO_LINEA                  IOTT_SUSCRIPCION.SUSV_TIPO_LINEA%TYPE;
  V_METODOPAGO                  IOTT_SUSCRIPCION.SUSV_METODOPAGO%TYPE;
  V_CUSTOMERID                  IOTT_SUSCRIPCION.SUSV_CUSTOMERID%TYPE;
  V_SERVICIOID                  IOTT_SUSCRIPCION.SUSN_SERVICIOID%TYPE;
  V_FECHA_SUSCRIPCION           IOTT_SUSCRIPCION.SUSD_FECHA_SUSCRIPCION%TYPE;
  E_ERROR                       EXCEPTION;
  E_ERROR_ROW                   EXCEPTION;

BEGIN
  PO_CODRPTA := '0';
  PO_MSJRPTA := 'Operacion Exitosa';

  IF PI_LINEA1 IS NULL THEN
    PO_CODRPTA := '1';
    PO_MSJRPTA := 'Debe ingresar una linea';
    RETURN;
  END IF;
  CASE PI_ESTADO
    WHEN 'I' THEN
      SELECT COUNT(1)
        INTO V_LINEA
        FROM IOTT_SUSCRIPCION
       WHERE SUSV_LINEA = PI_LINEA1
         AND SUSN_SERVICIOID = PI_SERVICEID
         AND SUSC_ESTADO = C_AMCO_ACTI;

         IF V_LINEA = 0 THEN
           SELECT COUNT(1)
             INTO V_COUNT
             FROM IOTT_CLIENTE C
            WHERE C.CLIN_USUARIOID = PI_USUARIOID
              AND C.CLIC_ESTADO = C_AMCO_ACTI;

              IF V_COUNT > 0 THEN
                SELECT (CASE X.SERVN_DIAS_PROMO
                        WHEN 7 THEN
                         SYSDATE + 7
                        WHEN 30 THEN
                         ADD_MONTHS(SYSDATE, 1)
                        WHEN 90 THEN
                         ADD_MONTHS(SYSDATE, 3)
                        WHEN 365 THEN
                         ADD_MONTHS(SYSDATE, 12)
                        WHEN 730 THEN
                         ADD_MONTHS(SYSDATE, 24)
                        WHEN 0 THEN
                         ADD_MONTHS(SYSDATE, 1)
                        ELSE
                          NULL
                      END)
                 INTO V_FECHA_VIGENCIA
                 FROM IOTCT_SERVICIO X
                WHERE X.SERVN_SERVICEID = PI_SERVICEID;

                SQUTX_VALUE_SUS_CURRENT := IOTSEQ_SUSCRIPCION.NEXTVAL;

                 INSERT INTO IOTT_SUSCRIPCION
                 (SUSN_SUSCRIPCIONID,
                  SUSV_TIPOCLI,
                  SUSV_TOKEN,
                  SUSV_LINEA,
                  SUSV_TIPO_LINEA,
                  SUSN_CONTADOR_COBRO,
                  SUSV_CUSTOMERID,
                  SUSD_FECHA_SUSCRIPCION,
                  SUSD_FECHA_VIGENCIA,
                  SUSN_SERVICIOID,
                  SUSV_METODOPAGO,
                  SUSN_USUARIOID,
                  SUSC_ESTADO,
                  SUSV_CREATE_USER,
                  SUSV_CREATE_DATE,
                  SUSV_MODIFI_USER,
                  SUSD_MODIFI_DATE)
               VALUES
                 (SQUTX_VALUE_SUS_CURRENT,
                  V_TIPO_CLIENTE,
                  PI_TOKEN,
                  TRIM(PI_LINEA1),
                  TRIM(UPPER(PI_TIPO_LINEA)),
                  V_CONTADOR_COBRO,
                  PI_CUSTOMERID,
                  SYSDATE,
                  V_FECHA_VIGENCIA,
                  PI_SERVICEID,
                  PI_METODO_PAGO,
                  PI_USUARIOID,
                  C_AMCO_ACTI,
                  USER,
                  SYSDATE,
                  NULL,
                  NULL);

                 INSERT INTO IOTT_SUSCRIPCION_HIST
                  (SUSHN_SUSCID_HIST,
                   SUSHV_LINEA,
                   SUSHV_TIPO_LINEA,
                   SUSHV_METODO_PAGO,
                   SUSHV_CUSTOMERID,
                   SUSHN_SERVICIOID,
                   SUSHD_FECHA_SUSCRIPCION,
                   SUSHD_FECHA_VIGENCIA,
                   SUSHD_FECHA_OPERACION,
                   SUSHV_TIPO_OPERACION,
                   SUSHV_ESTADO_SUS,
                   SUSHV_CREATE_USER,
                   SUSHD_CREATE_DATE)
               VALUES
                 (IOTSEQ_SUSC_HIST.NEXTVAL,
                  TRIM(PI_LINEA1),
                  TRIM(UPPER(PI_TIPO_LINEA)),
                  PI_METODO_PAGO,
                  PI_CUSTOMERID,
                  PI_SERVICEID,
                  SYSDATE,
                  V_FECHA_VIGENCIA,
                  SYSDATE,
                  '1',
                  'A',
                  USER,
                  SYSDATE);

              ELSE
                  PO_CODRPTA := '1';
                  PO_MSJRPTA := 'El cliente no existe.';
              END IF;
         ELSE
           PO_CODRPTA := '1';
           PO_MSJRPTA := 'Existe la linea y el servicio.';
         END IF;

    WHEN 'N' THEN
      SELECT COUNT(1)
        INTO V_LINEA
        FROM IOTT_SUSCRIPCION
       WHERE SUSV_LINEA = PI_LINEA1
         AND SUSC_ESTADO <> V_ESTADO_BAJA
         AND (SUSV_METODOPAGO = '1' or SUSV_METODOPAGO = '3');

         IF V_LINEA = 0 THEN
           PO_CODRPTA := '1';
           PO_MSJRPTA := 'La linea mÃ³vil no cuenta con suscripciones';
         ELSE
           UPDATE IOTT_SUSCRIPCION
              SET SUSV_LINEA       = PI_LINEA2,
                  SUSV_MODIFI_USER = USER,
                  SUSD_MODIFI_DATE = SYSDATE
            WHERE SUSV_LINEA = PI_LINEA1
              AND SUSC_ESTADO <> V_ESTADO_BAJA
              AND (SUSV_METODOPAGO = '1' or SUSV_METODOPAGO = '3');

             PO_CODRPTA := '0';
             PO_MSJRPTA := 'Operacion Exitosa';
         END IF;
    WHEN 'R' THEN
      SELECT COUNT(1)
        INTO V_LINEA
        FROM IOTT_SUSCRIPCION
       WHERE SUSV_LINEA = PI_LINEA1
         AND SUSC_ESTADO = C_AMCO_SUSP;

         IF V_LINEA = 0 THEN
           PO_CODRPTA := '1';
           PO_MSJRPTA := 'La linea no cuenta con suscripciones suspendidas';
         ELSE
           INSERT INTO IOTT_SUSCRIPCION_HIST
                  (SUSHN_SUSCID_HIST,
                   SUSHV_LINEA,
                   SUSHV_TIPO_LINEA,
                   SUSHV_METODO_PAGO,
                   SUSHV_CUSTOMERID,
                   SUSHN_SERVICIOID,
                   SUSHD_FECHA_SUSCRIPCION,
                   SUSHD_FECHA_VIGENCIA,
                   SUSHD_FECHA_OPERACION,
                   SUSHV_TIPO_OPERACION,
                   SUSHV_ESTADO_SUS,
                   SUSHV_CREATE_USER,
                   SUSHD_CREATE_DATE)
               VALUES
                 (IOTSEQ_SUSC_HIST.NEXTVAL,
                  TRIM(PI_LINEA1),
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  SYSDATE,
                  '3',
                  'R',
                  USER,
                  SYSDATE);

           UPDATE IOTT_SUSCRIPCION
              SET SUSC_ESTADO      = C_AMCO_ACTI,
                  SUSV_MODIFI_USER = USER,
                  SUSD_MODIFI_DATE = SYSDATE
            WHERE SUSV_LINEA = PI_LINEA1
              AND SUSC_ESTADO = C_AMCO_SUSP;
           END IF;

    WHEN 'S' THEN
      SELECT COUNT(1)
        INTO V_LINEA
        FROM IOTT_SUSCRIPCION
       WHERE SUSV_LINEA = PI_LINEA1
         AND SUSC_ESTADO = C_AMCO_ACTI;

      IF V_LINEA = 0 THEN
         PO_CODRPTA := '1';
         PO_MSJRPTA := 'La linea no cuenta con suscripciones activas';
      ELSE
         INSERT INTO IOTT_SUSCRIPCION_HIST
                  (SUSHN_SUSCID_HIST,
                   SUSHV_LINEA,
                   SUSHV_TIPO_LINEA,
                   SUSHV_METODO_PAGO,
                   SUSHV_CUSTOMERID,
                   SUSHN_SERVICIOID,
                   SUSHD_FECHA_SUSCRIPCION,
                   SUSHD_FECHA_VIGENCIA,
                   SUSHD_FECHA_OPERACION,
                   SUSHV_TIPO_OPERACION,
                   SUSHV_ESTADO_SUS,
                   SUSHV_CREATE_USER,
                   SUSHD_CREATE_DATE)
               VALUES
                 (IOTSEQ_SUSC_HIST.NEXTVAL,
                  TRIM(PI_LINEA1),
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  SYSDATE,
                  '4',
                  'S',
                  USER,
                  SYSDATE);

          UPDATE IOTT_SUSCRIPCION
             SET SUSC_ESTADO      = C_AMCO_SUSP,
                 SUSV_MODIFI_USER = USER,
                 SUSD_MODIFI_DATE = SYSDATE
           WHERE SUSV_LINEA = PI_LINEA1
             AND SUSC_ESTADO = C_AMCO_ACTI;
      END IF;

    WHEN 'C' THEN
      BEGIN
       SELECT S.SUSV_TIPO_LINEA,
              S.SUSV_METODOPAGO,
              S.SUSV_CUSTOMERID,
              S.SUSN_SERVICIOID,
              S.SUSD_FECHA_SUSCRIPCION,
              S.SUSD_FECHA_VIGENCIA
         INTO V_TIPO_LINEA,
              V_METODOPAGO,
              V_CUSTOMERID,
              V_SERVICIOID,
              V_FECHA_SUSCRIPCION,
              V_FECHA_VIGENCIA
         FROM IOTT_SUSCRIPCION S
       WHERE SUSV_LINEA = PI_LINEA1
         AND SUSN_SERVICIOID = PI_SERVICEID
         AND SUSC_ESTADO = C_AMCO_ACTI;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE E_ERROR;
        WHEN TOO_MANY_ROWS THEN
          RAISE E_ERROR_ROW;
       END;

          INSERT INTO IOTT_SUSCRIPCION_HIST
            (SUSHN_SUSCID_HIST,
             SUSHV_LINEA,
             SUSHV_TIPO_LINEA,
             SUSHV_METODO_PAGO,
             SUSHV_CUSTOMERID,
             SUSHN_SERVICIOID,
             SUSHD_FECHA_SUSCRIPCION,
             SUSHD_FECHA_VIGENCIA,
             SUSHD_FECHA_OPERACION,
             SUSHV_TIPO_OPERACION,
             SUSHV_ESTADO_SUS,
             SUSHV_CREATE_USER,
             SUSHD_CREATE_DATE)
          VALUES
            (IOTSEQ_SUSC_HIST.NEXTVAL,
             TRIM(PI_LINEA1),
             V_TIPO_LINEA,
             V_METODOPAGO,
             V_CUSTOMERID,
             V_SERVICIOID,
             V_FECHA_SUSCRIPCION,
             V_FECHA_VIGENCIA,
                   SYSDATE,
                   '5',
                   'C',
                   USER,
             SYSDATE);

          UPDATE IOTT_SUSCRIPCION
               SET SUSC_ESTADO      = C_AMCO_CANC,
                   SUSV_MODIFI_USER = USER,
                   SUSD_MODIFI_DATE = SYSDATE
             WHERE SUSV_LINEA = PI_LINEA1
               AND SUSN_SERVICIOID = PI_SERVICEID
               AND SUSC_ESTADO = C_AMCO_ACTI;

     ELSE
       PO_CODRPTA := '1';
       PO_MSJRPTA := 'Estado incorrecto';
  END CASE;
EXCEPTION
     WHEN E_ERROR THEN
      PO_CODRPTA := '1';
      PO_MSJRPTA := 'Linea/Servicio no existe';
    WHEN E_ERROR_ROW then
      PO_CODRPTA := '2';
      PO_MSJRPTA := 'Existe Mas de un servicio asociado a la linea  ' ||
                    PI_LINEA1;
     WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error de insercion => ' || sqlerrm;
END IOTSU_SUSCRIPCION;

/****************************************************************
  * Nombre SP          : IOTSI_DISPO_MEDP
  * Proposito          : SP que registra las consultas de dispositivos y medios de pago.
  *
  * Input               :PI_METODOS_PAGO      - Arreglo de medios de pago
  *                      PI_DISPOSITIVOS      - Arreglo de dispositivos.
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Motivo             : Se agrego el parametro PI_LINEA en el SP, se modifico la tabla
  *                      agregando el parametro linea.
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  :
  ***************************************************************/

PROCEDURE IOTSI_DISPO_MEDP (PI_METODOS_PAGO IN IOT.IOTC_METODO_PAGO_TYPE,
                            PI_DISPOSITIVOS IN IOT.IOTC_DISPOSITIVOS_TYPE,
                            PI_LINEA        IN IOTCT_DISPOSITIVO_CLIENTE.DISCLN_LINEA%TYPE,
                            PI_CUSTOMER_ID  IN VARCHAR2,
                            PO_CODRPTA      OUT VARCHAR2,
                            PO_MSJRPTA      OUT VARCHAR2)IS

COUNT_ROWS_TABLE        NUMBER := 0;
V_CANTIDAD              NUMBER := 0;
SQUTX_VALUE_DIS_CURRENT NUMBER;
BEGIN
  SELECT COUNT(*) INTO COUNT_ROWS_TABLE FROM TABLE(PI_METODOS_PAGO);

  IF COUNT_ROWS_TABLE > 0 THEN
    FOR i IN PI_METODOS_PAGO.FIRST .. PI_METODOS_PAGO.LAST LOOP

      SELECT COUNT(1)
       INTO V_CANTIDAD
       FROM IOTT_LLAVEPAGO L
      WHERE L.LLAPV_CUSTOMERID = PI_CUSTOMER_ID
        AND L.LLAPV_MPAGOID = PI_METODOS_PAGO(I).ID_MEDIO_PAGO;

      IF V_CANTIDAD = 0 THEN
        INSERT INTO IOTT_LLAVEPAGO
          (LLAPV_CUSTOMERID,
           LLAPV_MPAGOID,
           LLAPV_DESCRIP,
           LLAPV_CREATE_USER,
           LLAPV_CREATE_DATE,
           LLAPV_MODIFI_USER,
           LLAPV_MODIFI_DATE,
           LLAPC_ESTADO)
        VALUES
          (PI_CUSTOMER_ID,
           PI_METODOS_PAGO(I).ID_MEDIO_PAGO,
           PI_METODOS_PAGO(I).DESC_PAGO,
           USER,
           SYSDATE,
           NULL,
           NULL,
           C_AMCO_ACTI);
      END IF;
    END LOOP;
  END IF;

  SELECT COUNT(*) INTO COUNT_ROWS_TABLE FROM TABLE(PI_DISPOSITIVOS);

  IF COUNT_ROWS_TABLE > 0 THEN

     FOR i IN PI_DISPOSITIVOS.FIRST .. PI_DISPOSITIVOS.LAST LOOP

       SELECT COUNT(1)
         INTO V_CANTIDAD
         FROM IOTCT_DISPOSITIVO_CLIENTE D
        WHERE (D.DISCLN_USUARIOID = PI_CUSTOMER_ID OR
              D.DISCLN_LINEA = PI_LINEA)
          AND D.DISCLV_DEVICEID = PI_DISPOSITIVOS(I).ID_DISPOSITVO
          AND D.DISCLC_ESTADO = 'A';

          IF V_CANTIDAD = 0 THEN

            SQUTX_VALUE_DIS_CURRENT := IOTSEQ_DISPOSTIVOS_CLIENTE.NEXTVAL;

            INSERT INTO IOTCT_DISPOSITIVO_CLIENTE
             (DISCLN_DISCLID,
              DISCLN_USUARIOID,
              DISCLN_LINEA,
              DISCLV_NOMDISP,
              DISCLV_TIPODISP,
              DISCLV_DEVICEID,
              DISCLD_FECHA_ACT,
              DISCLD_FECHA_DESV,
              DISCLC_ESTADO,
              DISCLV_CREATE_USER,
              DISCLV_CREATE_DATE,
              DISCLV_MODIFI_USER,
              DISCLD_MODIFI_DATE)
           VALUES
             (SQUTX_VALUE_DIS_CURRENT,
              PI_CUSTOMER_ID,
              PI_LINEA,
              PI_DISPOSITIVOS(I).NOMBRE_DISPOSITIVO,
              PI_DISPOSITIVOS(I).TIPO_DISPOSITIVO,
              PI_DISPOSITIVOS(I).ID_DISPOSITVO,
              PI_DISPOSITIVOS(I).FECHA_ACTIVACION,
              NULL,
              C_AMCO_ACTI,
              USER,
              SYSDATE,
              NULL,
              NULL);
           END IF;
     END LOOP;
  END IF;
  PO_CODRPTA := '0';
  PO_MSJRPTA := 'Operacion Exitosa';

EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error de insercion => ' || sqlerrm;
END IOTSI_DISPO_MEDP;
/****************************************************************
  * Nombre SP          : IOTSS_VIGENCIA_SUSCRIPCION
  * Proposito          : SP que lista las suscripciones  activas vigentes de cobro
  *                      para prepago.
  *
  * Output             : PO_CURSOR            - Listado de suscripciones vigentes de cobro.
  *                      @ID_SUSCRIPCION
  *                      @LINEA
  *                      @PRODUCTID
  *                      @PRECIO
  *                      @DESCRIPCION
  *                      @TIPO_LINEA
  *                      @CONTADOR_COBRO
  *                      @FECHA_VIGENCIA
  *                      @USUARIOID
  *                      PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 25/03/2020 - Se agrego el parametro de salida USUARIOID.
  *                      10/05/2020 - Cambio en el filtro paga.
  ***************************************************************/
PROCEDURE IOTSS_VIGENCIA_SUSCRIPCION(PO_CURSOR  OUT C_REF_CURSOR,
                                     PO_CODRPTA OUT VARCHAR2,
                                     PO_MSJRPTA OUT VARCHAR2)IS
V_CONTADOR        NUMBER:=0;
V_TEXTO_PREPAGO   VARCHAR(10):='PREPAGO';
V_ESTADO_ACTIVO   CHAR(1):='A';
BEGIN
  SELECT COUNT(1)
    INTO V_CONTADOR
    FROM IOTT_SUSCRIPCION S
    JOIN IOTCT_SERVICIO E
      ON S.SUSN_SERVICIOID = E.SERVN_SERVICEID
   WHERE UPPER(S.SUSV_TIPO_LINEA) = V_TEXTO_PREPAGO
     AND TRUNC(S.SUSD_FECHA_VIGENCIA) < TRUNC(SYSDATE)
     AND S.SUSC_ESTADO = V_ESTADO_ACTIVO
     AND E.SERVV_TIPO = C_AMCO_PAGA;

  IF V_CONTADOR > 0 THEN
    OPEN PO_CURSOR FOR
     SELECT S.SUSN_SUSCRIPCIONID  ID_SUSCRIPCION,
            S.SUSV_LINEA          LINEA,
            S.SUSN_SERVICIOID     PRODUCTID,
            E.SERVD_PRECIO        PRECIO,
            E.SERVV_DESCRIP       DESCRIPCION,
            S.SUSV_TIPO_LINEA     TIPO_LINEA,
            S.SUSN_CONTADOR_COBRO CONTADOR_COBRO,
            S.SUSD_FECHA_VIGENCIA FECHA_VIGENCIA,
            S.SUSN_USUARIOID      USUARIOID
       FROM IOTT_SUSCRIPCION S
       JOIN IOTCT_SERVICIO E
         ON S.SUSN_SERVICIOID = E.SERVN_SERVICEID
      WHERE UPPER(S.SUSV_TIPO_LINEA) = V_TEXTO_PREPAGO
        AND TRUNC(S.SUSD_FECHA_VIGENCIA) < TRUNC(SYSDATE)
        AND UPPER(S.SUSC_ESTADO) = V_ESTADO_ACTIVO
        AND E.SERVV_TIPO = C_AMCO_PAGA;

        PO_CODRPTA := '0';
        PO_MSJRPTA := 'Operacion Exitosa';
  ELSE
    OPEN PO_CURSOR FOR
       SELECT  NULL ID_SUSCRIPCION,
               NULL LINEA,
               NULL PRODUCTID,
               NULL PRECIO,
               NULL DESCRIPCION,
               NULL TIPO_LINEA,
               NULL CONTADOR,
               NULL FECHA_VIGENCIA,
               NULL USUARIOID
          FROM DUAL WHERE ROWNUM=0;
          PO_CODRPTA     := 1;
          PO_MSJRPTA     := 'No se encontraron suscripciones vigentes de cobro.';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_VIGENCIA_SUSCRIPCION;
/****************************************************************
  * Nombre SP          : IOTSU_CONTADOR_PREPAGO
  * Proposito          : SP que actualiza el contador de prepago.
  *
  * Input               :PI_LINEA             - Linea del cliente
  *                      PI_SUSCRIPCIONID     - Id de suscripcion.
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  :
***************************************************************/
PROCEDURE IOTSU_CONTADOR_PREPAGO   (PI_LINEA         IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                    PI_SUSCRIPCIONID IN IOTT_SUSCRIPCION.SUSN_SUSCRIPCIONID%TYPE,
                                    PO_CODRPTA       OUT VARCHAR2,
                                    PO_MSJRPTA       OUT VARCHAR2) IS
V_INCREMENTO NUMBER := 1;
V_CONTADOR   NUMBER := 0;

BEGIN
  SELECT COUNT(1)
    INTO V_CONTADOR
    FROM IOTT_SUSCRIPCION S
   WHERE S.SUSN_SUSCRIPCIONID = PI_SUSCRIPCIONID
     AND SUSV_LINEA = PI_LINEA;

     IF (V_CONTADOR > 0) THEN
       UPDATE IOTT_SUSCRIPCION
          SET SUSN_CONTADOR_COBRO =
              (SUSN_CONTADOR_COBRO + V_INCREMENTO)
        WHERE SUSN_SUSCRIPCIONID = PI_SUSCRIPCIONID
          AND SUSV_LINEA = PI_LINEA;

          PO_CODRPTA := '0';
          PO_MSJRPTA := 'SE ACTUALIZO EL CONTADOR PREPAGO';
     ELSE
       PO_CODRPTA := '1';
       PO_MSJRPTA := 'NO EXISTEN REGISTROS A ACTUALIZAR';
     END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error al actualizar el contador => ' || SQLERRM;
END IOTSU_CONTADOR_PREPAGO;
/****************************************************************
  * Nombre SP          : IOTSU_NUEVA_VIG_SUS
  * Proposito          : SP que actualiza la fecha de vigencia a 1 mes por
                         la linea y el id de suscripcion.
  *
  * Input               :PI_LINEA             - Linea del cliente
  *                      PI_SUSCRIPCIONID     - Id de suscripcion.
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  :
***************************************************************/

PROCEDURE IOTSU_NUEVA_VIG_SUS(PI_LINEA           IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                              PI_SUSCRIPCIONID   IN IOTT_SUSCRIPCION.susn_suscripcionid%TYPE,
                              PO_CODRPTA OUT VARCHAR2,
                              PO_MSJRPTA OUT VARCHAR2)IS

V_CONTADOR       NUMBER :=0;
V_FECHA_VIGENCIA DATE;
BEGIN
  SELECT COUNT(1)
    INTO V_CONTADOR
    FROM IOTT_SUSCRIPCION S
   WHERE SUSV_LINEA = PI_LINEA
     AND SUSN_SUSCRIPCIONID = PI_SUSCRIPCIONID;

  SELECT SUSD_FECHA_VIGENCIA
    INTO V_FECHA_VIGENCIA
    FROM IOTT_SUSCRIPCION
   WHERE SUSV_LINEA = PI_LINEA
     AND SUSN_SUSCRIPCIONID = PI_SUSCRIPCIONID;

     IF (V_CONTADOR > 0) THEN
       UPDATE IOTT_SUSCRIPCION S
          SET S.SUSD_FECHA_VIGENCIA = ADD_MONTHS(V_FECHA_VIGENCIA, 1),
              S.SUSV_MODIFI_USER    = USER,
              S.SUSD_MODIFI_DATE    = SYSDATE
        WHERE SUSV_LINEA = PI_LINEA
          AND SUSN_SUSCRIPCIONID = PI_SUSCRIPCIONID;

          PO_CODRPTA := '0';
          PO_MSJRPTA := 'SE ACTUALIZO LA FECHA DE VIGENCIA';
     ELSE
       PO_CODRPTA := '1';
       PO_MSJRPTA := 'NO EXISTEN REGISTROS A ACTUALIZAR';
     END IF;


EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;

END IOTSU_NUEVA_VIG_SUS;
/****************************************************************
  * Nombre SP          : ISTSI_SUSCRIPCION_HIST
  * Proposito          : SP que insetar las suscripciones a la tabla historial
                         (IOTT_SUSCRIPCION_HIST).
  *
  * Input               :PI_LINEA             - Linea del cliente
  *                      PI_SUSCRIPCIONID     - Id de suscripcion.
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Motivo :   Se renombro el nombre del campo Fecha a SUSHD_FECHA_OPERACION , se agrego el campo
  *            SUSHD_FECHA_SUSCRIPCION.
  *            Se elimino los campos Fecha de Moficacion y Usuario de ModificaciÃ³n ya que no se usan.
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 26/06/2020 - Se quito la llave foranea y la columna
***************************************************************/
PROCEDURE IOTSI_SUSCRIPCION_HIST(PI_LINEA      IN IOTT_SUSCRIPCION_HIST.SUSHV_LINEA%TYPE,
                                 PI_SERVICIOID IN IOTT_SUSCRIPCION_HIST.SUSHN_SERVICIOID%TYPE,
                                 PI_OPERACION  IN IOTT_SUSCRIPCION_HIST.SUSHV_TIPO_OPERACION%TYPE,
                                 PO_CODRPTA    OUT VARCHAR2,
                                 PO_MSJRPTA    OUT VARCHAR2) IS

  SQUTX_VALUE_SUSH_CURRENT NUMBER := IOTSEQ_SUSC_HIST.NEXTVAL;
BEGIN

  INSERT INTO IOTT_SUSCRIPCION_HIST
    (SUSHN_SUSCID_HIST,
     SUSHV_LINEA,
     SUSHV_TIPO_LINEA,
     SUSHV_METODO_PAGO,
     SUSHV_CUSTOMERID,
     SUSHN_SERVICIOID,
     SUSHD_FECHA_SUSCRIPCION,
     SUSHD_FECHA_VIGENCIA,
     SUSHD_FECHA_OPERACION,
     SUSHV_TIPO_OPERACION,
     SUSHV_ESTADO_SUS,
     SUSHV_CREATE_USER,
     SUSHD_CREATE_DATE)
    SELECT SQUTX_VALUE_SUSH_CURRENT,
           SUSV_LINEA,
           SUSV_TIPO_LINEA,
           SUSV_METODOPAGO,
           SUSV_CUSTOMERID,
           SUSN_SERVICIOID,
           SUSD_FECHA_SUSCRIPCION,
           SUSD_FECHA_VIGENCIA,
           SUSD_MODIFI_DATE,
           PI_OPERACION,
           SUSC_ESTADO,
           SUSV_CREATE_USER,
           SUSV_CREATE_DATE
      FROM IOTT_SUSCRIPCION
     WHERE SUSV_LINEA = PI_LINEA
       AND SUSN_SERVICIOID = PI_SERVICIOID;

  PO_CODRPTA := '0';
  PO_MSJRPTA := 'Operacion Exitosa';

EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSI_SUSCRIPCION_HIST;
/****************************************************************
  * Nombre SP          : IOTSU_GEST_TRANSACT
  * Proposito          : SP que actualiza el estado de notificaciÃ³n de la tabla transaccion.
  *
  * Input               :PI_CORRELATOR_ID             - Correlator de la transacciÃ³n
  *                      PI_ESTADO_NOTI               -  Estado de la notificaciÃ³n.
  * Output             : PO_CODRPTA                   - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA                   - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  :
***************************************************************/
  PROCEDURE IOTSU_GEST_TRANSACT(PI_CORRELATOR_ID IN IOTCT_TRANSACCION.TRANV_CORRELATOR_ID%TYPE,
                               PI_ESTADO_NOTI   IN CHAR,
                               PO_CODRPTA       OUT VARCHAR2,
                               PO_MSJRPTA       OUT VARCHAR2) IS
 BEGIN
   UPDATE IOTCT_TRANSACCION X
      SET X.TRANC_ESTADO_NOTI = PI_ESTADO_NOTI
    WHERE X.TRANV_CORRELATOR_ID = PI_CORRELATOR_ID
      AND X.TRANN_TRANSACCION_ID =
          (SELECT TRANN_TRANSACCION_ID
             FROM (SELECT TRANN_TRANSACCION_ID,
                          DENSE_RANK() OVER(PARTITION BY 1 ORDER BY TRANN_TRANSACCION_ID DESC) DNRK
                     FROM IOTCT_TRANSACCION
                    WHERE TRANV_CORRELATOR_ID = PI_CORRELATOR_ID)
            WHERE DNRK = 1);

    PO_CODRPTA := '0';
    PO_MSJRPTA := 'Actualizacion de transaccion exitosa.';

 EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error de actualizacion => ' || sqlerrm;
 END IOTSU_GEST_TRANSACT;

/****************************************************************
  * Nombre SP          : IOTSS_PRODUCTID
  * Proposito          : SP que obtiene el listado de product id de la tabla servicio
  *
  * Input               :PI_PRODUCTID             - Product id de la tabla servicio
  *                      PI_PRODUCTO              -  Nombre del servicio.
  *                      PI_MEDIO_PAGO            -  Linea mÃ³vil o Fija.
  * Output             : PO_CURSOR                - Listado de Product Id.
  *                      @ID_PRODUCTO
  *                      @TIPO_PRODUCTO
  *                      @PRODUCTID_NOM
  *                      @CODIGO_BSCS,
  *                      @TIPO_LINEA,
  *                      @CUSTOMERID
  *                      PO_CODRPTA               - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA               - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  :
***************************************************************/
PROCEDURE IOTSS_PRODUCTID(PI_PRODUCTID     IN IOTCT_SERVICIO.SERVN_SERVICEID%TYPE, --PARA NORTE A SUR
                          PI_PRODUCTO      IN IOTCT_SERVICIO.SERVV_NOMBRE%TYPE, --PARA SUR A NORTE
                          PI_MEDIO_PAGO    IN VARCHAR2,--SIEMPRE
                          PO_CURSOR        OUT C_REF_CURSOR,
                          PO_CODRPTA       OUT VARCHAR2,
                          PO_MSJRPTA       OUT VARCHAR2) IS
V_CONTADOR NUMBER;
BEGIN
  SELECT COUNT(1)
    INTO V_CONTADOR
    FROM IOTCT_SERVICIO S
    JOIN IOTT_SUSCRIPCION X
      ON S.SERVN_SERVICEID = X.SUSN_SERVICIOID
   WHERE X.SUSV_LINEA = PI_MEDIO_PAGO
     AND UPPER(X.SUSC_ESTADO) = C_AMCO_ACTI
     AND (S.SERVV_NOMBRE = PI_PRODUCTO OR S.SERVN_SERVICEID = PI_PRODUCTID);

    IF V_CONTADOR > 0 THEN
      OPEN PO_CURSOR FOR
        SELECT S.SERVN_SERVICEID         AS ID_PRODUCTO,
               S.SERVV_TIPO              AS TIPO_PRODUCTO,
               S.SERVV_NOMBRE            AS PRODUCTID_NOM,
               S.SERVV_SERVICEID_BSCS_M  AS CODIGO_BSCS,
               s.SERVV_SERVICEID_BSCS_F  AS CODIGO_BSCS_F,
               s.SERVV_SERVICEID_BSCS_MO AS CODIGO_BSCS_MO,
               X.SUSV_TIPO_LINEA         AS TIPO_LINEA,
               X.SUSV_CUSTOMERID         AS CUSTOMERID
          FROM IOTCT_SERVICIO S
          JOIN IOTT_SUSCRIPCION X
            ON S.SERVN_SERVICEID = X.SUSN_SERVICIOID
         WHERE X.SUSV_LINEA = PI_MEDIO_PAGO
              AND UPPER(X.SUSC_ESTADO) = C_AMCO_ACTI
              AND (S.SERVV_NOMBRE = PI_PRODUCTO OR S.SERVN_SERVICEID = PI_PRODUCTID);

              PO_CODRPTA := '0';
              PO_MSJRPTA := 'Operacion Exitosa';
     ELSE
        OPEN PO_CURSOR FOR
           SELECT NULL ID_PRODUCTO,
                  NULL TIPO_PRODUCTO,
                  NULL PRODUCTID_NOM,
                  NULL CODIGO_BSCS,
                  NULL CODIGO_BSCS_F,
                  NULL CODIGO_BSCS_MO,
                  NULL TIPO_LINEA,
                  NULL CUSTOMERID
             FROM DUAL
            WHERE ROWNUM = 0;

           PO_CODRPTA     := 1;
           PO_MSJRPTA     := 'No se encontro data de la suscripciÃ³n';
     END IF;
EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_PRODUCTID;

/****************************************************************
  * Nombre SP          : IOTSS_PRODUCTID_PLAN
  * Proposito          : SP que obtiene datos de la tabla servicio por el tmcode,descripciÃ³n del plan
  *                      y el nombre del producto.
  *
  * Input               :  PI_PLAN           - tmcode de bono
  *                        PI_LINEA          - Linea del cliente
  *                        PI_PRODUCTO       - Nombre del producto(Ejm:Claro Video)
  * Output             :   PO_PRODUCTID      - Product id del servicio(Ejm:10030)
  *                        PO_PRODUCTID_NOM  - Nombre del servicio
  *                        PO_PRECIO         - Precio del servicio
  *                        PO_PRODUCTID_TIPO - Tipo de producto Bono o Paga
  *                        PO_CODIGO_BSCS    - Codigo de Bscs
  *                        PO_CODRPTA        - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA        - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 17/10/2019
***************************************************************/
PROCEDURE IOTSS_PRODUCTID_PLAN (PI_PLAN             IN  IOTCT_PLANES.PLNN_TMCOD%TYPE, --
                                PI_LINEA            IN  IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                PI_PRODUCTO         IN  IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                PO_PRODUCTID        OUT IOTCT_SERVICIO.SERVN_SERVICEID%TYPE, --
                                PO_PRODUCTID_NOM    OUT IOTCT_SERVICIO.SERVV_NOMBRE%TYPE, --
                                PO_PRECIO           OUT IOTCT_SERVICIO.SERVD_PRECIO%TYPE,
                                PO_PRODUCTID_TIPO   OUT IOTCT_SERVICIO.SERVV_TIPO%TYPE,--
                                PO_CODIGO_BSCS      OUT IOTCT_SERVICIO.SERVV_SERVICEID_BSCS_M%TYPE, --
                                PO_CODRPTA          OUT VARCHAR2,
                                PO_MSJRPTA          OUT VARCHAR2)IS

V_CONTADOR_CV     NUMBER:=0;
V_CONTADOR_ADDON  NUMBER:=0;
V_CONTADOR_ACTIVO NUMBER:=0;
V_CONT_PLAN       NUMBER:=0;
V_CONT_SERV       NUMBER:=0;
V_TIPO            VARCHAR2(10);
V_ESTADO_ACTIVO   CHAR(1):='A';
V_ESTADO_CANCEL   CHAR(1):='C';
V_TIPO_PLAN       VARCHAR2(10);

V_COD_CV          IOTCT_SERVICIO.SERVV_NOMBRE%TYPE:='CLARO VIDEO';
BEGIN
   SELECT COUNT(1)
    INTO V_CONT_SERV
    FROM IOTCT_SERVICIO S
   WHERE S.SERVV_NOMBRE = PI_PRODUCTO;

    SELECT COUNT(1)
    INTO V_CONT_PLAN
    FROM IOTCT_PLANES P
   WHERE PLNN_TMCOD = PI_PLAN;

   IF V_CONT_SERV > 0 AND V_CONT_PLAN > 0 THEN
      SELECT P.PLNV_TIPO_PLAN
        INTO V_TIPO_PLAN
        FROM IOTCT_PLANES P
       WHERE PLNN_TMCOD = PI_PLAN;

    --Validar si cuenta con el servicio activo.
       SELECT COUNT(1)
          INTO V_CONTADOR_ACTIVO
          FROM IOTT_SUSCRIPCION SU
          JOIN IOTCT_SERVICIO S
            ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
         WHERE S.SERVV_NOMBRE = PI_PRODUCTO
           AND SU.SUSV_LINEA = PI_LINEA
           AND SU.SUSC_ESTADO = V_ESTADO_ACTIVO;

         IF V_CONTADOR_ACTIVO > 0 THEN
            PO_CODRPTA:='2';
            PO_MSJRPTA:='El Cliente ya cuenta con el servicio activo';
            RETURN;
         END IF;
         --Validar si es claro video
         IF PI_PRODUCTO  = V_COD_CV THEN
            SELECT COUNT(1)
              INTO V_CONTADOR_CV
              FROM IOTCT_SERVICIO S
              JOIN IOTT_SUSCRIPCION SU
                ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
             WHERE S.SERVV_NOMBRE = PI_PRODUCTO
               AND SU.SUSV_LINEA = PI_LINEA
               AND SU.SUSC_ESTADO = V_ESTADO_CANCEL;
               --BONO
               IF V_CONTADOR_CV = 0 THEN
                  SELECT COUNT(1)
                    INTO V_CONTADOR_CV
                    FROM IOTCT_PLANES P
                    JOIN IOTCT_SERVICIO S
                      ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
                   WHERE P.PLNN_TMCOD = PI_PLAN
                     AND S.SERVV_NOMBRE = PI_PRODUCTO
                     AND S.SERVV_TIPO = C_AMCO_BONO;

                    IF V_CONTADOR_CV = 0 THEN
                       PO_CODRPTA:='3';
                       PO_MSJRPTA:='Plan de Bono no configurado';
                       RETURN;
                    END IF;
                    SELECT S.SERVN_SERVICEID,
                           S.SERVV_NOMBRE,
                           S.SERVD_PRECIO,
                           S.SERVV_TIPO,
                           C_AMCO_VACIO
                      INTO PO_PRODUCTID,
                           PO_PRODUCTID_NOM,
                           PO_PRECIO,
                           PO_PRODUCTID_TIPO,
                           PO_CODIGO_BSCS
                      FROM IOTCT_PLANES P
                      JOIN IOTCT_SERVICIO S
                        ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
                     WHERE P.PLNN_TMCOD = PI_PLAN
                       AND S.SERVV_NOMBRE = PI_PRODUCTO
                       AND S.SERVV_TIPO = C_AMCO_BONO;

                     PO_CODRPTA:='0';
                     PO_MSJRPTA:='Consulta exitosa';
                --PAGA
               ELSE
                  SELECT COUNT(1)
                    INTO V_CONTADOR_CV
                    FROM IOTCT_SERVICIO S
                   WHERE S.SERVV_NOMBRE = PI_PRODUCTO
                     AND S.SERVV_TIPO = C_AMCO_PAGA;

                     IF V_CONTADOR_CV = 0 THEN
                        PO_CODRPTA:='4';
                        PO_MSJRPTA:='Plan de Paga no configurado';
                        RETURN;
                     END IF;

                     SELECT S.SERVN_SERVICEID,
                          S.SERVV_NOMBRE,
                          S.SERVD_PRECIO,
                          S.SERVV_TIPO,
                          (CASE V_TIPO_PLAN
                             WHEN C_AMCO_MOVIL THEN S.SERVV_SERVICEID_BSCS_M
                             WHEN C_AMCO_FIJA  THEN S.SERVV_SERVICEID_BSCS_F END)
                      INTO PO_PRODUCTID,
                           PO_PRODUCTID_NOM,
                           PO_PRECIO,
                           PO_PRODUCTID_TIPO,
                           PO_CODIGO_BSCS
                     FROM IOTCT_SERVICIO S
                     WHERE S.SERVV_NOMBRE = PI_PRODUCTO
                       AND S.SERVV_TIPO = C_AMCO_PAGA;
                       PO_CODRPTA:='0';
                       PO_MSJRPTA:='Consulta exitosa';
               END IF;
         ELSE
          --ADDONS
          --Validar que exista el servicio
           SELECT COUNT(1)
             INTO V_CONTADOR_ADDON
             FROM IOTCT_SERVICIO S
             JOIN IOTT_SUSCRIPCION SU
               ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
            WHERE S.SERVV_NOMBRE = PI_PRODUCTO
              AND SU.SUSV_LINEA = PI_LINEA;

              V_TIPO := CASE V_CONTADOR_ADDON WHEN 0 THEN C_AMCO_BONO ELSE C_AMCO_PAGA END;

              SELECT S.SERVN_SERVICEID,
                     S.SERVV_NOMBRE,
                     S.SERVD_PRECIO,
                     S.SERVV_TIPO,
                     (CASE V_TIPO
                       WHEN C_AMCO_PAGA THEN
                           DECODE(TRIM(V_TIPO_PLAN),
                                     C_AMCO_MOVIL,
                                     S.SERVV_SERVICEID_BSCS_M,
                                     S.SERVV_SERVICEID_BSCS_F)
                       ELSE
                        C_AMCO_VACIO
                     END)
                INTO PO_PRODUCTID,
                     PO_PRODUCTID_NOM,
                     PO_PRECIO,
                     PO_PRODUCTID_TIPO,
                     PO_CODIGO_BSCS
                FROM IOTCT_SERVICIO S
               WHERE S.SERVV_NOMBRE = PI_PRODUCTO
                 AND S.SERVV_TIPO = V_TIPO;

                PO_CODRPTA:='0';
                PO_MSJRPTA:='Consulta exitosa';
         END IF;
   ELSE
     PO_CODRPTA:='1';
     PO_MSJRPTA:='Plan/Servicio no configurado';
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
END IOTSS_PRODUCTID_PLAN;

/****************************************************************
  * Nombre SP          : IOTSS_VIGENCIA_PROMOCIONAL
  * Proposito          : SP que obtiene las suscripciones activas del dia anterior.
  * Output             :   PO_CURSOR - Listado de Lineas activas del dia anterior
  *                        @LINEA,
  *                        @PRODUCTID,
  *                        @PRODUCTID_NOM,
  *                        @PRODUCTID_PAGA
  *                        @FECHA_VIGENCIA
  *                        @CONTADOR_COBRO
  *                        @METODO_PAGO
  *                        PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 26/10/2019 - Se agrego el parametro customer al S
  *                      10/05/2020 - Cambio en los filtros.
  *                      12/08/2020 - Se agrego campos al cursor
***************************************************************/
  PROCEDURE IOTSS_VIGENCIA_PROMOCIONAL (PO_CURSOR     OUT C_REF_CURSOR,
                                      PO_CODRPTA    OUT VARCHAR2,
                                      PO_MSJRPTA    OUT VARCHAR2)IS
 V_CONT NUMBER;
 BEGIN
   SELECT COUNT(1)
     INTO V_CONT
     FROM IOTT_SUSCRIPCION S
     JOIN IOTCT_SERVICIO X
       ON S.SUSN_SERVICIOID = X.SERVN_SERVICEID
    WHERE UPPER(S.SUSC_ESTADO) = C_AMCO_ACTI
      AND TRUNC(S.SUSD_FECHA_VIGENCIA) <= TRUNC(SYSDATE - 1)
      AND X.SERVV_TIPO = C_AMCO_BONO;

   IF V_CONT > 0 THEN
     OPEN PO_CURSOR FOR
          SELECT S.SUSV_LINEA LINEA,
                 S.SUSN_SERVICIOID PRODUCTID,
                 X.SERVV_NOMBRE PRODUCTID_NOM,
                 (SELECT IOTS.SERVN_SERVICEID
                    FROM IOTCT_SERVICIO IOTS
                   WHERE IOTS.SERVV_NOMBRE = X.SERVV_NOMBRE
                     AND IOTS.SERVV_TIPO = C_AMCO_PAGA) PRODUCTID_PAGA,
                 S.SUSD_FECHA_VIGENCIA FECHA_VIGENCIA,
                 S.SUSN_USUARIOID CUSTOMERID,
                 S.SUSN_CONTADOR_COBRO CONTADOR_COBRO,
                 S.SUSV_METODOPAGO METODO_PAGO
            FROM IOTT_SUSCRIPCION S
            JOIN IOTCT_SERVICIO X
              ON S.SUSN_SERVICIOID = X.SERVN_SERVICEID
           WHERE UPPER(S.SUSC_ESTADO) = C_AMCO_ACTI
             AND TRUNC(S.SUSD_FECHA_VIGENCIA) <= TRUNC(SYSDATE - 1)
             AND X.SERVV_TIPO = C_AMCO_BONO;

             PO_CODRPTA:='0';
             PO_MSJRPTA:='Operacion exitosa';
   ELSE
      OPEN PO_CURSOR FOR
         SELECT NULL LINEA,
                NULL PRODUCTID,
                NULL PRODUCTID_NOM,
                NULL PRODUCTID_PAGA,
                NULL FECHA_VIGENCIA,
                NULL CUSTOMERID,
                NULL CONTADOR_COBRO,
                NULL METODO_PAGO
           FROM DUAL
          WHERE ROWNUM = 0;
          PO_CODRPTA:='1';
          PO_MSJRPTA:='No se encontraron suscripciones con vigencia vencida.';
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_VIGENCIA_PROMOCIONAL;

/****************************************************************
  * Nombre SP          : IOTSS_VIGENCIA
  * Proposito          : SP que obtiene el listado de suscripciones con fecha de vigencia
  *                      del dia anterior con estado activo y que el contador de cobro sea menor
  *                      o igual a 10.
  *
  * Output             :   PO_CURSOR - Listado de Lineas activas del dia anterior.
  *                        @LINEA,
  *                        @PRODUCTID,
  *                        @PRODUCTID_NOM,
  *                        @CUSTOMERID,
  *                        @CODIGO_BSCS,
  *                        @PRECIO,
  *                        @FECHA_VIGENCIA,
  *                        @REINTENTO_COBRO
  *                        PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  *        @CODIGO_BSCS_IX
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 10/10/2019
  * Fec Actualizacion  : 12/11/2019 - Se modifico el SP Para que devuelva el campo PO_TIPO_LINEA
  *                      25/03/2020 - Agregar un parametro de salida USUARIOID
  *                      10/05/2020 - Modificacion de filtro paga
  *                      29/05/2020 - Moficar el precio sin IGV
***************************************************************/
PROCEDURE IOTSS_VIGENCIA  (PO_CURSOR   OUT C_REF_CURSOR,
                           PO_CODRPTA  OUT VARCHAR2,
                           PO_MSJRPTA  OUT VARCHAR2)IS

V_CONT                     NUMBER:=0;
V_COD_MOVIL                CHAR(1):='1';
V_COD_FIJA                 CHAR(1):='2';
V_MAX_COBRO                IOTT_SUSCRIPCION.SUSN_CONTADOR_COBRO%TYPE :=10;
V_TEXTO_POSTPAGO           IOTT_SUSCRIPCION.SUSV_TIPO_LINEA%TYPE := 'POSTPAGO';
V_TEXTO_FIJA               IOTT_SUSCRIPCION.SUSV_TIPO_LINEA%TYPE := 'FIJA';
V_IGV                      NUMBER:=1.18;
BEGIN

  SELECT COUNT(1)
    INTO V_CONT
    FROM IOTT_SUSCRIPCION S
    JOIN IOTCT_SERVICIO X
      ON S.SUSN_SERVICIOID = X.SERVN_SERVICEID
   WHERE UPPER(S.SUSC_ESTADO) = C_AMCO_ACTI
     AND TRUNC(S.SUSD_FECHA_VIGENCIA) <= TRUNC(SYSDATE - 1)
     AND S.SUSN_CONTADOR_COBRO <= V_MAX_COBRO
     AND UPPER(S.SUSV_TIPO_LINEA) IN (V_TEXTO_POSTPAGO,V_TEXTO_FIJA)
     AND X.SERVV_TIPO = C_AMCO_PAGA;

    IF V_CONT > 0 THEN
      OPEN PO_CURSOR FOR
         SELECT S.SUSV_LINEA LINEA,
                S.SUSN_SERVICIOID PRODUCTID,
                X.SERVV_NOMBRE PRODUCTID_NOM,
                S.SUSV_TIPO_LINEA TIPO_LINEA, --NUEVO CAMBIO
                S.SUSV_CUSTOMERID CUSTOMERID,
                (SELECT DECODE(S.SUSV_METODOPAGO,
                               V_COD_MOVIL,IOTS.SERVV_SERVICEID_BSCS_M,
                               V_COD_FIJA,IOTS.SERVV_SERVICEID_BSCS_F,
                               IOTS.SERVV_SERVICEID_BSCS_MO)
                   FROM IOTCT_SERVICIO IOTS
                  WHERE IOTS.SERVV_NOMBRE = X.SERVV_NOMBRE
                    AND IOTS.SERVV_TIPO = C_AMCO_PAGA) CODIGO_BSCS,
                ROUND(X.SERVD_PRECIO/V_IGV,2) PRECIO,
                S.SUSD_FECHA_VIGENCIA FECHA_VIGENCIA,
                S.SUSN_CONTADOR_COBRO REINTENTO_COBRO,
                S.SUSN_USUARIOID USUARIOID,
          (SELECT DECODE(S.SUSV_METODOPAGO,
                               V_COD_MOVIL,
                               IOTS.SERVV_SERVICEID_BSCS_MO,
          V_COD_FIJA,
                               IOTS.SERVV_SERVICEID_BSCS_FO
        )
                   FROM IOTCT_SERVICIO IOTS
                  WHERE IOTS.SERVV_NOMBRE = X.SERVV_NOMBRE
                    AND IOTS.SERVV_TIPO = C_AMCO_PAGA) CODIGO_BSCS_IX
           FROM IOTT_SUSCRIPCION S
           JOIN IOTCT_SERVICIO X
             ON S.SUSN_SERVICIOID = X.SERVN_SERVICEID
          WHERE UPPER(S.SUSC_ESTADO) = C_AMCO_ACTI
            AND TRUNC(S.SUSD_FECHA_VIGENCIA) <= TRUNC(SYSDATE - 1)
            AND S.SUSN_CONTADOR_COBRO <= V_MAX_COBRO
            AND UPPER(S.SUSV_TIPO_LINEA) IN (V_TEXTO_POSTPAGO,V_TEXTO_FIJA)
            AND X.SERVV_TIPO = C_AMCO_PAGA;

         PO_CODRPTA:='0';
         PO_MSJRPTA:='Operacion exitosa';

    ELSE
       OPEN PO_CURSOR FOR
        SELECT
               NULL LINEA,
               NULL PRODUCTID,
               NULL PRODUCTID_NOM,
               NULL TIPO_LINEA,
               NULL CUSTOMERID,
               NULL CODIGO_BSCS,
               NULL PRECIO,
               NULL FECHA_VIGENCIA,
               NULL REINTENTO_COBRO,
         NULL USUARIOID,
               NULL CODIGO_BSCS_IX
           FROM DUAL WHERE ROWNUM=0;
           PO_CODRPTA:='1';
           PO_MSJRPTA:='No se encontraron registros vigentes';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_VIGENCIA;

 /****************************************************************
    * Nombre SP          : IOTSU_ACTUALIZA_SUSCRIPCION
    * Proposito          : SP que actualiza el contador y la fecha de vigencia de la tabla suscripciÃ³n.

    * Input               :   LINEA                    - Linea del clienbte
    *                         PRODUCTID                - Product id del servicio.
    *                         TIPO                     - Flag que indica la accion a realizar
    *                                                    (C:Actualizar contador,V:Actualizar Vigencia)
    * Output             :
    *                        PO_CODRPTA               - Indica si el procedure termino exitosamente o no.
    *                        PO_MSJRPTA               - Indica la descripcion del codigo de respuesta.
    *
    * Creado por         : jaraco
    * Actualizado por    :
    * Fec Creacion       : 10/10/2019
    * Fec Actualizacion  : 07/05/2020 - ActualizaciÃ³n de lÃ³gica de negocio
  ***************************************************************/
  PROCEDURE IOTSU_ACTUALIZA_SUSCRIPCION(LINEA            IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                        PRODUCTID        IN IOTT_SUSCRIPCION.SUSN_SERVICIOID%TYPE,
                                        TIPO             IN CHAR,
                                        PO_CODRPTA       OUT VARCHAR2,
                                        PO_MSJRPTA       OUT VARCHAR2) IS

    V_INCREMENTO                        NUMBER := 1;
  V_CERO                NUMBER := 0;
    V_CONTADOR                          NUMBER := 0;
    V_FECHA_VIGENCIA                    IOTT_SUSCRIPCION.SUSD_FECHA_VIGENCIA%TYPE;
    V_ESTADO                            IOTT_SUSCRIPCION.SUSC_ESTADO%TYPE :='A';
  BEGIN

    SELECT COUNT(1)
      INTO V_CONTADOR
      FROM IOTT_SUSCRIPCION
     WHERE SUSV_LINEA = LINEA
       AND SUSN_SERVICIOID = PRODUCTID
       AND SUSC_ESTADO = V_ESTADO;

    IF V_CONTADOR = 0 THEN
      PO_CODRPTA := '1';
      PO_MSJRPTA := 'Linea/servicio no existe';
      RETURN;
    END IF;

    CASE TIPO
      WHEN 'C' THEN
        UPDATE IOTT_SUSCRIPCION
           SET SUSN_CONTADOR_COBRO = (SUSN_CONTADOR_COBRO + V_INCREMENTO)
         WHERE SUSV_LINEA = LINEA
           AND SUSN_SERVICIOID = PRODUCTID
           AND SUSC_ESTADO = V_ESTADO;

        PO_CODRPTA := '0';
        PO_MSJRPTA := 'Se actualizo el contador de cobro.';

      WHEN 'V' THEN
        SELECT SUSD_FECHA_VIGENCIA
          INTO V_FECHA_VIGENCIA
          FROM IOTT_SUSCRIPCION
         WHERE SUSV_LINEA = LINEA
           AND SUSN_SERVICIOID = PRODUCTID
           AND SUSC_ESTADO = V_ESTADO;

       UPDATE IOTT_SUSCRIPCION S
           SET S.SUSD_FECHA_VIGENCIA = ADD_MONTHS(V_FECHA_VIGENCIA, 1),
         SUSN_CONTADOR_COBRO = V_CERO,
               S.SUSV_MODIFI_USER    = USER,
               S.SUSD_MODIFI_DATE    = SYSDATE
         WHERE S.SUSV_LINEA = LINEA
           AND SUSN_SERVICIOID = PRODUCTID
           AND SUSC_ESTADO = V_ESTADO;

           PO_CODRPTA := '0';
           PO_MSJRPTA := 'Se actualizo la fecha de vigencia';
      ELSE
           PO_CODRPTA := '1';
           PO_MSJRPTA := 'Tipo de consulta invalida';
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;
  END IOTSU_ACTUALIZA_SUSCRIPCION;
/****************************************************************
  * Nombre SP          : IOTSI_CONTROL_SUSCRIPCIONES
  * Proposito          : SP que permite el registro de transacciones en la tabla de IOTCT_MESA_CONTROL_CV.
  * Input              :  PI_TRANSACCION_ID
  *                       PI_PRODUCTO
  *                       PI_FLAG_TRANSACCION
  *                       PI_DOCUMENTO_VENTA
  *                       PI_NOMBRE_APLICACION
  *                       PI_TIPO_OPERACION
  *                       PI_OPERACION
  *                       PI_NOMBRE_SERVICIO
  *                       PI_NOMBRE_PDV
  *                       PI_CUSTOMERID
  *                       PI_LINEA
  *                       PI_ESTADO_EJECUCION
  *                       PI_FECHA_EJECUCION
  *                       PI_FECHA_TRANSACCIÃ“N
  *                       PI_ESTADO_TRANSACCION
  *                       PI_MENSAJE_TRANSACCION
  *  Output               PO_CODRPTA - Codigo de respuesta.
  *                       PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 21/10/2019
  * Fec Actualizacion  :
***************************************************************/

  PROCEDURE IOTSI_CONTROL_SUSCRIPCIONES(PI_TRANSACCION_ID        IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSN_ID_TRANSACCION%TYPE,
                                        PI_FLAG_TRANSACCION      IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSC_FLAG_TRANSACCION%TYPE,
                                        PI_TIPO_TRANSACCION      IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_TIPO_TRANSACCION%TYPE,
                                        PI_DOCUMENTO_VENTA       IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSN_DOCUMENTO_VENTA%TYPE,
                                        PI_NOMBRE_APLICACION     IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_NOMBRE_APLICACION%TYPE,
                                        PI_OPERACION_SUSCRIPCION IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_OPERACION_SUSCRIPCION%TYPE,
                                        PI_NOMBRE_SERVICIO       IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_NOMBRE_SERVICIO%TYPE,
                                        PI_NOMBRE_PDV            IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_NOMBRE_PDV%TYPE,
                                        PI_CUSTOMERID            IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSN_CUSTOMERID%TYPE,
                                        PI_LINEA                 IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_TELEFONO%TYPE,
                                        PI_ESTADO_TRANSACCION    IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_ESTADO_TRANSACCION%TYPE,
                                        PI_MENSAJE_TRANSACCION   IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSV_MENSAJE_TRANSACCION%TYPE,
                                        PO_CODRPTA               OUT VARCHAR2,
                                        PO_MSJRPTA               OUT VARCHAR2)
IS
 SQUTX_VALUE_CURRENT_MC NUMBER := IOTSEQ_AMCO_MC.NEXTVAL;
 BEGIN

     INSERT INTO IOTCT_CONTROL_SUSCRIPCIONES
        (CSUSN_ID_CONTROLSUS,
         CSUSN_ID_TRANSACCION,
         CSUSC_FLAG_TRANSACCION,
         CSUSV_TIPO_TRANSACCION,
         CSUSN_DOCUMENTO_VENTA,
         CSUSV_NOMBRE_APLICACION,
         CSUSV_OPERACION_SUSCRIPCION,
         CSUSV_NOMBRE_SERVICIO,
         CSUSV_NOMBRE_PDV,
         CSUSN_CUSTOMERID,
         CSUSV_TELEFONO,
         CSUSD_FECHA_TRANSACCION,
         CSUSV_ESTADO_TRANSACCION,
         CSUSV_MENSAJE_TRANSACCION
         )
         VALUES
        (SQUTX_VALUE_CURRENT_MC,
         PI_TRANSACCION_ID,
         PI_FLAG_TRANSACCION,
         PI_TIPO_TRANSACCION,
         PI_DOCUMENTO_VENTA,
         PI_NOMBRE_APLICACION,
         PI_OPERACION_SUSCRIPCION,
         PI_NOMBRE_SERVICIO,
         PI_NOMBRE_PDV,
         PI_CUSTOMERID,
         PI_LINEA,
         SYSDATE,
         PI_ESTADO_TRANSACCION,
         PI_MENSAJE_TRANSACCION);

        PO_CODRPTA:='0';
        PO_MSJRPTA:='Operacion exitosa';

EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error de insercion => ' || sqlerrm;
 END IOTSI_CONTROL_SUSCRIPCIONES;
/****************************************************************
  * Nombre SP          : IOTSS_CONSULTAR_SERVICIOS
  * Proposito          : SP que permiste lista las suscripciones activas y canceladas de
                         la tabla historial IOTT_SUSCRIPCION_HIST.
  * Input              :  PI_LINEA
  *                       PI_NOMBRE

  *  Output              :PO_CURSOR               - Lista de Servicios
                          PO_CODRPTA               - Codigo de respuesta.
  *                       PO_MSJRPTA               - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 04/11/2019
  * Fec Actualizacion  :
***************************************************************/

PROCEDURE IOTSS_CONSULTAR_SERVICIOS(PI_LINEA      IN VARCHAR2,
                                    PI_NOMBRE     IN VARCHAR2,
                                    PO_CURSOR     OUT C_REF_CURSOR,
                                    PO_CODRPTA    OUT VARCHAR2,
                                    PO_MSJRPTA    OUT VARCHAR2)IS

  V_CONT              NUMBER:=0;
  V_COD_MOVIL         CHAR(1):='1';
  V_TEXTO_MOVIL       VARCHAR(10):='MOVIL';
  V_TEXTO_FIJA        VARCHAR(10):='FIJA';
  V_TEXTO_ACTIVA      VARCHAR(20):='ACTIVACION';
  V_TEXTO_CANCEL      VARCHAR(20):='CANCELACION';

  V_TIPO_ACT   IOTT_SUSCRIPCION_HIST.SUSHV_TIPO_OPERACION%TYPE  := '1';
  V_TIPO_CAN   IOTT_SUSCRIPCION_HIST.SUSHV_TIPO_OPERACION%TYPE  := '5';
BEGIN

  SELECT COUNT(1)
      INTO V_CONT
      FROM IOTT_SUSCRIPCION_HIST H
      JOIN IOTCT_SERVICIO SRV
        ON H.SUSHN_SERVICIOID = SRV.SERVN_SERVICEID
     WHERE H.SUSHV_LINEA = PI_LINEA
           AND H.SUSHN_SERVICIOID IN
                (SELECT S.SERVN_SERVICEID
                   FROM IOTCT_SERVICIO S
                  WHERE S.SERVV_NOMBRE = PI_NOMBRE)
            AND H.SUSHV_TIPO_OPERACION IN (V_TIPO_ACT,V_TIPO_CAN)
            ORDER BY SUSHV_ESTADO_SUS ASC;

     IF  V_CONT > 0 THEN
       OPEN PO_CURSOR FOR
         SELECT SRV.SERVN_SERVICEID AS SERVICIOID,
                SRV.SERVV_NOMBRE AS NOMBRE_SERVICIO,
                SRV.SERVD_PRECIO AS PRECIO,
                TRUNC(H.SUSHD_FECHA_SUSCRIPCION) AS FECHA_ACTIVACION,
                TRUNC(H.SUSHD_FECHA_VIGENCIA)  AS FECHA_EXPIRACION,
                TRUNC(H.SUSHD_FECHA_OPERACION) AS FECHA_CANCELACION,
                H.SUSHV_TIPO_LINEA AS TIPO_LINEA,
                DECODE(H.SUSHV_METODO_PAGO, V_COD_MOVIL,V_TEXTO_MOVIL, V_TEXTO_FIJA) AS SERVICIO,
                H.SUSHV_ESTADO_SUS AS ESTADO,
               (CASE WHEN H.SUSHV_TIPO_OPERACION = '1' THEN V_TEXTO_ACTIVA ELSE V_TEXTO_CANCEL END) AS OPERACION
           FROM IOTT_SUSCRIPCION_HIST H
           JOIN IOTCT_SERVICIO SRV
             ON H.SUSHN_SERVICIOID = SRV.SERVN_SERVICEID
          WHERE H.SUSHV_LINEA = PI_LINEA
            AND H.SUSHN_SERVICIOID IN
                (SELECT S.SERVN_SERVICEID
                   FROM IOTCT_SERVICIO S
                  WHERE S.SERVV_NOMBRE = PI_NOMBRE)
            AND H.SUSHV_TIPO_OPERACION IN (V_TIPO_ACT,V_TIPO_CAN)
            ORDER BY SUSHV_ESTADO_SUS ASC;

           PO_CODRPTA :='0';
           PO_MSJRPTA := 'Operacion exitosa';
     ELSE
       OPEN PO_CURSOR FOR
          SELECT NULL AS SERVICIOID,
                 NULL AS NOMBRE_SERVICIO,
                 NULL AS PRECIO,
                 NULL AS FECHA_ACTIVACION,
                 NULL AS FECHA_EXPIRACION,
                 NULL AS FECHA_CANCELACION,
                 NULL AS TIPO_LINEA,
                 NULL AS SERVICIO,
                 NULL AS ESTADO,
                 NULL AS OPERACION
            FROM DUAL
           WHERE ROWNUM = 0;

           PO_CODRPTA := '1';
           PO_MSJRPTA := 'No se encontraron registros';
 END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error al consultar servicios => ' || sqlerrm;

END IOTSS_CONSULTAR_SERVICIOS;
/****************************************************************
  * Nombre SP          : IOTSS_CONSULTAR_DISPOSITIVOS
  * Proposito          : SP que permiste listar el historial de dispositivos
                         a partir de un rango de fechas.
  * Input              :  PI_LINEA
  *                       PI_FECHA_DESDE
  *                       PI_FECHA_HASTA
  *  Output              :PO_CURSOR                - Lista de Dispositivos del cliente.
                          PO_CODRPTA               - Codigo de respuesta.
  *                       PO_MSJRPTA               - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 04/11/2019
  * Fec Actualizacion  :
***************************************************************/

PROCEDURE IOTSS_CONSULTAR_DISPOSITIVOS(PI_LINEA       IN IOTCT_DISPOSITIVO_CLIENTE.DISCLN_LINEA%TYPE,
                                       PI_FECHA_DESDE IN DATE,
                                       PI_FECHA_HASTA IN DATE,
                                       PO_CURSOR      OUT C_REF_CURSOR,
                                       PO_CODRPTA     OUT VARCHAR2,
                                       PO_MSJRPTA     OUT VARCHAR2)IS
V_CONT NUMBER;
V_ESTADO_INACTIVO CHAR(1):='D';
 BEGIN
    SELECT COUNT(1) INTO V_CONT
           FROM IOTCT_DISPOSITIVO_CLIENTE SD
          WHERE SD.DISCLN_LINEA = PI_LINEA
           AND SD.DISCLC_ESTADO = V_ESTADO_INACTIVO
           AND TRUNC(SD.DISCLD_FECHA_ACT) BETWEEN TRUNC(PI_FECHA_DESDE) AND TRUNC(PI_FECHA_HASTA)
          ORDER BY SD.DISCLD_FECHA_ACT;

  IF  V_CONT > 0 THEN
    OPEN PO_CURSOR FOR
        SELECT SD.DISCLN_LINEA               AS LINEA,
               SD.DISCLV_DEVICEID            AS ID_DISPOSITIVO,
               SD.DISCLV_NOMDISP             AS NOMBRE,
               SD.DISCLV_TIPODISP            AS TIPO_DISPOSITIVO,
               TRUNC(SD.DISCLD_FECHA_ACT)    AS FECHA_ACTIVACION,
               TRUNC(SD.DISCLD_FECHA_DESV)   AS FECHA_EXPIRACION
          FROM IOTCT_DISPOSITIVO_CLIENTE SD
         WHERE SD.DISCLN_LINEA = PI_LINEA
           AND SD.DISCLC_ESTADO = V_ESTADO_INACTIVO
           AND TRUNC(SD.DISCLD_FECHA_ACT) BETWEEN TRUNC(PI_FECHA_DESDE) AND TRUNC(PI_FECHA_HASTA)
         ORDER BY SD.DISCLD_FECHA_ACT;

         PO_CODRPTA :='0';
         PO_MSJRPTA := 'Operacion exitosa';
  ELSE
      OPEN PO_CURSOR FOR
        SELECT NULL AS LINEA,
               NULL AS ID_DISPOSITIVO,
               NULL AS NOMBRE,
               NULL AS TIPO_DISPOSITIVO,
               NULL AS FECHA_ACTIVACION,
               NULL AS FECHA_EXPIRACION
          FROM DUAL
         WHERE ROWNUM = 0;

         PO_CODRPTA := '1';
         PO_MSJRPTA := 'No existen dispositivos entre ese rango de fechas';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error al consultar dispositivos => ' || sqlerrm;

END IOTSS_CONSULTAR_DISPOSITIVOS;
/****************************************************************
  * Nombre SP          : IOTSS_PRODUCTID_PREPAGO
  * Proposito          : SP que obtiene el productId , tipo de producto , precio de producto
                         de la tabla sevicios para prepago.
  *
  * Input               :  PI_LINEA          - Linea del cliente
  *                        PI_PRODUCTO       - Nombre del producto
  * Output             :   PO_PRODUCTID      - Product id del servicio(Ejm:10030)
  *                        PO_PRECIO         - Precio del servicio
  *                        PO_PRODUCTID_TIPO - Tipo de producto Bono o Paga
  *                        PO_PRODUCTID_BSCS - Product id de BSCS
  *                        PO_CODRPTA        - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA        - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 30/10/2019
  * Fec Actualizacion  : 27/02/2020 - Se cambio codigo de productid de prepago.
***************************************************************/

 PROCEDURE IOTSS_PRODUCTID_PREPAGO(PI_LINEA          IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                    PI_PRODUCTO       IN IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                    PO_PRODUCTID      OUT IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                    PO_PRECIO         OUT IOTCT_SERVICIO.SERVD_PRECIO%TYPE,
                                    PO_PRODUCTID_TIPO OUT IOTCT_SERVICIO.SERVV_TIPO%TYPE,
                                    PO_PRODUCTID_NOM  OUT IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                    PO_PRODUCTID_BSCS OUT IOTCT_SERVICIO.SERVV_SERVICEID_BSCS_M%TYPE,
                                    PO_CODRPTA        OUT VARCHAR2,
                                    PO_MSJRPTA        OUT VARCHAR2) IS

    V_CONTADOR      NUMBER := 0;
    V_COUNT_ACTIVOS NUMBER := 0;
    V_COD_CV        IOTCT_SERVICIO.SERVV_NOMBRE%TYPE := 'CLARO VIDEO';
    V_ESTADO_ACTIVO CHAR(1) := 'A';
    V_CONT_PRE      NUMBER := 0;
  BEGIN
    SELECT COUNT(1)
      INTO V_CONTADOR
      FROM IOTCT_SERVICIO S
     WHERE S.SERVV_NOMBRE = PI_PRODUCTO;

    IF V_CONTADOR > 0 THEN
      SELECT COUNT(1)
        INTO V_COUNT_ACTIVOS
        FROM IOTT_SUSCRIPCION SU
        JOIN IOTCT_SERVICIO S
          ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
       WHERE S.SERVV_NOMBRE = PI_PRODUCTO
         AND SU.SUSV_LINEA = PI_LINEA
         AND UPPER(SU.SUSC_ESTADO) = V_ESTADO_ACTIVO;

      IF V_COUNT_ACTIVOS > 0 THEN
        PO_CODRPTA := '2';
        PO_MSJRPTA := 'El Cliente ya cuenta con el servicio activo';
        RETURN;
      END IF;

      SELECT COUNT(1)
        INTO V_CONTADOR
        FROM IOTCT_SERVICIO S
        JOIN IOTT_SUSCRIPCION SU
          ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
       WHERE S.SERVV_NOMBRE = PI_PRODUCTO
         AND SU.SUSV_LINEA = PI_LINEA;

      IF V_CONTADOR = 0 THEN
        IF PI_PRODUCTO = V_COD_CV THEN
         SELECT COUNT(1)
           INTO V_CONT_PRE
           FROM IOTCT_SERVICIO S
          WHERE S.SERVV_NOMBRE = PI_PRODUCTO
            AND S.SERVV_TIPO = C_AMCO_BONO
            AND S.SERVN_SERVICEID = 10000030;

           IF V_CONT_PRE = 0 THEN
            PO_CODRPTA := '3';
            PO_MSJRPTA := 'No se pudo obtener producto prepago';
            RETURN;
           END IF;

          SELECT S.SERVN_SERVICEID,
                 S.SERVV_NOMBRE,
                 S.SERVD_PRECIO,
                 S.SERVV_TIPO,
                 C_AMCO_VACIO
            INTO PO_PRODUCTID,
                 PO_PRODUCTID_NOM,
                 PO_PRECIO,
                 PO_PRODUCTID_TIPO,
                 PO_PRODUCTID_BSCS
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = PI_PRODUCTO
             AND S.SERVV_TIPO = C_AMCO_BONO
             AND S.SERVN_SERVICEID = 10000030;

            PO_CODRPTA := '0';
            PO_MSJRPTA := 'Consulta exitosa';

        ELSE
          SELECT COUNT(1)
            INTO V_CONT_PRE
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = PI_PRODUCTO
             AND S.SERVV_TIPO = C_AMCO_BONO;

            IF V_CONT_PRE = 0 THEN
              PO_CODRPTA := '3';
              PO_MSJRPTA := 'No se pudo obtener el producto addon';
            RETURN;
           END IF;

          SELECT S.SERVN_SERVICEID,
                 S.SERVV_NOMBRE,
                 S.SERVD_PRECIO,
                 S.SERVV_TIPO,
                 C_AMCO_VACIO
            INTO PO_PRODUCTID,
                 PO_PRODUCTID_NOM,
                 PO_PRECIO,
                 PO_PRODUCTID_TIPO,
                 PO_PRODUCTID_BSCS
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = PI_PRODUCTO
             AND S.SERVV_TIPO = C_AMCO_BONO;
            PO_CODRPTA := '0';
            PO_MSJRPTA := 'Consulta exitosa';

        END IF;
      ELSE
        SELECT S.SERVN_SERVICEID,
               S.SERVV_NOMBRE,
               S.SERVD_PRECIO,
               S.SERVV_TIPO,
               C_AMCO_VACIO
          INTO PO_PRODUCTID,
               PO_PRODUCTID_NOM,
               PO_PRECIO,
               PO_PRODUCTID_TIPO,
               PO_PRODUCTID_BSCS
          FROM IOTCT_SERVICIO S
         WHERE S.SERVV_NOMBRE = PI_PRODUCTO
           AND S.SERVV_TIPO = C_AMCO_PAGA;

        PO_CODRPTA := '0';
        PO_MSJRPTA := 'Consulta exitosa';
      END IF;
    ELSE
      PO_CODRPTA := '1';
      PO_MSJRPTA := 'Producto no configurado';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error al consultar los productos => ' || sqlerrm;

  END IOTSS_PRODUCTID_PREPAGO;
/****************************************************************
  * Nombre SP          : IOTSS_CONTROL_SUSCRIPCIONES
  * Proposito          : SP que consulta las transacciones de la tabla IOTCT_CONTROL_SUSCRIPCIONES.
  *
  * Input               :  PI_FECHA_TRANSACCION          - Fecha de transaccion
  * Output              :  PO_CURSOR
  *                        @ID_TRANSACCION,
  *                        @FLAG_TRANSACCION,
  *                        @TIPO_TRANSACCION ,
  *                        @DOCUMENTO_VENTA,
  *                        @NOMBRE_APLICACION,
  *                        @OPERACION_SUSCRIPCION
  *                        @NOMBRE_SERVICIO,
  *                        @NOMBRE_PDV,
  *                        @CUSTOMERID,
  *                        @TELEFONO,
  *                        @FECHA_TRANSACCION
  *                        @ESTADO_TRANSACCION,
  *                        @MENSAJE_TRANSACCION
  *                        PO_CODRPTA        - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA        - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 09/12/2019
  * Fec Actualizacion  :
***************************************************************/
PROCEDURE IOTSS_CONTROL_SUSCRIPCIONES (PI_FECHA_TRANSACCION   IN IOTCT_CONTROL_SUSCRIPCIONES.CSUSD_FECHA_TRANSACCION%TYPE,
                                       PO_CURSOR              OUT C_REF_CURSOR,
                                       PO_CODRPTA             OUT VARCHAR2,
                                       PO_MSJRPTA             OUT VARCHAR2)IS

V_CONTADOR NUMBER;
BEGIN

    SELECT COUNT(1)
      INTO V_CONTADOR
      FROM IOTCT_CONTROL_SUSCRIPCIONES CR
      WHERE TO_DATE(TO_CHAR(CR.CSUSD_FECHA_TRANSACCION, 'DD/MM/YYYY'),
       'DD/MM/YYYY') = TO_DATE(TO_CHAR(PI_FECHA_TRANSACCION,'DD/MM/YYYY'), 'DD/MM/YYYY');

   IF V_CONTADOR > 0 THEN
     OPEN PO_CURSOR FOR
       SELECT CR.CSUSN_ID_CONTROLSUS         AS ID_CONTROLSUS,
              CR.CSUSN_ID_TRANSACCION        AS ID_TRANSACCION,
              CR.CSUSC_FLAG_TRANSACCION      AS FLAG_TRANSACCION,
              CR.CSUSV_TIPO_TRANSACCION      AS TIPO_TRANSACCION,
              CR.CSUSN_DOCUMENTO_VENTA       AS DOCUMENTO_VENTA,
              CR.CSUSV_NOMBRE_APLICACION     AS NOMBRE_APLICACION,
              CR.CSUSV_OPERACION_SUSCRIPCION AS OPERACION_SUSCRIPCION,
              CR.CSUSV_NOMBRE_SERVICIO       AS NOMBRE_SERVICIO,
              CR.CSUSV_NOMBRE_PDV            AS NOMBRE_PDV,
              CR.CSUSN_CUSTOMERID            AS CUSTOMERID,
              CR.CSUSV_TELEFONO              AS TELEFONO,
              CR.CSUSD_FECHA_TRANSACCION     AS FECHA_TRANSACCION,
              CR.CSUSV_ESTADO_TRANSACCION    AS ESTADO_TRANSACCION,
              CR.CSUSV_MENSAJE_TRANSACCION   AS MENSAJE_TRANSACCION
      FROM IOTCT_CONTROL_SUSCRIPCIONES CR
      WHERE TO_DATE(TO_CHAR(CR.CSUSD_FECHA_TRANSACCION, 'DD/MM/YYYY'), 'DD/MM/YYYY') = TO_DATE(TO_CHAR(PI_FECHA_TRANSACCION,'DD/MM/YYYY'), 'DD/MM/YYYY');

      PO_CODRPTA:='0';
      PO_MSJRPTA:='Consulta exitosa';

  ELSE
     OPEN PO_CURSOR FOR
        SELECT NULL ID_CONTROLSUS,
               NULL ID_TRANSACCION,
               NULL FLAG_TRANSACCION,
               NULL TIPO_TRANSACCION,
               NULL DOCUMENTO_VENTA,
               NULL NOMBRE_APLICACION,
               NULL OPERACION_SUSCRIPCION,
               NULL NOMBRE_SERVICIO,
               NULL NOMBRE_PDV,
               NULL CUSTOMERID,
               NULL TELEFONO,
               NULL FECHA_TRANSACCION,
               NULL ESTADO_TRANSACCION,
               NULL MENSAJE_TRANSACCION
          FROM DUAL
         WHERE ROWNUM = 0;

         PO_CODRPTA:='1';
         PO_MSJRPTA:='No existen registros';
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_CONTROL_SUSCRIPCIONES;
/****************************************************************
  * Nombre SP          : IOTSS_OBTENER_CUSTOMERID
  * Proposito          : SP que genera el id de usuario de claro video.
  *
  * Input               : No Aplica.
  * Output              : PO_CUSTOMERID     -ID de Usuario de claro video.
  *                       PO_CODRPTA        - Indica si el procedure termino exitosamente o no.
  *                       PO_MSJRPTA        - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 09/12/2019
  * Fec Actualizacion  :
***************************************************************/
PROCEDURE IOTSS_OBTENER_CUSTOMERID (PO_CUSTOMERID             OUT IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                                    PO_CODRPTA                OUT VARCHAR2,
                                    PO_MSJRPTA                OUT VARCHAR2)IS

 SQUTX_VALUE_USU_CURRENT NUMBER;
 BEGIN
     SELECT IOTSEQ_USUARIO.NEXTVAL INTO SQUTX_VALUE_USU_CURRENT FROM DUAL;
        PO_CUSTOMERID:= SQUTX_VALUE_USU_CURRENT;
        PO_CODRPTA:='0';
        PO_MSJRPTA:='Exito';

 EXCEPTION
    WHEN OTHERS THEN
      PO_CUSTOMERID:='';
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;
  END IOTSS_OBTENER_CUSTOMERID;
/****************************************************************
  * Nombre SP          : IOTSS_INGRESOS_SUSC
  * Proposito          : SP para el proceso de Reportes que obtiene los ingresos diarios
                         de las suscripciones de los servicios de claro video.
  * Input              :   PI_FECHA_INICIO - Fecha del dia anterior.
  * Output             :   PO_CURSOR       - Listado de Ingresos Activos.
  *                         @NRO_RNO,
  *                         @CUSTOMER_ID,
  *                         @LINEA,
  *                         @TIPO_CLIENTE,
  *                         @FECHA_SUSCRIPCION
  *                         @FECHA_VIGENCIA,
  *                         @ESTADO_SUS,
  *                         @ID_SERVICIO,
  *                         @DESC_SERVICIO,
  *                         @SERV_NOMBRE,
  *                         @TIPO_SERVICIO,
  *                         @EMAIL,
  *                         @SEGMENTO,
  *                         @TIPO_CLIENTE
  *                        PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         :
  * Actualizado por    :
  * Fec Creacion       : 09/12/2019
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/

PROCEDURE IOTSS_INGRESOS_SUSC(PI_FECHA_INICIO      IN DATE,
                              PO_CODRPTA           OUT VARCHAR2,
                              PO_MSJRPTA           OUT VARCHAR2,
                              PO_CURSOR            OUT C_REF_CURSOR)IS

V_CONTADOR NUMBER :=0;
V_MASIVO   VARCHAR(10):='MASIVO';
BEGIN
  SELECT COUNT(1) INTO V_CONTADOR
      FROM IOTT_CLIENTE C
      JOIN IOTT_SUSCRIPCION S
         ON C.CLIN_USUARIOID = S.SUSN_USUARIOID
      JOIN IOTCT_SERVICIO SE
        ON S.SUSN_SERVICIOID = SE.SERVN_SERVICEID
     WHERE S.SUSC_ESTADO = C_AMCO_ACTI
      AND TRUNC(S.SUSD_FECHA_SUSCRIPCION) = TO_DATE(TO_CHAR(PI_FECHA_INICIO,'DD/MM/YYYY'), 'DD/MM/YYYY')
      AND C.CLIC_ESTADO = C_AMCO_ACTI;

   IF V_CONTADOR > 0 THEN
     OPEN PO_CURSOR FOR
      SELECT V_MASIVO                     AS TIPO_CLIENTE,
             S.SUSV_LINEA                 AS LINEA,
             S.SUSV_TIPO_LINEA            AS SEGMENTO,
             S.SUSV_CUSTOMERID            AS CUSTOMER_ID,
             SE.SERVV_DESCRIP             AS DESC_SERV,
             SE.SERVD_PRECIO              AS PRECIO_SERV,
             S.SUSD_FECHA_SUSCRIPCION     AS FEC_ALTA_SUS,
             DECODE(S.SUSV_METODOPAGO, '1', C_AMCO_MOVIL, '2', C_AMCO_FIJA) AS METODO_PAGO,
             S.SUSC_ESTADO AS ESTADO_SUS,
             C.CLIV_CORREO AS EMAIL
        FROM IOTT_CLIENTE C
        JOIN IOTT_SUSCRIPCION S
         ON C.CLIN_USUARIOID = S.SUSN_USUARIOID
        JOIN IOTCT_SERVICIO SE
          ON S.SUSN_SERVICIOID = SE.SERVN_SERVICEID
         WHERE S.SUSC_ESTADO = C_AMCO_ACTI
         AND TRUNC(S.SUSD_FECHA_SUSCRIPCION) = TO_DATE(TO_CHAR(PI_FECHA_INICIO,'DD/MM/YYYY'), 'DD/MM/YYYY')
         AND C.CLIC_ESTADO = C_AMCO_ACTI;

         PO_CODRPTA:='0';
         PO_MSJRPTA:='Operacion exitosa';
  ELSE
     OPEN PO_CURSOR FOR
      SELECT NULL AS TIPO_CLIENTE,
             NULL AS LINEA,
             NULL AS SEGMENTO,
             NULL AS CUSTOMER_ID,
             NULL AS DESC_SERV,
             NULL AS PRECIO_SERV,
             NULL AS FEC_ALTA_SUS,
             NULL AS METODO_PAGO,
             NULL AS ESTADO_SUS,
             NULL AS EMAIL
         FROM DUAL WHERE ROWNUM=0;
     PO_CODRPTA:='1';
     PO_MSJRPTA:='No se encontraron registros de ingresos';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_INGRESOS_SUSC;
/****************************************************************
  * Nombre SP          : IOTSS_ALTAS_SUSC
  * Proposito          : SP para el proceso de Reportes que obtiene las altas de los servicios
  *                      de Claro Video.
  * Input              :   PI_FECHA_INICIO - Fecha del dia anterior.
  * Output             :   PO_CURSOR       - Listado de Altas de Suscripciones
  *                         @NRO_RNO,
  *                         @CUSTOMER_ID,
  *                         @LINEA,
  *                         @TIPO_CLIENTE,
  *                         @FECHA_SUSCRIPCION
  *                         @FECHA_VIGENCIA,
  *                         @ESTADO_SUS,
  *                         @ID_SERVICIO,
  *                         @DESC_SERVICIO,
  *                         @SERV_NOMBRE,
  *                         @TIPO_SERVICIO,
  *                         @EMAIL,
  *                         @SEGMENTO,
  *                         @TIPO_CLIENTE
  *                        PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 09/12/2019
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSS_ALTAS_SUSC(PI_FECHA_INICIO IN DATE,
                           PO_CODRPTA      OUT VARCHAR2,
                           PO_MSJRPTA      OUT VARCHAR2,
                           PO_CURSOR       OUT C_REF_CURSOR) IS

V_CONT                NUMBER := 0;
V_COD_MOVIL           CHAR(1):= '1';
V_COD_FIJA            CHAR(1):= '2';
V_ESTADO_ACTIVO       CHAR(1):= '1';
V_CONT_RENO           NUMBER :=  0;
V_MASIVO              VARCHAR(10):='MASIVO';
BEGIN
  SELECT COUNT(1)
    INTO V_CONT
    FROM IOTT_CLIENTE C
    JOIN IOTT_SUSCRIPCION S
      ON C.CLIN_USUARIOID = S.SUSN_USUARIOID
    JOIN IOTCT_SERVICIO SE
      ON S.SUSN_SERVICIOID = SE.SERVN_SERVICEID
   WHERE SE.SERVC_ESTADO = V_ESTADO_ACTIVO
         AND UPPER(S.SUSC_ESTADO) = C_AMCO_ACTI
         AND TRUNC(S.SUSD_FECHA_SUSCRIPCION) = TRUNC(PI_FECHA_INICIO)
       ORDER BY S.SUSD_FECHA_SUSCRIPCION DESC;

  IF V_CONT > 0 THEN
    OPEN PO_CURSOR FOR
      SELECT
            (CASE WHEN SE.SERVV_TIPO = C_AMCO_PAGA THEN TRUNC(MONTHS_BETWEEN(SUSD_FECHA_VIGENCIA,SUSD_FECHA_SUSCRIPCION))
                  ELSE V_CONT_RENO END) AS NRO_RNO,
             S.SUSV_CUSTOMERID          AS CUSTOMER_ID,
             S.SUSV_LINEA               AS LINEA,
             (CASE WHEN S.SUSV_METODOPAGO = V_COD_MOVIL  THEN C_AMCO_MOVIL
                   WHEN S.SUSV_METODOPAGO = V_COD_FIJA   THEN C_AMCO_FIJA
                   ELSE NULL END)     AS METODO_PAGO,
             S.SUSD_FECHA_SUSCRIPCION AS FECHA_SUSCRIPCION,
             S.SUSD_FECHA_VIGENCIA    AS FECHA_VIGENCIA,
             S.SUSC_ESTADO            AS ESTADO_SUS,
             S.SUSN_SERVICIOID        AS ID_SERVICIO,
             SE.SERVV_DESCRIP         AS DESC_SERVICIO,
             SE.SERVV_NOMBRE          AS SERV_NOMBRE,
             SE.SERVV_TIPO            AS TIPO_SERVICIO,
             C.CLIV_CORREO            AS EMAIL,
             S.SUSV_TIPO_LINEA        AS SEGMENTO,
             V_MASIVO                 AS TIPO_CLIENTE
        FROM IOTT_CLIENTE C
        JOIN IOTT_SUSCRIPCION S
          ON C.CLIN_USUARIOID = S.SUSN_USUARIOID
        JOIN IOTCT_SERVICIO SE
          ON S.SUSN_SERVICIOID = SE.SERVN_SERVICEID
       WHERE SE.SERVC_ESTADO = V_ESTADO_ACTIVO
         AND UPPER(S.SUSC_ESTADO) = C_AMCO_ACTI
         AND TRUNC(S.SUSD_FECHA_SUSCRIPCION) = TRUNC(PI_FECHA_INICIO)
       ORDER BY S.SUSD_FECHA_SUSCRIPCION DESC;

       PO_CODRPTA:='0';
       PO_MSJRPTA:='Operacion exitosa';

  ELSE
    OPEN PO_CURSOR FOR
      SELECT NULL AS NRO_RNO,
             NULL AS CUSTOMER_ID,
             NULL AS LINEA,
             NULL AS METODO_PAGO,
             NULL AS FECHA_SUSCRIPCION,
             NULL AS FECHA_VIGENCIA,
             NULL AS ESTADO_SUS,
             NULL AS ID_SERVICIO,
             NULL AS DESC_SERVICIO,
             NULL AS SERV_NOMBRE,
             NULL AS TIPO_SERVICIO,
             NULL AS EMAIL,
             NULL AS SEGMENTO,
             NULL AS TIPO_CLIENTE
        FROM DUAL
       WHERE ROWNUM = 0;

    PO_CODRPTA:='1';
    PO_MSJRPTA:='No se encontraron registros de altas';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_ALTAS_SUSC;
/****************************************************************
  * Nombre SP          : IOTSS_CONCILIACION
  * Proposito          : SP para el proceso de Reportes que obtiene el detalle
                         de las ventas que han caido en error.
  * Input              :   PI_FECHA_INICIO - Fecha del dia anterior.
  * Output             :   PO_CURSOR       - Listado de Concialiaciones
  *                         @FECHA_TRANSAC,
  *                         @LINEA,
  *                         @MENSAJE_ERROR,
  *                         @TIPO,
  *                         @SERVICIOID
  *                         @SERV_NOMBRE
  *                        PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         : Renzo Carbajal
  * Actualizado por    :
  * Fec Creacion       : 16/12/2019
  * Fec Actualizacion  : 10/03/2020
  * Motivo cambio      : Mejora de querys
***************************************************************/
PROCEDURE IOTSS_CONCILIACION(PI_FECHA_INICIO       IN DATE,
                              PO_CODRPTA           OUT VARCHAR2,
                              PO_MSJRPTA           OUT VARCHAR2,
                              PO_CURSOR            OUT C_REF_CURSOR)IS
V_CONT    NUMBER :=0;
BEGIN

      SELECT COUNT(1) INTO V_CONT
      FROM IOTCT_TRANSACCION TR
      LEFT JOIN IOTT_SUSCRIPCION T  ON TR.TRANV_TELEFONO = T.SUSV_LINEA AND TR.TRANV_SERVICIO = TO_CHAR(T.SUSN_SERVICIOID)
      LEFT JOIN IOTCT_SERVICIO  SE  ON TR.TRANV_SERVICIO = TO_CHAR(SE.SERVN_SERVICEID)
      WHERE TR.TRANV_SERVICE_NAME IN ('provisionarSuscripcionNS','provisionarSuscripcionNS','cancelarSuscripcionSN','cancelarSuscripcionNS')
      AND TR.TRANV_TELEFONO IS NOT NULL
      AND TRUNC(TR.TRAND_FECHA_TRANSAC) = TO_DATE(TO_CHAR(PI_FECHA_INICIO, 'DD/MM/YYYY'), 'DD/MM/YYYY');

  IF V_CONT > 0 THEN
    OPEN PO_CURSOR FOR
      SELECT TR.TRAND_FECHA_TRANSAC AS FECHA_TRANSAC,
             TR.TRANV_TELEFONO      AS LINEA,
             TR.TRANV_MENSAJE       AS MENSAJE_ERROR,
             SE.SERVV_TIPO          AS TIPO,
             SE.SERVN_SERVICEID     AS SERVICIOID,
             SE.SERVV_NOMBRE        AS SERV_NOMBRE
      FROM IOTCT_TRANSACCION TR
      LEFT JOIN IOTT_SUSCRIPCION T  ON TR.TRANV_TELEFONO = T.SUSV_LINEA AND TR.TRANV_SERVICIO = TO_CHAR(T.SUSN_SERVICIOID)
      LEFT JOIN IOTCT_SERVICIO  SE  ON TR.TRANV_SERVICIO = TO_CHAR(SE.SERVN_SERVICEID)
      WHERE TR.TRANV_SERVICE_NAME IN ('provisionarSuscripcionNS','provisionarSuscripcionNS','cancelarSuscripcionSN','cancelarSuscripcionNS')
      AND TR.TRANV_TELEFONO IS NOT NULL
      AND TRUNC(TR.TRAND_FECHA_TRANSAC) = TO_DATE(TO_CHAR(PI_FECHA_INICIO, 'DD/MM/YYYY'), 'DD/MM/YYYY');

       PO_CODRPTA:='0';
       PO_MSJRPTA:='Operacion Exitosa';
    ELSE
      OPEN PO_CURSOR FOR
            SELECT NULL AS FECHA_TRANSAC,
                   NULL AS LINEA,
                   NULL AS MENSAJE_ERROR,
                   NULL AS TIPO,
                   NULL AS SERVICIOID,
                   NULL AS SERV_NOMBRE
              FROM DUAL
             WHERE ROWNUM = 0;

             PO_CODRPTA:='1';
             PO_MSJRPTA:='No existen registros para la conciliaciÃ³n';
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_CONCILIACION;
/****************************************************************
  * Nombre SP          : IOTSS_LINEA_CUSTOMERID
  * Proposito          : SP para obtener el customerId del cliente por la linea del cliente
  * Input              :   PI_LINEA - Linea del cliente.
  * Output             :   PO_CUSTOMERID   - Id generado de la tabla cliente
  *                        PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         :
  * Actualizado por    :
  * Fec Creacion       : 16/12/2019
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSS_LINEA_CUSTOMERID(PI_LINEA             IN  IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                 PO_CUSTOMERID        OUT IOTT_SUSCRIPCION.SUSN_USUARIOID%TYPE,
                                 PO_CODRPTA           OUT VARCHAR2,
                                 PO_MSJRPTA           OUT VARCHAR2)IS


V_CONTADOR NUMBER;
BEGIN
  SELECT COUNT(1)
    INTO V_CONTADOR
    FROM IOTT_SUSCRIPCION C
   WHERE C.SUSV_LINEA = PI_LINEA;

   IF V_CONTADOR = 0 THEN
     PO_CODRPTA:= '1';
     PO_MSJRPTA:= 'Linea no cuenta con customerID';
   RETURN;
 END IF;

 SELECT C.SUSN_USUARIOID
   INTO PO_CUSTOMERID
   FROM IOTT_SUSCRIPCION C
  WHERE C.SUSV_LINEA = PI_LINEA
    AND ROWNUM = 1;

    PO_CODRPTA:= '0';
    PO_MSJRPTA:= 'Operacion Exitosa';

EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
END IOTSS_LINEA_CUSTOMERID;
/****************************************************************
  * Nombre SP          : IOTSS_CORREO_CUSTOMERID
  * Proposito          : SP para obtener el customerId por el correo del cliente.
  * Input              :   PI_CORREO - Correo del cliente.
  * Output             :   PO_CUSTOMERID - Id generado de la tabla cliente
  *                        PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                        PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         :
  * Actualizado por    :
  * Fec Creacion       : 16/12/2019
  * Fec Actualizacion  : 25/03/2020 - Se mejoro el query para contralar las escepciones
                         07/05/2020 - Mejora de filtro.
***************************************************************/
PROCEDURE IOTSS_CORREO_CUSTOMERID(PI_CORREO            IN  IOTT_CLIENTE.CLIV_CORREO%TYPE,
                                  PO_CUSTOMERID        OUT IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                                  PO_CODRPTA           OUT VARCHAR2,
                                  PO_MSJRPTA           OUT VARCHAR2)IS

e_error     EXCEPTION;
e_error_row EXCEPTION;
BEGIN
  BEGIN
     SELECT
       C.CLIN_USUARIOID INTO PO_CUSTOMERID
     FROM IOTT_CLIENTE C
     WHERE UPPER(C.CLIV_CORREO) = UPPER(PI_CORREO)
     and c.clic_estado = 'A';
   Exception
      WHEN NO_DATA_FOUND THEN
        RAISE e_error;
      WHEN too_many_rows then
        RAISE e_error_row;
    end;
     PO_CODRPTA:='0';
     PO_MSJRPTA:='Operacion Exitosa';
 EXCEPTION
    WHEN e_error then
      po_codrpta := -1;
      po_msjrpta := 'El correo del ' ||
                    PI_CORREO || ' no Existe';
    WHEN e_error_row then
      po_codrpta := -2;
      po_msjrpta := 'Existe mas de un customer asociado al correo ' ||
                    PI_CORREO;
    When Others Then
      po_codrpta := -3;
      po_msjrpta := 'Error' || Sqlerrm;
END IOTSS_CORREO_CUSTOMERID;

/****************************************************************
  * Nombre SP          : IOTSS_DATOS_CLIENTE
  * Proposito          : SP para obtener el correo y el customerId por la linea mÃ³vil y fija.
  * Input              : PI_MEDIO_PAGO  - Linea del cliente.
  * Output             : PO_CORREO     - Correo del cliente suscrito.
  *                    : PO_USUARIOID  - Id generado de la tabla cliente.
  *                      PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         :
  * Actualizado por    :
  * Fec Creacion       : 16/12/2019
  * Fec Actualizacion  :
  * Motivo cambio      : 25/06/2020 - Cambio para que maneje estado de baja
***************************************************************/
 PROCEDURE IOTSS_DATOS_CLIENTE (PI_MEDIO_PAGO IN IOTT_CLIENTE.CLIV_LINEA%TYPE,
                                PO_CORREO     OUT IOTT_CLIENTE.CLIV_CORREO%TYPE,
                                PO_USUARIOID  OUT IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                                PO_CODRPTA    OUT VARCHAR2,
                                PO_MSJRPTA    OUT VARCHAR2)IS

V_CORREO                        IOTT_CLIENTE.CLIV_CORREO%TYPE;
V_USUARIOID                     IOTT_CLIENTE.CLIN_USUARIOID%TYPE;
V_CONT                          NUMBER  := 0;
V_ESTADO_BAJA                   CHAR(1) := 'B';
BEGIN
  PO_CORREO:='';
  PO_USUARIOID:='';

  SELECT COUNT(1)
    INTO V_CONT
    FROM IOTT_SUSCRIPCION S
    JOIN IOTT_CLIENTE C
      ON S.SUSN_USUARIOID = C.CLIN_USUARIOID
   WHERE S.SUSV_LINEA = PI_MEDIO_PAGO
     AND S.SUSC_ESTADO <> V_ESTADO_BAJA;

     IF V_CONT > 0 THEN
       SELECT C.CLIV_CORREO, C.CLIN_USUARIOID
         INTO V_CORREO, V_USUARIOID
         FROM IOTT_SUSCRIPCION S
         JOIN IOTT_CLIENTE C
           ON S.SUSN_USUARIOID = C.CLIN_USUARIOID
        WHERE S.SUSV_LINEA = PI_MEDIO_PAGO
          AND S.SUSC_ESTADO <> V_ESTADO_BAJA
          AND ROWNUM = 1;

          PO_CORREO:=V_CORREO;
          PO_USUARIOID:=V_USUARIOID;
          PO_CODRPTA:='0';
          PO_MSJRPTA:='Operacion Exitosa';
     ELSE
       PO_CODRPTA:='1';
       PO_MSJRPTA:='No existen suscripciones';
     END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
END IOTSS_DATOS_CLIENTE;
/****************************************************************
  * Nombre SP          : IOTSS_CONSULTAR_PAGO_SERVICIO
  * Proposito          : SP  que devuelve los datos del servicio que tiene activo o que se puede
                         suscribir asi este en su periodo de Promocion o de Paga.
  * Input              : PI_LINEA - Fecha del dia anterior.
                         PI_TMCOD_PLAN - Codigo de plan de la tabla planes
       PI_TPOID_PLAN - Codigo de plan de linea de la tabla planes
                         PI_NOMBRE_SERVICIO - Nombre del servicio
                         DESCRIP_SERVICIO   -
                         PI_TIPO_LINEA - Tipo de Linea(PREPAGO,POSTPAGO,FIJA)
  * Output             : PO_CURSOR         - Cursor de consulta de servicios.
  *                    : @NOMBRE_SERVICIO  - Nombre del Servicio.
  *                      @DESCRIP_SERVICIO - Descripcion del Servicio
  *                      @FECHA_SUSCRIPCION - Fecha de Suscripcion
  *                      @FECHA_VIGENCIA    - Fecha de Vigencia
  *                      @DIAS_PROMO        - Dias de Promocion
  *                      @SERVICIO_PRECIO   - Precio del Servicio
  *                      @ESTADO_PAGO       - Estado de Pago
  *                      PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 16/12/2019
  * Fec Actualizacion  : 10/07/2020
  * Motivo cambio      : Actualizacion de logica de negocio para el estado de pago contemplando
  *                      los planes de TV BASICA y Claro video.
***************************************************************/
PROCEDURE IOTSS_CONSULTAR_PAGO_SERVICIO (PI_LINEA           IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                         PI_TMCOD_PLAN      IN IOTCT_PLANES.PLNN_TMCOD%TYPE,
                                         PI_TPOID_PLAN      IN IOTCT_PLANES.PLNN_POID%TYPE,
                                         PI_NOMBRE_SERVICIO IN IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                         PI_TIPO_LINEA      IN IOTT_SUSCRIPCION.SUSV_TIPO_LINEA%TYPE,
                                         PO_CURSOR          OUT C_REF_CURSOR,
                                         PO_CODRPTA         OUT VARCHAR2,
                                         PO_MSJRPTA         OUT VARCHAR2)IS

V_CONSERV        NUMBER:=0;
V_COUNT_ACT      NUMBER:=0;
V_COUNT_SUSC     NUMBER:=0;
V_COUNT_PLAN     NUMBER:=0;
V_PROMOCION      VARCHAR2(15):='PROMOCION';
V_POSTPAGO       VARCHAR2(10):='POSTPAGO';
V_PREPAGO        VARCHAR2(10):='PREPAGO';
V_FIJA           VARCHAR2(5):='FIJA';
V_CLARO_VIDEO    IOTCT_SERVICIO.SERVV_NOMBRE%TYPE:='CLARO VIDEO';
V_PRECIO         IOTCT_SERVICIO.SERVD_PRECIO%TYPE;
BEGIN

  PO_CODRPTA:='0';
  PO_MSJRPTA:='Operacion Exitosa';

  SELECT COUNT(1)
    INTO V_CONSERV
    FROM IOTCT_SERVICIO S
   WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
   AND S.SERVV_TIPO IN (C_AMCO_BONO, C_AMCO_PAGA);

   IF V_CONSERV > 0 THEN

     SELECT SE.SERVD_PRECIO
       INTO V_PRECIO
       FROM IOTCT_SERVICIO SE
      WHERE SE.SERVV_TIPO = C_AMCO_PAGA
        AND SE.SERVV_NOMBRE = PI_NOMBRE_SERVICIO;


    SELECT COUNT(1)
      INTO V_COUNT_SUSC
      FROM IOTT_SUSCRIPCION S
      JOIN IOTCT_SERVICIO X
        ON S.SUSN_SERVICIOID = X.SERVN_SERVICEID
     WHERE S.SUSV_LINEA = PI_LINEA
       AND X.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
       AND S.SUSC_ESTADO <> 'B';

       IF V_COUNT_SUSC > 0 THEN

         SELECT COUNT(1)
          INTO V_COUNT_ACT
          FROM IOTT_SUSCRIPCION S
          JOIN IOTCT_SERVICIO X
            ON S.SUSN_SERVICIOID = X.SERVN_SERVICEID
         WHERE S.SUSV_LINEA = PI_LINEA
           AND X.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
           AND (S.SUSC_ESTADO = C_AMCO_ACTI OR
                S.SUSC_ESTADO = C_AMCO_SUSP);

           IF V_COUNT_ACT > 0 THEN

             OPEN PO_CURSOR FOR
                SELECT X.SERVV_NOMBRE                  AS NOMBRE_SERVICIO,
                       X.SERVV_DESCRIP                 AS DESCRIP_SERVICIO,
                       TRUNC(S.SUSD_FECHA_SUSCRIPCION) AS FECHA_SUSCRIPCION,
                       TRUNC(S.SUSD_FECHA_VIGENCIA)    AS FECHA_VIGENCIA,
                       X.SERVN_DIAS_PROMO              AS DIAS_PROMO,
                       DECODE(X.SERVN_SERVICEID,
                              110000999,
                              0,
                              V_PRECIO)                 AS SERVICIO_PRECIO,
                       DECODE(X.SERVV_TIPO,
                               C_AMCO_BONO,
                                   V_PROMOCION,
                                       X.SERVV_TIPO)   AS ESTADO_PAGO
                  FROM IOTT_SUSCRIPCION S
                  JOIN IOTCT_SERVICIO X
                    ON S.SUSN_SERVICIOID = X.SERVN_SERVICEID
                 WHERE S.SUSV_LINEA = PI_LINEA
                   AND X.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                   AND (S.SUSC_ESTADO = C_AMCO_ACTI OR
                        S.SUSC_ESTADO = C_AMCO_SUSP)
                   AND ROWNUM = 1;

                RETURN;

           ELSE

             OPEN PO_CURSOR FOR
                 SELECT X.SERVV_NOMBRE     AS NOMBRE_SERVICIO,
                        X.SERVV_DESCRIP    AS DESCRIP_SERVICIO,
                        NULL               AS FECHA_SUSCRIPCION,
                        NULL               AS FECHA_VIGENCIA,
                        '0'                AS DIAS_PROMO,
                        X.SERVD_PRECIO     AS SERVICIO_PRECIO,
                        X.SERVV_TIPO       AS ESTADO_PAGO
                   FROM IOTCT_SERVICIO X
                  WHERE X.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                    AND X.SERVV_TIPO = C_AMCO_PAGA;

              RETURN;
          END IF;

      ELSE

        IF (UPPER(PI_TIPO_LINEA) = V_POSTPAGO) OR (UPPER(PI_TIPO_LINEA) = V_FIJA)  THEN

          IF PI_NOMBRE_SERVICIO = 'CLARO VIDEO' THEN

            SELECT COUNT(1)
              INTO V_COUNT_PLAN
              FROM IOTCT_PLANES P
              JOIN IOTCT_SERVICIO S
                ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
             WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
               AND (CASE
           WHEN  PI_TMCOD_PLAN = 0
             AND  P.PLNN_POID = PI_TPOID_PLAN
             THEN 1
           WHEN  PI_TMCOD_PLAN <> 0 AND
             P.PLNN_TMCOD =  PI_TMCOD_PLAN
             THEN 1
           ELSE 0
          END) = 1;

              OPEN PO_CURSOR FOR
                   SELECT S.SERVV_NOMBRE     AS NOMBRE_SERVICIO,
                          S.SERVV_DESCRIP    AS DESCRIP_SERVICIO,
                          NULL               AS FECHA_SUSCRIPCION,
                          NULL               AS FECHA_VIGENCIA,
                          S.SERVN_DIAS_PROMO AS DIAS_PROMO,
                          V_PRECIO           AS SERVICIO_PRECIO,
                          V_PROMOCION        AS ESTADO_PAGO
                     FROM IOTCT_SERVICIO S
                    WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                      AND S.SERVV_TIPO = C_AMCO_BONO
                      AND S.SERVN_SERVICEID =
                          DECODE(V_COUNT_PLAN, 0, 10000030, 10000999);

                RETURN;

          ELSIF PI_NOMBRE_SERVICIO = 'TV BASICA' THEN

            IF UPPER(PI_TIPO_LINEA) = V_FIJA THEN

              SELECT COUNT(1)
                INTO V_COUNT_PLAN
                FROM IOTCT_PLANES P
                JOIN IOTCT_SERVICIO S
                  ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
               WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                 AND (CASE
           WHEN  PI_TMCOD_PLAN = 0
             AND  P.PLNN_POID = PI_TPOID_PLAN
             THEN 1
           WHEN  PI_TMCOD_PLAN <> 0 AND
             P.PLNN_TMCOD =  PI_TMCOD_PLAN
             THEN 1
           ELSE 0
          END) = 1;

                OPEN PO_CURSOR FOR
                     SELECT S.SERVV_NOMBRE               AS NOMBRE_SERVICIO,
                            S.SERVV_DESCRIP              AS DESCRIP_SERVICIO,
                            NULL                         AS FECHA_SUSCRIPCION,
                            NULL                         AS FECHA_VIGENCIA,
                            S.SERVN_DIAS_PROMO           AS DIAS_PROMO,
                            S.SERVD_PRECIO               AS SERVICIO_PRECIO,
                            DECODE(S.SERVV_TIPO,
                                     C_AMCO_BONO,
                                       V_PROMOCION,
                                         S.SERVV_TIPO)   AS ESTADO_PAGO
                       FROM IOTCT_SERVICIO S
                       WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                         AND S.SERVV_TIPO = DECODE(V_COUNT_PLAN,0,C_AMCO_PAGA,C_AMCO_BONO);

                   RETURN;
            ELSE

              OPEN PO_CURSOR FOR
                  SELECT X.SERVV_NOMBRE     AS NOMBRE_SERVICIO,
                         X.SERVV_DESCRIP    AS DESCRIP_SERVICIO,
                         NULL               AS FECHA_SUSCRIPCION,
                         NULL               AS FECHA_VIGENCIA,
                         X.SERVN_DIAS_PROMO AS DIAS_PROMO,
                         X.SERVD_PRECIO     AS SERVICIO_PRECIO,
                         X.SERVV_TIPO       AS ESTADO_PAGO
                    FROM IOTCT_SERVICIO X
                   WHERE X.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                     AND X.SERVV_TIPO = C_AMCO_PAGA;

                   RETURN;

            END IF;

          ELSIF PI_NOMBRE_SERVICIO IN ('INDYCAR','KARAOKE') THEN

             OPEN PO_CURSOR FOR
                  SELECT  S.SERVV_NOMBRE     AS NOMBRE_SERVICIO,
                          S.SERVV_DESCRIP    AS DESCRIP_SERVICIO,
                          NULL               AS FECHA_SUSCRIPCION,
                          NULL               AS FECHA_VIGENCIA,
                          '0'                AS DIAS_PROMO,
                          S.SERVD_PRECIO     AS SERVICIO_PRECIO,
                          S.SERVV_TIPO       AS ESTADO_PAGO
                     FROM IOTCT_SERVICIO S
                    WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                      AND S.SERVV_TIPO = C_AMCO_PAGA;
              RETURN;

          ELSE

             OPEN PO_CURSOR FOR
                  SELECT S.SERVV_NOMBRE      AS NOMBRE_SERVICIO,
                         S.SERVV_DESCRIP     AS DESCRIP_SERVICIO,
                         NULL                AS FECHA_SUSCRIPCION,
                         NULL                AS FECHA_VIGENCIA,
                         S.SERVN_DIAS_PROMO  AS DIAS_PROMO,
                         V_PRECIO            AS SERVICIO_PRECIO,
                         V_PROMOCION         AS ESTADO_PAGO
                     FROM IOTCT_SERVICIO S
                    WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                      AND S.SERVV_TIPO = C_AMCO_BONO;

              RETURN;

          END IF;

        ELSIF UPPER(PI_TIPO_LINEA) = V_PREPAGO THEN

          IF PI_NOMBRE_SERVICIO = V_CLARO_VIDEO THEN

             OPEN PO_CURSOR FOR
                  SELECT S.SERVV_NOMBRE         AS NOMBRE_SERVICIO,
                         S.SERVV_DESCRIP        AS DESCRIP_SERVICIO,
                         NULL                   AS FECHA_SUSCRIPCION,
                         NULL                   AS FECHA_VIGENCIA,
                         S.SERVN_DIAS_PROMO     AS DIAS_PROMO,
                         V_PRECIO               AS SERVICIO_PRECIO,
                         V_PROMOCION            AS ESTADO_PAGO
                    FROM IOTCT_SERVICIO S
                   WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                     AND S.SERVV_TIPO = C_AMCO_BONO
                     AND S.SERVN_SERVICEID = 10000030;
              RETURN;

          ELSIF PI_NOMBRE_SERVICIO IN ('INDYCAR','KARAOKE','TV BASICA') THEN

             OPEN PO_CURSOR FOR
                  SELECT  S.SERVV_NOMBRE     AS NOMBRE_SERVICIO,
                          S.SERVV_DESCRIP    AS DESCRIP_SERVICIO,
                          NULL               AS FECHA_SUSCRIPCION,
                          NULL               AS FECHA_VIGENCIA,
                          '0'                AS DIAS_PROMO,
                          S.SERVD_PRECIO     AS SERVICIO_PRECIO,
                          S.SERVV_TIPO       AS ESTADO_PAGO
                     FROM IOTCT_SERVICIO S
                    WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                      AND S.SERVV_TIPO = C_AMCO_PAGA;
             RETURN;

          ELSE

            OPEN PO_CURSOR FOR
                 SELECT   S.SERVV_NOMBRE      AS NOMBRE_SERVICIO,
                          S.SERVV_DESCRIP     AS DESCRIP_SERVICIO,
                          NULL                AS FECHA_SUSCRIPCION,
                          NULL                AS FECHA_VIGENCIA,
                          S.SERVN_DIAS_PROMO  AS DIAS_PROMO,
                          V_PRECIO            AS SERVICIO_PRECIO,
                          V_PROMOCION         AS ESTADO_PAGO
                     FROM IOTCT_SERVICIO S
                    WHERE S.SERVV_NOMBRE = PI_NOMBRE_SERVICIO
                      AND S.SERVV_TIPO = C_AMCO_BONO;
          END IF;

        ELSE

          PO_CODRPTA:='2';
          PO_MSJRPTA:='Tipo de linea no existe';

          OPEN PO_CURSOR FOR
            SELECT NULL AS NOMBRE_SERVICIO,
                   NULL AS DESCRIP_SERVICIO,
                   NULL AS FECHA_SUSCRIPCION,
                   NULL AS FECHA_VIGENCIA,
                   NULL AS DIAS_PROMO,
                   NULL AS SERVICIO_PRECIO,
                   NULL AS ESTADO_PAGO
              FROM DUAL
             WHERE ROWNUM = 0;

        END IF;

      END IF;
 ELSE

    PO_CODRPTA:='1';
    PO_MSJRPTA:='Servicio no configurado';

    OPEN PO_CURSOR FOR
     SELECT NULL AS NOMBRE_SERVICIO,
            NULL AS DESCRIP_SERVICIO,
            NULL AS FECHA_SUSCRIPCION,
            NULL AS FECHA_VIGENCIA,
            NULL AS DIAS_PROMO,
            NULL AS SERVICIO_PRECIO,
            NULL AS ESTADO_PAGO
       FROM DUAL
      WHERE ROWNUM = 0;

 END IF;
EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error ' || SQLCODE || ' : ' || SQLERRM;
END IOTSS_CONSULTAR_PAGO_SERVICIO;

 /****************************************************************
  * Nombre SP          : IOTSS_VALIDAR_PRODUCTID_PLAN
  * Proposito          : SP que valida el productid antes de adquirir un servicio
  *                      de claro video.
  *
  * Input              :  PI_PLAN             - CÃ³digo de plan del cliente
  *                       PI_LINEA            - Linea Fija o Movil del cliente.
  *                       PI_PRODUCTID        - Id Generico que envia Amco.
  *
  * Output             :  PO_PRODUCTID         - Id del producto que le pertenece al cliente
  *                                               segun su plan o si tuvo servicios.
  *                       PO_PRODUCTID_NOM     - Nombre del servicio
  *                       PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                       PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 30/01/2020
  * Fec Actualizacion  : 25/06/2020 - Se actualizo la logica del SP para los planes de
  *                                    TV- EN VIVO y CLARO VIDEO
  ***************************************************************/
PROCEDURE IOTSS_VALIDAR_PRODUCTID_PLAN  (PI_PLAN         IN IOTCT_PLANES.PLNN_TMCOD%TYPE,
                                        PI_PLAN_POID   IN VARCHAR2,
                                        PI_LINEA         IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                        PI_PRODUCTID     IN IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PO_PRODUCTID     OUT IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PO_PRODUCTID_NOM OUT IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                        PO_CODRPTA       OUT VARCHAR2,
                                        PO_MSJRPTA       OUT VARCHAR2) IS
   V_CONT_SERV          NUMBER := 0;
   V_CONT_PLAN          NUMBER := 0;
   V_CONTADOR_ACTIVO    NUMBER := 0;
   V_CONT_SUSC_CAN      NUMBER := 0;
   V_COUNT_TV           NUMBER := 0;
   V_ESTADO_ACTIVO      CHAR(1) := 'A';
   V_ESTADO_CANCEL      CHAR(1) := 'C';
   V_FLAG_PAGA        CHAR(1) := 'F';
   V_CONT_SOLO_PAGA     NUMBER := 0;
   V_CONT_PROD_INCL_PLAN NUMBER := 0;
   V_TIPO_LINEA     VARCHAR2(20);
   V_CONT_EXLC_PROD   NUMBER := 0;


   V_NOM_SERVICIO IOTCT_SERVICIO.SERVV_NOMBRE%TYPE;

   CURSOR C_NOM_SERVICIO(C_SERVICIO VARCHAR2) IS
     SELECT SE.SERVV_NOMBRE
       FROM IOTCT_SERVICIO SE
      WHERE SE.SERVN_SERVICEID = C_SERVICIO;

 BEGIN
    PO_CODRPTA := '0';
    PO_MSJRPTA := 'Consulta exitosa';

   SELECT COUNT(1)
     INTO V_CONT_SERV
     FROM IOTCT_SERVICIO S
    WHERE S.SERVN_SERVICEID = PI_PRODUCTID
      AND S.SERVV_TIPO IN (C_AMCO_BONO, C_AMCO_PAGA);

   IF V_CONT_SERV = 0 THEN
     PO_CODRPTA := '1';
     PO_MSJRPTA := 'Servicio no configurado';
     RETURN;
   END IF;

     --Obtener el servicio
     OPEN C_NOM_SERVICIO(PI_PRODUCTID);
     FETCH C_NOM_SERVICIO
       INTO V_NOM_SERVICIO;
     CLOSE C_NOM_SERVICIO;

     --Validar si cuenta con el servicio activo.
     SELECT COUNT(1)
       INTO V_CONTADOR_ACTIVO
       FROM IOTT_SUSCRIPCION SU
       JOIN IOTCT_SERVICIO S
         ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
      WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
        AND SU.SUSV_LINEA = PI_LINEA
        AND SU.SUSC_ESTADO = V_ESTADO_ACTIVO;

     IF V_CONTADOR_ACTIVO > 0 THEN
       PO_CODRPTA := '2';
       PO_MSJRPTA := 'El cliente ya cuenta con el servicio activo';
       RETURN;
     END IF;

    -- Validar tipo de Linea

    IF LENGTH(PI_LINEA) = 9 THEN
      V_TIPO_LINEA := C_AMCO_MOVIL;
    ELSE
      V_TIPO_LINEA := C_AMCO_FIJA;
    END IF;

       -- Validar exclusion de producto por tipo de linea

    SELECT COUNT(1)
               INTO V_CONT_EXLC_PROD
           FROM IOT.IOTT_CONFIGURACION C
           WHERE C.CONFV_SERVICIO = 'PROD_EXCL_X_TIPOLINEA'
                 AND C.CONFV_VALOR1 = PI_PRODUCTID
                 AND C.CONFV_VALOR2 = 'A'
         AND C.CONFV_VALOR3 = V_TIPO_LINEA;

    IF V_CONT_EXLC_PROD > 0 then
      PO_CODRPTA := '3';
            PO_MSJRPTA := 'El cliente no es elegible para el servicio';
      RETURN;
    END IF;

   -- Validar productos incluidos en el plan
    SELECT COUNT(1)
         INTO V_CONT_PROD_INCL_PLAN
         FROM IOT.IOTT_CONFIGURACION C
        WHERE C.CONFV_SERVICIO = 'PROD_INCL_PLAN'
            AND C.CONFV_VALOR1 = PI_PRODUCTID
            AND C.CONFV_VALOR2 = 'A';

    IF V_CONT_PROD_INCL_PLAN > 0 THEN

     PKG_HUB_IOT.IOTSS_VALID_PRODUCTID_INCL_PLAN (PI_PLAN, PI_PLAN_POID, PI_LINEA, PI_PRODUCTID, V_NOM_SERVICIO, V_TIPO_LINEA, PO_PRODUCTID, PO_PRODUCTID_NOM,PO_CODRPTA, PO_MSJRPTA);
     RETURN;

    END IF;

    --Validar si cuenta con servicios cancelados
    SELECT COUNT(1)
      INTO V_CONT_SUSC_CAN
      FROM IOTCT_SERVICIO S
      JOIN IOTT_SUSCRIPCION SU
        ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
     WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
       AND SU.SUSV_LINEA = PI_LINEA
       AND SU.SUSC_ESTADO = V_ESTADO_CANCEL;

   --Validar si es un producto solo de paga

        SELECT COUNT(1)
             INTO V_CONT_SOLO_PAGA
             FROM IOT.IOTT_CONFIGURACION C
             WHERE C.CONFV_SERVICIO='SP_POST'
                  AND C.CONFV_VALOR1=PI_PRODUCTID
                  AND C.CONFV_VALOR2='A';

   IF (V_CONT_SUSC_CAN = 0) AND (V_CONT_SOLO_PAGA = 0) THEN
     IF V_NOM_SERVICIO = 'CLARO VIDEO' THEN
       SELECT COUNT(1)
         INTO V_CONT_PLAN
         FROM IOTCT_PLANES P
         JOIN IOTCT_SERVICIO S
           ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
        WHERE (P.PLNN_TMCOD = PI_PLAN OR P.PLNN_POID = PI_PLAN_POID)
          AND S.SERVV_NOMBRE = V_NOM_SERVICIO
          AND S.SERVV_TIPO = C_AMCO_BONO;

        IF V_CONT_PLAN > 0 THEN
         SELECT DISTINCT S.SERVN_SERVICEID, S.SERVV_NOMBRE
           INTO PO_PRODUCTID, PO_PRODUCTID_NOM
           FROM IOTCT_PLANES P
           JOIN IOTCT_SERVICIO S
             ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
          WHERE (P.PLNN_TMCOD = PI_PLAN OR P.PLNN_POID = PI_PLAN_POID)
            AND S.SERVV_NOMBRE = V_NOM_SERVICIO
            AND S.SERVV_TIPO = C_AMCO_BONO;
         RETURN;
        ELSE
          SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
            INTO PO_PRODUCTID, PO_PRODUCTID_NOM
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
             AND S.SERVV_TIPO = C_AMCO_BONO
             AND S.SERVN_SERVICEID = 10000030;
          RETURN;
        END IF;
     ELSIF PI_PRODUCTID = 110001001 THEN
       IF (LENGTH(TRIM(PI_LINEA)) > 9) THEN
         SELECT COUNT(1)
           INTO V_COUNT_TV
           FROM IOTCT_PLANES PLN
           LEFT JOIN IOTCT_SERVICIO SER
             ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
          WHERE (PLN.PLNN_TMCOD = PI_PLAN OR PLN.PLNN_POID = PI_PLAN_POID)
            AND SERVV_NOMBRE = V_NOM_SERVICIO;

            IF V_COUNT_TV > 0 THEN
              SELECT DISTINCT SER.SERVN_SERVICEID,SER.SERVV_NOMBRE
                INTO PO_PRODUCTID, PO_PRODUCTID_NOM
                FROM IOTCT_PLANES PLN
                LEFT JOIN IOTCT_SERVICIO SER
                  ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
               WHERE (PLN.PLNN_TMCOD = PI_PLAN OR PLN.PLNN_POID = PI_PLAN_POID)
                 AND SERVV_NOMBRE = V_NOM_SERVICIO;
              RETURN;
            ELSE
              V_FLAG_PAGA :='T';
            END IF;
       ELSE
          V_FLAG_PAGA :='T';
       END IF;
    ELSE
      SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
        INTO PO_PRODUCTID, PO_PRODUCTID_NOM
        FROM IOTCT_SERVICIO S
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND S.SERVV_TIPO = C_AMCO_BONO;
      RETURN;
     END IF;
   ELSE
       V_FLAG_PAGA :='T';
   END IF;

   IF V_FLAG_PAGA = 'T' THEN
      SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
        INTO PO_PRODUCTID, PO_PRODUCTID_NOM
        FROM IOTCT_SERVICIO S
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND S.SERVV_TIPO = C_AMCO_PAGA;
    END IF;
 EXCEPTION
   WHEN OTHERS THEN
     PO_CODRPTA := '-1';
     PO_MSJRPTA := 'Error ' || SQLCODE || ' : ' || SQLERRM;
 END IOTSS_VALIDAR_PRODUCTID_PLAN;

/****************************************************************
  * Nombre SP          : IOTSS_VALIDAR_PRODUCTID_CABLE
  * Proposito          : SP que valida el productid antes de adquirir un servicio
  *                      de claro video.
  *
  * Input              :  PI_PLAN             - CÃ³digo de plan del cliente
  *                       PI_LINEA            - Linea Fija o Movil del cliente.
  *                       PI_PRODUCTID        - Id Generico que envia Amco.
  *
  * Output             :  PO_PRODUCTID         - Id del producto que le pertenece al cliente
  *                                               segun su plan o si tuvo servicios.
  *                       PO_PRODUCTID_NOM     - Nombre del servicio
  *                       PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                       PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  * Creado por         : Fallas N3
  * Actualizado por    :
  * Fec Creacion       : 23/03/2022
  ***************************************************************/
PROCEDURE IOTSS_VALIDAR_PRODUCTID_CABLE(PI_PLAN         IN IOTCT_PLANES.PLNN_TMCOD%TYPE,
                                        PI_PLAN_POID   IN VARCHAR2,
                                        PI_LINEA         IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                        PI_PRODUCTID     IN IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PO_PRODUCTID     OUT IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PO_PRODUCTID_NOM OUT IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                        PO_CODRPTA       OUT VARCHAR2,
                                        PO_MSJRPTA       OUT VARCHAR2) IS
   V_CONT_SERV          NUMBER := 0;
   V_CONT_PLAN          NUMBER := 0;
   V_CONTADOR_ACTIVO    NUMBER := 0;
   V_CONT_SUSC_CAN      NUMBER := 0;
   V_COUNT_TV           NUMBER := 0;
   V_CONTADOR_HBO           NUMBER := 0;
   V_ESTADO_ACTIVO      CHAR(1) := 'A';
   V_ESTADO_CANCEL      CHAR(1) := 'C';
   V_FLAG_PAGA        CHAR(1) := 'F';


   V_NOM_SERVICIO IOTCT_SERVICIO.SERVV_NOMBRE%TYPE;

   CURSOR C_NOM_SERVICIO(C_SERVICIO VARCHAR2) IS
     SELECT SE.SERVV_NOMBRE
       FROM IOTCT_SERVICIO SE
      WHERE SE.SERVN_SERVICEID = C_SERVICIO;

 BEGIN
    PO_CODRPTA := '0';
    PO_MSJRPTA := 'Consulta exitosa';

   SELECT COUNT(1)
     INTO V_CONT_SERV
     FROM IOTCT_SERVICIO S
    WHERE S.SERVN_SERVICEID = PI_PRODUCTID
      AND S.SERVV_TIPO IN (C_AMCO_BONO, C_AMCO_PAGA);

   IF V_CONT_SERV = 0 THEN
     PO_CODRPTA := '1';
     PO_MSJRPTA := 'Servicio no configurado';
     RETURN;
   END IF;

     --Obtener el servicio
     OPEN C_NOM_SERVICIO(PI_PRODUCTID);
     FETCH C_NOM_SERVICIO
       INTO V_NOM_SERVICIO;
     CLOSE C_NOM_SERVICIO;

     --Validar si cuenta con el servicio activo.
     SELECT COUNT(1)
       INTO V_CONTADOR_ACTIVO
       FROM IOTT_SUSCRIPCION SU
       JOIN IOTCT_SERVICIO S
         ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
      WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
        AND SU.SUSV_LINEA = PI_LINEA
        AND SU.SUSC_ESTADO = V_ESTADO_ACTIVO;

     IF V_CONTADOR_ACTIVO > 0 THEN
       PO_CODRPTA := '2';
       PO_MSJRPTA := 'El cliente ya cuenta con el servicio activo';
       RETURN;
     END IF;

   ---
    IF (V_NOM_SERVICIO = 'HBO')THEN
  SELECT COUNT(1)
       INTO V_CONTADOR_HBO
       FROM IOTT_SUSCRIPCION SU
       JOIN IOTCT_SERVICIO S
         ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
      WHERE S.SERVV_NOMBRE ='CLARO VIDEO'
        AND SU.SUSV_LINEA = PI_LINEA
        AND SU.SUSC_ESTADO = V_ESTADO_ACTIVO;


     IF V_CONTADOR_HBO = 0 THEN
    --Validar si cuenta con servicios cancelados
    SELECT COUNT(1)
      INTO V_CONT_SUSC_CAN
      FROM IOTCT_SERVICIO S
      JOIN IOTT_SUSCRIPCION SU
      ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
     WHERE S.SERVV_NOMBRE !='HBO'
      AND S.SERVV_NOMBRE = V_NOM_SERVICIO
       AND SU.SUSV_LINEA = PI_LINEA
       AND SU.SUSC_ESTADO = V_ESTADO_CANCEL;

       ELSE


   IF (V_CONT_SUSC_CAN = 0) AND (PI_PRODUCTID NOT IN (140001001,130001001)) THEN
     IF V_NOM_SERVICIO = 'CLARO VIDEO' THEN
       SELECT COUNT(1)
         INTO V_CONT_PLAN
         FROM IOTCT_PLANES P
         JOIN IOTCT_SERVICIO S
           ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
        WHERE (P.PLNN_TMCOD = PI_PLAN OR P.PLNN_POID = PI_PLAN_POID)
          AND S.SERVV_NOMBRE = V_NOM_SERVICIO
          AND S.SERVV_TIPO = C_AMCO_BONO;

        IF V_CONT_PLAN > 0 THEN
         SELECT DISTINCT S.SERVN_SERVICEID, S.SERVV_NOMBRE
           INTO PO_PRODUCTID, PO_PRODUCTID_NOM
           FROM IOTCT_PLANES P
           JOIN IOTCT_SERVICIO S
             ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
          WHERE (P.PLNN_TMCOD = PI_PLAN OR P.PLNN_POID = PI_PLAN_POID)
            AND S.SERVV_NOMBRE = V_NOM_SERVICIO
            AND S.SERVV_TIPO = C_AMCO_BONO;
         RETURN;
        ELSE
          SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
            INTO PO_PRODUCTID, PO_PRODUCTID_NOM
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
             AND S.SERVV_TIPO = C_AMCO_BONO
             AND S.SERVN_SERVICEID = 10000030;
          RETURN;
        END IF;
     ELSIF PI_PRODUCTID = 110001001 THEN
       IF (LENGTH(TRIM(PI_LINEA)) > 9) THEN
         SELECT COUNT(1)
           INTO V_COUNT_TV
           FROM IOTCT_PLANES PLN
           LEFT JOIN IOTCT_SERVICIO SER
             ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
          WHERE (PLN.PLNN_TMCOD = PI_PLAN OR PLN.PLNN_POID = PI_PLAN_POID)
            AND SERVV_NOMBRE = V_NOM_SERVICIO;

            IF V_COUNT_TV > 0 THEN
              SELECT DISTINCT SER.SERVN_SERVICEID,SER.SERVV_NOMBRE
                INTO PO_PRODUCTID, PO_PRODUCTID_NOM
                FROM IOTCT_PLANES PLN
                LEFT JOIN IOTCT_SERVICIO SER
                  ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
               WHERE (PLN.PLNN_TMCOD = PI_PLAN OR PLN.PLNN_POID = PI_PLAN_POID)
                 AND SERVV_NOMBRE = V_NOM_SERVICIO;
              RETURN;
            ELSE
              V_FLAG_PAGA :='T';
            END IF;
       ELSE
          V_FLAG_PAGA :='T';
       END IF;
    ELSE
      SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
        INTO PO_PRODUCTID, PO_PRODUCTID_NOM
        FROM IOTCT_SERVICIO S
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND S.SERVV_TIPO = C_AMCO_BONO;
      RETURN;
     END IF;
   ELSE
       V_FLAG_PAGA :='T';
   END IF;
   END IF;

   IF V_FLAG_PAGA = 'T' THEN
      SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
        INTO PO_PRODUCTID, PO_PRODUCTID_NOM
        FROM IOTCT_SERVICIO S
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND S.SERVV_TIPO = C_AMCO_PAGA;
    END IF;
--------
END IF;
   IF (V_CONT_SUSC_CAN = 0) AND (PI_PRODUCTID NOT IN (140001001,130001001)) THEN
     IF V_NOM_SERVICIO = 'CLARO VIDEO' THEN
       SELECT COUNT(1)
         INTO V_CONT_PLAN
         FROM IOTCT_PLANES P
         JOIN IOTCT_SERVICIO S
           ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
        WHERE (P.PLNN_TMCOD = PI_PLAN OR P.PLNN_POID = PI_PLAN_POID)
          AND S.SERVV_NOMBRE = V_NOM_SERVICIO
          AND S.SERVV_TIPO = C_AMCO_BONO;

        IF V_CONT_PLAN > 0 THEN
         SELECT DISTINCT S.SERVN_SERVICEID, S.SERVV_NOMBRE
           INTO PO_PRODUCTID, PO_PRODUCTID_NOM
           FROM IOTCT_PLANES P
           JOIN IOTCT_SERVICIO S
             ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
          WHERE (P.PLNN_TMCOD = PI_PLAN OR P.PLNN_POID = PI_PLAN_POID)
            AND S.SERVV_NOMBRE = V_NOM_SERVICIO
            AND S.SERVV_TIPO = C_AMCO_BONO;
         RETURN;
        ELSE
          SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
            INTO PO_PRODUCTID, PO_PRODUCTID_NOM
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
             AND S.SERVV_TIPO = C_AMCO_BONO
             AND S.SERVN_SERVICEID = 10000030;
          RETURN;
        END IF;
     ELSIF PI_PRODUCTID = 110001001 THEN
       IF (LENGTH(TRIM(PI_LINEA)) > 9) THEN
         SELECT COUNT(1)
           INTO V_COUNT_TV
           FROM IOTCT_PLANES PLN
           LEFT JOIN IOTCT_SERVICIO SER
             ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
          WHERE (PLN.PLNN_TMCOD = PI_PLAN OR PLN.PLNN_POID = PI_PLAN_POID)
            AND SERVV_NOMBRE = V_NOM_SERVICIO;

            IF V_COUNT_TV > 0 THEN
              SELECT DISTINCT SER.SERVN_SERVICEID,SER.SERVV_NOMBRE
                INTO PO_PRODUCTID, PO_PRODUCTID_NOM
                FROM IOTCT_PLANES PLN
                LEFT JOIN IOTCT_SERVICIO SER
                  ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
               WHERE (PLN.PLNN_TMCOD = PI_PLAN OR PLN.PLNN_POID = PI_PLAN_POID)
                 AND SERVV_NOMBRE = V_NOM_SERVICIO;
              RETURN;
            ELSE
              V_FLAG_PAGA :='T';
            END IF;
       ELSE
          V_FLAG_PAGA :='T';
       END IF;
    ELSE
      SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
        INTO PO_PRODUCTID, PO_PRODUCTID_NOM
        FROM IOTCT_SERVICIO S
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND S.SERVV_TIPO = C_AMCO_BONO;
      RETURN;
     END IF;
   ELSE
       V_FLAG_PAGA :='T';
   END IF;

   IF V_FLAG_PAGA = 'T' THEN
      SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
        INTO PO_PRODUCTID, PO_PRODUCTID_NOM
        FROM IOTCT_SERVICIO S
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND S.SERVV_TIPO = C_AMCO_PAGA;
    END IF;
 EXCEPTION
   WHEN OTHERS THEN
     PO_CODRPTA := '-1';
     PO_MSJRPTA := 'Error ' || SQLCODE || ' : ' || SQLERRM;
 END IOTSS_VALIDAR_PRODUCTID_CABLE;

  /****************************************************************
  * Nombre SP          : IOTSS_OBTENER_DATOS_PRODUCTID
  * Proposito          : SP que obtiene el precio,el tipo de servicio,nombre de servicio
  *                      y el sncode configurable en iot.
  *
  * Input              : PI_PRODUCT_ID        -  Id del producto de los servicios de claro video.
  *                      PI_TIPO_LINEA        - Flag de tipo de linea (M:MÃ³vil,F:Fija).
  *
  * Output             :  PO_NOMBRE_SERV         - Nombre del servicio
  *                       PO_TIPO_SERV           - Tipo de Servicio(Bono/Paga)
  *                       PO_PRECIO              - Precio del servicio a activar
  *                       PO_SERVICEID_BSCS      - Sncode configurable en iot.
  *                       PO_CODRPTA             - Indica si el procedure termino exitosamente o no.
  *                       PO_MSJRPTA             - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 30/01/2020
  * Fec Actualizacion  :  29/05/2020 - Modificar el precio quitando IGV.
  ***************************************************************/
PROCEDURE IOTSS_OBTENER_DATOS_PRODUCTID (PI_PRODUCT_ID       IN  IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                         PI_TIPO_LINEA       IN  VARCHAR2,
                                         PO_NOMBRE_SERV      OUT IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                         PO_TIPO_SERV        OUT IOTCT_SERVICIO.SERVV_TIPO%TYPE,
                                         PO_PRECIO           OUT IOTCT_SERVICIO.SERVD_PRECIO%TYPE,
                                         PO_SERVICEID_BSCS   OUT IOTCT_SERVICIO.SERVV_SERVICEID_BSCS_M%TYPE,
                                         PO_CODRPTA          OUT VARCHAR2,
                                         PO_MSJRPTA          OUT VARCHAR2)IS

 V_CONTADOR NUMBER:=0;
 V_IGV                                   NUMBER:=1.18;
 BEGIN

  IF PI_PRODUCT_ID IS NULL THEN
    PO_CODRPTA := '1';
    PO_MSJRPTA := 'Debe ingresar el codigo de producto';
    RETURN;
  END IF;

  IF PI_TIPO_LINEA IS NULL THEN
    PO_CODRPTA := '1';
    PO_MSJRPTA := 'Debe ingresar el flag tipo de linea';
    RETURN;
  END IF;

  SELECT COUNT(1)
    INTO V_CONTADOR
    FROM IOTCT_SERVICIO S
   WHERE S.SERVN_SERVICEID = PI_PRODUCT_ID;

    IF V_CONTADOR > 0 THEN
      SELECT S.SERVV_NOMBRE,
              S.SERVV_TIPO,
            (CASE UPPER(PI_TIPO_LINEA)
               WHEN 'M' THEN
                ROUND(S.SERVD_PRECIO/V_IGV,2)
               WHEN 'F' THEN
                ROUND(S.SERVD_PRECIO/V_IGV,2)
               WHEN 'MO' THEN
                ROUND(S.SERVD_PRECIO,2)
               WHEN 'FO' THEN
                ROUND(S.SERVD_PRECIO/V_IGV,2)
               ELSE
                NULL
             END),
             (CASE UPPER(PI_TIPO_LINEA)
               WHEN 'M' THEN
                S.SERVV_SERVICEID_BSCS_M
               WHEN 'F' THEN
                S.SERVV_SERVICEID_BSCS_F
               WHEN 'MO' THEN
                S.SERVV_SERVICEID_BSCS_MO
               WHEN 'FO' THEN
                S.SERVV_SERVICEID_BSCS_FO
               ELSE
                NULL
             END)
        INTO PO_NOMBRE_SERV,
             PO_TIPO_SERV,
             PO_PRECIO,
             PO_SERVICEID_BSCS
        FROM IOTCT_SERVICIO S
       WHERE S.SERVN_SERVICEID = PI_PRODUCT_ID;

       PO_CODRPTA := '0';
       PO_MSJRPTA := 'Operacion exitosa';
    ELSE
      PO_CODRPTA := '2';
      PO_MSJRPTA := 'El producto no se encuentra configurado';
    END IF;
 EXCEPTION
   WHEN OTHERS THEN
     PO_CODRPTA := '-1';
     PO_MSJRPTA := 'Error ' || SQLCODE || ' : ' || SQLERRM;
 END IOTSS_OBTENER_DATOS_PRODUCTID;
  /****************************************************************
  * Nombre SP          : IOTSS_VALIDAR_PRODUCTID_PRE
  * Proposito          : SP que valida que product id se le asignara a una linea prepago.
  *
  * Input              : PI_LINEA        -  Linea Prepago.
  *                      PI_PRODUCTOID   -  Id del producto de los servicios de claro video.
  *
  * Output             : PO_PRODUCTID           - Id del producto para activar servicios claro video
  *                      PO_PRODUCTID_TIPO      - Tipo de servicio(Bono/Paga)
  *                      PO_PRODUCTID_NOM       - Nombre del servicio
  *                      PO_CODRPTA             - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA             - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 30/01/2020
  * Fec Actualizacion  : 27/02/2020 - Cambio por el codigo de productid
  ***************************************************************/
  PROCEDURE IOTSS_VALIDAR_PRODUCTID_PRE(PI_LINEA          IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                        PI_PRODUCTOID     IN IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                        PO_PRODUCTID      OUT IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PO_PRODUCTID_TIPO OUT IOTCT_SERVICIO.SERVV_TIPO%TYPE,
                                        PO_PRODUCTID_NOM  OUT IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                        PO_CODRPTA        OUT VARCHAR2,
                                        PO_MSJRPTA        OUT VARCHAR2) IS

    V_CONTADOR      NUMBER  := 0;
    V_COUNT_ACTIVOS NUMBER  := 0;
    V_ESTADO_ACTIVO CHAR(1) := 'A';
    V_NOM_CLARO     IOTCT_SERVICIO.SERVV_NOMBRE%TYPE := 'CLARO VIDEO';
    V_NOM_SERVICIO  IOTCT_SERVICIO.SERVV_NOMBRE%TYPE;
    V_CONT_PREPAGO  NUMBER  := 0;
    V_CONT_SOLO_PAGA NUMBER := 0;
    V_CONT_EXLC_PROD NUMBER := 0;    

    CURSOR C_NOM_SERVICIO(C_SERVICIO VARCHAR2) IS
    SELECT SE.SERVV_NOMBRE
    FROM IOTCT_SERVICIO SE
    WHERE SE.SERVN_SERVICEID = C_SERVICIO;

  BEGIN

    OPEN C_NOM_SERVICIO(PI_PRODUCTOID);
    FETCH C_NOM_SERVICIO INTO V_NOM_SERVICIO;
    CLOSE C_NOM_SERVICIO;

    SELECT COUNT(1)
    INTO V_CONTADOR
    FROM IOTCT_SERVICIO S
    WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO;

    IF V_CONTADOR > 0 THEN

      SELECT COUNT(1)
       INTO V_COUNT_ACTIVOS
       FROM IOTT_SUSCRIPCION SU
       JOIN IOTCT_SERVICIO S
         ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
      WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
        AND SU.SUSV_LINEA = PI_LINEA
        AND UPPER(SU.SUSC_ESTADO) = V_ESTADO_ACTIVO;

      IF V_COUNT_ACTIVOS > 0 THEN
        PO_CODRPTA := '2';
        PO_MSJRPTA := 'El cliente ya cuenta con el servicio activo';
        RETURN;
      END IF;
      
      -- Validar exclusion de producto por tipo de linea

    SELECT COUNT(1)
               INTO V_CONT_EXLC_PROD
           FROM IOT.IOTT_CONFIGURACION C
           WHERE C.CONFV_SERVICIO = 'PROD_EXCL_X_TIPOLINEA'
                 AND C.CONFV_VALOR1 = PI_PRODUCTOID
                 AND C.CONFV_VALOR2 = 'A'
         AND C.CONFV_VALOR3 = 'PREPAGO';

    IF V_CONT_EXLC_PROD > 0 then
      PO_CODRPTA := '3';
      PO_MSJRPTA := 'El cliente no es elegible para el servicio';
      RETURN;
    END IF;
    
    --

      SELECT COUNT(1)
          INTO V_CONTADOR
          FROM IOTCT_SERVICIO S
          JOIN IOTT_SUSCRIPCION SU
            ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
         WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
           AND SU.SUSV_LINEA = PI_LINEA
           AND SU.SUSC_ESTADO = 'C';

      SELECT COUNT(1)
             INTO V_CONT_SOLO_PAGA
             FROM IOT.IOTT_CONFIGURACION C
             WHERE C.CONFV_SERVICIO='SP_PRE'
                  AND C.CONFV_VALOR1=PI_PRODUCTOID
                  AND C.CONFV_VALOR2='A';

      IF V_CONTADOR = 0 THEN
        IF V_NOM_SERVICIO = V_NOM_CLARO THEN

           SELECT COUNT(1)
             INTO V_CONT_PREPAGO
             FROM IOTCT_SERVICIO S
            WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
              AND S.SERVV_TIPO = C_AMCO_BONO
              AND S.SERVN_SERVICEID = 10000030;

           IF V_CONT_PREPAGO = 0 THEN
             PO_CODRPTA := '3';
             PO_MSJRPTA := 'No se pudo obtener producto prepago';
            RETURN;
           END IF;

          SELECT S.SERVN_SERVICEID, S.SERVV_TIPO, S.SERVV_NOMBRE
            INTO PO_PRODUCTID, PO_PRODUCTID_TIPO, PO_PRODUCTID_NOM
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
             AND S.SERVV_TIPO = C_AMCO_BONO
             AND S.SERVN_SERVICEID = 10000030;

            PO_CODRPTA := '0';
            PO_MSJRPTA := 'Consulta exitosa';

       ELSIF (V_CONT_SOLO_PAGA > 0) THEN
          BEGIN
            SELECT SERVN_SERVICEID,SERVV_TIPO,SERVV_NOMBRE
              INTO PO_PRODUCTID,PO_PRODUCTID_TIPO,PO_PRODUCTID_NOM
              FROM IOTCT_SERVICIO
             WHERE SERVN_SERVICEID = PI_PRODUCTOID
               AND SERVV_TIPO = 'PAGA';

              PO_CODRPTA:='0';
              PO_MSJRPTA:='Consulta exitosa';
           END;

       ELSE
          SELECT COUNT(1)
            INTO V_CONT_PREPAGO
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
             AND S.SERVV_TIPO = C_AMCO_BONO;

            IF V_CONT_PREPAGO = 0 THEN
              PO_CODRPTA := '3';
              PO_MSJRPTA := 'No se pudo obtener el producto addon';
            RETURN;
           END IF;

          SELECT S.SERVN_SERVICEID, S.SERVV_TIPO, S.SERVV_NOMBRE
            INTO PO_PRODUCTID, PO_PRODUCTID_TIPO, PO_PRODUCTID_NOM
            FROM IOTCT_SERVICIO S
           WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
             AND S.SERVV_TIPO = C_AMCO_BONO;

            PO_CODRPTA := '0';
            PO_MSJRPTA := 'Consulta exitosa';

        END IF;
      ELSE
        SELECT S.SERVN_SERVICEID, S.SERVV_TIPO, S.SERVV_NOMBRE
          INTO PO_PRODUCTID, PO_PRODUCTID_TIPO, PO_PRODUCTID_NOM
          FROM IOTCT_SERVICIO S
         WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
           AND S.SERVV_TIPO = C_AMCO_PAGA;

        PO_CODRPTA := '0';
        PO_MSJRPTA := 'Consulta exitosa';
      END IF;
    ELSE
      PO_CODRPTA := '1';
      PO_MSJRPTA := 'Producto no configurado';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error al consultar los productos => ' || sqlerrm;
  END IOTSS_VALIDAR_PRODUCTID_PRE;
 /****************************************************************
  * Nombre SP          : IOTSS_VALIDAR_PRODUCTID_FIJA
  * Proposito          : SP que valida el productId y te brina servicio de TV en VIVO de acuerdo a tu plan.
  *
  * Input              : PI_LINEA        -  Linea Prepago.
  *                      PI_PRODUCTOID   -  Id del producto de los servicios de claro video.
  *                      PI_PLAN         -  Tmcode del cliente Fija o Movil.
  * Output             : PO_CURSOR       -  Listado de Servicios de claro video.
  *                      @PO_PRODUCTID   -  Product id.
  *                      @PO_PRODUCTID_TIPO - Tipo de producto
  *                      @PO_PRODUCTID_NOM  - Nombre del producto.
  *                      PO_CODRPTA             - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA             - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    : jaraco
  * Fec Creacion       : 24/03/2020
  * Fec Actualizacion  : 25/06/2020 - Validar el productid para clientes fijos segun su plan
  ***************************************************************/
 PROCEDURE IOTSS_VALIDAR_PRODUCTID_FIJA(PI_LINEA          IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                        PI_PRODUCTOID     IN IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PI_PLAN           IN IOTCT_PLANES.PLNN_TMCOD%TYPE,
                                        PO_CURSOR          OUT C_REF_CURSOR,
                                        PO_CODRPTA        OUT NUMBER,
                                        PO_MSJRPTA        OUT VARCHAR2)IS


 V_COUNT_PLANES                         NUMBER(10):=0;
 V_COUNT_SERV                           NUMBER(10):=0;
 V_COUNT_ACTIVO                         NUMBER(10):=0;
 V_COUNT_CANCEL                         NUMBER(10):=0;
 V_COUNT_TV                             NUMBER(10):=0;
 V_FLAG_PAGA                            CHAR(1) := 'F';

 V_NOM_SERVICIO                         IOTCT_SERVICIO.SERVV_NOMBRE%TYPE;
 V_CONT_SOLO_PAGA                       NUMBER:= 0;
 V_CONT_EXLC_PROD                       NUMBER:= 0;

 CURSOR c_nom_servicio (C_SERVICIO  VARCHAR2)IS
 SELECT SE.SERVV_NOMBRE FROM IOTCT_SERVICIO SE
 WHERE SE.SERVN_SERVICEID = C_SERVICIO;

 BEGIN
    PO_CODRPTA := 0;
    PO_MSJRPTA := 'Consulta Exitosa';

   SELECT COUNT(1)
     INTO V_COUNT_SERV
     FROM IOTCT_SERVICIO SER
    WHERE SER.SERVN_SERVICEID = PI_PRODUCTOID
      AND SER.SERVV_TIPO IN (C_AMCO_BONO, C_AMCO_PAGA);

   IF V_COUNT_SERV = 0 THEN
     PO_CODRPTA := 1;
     PO_MSJRPTA := 'Servicio no configurado';
     RETURN;
   END IF;  

   OPEN C_NOM_SERVICIO(PI_PRODUCTOID);
   FETCH C_NOM_SERVICIO INTO V_NOM_SERVICIO;
   CLOSE C_NOM_SERVICIO;

   SELECT COUNT(1)
     INTO V_COUNT_ACTIVO
     FROM IOTT_SUSCRIPCION SU
     JOIN IOTCT_SERVICIO S
       ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
    WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
      AND SU.SUSV_LINEA = PI_LINEA
      AND SU.SUSC_ESTADO = C_AMCO_ACTI;

    SELECT COUNT(1)
           INTO V_CONT_SOLO_PAGA
             FROM IOT.IOTT_CONFIGURACION C
             WHERE C.CONFV_SERVICIO='SP_FIJA'
                  AND C.CONFV_VALOR1=PI_PRODUCTOID
                  AND C.CONFV_VALOR2='A';

      IF V_COUNT_ACTIVO > 0 THEN
         PO_CODRPTA:='2';
         PO_MSJRPTA:='El cliente ya cuenta con el servicio activo';
         RETURN;
      END IF;
      
      -- Validar exclusion de producto por tipo de linea

    SELECT COUNT(1)
               INTO V_CONT_EXLC_PROD
           FROM IOT.IOTT_CONFIGURACION C
           WHERE C.CONFV_SERVICIO = 'PROD_EXCL_X_TIPOLINEA'
                 AND C.CONFV_VALOR1 = PI_PRODUCTOID
                 AND C.CONFV_VALOR2 = 'A'
         AND C.CONFV_VALOR3 = C_AMCO_FIJA;

    IF V_CONT_EXLC_PROD > 0 then
      PO_CODRPTA := '3';
            PO_MSJRPTA := 'El cliente no es elegible para el servicio';
      RETURN;
    END IF;
    
    --

      SELECT COUNT(1)
        INTO V_COUNT_CANCEL
        FROM IOTCT_SERVICIO S
        JOIN IOTT_SUSCRIPCION SU
          ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND SU.SUSV_LINEA = PI_LINEA
         AND SU.SUSC_ESTADO = C_AMCO_CANC;

         IF V_COUNT_CANCEL = 0 THEN
           IF V_NOM_SERVICIO = 'CLARO VIDEO' THEN

             SELECT COUNT(1)
               INTO V_COUNT_PLANES
               FROM IOTCT_PLANES PLN
               JOIN IOTCT_SERVICIO SER
                 ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
              WHERE PLN.PLNN_TMCOD = PI_PLAN;

              IF V_COUNT_PLANES > 0 THEN
                OPEN PO_CURSOR FOR
                  SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                         SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                         SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                    FROM IOTCT_PLANES PLN
                    JOIN IOTCT_SERVICIO SER
                      ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
                   WHERE PLN.PLNN_TMCOD = PI_PLAN
                     AND SERVV_TIPO = C_AMCO_BONO;
                 RETURN;
              ELSE
                OPEN PO_CURSOR FOR
                      SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                             SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                             SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                        FROM IOTCT_SERVICIO SER
                        WHERE SER.SERVV_NOMBRE = V_NOM_SERVICIO
                        AND SER.SERVN_SERVICEID = 10000030
                        AND SERVV_TIPO = C_AMCO_BONO;
                 RETURN;
              END IF;
           ELSIF (V_CONT_SOLO_PAGA > 0) THEN
                 V_FLAG_PAGA := 'T';
           ELSIF PI_PRODUCTOID = 110001001 THEN
              SELECT COUNT(1)
                INTO V_COUNT_TV
                FROM IOTCT_PLANES PLN
                JOIN IOTCT_SERVICIO SER
                  ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
               WHERE PLN.PLNN_TMCOD = PI_PLAN
                 AND SER.SERVV_NOMBRE = V_NOM_SERVICIO;

                IF V_COUNT_TV > 0  THEN
                    OPEN PO_CURSOR FOR
                       SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                              SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                              SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                         FROM IOTCT_PLANES PLN
                         JOIN IOTCT_SERVICIO SER
                           ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
                        WHERE PLN.PLNN_TMCOD = PI_PLAN
                          AND SER.SERVV_NOMBRE = V_NOM_SERVICIO;
                   RETURN;
                 ELSE
                   V_FLAG_PAGA :='T';
                 END IF;
           ELSE
               OPEN PO_CURSOR FOR
                 SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                        SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                        SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                   FROM IOTCT_SERVICIO SER
                  WHERE SER.SERVV_NOMBRE = V_NOM_SERVICIO
                    AND SERVV_TIPO = C_AMCO_BONO;
              RETURN;
           END IF;
    ELSE
      V_FLAG_PAGA:='T';
    END IF;
    IF V_FLAG_PAGA = 'T' THEN
      OPEN PO_CURSOR FOR
        SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
               SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
               SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
          FROM IOTCT_SERVICIO SER
         WHERE SER.SERVV_NOMBRE = V_NOM_SERVICIO
           AND SERVV_TIPO = C_AMCO_PAGA;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := -1;
      PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_VALIDAR_PRODUCTID_FIJA;


  /****************************************************************
  * Nombre SP          : IOTSS_CONSULTAR_REQUEST_CV
  * Proposito          : SP que sirve para obtener la lista de lÃ­neas postpago(MÃ³vil/Fija) y Prepago
  *                      que han realizado un Bloqueo Cobro/fraude y PortOut
  * Input              : PI_FECHA  - Fecha de ejecuciÃ³n del proceso.
  * Output             :  PO_CURSOR
  *                       @ID_TRANSAC - ID DE TRANSACCION,
  *                       @REQUEST    - Request,
  *                       @STATUS     - Estado de Registro,
  *                       @CO_ID      - codigo de contrato,
  *                       @INSERT_DATE - fecha de ejecuciÃ³n,
  *                       @ACTION_ID   - AcciÃ³n ejecutada,
  *                       @LINEA       - linea Movil o Fija,
  *                       @CUSTOMERID  - Codigo del Cliente,
  *                       @TIPO_BLOQ   - Tipo de Bloqueo,
  *                       @TIPO_LINEA  - Tipo de Linea,
  *                       @FLAG_PROCESO - Flag de proceso de registro
  *                      PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         : mcordero
  * Actualizado por    :
  * Fec Creacion       : 07/04/2020
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSS_CONSULTAR_REQUEST_CV  (PI_FECHA          IN IOTT_REQUEST_FIN_CV.IOTD_INSERT_DATE%TYPE,
                                       PI_FLAG_PROCESO IN IOTT_REQUEST_FIN_CV.IOTC_FLAG_PROCESO%TYPE,
                                       PO_CURSOR       OUT C_REF_CURSOR,
                                       PO_CODRPTA      OUT VARCHAR2,
                                       PO_MSJRPTA      OUT VARCHAR2)
IS
V_COUNT              NUMBER;


  BEGIN
       SELECT COUNT(1) INTO V_COUNT FROM IOTT_REQUEST_FIN_CV
                                    WHERE TRUNC (IOTD_INSERT_DATE) = PI_FECHA AND
                                          IOTC_FLAG_PROCESO = PI_FLAG_PROCESO;

       IF (V_COUNT > 0) THEN

            OPEN PO_CURSOR FOR
            SELECT IOTV_ID_TRANSAC AS ID_TRANSAC,
                   IOTN_REQUEST    AS REQUEST,
                   IOTV_STATUS     AS STATUS,
                   IOTI_CO_ID      AS CO_ID,
                   IOTD_INSERT_DATE AS INSERT_DATE,
                   IOTI_ACTION_ID   AS ACTION_ID,
                   IOTV_LINEA       AS LINEA,
                   IOTV_CUSTOMERID  AS CUSTOMERID,
                   IOTV_TIPO_BLOQ   AS TIPO_BLOQ,
                   IOTC_TIPO_LINEA  AS TIPO_LINEA,
                   IOTC_FLAG_PROCESO AS FLAG_PROCESO
                   FROM IOTT_REQUEST_FIN_CV
                            WHERE TRUNC (IOTD_INSERT_DATE)    = PI_FECHA OR
                                  IOTC_FLAG_PROCESO           = PI_FLAG_PROCESO;

            PO_CODRPTA  := '0';
            PO_MSJRPTA := 'Operacion Exitosa';

       ELSE
      OPEN PO_CURSOR FOR

            SELECT NULL AS ID_TRANSAC,
                   NULL AS REQUEST,
                   NULL AS STATUS,
                   NULL AS CO_ID,
                   NULL AS INSERT_DATE,
                   NULL AS ACTION_ID,
                   NULL AS LINEA,
                   NULL AS CUSTOMERID,
                   NULL AS TIPO_BLOQ,
                   NULL AS TIPO_LINEA,
                   NULL AS FLAG_PROCESO
            FROM DUAL
             WHERE ROWNUM = 0;
            PO_CODRPTA  := '1';
            PO_MSJRPTA := 'No se encontro registros ';


      END IF;


  EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA  := '-1';
      PO_MSJRPTA := 'ERROR DE ORACLE: ' || to_char(SQLCODE) || ': ' ||
                              SQLERRM;


END IOTSS_CONSULTAR_REQUEST_CV;


/****************************************************************
  * Nombre SP          : IOTSS_CARGAR_ESTAD_LINEAS
  * Proposito          : SP que sirve para obtener los datos de las lineas que han
  *                      realizado un Bloqueo Cobro/fraude y PortOut.
  * Input              : PI_LINEA  - Linea en consulta.
  *                      PI_CUSTOMERID - CustomerID
  *                      PI_TIP_LINEA  - Tipo de LÃ­nea
  *                      PI_TIPO_BLOQ  - Tipo de Bloqueo
  * Output             :  PO_CURSOR
  *                       @USUARIO    - ID de Usuario de Claro Video,
  *                       @LINEA      - LÃ­nea / Token(Fija)
  *                       @ESTADO     - Estado de Usuario,
  *                       @CORREO     - Correo del usuario,
  *                       @PRODUCTID  - Id Producto,
  *                       @NOMBRE     - Nombre del servicio,
  *                       @ESTADO_SUSCRC   - Estado de la SuscripciÃ³n,
  *                       @FLAG_SERVICIO   - Cuenta con servicios Activos -> Si / NO,
  *                      PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         : mcordero
  * Actualizado por    :
  * Fec Creacion       : 07/04/2020
  * Fec Actualizacion  : 17/08/2020
  * Motivo cambio      :
***************************************************************/
  PROCEDURE IOTSS_CARGAR_ESTAD_LINEAS  ( PI_LINEA        IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                         PI_CUSTOMERID   IN IOTT_SUSCRIPCION.SUSV_CUSTOMERID%TYPE,
                                         PI_TIP_LINEA    IN IOTT_SUSCRIPCION.SUSV_TIPO_LINEA%TYPE,
                                         PI_TIPO_BLOQ    IN IOTT_REQUEST_FIN_CV.IOTV_TIPO_BLOQ%TYPE,
                                         PO_CURSOR       OUT C_REF_CURSOR,
                                         PO_CODRPTA      OUT VARCHAR2,
                                         PO_MSJRPTA      OUT VARCHAR2)

  IS
  V_COUNT_SUSC           NUMBER:=0;
  V_BLOQ_FRA             VARCHAR(20):='BLOQ_FRAU';     --- A Y S
  V_BLOQ_COB             VARCHAR(20):='BLOQ_COB';      --- A Y S
  V_PORT_OUT             VARCHAR(20):='PORT_OUT';      --- A Y S
  V_BLOQ_SUSP            VARCHAR(20):='BLOQ_SUSP';     --- A

  BEGIN

  IF PI_TIP_LINEA ='M' THEN
    SELECT COUNT(1) INTO V_COUNT_SUSC
                 FROM IOTT_SUSCRIPCION S,
                      IOTT_CLIENTE C
                 WHERE C.CLIN_USUARIOID = S.SUSN_USUARIOID AND
                      S.SUSV_LINEA =PI_LINEA;

  ELSE
     SELECT COUNT(1) INTO V_COUNT_SUSC
               FROM IOTT_SUSCRIPCION S,
                    IOTT_CLIENTE C
               WHERE C.CLIN_USUARIOID = S.SUSN_USUARIOID AND
                     S.SUSV_CUSTOMERID= PI_CUSTOMERID;
  END IF;

   IF V_COUNT_SUSC > 0 THEN

        IF ( PI_TIPO_BLOQ = V_BLOQ_FRA OR PI_TIPO_BLOQ = V_BLOQ_COB OR PI_TIPO_BLOQ = V_PORT_OUT ) THEN

           OPEN PO_CURSOR FOR
           SELECT S.SUSN_USUARIOID            AS USUARIOID,
                  S.SUSV_LINEA                AS LINEA,
                  C.CLIC_ESTADO               AS ESTADO_USUARIO,
                  C.CLIV_CORREO               AS CORREO,
                  S.SUSN_SERVICIOID           AS PRODUCTID,
                  P.SERVV_NOMBRE              AS NOMBRE,
                  S.SUSC_ESTADO               AS ESTADO_SUSCRC,
                  'SI'                        AS FLAG_SERVICIO

            FROM IOTT_SUSCRIPCION S,
                 IOTT_CLIENTE C ,
                 IOTCT_SERVICIO P
            WHERE C.CLIN_USUARIOID = S.SUSN_USUARIOID AND
                  S.SUSN_SERVICIOID= P.SERVN_SERVICEID AND
                  (S.SUSV_LINEA =PI_LINEA OR S.SUSV_CUSTOMERID= PI_CUSTOMERID) AND
                   S.SUSC_ESTADO     IN ('A','S');

        ELSIF ( PI_TIPO_BLOQ = V_BLOQ_SUSP) THEN -- Suspendidos

           OPEN PO_CURSOR FOR
           SELECT S.SUSN_USUARIOID            AS USUARIOID,
                  S.SUSV_LINEA                AS LINEA,
                  C.CLIC_ESTADO               AS ESTADO_USUARIO,
                  C.CLIV_CORREO               AS CORREO,
                  S.SUSN_SERVICIOID           AS PRODUCTID,
                  P.SERVV_NOMBRE              AS NOMBRE,
                  S.SUSC_ESTADO               AS ESTADO_SUSCRC,
                  'SI'                        AS FLAG_SERVICIO

            FROM IOTT_SUSCRIPCION S,
                 IOTT_CLIENTE C ,
                 IOTCT_SERVICIO P
            WHERE C.CLIN_USUARIOID  = S.SUSN_USUARIOID AND
                  S.SUSN_SERVICIOID = P.SERVN_SERVICEID AND
                  (S.SUSV_LINEA =PI_LINEA OR S.SUSV_CUSTOMERID= PI_CUSTOMERID) AND
                  S.SUSC_ESTADO     = 'A';


        ELSE  --- REACTIVACION
           OPEN PO_CURSOR FOR
           SELECT S.SUSN_USUARIOID            AS USUARIOID,
                  S.SUSV_LINEA                AS LINEA,
                  C.CLIC_ESTADO               AS ESTADO_USUARIO,
                  C.CLIV_CORREO               AS CORREO,
                  S.SUSN_SERVICIOID           AS PRODUCTID,
                  P.SERVV_NOMBRE              AS NOMBRE,
                  S.SUSC_ESTADO               AS ESTADO_SUSCRC,
                  'SI'                        AS FLAG_SERVICIO

            FROM IOTT_SUSCRIPCION S,
                 IOTT_CLIENTE C ,
                 IOTCT_SERVICIO P
            WHERE C.CLIN_USUARIOID  = S.SUSN_USUARIOID AND
                  S.SUSN_SERVICIOID = P.SERVN_SERVICEID AND
                  (S.SUSV_LINEA =PI_LINEA OR S.SUSV_CUSTOMERID= PI_CUSTOMERID) AND
                  S.SUSC_ESTADO     = ('S');


        END IF;

      PO_CODRPTA  := '0';
      PO_MSJRPTA := 'Operacion Exitosa';


 ELSE

    PO_CODRPTA  := '0';
    PO_MSJRPTA := 'No Existen Suscripciones';

END IF;


  EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA  := '-1';
    PO_MSJRPTA := 'ERROR DE ORACLE: ' || to_char(SQLCODE) || ': ' ||
                            SQLERRM;

 END IOTSS_CARGAR_ESTAD_LINEAS;

/****************************************************************
  * Nombre SP          : IOTSU_ACTUALIZAR_REG_MDB
  * Proposito          : SP que actualiza los registros que al culminado
  *                      de forma satisfactoria o Pendiente en culminar el proceso
  *                      de los registrs que han realizado un Bloqueo Cobro/fraude y PortOut.
  * Input              : PI_TRANSACCION_ID  - Id de TransacciÃ³n.
  * Output             :
  *                      PO_FLAG_PROCESO    - Flag de Proceso,
  *                      PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         : mcordero
  * Actualizado por    :
  * Fec Creacion       : 07/04/2020
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSU_ACTUALIZAR_REG_MDB  ( PI_TRANSACCION_ID      IN IOTT_REQUEST_FIN_CV.IOTV_ID_TRANSAC%TYPE,
                                      PI_FLAG_PROCESO        IN IOTT_REQUEST_FIN_CV.IOTC_FLAG_PROCESO%TYPE,
                                      PO_CODRPTA             OUT VARCHAR2,
                                      PO_MSJRPTA             OUT VARCHAR2)
 IS
 BEGIN
    UPDATE IOTT_REQUEST_FIN_CV
           SET   IOTC_FLAG_PROCESO = PI_FLAG_PROCESO
           WHERE IOTV_ID_TRANSAC   = PI_TRANSACCION_ID;

    PO_CODRPTA :='0';
    PO_MSJRPTA :='Operacion exitosa';

  EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA  := '-1';
    PO_MSJRPTA := 'ERROR DE ORACLE: ' || to_char(SQLCODE) || ': ' || SQLERRM;

 END IOTSU_ACTUALIZAR_REG_MDB;

  /****************************************************************
  * Nombre SP          : IOTSS_CONSULTAR_NOMBRE_SERVICIO
  * Proposito          : SP que sirve para obtener el nombre personalizado de los servicios de Claro Video
  * Input              : PI_SERVICIO  - Codigo del Proyecto_Nombre del Proyecto.
  * Input              : PI_IDSUSCRIPCION - Id de Suscripcion
  * Output             : PO_PRODUCTID  - Porduct Id (Bono)
  *                      PO_NOMB_SERV  - Nombre del Porducto
  *                      PO_CODRPTA    - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA    - Indica la descripcion del codigo de respuesta.
  * Creado por         : mcordero
  * Actualizado por    :
  * Fec Creacion       : 10/04/2020
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSS_CONSULTAR_NOMB_SERVICIO  (PI_SERVICIO        IN VARCHAR2,
                                           PI_IDSUSCRIPCION  IN VARCHAR2,
                                           PO_PRODUCTID      OUT NUMBER,
                                           PO_NOMB_SERV      OUT VARCHAR2,
                                           PO_CODRPTA        OUT VARCHAR2,
                                           PO_MSJRPTA        OUT VARCHAR2)
IS
V_COUNT              NUMBER;


  BEGIN
       SELECT COUNT(1) INTO V_COUNT FROM IOTT_CONFIGURACION
                                    WHERE CONFV_SERVICIO = PI_SERVICIO AND
                                          CONFV_VALOR1 = PI_IDSUSCRIPCION;

       IF (V_COUNT > 0) THEN

            SELECT CONFV_DESCRIP,CONFV_VALOR2 INTO PO_NOMB_SERV,PO_PRODUCTID
                   FROM IOTT_CONFIGURACION
                                    WHERE CONFV_SERVICIO = PI_SERVICIO AND
                                          CONFV_VALOR1 = PI_IDSUSCRIPCION AND
                                          ROWNUM = 1;

            PO_CODRPTA  := '0';
            PO_MSJRPTA := 'Operacion Exitosa';

       ELSE

            PO_CODRPTA  := '1';
            PO_MSJRPTA := 'No existe el servicio ';
      END IF;


  EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA  := '-1';
      PO_MSJRPTA := 'ERROR DE ORACLE: ' || to_char(SQLCODE) || ': ' ||
                              SQLERRM;


END IOTSS_CONSULTAR_NOMB_SERVICIO;

/****************************************************************
  * Nombre SP          : IOTSI_REGISTRA_NUMSERIE_STB-IP
  * Proposito          : SP que registra Numero de Serie de los equipos STB-IP asociado a un cliente
  *
  * Input              : PI_CORREO            - Correo del cliente.
  *                      PI_DEVICEID          - Numero Serie del Dispositivo STB-IP
  *
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : Steve Panduro
  * Actualizado por    :
  * Fec Creacion       : 07/02/2020
  * Fec Actualizacion  :
  * Motivo             :
  ***************************************************************/
 procedure IOTSI_REGISTRA_NUMSERIE_STB_IP(pi_correo     iott_cliente.cliv_correo%type,
                                           pi_deviceid   iotct_dispositivo_cliente.disclv_deviceid%type,
                                           lv_nomdisp    iotct_dispositivo_cliente.disclv_nomdisp%type,
                                           lv_tipodisp   iotct_dispositivo_cliente.disclv_tipodisp%type,
                                           po_customerid out iotct_dispositivo_cliente.discln_usuarioid%type,
                                           po_codrpta    out number,
                                           po_msjrpta    out varchar2) is

    ln_disclid              iotct_dispositivo_cliente.discln_disclid%type;
    lv_customer_dispositivo iotct_dispositivo_cliente.discln_disclid%type;
    ln_customerid           iott_cliente.clin_usuarioid%type;
    ln_cant                 number;
    e_error     EXCEPTION;
    e_error_row EXCEPTION;
    v_id number;

   begin
    begin
      select clin_usuarioid
        into ln_customerid
        from iott_cliente
       where UPPER(cliv_correo) = UPPER(pi_correo)
         and CLIC_ESTADO ='A';
    Exception
      WHEN NO_DATA_FOUND THEN
        RAISE e_error;
      WHEN too_many_rows then
        RAISE e_error_row;
    end;

    select count(1)
      into ln_cant
      from iotct_dispositivo_cliente
     where disclv_deviceid = pi_deviceid
       and DISCLC_ESTADO = 'A';

    if ln_cant > 0 then
      select DISCLN_USUARIOID
        into lv_customer_dispositivo
        from iotct_dispositivo_cliente
       where disclv_deviceid = pi_deviceid
         and DISCLC_ESTADO = 'A';

    IF lv_customer_dispositivo = ln_customerid THEN

    po_customerid := ln_customerid;
          po_codrpta    := 0;
          po_msjrpta    := 'Se Registro con Exito el Numero de Serie ' ||
                   pi_deviceid;

        return;

    ELSE

       UPDATE IOTCT_DISPOSITIVO_CLIENTE
         SET DISCLC_ESTADO      = 'D',
             DISCLD_FECHA_DESV  = SYSDATE,
             DISCLV_MODIFI_USER = USER,
             DISCLD_MODIFI_DATE = SYSDATE
       WHERE DISCLN_USUARIOID = lv_customer_dispositivo
         AND DISCLV_DEVICEID = PI_DEVICEID;


    BEGIN
    --GUARDAMOS TRAZABILIDAD

        v_id:=IOT.IOTSEQ_FIJA_TRANSAC.nextval;

    INSERT INTO IOT.IOTCT_FIJA_TRANSAC
      (
        TRANN_ID,
        TRANV_TRANSACCION,
        TRANV_TIPO_TRANSACCION,
        TRANN_USUARIOID,
        TRANV_DEVICEID,
        TRANV_TOKEN,
        TRANC_ESTADO,
        TRANV_MENSAJE,
        TRANV_CREATE_USER,
        TRAND_CREATE_DATE)
       VALUES
       (v_id,
       'TRAZABILIDAD DE ESTADO DECO CLIENTE',
       'REGISTRA_NUMSERIE_STB_IP',
         lv_customer_dispositivo,
         PI_DEVICEID,
         lv_customer_dispositivo||'0;phone-context=claro.pe',
         'D',
         'DesasociaciÃ³n de deco '||PI_DEVICEID||' del cliente '||lv_customer_dispositivo||' para ser asociado a nuevo cliente '||ln_customerid,
         USER,
         SYSDATE
        );

    Exception
     When Others Then
      po_codrpta    := -4;
      po_msjrpta    := 'Error de insercion: ' || Sqlerrm;

    END;

       ln_disclid := iotseq_dispostivos_cliente.nextval;

        insert into iotct_dispositivo_cliente
          (discln_disclid,
           discln_usuarioid,
           disclv_deviceid,
           disclv_nomdisp,
           disclv_tipodisp,
           discld_fecha_act,
           disclc_estado,
           disclv_create_user,
           disclv_create_date)
          values
          (ln_disclid,
           ln_customerid,
           pi_deviceid,
           lv_nomdisp,
           lv_tipodisp,
           sysdate,
           c_amco_acti,
           user,
           sysdate);


    begin

      v_id:=IOT.IOTSEQ_FIJA_TRANSAC.nextval;

    INSERT INTO IOT.IOTCT_FIJA_TRANSAC
      (
        TRANN_ID,
        TRANV_TRANSACCION,
        TRANV_TIPO_TRANSACCION,
        TRANN_USUARIOID,
        TRANV_DEVICEID,
        TRANV_TOKEN,
        TRANC_ESTADO,
        TRANV_MENSAJE,
        TRANV_CREATE_USER,
        TRAND_CREATE_DATE)
       VALUES
       (v_id,
       'TRAZABILIDAD DE ESTADO DECO CLIENTE',
       'REGISTRA_NUMSERIE_STB_IP',
         ln_customerid,
         PI_DEVICEID,
         ln_customerid||'0;phone-context=claro.pe',
         'A',
         'AsociaciÃ³n de deco: '||PI_DEVICEID||' al cliente '||ln_customerid ||' post desasociaciÃ³n del cliente '||lv_customer_dispositivo,
         USER,
         SYSDATE
        );


     Exception
     When Others Then
      po_codrpta    := -4;
      po_msjrpta    := 'Error de insercion: ' || Sqlerrm;

    END;

          po_customerid := ln_customerid;
          po_codrpta    := 0;
          po_msjrpta    := 'Se Registro con Exito el Numero de Serie ' ||
                   pi_deviceid;

     END IF;

    else

      ln_disclid := iotseq_dispostivos_cliente.nextval;

      insert into iotct_dispositivo_cliente
        (discln_disclid,
         discln_usuarioid,
         disclv_deviceid,
         disclv_nomdisp,
         disclv_tipodisp,
         discld_fecha_act,
         disclc_estado,
         disclv_create_user,
         disclv_create_date)
      values
        (ln_disclid,
         ln_customerid,
         pi_deviceid,
         lv_nomdisp,
         lv_tipodisp,
         sysdate,
         c_amco_acti,
         user,
         sysdate);

    begin


      v_id:=IOT.IOTSEQ_FIJA_TRANSAC.nextval;

    INSERT INTO IOT.IOTCT_FIJA_TRANSAC
      (
        TRANN_ID,
        TRANV_TRANSACCION,
        TRANV_TIPO_TRANSACCION,
        TRANN_USUARIOID,
        TRANV_DEVICEID,
        TRANV_TOKEN,
        TRANC_ESTADO,
        TRANV_MENSAJE,
        TRANV_CREATE_USER,
        TRAND_CREATE_DATE)
       VALUES
       (v_id,
       'TRAZABILIDAD DE ESTADO DECO CLIENTE',
       'REGISTRA_NUMSERIE_STB_IP',
         ln_customerid,
         PI_DEVICEID,
         ln_customerid||'0;phone-context=claro.pe',
         'A',
         'AsociaciÃ³n de deco: '||PI_DEVICEID||' al cliente '||ln_customerid,
         USER,
         SYSDATE
        );

       Exception
     When Others Then
      po_codrpta    := -4;
      po_msjrpta    := 'Error de insercion: ' || Sqlerrm;

    END;

      po_customerid := ln_customerid;
      po_codrpta    := 0;
      po_msjrpta    := 'Se Registro con Exito el Numero de Serie ' ||
                       pi_deviceid;
    end if;
  Exception
    WHEN e_error then
      po_customerid := null;
      po_codrpta    := -1;
      po_msjrpta    := '[IOTSI_REGISTRA_NUMSERIE_STB_IP ] - El Correo ' ||
                       pi_correo || ' no se encuentra suscrito';
    WHEN e_error_row then
      po_customerid := null;
      po_codrpta    := -2;
      po_msjrpta    := '[IOTSI_REGISTRA_NUMSERIE_STB_IP ] - Existe Mas de un Customer asociado al Correo ' ||
                       pi_correo;
    When Others Then
      po_customerid := null;
      po_codrpta    := -3;
      po_msjrpta    := '[IOTSI_REGISTRA_NUMSERIE_STB_IP ] - ' || Sqlerrm;
  end;

  /****************************************************************
  * Nombre SP          : iotss_customer_x_deviceid
  * Proposito          : Funcion que devuelve customer a quien pertenece DeviceID
  *
  * Input              : PI_DEVICEID          - Numero Serie del Dispositivo STB-IP
  *
  * Output             : PO_CODRPTA           - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA           - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : Steve Panduro
  * Actualizado por    :
  * Fec Creacion       : 07/02/2020
  * Fec Actualizacion  :
  * Motivo             :
  ***************************************************************/
  FUNCTION IOTSS_CUSTOMER_X_DEVICEID(pi_deviceid iotct_dispositivo_cliente.disclv_deviceid%type,
                                     po_codrpta  out number,
                                     po_msjrpta  out varchar2) return number is

    ln_customerid iott_cliente.clin_usuarioid%type;
    n_contenvio number default 0;
    n_contfraude number default 0;
    v_status varchar2(30);
    n_idseqiot number;
  begin
    begin
      select discln_usuarioid into ln_customerid
      from iotct_dispositivo_cliente
      where disclv_deviceid = pi_deviceid and DISCLC_ESTADO = 'A';
    po_codrpta := 0;
      po_msjrpta := 'Consulta Exitosa';
      return ln_customerid;
    Exception
      WHEN others THEN
        po_codrpta := 0;
        if sqlcode=+100 then
          po_msjrpta := '[IOTSS_CUSTOMER_X_DEVICEID ] - El Numero de Serie ' ||pi_deviceid || ' no Existe';
        elsif sqlcode=-1422 then
          po_msjrpta := '[IOTSS_CUSTOMER_X_DEVICEID ] - Existe Mas de un Customer asociado al Numero de Serie ' ||
          pi_deviceid;
        else
          po_msjrpta := '[IOTSS_CUSTOMER_X_DEVICEID ] - ' || Sqlerrm;
        end if;
        begin
          select max(idseqiot) into n_idseqiot from IOT.CONTROL_SERIES_IOT
          where deviceid=pi_deviceid and not status='CONFORME';
          select contenvio,status,contfraude into n_contenvio,v_status,n_contfraude
          from IOT.CONTROL_SERIES_IOT where deviceid=pi_deviceid and idseqiot=n_idseqiot;
        exception
          when no_data_found then
            v_status:='REGISTRADO';
            select IOT.SQ_IDSEQIOT.nextval into n_idseqiot from dual;
            insert into IOT.CONTROL_SERIES_IOT(iDSEQIOT,deviceid,status,contenvio)
            values(n_idseqiot,pi_deviceid,v_status,0);
        end;
        if v_status='REGISTRADO' then
          update IOT.CONTROL_SERIES_IOT set contenvio=n_contenvio+1,fecmod=sysdate
          where deviceid=pi_deviceid and idseqiot=n_idseqiot;
          select valor into ln_customerid from IOT.constante where constante='IOTCUSTXDEFAULT';
        end if;
        if v_status='FRAUDE' then
          update IOT.CONTROL_SERIES_IOT set contfraude=n_contfraude+1,fecmodfrau=sysdate
          where deviceid=pi_deviceid and idseqiot=n_idseqiot;
          po_codrpta := -1;
          ln_customerid := null;
        end if;
        return ln_customerid;
    end;
  end;

 /****************************************************************
  * Nombre SP          : IOTSS_PERSONALIZAR_MSJ
  * Proposito          : SP que permite mostrar los mensajes personalizados para cada API.
  * Input              : PI_COD_SERVICIO  - Codigo del Proyecto_Nombre del Proyecto.
  * Input              : PI_COD_MENSAJE - Codigo del mensaje
                         PI_MENSAJE_AMCO - Mensaje de Amco
  * Output             : PO_PRODUCTID  - Porduct Id (Bono)
  *                      PO_PERSONALIZAR_MSJ  - Mensaje personalizado
  *                      PO_CODRPTA    - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA    - Indica la descripcion del codigo de respuesta.
  * Creado por         : jaraco
  * Actualizado por    :
  * Fec Creacion       : 15/07/2020
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSS_PERSONALIZAR_MSJ  (PI_COD_SERVICIO      IN  IOTT_CONFIGURACION.CONFV_SERVICIO%TYPE,
                                   PI_MENSAJE_AMCO      IN  IOTT_CONFIGURACION.CONFV_DESCRIP%TYPE,
                                   PO_PERSONALIZAR_MSJ  OUT IOTT_CONFIGURACION.CONFV_VALOR1%TYPE,
                                   PO_CODRPTA           OUT VARCHAR2,
                                   PO_MSJRPTA           OUT VARCHAR2)

IS
V_COUNT              NUMBER;

 BEGIN

    SELECT COUNT(1) INTO V_COUNT
                   FROM IOTT_CONFIGURACION
                                    WHERE CONFV_SERVICIO = PI_COD_SERVICIO AND
                                          CONFV_DESCRIP = PI_MENSAJE_AMCO AND
                                          ROWNUM = 1;

   IF V_COUNT > 0 THEN

     SELECT CONFV_VALOR1 INTO PO_PERSONALIZAR_MSJ
                     FROM IOTT_CONFIGURACION
                                      WHERE CONFV_SERVICIO = PI_COD_SERVICIO AND
                                            CONFV_DESCRIP = PI_MENSAJE_AMCO AND
                                            ROWNUM = 1;

     PO_CODRPTA  := '0';
     PO_MSJRPTA := 'Operacion Exitosa';

   ELSE

      PO_PERSONALIZAR_MSJ := PI_MENSAJE_AMCO;
      PO_CODRPTA  := '1';
      PO_MSJRPTA := 'No se encontraron datos';

   END IF;

 EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA  := '-1';
      PO_MSJRPTA := 'ERROR DE ORACLE: ' || to_char(SQLCODE) || ': ' ||
                              SQLERRM;


END IOTSS_PERSONALIZAR_MSJ;

/****************************************************************
  * Nombre SP          : IOTSU_ACTUALIZA_ESTADO
  * Proposito          : SP que permite actualizar el estado de la tabla de asociacion
  * Input              : PI_CUSTOMER  - Customer cliente.
  * Output             : PO_CODRPTA    - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA    - Indica la descripcion del codigo de respuesta.
  * Creado por         : hitss
  * Actualizado por    :
  * Fec Creacion       : 03/08/2020
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSU_ACTUALIZA_ESTADO (PI_CUSTOMER         IN iotct_dispositivo_cliente.discln_usuarioid%type,
                                   PO_CODRPTA          OUT VARCHAR2,
                                   PO_MSJRPTA          OUT VARCHAR2 ) IS

 V_CONTADOR             NUMBER:=0;
 V_ESTADO               IOTCT_DISPOSITIVO_CLIENTE.DISCLC_ESTADO%TYPE:='D';
 V_ID                   NUMBER;

 BEGIN

   SELECT COUNT(1)
        INTO V_CONTADOR
        FROM IOTCT_DISPOSITIVO_CLIENTE E
       WHERE E.DISCLN_USUARIOID = PI_CUSTOMER
     AND E.DISCLC_ESTADO= C_AMCO_ACTI;

      IF V_CONTADOR = 0 THEN
        PO_CODRPTA := '0';
        PO_MSJRPTA := 'No se encontro cliente asociado';
       RETURN;
      END IF;

      UPDATE IOTCT_DISPOSITIVO_CLIENTE
           SET DISCLC_ESTADO      = V_ESTADO,
               DISCLD_FECHA_DESV  = SYSDATE,
               DISCLV_MODIFI_USER = USER,
               DISCLD_MODIFI_DATE = SYSDATE
         WHERE DISCLN_USUARIOID = PI_CUSTOMER
          AND (DISCLN_LINEA IS NULL OR DISCLN_LINEA='');

begin
--Generamos trama:
 FOR FILA IN (
          SELECT disclv_deviceid
            FROM IOTCT_DISPOSITIVO_CLIENTE E
             WHERE E.DISCLN_USUARIOID = PI_CUSTOMER
           AND E.DISCLC_ESTADO= V_ESTADO
           AND (DISCLN_LINEA IS NULL OR DISCLN_LINEA='')

              )LOOP

    V_ID:=IOT.IOTSEQ_FIJA_TRANSAC.nextval;

    INSERT INTO IOT.IOTCT_FIJA_TRANSAC
      (
        TRANN_ID,
        TRANV_TRANSACCION,
        TRANV_TIPO_TRANSACCION,
        TRANN_USUARIOID,
        TRANV_DEVICEID,
        TRANV_TOKEN,
        TRANC_ESTADO,
        TRANV_MENSAJE,
        TRANV_CREATE_USER,
        TRAND_CREATE_DATE)
       VALUES
       (V_ID,
       'TRAZABILIDAD DE ESTADO DECO CLIENTE',
       'IOTSU_ACTUALIZA_ESTADO',
         PI_CUSTOMER,
         FILA.disclv_deviceid,
         PI_CUSTOMER||'0;phone-context=claro.pe',
         'D',
         'DesasociaciÃ³n de deco: '||FILA.disclv_deviceid||' al cliente '||PI_CUSTOMER,
         USER,
         SYSDATE
        );


END LOOP;

 Exception
     When Others Then
      po_codrpta    := -2;
      po_msjrpta    := 'Error de insercion: ' || Sqlerrm;

 END;
           PO_CODRPTA := '0';
           PO_MSJRPTA := 'Dispositivos de cliente desasociados';

  EXCEPTION
   WHEN OTHERS THEN
     BEGIN
       PO_CODRPTA := '-1';
       PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
     END;
 END;


  /****************************************************************
    * Nombre SP          : IOTSU_ACTUALIZA_ESTADO_STB_IP
    * Proposito          : SP que permite actualizar el estado de un dispositivo en la tabla de asociacion
    * Input              : PI_CUSTOMERID  - Customer cliente.
                           PI_DEVICEID - Identificador del dispositivo
                           PI_ESTADO - Estado a modificar (A:Activado, D:Desvinculado)
    * Output             : PO_CODRPTA - Indica si el procedure termino exitosamente o no.
    *                      PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
    * Creado por         : hitss
    * Actualizado por    :
    * Fec Creacion       : 23/09/2020
    * Fec Actualizacion  :
  ***************************************************************/
  PROCEDURE IOTSU_ACTUALIZA_ESTADO_STB_IP(PI_CUSTOMERID IN IOTCT_DISPOSITIVO_CLIENTE.DISCLN_USUARIOID%TYPE,
                                          PI_DEVICEID   IN IOTCT_DISPOSITIVO_CLIENTE.DISCLV_DEVICEID%TYPE,
                                          PI_ESTADO     IN IOTCT_DISPOSITIVO_CLIENTE.DISCLC_ESTADO%TYPE,
                                          PO_CODRPTA    OUT VARCHAR2,
                                          PO_MSJRPTA    OUT VARCHAR2) IS
    V_CONTADOR NUMBER := 0;
    V_ESTADO   IOTCT_DISPOSITIVO_CLIENTE.DISCLC_ESTADO%TYPE := UPPER(PI_ESTADO);
    V_EXCEPT_ESTADO EXCEPTION;
    V_ID number;

  BEGIN
    SELECT COUNT(1)
      INTO V_CONTADOR
      FROM IOTCT_DISPOSITIVO_CLIENTE E
     WHERE E.DISCLN_USUARIOID = PI_CUSTOMERID
       AND E.DISCLV_DEVICEID = PI_DEVICEID;
    IF V_CONTADOR = 0 THEN
      PO_CODRPTA := '0';
      PO_MSJRPTA := 'No se encontro dispositivo';
      RETURN;
    END IF;
    IF V_ESTADO = C_AMCO_ACTI THEN
      UPDATE IOTCT_DISPOSITIVO_CLIENTE
         SET DISCLC_ESTADO      = V_ESTADO,
             DISCLD_FECHA_ACT   = SYSDATE,
             DISCLV_MODIFI_USER = USER,
             DISCLD_MODIFI_DATE = SYSDATE
       WHERE DISCLN_USUARIOID = PI_CUSTOMERID
         AND DISCLV_DEVICEID = PI_DEVICEID;

     BEGIN
     --GENERAMOS TRAZA
      V_ID:=IOT.IOTSEQ_FIJA_TRANSAC.nextval;

    INSERT INTO IOT.IOTCT_FIJA_TRANSAC
      (
        TRANN_ID,
        TRANV_TRANSACCION,
        TRANV_TIPO_TRANSACCION,
        TRANN_USUARIOID,
        TRANV_DEVICEID,
        TRANV_TOKEN,
        TRANC_ESTADO,
        TRANV_MENSAJE,
        TRANV_CREATE_USER,
        TRAND_CREATE_DATE)
       VALUES
       (V_ID,
       'TRAZABILIDAD DE ESTADO DECO CLIENTE',
       'IOTSU_ACTUALIZA_ESTADO_STB_IP',
         PI_CUSTOMERID,
         PI_DEVICEID,
         PI_CUSTOMERID||'0;phone-context=claro.pe',
         'A',
         'AsociaciÃ³n de deco: '||PI_DEVICEID||' al cliente '||PI_CUSTOMERID,
         USER,
         SYSDATE
        );


     Exception
     When Others Then
      po_codrpta    := -2;
      po_msjrpta    := 'Error de insercion: ' || Sqlerrm;

      END;

    ELSIF V_ESTADO = C_AMCO_DESA THEN
      UPDATE IOTCT_DISPOSITIVO_CLIENTE
         SET DISCLC_ESTADO      = V_ESTADO,
             DISCLD_FECHA_DESV  = SYSDATE,
             DISCLV_MODIFI_USER = USER,
             DISCLD_MODIFI_DATE = SYSDATE
       WHERE DISCLN_USUARIOID = PI_CUSTOMERID
         AND DISCLV_DEVICEID = PI_DEVICEID;


    BEGIN
       --generamos traza
       V_ID:=IOT.IOTSEQ_FIJA_TRANSAC.nextval;

    INSERT INTO IOT.IOTCT_FIJA_TRANSAC
      (
        TRANN_ID,
        TRANV_TRANSACCION,
        TRANV_TIPO_TRANSACCION,
        TRANN_USUARIOID,
        TRANV_DEVICEID,
        TRANV_TOKEN,
        TRANC_ESTADO,
        TRANV_MENSAJE,
        TRANV_CREATE_USER,
        TRAND_CREATE_DATE)
       VALUES
       (V_ID,
       'TRAZABILIDAD DE ESTADO DECO CLIENTE',
       'IOTSU_ACTUALIZA_ESTADO_STB_IP',
         PI_CUSTOMERID,
         PI_DEVICEID,
         PI_CUSTOMERID||'0;phone-context=claro.pe',
         'D',
         'DesasociaciÃ³n de deco: '||PI_DEVICEID||' al cliente '||PI_CUSTOMERID,
         USER,
         SYSDATE
        );

    Exception
     When Others Then
      po_codrpta    := -2;
      po_msjrpta    := 'Error de insercion: ' || Sqlerrm;

   END;

    ELSE
      RAISE V_EXCEPT_ESTADO;
    END IF;
    PO_CODRPTA := '0';
    PO_MSJRPTA := 'Dispositivo de cliente actualizado';
  EXCEPTION
    WHEN V_EXCEPT_ESTADO THEN
      BEGIN
        PO_CODRPTA := '-1';
        PO_MSJRPTA := 'EXCEPTION: ESTADO NO VALIDO';
      END;
    WHEN OTHERS THEN
      BEGIN
        PO_CODRPTA := '-1';
        PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
      END;
  END;

/****************************************************************
  * Nombre SP          : IOTSS_CONSULTAR_CLIENTECV
  * Proposito          : SP que permite consultar la sucripcion del usuario.
  * Input              : PI_MEDIO_PAGO  - LÃ­nea o token.
  * Input              : PI_PRODUCTOID
  * Output             : PO_CORREO
  *                      PO_USUARIOID
  *                      PO_PRODUCTID
  *                      PO_CODRPTA    - Indica si el(Codigo) procedure termino exitosamente o no.
  *                      PO_MSJRPTA    - Indica la descripcion del codigo de respuesta.
  * Creado por         : mcordero
  * Actualizado por    : mcordero
  * Fec Creacion       : 01/10/2020
  * Fec Actualizacion  : 23/10/2020
  * Motivo cambio      : el PI_PRODUCTOID es opcional
***************************************************************/
PROCEDURE IOTSS_CONSULTAR_CLIENTECV (PI_MEDIO_PAGO IN IOTT_CLIENTE.CLIV_LINEA%TYPE,
                                     PI_PRODUCTOID IN IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                     PO_CORREO     OUT IOTT_CLIENTE.CLIV_CORREO%TYPE,
                                     PO_USUARIOID  OUT IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                                     PO_PRODUCTID  OUT IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                     PO_CODRPTA    OUT VARCHAR2,
                                     PO_MSJRPTA    OUT VARCHAR2)IS

V_CORREO                              IOTT_CLIENTE.CLIV_CORREO%TYPE;
V_USUARIOID                           IOTT_CLIENTE.CLIN_USUARIOID%TYPE;
V_CONT                                NUMBER  := 0;
V_CANT_ROW                            NUMBER  := 0;
V_ESTADO_ACTIVADO                     CHAR(1) := 'A';
V_ESTADO_CANCELADO                    CHAR(1) := 'C';
V_PRODUCTID                           IOTCT_SERVICIO.SERVN_SERVICEID%TYPE;
V_PRODUCTO                            IOTCT_SERVICIO.SERVV_NOMBRE%TYPE;


BEGIN
  PO_CORREO:='';
  PO_USUARIOID:='';

IF PI_PRODUCTOID IS NULL  THEN  --- PROCESO DE ELIMINACION

  SELECT COUNT(1) INTO V_CANT_ROW FROM IOTT_SUSCRIPCION S
                             WHERE S.SUSV_LINEA          = PI_MEDIO_PAGO
                               AND S.SUSC_ESTADO         IN (V_ESTADO_ACTIVADO ,V_ESTADO_CANCELADO)
                               AND ROWNUM                = 1;

  IF V_CANT_ROW >0 THEN

     SELECT S.SUSN_SERVICIOID INTO V_PRODUCTID
                             FROM IOTCT_SERVICIO SV
                             JOIN IOTT_SUSCRIPCION S
                                  ON SV.SERVN_SERVICEID  = S.SUSN_SERVICIOID
                             WHERE S.SUSV_LINEA          = PI_MEDIO_PAGO
                               AND S.SUSC_ESTADO         IN (V_ESTADO_ACTIVADO ,V_ESTADO_CANCELADO)
                               AND ROWNUM                = 1;

   ELSE
          PO_CODRPTA:='2';
          PO_MSJRPTA:='El Cliente no existe';
          RETURN;
   END IF;

ELSE                            --- PROCESO DE CANCELACION

  SELECT SV.SERVV_NOMBRE INTO V_PRODUCTO
                         FROM IOTCT_SERVICIO SV
                         WHERE SV.SERVN_SERVICEID= PI_PRODUCTOID;

  SELECT COUNT(1) INTO V_CANT_ROW FROM IOTCT_SERVICIO SV
                       JOIN IOTT_SUSCRIPCION S
                            ON SV.SERVN_SERVICEID  = S.SUSN_SERVICIOID
                       WHERE S.SUSV_LINEA          = PI_MEDIO_PAGO
                         AND S.SUSC_ESTADO         = V_ESTADO_ACTIVADO
                         AND SV.SERVV_NOMBRE       = V_PRODUCTO
                         AND ROWNUM                = 1;
    IF V_CANT_ROW > 0 THEN

             SELECT S.SUSN_SERVICIOID INTO V_PRODUCTID
                       FROM IOTCT_SERVICIO SV
                       JOIN IOTT_SUSCRIPCION S
                            ON SV.SERVN_SERVICEID  = S.SUSN_SERVICIOID
                       WHERE S.SUSV_LINEA          = PI_MEDIO_PAGO
                         AND S.SUSC_ESTADO         = V_ESTADO_ACTIVADO
                         AND SV.SERVV_NOMBRE       = V_PRODUCTO
                         AND ROWNUM                = 1;
     ELSE

          PO_CODRPTA:='3';
          PO_MSJRPTA:='No Existe SuscripciÃ³n';
          RETURN;
    END IF;


END IF;

  SELECT COUNT(1)
         INTO V_CONT
              FROM IOTT_SUSCRIPCION S
              JOIN IOTT_CLIENTE C
                   ON S.SUSN_USUARIOID  = C.CLIN_USUARIOID
              JOIN IOTCT_SERVICIO SV
                   ON S.SUSN_SERVICIOID = SV.SERVN_SERVICEID
              WHERE S.SUSV_LINEA        = PI_MEDIO_PAGO
              AND S.SUSC_ESTADO         IN ( V_ESTADO_ACTIVADO,V_ESTADO_CANCELADO)
              AND S.SUSN_SERVICIOID     = V_PRODUCTID
              AND ROWNUM                = 1;


     IF V_CONT > 0 THEN
       SELECT C.CLIV_CORREO, C.CLIN_USUARIOID,S.SUSN_SERVICIOID
              INTO V_CORREO, V_USUARIOID, V_PRODUCTID
                   FROM IOTT_SUSCRIPCION S
                   JOIN IOTT_CLIENTE C
                        ON S.SUSN_USUARIOID  = C.CLIN_USUARIOID
                   JOIN IOTCT_SERVICIO SV
                        ON S.SUSN_SERVICIOID  = SV.SERVN_SERVICEID
                   WHERE S.SUSV_LINEA         = PI_MEDIO_PAGO
                     AND S.SUSC_ESTADO        IN (V_ESTADO_ACTIVADO,V_ESTADO_CANCELADO)
                     AND S.SUSN_SERVICIOID     = V_PRODUCTID
                     AND ROWNUM              = 1;

          PO_CORREO       :=         V_CORREO;
          PO_USUARIOID    :=         V_USUARIOID;
          PO_PRODUCTID    :=         V_PRODUCTID;

          PO_CODRPTA:='0';
          PO_MSJRPTA:='Operacion Exitosa';

     ELSE
       PO_CODRPTA:='1';
       PO_MSJRPTA:='No existen suscripciones';

     END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;

END IOTSS_CONSULTAR_CLIENTECV;

/****************************************************************
  * Nombre SP          : IOTSS_DATOS_CLIENTE_CORREO
  * Proposito          : SP para obtener el customerId con el correo.
  * Input              : PI_CORREO     - Correo del cliente.
  * Output             : PO_CORREO     - Correo del cliente suscrito.
  *                    : PO_USUARIOID  - Id generado de la tabla cliente.
  *                      PO_CODRPTA - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJRPTA - Indica la descripcion del codigo de respuesta.
  * Creado por         :
  * Actualizado por    :
  * Fec Creacion       : 26/11/2020
  * Fec Actualizacion  :
  * Motivo cambio      :
***************************************************************/
PROCEDURE IOTSS_DATOS_CLIENTE_CORREO (PI_CORREO IN IOTT_CLIENTE.CLIV_CORREO%TYPE,
                    PO_CORREO     OUT IOTT_CLIENTE.CLIV_CORREO%TYPE,
                    PO_USUARIOID  OUT IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                    PO_CODRPTA    OUT VARCHAR2,
                    PO_MSJRPTA    OUT VARCHAR2)IS

V_USUARIOID                     IOTT_CLIENTE.CLIN_USUARIOID%TYPE;
V_CONT                          NUMBER  := 0;
V_ESTADO_ALTA                   CHAR(1) := 'A';

BEGIN
  PO_CORREO:='';
  PO_USUARIOID:='';

  SELECT COUNT(1)
    INTO V_CONT
    FROM IOTT_CLIENTE C
    WHERE UPPER(CLIV_CORREO) = UPPER(PI_CORREO)
     AND CLIC_ESTADO = V_ESTADO_ALTA;

  IF V_CONT > 0 THEN
    SELECT MAX(C.CLIN_USUARIOID)
         INTO V_USUARIOID
    FROM IOTT_CLIENTE C
    WHERE UPPER(CLIV_CORREO) = UPPER(PI_CORREO)
     AND CLIC_ESTADO = V_ESTADO_ALTA;

    PO_CORREO:=PI_CORREO;
    PO_USUARIOID:=V_USUARIOID;
    PO_CODRPTA:='0';
    PO_MSJRPTA:='Operacion Exitosa';
  ELSE
    PO_CODRPTA:='1';
    PO_MSJRPTA:='No existen correo en IOTDB';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
END IOTSS_DATOS_CLIENTE_CORREO;

 PROCEDURE IOTSS_VALIDAR_PRODUCTID_SACV(PI_LINEA          IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                        PI_PRODUCTOID     IN IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PI_DESSERV        IN VARCHAR2,
                                        PO_CURSOR         OUT C_REF_CURSOR,
                                        PO_CODRPTA        OUT NUMBER,
                                        PO_MSJRPTA        OUT VARCHAR2)IS


 V_COUNT_PLANES                         NUMBER(10):=0;
 V_COUNT_SERV                           NUMBER(10):=0;
 V_COUNT_ACTIVO                         NUMBER(10):=0;
 V_COUNT_CANCEL                         NUMBER(10):=0;
 V_COUNT_TV                             NUMBER(10):=0;
 V_FLAG_PAGA                            CHAR(1) := 'F';

 V_NOM_SERVICIO                         IOTCT_SERVICIO.SERVV_NOMBRE%TYPE;

 CURSOR c_nom_servicio (C_SERVICIO  VARCHAR2)IS
 SELECT SE.SERVV_NOMBRE FROM IOTCT_SERVICIO SE
 WHERE SE.SERVN_SERVICEID = C_SERVICIO;

 BEGIN
    PO_CODRPTA := 0;
    PO_MSJRPTA := 'Consulta Exitosa';

   SELECT COUNT(1)
     INTO V_COUNT_SERV
     FROM IOTCT_SERVICIO SER
    WHERE SER.SERVN_SERVICEID = PI_PRODUCTOID;

   IF V_COUNT_SERV = 0 THEN
     PO_CODRPTA := 1;
     PO_MSJRPTA := 'Servicio no configurado';
     RETURN;
   END IF;

   OPEN C_NOM_SERVICIO(PI_PRODUCTOID);
   FETCH C_NOM_SERVICIO INTO V_NOM_SERVICIO;
   CLOSE C_NOM_SERVICIO;

   SELECT COUNT(1)
     INTO V_COUNT_ACTIVO
     FROM IOTT_SUSCRIPCION SU
     JOIN IOTCT_SERVICIO S
       ON SU.SUSN_SERVICIOID = S.SERVN_SERVICEID
    WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
      AND SU.SUSV_LINEA = PI_LINEA;

      IF V_COUNT_ACTIVO > 0 THEN
         PO_CODRPTA:='2';
         PO_MSJRPTA:='El cliente ya cuenta con el servicio activo';
         RETURN;
      END IF;

      SELECT COUNT(1)
        INTO V_COUNT_CANCEL
        FROM IOTCT_SERVICIO S
        JOIN IOTT_SUSCRIPCION SU
          ON S.SERVN_SERVICEID = SU.SUSN_SERVICIOID
       WHERE S.SERVV_NOMBRE = V_NOM_SERVICIO
         AND SU.SUSV_LINEA = PI_LINEA;

         IF V_COUNT_CANCEL = 0 THEN
           IF V_NOM_SERVICIO = 'CLARO VIDEO' THEN

             SELECT COUNT(1)
               INTO V_COUNT_PLANES
               FROM IOTCT_PLANES PLN
               JOIN IOTCT_SERVICIO SER
                 ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
              WHERE PLN.PLNN_TMCOD = '1000';

              IF V_COUNT_PLANES > 0 THEN
                OPEN PO_CURSOR FOR
                  SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                         SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                         SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                    FROM IOTCT_PLANES PLN
                    JOIN IOTCT_SERVICIO SER
                      ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
                   WHERE PLN.PLNN_TMCOD = '1000';

                 RETURN;
              ELSE
                OPEN PO_CURSOR FOR
                      SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                             SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                             SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                        FROM IOTCT_SERVICIO SER
                        WHERE SER.SERVV_NOMBRE = V_NOM_SERVICIO
                        AND SER.SERVN_SERVICEID = 10000030;
                 RETURN;
              END IF;
           ELSIF (PI_PRODUCTOID IN (130001001,140001001)) THEN
                 V_FLAG_PAGA := 'T';
           ELSIF PI_PRODUCTOID = 110001001 THEN
              SELECT COUNT(1)
                INTO V_COUNT_TV
                FROM IOTCT_PLANES PLN
                JOIN IOTCT_SERVICIO SER
                  ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
               WHERE PLN.PLNN_TMCOD = '100'
                 AND SER.SERVV_NOMBRE = V_NOM_SERVICIO;

                IF V_COUNT_TV > 0  THEN
                    OPEN PO_CURSOR FOR
                       SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                              SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                              SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                         FROM IOTCT_PLANES PLN
                         JOIN IOTCT_SERVICIO SER
                           ON PLN.PLNN_SERVICEID = SER.SERVN_SERVICEID
                        WHERE PLN.PLNN_TMCOD = '1000';

                   RETURN;
                 ELSE
                   V_FLAG_PAGA :='T';
                 END IF;
           ELSE
               OPEN PO_CURSOR FOR
                 SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
                        SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
                        SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
                   FROM IOTCT_SERVICIO SER
                  WHERE SER.SERVV_NOMBRE = V_NOM_SERVICIO;

              RETURN;
           END IF;
    ELSE
      V_FLAG_PAGA:='T';
    END IF;
    IF V_FLAG_PAGA = 'T' THEN
      OPEN PO_CURSOR FOR
        SELECT SER.SERVN_SERVICEID PO_PRODUCTID,
               SER.SERVV_TIPO      PO_PRODUCTID_TIPO,
               SER.SERVV_NOMBRE    PO_PRODUCTID_NOM
          FROM IOTCT_SERVICIO SER
         WHERE SER.SERVV_NOMBRE = V_NOM_SERVICIO
           AND SERVV_TIPO = C_AMCO_PAGA;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      PO_CODRPTA := -1;
      PO_MSJRPTA := 'Error => ' || sqlerrm;
END IOTSS_VALIDAR_PRODUCTID_SACV;


 /****************************************************************
  * Nombre SP          : IOTSS_CUSTOMER
  * Proposito          : SP que obtiene el customer de bscs.
  *
  * Input               :PI_CUSTOMERAMCO           - customer de amco
  *
  * Output             : PO_CUSTOMERBSCS           - Customer de BSCS
  *                      PO_COD_RESULTADO          - Indica si el procedure termino exitosamente o no.
  *                      PO_MSJ_RESULTADO          - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : hitss
  * Actualizado por    :
  * Fec Creacion       : 03/03/2021
  * Fec Actualizacion  :
  ***************************************************************/

PROCEDURE IOTSS_CUSTOMER (PI_CUSTOMERAMCO   IN VARCHAR2,
                          PO_CUSTOMERBSCS    OUT VARCHAR2,
                          PO_COD_RESULTADO   OUT VARCHAR2,
                          PO_MSJ_RESULTADO   OUT VARCHAR2 ) IS

BEGIN

 select distinct  nvl(S.SUSV_CUSTOMERID,substr(s.susv_linea,1,8)) SUSV_CUSTOMERID
 into PO_CUSTOMERBSCS
from  IOT.IOTT_SUSCRIPCION  s , IOT.IOTT_CLIENTE  c
where S.SUSN_USUARIOID=C.CLIN_USUARIOID
AND C.CLIN_USUARIOID=PI_CUSTOMERAMCO;


PO_COD_RESULTADO := '0';
PO_MSJ_RESULTADO := 'EXITO AL OBTENER CUSTOMER BSCS';

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     PO_COD_RESULTADO:='-1';
     PO_MSJ_RESULTADO:='NO SE ENCONTRO CUSTOMER BSCS';
   WHEN OTHERS THEN
      PO_COD_RESULTADO := -2;
      PO_MSJ_RESULTADO := SQLCODE || ' : ' || SQLERRM;

END  IOTSS_CUSTOMER;

 /****************************************************************
  * Nombre SP          : IOTSS_SERIES
  * Proposito          : SP que obtiene las series y customer bscs.
  *
  * Input               :PI_TIPO                   - T:todos, A:activos, TI:todos iptv, AI:todos activos
  *                     :PI_CUSTOMER               - Customer BSCS
  * Output              :PO_CURSOR                 - Cursor de series
  *                     :PO_COD_RESULTADO          - Indica si el procedure termino exitosamente o no.
  *                     :PO_MSJ_RESULTADO          - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : hitss
  * Actualizado por    :
  * Fec Creacion       : 03/03/2021
  * Fec Actualizacion  :
  ***************************************************************/


PROCEDURE IOTSS_SERIES (  PI_TIPO            IN VARCHAR2,
                          PI_CUSTOMER        IN VARCHAR2,
                          PO_CURSOR          OUT SYS_REFCURSOR,
                          PO_COD_RESULTADO   OUT VARCHAR2,
                          PO_MSJ_RESULTADO   OUT VARCHAR2 ) IS

V_CANTIDAD integer; --3.0
V_LINEA    VARCHAR2(50); --3.0
V_TOKEN      VARCHAR(50); --3.0
BEGIN

PO_COD_RESULTADO := '0';
PO_MSJ_RESULTADO := 'EXITO';
V_CANTIDAD := LENGTH(PI_CUSTOMER); --3.0
    --INI 3.0
       SELECT CONFV_VALOR1
       INTO V_TOKEN
       FROM IOT.IOTT_CONFIGURACION
       WHERE CONFV_DESCRIP = 'TOKEN'
       AND CONFV_SERVICIO = '141348_ONEFIJA';

      V_LINEA := PI_CUSTOMER || V_TOKEN;
       --FIN 3.0
      IF PI_TIPO='TI' THEN
     OPEN PO_CURSOR   FOR
         select distinct NVL(S.SUSV_CUSTOMERID,substr(S.SUSV_LINEA,1,V_CANTIDAD)) SUSV_CUSTOMERID, D.DISCLV_DEVICEID,
                nvl(D.discld_modifi_date,D.DISCLD_FECHA_ACT)as DISCLD_FECHA_ACT,
                D.DISCLN_USUARIOID,
                D.DISCLC_ESTADO
         from  IOT.IOTT_SUSCRIPCION  S , IOT.IOTT_CLIENTE  C, IOT.IOTCT_DISPOSITIVO_CLIENTE D
          where S.SUSN_USUARIOID=C.CLIN_USUARIOID
          AND D.DISCLN_USUARIOID=C.CLIN_USUARIOID
          AND C.CLIC_ESTADO='A'
          AND D.DISCLC_ESTADO IN ('A','D')
          AND (S.SUSV_LINEA =V_LINEA OR S.SUSV_CUSTOMERID= PI_CUSTOMER); --3.0

  ELSE
       IF PI_TIPO ='AI' THEN
          OPEN PO_CURSOR   FOR
             select distinct NVL(S.SUSV_CUSTOMERID,substr(S.SUSV_LINEA,1,V_CANTIDAD)) SUSV_CUSTOMERID, D.DISCLV_DEVICEID,
                    nvl(D.discld_modifi_date,D.DISCLD_FECHA_ACT)as DISCLD_FECHA_ACT,
                    D.DISCLN_USUARIOID,
                    D.DISCLC_ESTADO
         from  IOT.IOTT_SUSCRIPCION  S , IOT.IOTT_CLIENTE  C, IOT.IOTCT_DISPOSITIVO_CLIENTE D
          where S.SUSN_USUARIOID=C.CLIN_USUARIOID
          AND D.DISCLN_USUARIOID=C.CLIN_USUARIOID
          AND C.CLIC_ESTADO='A'
          AND D.DISCLC_ESTADO='A'
          AND (S.SUSV_LINEA =V_LINEA OR S.SUSV_CUSTOMERID= PI_CUSTOMER); --3.0

        ELSE
            OPEN PO_CURSOR FOR
            SELECT NULL AS SUSV_CUSTOMERID,
                   NULL AS DISCLV_DEVICEID,
                   NULL AS DISCLD_FECHA_ACT,
                   NULL AS DISCLN_USUARIOID,
                   NULL AS DISCLC_ESTADO
                   FROM DUAL
             WHERE ROWNUM = 0;
          PO_COD_RESULTADO := '1';
          PO_MSJ_RESULTADO := 'TIPO NO DEFINIDO';
        END IF;
     END IF;


EXCEPTION
    WHEN OTHERS THEN
      PO_COD_RESULTADO := -2;
      PO_MSJ_RESULTADO := SQLCODE || ' : ' || SQLERRM;

END  IOTSS_SERIES;



PROCEDURE IOTSS_CONSULTAR_CLIENTE(PI_CORREO    IN IOTT_CLIENTE.CLIV_CORREO%TYPE,
                                  PI_USUARIOID IN IOTT_CLIENTE.CLIN_USUARIOID%TYPE,
                                  PO_CURSOR    OUT C_REF_CURSOR,
                                  PO_CODRPTA   OUT VARCHAR2,
                                  PO_MSJRPTA   OUT VARCHAR2) IS

  V_USUARIOID IOTT_CLIENTE.CLIN_USUARIOID%TYPE;
BEGIN
  IF (PI_CORREO IS NOT NULL) THEN
    SELECT MAX(IC.CLIN_USUARIOID)
      INTO V_USUARIOID
      FROM IOT.IOTT_CLIENTE IC
     WHERE 1 = 1
       AND UPPER(IC.CLIV_CORREO) = UPPER(PI_CORREO)
       AND IC.CLIC_ESTADO IN ('A','P');

  ELSE
    V_USUARIOID := PI_USUARIOID;
  END IF;

  OPEN PO_CURSOR FOR
    SELECT IC.CLIV_NOMBRES     PO_NOMBRES,
           IC.CLIV_APELLIDOS   PO_APELLIDOS,
           IC.CLIV_CORREO      PO_CORREO,
           IC.CLIN_USUARIOID   PO_USUARIOID,
           IC.CLIC_ESTADO      PO_ESTADO,
           IC.CLID_CREATE_DATE PO_CREATE_DATE
      FROM IOT.IOTT_CLIENTE IC
     WHERE 1 = 1
       AND CLIN_USUARIOID = V_USUARIOID;

  PO_CODRPTA := '0';
  PO_MSJRPTA := 'Operacion Exitosa';
EXCEPTION
  WHEN OTHERS THEN
    PO_CODRPTA := '-1';
    PO_MSJRPTA := 'EXCEPTION: ' || SQLERRM;
END IOTSS_CONSULTAR_CLIENTE;

 /****************************************************************
 * Nombre SP          : IOTSS_SERIESXCUSTOMER
 * Proposito          : SP que obtiene las series y customer bscs.
 * Output              :PO_CURSOR                 - Cursor de series
 *                     :PO_COD_RESULTADO          - Indica si el procedure termino exitosamente o no.
 *                     :PO_MSJ_RESULTADO          - Indica la descripcion del codigo de respuesta.
 *
 * Creado por         : hitss
 * Actualizado por    :
 * Fec Creacion       : 23/09/2021
 * Fec Actualizacion  :
 ***************************************************************/
 PROCEDURE IOTSS_SERIESXCUSTOMER(PO_ESTCUST       IN VARCHAR2,
                                 PO_ESTDEVIC      IN VARCHAR2,
                                 PO_CURSOR        OUT SYS_REFCURSOR,
                                 PO_COD_RESULTADO OUT VARCHAR2,
                                 PO_MSJ_RESULTADO OUT VARCHAR2) IS

   V_SQL VARCHAR2(3200);
 BEGIN

   PO_COD_RESULTADO := '0';
   PO_MSJ_RESULTADO := 'EXITO';
   V_SQL            := 'select distinct TO_CHAR(NVL(S.SUSV_CUSTOMERID, substr(S.SUSV_LINEA, 1, 8))) SUSV_CUSTOMERID,' ||
                       'C.CLIC_ESTADO,D.DISCLV_DEVICEID,' ||
                       'TO_CHAR(D.DISCLV_CREATE_DATE,''DD/MM/YYYY HH:MI:SS AM'') as DISCLV_CREATE_DATE,' ||
                       'TO_CHAR(D.DISCLD_FECHA_ACT,''DD/MM/YYYY HH:MI:SS AM'') as DISCLD_FECHA_ACT,' ||
                       'TO_CHAR(D.DISCLD_MODIFI_DATE,''DD/MM/YYYY HH:MI:SS AM'') as DISCLD_MODIFI_DATE,' ||
                       'D.DISCLC_ESTADO,' ||
                       'TO_CHAR(SYSDATE, ''DD/MM/YYYY HH:MI:SS AM'') AS FECHA_CONSULTA ' ||
                       'from IOT.IOTT_SUSCRIPCION S, IOT.IOTT_CLIENTE C, IOT.IOTCT_DISPOSITIVO_CLIENTE D ' ||
                       'where S.SUSN_USUARIOID = C.CLIN_USUARIOID AND D.DISCLN_USUARIOID = C.CLIN_USUARIOID';
   IF PO_ESTCUST IS NOT NULL THEN
     V_SQL := V_SQL || ' AND C.CLIC_ESTADO IN (' || PO_ESTCUST || ')';
   END IF;
   IF PO_ESTDEVIC IS NOT NULL THEN
     V_SQL := V_SQL || ' AND D.DISCLC_ESTADO IN (' || PO_ESTDEVIC || ')';
   END IF;
   OPEN PO_CURSOR FOR V_SQL;

 EXCEPTION
   WHEN OTHERS THEN
     PO_COD_RESULTADO := -2;
     PO_MSJ_RESULTADO := SQLCODE || ' : ' || SQLERRM;

 END IOTSS_SERIESXCUSTOMER;

/****************************************************************
  * Nombre SP          : IOTSS_SERVICIO_LINEA
  * Proposito          : SP que obtiene los datos del cliente.
  *
  * Input              :PI_LINEA         - Linea actual del cliente
  * Output             :PO_CURSOR        - Cursor de Servicios x Linea
  *                    :PO_CODRPTA       - Indica si el procedure termino exitosamente o no.
  *                    :PO_MSJRPTA       - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : Hitss
  * Actualizado por    : 24/01/2022
  * Fec Creacion       :
  * Fec Actualizacion  :
  ***************************************************************/
  PROCEDURE IOTSS_SERVICIO_LINEA(PI_LINEA   IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                 PO_CURSOR  OUT C_REF_CURSOR,
                                 PO_CODRPTA OUT VARCHAR2,
                                 PO_MSJRPTA OUT VARCHAR2) IS
    V_CONT NUMBER := 0;
  BEGIN
    SELECT NVL(COUNT(1), 0)
      INTO V_CONT
      FROM IOT.IOTT_SUSCRIPCION H
      JOIN IOT.IOTCT_SERVICIO SRV
        ON H.SUSN_SERVICIOID = SRV.SERVN_SERVICEID
     WHERE H.SUSC_ESTADO IN ('A')
       AND H.SUSV_LINEA = PI_LINEA;
    IF V_CONT > 0 THEN
      OPEN PO_CURSOR FOR
        SELECT SRV.SERVN_SERVICEID AS SERVICIOID,
               SRV.SERVV_NOMBRE AS NOMBRE_SERVICIO,
               SRV.SERVD_PRECIO AS PRECIO,
               (CASE WHEN H.SUSD_FECHA_SUSCRIPCION IS NULL THEN TRUNC(H.SUSV_CREATE_DATE) ELSE TRUNC(H.SUSD_FECHA_SUSCRIPCION) END) AS FECHA_ACTIVACION,
               (CASE WHEN H.SUSD_FECHA_VIGENCIA IS NULL THEN TRUNC(H.SUSD_MODIFI_DATE) ELSE TRUNC(H.SUSD_FECHA_VIGENCIA) END) AS FECHA_EXPIRACION,
               H.SUSV_TIPO_LINEA AS TIPO_LINEA,
               DECODE(H.SUSV_METODOPAGO, 1, 'MOVIL', 'FIJA') AS SERVICIO,
               H.SUSC_ESTADO AS ESTADO,
               H.SUSV_LINEA
          FROM IOT.IOTT_SUSCRIPCION H
          JOIN IOT.IOTCT_SERVICIO SRV
            ON H.SUSN_SERVICIOID = SRV.SERVN_SERVICEID
         WHERE H.SUSV_LINEA = PI_LINEA
           AND H.SUSC_ESTADO IN ('A');
      PO_CODRPTA := '0';
      PO_MSJRPTA := 'Operacion exitosa';
    ELSE
      OPEN PO_CURSOR FOR
        SELECT NULL AS SERVICIOID,
               NULL AS NOMBRE_SERVICIO,
               NULL AS PRECIO,
               NULL AS FECHA_ACTIVACION,
               NULL AS FECHA_EXPIRACION,
               NULL AS TIPO_LINEA,
               NULL AS SERVICIO,
               NULL AS ESTADO,
               NULL AS SUSV_LINEA
          FROM DUAL
         WHERE ROWNUM = 0;
      PO_CODRPTA := '1';
      PO_MSJRPTA := 'No se encontraron registros';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      OPEN PO_CURSOR FOR
        SELECT NULL AS SERVICIOID,
               NULL AS NOMBRE_SERVICIO,
               NULL AS PRECIO,
               NULL AS FECHA_ACTIVACION,
               NULL AS FECHA_EXPIRACION,
               NULL AS TIPO_LINEA,
               NULL AS SERVICIO,
               NULL AS ESTADO,
               NULL AS SUSV_LINEA
          FROM DUAL
         WHERE ROWNUM = 0;
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error al consultar servicios x Linea => ' || SQLERRM;
  END IOTSS_SERVICIO_LINEA;

  /****************************************************************
  * Nombre SP          : IOTSS_CLIENTE
  * Proposito          : SP que obtiene los datos del cliente.
  *
  * Input               :PI_TIPOBUSQUEDA           - Tipo de busqueda
                        :PI_VALOR_BUSQUEDA         - Valor de busqueda
  * Output              :PO_CURSOR                 - Cursor de Clientes
  *                     :PO_CODRPTA                - Indica si el procedure termino exitosamente o no.
  *                     :PO_MSJRPTA                - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : Hitss
  * Actualizado por    :
  * Fec Creacion       : 24/01/2022
  * Fec Actualizacion  :
  ***************************************************************/
  PROCEDURE IOTSS_CLIENTE(PI_TIPOBUSQUEDA   IN VARCHAR2,
                          PI_VALOR_BUSQUEDA IN VARCHAR2,
                          PO_CURSOR         OUT C_REF_CURSOR,
                          PO_CODRPTA        OUT VARCHAR2,
                          PO_MSJRPTA        OUT VARCHAR2) IS
    V_COUNT NUMBER := 0;
    V_EXCEPTION_BUSQUEDA EXCEPTION;
    V_EXCEPTION_DATOS    EXCEPTION;
  BEGIN
    IF PI_TIPOBUSQUEDA = '1' THEN
      SELECT COUNT(1)
        INTO V_COUNT
        FROM IOT.IOTT_CLIENTE
       WHERE CLIV_CORREO LIKE TRIM(PI_VALOR_BUSQUEDA) || '%';
      IF V_COUNT > 0 THEN
        OPEN PO_CURSOR FOR
          SELECT (SELECT RTRIM(XMLAGG(XMLELEMENT(E, D.DISCLV_DEVICEID || ' (' || D.DISCLC_ESTADO || ')' || ';')).EXTRACT('//text()'), ';')
                             FROM IOT.IOTCT_DISPOSITIVO_CLIENTE D
                            WHERE D.DISCLN_USUARIOID = C.CLIN_USUARIOID) AS SERIE,
                          UPPER(C.CLIV_NOMBRES) AS NOMBRE,
                 (SELECT DISTINCT NVL(S.SUSV_CUSTOMERID,
                                      SUBSTR(TRIM(S.SUSV_LINEA), 1, INSTR(S.SUSV_LINEA, '0;') - 1))
                    FROM IOT.IOTT_SUSCRIPCION S
                   WHERE S.SUSN_USUARIOID = C.CLIN_USUARIOID) AS CUSTOMERID,
                          C.CLIN_USUARIOID AS CUSTOMER_AMCO,
                          C.CLIV_CORREO AS CORREO,
                          C.CLID_CREATE_DATE AS FECHA_ACTIVACION,
                 DECODE(C.CLIC_ESTADO, 'A', 'Activo', 'D', 'Desactivo') AS ESTADO
            FROM IOT.IOTT_CLIENTE C
           WHERE C.CLIV_CORREO LIKE TRIM(PI_VALOR_BUSQUEDA) || '%'
       AND C.CLIC_ESTADO IN ('A', 'D');
      ELSE
        RAISE V_EXCEPTION_DATOS;
      END IF;
    ELSIF PI_TIPOBUSQUEDA = '2' THEN
      SELECT COUNT(1)
        INTO V_COUNT
        FROM IOT.IOTCT_DISPOSITIVO_CLIENTE
       WHERE DISCLV_DEVICEID = PI_VALOR_BUSQUEDA;
      IF V_COUNT > 0 THEN
        OPEN PO_CURSOR FOR
          SELECT (SELECT RTRIM(XMLAGG(XMLELEMENT(E, D.DISCLV_DEVICEID || ' (' || D.DISCLC_ESTADO || ')' || ';')).EXTRACT('//text()'), ';')
                             FROM IOT.IOTCT_DISPOSITIVO_CLIENTE D
                            WHERE D.DISCLN_USUARIOID = C.CLIN_USUARIOID) AS SERIE,
                          UPPER(C.CLIV_NOMBRES) AS NOMBRE,
                 (SELECT DISTINCT NVL(S.SUSV_CUSTOMERID,
                                      SUBSTR(TRIM(S.SUSV_LINEA), 1, INSTR(S.SUSV_LINEA, '0;') - 1))
                    FROM IOT.IOTT_SUSCRIPCION S
                   WHERE S.SUSN_USUARIOID = C.CLIN_USUARIOID) AS CUSTOMERID,
                          C.CLIN_USUARIOID AS CUSTOMER_AMCO,
                          C.CLIV_CORREO AS CORREO,
                          C.CLID_CREATE_DATE AS FECHA_ACTIVACION,
                 DECODE(C.CLIC_ESTADO, 'A', 'Activo', 'D', 'Desactivo') AS ESTADO
            FROM IOT.IOTT_CLIENTE C
           WHERE C.CLIN_USUARIOID IN (SELECT DISCLN_USUARIOID
                    FROM IOT.IOTCT_DISPOSITIVO_CLIENTE
                   WHERE DISCLV_DEVICEID = PI_VALOR_BUSQUEDA)
      AND C.CLIC_ESTADO IN ('A', 'D');
      ELSE
        RAISE V_EXCEPTION_DATOS;
      END IF;
    ELSIF PI_TIPOBUSQUEDA = '3' THEN
      SELECT COUNT(1) INTO V_COUNT FROM IOT.IOTT_CLIENTE WHERE CLIN_USUARIOID = PI_VALOR_BUSQUEDA;
      IF V_COUNT > 0 THEN
        OPEN PO_CURSOR FOR
          SELECT (SELECT RTRIM(XMLAGG(XMLELEMENT(E, D.DISCLV_DEVICEID || ' (' || D.DISCLC_ESTADO || ')' || ';')).EXTRACT('//text()'), ';')
                             FROM IOT.IOTCT_DISPOSITIVO_CLIENTE D
                            WHERE D.DISCLN_USUARIOID = C.CLIN_USUARIOID) AS SERIE,
                          UPPER(C.CLIV_NOMBRES) AS NOMBRE,
                 (SELECT DISTINCT NVL(S.SUSV_CUSTOMERID,
                                      SUBSTR(TRIM(S.SUSV_LINEA), 1, INSTR(S.SUSV_LINEA, '0;') - 1))
                    FROM IOT.IOTT_SUSCRIPCION S
                   WHERE S.SUSN_USUARIOID = C.CLIN_USUARIOID) AS CUSTOMERID,
                          C.CLIN_USUARIOID AS CUSTOMER_AMCO,
                          C.CLIV_CORREO AS CORREO,
                          C.CLID_CREATE_DATE AS FECHA_ACTIVACION,
                 DECODE(C.CLIC_ESTADO, 'A', 'Activo', 'D', 'Desactivo') AS ESTADO
            FROM IOT.IOTT_CLIENTE C
           WHERE C.CLIN_USUARIOID = PI_VALOR_BUSQUEDA
       AND C.CLIC_ESTADO IN ('A', 'D');
      ELSE
        RAISE V_EXCEPTION_DATOS;
      END IF;
    ELSE
      RAISE V_EXCEPTION_BUSQUEDA;
    END IF;
    PO_CODRPTA := '0';
    PO_MSJRPTA := 'Operacion exitosa';
  EXCEPTION
    WHEN V_EXCEPTION_DATOS THEN
      PO_CODRPTA := -1;
      PO_MSJRPTA := '[IOTSS_CLIENTE] - No se encontraron datos: ' || SQLERRM;
      OPEN PO_CURSOR FOR
        SELECT '' SERIE,
               '' NOMBRE,
               '' CUSTOMERID,
               '' CUSTOMER_AMCO,
               '' CORREO,
               '' FECHA_ACTIVACION,
               '' ESTADO
          FROM DUAL
         WHERE ROWNUM < 1;
    WHEN V_EXCEPTION_BUSQUEDA THEN
      PO_CODRPTA := -1;
      PO_MSJRPTA := '[IOTSS_CLIENTE] - Tipo de consulta invalido: ' || SQLERRM;
      OPEN PO_CURSOR FOR
        SELECT '' SERIE,
               '' NOMBRE,
               '' CUSTOMERID,
               '' CUSTOMER_AMCO,
               '' CORREO,
               '' FECHA_ACTIVACION,
               '' ESTADO
          FROM DUAL
         WHERE ROWNUM < 1;
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := '[IOTSS_CLIENTE] - Error al consultar clientes: ' || SQLERRM;
      OPEN PO_CURSOR FOR
        SELECT '' SERIE,
               '' NOMBRE,
               '' CUSTOMERID,
               '' CUSTOMER_AMCO,
               '' CORREO,
               '' FECHA_ACTIVACION,
               '' ESTADO
          FROM DUAL
         WHERE ROWNUM < 1;
  END IOTSS_CLIENTE;

   /****************************************************************
  * Nombre SP          : IOTSS_VALIDAR_PRODUCTID_INCLUIDO_PLAN
  * Proposito          : SP que obtiene el productId que se debe activar de un producto que esta incluido en el plan.
  *
  * Input               :PI_PLAN            - plan de la linea (ASIS)
                        :PI_PLAN_POID       - po de la linea (TOBE)
                        :PI_LINEA           - Linea
                        :PI_PRODUCTID       - productId
                        :PI_PRODUCTID_NOM   - nombre del Producto
                        :PI_TIPO_LINEA      - Tipo de linea
  * Output              :PO_PRODUCTID       - productId que se debe activar
  *                     :PO_PRODUCTID_NOM   - nombre del Producto a activar
  *                     :PO_CODRPTA         - Indica si el procedure termino exitosamente o no.
  *                     :PO_MSJRPTA         - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : Hitss
  * Actualizado por    :
  * Fec Creacion       : 24/07/2025
  * Fec Actualizacion  :
  ***************************************************************/
  PROCEDURE IOTSS_VALID_PRODUCTID_INCL_PLAN(PI_PLAN   IN IOTCT_PLANES.PLNN_TMCOD%TYPE,
                                        PI_PLAN_POID     IN VARCHAR2,
                                        PI_LINEA         IN IOTT_SUSCRIPCION.SUSV_LINEA%TYPE,
                                        PI_PRODUCTID     IN IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PI_PRODUCTID_NOM IN IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                        PI_TIPO_LINEA    IN VARCHAR2,
                                        PO_PRODUCTID     OUT IOTCT_SERVICIO.SERVN_SERVICEID%TYPE,
                                        PO_PRODUCTID_NOM OUT IOTCT_SERVICIO.SERVV_NOMBRE%TYPE,
                                        PO_CODRPTA       OUT VARCHAR2,
                                        PO_MSJRPTA       OUT VARCHAR2) IS

  
  V_CONT_PLAN      NUMBER := 0;

  BEGIN

     PO_CODRPTA := '0';
       PO_MSJRPTA := 'Consulta exitosa';

    --Validar si el plan tiene incluido el producto

     SELECT COUNT(1)
              INTO V_CONT_PLAN
         FROM IOTCT_PLANES P
         JOIN IOTCT_SERVICIO S
           ON P.PLNN_SERVICEID = S.SERVN_SERVICEID
        WHERE (P.PLNN_TMCOD = PI_PLAN OR P.PLNN_POID = PI_PLAN_POID)
          AND S.SERVV_NOMBRE = PI_PRODUCTID_NOM
          AND S.SERVV_TIPO = C_AMCO_BONO
      AND P.PLNC_ESTADO = '1';

    IF V_CONT_PLAN > 0 THEN

       SELECT S.SERVN_SERVICEID,S.SERVV_NOMBRE
                INTO PO_PRODUCTID, PO_PRODUCTID_NOM
           FROM IOTCT_SERVICIO S
          WHERE S.SERVV_NOMBRE = PI_PRODUCTID_NOM
            AND S.SERVV_TIPO = C_AMCO_BONO;
    ELSE
     
       SELECT S.SERVN_SERVICEID, S.SERVV_NOMBRE
                INTO PO_PRODUCTID, PO_PRODUCTID_NOM
          FROM IOTCT_SERVICIO S
         WHERE S.SERVV_NOMBRE = PI_PRODUCTID_NOM
               AND S.SERVV_TIPO = C_AMCO_PAGA;

     END IF;

    EXCEPTION
        WHEN OTHERS THEN
          PO_CODRPTA := '-1';
          PO_MSJRPTA := 'Error SP: IOTSS_VALID_PRODUCTID_INCL_PLAN - ' || SQLCODE || ' : ' || SQLERRM;


  END IOTSS_VALID_PRODUCTID_INCL_PLAN;
  
  /****************************************************************
  * Nombre SP          : IOTSS_BONOS_X_PLAN
  * Proposito          : SP que obtiene el productId que corresponden a BONO que esta incluido en el plan.
  *
  * Input              :PI_COD_PLAN        - TMCODE de la linea (ASIS) / PO de la linea (TOBE)
  *                    :PI_TIPO_PLAN       - Tipo de Plan (TMCODE o POID)
  * Output             :PO_CURSOR_BONOS    - Lista de bonos asociados al plan
  *                    :PO_CODRPTA         - Indica si el procedure termino exitosamente o no.
  *                    :PO_MSJRPTA         - Indica la descripcion del codigo de respuesta.
  *
  * Creado por         : Hitss
  * Actualizado por    :
  * Fec Creacion       : 18/06/2026
  * Fec Actualizacion  :
  ***************************************************************/
  PROCEDURE IOTSS_BONOS_X_PLAN(PI_COD_PLAN      IN VARCHAR2,
                               PI_TIPO_PLAN     IN VARCHAR2,
                               PO_CODRPTA       OUT VARCHAR2,
                               PO_MSJRPTA       OUT VARCHAR2,
                               PO_CURSOR_BONOS  OUT C_REF_CURSOR) IS
     
     V_TIPO_PLAN          VARCHAR2(20);
     V_EXCEPTION_BUSQUEDA EXCEPTION;
  BEGIN

    IF PI_COD_PLAN IS NULL THEN
      RAISE V_EXCEPTION_BUSQUEDA;
    END IF;
    
    IF PI_TIPO_PLAN IS NOT NULL THEN
      V_TIPO_PLAN := PI_TIPO_PLAN;
    ELSE
      IF REGEXP_LIKE(PI_COD_PLAN, '^[0-9]+$') THEN
        V_TIPO_PLAN := 'TMCODE';
      ELSE
        V_TIPO_PLAN := 'POID';
      END IF;
    END IF;

    IF V_TIPO_PLAN = 'TMCODE' THEN
        
        OPEN PO_CURSOR_BONOS FOR
          SELECT DISTINCT P.PLNN_TMCOD, P.PLNN_POID, P.PLNV_DESCRIPCION_PLAN,
                          S.SERVN_SERVICEID, S.SERVV_NOMBRE, S.SERVV_TIPO, S.SERVD_PRECIO
          FROM IOT.IOTCT_PLANES P, IOT.IOTCT_SERVICIO S
          WHERE P.PLNN_SERVICEID = S.SERVN_SERVICEID
          AND P.PLNN_TMCOD = PI_COD_PLAN
          AND P.PLNC_ESTADO = '1';

     ELSIF V_TIPO_PLAN = 'POID' THEN

         OPEN PO_CURSOR_BONOS FOR
          SELECT DISTINCT P.PLNN_TMCOD, P.PLNN_POID, P.PLNV_DESCRIPCION_PLAN,
                          S.SERVN_SERVICEID, S.SERVV_NOMBRE, S.SERVV_TIPO, S.SERVD_PRECIO
          FROM IOT.IOTCT_PLANES P, IOT.IOTCT_SERVICIO S
          WHERE P.PLNN_SERVICEID = S.SERVN_SERVICEID
          AND P.PLNN_POID = PI_COD_PLAN
          AND P.PLNC_ESTADO = '1';
            
     END IF;

     PO_CODRPTA := '0';
     PO_MSJRPTA := 'Consulta Exitosa';

  EXCEPTION
    WHEN V_EXCEPTION_BUSQUEDA THEN
      PO_CODRPTA := '1';
      PO_MSJRPTA :=  'Parametros incompletos [PI_COD_PLAN]';
      OPEN PO_CURSOR_BONOS FOR
        SELECT '' AS PLNN_TMCOD,
               '' AS PLNN_POID,
               '' AS PLNV_DESCRIPCION_PLAN,
               '' AS SERVN_SERVICEID,
               '' AS SERVV_NOMBRE,
               '' AS SERVV_TIPO,
               '' AS SERVD_PRECIO
          FROM DUAL
          WHERE 1 = 0;
          
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error al obtener los datos :'|| SQLCODE ||'-'|| SQLERRM;
      OPEN PO_CURSOR_BONOS FOR
        SELECT '' AS PLNN_TMCOD,
               '' AS PLNN_POID,
               '' AS PLNV_DESCRIPCION_PLAN,
               '' AS SERVN_SERVICEID,
               '' AS SERVV_NOMBRE,
               '' AS SERVV_TIPO,
               '' AS SERVD_PRECIO
          FROM DUAL
          WHERE 1 = 0;
  END;

  /****************************************************************
  * Nombre SP          : IOTSS_OBTENER_SERVICIOS_CONFIG
  * Proposito          : SP que obtiene las configuraciones para Claro Video
  *
  * Input              :PI_COD_GRUPO        - Grupo de configuraciones
  * Output             :PI_VALOR1           - Parametro 1 de busqueda
  *                    :PI_VALOR2           - Parametro 2 de busqueda
  *                    :PI_VALOR3           - Parametro 3 de busqueda
  *                    :PI_VALOR4           - Parametro 4 de busqueda
  *                    :PI_VALOR5           - Parametro 5 de busqueda
  *                    :PO_CODRPTA          - Indica si el procedure termino exitosamente o no.
  *                    :PO_MSJRPTA          - Indica la descripcion del codigo de respuesta.
  *                    :PO_CURSOR_LISTA     - Lista de configuraciones
  * Creado por         : Hitss
  * Actualizado por    :
  * Fec Creacion       : 18/06/2026
  * Fec Actualizacion  :
  ***************************************************************/
  PROCEDURE IOTSS_OBTENER_SERVICIOS_CONFIG(PI_COD_GRUPO    IN  VARCHAR2,
                                           PI_VALOR1       IN  VARCHAR2,
                                           PI_VALOR2       IN  VARCHAR2,
                                           PI_VALOR3       IN  VARCHAR2,
                                           PI_VALOR4       IN  VARCHAR2,
                                           PI_VALOR5       IN  VARCHAR2,
                                           PO_CODRPTA      OUT VARCHAR2,
                                           PO_MSJRPTA      OUT VARCHAR2,
                                           PO_CURSOR_LISTA OUT C_REF_CURSOR) AS
     V_EXCEPTION_BUSQUEDA  EXCEPTION;
  BEGIN

      IF TRIM(PI_COD_GRUPO) IS NULL THEN
         RAISE V_EXCEPTION_BUSQUEDA; 
      END IF;

      OPEN PO_CURSOR_LISTA FOR
          SELECT
              CONFV_SERVICIO AS PO_CONFV_SERVICIO,
              CONFV_DESCRIP  AS PO_CONFV_DESCRIP,
              CONFV_VALOR1   AS PO_CONFV_VALOR1,
              CONFV_VALOR2   AS PO_CONFV_VALOR2,
              CONFV_VALOR3   AS PO_CONFV_VALOR3,
              CONFV_VALOR4   AS PO_CONFV_VALOR4,
              CONFV_VALOR5   AS PO_CONFV_VALOR5
          FROM IOT.IOTT_CONFIGURACION
          WHERE CONFV_SERVICIO = PI_COD_GRUPO
            AND (PI_VALOR1 IS NULL OR CONFV_VALOR1 = PI_VALOR1)
            AND (PI_VALOR2 IS NULL OR CONFV_VALOR2 = PI_VALOR2)
            AND (PI_VALOR3 IS NULL OR CONFV_VALOR3 = PI_VALOR3)
            AND (PI_VALOR4 IS NULL OR CONFV_VALOR4 = PI_VALOR4)
            AND (PI_VALOR5 IS NULL OR CONFV_VALOR5 = PI_VALOR5);

      PO_CODRPTA := '0';
      PO_MSJRPTA := 'Consulta exitosa.';
      
  EXCEPTION
    WHEN V_EXCEPTION_BUSQUEDA THEN
      PO_CODRPTA := '1';
      PO_MSJRPTA := 'Parámetros incompletos [PI_COD_GRUPO].';
      OPEN PO_CURSOR_LISTA FOR
        SELECT '' AS PO_CONFV_SERVICIO,
               '' AS PO_CONFV_DESCRIP,
               '' AS PO_CONFV_VALOR1,
               '' AS PO_CONFV_VALOR2,
               '' AS PO_CONFV_VALOR3,
               '' AS PO_CONFV_VALOR4,
               '' AS PO_CONFV_VALOR5
          FROM DUAL
          WHERE 1 = 0;
          
    WHEN OTHERS THEN
      PO_CODRPTA := '-1';
      PO_MSJRPTA := 'Error al obtener los datos :'||SQLCODE || ' - ' || SQLERRM;
        
      OPEN PO_CURSOR_LISTA FOR
        SELECT '' AS PO_CONFV_SERVICIO,
               '' AS PO_CONFV_DESCRIP,
               '' AS PO_CONFV_VALOR1,
               '' AS PO_CONFV_VALOR2,
               '' AS PO_CONFV_VALOR3,
               '' AS PO_CONFV_VALOR4,
               '' AS PO_CONFV_VALOR5
          FROM DUAL
          WHERE 1 = 0;
  END IOTSS_OBTENER_SERVICIOS_CONFIG;
end PKG_HUB_IOT;
/
