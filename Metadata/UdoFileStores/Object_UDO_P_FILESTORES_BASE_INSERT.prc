/* ������� ���������� */
create or replace procedure UDO_P_FILESTORES_BASE_INSERT
(
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NCRN                      in number,       -- �������  (������ �� ACATALOG(RN))
  SCODE                     in varchar2,     -- �������� ����� ��������
  SNAME                     in varchar2,     -- ������������ ����� ��������
  NSTORE_TYPE               in number,       -- ��� ����� ��������
  SORA_DIRECTORY            in varchar2,     -- ���������� Oracle
  SDOMAINNAME               in varchar2,     -- �������� ���
  SIPADDRESS                in varchar2,     -- IP �����
  NPORT                     in number,       -- ���� FTP �������
  SUSERNAME                 in varchar2,     -- ��� ������������
  SPASSWORD                 in varchar2,     -- ������
  SROOTFOLDER               in varchar2,     -- �������� ����� ��� �������� ������
  NMAXFILES                 in number,       -- ������������ ���������� ������ � �����
  SNOTE                     in varchar2,     -- ����������
  NRN                       out number       -- ���������������  �����
)
as
begin
  /* ��������� ���������������� ������ */
  NRN := gen_id;

  /* ���������� ������ � ������� */
  insert into UDO_FILESTORES
  (
    RN,
    COMPANY,
    CRN,
    CODE,
    NAME,
    STORE_TYPE,
    ORA_DIRECTORY,
    DOMAINNAME,
    IPADDRESS,
    PORT,
    USERNAME,
    PASSWORD,
    ROOTFOLDER,
    MAXFILES,
    NOTE
  )
  values
  (
    NRN,
    NCOMPANY,
    NCRN,
    SCODE,
    SNAME,
    NSTORE_TYPE,
    SORA_DIRECTORY,
    SDOMAINNAME,
    SIPADDRESS,
    NPORT,
    SUSERNAME,
    SPASSWORD,
    SROOTFOLDER,
    NMAXFILES,
    SNOTE
  );
end;
/
show errors procedure UDO_P_FILESTORES_BASE_INSERT;
