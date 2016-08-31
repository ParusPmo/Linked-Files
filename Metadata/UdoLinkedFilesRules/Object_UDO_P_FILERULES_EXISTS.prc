/* Считывание записи */
create or replace procedure UDO_P_FILERULES_EXISTS
(
  NRN       in number,                -- Регистрационный  номер
  NCOMPANY  in number,                -- Организация  (ссылка на COMPANIES(RN))
  RFILERULE out UDO_FILERULES%rowtype -- запись связи с разделом
) as
begin
  /* поиск записи */
  begin
    select *
      into RFILERULE
      from UDO_FILERULES
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFilesRules');
  end;
end;
/
show errors procedure UDO_P_FILERULES_EXISTS;
