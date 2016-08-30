create or replace procedure UDO_P_FILESTORES_DELETE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number        -- Организация  (ссылка на COMPANIES(RN))
)
as
  LFILESTORE      UDO_FILESTORES%rowtype;    -- Запись места хранения
begin
  /* Считывание записи */
  UDO_P_FILESTORES_EXISTS
  (
    NRN,
    NCOMPANY,
    LFILESTORE
  );

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );

  /* Базовое удаление */
  UDO_P_FILESTORES_BASE_DELETE
  (
    NRN,
    NCOMPANY
  );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );
end;

/
