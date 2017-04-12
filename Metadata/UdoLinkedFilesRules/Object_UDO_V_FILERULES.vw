/* Разделы присоединенных файлов (клиентское представление) */
create or replace force view UDO_V_FILERULES
(
  NRN,                                  -- Регистрационный  номер
  NCOMPANY,                             -- Организация  (ссылка на COMPANIES(RN))
  SUNITCODE,                            -- Раздел системы
  NFILESTORE,                           -- Место хранения
  NMAXFILES,                            -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE,                         -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME,                            -- Срок хранения файла (мес) (0 - неограничено)
  SFILESTORE,                           -- Сервер хранения
  SUNITNAME,                            -- Раздел (наименование)
  NBLOCKED                              -- Заблокировать добавление
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
  U.CODE,                               -- SFILESTORE
  (select RS.TEXT from V_RESOURCES_LOCAL RS where RS.TABLE_NAME = 'UNITLIST' and RS.COLUMN_NAME = 'UNITNAME' and RS.RN = U.RN), -- SUNITNAME
  T.BLOCKED                             -- NBLOCKED
from
  UDO_FILERULES T,
  UDO_FILESTORES U,
  UNITLIST U2
where T.FILESTORE = U.RN
  and T.UNITCODE = U2.UNITCODE
  and exists (select null from V_USERPRIV UP where UP.COMPANY = T.COMPANY and UP.UNITCODE = 'UdoLinkedFilesRules');
