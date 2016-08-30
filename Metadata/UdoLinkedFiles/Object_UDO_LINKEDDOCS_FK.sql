/* ���� ������� ������ */
alter table UDO_LINKEDDOCS
add
(
-- ����� � �������� �������������
constraint UDO_C_LINKEDDOCS_AUTHID_FK foreign key (AUTHID)
  references USERLIST(AUTHID),
-- ������ �� ������������
constraint UDO_C_LINKEDDOCS_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- ����� � �������� ������ �������� ������ (�����)�
constraint UDO_C_LINKEDDOCS_FILESTORE_FK foreign key (FILESTORE)
  references UDO_FILEFOLDERS(RN),
-- ����� � �������� �������� ��������
constraint UDO_C_LINKEDDOCS_UNIT_FK foreign key (UNITCODE)
  references UNITLIST(UNITCODE)
);
