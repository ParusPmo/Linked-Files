create or replace procedure UDO_P_FILERULES_BASE_UPDATE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  NFILESTORE                in number,       -- Место хранения
  NMAXFILES                 in number,       -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE              in number,       -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME                 in number        -- Срок хранения файла (мес) (0 - неограничено)
)
as
begin
  /* исправление записи в таблице */
  update UDO_FILERULES
     set FILESTORE = NFILESTORE,
         MAXFILES = NMAXFILES,
         MAXFILESIZE = NMAXFILESIZE,
         LIFETIME = NLIFETIME
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoLinkedFilesRules' );
  end if;
end;

/
