/* ������� ����� �������� */
create or replace trigger UDO_T_FILESTORES_ADELETE
  after delete on UDO_FILESTORES for each row
begin
  /* �������������� ��������� ����� �������� ������ ������� */
  P_LOG_DELETE( :old.RN,'UdoFileStores' );
end;
/
show errors trigger UDO_T_FILESTORES_ADELETE;
