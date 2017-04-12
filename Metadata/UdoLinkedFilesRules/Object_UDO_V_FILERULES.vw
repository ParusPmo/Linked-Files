/* ������� �������������� ������ (���������� �������������) */
create or replace force view UDO_V_FILERULES
(
  NRN,                                  -- ���������������  �����
  NCOMPANY,                             -- �����������  (������ �� COMPANIES(RN))
  SUNITCODE,                            -- ������ �������
  NFILESTORE,                           -- ����� ��������
  NMAXFILES,                            -- ������������ ���-�� �������������� � ������ ������ (0 - ������������)
  NMAXFILESIZE,                         -- ������������ ������ ��������������� ����� (�����) (0 - ������������)
  NLIFETIME,                            -- ���� �������� ����� (���) (0 - ������������)
  SFILESTORE,                           -- ������ ��������
  SUNITNAME,                            -- ������ (������������)
  NBLOCKED                              -- ������������� ����������
)
as
select
  T.RN,                                 -- NRN
  T.COMPANY,                            -- NCOMPANY
  T.UNITCODE,                           -- SUNITCODE
  T.FILESTORE,                          -- NFILESTORE
  T.MAXFILES,                           -- NMAXFILES
  T.MAXFILESIZE,                        -- NMAXFILESIZE
  T.LIFETIME,                           -- NLIFETIME
  U.CODE,                               -- SFILESTORE
  (select RS.TEXT from V_RESOURCES_LOCAL RS where RS.TABLE_NAME = 'UNITLIST' and RS.COLUMN_NAME = 'UNITNAME' and RS.RN = U.RN), -- SUNITNAME
  T.BLOCKED                             -- NBLOCKED
from
  UDO_FILERULES T,
  UDO_FILESTORES U,
  UNITLIST U2
where T.FILESTORE = U.RN
  and T.UNITCODE = U2.UNITCODE
  and exists (select null from V_USERPRIV UP where UP.COMPANY = T.COMPANY and UP.UNITCODE = 'UdoLinkedFilesRules');
