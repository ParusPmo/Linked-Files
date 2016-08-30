/* Блок внешних ключей */
alter table UDO_FILERULES
add
(
-- Ссылка на «Организации»
constraint UDO_C_FILERULES_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- Связь с разделом «Места хранения присоединенных файлов»
constraint UDO_C_FILERULES_FILESTORE_FK foreign key (FILESTORE)
  references UDO_FILESTORES(RN),
-- Связь с действиями системы
constraint UDO_C_FILERULES_UNITFUNC_FK foreign key (UNITFUNC)
  references UNITFUNC(RN),
-- Связь с разделом «Разделы системы»
constraint UDO_C_FILERULES_UNIT_FK foreign key (UNITCODE)
  references UNITLIST(UNITCODE)
);
