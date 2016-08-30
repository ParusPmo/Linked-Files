/* Базовое исправление */
create or replace procedure UDO_P_FILEFOLDERS_BASE_UPDATE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  SNAME                     in varchar2,     -- Наименование папки
  NFILECNT                  in number        -- Количество файлов в папке
)
as
begin
  /* исправление записи в таблице */
  update UDO_FILEFOLDERS
     set NAME = SNAME,
         FILECNT = NFILECNT
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStoreFolders' );
  end if;
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_UPDATE;
