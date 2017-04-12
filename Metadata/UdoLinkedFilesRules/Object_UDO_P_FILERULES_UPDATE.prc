create or replace procedure UDO_P_FILERULES_UPDATE
(
  NRN          in number,   -- Регистрационный  номер
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  SFILESTORE   in varchar2, -- Место хранения
  NMAXFILES    in number,   -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE in number,   -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME    in number    -- Срок хранения файла (мес) (0 - неограничено)
) as
  NFILESTORE PKG_STD.TREF; -- Место хранения
  LFILERULE  UDO_FILERULES%rowtype;
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
                   'UDO_FILERULES_UPDATE',
                   'UDO_FILERULES',
                   NRN);

  /* Разрешение ссылок */
  UDO_P_FILERULES_JOINS(NCOMPANY, SFILESTORE, null, NFILESTORE, PKG_STD.VSTRING);

  /* Базовое исправление */
  UDO_P_FILERULES_BASE_UPDATE(NRN,
                              NCOMPANY,
                              NFILESTORE,
                              NMAXFILES,
                              NMAXFILESIZE,
                              NLIFETIME);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UPDATE',
                   'UDO_FILERULES',
                   NRN);
end;

/
