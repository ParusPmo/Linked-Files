/* ����� �������� �������������� ������ (�����) (���������� �������������) */
create or replace force view UDO_V_FILEFOLDERS
(
  NRN,                                  -- ���������������  �����
  NCOMPANY,                             -- �����������  (������ �� COMPANIES(RN))
  NCRN,                                 -- �������  (������ �� ACATALOG(RN))
  NPRN,                                 -- ��������������� ����� ������������ ������
  SNAME,                                -- ������������ �����
  NFILECNT                              -- ���������� ������ � �����
)
as
select
  T.RN,                                 -- NRN
  T.COMPANY,                            -- NCOMPANY
  T.CRN,                                -- NCRN
  T.PRN,                                -- NPRN
  T.NAME,                               -- SNAME
  T.FILECNT                             -- NFILECNT
from
  UDO_FILEFOLDERS T
where exists (select null from V_USERPRIV UP where UP.CATALOG = T.CRN);
