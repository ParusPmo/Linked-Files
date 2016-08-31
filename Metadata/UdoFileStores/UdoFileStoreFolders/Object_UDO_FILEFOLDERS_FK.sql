/* ���� ������� ������ */
alter table UDO_FILEFOLDERS
add
(
-- ������ �� ������������
constraint UDO_C_FILEFOLDERS_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- ������ �� ��������� ��������
constraint UDO_C_FILEFOLDERS_CRN_FK foreign key (CRN)
  references ACATALOG(RN),
-- ������ �� ��������
constraint UDO_C_FILEFOLDERS_PRN_FK foreign key (PRN)
  references UDO_FILESTORES(RN) on delete cascade
);
