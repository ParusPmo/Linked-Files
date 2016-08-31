create or replace procedure UDO_P_FILERULES_GET_ATTRIB
(
  NRN       in number,
  SUNITNAME out varchar2
) is
  cursor LC_REC is
    select T.RN,
           (select RS.TEXT
              from V_RESOURCES_LOCAL RS
             where RS.TABLE_NAME = 'UNITLIST'
               and RS.COLUMN_NAME = 'UNITNAME'
               and RS.RN = U.RN) as SUNITNAME
      from UDO_FILERULES T,
           UNITLIST      U
     where T.UNITCODE = U.UNITCODE
       and exists (select null
              from V_USERPRIV UP
             where UP.COMPANY = T.COMPANY
               and UP.UNITCODE = 'UdoLinkedFilesRules');
  L_REC LC_REC%rowtype;
begin
  open LC_REC;
  fetch LC_REC
    into L_REC;
  close LC_REC;
  if L_REC.RN is null then
    PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NRN, SUNIT_TABLE => 'UDO_FILERULES');
  end if;
  SUNITNAME := L_REC.SUNITNAME;
end UDO_P_FILERULES_GET_ATTRIB;
/
