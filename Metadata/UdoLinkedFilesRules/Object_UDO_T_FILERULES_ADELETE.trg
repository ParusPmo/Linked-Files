/* ������� ����� �������� */
create or replace trigger UDO_T_FILERULES_ADELETE
  after delete on UDO_FILERULES for each row
begin
  /* �������������� ��������� ����� �������� ������ ������� */
  P_LOG_DELETE( :old.RN,'UdoLinkedFilesRules' );
end;
/
show errors trigger UDO_T_FILERULES_ADELETE;
