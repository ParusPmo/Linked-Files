/* Блок внешних ключей */
alter table UDO_FILEFOLDERS
add
(
-- Ссылка на «Организации»
constraint UDO_C_FILEFOLDERS_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- Ссылка на «Каталоги иерархии»
constraint UDO_C_FILEFOLDERS_CRN_FK foreign key (CRN)
  references ACATALOG(RN),
-- Ссылка на родителя
constraint UDO_C_FILEFOLDERS_PRN_FK foreign key (PRN)
  references UDO_FILESTORES(RN) on delete cascade
);
