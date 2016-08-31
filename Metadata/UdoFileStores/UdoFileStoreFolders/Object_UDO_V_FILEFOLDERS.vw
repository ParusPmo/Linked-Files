/* Места хранения присоединенных файлов (папки) (клиентское представление) */
create or replace force view UDO_V_FILEFOLDERS
(
  NRN,                                  -- Регистрационный  номер
  NCOMPANY,                             -- Организация  (ссылка на COMPANIES(RN))
  NCRN,                                 -- Каталог  (ссылка на ACATALOG(RN))
  NPRN,                                 -- Регистрационный номер родительской записи
  SNAME,                                -- Наименование папки
  NFILECNT                              -- Количество файлов в папке
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
