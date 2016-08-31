create or replace procedure UDO_P_FILESTORES_BASE_UPDATE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  SCODE                     in varchar2,     -- �������� ����� ��������
  SNAME                     in varchar2,     -- ������������ ����� ��������
  SORA_DIRECTORY            in varchar2,     -- ���������� Oracle
  SDOMAINNAME               in varchar2,     -- �������� ���
  SIPADDRESS                in varchar2,     -- IP �����
  NPORT                     in number,       -- ���� FTP �������
  SUSERNAME                 in varchar2,     -- ��� ������������
  SPASSWORD                 in varchar2,     -- ������
  SROOTFOLDER               in varchar2,     -- �������� ����� ��� �������� ������
  NMAXFILES                 in number,       -- ������������ ���������� ������ � �����
  SNOTE                     in varchar2      -- ����������
)
as
begin
  /* ����������� ������ � ������� */
  update UDO_FILESTORES
     set CODE = SCODE,
         NAME = SNAME,
         ORA_DIRECTORY = SORA_DIRECTORY,
         DOMAINNAME = SDOMAINNAME,
         IPADDRESS = SIPADDRESS,
         PORT = NPORT,
         USERNAME = SUSERNAME,
         PASSWORD = SPASSWORD,
         ROOTFOLDER = SROOTFOLDER,
         MAXFILES = NMAXFILES,
         NOTE = SNOTE
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStores' );
  end if;
end;

/
