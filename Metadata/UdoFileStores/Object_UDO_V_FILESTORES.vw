/* Места хранения присоединенных файлов (клиентское представление) */
create or replace force view UDO_V_FILESTORES
(
  NRN,                                  -- Регистрационный  номер
  NCOMPANY,                             -- Организация  (ссылка на COMPANIES(RN))
  NCRN,                                 -- Каталог  (ссылка на ACATALOG(RN))
  SCODE,                                -- Мнемокод места хранения
  SNAME,                                -- Наименование места хранения
  NSTORE_TYPE,                          -- Тип места хранения
  SORA_DIRECTORY,                       -- Директория Oracle
  SDOMAINNAME,                          -- Доменное имя
  SIPADDRESS,                           -- IP адрес
  NPORT,                                -- Порт FTP сервера
  SUSERNAME,                            -- Имя пользователя
  SPASSWORD,                            -- Пароль
  SROOTFOLDER,                          -- Корневая папка для хранения файлов
  NMAXFILES,                            -- Максимальное количество файлов в папке
  SNOTE                                 -- Примечание
)
as
select
  T.RN,                                 -- NRN
  T.COMPANY,                            -- NCOMPANY
  T.CRN,                                -- NCRN
  T.CODE,                               -- SCODE
  T.NAME,                               -- SNAME
  T.STORE_TYPE,                         -- NSTORE_TYPE
  T.ORA_DIRECTORY,                      -- SORA_DIRECTORY
  T.DOMAINNAME,                         -- SDOMAINNAME
  T.IPADDRESS,                          -- SIPADDRESS
  T.PORT,                               -- NPORT
  T.USERNAME,                           -- SUSERNAME
  T.PASSWORD,                           -- SPASSWORD
  T.ROOTFOLDER,                         -- SROOTFOLDER
  T.MAXFILES,                           -- NMAXFILES
  T.NOTE                                -- SNOTE
from
  UDO_FILESTORES T
where exists (select null from V_USERPRIV UP where UP.CATALOG = T.CRN);
