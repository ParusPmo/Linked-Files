create or replace procedure UDO_P_FILESTORES_UPDATE
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
  LFILESTORE      UDO_FILESTORES%rowtype;    -- ������ ����� ��������
  LORA_DIRECTORY  UDO_FILESTORES.ORA_DIRECTORY%type;
  LDOMAINNAME     UDO_FILESTORES.DOMAINNAME%type;
  LIPADDRESS      UDO_FILESTORES.IPADDRESS%type;
  LPORT           UDO_FILESTORES.PORT%type;
  LUSERNAME       UDO_FILESTORES.USERNAME%type;
  LPASSWORD       UDO_FILESTORES.PASSWORD%type;
  LROOTFOLDER     UDO_FILESTORES.ROOTFOLDER%type;

begin
  /* ���������� ������ */
  UDO_P_FILESTORES_EXISTS
  (
    NRN,
    NCOMPANY,
    LFILESTORE
  );

  if LFILESTORE.STORE_TYPE = 1 then
    LORA_DIRECTORY := SORA_DIRECTORY;
    LDOMAINNAME    := null;
    LIPADDRESS     := null;
    LPORT          := null;
    LUSERNAME      := null;
    LPASSWORD      := null;
    LROOTFOLDER    := null;
  elsif LFILESTORE.STORE_TYPE = 2 then
    LORA_DIRECTORY := null;
    LDOMAINNAME    := SDOMAINNAME;
    LIPADDRESS     := SIPADDRESS;
    LPORT          := NPORT;
    LUSERNAME      := SUSERNAME;
    LPASSWORD      := SPASSWORD;
    LROOTFOLDER    := SROOTFOLDER;
  end if;

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_UPDATE','UDO_FILESTORES',NRN );

  /* ������� ����������� */
  UDO_P_FILESTORES_BASE_UPDATE
  (
    NRN,
    NCOMPANY,
    SCODE,
    SNAME,
    LORA_DIRECTORY,
    LDOMAINNAME,
    LIPADDRESS,
    LPORT,
    LUSERNAME,
    LPASSWORD,
    LROOTFOLDER,
    NMAXFILES,
    SNOTE
  );

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_UPDATE','UDO_FILESTORES',NRN );
end;

/
