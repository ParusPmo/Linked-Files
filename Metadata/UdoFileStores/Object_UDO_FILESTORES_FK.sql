/* Блок внешних ключей */
alter table UDO_FILESTORES
add
(
-- Ссылка на «Организации»
constraint UDO_C_FILESTORES_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- Ссылка на «Каталоги иерархии»
constraint UDO_C_FILESTORES_CRN_FK foreign key (CRN)
  references ACATALOG(RN)
);
