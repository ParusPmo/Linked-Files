/* Разрешение ссылок */
create or replace procedure UDO_P_FILERULES_JOINS
(
  NCOMPANY   in number,   -- Регистрационный номер организации
  SFILESTORE in varchar2, -- Место хранения
  SUNITNAME  in varchar2, -- Наименование раздела
  NFILESTORE out number,  -- Место хранения
  SUNITCODE  out varchar2 -- Код раздела
) as
begin
  FIND_UNITLIST_NAME(NFLAG_SMART  => 0,
                     NFLAG_OPTION => 1,
                     SNAME        => SUNITNAME,
                     SCODE        => SUNITCODE,
                     NRN          => PKG_STD.VREF);

  FIND_UDO_FILESTORES_CODE(NFLAG_SMART  => 0,
                           NFLAG_OPTION => 0,
                           NCOMPANY     => NCOMPANY,
                           SCODE        => SFILESTORE,
                           NRN          => NFILESTORE);

end;
/
show errors procedure UDO_P_FILERULES_JOINS;
