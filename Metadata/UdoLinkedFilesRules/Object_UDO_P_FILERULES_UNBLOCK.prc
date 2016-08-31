create or replace procedure UDO_P_FILERULES_UNBLOCK
(
  NRN      in number, -- Регистрационный  номер
  NCOMPANY in number -- Организация  (ссылка на COMPANIES(RN))
) as
  LFILERULE UDO_FILERULES%rowtype;
begin
  /* Считывание записи */
  UDO_P_FILERULES_EXISTS(NRN, NCOMPANY, LFILERULE);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UNBLOCK',
                   'UDO_FILERULES',
                   NRN);

  /* Базовое удаление */
  UDO_P_FILERULES_BASE_STATUS(NRN, NCOMPANY, 0);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UNBLOCK',
                   'UDO_FILERULES',
                   NRN);
end;
/
