create or replace procedure UDO_P_FILESTORES_UPDATE
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
  LFILESTORE      UDO_FILESTORES%rowtype;    -- Запись места хранения
  LORA_DIRECTORY  UDO_FILESTORES.ORA_DIRECTORY%type;
  LDOMAINNAME     UDO_FILESTORES.DOMAINNAME%type;
  LIPADDRESS      UDO_FILESTORES.IPADDRESS%type;
  LPORT           UDO_FILESTORES.PORT%type;
  LUSERNAME       UDO_FILESTORES.USERNAME%type;
  LPASSWORD       UDO_FILESTORES.PASSWORD%type;
  LROOTFOLDER     UDO_FILESTORES.ROOTFOLDER%type;

begin
  /* Считывание записи */
  UDO_P_FILESTORES_EXISTS
  (
    NRN,
    NCOMPANY,
    LFILESTORE
  );

  if LFILESTORE.STORE_TYPE = 1 then
    LORA_DIRECTORY := SORA_DIRECTORY;
    LDOMAINNAME    := null;
    LIPADDRESS     := null;
    LPORT          := null;
    LUSERNAME      := null;
    LPASSWORD      := null;
    LROOTFOLDER    := null;
  elsif LFILESTORE.STORE_TYPE = 2 then
    LORA_DIRECTORY := null;
    LDOMAINNAME    := SDOMAINNAME;
    LIPADDRESS     := SIPADDRESS;
    LPORT          := NPORT;
    LUSERNAME      := SUSERNAME;
    LPASSWORD      := SPASSWORD;
    LROOTFOLDER    := SROOTFOLDER;
  end if;

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_UPDATE','UDO_FILESTORES',NRN );

  /* Базовое исправление */
  UDO_P_FILESTORES_BASE_UPDATE
  (
    NRN,
    NCOMPANY,
    SCODE,
    SNAME,
    LORA_DIRECTORY,
    LDOMAINNAME,
    LIPADDRESS,
    LPORT,
    LUSERNAME,
    LPASSWORD,
    LROOTFOLDER,
    NMAXFILES,
    SNOTE
  );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_UPDATE','UDO_FILESTORES',NRN );
end;

/
