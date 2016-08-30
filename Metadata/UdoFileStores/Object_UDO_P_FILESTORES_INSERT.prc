create or replace procedure UDO_P_FILESTORES_INSERT
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
  LORA_DIRECTORY  UDO_FILESTORES.ORA_DIRECTORY%type;
  LDOMAINNAME     UDO_FILESTORES.DOMAINNAME%type;
  LIPADDRESS      UDO_FILESTORES.IPADDRESS%type;
  LPORT           UDO_FILESTORES.PORT%type;
  LUSERNAME       UDO_FILESTORES.USERNAME%type;
  LPASSWORD       UDO_FILESTORES.PASSWORD%type;
  LROOTFOLDER     UDO_FILESTORES.ROOTFOLDER%type;

begin

  if NSTORE_TYPE = 1 then
    LORA_DIRECTORY := SORA_DIRECTORY;
    LDOMAINNAME    := null;
    LIPADDRESS     := null;
    LPORT          := null;
    LUSERNAME      := null;
    LPASSWORD      := null;
    LROOTFOLDER    := null;
  elsif NSTORE_TYPE = 2 then
    LORA_DIRECTORY := null;
    LDOMAINNAME    := SDOMAINNAME;
    LIPADDRESS     := SIPADDRESS;
    LPORT          := NPORT;
    LUSERNAME      := SUSERNAME;
    LPASSWORD      := SPASSWORD;
    LROOTFOLDER    := SROOTFOLDER;
  end if;

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE( NCOMPANY,null,NCRN,null,null,'UdoFileStores','UDO_FILESTORES_INSERT','UDO_FILESTORES' );

  /* ������� ���������� */
  UDO_P_FILESTORES_BASE_INSERT
  (
    NCOMPANY,
    NCRN,
    SCODE,
    SNAME,
    NSTORE_TYPE,
    LORA_DIRECTORY,
    LDOMAINNAME,
    LIPADDRESS,
    LPORT,
    LUSERNAME,
    LPASSWORD,
    LROOTFOLDER,
    NMAXFILES,
    SNOTE,
    NRN
  );

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE( NCOMPANY,null,NCRN,null,null,'UdoFileStores','UDO_FILESTORES_INSERT','UDO_FILESTORES',NRN );
end;

/
