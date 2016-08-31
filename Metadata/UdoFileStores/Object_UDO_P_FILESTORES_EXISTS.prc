create or replace procedure UDO_P_FILESTORES_EXISTS
(
  NRN         in number,                 -- ���������������  �����
  NCOMPANY    in number,                 -- �����������  (������ �� COMPANIES(RN))
  FILESTORE   out UDO_FILESTORES%rowtype -- ����� ��������
) as
begin
  /* ����� ������ */
  begin
    select *
      into FILESTORE
      from UDO_FILESTORES
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoFileStores');
  end;
end;
/
