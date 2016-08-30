/* Базовое удаление */
create or replace procedure UDO_P_FILEFOLDERS_BASE_DELETE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number        -- Организация  (ссылка на COMPANIES(RN))
)
as
begin
  /* удаление записи из таблицы */
  delete
    from UDO_FILEFOLDERS
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStoreFolders' );
  end if;
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_DELETE;
