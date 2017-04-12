create or replace procedure UDO_P_FILERULES_INSERT
(
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  SUNITNAME    in varchar2, -- Наименование раздела
  SFILESTORE   in varchar2, -- Место хранения
  NMAXFILES    in number,   -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE in number,   -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME    in number,   -- Срок хранения файла (мес) (0 - неограничено)
  NRN          out number   -- Регистрационный  номер
) as
  NFILESTORE PKG_STD.TREF; -- Место хранения
  SUNITCODE  UNITLIST.UNITCODE%type;
begin
  /* Разрешение ссылок */
  UDO_P_FILERULES_JOINS(NCOMPANY, SFILESTORE, SUNITNAME, NFILESTORE, SUNITCODE);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_INSERT',
                   'UDO_FILERULES');

  /* Базовое добавление */
  UDO_P_FILERULES_BASE_INSERT(NCOMPANY,
                              SUNITCODE,
                              NFILESTORE,
                              NMAXFILES,
                              NMAXFILESIZE,
                              NLIFETIME,
                              NRN);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_INSERT',
                   'UDO_FILERULES',
                   NRN);
end;

/
