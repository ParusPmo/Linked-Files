/* ������� ����� �������� */
create or replace trigger UDO_T_FILEFOLDERS_ADELETE
  after delete on UDO_FILEFOLDERS for each row
begin
  /* �������������� ��������� ����� �������� ������ ������� */
  P_LOG_DELETE( :old.RN,'UdoFileStoreFolders' );
end;
/
show errors trigger UDO_T_FILEFOLDERS_ADELETE;
