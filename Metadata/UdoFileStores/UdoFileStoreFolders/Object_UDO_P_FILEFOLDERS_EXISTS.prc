/* ���������� ������ */
create or replace procedure UDO_P_FILEFOLDERS_EXISTS
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NCRN                      out number       -- �������  (������ �� ACATALOG(RN))
)
as
begin
  /* ����� ������ */
  begin
    select CRN
      into NCRN
      from UDO_FILEFOLDERS
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStoreFolders' );
  end;
end;
/
show errors procedure UDO_P_FILEFOLDERS_EXISTS;
