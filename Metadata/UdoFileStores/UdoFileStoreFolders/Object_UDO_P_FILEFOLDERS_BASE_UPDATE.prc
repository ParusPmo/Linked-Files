/* ������� ����������� */
create or replace procedure UDO_P_FILEFOLDERS_BASE_UPDATE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  SNAME                     in varchar2,     -- ������������ �����
  NFILECNT                  in number        -- ���������� ������ � �����
)
as
begin
  /* ����������� ������ � ������� */
  update UDO_FILEFOLDERS
     set NAME = SNAME,
         FILECNT = NFILECNT
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStoreFolders' );
  end if;
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_UPDATE;
