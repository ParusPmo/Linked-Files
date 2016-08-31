/* Триггер после исправления */
create or replace trigger UDO_T_FILESTORES_AUPDATE
  after update on UDO_FILESTORES for each row
begin
  /* дополнительная обработка после исправления записи раздела */
  P_LOG_UPDATE( :new.RN,'UdoFileStores',:new.CRN,:old.CRN,null,null );
end;
/
show errors trigger UDO_T_FILESTORES_AUPDATE;
