/* ����� �������� �������������� ������ (���������� �������������) */
create or replace force view UDO_V_FILESTORES
(
  NRN,                                  -- ���������������  �����
  NCOMPANY,                             -- �����������  (������ �� COMPANIES(RN))
  NCRN,                                 -- �������  (������ �� ACATALOG(RN))
  SCODE,                                -- �������� ����� ��������
  SNAME,                                -- ������������ ����� ��������
  NSTORE_TYPE,                          -- ��� ����� ��������
  SORA_DIRECTORY,                       -- ���������� Oracle
  SDOMAINNAME,                          -- �������� ���
  SIPADDRESS,                           -- IP �����
  NPORT,                                -- ���� FTP �������
  SUSERNAME,                            -- ��� ������������
  SPASSWORD,                            -- ������
  SROOTFOLDER,                          -- �������� ����� ��� �������� ������
  NMAXFILES,                            -- ������������ ���������� ������ � �����
  SNOTE                                 -- ����������
)
as
select
  T.RN,                                 -- NRN
  T.COMPANY,                            -- NCOMPANY
  T.CRN,                                -- NCRN
  T.CODE,                               -- SCODE
  T.NAME,                               -- SNAME
  T.STORE_TYPE,                         -- NSTORE_TYPE
  T.ORA_DIRECTORY,                      -- SORA_DIRECTORY
  T.DOMAINNAME,                         -- SDOMAINNAME
  T.IPADDRESS,                          -- SIPADDRESS
  T.PORT,                               -- NPORT
  T.USERNAME,                           -- SUSERNAME
  T.PASSWORD,                           -- SPASSWORD
  T.ROOTFOLDER,                         -- SROOTFOLDER
  T.MAXFILES,                           -- NMAXFILES
  T.NOTE                                -- SNOTE
from
  UDO_FILESTORES T
where exists (select null from V_USERPRIV UP where UP.CATALOG = T.CRN);
