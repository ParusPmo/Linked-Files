/* Базовое исправление */
create or replace procedure UDO_P_FILERULES_BASE_UPDATE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  STABLENAME                in varchar2,     -- Имя таблицы раздела
  SCTLGFIELD                in varchar2,     -- Поле дерева каталогов
  SJPERSFIELD               in varchar2,     -- Поле юридического лица
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
         LIFETIME = NLIFETIME,
         TABLENAME = STABLENAME,
         CTLGFIELD = SCTLGFIELD,
         JPERSFIELD = SJPERSFIELD
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoLinkedFilesRules' );
  end if;
end;
/
show errors procedure UDO_P_FILERULES_BASE_UPDATE;
