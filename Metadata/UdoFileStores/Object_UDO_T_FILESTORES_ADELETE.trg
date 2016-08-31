/* Триггер после удаления */
create or replace trigger UDO_T_FILESTORES_ADELETE
  after delete on UDO_FILESTORES for each row
begin
  /* дополнительная обработка после удаления записи раздела */
  P_LOG_DELETE( :old.RN,'UdoFileStores' );
end;
/
show errors trigger UDO_T_FILESTORES_ADELETE;
