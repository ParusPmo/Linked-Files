/* ������� ����� �������� */
create or replace trigger UDO_T_LINKEDDOCS_ADELETE
  after delete on UDO_LINKEDDOCS for each row
begin
  /* �������������� ��������� ����� �������� ������ ������� */
  P_LOG_DELETE( :old.RN,'UdoLinkedFiles' );
end;
/
show errors trigger UDO_T_LINKEDDOCS_ADELETE;
