/* ���� ������� ������ */
alter table UDO_FILESTORES
add
(
-- ������ �� ������������
constraint UDO_C_FILESTORES_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- ������ �� ��������� ��������
constraint UDO_C_FILESTORES_CRN_FK foreign key (CRN)
  references ACATALOG(RN)
);
