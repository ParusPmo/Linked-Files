/* ������� ����� ����������� */
create or replace trigger UDO_T_LINKEDDOCS_AUPDATE
  after update on UDO_LINKEDDOCS for each row
begin
  /* �������������� ��������� ����� ����������� ������ ������� */
  P_LOG_UPDATE( :new.RN,'UdoLinkedFiles',null,null,null,null );
end;
/
show errors trigger UDO_T_LINKEDDOCS_AUPDATE;
