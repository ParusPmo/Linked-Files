/* ���� ������� ������ */
alter table UDO_FILERULES
add
(
-- ������ �� ������������
constraint UDO_C_FILERULES_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- ����� � �������� ������ �������� �������������� ������
constraint UDO_C_FILERULES_FILESTORE_FK foreign key (FILESTORE)
  references UDO_FILESTORES(RN),
-- ����� � ���������� �������
constraint UDO_C_FILERULES_UNITFUNC_FK foreign key (UNITFUNC)
  references UNITFUNC(RN),
-- ����� � �������� �������� ��������
constraint UDO_C_FILERULES_UNIT_FK foreign key (UNITCODE)
  references UNITLIST(UNITCODE)
);
