/* Базовое добавление */
create or replace procedure UDO_P_FILESTORES_BASE_INSERT
(
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  NCRN                      in number,       -- Каталог  (ссылка на ACATALOG(RN))
  SCODE                     in varchar2,     -- Мнемокод места хранения
  SNAME                     in varchar2,     -- Наименование места хранения
  NSTORE_TYPE               in number,       -- Тип места хранения
  SORA_DIRECTORY            in varchar2,     -- Директория Oracle
  SDOMAINNAME               in varchar2,     -- Доменное имя
  SIPADDRESS                in varchar2,     -- IP адрес
  NPORT                     in number,       -- Порт FTP сервера
  SUSERNAME                 in varchar2,     -- Имя пользователя
  SPASSWORD                 in varchar2,     -- Пароль
  SROOTFOLDER               in varchar2,     -- Корневая папка для хранения файлов
  NMAXFILES                 in number,       -- Максимальное количество файлов в папке
  SNOTE                     in varchar2,     -- Примечание
  NRN                       out number       -- Регистрационный  номер
)
as
begin
  /* генерация регистрационного номера */
  NRN := gen_id;

  /* добавление записи в таблицу */
  insert into UDO_FILESTORES
  (
    RN,
    COMPANY,
    CRN,
    CODE,
    NAME,
    STORE_TYPE,
    ORA_DIRECTORY,
    DOMAINNAME,
    IPADDRESS,
    PORT,
    USERNAME,
    PASSWORD,
    ROOTFOLDER,
    MAXFILES,
    NOTE
  )
  values
  (
    NRN,
    NCOMPANY,
    NCRN,
    SCODE,
    SNAME,
    NSTORE_TYPE,
    SORA_DIRECTORY,
    SDOMAINNAME,
    SIPADDRESS,
    NPORT,
    SUSERNAME,
    SPASSWORD,
    SROOTFOLDER,
    NMAXFILES,
    SNOTE
  );
end;
/
show errors procedure UDO_P_FILESTORES_BASE_INSERT;
