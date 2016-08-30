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
  NBLOCKED,                             -- ������������� ����������
  STABLENAME,                           -- ��� ������� �������
  SCTLGFIELD,                           -- ���� ������ ���������
  SJPERSFIELD                           -- ���� ������������ ����
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
  S.CODE,                               -- SFILESTORE
  (select RS.TEXT from V_RESOURCES_LOCAL RS where RS.TABLE_NAME = 'UNITLIST' and RS.COLUMN_NAME = 'UNITNAME' and RS.RN = U.RN), -- SUNITNAME
  T.BLOCKED,                            -- NBLOCKED
  T.TABLENAME,                          -- STABLENAME
  T.CTLGFIELD,                          -- SCTLGFIELD
  T.JPERSFIELD                          -- SJPERSFIELD
from
  UDO_FILERULES T,
  UDO_FILESTORES S,
  UNITLIST U
where T.FILESTORE = S.RN
  and T.UNITCODE = U.UNITCODE
  and exists (select null from V_USERPRIV UP where UP.COMPANY = T.COMPANY and UP.UNITCODE = 'UdoLinkedFilesRules');
