/* ������� ����� ����������� */
create or replace trigger UDO_T_FILERULES_AUPDATE
  after update on UDO_FILERULES for each row
begin
  /* �������������� ��������� ����� ����������� ������ ������� */
  P_LOG_UPDATE( :new.RN,'UdoLinkedFilesRules',null,null,null,null );
end;
/
show errors trigger UDO_T_FILERULES_AUPDATE;
