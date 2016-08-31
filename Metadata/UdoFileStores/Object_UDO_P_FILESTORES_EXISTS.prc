create or replace procedure UDO_P_FILESTORES_EXISTS
(
  NRN         in number,                 -- Регистрационный  номер
  NCOMPANY    in number,                 -- Организация  (ссылка на COMPANIES(RN))
  FILESTORE   out UDO_FILESTORES%rowtype -- Место хранения
) as
begin
  /* поиск записи */
  begin
    select *
      into FILESTORE
      from UDO_FILESTORES
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoFileStores');
  end;
end;
/
