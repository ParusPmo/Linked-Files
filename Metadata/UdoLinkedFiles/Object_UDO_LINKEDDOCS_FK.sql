/* Блок внешних ключей */
alter table UDO_LINKEDDOCS
add
(
-- Связь с разделом «Пользователи»
constraint UDO_C_LINKEDDOCS_AUTHID_FK foreign key (AUTHID)
  references USERLIST(AUTHID),
-- Ссылка на «Организации»
constraint UDO_C_LINKEDDOCS_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- Связь с разделом «Места хранения файлов (папки)»
constraint UDO_C_LINKEDDOCS_FILESTORE_FK foreign key (FILESTORE)
  references UDO_FILEFOLDERS(RN),
-- Связь с разделом «Разделы системы»
constraint UDO_C_LINKEDDOCS_UNIT_FK foreign key (UNITCODE)
  references UNITLIST(UNITCODE)
);
