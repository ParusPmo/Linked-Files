create or replace procedure UDO_P_FILESTORES_BASE_UPDATE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  SCODE                     in varchar2,     -- Мнемокод места хранения
  SNAME                     in varchar2,     -- Наименование места хранения
  SORA_DIRECTORY            in varchar2,     -- Директория Oracle
  SDOMAINNAME               in varchar2,     -- Доменное имя
  SIPADDRESS                in varchar2,     -- IP адрес
  NPORT                     in number,       -- Порт FTP сервера
  SUSERNAME                 in varchar2,     -- Имя пользователя
  SPASSWORD                 in varchar2,     -- Пароль
  SROOTFOLDER               in varchar2,     -- Корневая папка для хранения файлов
  NMAXFILES                 in number,       -- Максимальное количество файлов в папке
  SNOTE                     in varchar2      -- Примечание
)
as
begin
  /* исправление записи в таблице */
  update UDO_FILESTORES
     set CODE = SCODE,
         NAME = SNAME,
         ORA_DIRECTORY = SORA_DIRECTORY,
         DOMAINNAME = SDOMAINNAME,
         IPADDRESS = SIPADDRESS,
         PORT = NPORT,
         USERNAME = SUSERNAME,
         PASSWORD = SPASSWORD,
         ROOTFOLDER = SROOTFOLDER,
         MAXFILES = NMAXFILES,
         NOTE = SNOTE
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStores' );
  end if;
end;

/
