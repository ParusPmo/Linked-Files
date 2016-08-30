/* Места хранения присоединенных файлов */
create table UDO_FILESTORES
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Каталог  (ссылка на ACATALOG(RN)) */
CRN               number( 17 ) not null,
/* Мнемокод места хранения */
CODE              varchar2( 20 ) not null
                  constraint UDO_C_FILESTORES_CODE_NB check( RTRIM(CODE) IS NOT NULL ),
/* Наименование места хранения */
NAME              varchar2( 160 ) not null
                  constraint UDO_C_FILESTORES_NAME_NB check( RTRIM(NAME) IS NOT NULL ),
/* Тип места хранения */
STORE_TYPE        number( 1 ) default 1 not null,
/* Директория Oracle */
ORA_DIRECTORY     varchar2( 30 ),
/* Доменное имя */
DOMAINNAME        varchar2( 240 ),
/* IP адрес */
IPADDRESS         varchar2( 15 ),
/* Порт FTP сервера */
PORT              number( 5 ) default 21,
/* Имя пользователя */
USERNAME          varchar2( 30 ),
/* Пароль */
PASSWORD          varchar2( 30 ),
/* Корневая папка для хранения файлов */
ROOTFOLDER        varchar2( 240 ),
/* Максимальное количество файлов в папке */
MAXFILES          number( 6 ) not null
                  constraint UDO_C_FILESTORES_MAXFILES_VAL check( MAXFILES > 0 ),
/* Примечание */
NOTE              varchar2( 4000 ),
/* ключи */
constraint UDO_C_FILESTORES_PK primary key (RN),
constraint UDO_C_FILESTORES_CODE_UK unique (CODE,COMPANY)
);


/* Места хранения файлов (папки) */
create table UDO_FILEFOLDERS
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Каталог  (ссылка на ACATALOG(RN)) */
CRN               number( 17 ) not null,
/* Регистрационный номер родительской записи */
PRN               number( 17 ) not null,
/* Наименование папки */
NAME              varchar2( 36 ) not null
                  constraint UDO_C_FILEFOLDERS_NAME_NB check( RTRIM(NAME) IS NOT NULL ),
/* Количество файлов в папке */
FILECNT           number( 6 ) default 0 not null
                  constraint UDO_C_FILEFOLDERS_FILECNT_VAL check( FILECNT >= 0 ),
/* ключи */
constraint UDO_C_FILEFOLDERS_PK primary key (RN),
constraint UDO_C_FILEFOLDERS_NAME_UK unique (PRN,NAME)
);


/* Триггер после исправления */
create or replace trigger UDO_T_FILESTORES_AUPDATE
  after update on UDO_FILESTORES for each row
begin
  /* дополнительная обработка после исправления записи раздела */
  P_LOG_UPDATE( :new.RN,'UdoFileStores',:new.CRN,:old.CRN,null,null );
end;
/
show errors trigger UDO_T_FILESTORES_AUPDATE;


/* Базовое удаление */
create or replace procedure UDO_P_FILESTORES_BASE_DELETE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number        -- Организация  (ссылка на COMPANIES(RN))
)
as
begin
  /* удаление записи из таблицы */
  delete
    from UDO_FILESTORES
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStores' );
  end if;
end;
/
show errors procedure UDO_P_FILESTORES_BASE_DELETE;


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


grant select on UDO_V_FILESTORES to public;

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


/* Считывание записи */
create or replace procedure UDO_P_FILEFOLDERS_EXISTS
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  NCRN                      out number       -- Каталог  (ссылка на ACATALOG(RN))
)
as
begin
  /* поиск записи */
  begin
    select CRN
      into NCRN
      from UDO_FILEFOLDERS
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStoreFolders' );
  end;
end;
/
show errors procedure UDO_P_FILEFOLDERS_EXISTS;


/* Триггер после удаления */
create or replace trigger UDO_T_FILESTORES_ADELETE
  after delete on UDO_FILESTORES for each row
begin
  /* дополнительная обработка после удаления записи раздела */
  P_LOG_DELETE( :old.RN,'UdoFileStores' );
end;
/
show errors trigger UDO_T_FILESTORES_ADELETE;


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


create or replace procedure UDO_P_FILESTORES_EXISTS
(
  NRN         in number,                 -- Регистрационный  номер
  NCOMPANY    in number,                 -- Организация  (ссылка на COMPANIES(RN))
  FILESTORE   out UDO_FILESTORES%rowtype -- Место хранения
) as
begin
  /* поиск записи */
  begin
    select *
      into FILESTORE
      from UDO_FILESTORES
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoFileStores');
  end;
end;
/


/* Базовое добавление */
create or replace procedure UDO_P_FILEFOLDERS_BASE_INSERT
(
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  NPRN                      in number,       -- Регистрационный номер родительской записи
  SNAME                     in varchar2,     -- Наименование папки
  NFILECNT                  in number,       -- Количество файлов в папке
  NRN                       out number       -- Регистрационный  номер
)
as
begin
  /* генерация регистрационного номера */
  NRN := gen_id;

  /* добавление записи в таблицу */
  insert into UDO_FILEFOLDERS
  (
    RN,
    PRN,
    NAME,
    FILECNT
  )
  values
  (
    NRN,
    NPRN,
    SNAME,
    NFILECNT
  );
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_INSERT;


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


/* Триггер до исправления */
create or replace trigger UDO_T_FILEFOLDERS_BUPDATE
  before update on UDO_FILEFOLDERS for each row
begin
  /* проверка неизменности значений полей */
  PKG_UNCHANGE.CHECK_NE('UDO_FILEFOLDERS', 'RN', :new.RN, :old.RN);
  PKG_UNCHANGE.CHECK_NE('UDO_FILEFOLDERS', 'COMPANY', :new.COMPANY, :old.COMPANY);
  PKG_UNCHANGE.CHECK_NE('UDO_FILEFOLDERS', 'PRN', :new.PRN, :old.PRN);

  /* при изменении синхронных атрибутов заголовка триггер не активировать */
  if (CMP_NUM(:old.CRN,:new.CRN) = 0) then
    return;
  end if;

  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILEFOLDERS', 'U') ) then
    PKG_IUD.REG_RN('RN', :new.RN, :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY, :old.COMPANY);
    PKG_IUD.REG_CRN('CRN', :new.CRN, :old.CRN);
    PKG_IUD.REG_PRN('PRN', :new.PRN, :old.PRN);
    PKG_IUD.REG(1, 'NAME', :new.NAME, :old.NAME);
    PKG_IUD.REG('FILECNT', :new.FILECNT, :old.FILECNT);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILEFOLDERS_BUPDATE;


/* Триггер до удаления */
create or replace trigger UDO_T_FILEFOLDERS_BDELETE
  before delete on UDO_FILEFOLDERS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILEFOLDERS', 'D') ) then
    PKG_IUD.REG_RN('RN', :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :old.COMPANY);
    PKG_IUD.REG_CRN('CRN', :old.CRN);
    PKG_IUD.REG_PRN('PRN', :old.PRN);
    PKG_IUD.REG(1, 'NAME', :old.NAME);
    PKG_IUD.REG('FILECNT', :old.FILECNT);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILEFOLDERS_BDELETE;


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


grant select on UDO_V_FILEFOLDERS to public;

/* Базовое исправление */
create or replace procedure UDO_P_FILEFOLDERS_BASE_UPDATE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  SNAME                     in varchar2,     -- Наименование папки
  NFILECNT                  in number        -- Количество файлов в папке
)
as
begin
  /* исправление записи в таблице */
  update UDO_FILEFOLDERS
     set NAME = SNAME,
         FILECNT = NFILECNT
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStoreFolders' );
  end if;
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_UPDATE;


/* Триггер после удаления */
create or replace trigger UDO_T_FILEFOLDERS_ADELETE
  after delete on UDO_FILEFOLDERS for each row
begin
  /* дополнительная обработка после удаления записи раздела */
  P_LOG_DELETE( :old.RN,'UdoFileStoreFolders' );
end;
/
show errors trigger UDO_T_FILEFOLDERS_ADELETE;


/* Триггер до исправления */
create or replace trigger UDO_T_FILESTORES_BUPDATE
  before update on UDO_FILESTORES for each row
begin
  /* проверка неизменности значений полей */
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'RN', :new.RN, :old.RN);
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'COMPANY', :new.COMPANY, :old.COMPANY);
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'STORE_TYPE', :new.STORE_TYPE, :old.STORE_TYPE);

  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILESTORES', 'U') ) then
    PKG_IUD.REG_RN('RN', :new.RN, :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY, :old.COMPANY);
    PKG_IUD.REG_CRN('CRN', :new.CRN, :old.CRN);
    PKG_IUD.REG(1, 'CODE', :new.CODE, :old.CODE);
    PKG_IUD.REG('NAME', :new.NAME, :old.NAME);
    PKG_IUD.REG('STORE_TYPE', :new.STORE_TYPE, :old.STORE_TYPE);
    PKG_IUD.REG('ORA_DIRECTORY', :new.ORA_DIRECTORY, :old.ORA_DIRECTORY);
    PKG_IUD.REG('DOMAINNAME', :new.DOMAINNAME, :old.DOMAINNAME);
    PKG_IUD.REG('IPADDRESS', :new.IPADDRESS, :old.IPADDRESS);
    PKG_IUD.REG('PORT', :new.PORT, :old.PORT);
    PKG_IUD.REG('USERNAME', :new.USERNAME, :old.USERNAME);
    PKG_IUD.REG('PASSWORD', :new.PASSWORD, :old.PASSWORD);
    PKG_IUD.REG('ROOTFOLDER', :new.ROOTFOLDER, :old.ROOTFOLDER);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES, :old.MAXFILES);
    PKG_IUD.REG('NOTE', :new.NOTE, :old.NOTE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILESTORES_BUPDATE;


/* Триггер до добавления */
create or replace trigger UDO_T_FILEFOLDERS_BINSERT
  before insert on UDO_FILEFOLDERS for each row
begin
  /* считывание параметров записи master-таблицы */
  select COMPANY,CRN
    into :new.COMPANY,:new.CRN
    from UDO_FILESTORES
   where RN = :new.PRN;

  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILEFOLDERS', 'I') ) then
    PKG_IUD.REG_RN('RN', :new.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY);
    PKG_IUD.REG_CRN('CRN', :new.CRN);
    PKG_IUD.REG_PRN('PRN', :new.PRN);
    PKG_IUD.REG(1, 'NAME', :new.NAME);
    PKG_IUD.REG('FILECNT', :new.FILECNT);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILEFOLDERS_BINSERT;


create or replace procedure FIND_UDO_FILESTORES_CODE
(
  NFLAG_SMART  in number, -- признак генерации исключения (0 - да, 1 - нет)
  NFLAG_OPTION in number, -- признак генерации исключения для пустого SCODE (0 - да, 1 - нет)
  NCOMPANY     in number, -- организация
  SCODE        in varchar2, -- мнемокод
  NRN          out number -- регистрационный номер записи места хранения
) as
begin
  /* инициализация результата */
  NRN := null;

  /* мнемокод не задан */
  if (RTRIM(SCODE) is null) then
    if (NFLAG_OPTION = 0) then
      P_EXCEPTION(NFLAG_SMART,
                  'Не задан мнемокод места хранения.');
    end if;

    /* мнемокод задан */
  else

    /* поиск записи */
    begin
      select T.RN
        into NRN
        from UDO_FILESTORES T
       where T.CODE = SCODE
         and T.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(NFLAG_SMART,
                    'Место хранения "%s" не определено.',
                    SCODE);
    end;
  end if;
end FIND_UDO_FILESTORES_CODE;
/


grant execute on FIND_UDO_FILESTORES_CODE to public;

/* Базовое удаление */
create or replace procedure UDO_P_FILEFOLDERS_BASE_DELETE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number        -- Организация  (ссылка на COMPANIES(RN))
)
as
begin
  /* удаление записи из таблицы */
  delete
    from UDO_FILEFOLDERS
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStoreFolders' );
  end if;
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_DELETE;


/* Триггер до добавления */
create or replace trigger UDO_T_FILESTORES_BINSERT
  before insert on UDO_FILESTORES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILESTORES', 'I') ) then
    PKG_IUD.REG_RN('RN', :new.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY);
    PKG_IUD.REG_CRN('CRN', :new.CRN);
    PKG_IUD.REG(1, 'CODE', :new.CODE);
    PKG_IUD.REG('NAME', :new.NAME);
    PKG_IUD.REG('STORE_TYPE', :new.STORE_TYPE);
    PKG_IUD.REG('ORA_DIRECTORY', :new.ORA_DIRECTORY);
    PKG_IUD.REG('DOMAINNAME', :new.DOMAINNAME);
    PKG_IUD.REG('IPADDRESS', :new.IPADDRESS);
    PKG_IUD.REG('PORT', :new.PORT);
    PKG_IUD.REG('USERNAME', :new.USERNAME);
    PKG_IUD.REG('PASSWORD', :new.PASSWORD);
    PKG_IUD.REG('ROOTFOLDER', :new.ROOTFOLDER);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES);
    PKG_IUD.REG('NOTE', :new.NOTE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILESTORES_BINSERT;


/* Триггер до удаления */
create or replace trigger UDO_T_FILESTORES_BDELETE
  before delete on UDO_FILESTORES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILESTORES', 'D') ) then
    PKG_IUD.REG_RN('RN', :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :old.COMPANY);
    PKG_IUD.REG_CRN('CRN', :old.CRN);
    PKG_IUD.REG(1, 'CODE', :old.CODE);
    PKG_IUD.REG('NAME', :old.NAME);
    PKG_IUD.REG('STORE_TYPE', :old.STORE_TYPE);
    PKG_IUD.REG('ORA_DIRECTORY', :old.ORA_DIRECTORY);
    PKG_IUD.REG('DOMAINNAME', :old.DOMAINNAME);
    PKG_IUD.REG('IPADDRESS', :old.IPADDRESS);
    PKG_IUD.REG('PORT', :old.PORT);
    PKG_IUD.REG('USERNAME', :old.USERNAME);
    PKG_IUD.REG('PASSWORD', :old.PASSWORD);
    PKG_IUD.REG('ROOTFOLDER', :old.ROOTFOLDER);
    PKG_IUD.REG('MAXFILES', :old.MAXFILES);
    PKG_IUD.REG('NOTE', :old.NOTE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILESTORES_BDELETE;


create or replace procedure UDO_P_FILESTORES_DELETE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number        -- Организация  (ссылка на COMPANIES(RN))
)
as
  LFILESTORE      UDO_FILESTORES%rowtype;    -- Запись места хранения
begin
  /* Считывание записи */
  UDO_P_FILESTORES_EXISTS
  (
    NRN,
    NCOMPANY,
    LFILESTORE
  );

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );

  /* Базовое удаление */
  UDO_P_FILESTORES_BASE_DELETE
  (
    NRN,
    NCOMPANY
  );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );
end;

/


grant execute on UDO_P_FILESTORES_DELETE to public;

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


grant execute on UDO_P_FILESTORES_UPDATE to public;

create or replace procedure UDO_P_FILESTORES_INSERT
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
  LORA_DIRECTORY  UDO_FILESTORES.ORA_DIRECTORY%type;
  LDOMAINNAME     UDO_FILESTORES.DOMAINNAME%type;
  LIPADDRESS      UDO_FILESTORES.IPADDRESS%type;
  LPORT           UDO_FILESTORES.PORT%type;
  LUSERNAME       UDO_FILESTORES.USERNAME%type;
  LPASSWORD       UDO_FILESTORES.PASSWORD%type;
  LROOTFOLDER     UDO_FILESTORES.ROOTFOLDER%type;

begin

  if NSTORE_TYPE = 1 then
    LORA_DIRECTORY := SORA_DIRECTORY;
    LDOMAINNAME    := null;
    LIPADDRESS     := null;
    LPORT          := null;
    LUSERNAME      := null;
    LPASSWORD      := null;
    LROOTFOLDER    := null;
  elsif NSTORE_TYPE = 2 then
    LORA_DIRECTORY := null;
    LDOMAINNAME    := SDOMAINNAME;
    LIPADDRESS     := SIPADDRESS;
    LPORT          := NPORT;
    LUSERNAME      := SUSERNAME;
    LPASSWORD      := SPASSWORD;
    LROOTFOLDER    := SROOTFOLDER;
  end if;

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( NCOMPANY,null,NCRN,null,null,'UdoFileStores','UDO_FILESTORES_INSERT','UDO_FILESTORES' );

  /* Базовое добавление */
  UDO_P_FILESTORES_BASE_INSERT
  (
    NCOMPANY,
    NCRN,
    SCODE,
    SNAME,
    NSTORE_TYPE,
    LORA_DIRECTORY,
    LDOMAINNAME,
    LIPADDRESS,
    LPORT,
    LUSERNAME,
    LPASSWORD,
    LROOTFOLDER,
    NMAXFILES,
    SNOTE,
    NRN
  );

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( NCOMPANY,null,NCRN,null,null,'UdoFileStores','UDO_FILESTORES_INSERT','UDO_FILESTORES',NRN );
end;

/


grant execute on UDO_P_FILESTORES_INSERT to public;

create or replace package UDO_PKG_FTP_UTIL as

  -- --------------------------------------------------------------------------
  -- Name         : http://www.oracle-base.com/dba/miscellaneous/ftp.pks
  -- Author       : DR Timothy S Hall
  -- Description  : Basic FTP API. For usage notes see:
  --                  http://www.oracle-base.com/articles/misc/FTPFromPLSQL.php
  -- Requirements : UTL_TCP
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   14-AUG-2003  Tim Hall  Initial Creation
  --   10-MAR-2004  Tim Hall  Add convert_crlf procedure.
  --                          Make get_passive function visible.
  --                          Added get_direct and put_direct procedures.
  --   03-OCT-2006  Tim Hall  Add list, rename, delete, mkdir, rmdir procedures.
  --   15-Jan-2008  Tim Hall  login: Include timeout parameter (suggested by Dmitry Bogomolov).
  --   12-Jun-2008  Tim Hall  get_reply: Moved to pakage specification.
  --   22-Apr-2009  Tim Hall  nlst: Added to return list of file names only (suggested by Julian and John Duncan)
  -- --------------------------------------------------------------------------

  type T_STRING_TABLE is table of varchar2(32767);

  function LOGIN
  (
    P_HOST    in varchar2,
    P_PORT    in varchar2,
    P_USER    in varchar2,
    P_PASS    in varchar2,
    P_TIMEOUT in number := null
  ) return UTL_TCP.CONNECTION;

  function GET_PASSIVE(P_CONN in out nocopy UTL_TCP.CONNECTION)
    return UTL_TCP.CONNECTION;

  procedure LOGOUT
  (
    P_CONN  in out nocopy UTL_TCP.CONNECTION,
    P_REPLY in boolean := true
  );

  procedure SEND_COMMAND
  (
    P_CONN    in out nocopy UTL_TCP.CONNECTION,
    P_COMMAND in varchar2,
    P_REPLY   in boolean := true
  );

  procedure GET_REPLY(P_CONN in out nocopy UTL_TCP.CONNECTION);

  function GET_LOCAL_ASCII_DATA
  (
    P_DIR  in varchar2,
    P_FILE in varchar2
  ) return clob;

  function GET_LOCAL_BINARY_DATA
  (
    P_DIR  in varchar2,
    P_FILE in varchar2
  ) return blob;

  function GET_REMOTE_ASCII_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2
  ) return clob;

  function GET_REMOTE_BINARY_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2
  ) return blob;

  procedure PUT_LOCAL_ASCII_DATA
  (
    P_DATA in clob,
    P_DIR  in varchar2,
    P_FILE in varchar2
  );

  procedure PUT_LOCAL_BINARY_DATA
  (
    P_DATA in blob,
    P_DIR  in varchar2,
    P_FILE in varchar2
  );

  procedure PUT_REMOTE_ASCII_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2,
    P_DATA in clob
  );

  procedure PUT_REMOTE_BINARY_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2,
    P_DATA in blob
  );

  procedure GET
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_FILE in varchar2,
    P_TO_DIR    in varchar2,
    P_TO_FILE   in varchar2
  );

  procedure PUT
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_DIR  in varchar2,
    P_FROM_FILE in varchar2,
    P_TO_FILE   in varchar2
  );

  procedure GET_DIRECT
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_FILE in varchar2,
    P_TO_DIR    in varchar2,
    P_TO_FILE   in varchar2
  );

  procedure PUT_DIRECT
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_DIR  in varchar2,
    P_FROM_FILE in varchar2,
    P_TO_FILE   in varchar2
  );

  procedure HELP(P_CONN in out nocopy UTL_TCP.CONNECTION);

  procedure ASCII(P_CONN in out nocopy UTL_TCP.CONNECTION);

  procedure BINARY(P_CONN in out nocopy UTL_TCP.CONNECTION);

  procedure LIST
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2,
    P_LIST out T_STRING_TABLE
  );

  procedure NLST
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2,
    P_LIST out T_STRING_TABLE
  );

  procedure RENAME
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FROM in varchar2,
    P_TO   in varchar2
  );

  procedure delete
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2
  );

  procedure MKDIR
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2
  );

  procedure RMDIR
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2
  );

  procedure CONVERT_CRLF(P_STATUS in boolean);

end UDO_PKG_FTP_UTIL;
/


grant execute on UDO_PKG_FTP_UTIL to public;

/* Присоединенные файлы */
create table UDO_LINKEDDOCS
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Имя файла на сервере (GUID) */
INT_NAME          varchar2( 36 ) not null
                  constraint UDO_C_LINKEDDOCS_INTNAME_NB check( RTRIM(INT_NAME) IS NOT NULL ),
/* Мнемокод раздела */
UNITCODE          varchar2( 40 ) not null,
/* Регистрационный номер документа в разделе */
DOCUMENT          number( 17 ) not null,
/* Имя файла */
REAL_NAME         varchar2( 160 ) not null
                  constraint UDO_C_LINKEDDOCS_REAL_NAME_NB check( RTRIM(REAL_NAME) IS NOT NULL ),
/* Дата и время загрузки */
UPLOAD_TIME       date not null,
/* Срок хранения */
SAVE_TILL         date,
/* Размер файла */
FILESIZE          number( 15 ),
/* Пользователь выполнивший загрузку */
AUTHID            varchar2( 30 ) not null
                  constraint UDO_C_LINKEDDOCS_AUTHID_NB check( RTRIM(AUTHID) IS NOT NULL ),
/* Примечание */
NOTE              varchar2( 4000 ),
/* Признак удаленного по сроку файла */
FILE_DELETED      number( 1 ) default 0 not null
                  constraint UDO_C_LINKEDDOCS_FILE_DEL_VAL check( FILE_DELETED IN (0,1) ),
/* Папка хранения */
FILESTORE         number( 17 ) not null,
/* ключи */
constraint UDO_C_LINKEDDOCS_PK primary key (RN),
constraint UDO_C_LINKEDDOCS_INTNAME_UK unique (INT_NAME,COMPANY),
constraint UDO_C_LINKEDDOCS_REAL_NAME_UK unique (DOCUMENT,REAL_NAME,UNITCODE)
);

/* Разделы присоединенных файлов */
create table UDO_FILERULES
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Раздел системы */
UNITCODE          varchar2( 40 ) not null
                  constraint UDO_C_FILERULES_UNITCODE_NB check( RTRIM(UNITCODE) IS NOT NULL ),
/* Место хранения */
FILESTORE         number( 17 ) not null,
/* Максимальное кол-во присоединенных к записи файлов (0 - неограничено) */
MAXFILES          number( 6 ) default 0 not null
                  constraint UDO_C_FILERULES_MAXFILES_VAL check( MAXFILES >= 0 ),
/* Максимальное размер присоединенного файла (Кбайт) (0 - неограничено) */
MAXFILESIZE       number( 15 ) default 0 not null
                  constraint UDO_C_FILERULES_MAXSIZE_VAL check( MAXFILESIZE >= 0 ),
/* Срок хранения файла (мес) (0 - неограничено) */
LIFETIME          number( 4 ) default 0 not null
                  constraint UDO_C_FILERULES_LIFETIME_VAL check( LIFETIME >= 0 ),
/* Заблокировать добавление */
BLOCKED           number( 1 ) default 0 not null
                  constraint UDO_C_FILERULES_BLOCKED_VAL check( BLOCKED IN (0,1) ),
/* Имя таблицы раздела */
TABLENAME         varchar2( 30 ) not null
                  constraint UDO_C_FILERULES_TABLENAME_NB check( RTRIM(TABLENAME) IS NOT NULL ),
/* Поле дерева каталогов */
CTLGFIELD         varchar2( 30 )
                  constraint UDO_C_FILERULES_CTLGFIELD_NB check( RTRIM(CTLGFIELD) IS NOT NULL or CTLGFIELD IS NULL ),
/* Поле юридического лица */
JPERSFIELD        varchar2( 30 )
                  constraint UDO_C_FILERULES_JPERSFIELD_NB check( RTRIM(JPERSFIELD) IS NOT NULL ),
/* Действие системы */
UNITFUNC          number( 17 ) not null,
/* ключи */
constraint UDO_C_FILERULES_PK primary key (RN),
constraint UDO_C_FILERULES_UNITCODE_UK unique (UNITCODE,COMPANY)
);

create or replace package UDO_PKG_FILE_API is

  /*
  Под пользователем с правами SYSDBA необходимо
  1. Cоздать директорию. Например:
    create or replace directory UDO_PARUS_LINKED_FILES as '/home/oracle/linkfilesstore';
  2. Дать права владельцу схемы Парус на чтение и запись в этой директории. Например:
    grant read, write on directory UDO_PARUS_LINKED_FILES to PARUS;
  3. Дать Java разрешения на операции в папке операционной системы соответствующей директории. Например:
    EXEC dbms_java.grant_permission( 'PARUS', 'SYS:java.io.FilePermission', '/home/oracle/linkfilesstore', 'read' );
    EXEC dbms_java.grant_permission( 'PARUS', 'SYS:java.io.FilePermission', '/home/oracle/linkfilesstore/-', 'read,write,delete' );
  */

  function GET_DIRECTORY_PATH(P_DIRECTORY_NAME in varchar2) return varchar2;

  function READ_FILE
  (
    P_DIRECTORY_NAME in varchar2,
    P_FILE_NAME      in varchar2,
    P_FOLDER         in varchar2 default null
  ) return blob;

  procedure DELETE_FILE
  (
    P_DIRECTORY_NAME in varchar2,
    P_FILE_NAME      in varchar2,
    P_FOLDER         in varchar2 default null
  );

  procedure WRITE_FILE
  (
    P_DIRECTORY_NAME in varchar2,
    P_FILE_NAME      in varchar2,
    P_FILEDATA       in blob,
    P_FOLDER         in varchar2 default null
  );

  procedure MKDIR
  (
    P_DIRECTORY_NAME in varchar2,
    P_FOLDER         in varchar2
  );

end UDO_PKG_FILE_API;
/


create or replace and compile java source named "FileHandler" as
import java.util.*;
import java.lang.*;
import java.io.*;
import oracle.sql.*;
import java.sql.*;

public class FileHandler
{
  private static int SUCCESS = 1;
  private static  int FAILURE = 0;

  public static int exists (String path)
  {
    File lFile = new File (path);
    if (lFile.exists()) return SUCCESS;
    else return FAILURE;
  }

  public static int write(String path, BLOB blob)
  throws    Exception,
            SQLException,
            IllegalAccessException,
            InstantiationException,
            ClassNotFoundException
  {
    try
    {
      File              lFile   = new File(path);
      FileOutputStream  lOutStream  = new FileOutputStream(lFile);
      InputStream       lInStream   = blob.getBinaryStream();

      int     lLength  = -1;
      int     lSize    = blob.getBufferSize();
      byte[]  lBuffer  = new byte[lSize];

      while ((lLength = lInStream.read(lBuffer)) != -1)
      {
        lOutStream.write(lBuffer, 0, lLength);
        lOutStream.flush();
      }

      lInStream.close();
      lOutStream.close();
      return SUCCESS;
    }
    catch (Exception e)
    {
      e.printStackTrace();
      throw e;
    }
  }

  public static int delete (String path) {
    File lFile = new File (path);
    if (lFile.delete()) return SUCCESS; else return FAILURE;
  }

  public static int isDirectory (String path) {
    File lFile = new File (path);
    if (lFile.isDirectory()) return SUCCESS; else return FAILURE;
  }

  public static String getPathSeparator() {
    return File.separator;
  }

  public static int isFile (String path) {
    File lFile = new File (path);
    if (lFile.isFile()) return SUCCESS; else return FAILURE;
  }

  public static int createDirectory (String path)
  throws    Exception,
            IllegalAccessException,
            InstantiationException,
            ClassNotFoundException
  {
    File lDir = new File (path);
    if (!lDir.exists()) {
       try {
        lDir.mkdir();
        return SUCCESS;
       }
       catch(Exception e){
          e.printStackTrace();
          throw e;
       }
    } else {
        return FAILURE;
    }
  }
}
/


/* Триггер до удаления */
create or replace trigger UDO_T_LINKEDDOCS_BDELETE
  before delete on UDO_LINKEDDOCS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_LINKEDDOCS', 'D') ) then
    PKG_IUD.REG('RN', :old.RN);
    PKG_IUD.REG('COMPANY', :old.COMPANY);
    PKG_IUD.REG('INT_NAME', :old.INT_NAME);
    PKG_IUD.REG(1, 'UNITCODE', :old.UNITCODE);
    PKG_IUD.REG(2, 'DOCUMENT', :old.DOCUMENT);
    PKG_IUD.REG(3, 'REAL_NAME', :old.REAL_NAME);
    PKG_IUD.REG('UPLOAD_TIME', :old.UPLOAD_TIME);
    PKG_IUD.REG('SAVE_TILL', :old.SAVE_TILL);
    PKG_IUD.REG('FILESIZE', :old.FILESIZE);
    PKG_IUD.REG('AUTHID', :old.AUTHID);
    PKG_IUD.REG('NOTE', :old.NOTE);
    PKG_IUD.REG('FILE_DELETED', :old.FILE_DELETED);
    PKG_IUD.REG('FILESTORE', :old.FILESTORE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_LINKEDDOCS_BDELETE;


/* Триггер после удаления */
create or replace trigger UDO_T_LINKEDDOCS_ADELETE
  after delete on UDO_LINKEDDOCS for each row
begin
  /* дополнительная обработка после удаления записи раздела */
  P_LOG_DELETE( :old.RN,'UdoLinkedFiles' );
end;
/
show errors trigger UDO_T_LINKEDDOCS_ADELETE;


/* Триггер до исправления */
create or replace trigger UDO_T_LINKEDDOCS_BUPDATE
  before update on UDO_LINKEDDOCS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_LINKEDDOCS', 'U') ) then
    PKG_IUD.REG('RN', :new.RN, :old.RN);
    PKG_IUD.REG('COMPANY', :new.COMPANY, :old.COMPANY);
    PKG_IUD.REG('INT_NAME', :new.INT_NAME, :old.INT_NAME);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE, :old.UNITCODE);
    PKG_IUD.REG(2, 'DOCUMENT', :new.DOCUMENT, :old.DOCUMENT);
    PKG_IUD.REG(3, 'REAL_NAME', :new.REAL_NAME, :old.REAL_NAME);
    PKG_IUD.REG('UPLOAD_TIME', :new.UPLOAD_TIME, :old.UPLOAD_TIME);
    PKG_IUD.REG('SAVE_TILL', :new.SAVE_TILL, :old.SAVE_TILL);
    PKG_IUD.REG('FILESIZE', :new.FILESIZE, :old.FILESIZE);
    PKG_IUD.REG('AUTHID', :new.AUTHID, :old.AUTHID);
    PKG_IUD.REG('NOTE', :new.NOTE, :old.NOTE);
    PKG_IUD.REG('FILE_DELETED', :new.FILE_DELETED, :old.FILE_DELETED);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE, :old.FILESTORE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_LINKEDDOCS_BUPDATE;


create or replace package UDO_PKG_LINKEDDOCS is

  -- Author  : IGOR-GO
  -- Created : 15.01.2016 9:32:04
  -- Purpose :

  cursor CUR_LINKEDDOCS is
    select
    /* Регистрационный  номер */
     T.RN as NRN,
     /* Организация  (ссылка на COMPANIES(RN)) */
     T.COMPANY as NCOMPANY,
     /* Имя файла на сервере (GUID) */
     T.INT_NAME as SINT_NAME,
     /* Мнемокод раздела */
     T.UNITCODE as SUNITCODE,
     /* Регистрационный номер документа в разделе */
     T.DOCUMENT as NDOCUMENT,
     /* Имя файла */
     T.REAL_NAME as SREAL_NAME,
     /* Дата и время загрузки */
     T.UPLOAD_TIME as DUPLOAD_TIME,
     /* Срок хранения */
     T.SAVE_TILL as DSAVE_TILL,
     /* Папка хранения */
     T.FILESTORE as NFILESTORE,
     /* Размер файла */
     T.FILESIZE as NFILESIZE,
     /* Пользователь выполнивший загрузку */
     T.AUTHID as SAUTHID,
     /* Полное имя пользователя */
     U.NAME as SUSERFULLNAME,
     /* Примечание */
     T.NOTE as SNOTE,
     /* Признак удаленного по сроку файла*/
     T.FILE_DELETED as NFILE_DELETED
      from UDO_LINKEDDOCS T,
           USERLIST       U
     where T.AUTHID = U.AUTHID;

  type T_LINKEDDOCS is table of CUR_LINKEDDOCS%rowtype;

  function V
  (
    NCOMPANY  in number,
    NDOCUMENT in number,
    SUNITCODE in varchar2
  ) return T_LINKEDDOCS
    pipelined;

  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- Организация  (ссылка на COMPANIES(RN))
    SUNITCODE  in varchar2, -- Мнемокод раздела
    NDOCUMENT  in number, -- Регистрационный номер документа в разделе
    SREAL_NAME in varchar2, -- Имя файла
    SNOTE      in varchar2, -- Примечание
    BFILEDATA  in blob, -- файл
    NRN        out number -- Регистрационный  номер
  );

  procedure DOC_UPDATE
  (
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN      in number, -- Регистрационный  номер
    SNOTE    in varchar2 -- Примечание
  );

  procedure DOC_DELETE
  (
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN      in number -- Регистрационный  номер
  );

  procedure DOWNLOAD
  (
    NCOMPANY  in number, -- Организация  (ссылка на COMPANIES(RN))
    NIDENT    in number, -- Идентификатор списка выбора
    NDOCUMENT in number, -- RN записи основного раздела
    SUNITCODE in varchar2, -- Код основного раздела
    NFBIDENT  in number -- Идентификатор файлового буфера
  );

  procedure CLEAR_EXPIRED(NCOMPANY in number);

end UDO_PKG_LINKEDDOCS;
/


grant execute on UDO_PKG_LINKEDDOCS to public;

/* Триггер до добавления */
create or replace trigger UDO_T_LINKEDDOCS_BINSERT
  before insert on UDO_LINKEDDOCS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_LINKEDDOCS', 'I') ) then
    PKG_IUD.REG('RN', :new.RN);
    PKG_IUD.REG('COMPANY', :new.COMPANY);
    PKG_IUD.REG('INT_NAME', :new.INT_NAME);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE);
    PKG_IUD.REG(2, 'DOCUMENT', :new.DOCUMENT);
    PKG_IUD.REG(3, 'REAL_NAME', :new.REAL_NAME);
    PKG_IUD.REG('UPLOAD_TIME', :new.UPLOAD_TIME);
    PKG_IUD.REG('SAVE_TILL', :new.SAVE_TILL);
    PKG_IUD.REG('FILESIZE', :new.FILESIZE);
    PKG_IUD.REG('AUTHID', :new.AUTHID);
    PKG_IUD.REG('NOTE', :new.NOTE);
    PKG_IUD.REG('FILE_DELETED', :new.FILE_DELETED);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_LINKEDDOCS_BINSERT;


/* Триггер после исправления */
create or replace trigger UDO_T_LINKEDDOCS_AUPDATE
  after update on UDO_LINKEDDOCS for each row
begin
  /* дополнительная обработка после исправления записи раздела */
  P_LOG_UPDATE( :new.RN,'UdoLinkedFiles',null,null,null,null );
end;
/
show errors trigger UDO_T_LINKEDDOCS_AUPDATE;


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


create or replace package body UDO_PKG_FTP_UTIL as

  -- --------------------------------------------------------------------------
  -- Name         : http://www.oracle-base.com/dba/miscellaneous/ftp.pkb
  -- Author       : DR Timothy S Hall
  -- Description  : Basic FTP API. For usage notes see:
  --                  http://www.oracle-base.com/articles/misc/FTPFromPLSQL.php
  -- Requirements : http://www.oracle-base.com/dba/miscellaneous/ftp.pks
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   14-AUG-2003  Tim Hall  Initial Creation
  --   10-MAR-2004  Tim Hall  Add convert_crlf procedure.
  --                          Incorporate CRLF conversion functionality into
  --                          put_local_ascii_data and put_remote_ascii_data
  --                          functions.
  --                          Make get_passive function visible.
  --                          Added get_direct and put_direct procedures.
  --   23-DEC-2004  Tim Hall  The get_reply procedure was altered to deal with
  --                          banners starting with 4 white spaces. This fix is
  --                          a small variation on the resolution provided by
  --                          Gary Mason who spotted the bug.
  --   10-NOV-2005  Tim Hall  Addition of get_reply after doing a transfer to
  --                          pickup the 226 Transfer complete message. This
  --                          allows gets and puts with a single connection.
  --                          Issue spotted by Trevor Woolnough.
  --   03-OCT-2006  Tim Hall  Add list, rename, delete, mkdir, rmdir procedures.
  --   12-JAN-2007  Tim Hall  A final call to get_reply was added to the get_remote%
  --                          procedures to allow multiple transfers per connection.
  --   15-Jan-2008  Tim Hall  login: Include timeout parameter (suggested by Dmitry Bogomolov).
  --   21-Jan-2008  Tim Hall  put_%: "l_pos < l_clob_len" to "l_pos <= l_clob_len" to prevent
  --                          potential loss of one character for single-byte files or files
  --                          sized 1 byte bigger than a number divisible by the buffer size
  --                          (spotted by Michael Surikov).
  --   23-Jan-2008  Tim Hall  send_command: Possible solution for ORA-29260 errors included,
  --                          but commented out (suggested by Kevin Phillips).
  --   12-Feb-2008  Tim Hall  put_local_binary_data and put_direct: Open file with "wb" for
  --                          binary writes (spotted by Dwayne Hoban).
  --   03-Mar-2008  Tim Hall  list: get_reply call and close of passive connection added
  --                          (suggested by Julian, Bavaria).
  --   12-Jun-2008  Tim Hall  A final call to get_reply was added to the put_remote%
  --                          procedures, but commented out. If uncommented, it may cause the
  --                          operation to hang, but it has been reported (morgul) to allow
  --                          multiple transfers per connection.
  --                          get_reply: Moved to pakage specification.
  --   24-Jun-2008  Tim Hall  get_remote% and put_remote%: Exception handler added to close the passive
  --                          connection and reraise the error (suggested by Mark Reichman).
  --   22-Apr-2009  Tim Hall  get_remote_ascii_data: Remove unnecessary logout (suggested by John Duncan).
  --                          get_reply and list: Handle 400 messages as well as 500 messages (suggested by John Duncan).
  --                          logout: Added a call to UTL_TCP.close_connection, so not necessary to close
  --                          any connections manually (suggested by Victor Munoz).
  --                          get_local_*_data: Check for zero length files to prevent exception (suggested by Daniel)
  --                          nlst: Added to return list of file names only (suggested by Julian and John Duncan)
  -- --------------------------------------------------------------------------

  G_REPLY        T_STRING_TABLE := T_STRING_TABLE();
  G_BINARY       boolean := true;
  G_DEBUG        boolean := true;
  G_CONVERT_CRLF boolean := true;

  procedure DEBUG(P_TEXT in varchar2);

  -- --------------------------------------------------------------------------
  function LOGIN
  (
    P_HOST    in varchar2,
    P_PORT    in varchar2,
    P_USER    in varchar2,
    P_PASS    in varchar2,
    P_TIMEOUT in number := null
  ) return UTL_TCP.CONNECTION is
    -- --------------------------------------------------------------------------
    L_CONN UTL_TCP.CONNECTION;
  begin
    G_REPLY.DELETE;

    L_CONN := UTL_TCP.OPEN_CONNECTION(P_HOST, P_PORT, TX_TIMEOUT => P_TIMEOUT);
    GET_REPLY(L_CONN);
    SEND_COMMAND(L_CONN, 'USER ' || P_USER);
    SEND_COMMAND(L_CONN, 'PASS ' || P_PASS);
    return L_CONN;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  function GET_PASSIVE(P_CONN in out nocopy UTL_TCP.CONNECTION)
    return UTL_TCP.CONNECTION is
    -- --------------------------------------------------------------------------
    L_CONN  UTL_TCP.CONNECTION;
    L_REPLY varchar2(32767);
    L_HOST  varchar(100);
    L_PORT1 number(10);
    L_PORT2 number(10);
  begin
    SEND_COMMAND(P_CONN, 'PASV');
    L_REPLY := G_REPLY(G_REPLY.LAST);

    L_REPLY := replace(SUBSTR(L_REPLY,
                              INSTR(L_REPLY, '(') + 1,
                              (INSTR(L_REPLY, ')')) - (INSTR(L_REPLY, '(')) - 1),
                       ',',
                       '.');
    L_HOST  := SUBSTR(L_REPLY, 1, INSTR(L_REPLY, '.', 1, 4) - 1);

    L_PORT1 := TO_NUMBER(SUBSTR(L_REPLY,
                                INSTR(L_REPLY, '.', 1, 4) + 1,
                                (INSTR(L_REPLY, '.', 1, 5) - 1) -
                                (INSTR(L_REPLY, '.', 1, 4))));
    L_PORT2 := TO_NUMBER(SUBSTR(L_REPLY, INSTR(L_REPLY, '.', 1, 5) + 1));

    L_CONN := UTL_TCP.OPEN_CONNECTION(L_HOST, 256 * L_PORT1 + L_PORT2);
    return L_CONN;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure LOGOUT
  (
    P_CONN  in out nocopy UTL_TCP.CONNECTION,
    P_REPLY in boolean := true
  ) as
    -- --------------------------------------------------------------------------
  begin
    SEND_COMMAND(P_CONN, 'QUIT', P_REPLY);
    UTL_TCP.CLOSE_CONNECTION(P_CONN);
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure SEND_COMMAND
  (
    P_CONN    in out nocopy UTL_TCP.CONNECTION,
    P_COMMAND in varchar2,
    P_REPLY   in boolean := true
  ) is
    -- --------------------------------------------------------------------------
    L_RESULT pls_integer;
  begin
    L_RESULT := UTL_TCP.WRITE_LINE(P_CONN, P_COMMAND);
    -- If you get ORA-29260 after the PASV call, replace the above line with the following line.
    -- l_result := UTL_TCP.write_text(p_conn, p_command || utl_tcp.crlf, length(p_command || utl_tcp.crlf));

    if P_REPLY then
      GET_REPLY(P_CONN);
    end if;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure GET_REPLY(P_CONN in out nocopy UTL_TCP.CONNECTION) is
    -- --------------------------------------------------------------------------
    L_REPLY_CODE varchar2(3) := null;
  begin
    loop
      G_REPLY.EXTEND;
      G_REPLY(G_REPLY.LAST) := UTL_TCP.GET_LINE(P_CONN, true);
      DEBUG(G_REPLY(G_REPLY.LAST));
      if L_REPLY_CODE is null then
        L_REPLY_CODE := SUBSTR(G_REPLY(G_REPLY.LAST), 1, 3);
      end if;
      if SUBSTR(L_REPLY_CODE, 1, 1) in ('4', '5') then
        RAISE_APPLICATION_ERROR(-20000, G_REPLY(G_REPLY.LAST));
      elsif (SUBSTR(G_REPLY(G_REPLY.LAST), 1, 3) = L_REPLY_CODE and
            SUBSTR(G_REPLY(G_REPLY.LAST), 4, 1) = ' ') then
        exit;
      end if;
    end loop;
  exception
    when UTL_TCP.END_OF_INPUT then
      null;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  function GET_LOCAL_ASCII_DATA
  (
    P_DIR  in varchar2,
    P_FILE in varchar2
  ) return clob is
    -- --------------------------------------------------------------------------
    L_BFILE bfile;
    L_DATA  clob;
  begin
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => L_DATA,
                             CACHE   => true,
                             DUR     => DBMS_LOB.CALL);

    L_BFILE := BFILENAME(P_DIR, P_FILE);
    DBMS_LOB.FILEOPEN(L_BFILE, DBMS_LOB.FILE_READONLY);

    if DBMS_LOB.GETLENGTH(L_BFILE) > 0 then
      DBMS_LOB.LOADFROMFILE(L_DATA, L_BFILE, DBMS_LOB.GETLENGTH(L_BFILE));
    end if;

    DBMS_LOB.FILECLOSE(L_BFILE);

    return L_DATA;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  function GET_LOCAL_BINARY_DATA
  (
    P_DIR  in varchar2,
    P_FILE in varchar2
  ) return blob is
    -- --------------------------------------------------------------------------
    L_BFILE bfile;
    L_DATA  blob;
  begin
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => L_DATA,
                             CACHE   => true,
                             DUR     => DBMS_LOB.CALL);

    L_BFILE := BFILENAME(P_DIR, P_FILE);
    DBMS_LOB.FILEOPEN(L_BFILE, DBMS_LOB.FILE_READONLY);
    if DBMS_LOB.GETLENGTH(L_BFILE) > 0 then
      DBMS_LOB.LOADFROMFILE(L_DATA, L_BFILE, DBMS_LOB.GETLENGTH(L_BFILE));
    end if;
    DBMS_LOB.FILECLOSE(L_BFILE);

    return L_DATA;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  function GET_REMOTE_ASCII_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2
  ) return clob is
    -- --------------------------------------------------------------------------
    L_CONN   UTL_TCP.CONNECTION;
    L_AMOUNT pls_integer;
    L_BUFFER varchar2(32767);
    L_DATA   clob;
  begin
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => L_DATA,
                             CACHE   => true,
                             DUR     => DBMS_LOB.CALL);

    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'RETR ' || P_FILE, true);
    --logout(l_conn, FALSE);

    begin
      loop
        L_AMOUNT := UTL_TCP.READ_TEXT(L_CONN, L_BUFFER, 32767);
        DBMS_LOB.WRITEAPPEND(L_DATA, L_AMOUNT, L_BUFFER);
      end loop;
    exception
      when UTL_TCP.END_OF_INPUT then
        null;
      when others then
        null;
    end;
    UTL_TCP.CLOSE_CONNECTION(L_CONN);
    GET_REPLY(P_CONN);

    return L_DATA;

  exception
    when others then
      UTL_TCP.CLOSE_CONNECTION(L_CONN);
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  function GET_REMOTE_BINARY_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2
  ) return blob is
    -- --------------------------------------------------------------------------
    L_CONN   UTL_TCP.CONNECTION;
    L_AMOUNT pls_integer;
    L_BUFFER raw(32767);
    L_DATA   blob;
  begin
    DBMS_LOB.CREATETEMPORARY(LOB_LOC => L_DATA,
                             CACHE   => true,
                             DUR     => DBMS_LOB.CALL);

    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'RETR ' || P_FILE, true);

    begin
      loop
        L_AMOUNT := UTL_TCP.READ_RAW(L_CONN, L_BUFFER, 32767);
        DBMS_LOB.WRITEAPPEND(L_DATA, L_AMOUNT, L_BUFFER);
      end loop;
    exception
      when UTL_TCP.END_OF_INPUT then
        null;
      when others then
        null;
    end;
    UTL_TCP.CLOSE_CONNECTION(L_CONN);
    GET_REPLY(P_CONN);

    return L_DATA;

  exception
    when others then
      UTL_TCP.CLOSE_CONNECTION(L_CONN);
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure PUT_LOCAL_ASCII_DATA
  (
    P_DATA in clob,
    P_DIR  in varchar2,
    P_FILE in varchar2
  ) is
    -- --------------------------------------------------------------------------
    L_OUT_FILE UTL_FILE.FILE_TYPE;
    L_BUFFER   varchar2(32767);
    L_AMOUNT   binary_integer := 32767;
    L_POS      integer := 1;
    L_CLOB_LEN integer;
  begin
    L_CLOB_LEN := DBMS_LOB.GETLENGTH(P_DATA);

    L_OUT_FILE := UTL_FILE.FOPEN(P_DIR, P_FILE, 'w', 32767);

    while L_POS <= L_CLOB_LEN loop
      DBMS_LOB.READ(P_DATA, L_AMOUNT, L_POS, L_BUFFER);
      if G_CONVERT_CRLF then
        L_BUFFER := replace(L_BUFFER, CHR(13), null);
      end if;

      UTL_FILE.PUT(L_OUT_FILE, L_BUFFER);
      UTL_FILE.FFLUSH(L_OUT_FILE);
      L_POS := L_POS + L_AMOUNT;
    end loop;

    UTL_FILE.FCLOSE(L_OUT_FILE);
  exception
    when others then
      if UTL_FILE.IS_OPEN(L_OUT_FILE) then
        UTL_FILE.FCLOSE(L_OUT_FILE);
      end if;
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure PUT_LOCAL_BINARY_DATA
  (
    P_DATA in blob,
    P_DIR  in varchar2,
    P_FILE in varchar2
  ) is
    -- --------------------------------------------------------------------------
    L_OUT_FILE UTL_FILE.FILE_TYPE;
    L_BUFFER   raw(32767);
    L_AMOUNT   binary_integer := 32767;
    L_POS      integer := 1;
    L_BLOB_LEN integer;
  begin
    L_BLOB_LEN := DBMS_LOB.GETLENGTH(P_DATA);

    L_OUT_FILE := UTL_FILE.FOPEN(P_DIR, P_FILE, 'wb', 32767);

    while L_POS <= L_BLOB_LEN loop
      DBMS_LOB.READ(P_DATA, L_AMOUNT, L_POS, L_BUFFER);
      UTL_FILE.PUT_RAW(L_OUT_FILE, L_BUFFER, true);
      UTL_FILE.FFLUSH(L_OUT_FILE);
      L_POS := L_POS + L_AMOUNT;
    end loop;

    UTL_FILE.FCLOSE(L_OUT_FILE);
  exception
    when others then
      if UTL_FILE.IS_OPEN(L_OUT_FILE) then
        UTL_FILE.FCLOSE(L_OUT_FILE);
      end if;
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure PUT_REMOTE_ASCII_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2,
    P_DATA in clob
  ) is
    -- --------------------------------------------------------------------------
    L_CONN     UTL_TCP.CONNECTION;
    L_RESULT   pls_integer;
    L_BUFFER   varchar2(32767);
    L_AMOUNT   binary_integer := 32767;
    L_POS      integer := 1;
    L_CLOB_LEN integer;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'STOR ' || P_FILE, true);

    L_CLOB_LEN := DBMS_LOB.GETLENGTH(P_DATA);

    while L_POS <= L_CLOB_LEN loop
      DBMS_LOB.READ(P_DATA, L_AMOUNT, L_POS, L_BUFFER);
      if G_CONVERT_CRLF then
        L_BUFFER := replace(L_BUFFER, CHR(13), null);
      end if;
      L_RESULT := UTL_TCP.WRITE_TEXT(L_CONN, L_BUFFER, LENGTH(L_BUFFER));
      UTL_TCP.FLUSH(L_CONN);
      L_POS := L_POS + L_AMOUNT;
    end loop;

    UTL_TCP.CLOSE_CONNECTION(L_CONN);
    -- The following line allows some people to make multiple calls from one connection.
    -- It causes the operation to hang for me, hence it is commented out by default.
    -- get_reply(p_conn);

  exception
    when others then
      UTL_TCP.CLOSE_CONNECTION(L_CONN);
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure PUT_REMOTE_BINARY_DATA
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2,
    P_DATA in blob
  ) is
    -- --------------------------------------------------------------------------
    L_CONN     UTL_TCP.CONNECTION;
    L_RESULT   pls_integer;
    L_BUFFER   raw(32767);
    L_AMOUNT   binary_integer := 32767;
    L_POS      integer := 1;
    L_BLOB_LEN integer;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'STOR ' || P_FILE, true);

    L_BLOB_LEN := DBMS_LOB.GETLENGTH(P_DATA);

    while L_POS <= L_BLOB_LEN loop
      DBMS_LOB.READ(P_DATA, L_AMOUNT, L_POS, L_BUFFER);
      L_RESULT := UTL_TCP.WRITE_RAW(L_CONN, L_BUFFER, L_AMOUNT);
      UTL_TCP.FLUSH(L_CONN);
      L_POS := L_POS + L_AMOUNT;
    end loop;

    UTL_TCP.CLOSE_CONNECTION(L_CONN);
    -- The following line allows some people to make multiple calls from one connection.
    -- It causes the operation to hang for me, hence it is commented out by default.
    -- get_reply(p_conn);

  exception
    when others then
      UTL_TCP.CLOSE_CONNECTION(L_CONN);
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure GET
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_FILE in varchar2,
    P_TO_DIR    in varchar2,
    P_TO_FILE   in varchar2
  ) as
    -- --------------------------------------------------------------------------
  begin
    if G_BINARY then
      PUT_LOCAL_BINARY_DATA(P_DATA => GET_REMOTE_BINARY_DATA(P_CONN,
                                                             P_FROM_FILE),
                            P_DIR  => P_TO_DIR,
                            P_FILE => P_TO_FILE);
    else
      PUT_LOCAL_ASCII_DATA(P_DATA => GET_REMOTE_ASCII_DATA(P_CONN, P_FROM_FILE),
                           P_DIR  => P_TO_DIR,
                           P_FILE => P_TO_FILE);
    end if;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure PUT
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_DIR  in varchar2,
    P_FROM_FILE in varchar2,
    P_TO_FILE   in varchar2
  ) as
    -- --------------------------------------------------------------------------
  begin
    if G_BINARY then
      PUT_REMOTE_BINARY_DATA(P_CONN => P_CONN,
                             P_FILE => P_TO_FILE,
                             P_DATA => GET_LOCAL_BINARY_DATA(P_FROM_DIR,
                                                             P_FROM_FILE));
    else
      PUT_REMOTE_ASCII_DATA(P_CONN => P_CONN,
                            P_FILE => P_TO_FILE,
                            P_DATA => GET_LOCAL_ASCII_DATA(P_FROM_DIR,
                                                           P_FROM_FILE));
    end if;
    GET_REPLY(P_CONN);
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure GET_DIRECT
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_FILE in varchar2,
    P_TO_DIR    in varchar2,
    P_TO_FILE   in varchar2
  ) is
    -- --------------------------------------------------------------------------
    L_CONN       UTL_TCP.CONNECTION;
    L_OUT_FILE   UTL_FILE.FILE_TYPE;
    L_AMOUNT     pls_integer;
    L_BUFFER     varchar2(32767);
    L_RAW_BUFFER raw(32767);
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'RETR ' || P_FROM_FILE, true);
    if G_BINARY then
      L_OUT_FILE := UTL_FILE.FOPEN(P_TO_DIR, P_TO_FILE, 'wb', 32767);
    else
      L_OUT_FILE := UTL_FILE.FOPEN(P_TO_DIR, P_TO_FILE, 'w', 32767);
    end if;

    begin
      loop
        if G_BINARY then
          L_AMOUNT := UTL_TCP.READ_RAW(L_CONN, L_RAW_BUFFER, 32767);
          UTL_FILE.PUT_RAW(L_OUT_FILE, L_RAW_BUFFER, true);
        else
          L_AMOUNT := UTL_TCP.READ_TEXT(L_CONN, L_BUFFER, 32767);
          if G_CONVERT_CRLF then
            L_BUFFER := replace(L_BUFFER, CHR(13), null);
          end if;
          UTL_FILE.PUT(L_OUT_FILE, L_BUFFER);
        end if;
        UTL_FILE.FFLUSH(L_OUT_FILE);
      end loop;
    exception
      when UTL_TCP.END_OF_INPUT then
        null;
      when others then
        null;
    end;
    UTL_FILE.FCLOSE(L_OUT_FILE);
    UTL_TCP.CLOSE_CONNECTION(L_CONN);
  exception
    when others then
      if UTL_FILE.IS_OPEN(L_OUT_FILE) then
        UTL_FILE.FCLOSE(L_OUT_FILE);
      end if;
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure PUT_DIRECT
  (
    P_CONN      in out nocopy UTL_TCP.CONNECTION,
    P_FROM_DIR  in varchar2,
    P_FROM_FILE in varchar2,
    P_TO_FILE   in varchar2
  ) is
    -- --------------------------------------------------------------------------
    L_CONN       UTL_TCP.CONNECTION;
    L_BFILE      bfile;
    L_RESULT     pls_integer;
    L_AMOUNT     pls_integer := 32767;
    L_RAW_BUFFER raw(32767);
    L_LEN        number;
    L_POS        number := 1;
    EX_ASCII exception;
  begin
    if not G_BINARY then
      raise EX_ASCII;
    end if;

    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'STOR ' || P_TO_FILE, true);

    L_BFILE := BFILENAME(P_FROM_DIR, P_FROM_FILE);

    DBMS_LOB.FILEOPEN(L_BFILE, DBMS_LOB.FILE_READONLY);
    L_LEN := DBMS_LOB.GETLENGTH(L_BFILE);

    while L_POS <= L_LEN loop
      DBMS_LOB.READ(L_BFILE, L_AMOUNT, L_POS, L_RAW_BUFFER);
      DEBUG(L_AMOUNT);
      L_RESULT := UTL_TCP.WRITE_RAW(L_CONN, L_RAW_BUFFER, L_AMOUNT);
      L_POS    := L_POS + L_AMOUNT;
    end loop;

    DBMS_LOB.FILECLOSE(L_BFILE);
    UTL_TCP.CLOSE_CONNECTION(L_CONN);
  exception
    when EX_ASCII then
      RAISE_APPLICATION_ERROR(-20000,
                              'PUT_DIRECT not available in ASCII mode.');
    when others then
      if DBMS_LOB.FILEISOPEN(L_BFILE) = 1 then
        DBMS_LOB.FILECLOSE(L_BFILE);
      end if;
      raise;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure HELP(P_CONN in out nocopy UTL_TCP.CONNECTION) as
    -- --------------------------------------------------------------------------
  begin
    SEND_COMMAND(P_CONN, 'HELP', true);
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure ASCII(P_CONN in out nocopy UTL_TCP.CONNECTION) as
    -- --------------------------------------------------------------------------
  begin
    SEND_COMMAND(P_CONN, 'TYPE A', true);
    G_BINARY := false;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure BINARY(P_CONN in out nocopy UTL_TCP.CONNECTION) as
    -- --------------------------------------------------------------------------
  begin
    SEND_COMMAND(P_CONN, 'TYPE I', true);
    G_BINARY := true;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure LIST
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2,
    P_LIST out T_STRING_TABLE
  ) as
    -- --------------------------------------------------------------------------
    L_CONN       UTL_TCP.CONNECTION;
    L_LIST       T_STRING_TABLE := T_STRING_TABLE();
    L_REPLY_CODE varchar2(3) := null;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'LIST ' || P_DIR, true);

    begin
      loop
        L_LIST.EXTEND;
        L_LIST(L_LIST.LAST) := UTL_TCP.GET_LINE(L_CONN, true);
        DEBUG(L_LIST(L_LIST.LAST));
        if L_REPLY_CODE is null then
          L_REPLY_CODE := SUBSTR(L_LIST(L_LIST.LAST), 1, 3);
        end if;
        if SUBSTR(L_REPLY_CODE, 1, 1) in ('4', '5') then
          RAISE_APPLICATION_ERROR(-20000, L_LIST(L_LIST.LAST));
        elsif (SUBSTR(G_REPLY(G_REPLY.LAST), 1, 3) = L_REPLY_CODE and
              SUBSTR(G_REPLY(G_REPLY.LAST), 4, 1) = ' ') then
          exit;
        end if;
      end loop;
    exception
      when UTL_TCP.END_OF_INPUT then
        null;
    end;

    L_LIST.DELETE(L_LIST.LAST);
    P_LIST := L_LIST;

    UTL_TCP.CLOSE_CONNECTION(L_CONN);
    GET_REPLY(P_CONN);
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure NLST
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2,
    P_LIST out T_STRING_TABLE
  ) as
    -- --------------------------------------------------------------------------
    L_CONN       UTL_TCP.CONNECTION;
    L_LIST       T_STRING_TABLE := T_STRING_TABLE();
    L_REPLY_CODE varchar2(3) := null;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'NLST ' || P_DIR, true);

    begin
      loop
        L_LIST.EXTEND;
        L_LIST(L_LIST.LAST) := UTL_TCP.GET_LINE(L_CONN, true);
        DEBUG(L_LIST(L_LIST.LAST));
        if L_REPLY_CODE is null then
          L_REPLY_CODE := SUBSTR(L_LIST(L_LIST.LAST), 1, 3);
        end if;
        if SUBSTR(L_REPLY_CODE, 1, 1) in ('4', '5') then
          RAISE_APPLICATION_ERROR(-20000, L_LIST(L_LIST.LAST));
        elsif (SUBSTR(G_REPLY(G_REPLY.LAST), 1, 3) = L_REPLY_CODE and
              SUBSTR(G_REPLY(G_REPLY.LAST), 4, 1) = ' ') then
          exit;
        end if;
      end loop;
    exception
      when UTL_TCP.END_OF_INPUT then
        null;
    end;

    L_LIST.DELETE(L_LIST.LAST);
    P_LIST := L_LIST;

    UTL_TCP.CLOSE_CONNECTION(L_CONN);
    GET_REPLY(P_CONN);
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure RENAME
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FROM in varchar2,
    P_TO   in varchar2
  ) as
    -- --------------------------------------------------------------------------
    L_CONN UTL_TCP.CONNECTION;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'RNFR ' || P_FROM, true);
    SEND_COMMAND(P_CONN, 'RNTO ' || P_TO, true);
    LOGOUT(L_CONN, false);
  end RENAME;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure delete
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_FILE in varchar2
  ) as
    -- --------------------------------------------------------------------------
    L_CONN UTL_TCP.CONNECTION;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'DELE ' || P_FILE, true);
    LOGOUT(L_CONN, false);
  end delete;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure MKDIR
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2
  ) as
    -- --------------------------------------------------------------------------
    L_CONN UTL_TCP.CONNECTION;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'MKD ' || P_DIR, true);
    LOGOUT(L_CONN, false);
  end MKDIR;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure RMDIR
  (
    P_CONN in out nocopy UTL_TCP.CONNECTION,
    P_DIR  in varchar2
  ) as
    -- --------------------------------------------------------------------------
    L_CONN UTL_TCP.CONNECTION;
  begin
    L_CONN := GET_PASSIVE(P_CONN);
    SEND_COMMAND(P_CONN, 'RMD ' || P_DIR, true);
    LOGOUT(L_CONN, false);
  end RMDIR;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure CONVERT_CRLF(P_STATUS in boolean) as
    -- --------------------------------------------------------------------------
  begin
    G_CONVERT_CRLF := P_STATUS;
  end;
  -- --------------------------------------------------------------------------

  -- --------------------------------------------------------------------------
  procedure DEBUG(P_TEXT in varchar2) is
    -- --------------------------------------------------------------------------
  begin
    if G_DEBUG then
      DBMS_OUTPUT.PUT_LINE(SUBSTR(P_TEXT, 1, 255));
    end if;
  end;
  -- --------------------------------------------------------------------------

end UDO_PKG_FTP_UTIL;
/


create or replace package body UDO_PKG_FILE_API is

  PATH_SEPARATOR varchar2(1);

  /*Обертки Java функций */
  function SEPARATOR_ return varchar2 is
    language java name 'FileHandler.getPathSeparator() return java.lang.String';

  function EXISTS_(P_FILENAME in varchar2) return number is
    language java name 'FileHandler.exists(java.lang.String) return integer';

  function MAKE_DIR_(P_FILENAME in varchar2) return number is
    language java name 'FileHandler.createDirectory(java.lang.String) return integer';

  function DELETE_(P_FILENAME in varchar2) return number is
    language java name 'FileHandler.delete(java.lang.String) return integer';

  function WRITE_
  (
    P_FILENAME in varchar2,
    P_BLOB     in blob
  ) return number is
    language java name 'FileHandler.write(java.lang.String, oracle.sql.BLOB) return integer';

  function IS_DIRECTORY_(P_FILENAME in varchar2) return number is
    language java name 'FileHandler.isDirectory(java.lang.String) return integer';

  function IS_FILE_(P_FILENAME in varchar2) return number is
    language java name 'FileHandler.isFile(java.lang.String) return integer';

  function GET_DIRECTORY_PATH(P_DIRECTORY_NAME in varchar2) return varchar2 is
    cursor LC_DIR is
      select DIRECTORY_PATH
        from ALL_DIRECTORIES
       where DIRECTORY_NAME = P_DIRECTORY_NAME;
    L_DIRECTORY_PATH PKG_STD.TSTRING;
  begin
    open LC_DIR;
    fetch LC_DIR
      into L_DIRECTORY_PATH;
    close LC_DIR;
    return L_DIRECTORY_PATH;
  end;

  function GET_FULL_FILE_NAME_
  (
    P_DIRECTORY_NAME in varchar2,
    P_FILE_NAME      in varchar2,
    P_FOLDER         in varchar2
  ) return varchar2 is
    L_FILE_NAME PKG_STD.TSTRING;
  begin
    if P_FOLDER is null then
      L_FILE_NAME := P_FILE_NAME;
    else
      L_FILE_NAME := P_FOLDER || PATH_SEPARATOR || P_FILE_NAME;
    end if;
    return GET_DIRECTORY_PATH(P_DIRECTORY_NAME) || PATH_SEPARATOR || L_FILE_NAME;
  end;

  procedure DELETE_FILE
  (
    P_DIRECTORY_NAME in varchar2,
    P_FILE_NAME      in varchar2,
    P_FOLDER         in varchar2 default null
  ) is
  begin
    if DELETE_(GET_FULL_FILE_NAME_(P_DIRECTORY_NAME, P_FILE_NAME, P_FOLDER)) = 0 then
      P_EXCEPTION(0, 'Ошибка удаления файла');
    end if;
  end;

  procedure WRITE_FILE
  (
    P_DIRECTORY_NAME in varchar2,
    P_FILE_NAME      in varchar2,
    P_FILEDATA       in blob,
    P_FOLDER         in varchar2 default null
  ) is
  begin
    if WRITE_(GET_FULL_FILE_NAME_(P_DIRECTORY_NAME, P_FILE_NAME, P_FOLDER), P_FILEDATA) = 0 then
      P_EXCEPTION(0, 'Ошибка записи файла');
    end if;
  end;

  procedure MKDIR
  (
    P_DIRECTORY_NAME in varchar2,
    P_FOLDER         in varchar2
  ) is
    L_PATH PKG_STD.TSTRING;
  begin
    L_PATH := GET_DIRECTORY_PATH(P_DIRECTORY_NAME) || PATH_SEPARATOR || P_FOLDER;
    if MAKE_DIR_(L_PATH) = 0 then
      P_EXCEPTION(0, 'Ошибка создания папки');
    end if;
  end;

  function READ_FILE
  (
    P_DIRECTORY_NAME in varchar2,
    P_FILE_NAME      in varchar2,
    P_FOLDER         in varchar2 default null
  ) return blob is
    L_BLOB      blob;
    L_BLOB_TMP  blob;
    L_FILE      bfile;
    L_FILE_NAME PKG_STD.TSTRING;
  begin
    if P_FOLDER is null then
      L_FILE_NAME := P_FILE_NAME;
    else
      L_FILE_NAME := P_FOLDER || PATH_SEPARATOR || P_FILE_NAME;
    end if;
    L_FILE := BFILENAME(P_DIRECTORY_NAME, L_FILE_NAME);
    DBMS_LOB.OPEN(L_FILE, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.CREATETEMPORARY(L_BLOB_TMP, false);
    DBMS_LOB.LOADFROMFILE(DEST_LOB => L_BLOB_TMP,
                          SRC_LOB  => L_FILE,
                          AMOUNT   => DBMS_LOB.GETLENGTH(L_FILE));
    DBMS_LOB.CLOSE(L_FILE);
    L_BLOB := L_BLOB_TMP;
    DBMS_LOB.FREETEMPORARY(L_BLOB_TMP);
    return L_BLOB;
  end;

begin
  PATH_SEPARATOR := SEPARATOR_;
end UDO_PKG_FILE_API;
/


create or replace package UDO_PKG_LINKEDDOCS_BASE is
  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- Организация  (ссылка на COMPANIES(RN))
    SUNITCODE  in varchar2, -- Мнемокод раздела
    NDOCUMENT  in number, -- Регистрационный номер документа в разделе
    SREAL_NAME in varchar2, -- Имя файла
    SNOTE      in varchar2, -- Примечание
    NFILESIZE  in number, -- размер файла
    NFILESTORE in number, -- хранилище
    NLIFETIME  in number, -- срок хранения
    BFILEDATA  in blob, -- файл
    NRN        out number -- Регистрационный  номер
  );

  procedure DOC_UPDATE
  (
    NRN           in number, -- Регистрационный  номер
    NCOMPANY      in number, -- Организация  (ссылка на COMPANIES(RN))
    SREAL_NAME    in varchar2, -- Имя файла
    SNOTE         in varchar2, -- Примечание
    NFILE_DELETED in number -- Признак удаленного по сроку файла
  );

  /* Считывание записи */
  procedure DOC_EXISTS
  (
    NRN      in number, -- Регистрационный  номер
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    REC      out UDO_LINKEDDOCS%rowtype
  );

  /* Удаление записи */
  procedure DOC_DELETE
  (
    NCOMPANY      in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN           in number, -- Регистрационный  номер
    ONLY_IN_STORE in boolean default false -- удалять только в хранилище
  );

  procedure FILE_TO_BUFFER
  (
    NFILE   in number,
    NBUFFER in number
  );

end UDO_PKG_LINKEDDOCS_BASE;
/


create or replace package body UDO_PKG_LINKEDDOCS is
  FUNC_STANDART_INSERT  constant integer := 1;
  FUNC_STANDART_UPDATE  constant integer := 2;
  FUNC_STANDART_DELETE  constant integer := 3;
  LINKEDDOC_FUNC_INSERT constant varchar2(30) := 'UDO_LINKEDDOCS_INSERT';
  LINKEDDOC_FUNC_UPDATE constant varchar2(30) := 'UDO_LINKEDDOCS_UPDATE';
  LINKEDDOC_FUNC_DELETE constant varchar2(30) := 'UDO_LINKEDDOCS_DELETE';
  LINKEDDOC_TABLENAME   constant varchar2(30) := 'UDO_LINKEDDOCS';
  LINKEDDOC_UNITCODE    constant varchar2(30) := 'UdoLinkedFiles';
  NOPRIV_INS_MSG        constant varchar2(200) := 'У вас нет прав на присоединение файлов к записи в этом каталоге. Обратитесь к администратору.';
  NOPRIV_UPD_MSG        constant varchar2(200) := 'У вас нет прав на изменение присоединенных файлов в этом каталоге. Обратитесь к администратору.';
  NOPRIV_DEL_MSG        constant varchar2(200) := 'У вас нет прав на удаление присоединенных файлов в этом каталоге. Обратитесь к администратору.';
  EXMSG_ADD_NOTALLOW    constant varchar2(200) := 'Добавление присоединенных файлов к записи раздела «%S» невозможно.';
  EXMSG_ADD_BLOCKED     constant varchar2(200) := 'Добавление присоединенных файлов к записи раздела «%S» заблокировано администратором.';
  EXMSG_EMPTY_FILE      constant varchar2(200) := 'Добавление пустого файла недопустимо.';
  EXMSG_TOOBIG_FILE     constant varchar2(200) := 'Добавление невозможно. Размер файла не должен превышать %S Кбайт.';
  EXMSG_TOOMANY_FILES   constant varchar2(200) := 'Добавление невозможно. Максимальное количество присоединенных файлов - %S.';

  /* определяем каталога записи в разделе */
  procedure GET_DOC_CATALOG_N_JPERS
  (
    NCOMPANY  in number,
    NDOCUMENT in number,
    SUNITCODE in varchar2,
    NCRN      out number,
    NJUR_PERS out number
  ) is
    cursor LC_UNITPARAMS is
      select R.RN,
             R.TABLENAME,
             R.CTLGFIELD,
             R.JPERSFIELD,
             U.SIGN_HIER,
             U.SIGN_JURPERS
        from UDO_FILERULES R,
             UNITLIST      U
       where R.COMPANY = NCOMPANY
         and R.UNITCODE = SUNITCODE
         and R.UNITCODE = U.UNITCODE;
    L_UNITPARAMS LC_UNITPARAMS%rowtype;
    L_SQL        PKG_STD.TSQL;
  begin
    /* определяем параметры раздела */
    open LC_UNITPARAMS;
    fetch LC_UNITPARAMS
      into L_UNITPARAMS;
    close LC_UNITPARAMS;

    if L_UNITPARAMS.RN is null or L_UNITPARAMS.TABLENAME is null then
      return;
    end if;

    if L_UNITPARAMS.SIGN_HIER = 1 and L_UNITPARAMS.CTLGFIELD is not null then

      L_SQL := 'select ' || L_UNITPARAMS.CTLGFIELD || ' from ' || L_UNITPARAMS.TABLENAME ||
               ' where RN = :1';
      execute immediate L_SQL
        into NCRN
        using NDOCUMENT;
    end if;

    if L_UNITPARAMS.SIGN_JURPERS = 1 and L_UNITPARAMS.JPERSFIELD is not null then

      L_SQL := 'select ' || L_UNITPARAMS.JPERSFIELD || ' from ' || L_UNITPARAMS.TABLENAME ||
               ' where RN = :1';
      execute immediate L_SQL
        into NJUR_PERS
        using NDOCUMENT;
    end if;

  end;

  procedure CHECK_PRIVILEGE
  (
    NCOMPANY  in number,
    NDOCUMENT in number,
    SUNITCODE in varchar2,
    NFUNC     in number, -- FUNC_STANDART_INSERT-INSERT,2-UPDATE',3-DELETE
    SMESS     in varchar2
  ) is
    cursor LC_FUNCCODE is
      select CODE
        from UNITFUNC T
       where T.UNITCODE = SUNITCODE
         and T.STANDARD = NFUNC;
    L_FUNC    UNITFUNC.CODE%type;
    L_CRN     ACATALOG.RN%type;
    L_JURPERS JURPERSONS.RN%type;

  begin
    open LC_FUNCCODE;
    fetch LC_FUNCCODE
      into L_FUNC;
    close LC_FUNCCODE;
    GET_DOC_CATALOG_N_JPERS(NCOMPANY, NDOCUMENT, SUNITCODE, L_CRN, L_JURPERS);
    PKG_ENV.ACCESS(NCOMPANY  => NCOMPANY,
                   NVERSION  => null,
                   NCATALOG  => L_CRN,
                   NJUR_PERS => L_JURPERS,
                   SUNIT     => SUNITCODE,
                   SACTION   => L_FUNC,
                   SALTMSG   => SMESS);
  end;

  /* Клиентское представление */
  function V
  (
    NCOMPANY  in number,
    NDOCUMENT in number,
    SUNITCODE in varchar2
  ) return T_LINKEDDOCS
    pipelined is
    type T_RES_CUR_TYP is ref cursor;
    L_RES_CUR T_RES_CUR_TYP;
    C_SQL            constant PKG_STD.TSQL := 'select T.RN           as NRN,' || CHR(10) ||
                                              '       T.COMPANY      as NCOMPANY,' || CHR(10) ||
                                              '       T.INT_NAME     as SINT_NAME,' || CHR(10) ||
                                              '       T.UNITCODE     as SUNITCODE,' || CHR(10) ||
                                              '       T.DOCUMENT     as NDOCUMENT,' || CHR(10) ||
                                              '       T.REAL_NAME    as SREAL_NAME,' || CHR(10) ||
                                              '       T.UPLOAD_TIME  as DUPLOAD_TIME,' || CHR(10) ||
                                              '       T.SAVE_TILL    as DSAVE_TILL,' || CHR(10) ||
                                              '       T.FILESTORE    as NFILESTORE,' || CHR(10) ||
                                              '       T.FILESIZE     as NFILESIZE,' || CHR(10) ||
                                              '       T.AUTHID       as SAUTHID,' || CHR(10) ||
                                              '       U.NAME         as SUSERFULLNAME,' || CHR(10) ||
                                              '       T.NOTE         as SNOTE,' || CHR(10) ||
                                              '       T.FILE_DELETED as NFILE_DELETED' || CHR(10) ||
                                              '  from UDO_LINKEDDOCS T,' || CHR(10) ||
                                              '       USERLIST       U' || CHR(10) ||
                                              ' where T.AUTHID = U.AUTHID' || CHR(10) ||
                                              '   and T.DOCUMENT = :FUNC_STANDART_INSERT' ||
                                              CHR(10) || '   and T.UNITCODE = :2';
    C_SQL_CTLG_PRIV  constant PKG_STD.TSQL := CHR(10) ||
                                              '   and exists(select * from V_USERPRIV UP where UP.CATALOG  = :3)';
    C_SQL_JPERS_PRIV constant PKG_STD.TSQL := CHR(10) ||
                                              '   and exists( select * from V_USERPRIV UP where UP.JUR_PERS = :4 and UP.UNITCODE=:5)';
    L_CRN     ACATALOG.RN%type;
    L_JURPERS JURPERSONS.RN%type;
    L_RES_ROW CUR_LINKEDDOCS%rowtype;
  begin
    GET_DOC_CATALOG_N_JPERS(NCOMPANY, NDOCUMENT, SUNITCODE, L_CRN, L_JURPERS);
    if L_CRN is null and L_JURPERS is null then
      open L_RES_CUR for C_SQL
        using NDOCUMENT, SUNITCODE;
    elsif L_CRN is not null and L_JURPERS is null then
      open L_RES_CUR for C_SQL || C_SQL_CTLG_PRIV
        using NDOCUMENT, SUNITCODE, L_CRN;
    elsif L_CRN is null and L_JURPERS is not null then
      open L_RES_CUR for C_SQL || C_SQL_JPERS_PRIV
        using NDOCUMENT, SUNITCODE, L_JURPERS, SUNITCODE;
    else
      open L_RES_CUR for C_SQL || C_SQL_CTLG_PRIV || C_SQL_JPERS_PRIV
        using NDOCUMENT, SUNITCODE, L_CRN, L_JURPERS, SUNITCODE;
    end if;
    loop
      fetch L_RES_CUR
        into L_RES_ROW;
      exit when L_RES_CUR%notfound;
      pipe row(L_RES_ROW);
    end loop;

    close L_RES_CUR;
  end V;

  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- Организация  (ссылка на COMPANIES(RN))
    SUNITCODE  in varchar2, -- Мнемокод раздела
    NDOCUMENT  in number, -- Регистрационный номер документа в разделе
    SREAL_NAME in varchar2, -- Имя файла
    SNOTE      in varchar2, -- Примечание
    BFILEDATA  in blob, -- файл
    NRN        out number -- Регистрационный  номер
  ) is
    cursor LC_RULE is
      select T.*,
             (select RS.TEXT
                from V_RESOURCES_LOCAL RS
               where RS.TABLE_NAME = 'UNITLIST'
                 and RS.COLUMN_NAME = 'UNITNAME'
                 and RS.RN = UL.RN) as UNITNAME
        from UDO_FILERULES T,
             UNITLIST      UL
       where T.COMPANY = NCOMPANY
         and T.UNITCODE(+) = UL.UNITCODE
         and UL.UNITCODE = SUNITCODE;
    L_RULE LC_RULE%rowtype;

    cursor LC_FILESCNT is
      select count(*)
        from UDO_LINKEDDOCS T
       where T.COMPANY = NCOMPANY
         and T.DOCUMENT = NDOCUMENT
         and T.UNITCODE = SUNITCODE;
    L_FILESCNT number;
    L_FILESIZE number;
  begin
    /* Считываем правило хранения присоединенных файлов */
    open LC_RULE;
    fetch LC_RULE
      into L_RULE;
    close LC_RULE;
    /* присоединение невозможно */
    if L_RULE.BLOCKED is null then
      P_EXCEPTION(0, EXMSG_ADD_NOTALLOW, L_RULE.UNITNAME);
    end if;
    /* присоединение заблокировано */
    if L_RULE.BLOCKED = 1 then
      P_EXCEPTION(0, EXMSG_ADD_BLOCKED, L_RULE.UNITNAME);
    end if;
    /* определяем размер файла в КБайтах */
    L_FILESIZE := DBMS_LOB.GETLENGTH(BFILEDATA) / 1024;
    /* пустой файл */
    if BFILEDATA is null or L_FILESIZE = 0 then
      P_EXCEPTION(0, EXMSG_EMPTY_FILE);
    end if;
    /* проверяем максимально допустимый размер */
    if L_RULE.MAXFILESIZE > 0 and L_FILESIZE > L_RULE.MAXFILESIZE then
      P_EXCEPTION(0, EXMSG_TOOBIG_FILE, L_RULE.MAXFILESIZE);
    end if;
    /* проверяем максимально допустимое к-во файлов */
    if L_RULE.MAXFILES > 0 then
      open LC_FILESCNT;
      fetch LC_FILESCNT
        into L_FILESCNT;
      close LC_FILESCNT;
      if L_FILESCNT >= L_RULE.MAXFILES then
        P_EXCEPTION(0, EXMSG_TOOMANY_FILES, L_RULE.MAXFILES);
      end if;
    end if;
    /* Проверяем права на добавление записи в разделе */
    CHECK_PRIVILEGE(NCOMPANY, NDOCUMENT, SUNITCODE, FUNC_STANDART_INSERT, NOPRIV_INS_MSG);
    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_INSERT,
                     LINKEDDOC_TABLENAME);
    UDO_PKG_LINKEDDOCS_BASE.DOC_INSERT(NCOMPANY   => NCOMPANY,
                                        SUNITCODE  => SUNITCODE,
                                        NDOCUMENT  => NDOCUMENT,
                                        SREAL_NAME => SREAL_NAME,
                                        SNOTE      => SNOTE,
                                        NFILESIZE  => L_FILESIZE,
                                        NFILESTORE => L_RULE.FILESTORE,
                                        NLIFETIME  => L_RULE.LIFETIME,
                                        BFILEDATA  => BFILEDATA,
                                        NRN        => NRN);
    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_INSERT,
                     LINKEDDOC_TABLENAME,
                     NRN);
  end;

  procedure DOC_UPDATE
  (
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN      in number, -- Регистрационный  номер
    SNOTE    in varchar2 -- Примечание
  ) is
    L_REC UDO_LINKEDDOCS%rowtype;
  begin
    /* Считывание записи */
    UDO_PKG_LINKEDDOCS_BASE.DOC_EXISTS(NRN => NRN, NCOMPANY => NCOMPANY, REC => L_REC);

    /* Проверяем права на добавление записи в разделе */
    CHECK_PRIVILEGE(NCOMPANY, L_REC.DOCUMENT, L_REC.UNITCODE, FUNC_STANDART_UPDATE, NOPRIV_UPD_MSG);

    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_UPDATE,
                     LINKEDDOC_TABLENAME,
                     NRN);

    /* Базовое исправление */
    UDO_PKG_LINKEDDOCS_BASE.DOC_UPDATE(NRN           => NRN,
                                        NCOMPANY      => NCOMPANY,
                                        SREAL_NAME    => L_REC.REAL_NAME,
                                        SNOTE         => SNOTE,
                                        NFILE_DELETED => L_REC.FILE_DELETED);

    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_UPDATE,
                     LINKEDDOC_TABLENAME,
                     NRN);
  end;

  procedure DOC_DELETE
  (
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN      in number -- Регистрационный  номер
  ) is
    L_REC UDO_LINKEDDOCS%rowtype;
  begin
    /* Считывание записи */
    UDO_PKG_LINKEDDOCS_BASE.DOC_EXISTS(NRN => NRN, NCOMPANY => NCOMPANY, REC => L_REC);

    /* Проверяем права на добавление записи в разделе */
    CHECK_PRIVILEGE(NCOMPANY, L_REC.DOCUMENT, L_REC.UNITCODE, FUNC_STANDART_DELETE, NOPRIV_DEL_MSG);

    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_DELETE,
                     LINKEDDOC_TABLENAME,
                     NRN);

    /* Базовое удаление */
    UDO_PKG_LINKEDDOCS_BASE.DOC_DELETE(NRN => NRN, NCOMPANY => NCOMPANY, ONLY_IN_STORE => false);

    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_DELETE,
                     LINKEDDOC_TABLENAME,
                     NRN);
  end DOC_DELETE;

  procedure DOWNLOAD
  (
    NCOMPANY  in number, -- Организация  (ссылка на COMPANIES(RN))
    NIDENT    in number, -- Идентификатор списка выбора
    NDOCUMENT in number, -- RN записи основного раздела
    SUNITCODE in varchar2, -- Код основного раздела
    NFBIDENT  in number -- Идентификатор файлового буфера
  ) is
    cursor LC_FILES is
      select T.NRN,
             T.NFILE_DELETED
        from table(V(NCOMPANY, NDOCUMENT, SUNITCODE)) T
       where T.NRN in (select S.DOCUMENT
                         from SELECTLIST S
                        where S.IDENT = NIDENT);
    L_FILE LC_FILES%rowtype;
  begin
    open LC_FILES;
    loop
      fetch LC_FILES
        into L_FILE;
      exit when LC_FILES%notfound;
      if L_FILE.NFILE_DELETED = 0 then
        UDO_PKG_LINKEDDOCS_BASE.FILE_TO_BUFFER(L_FILE.NRN, NFBIDENT);
      end if;
    end loop;
    close LC_FILES;
  end;

  procedure CLEAR_EXPIRED(NCOMPANY in number) is
    cursor LC_FILES is
      select RN
        from UDO_LINKEDDOCS T
       where T.FILE_DELETED = 0
                   and T.SAVE_TILL < sysdate
         and T.COMPANY = NCOMPANY;
    L_NRN PKG_STD.TREF;
  begin
    open LC_FILES;
    loop
      fetch LC_FILES
        into L_NRN;
      exit when LC_FILES%notfound;
      /* Базовое удаление */
      UDO_PKG_LINKEDDOCS_BASE.DOC_DELETE(NRN => L_NRN, NCOMPANY => NCOMPANY, ONLY_IN_STORE => true);
    end loop;
    close LC_FILES;
  end;

end UDO_PKG_LINKEDDOCS;
/


create or replace package body UDO_PKG_LINKEDDOCS_BASE is
  LINKEDDOC_UNITCODE constant varchar2(30) := 'UdoLinkedFiles';

  function GET_NEW_UNIQUE_NAME return varchar2 is
  begin
    return SYS_GUID();
  end GET_NEW_UNIQUE_NAME;

  procedure UPLOAD_FTP
  (
    SHOST       in varchar2,
    NPORT       in number,
    SUSER       in varchar2,
    SPASS       in varchar2,
    SROOT       in varchar2,
    SFOLDER     in varchar2,
    SFILENAME   in varchar2,
    BFILEDATA   in blob,
    ISNEWFOLDER in boolean := false
  ) is
    L_CONN UTL_TCP.CONNECTION;
  begin
    L_CONN := UDO_PKG_FTP_UTIL.LOGIN(P_HOST => SHOST,
                                     P_PORT => NPORT,
                                     P_USER => SUSER,
                                     P_PASS => SPASS);

    if ISNEWFOLDER then
      UDO_PKG_FTP_UTIL.MKDIR(P_CONN => L_CONN, P_DIR => SROOT || '/' || SFOLDER);
    end if;
    UDO_PKG_FTP_UTIL.PUT_REMOTE_BINARY_DATA(P_CONN => L_CONN,
                                            P_FILE => SROOT || '/' || SFOLDER || '/' || SFILENAME,
                                            P_DATA => BFILEDATA);
    UDO_PKG_FTP_UTIL.LOGOUT(L_CONN);
  end UPLOAD_FTP;

  procedure UPLOAD_DIRECTORY
  (
    SDIRECTORY  in varchar2,
    SFOLDER     in varchar2,
    SFILENAME   in varchar2,
    BFILEDATA   in blob,
    ISNEWFOLDER in boolean := false
  ) is
  begin
    if ISNEWFOLDER then
      UDO_PKG_FILE_API.MKDIR(P_DIRECTORY_NAME => SDIRECTORY, P_FOLDER => SFOLDER);
    end if;
    UDO_PKG_FILE_API.WRITE_FILE(P_DIRECTORY_NAME => SDIRECTORY,
                                P_FILE_NAME      => SFILENAME,
                                P_FILEDATA       => BFILEDATA,
                                P_FOLDER         => SFOLDER);
  end;

  /* Считывание записи */
  procedure DOC_EXISTS
  (
    NRN      in number, -- Регистрационный  номер
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    REC      out UDO_LINKEDDOCS%rowtype
  ) is
    cursor LC_REC is
      select RN,
             COMPANY,
             INT_NAME,
             UNITCODE,
             DOCUMENT,
             REAL_NAME,
             UPLOAD_TIME,
             SAVE_TILL,
             FILESTORE,
             FILESIZE,
             authid,
             NOTE,
             FILE_DELETED
        from UDO_LINKEDDOCS
       where RN = NRN
         and COMPANY = NCOMPANY;
  begin
    /* поиск записи */
    open LC_REC;
    fetch LC_REC
      into REC;
    close LC_REC;

    if (REC.RN is null) then
      PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFiles');
    end if;
  end;

  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- Организация  (ссылка на COMPANIES(RN))
    SUNITCODE  in varchar2, -- Мнемокод раздела
    NDOCUMENT  in number, -- Регистрационный номер документа в разделе
    SREAL_NAME in varchar2, -- Имя файла
    SNOTE      in varchar2, -- Примечание
    NFILESIZE  in number, -- размер файла
    NFILESTORE in number, -- хранилище
    NLIFETIME  in number, -- срок хранения
    BFILEDATA  in blob, -- файл
    NRN        out number -- Регистрационный  номер
  ) is
    cursor LC_STORE is
      select *
        from UDO_FILESTORES
       where RN = NFILESTORE;
    L_STORE LC_STORE%rowtype;
    cursor LC_FOLDER(A_MAXFILES number) is
      select *
        from UDO_FILEFOLDERS T
       where T.PRN = NFILESTORE
         and T.FILECNT < A_MAXFILES
       order by T.FILECNT desc;
    L_FOLDER    LC_FOLDER%rowtype;
    L_INT_NAME  UDO_LINKEDDOCS.INT_NAME%type;
    ISNEWFOLDER boolean := false;
  begin

    /* считывание параметров хранилища */
    open LC_STORE;
    fetch LC_STORE
      into L_STORE;
    close LC_STORE;
    /* подбор папки на сервере */
    open LC_FOLDER(L_STORE.MAXFILES);
    fetch LC_FOLDER
      into L_FOLDER;
    close LC_FOLDER;

    if L_FOLDER.RN is null then
      /* добавляем новую папку */
      ISNEWFOLDER      := true;
      L_FOLDER.NAME    := GET_NEW_UNIQUE_NAME;
      L_FOLDER.FILECNT := 0;
      UDO_P_FILEFOLDERS_BASE_INSERT(NCOMPANY => NCOMPANY,
                                    NPRN     => NFILESTORE,
                                    SNAME    => L_FOLDER.NAME,
                                    NFILECNT => L_FOLDER.FILECNT,
                                    NRN      => L_FOLDER.RN);
    end if;

    /* генерируем внутреннее имя файла */
    L_INT_NAME := GET_NEW_UNIQUE_NAME;

    /* загрузка файла */
    if L_STORE.STORE_TYPE = 2 then
      UPLOAD_FTP(SHOST       => COALESCE(L_STORE.IPADDRESS, L_STORE.DOMAINNAME),
                 NPORT       => L_STORE.PORT,
                 SUSER       => L_STORE.USERNAME,
                 SPASS       => L_STORE.PASSWORD,
                 SROOT       => L_STORE.ROOTFOLDER,
                 SFOLDER     => L_FOLDER.NAME,
                 SFILENAME   => L_INT_NAME,
                 BFILEDATA   => BFILEDATA,
                 ISNEWFOLDER => ISNEWFOLDER);
    elsif L_STORE.STORE_TYPE = 1 then
      UPLOAD_DIRECTORY(SDIRECTORY  => L_STORE.ORA_DIRECTORY,
                       SFOLDER     => L_FOLDER.NAME,
                       SFILENAME   => L_INT_NAME,
                       BFILEDATA   => BFILEDATA,
                       ISNEWFOLDER => ISNEWFOLDER);
    end if;

    /* генерация регистрационного номера */
    NRN := GEN_ID;

    /* добавление записи в таблицу */
    insert into UDO_LINKEDDOCS
      (RN, COMPANY, INT_NAME, UNITCODE, DOCUMENT, REAL_NAME, UPLOAD_TIME, SAVE_TILL, FILESTORE,
       FILESIZE, authid, NOTE, FILE_DELETED)
    values
      (NRN, NCOMPANY, L_INT_NAME, SUNITCODE, NDOCUMENT, SREAL_NAME, sysdate,
       ADD_MONTHS(sysdate, NLIFETIME), L_FOLDER.RN, NFILESIZE, UTILIZER, SNOTE, 0);

    /* увеличиваем количество файлов в папке */
    UDO_P_FILEFOLDERS_BASE_UPDATE(NRN      => L_FOLDER.RN,
                                  NCOMPANY => NCOMPANY,
                                  SNAME    => L_FOLDER.NAME,
                                  NFILECNT => L_FOLDER.FILECNT + 1);
  end;

  /* Базовое исправление */
  procedure DOC_UPDATE
  (
    NRN           in number, -- Регистрационный  номер
    NCOMPANY      in number, -- Организация  (ссылка на COMPANIES(RN))
    SREAL_NAME    in varchar2, -- Имя файла
    SNOTE         in varchar2, -- Примечание
    NFILE_DELETED in number -- Признак удаленного по сроку файла
  ) as
  begin
    /* исправление записи в таблице */
    update UDO_LINKEDDOCS
       set REAL_NAME    = SREAL_NAME,
           NOTE         = SNOTE,
           FILE_DELETED = NFILE_DELETED
     where RN = NRN
       and COMPANY = NCOMPANY;

    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NRN, LINKEDDOC_UNITCODE);
    end if;
  end;

  procedure ERASE_DIRECTORY
  (
    SDIRECTORY in varchar2,
    SFOLDER    in varchar2,
    SFILENAME  in varchar2
  ) is
  begin
    UDO_PKG_FILE_API.DELETE_FILE(P_DIRECTORY_NAME => SDIRECTORY,
                                 P_FILE_NAME      => SFILENAME,
                                 P_FOLDER         => SFOLDER);
  end;

  procedure ERASE_FTP
  (
    SHOST     in varchar2,
    NPORT     in varchar2,
    SUSER     in varchar2,
    SPASS     in varchar2,
    SROOT     in varchar2,
    SFOLDER   in varchar2,
    SFILENAME in varchar2
  ) is
    L_CONN UTL_TCP.CONNECTION;
  begin
    L_CONN := UDO_PKG_FTP_UTIL.LOGIN(P_HOST => SHOST,
                                     P_PORT => NPORT,
                                     P_USER => SUSER,
                                     P_PASS => SPASS);

    UDO_PKG_FTP_UTIL.DELETE(P_CONN => L_CONN,
                            P_FILE => SROOT || '/' || SFOLDER || '/' || SFILENAME);
    UDO_PKG_FTP_UTIL.LOGOUT(L_CONN);
  end ERASE_FTP;

  /* Базовое удаление */
  procedure DOC_DELETE
  (
    NCOMPANY      in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN           in number, -- Регистрационный  номер
    ONLY_IN_STORE in boolean default false -- удалять только в хранилище
  ) is

    cursor LC_FILE is
      select T.FILE_DELETED,
             F.RN as FOLDER_RN,
             T.INT_NAME,
             F.NAME as FOLDER_NAME,
             COALESCE(S.IPADDRESS, S.DOMAINNAME) as HOST,
             F.FILECNT as FOLDER_CNT,
             S.PORT,
             S.USERNAME,
             S.PASSWORD,
             S.ROOTFOLDER,
             S.STORE_TYPE,
             S.ORA_DIRECTORY
        from UDO_LINKEDDOCS  T,
             UDO_FILEFOLDERS F,
             UDO_FILESTORES  S
       where T.RN = NRN
         and F.RN = T.FILESTORE
         and S.RN = F.PRN;
    L_FILE LC_FILE%rowtype;
  begin
    /* считывание файла */
    open LC_FILE;
    fetch LC_FILE
      into L_FILE;
    close LC_FILE;
    if ONLY_IN_STORE then
      /* исправление записи в таблице */
      update UDO_LINKEDDOCS
         set FILE_DELETED = 1
       where RN = NRN
         and COMPANY = NCOMPANY;
    else
      /* удаление записи из таблицы */
      delete UDO_LINKEDDOCS
       where RN = NRN
         and COMPANY = NCOMPANY;
    end if;

    if L_FILE.FILE_DELETED = 0 then
      /* уменьшаем количество файлов в папке */
      UDO_P_FILEFOLDERS_BASE_UPDATE(NRN      => L_FILE.FOLDER_RN,
                                    NCOMPANY => NCOMPANY,
                                    SNAME    => L_FILE.FOLDER_NAME,
                                    NFILECNT => L_FILE.FOLDER_CNT - 1);

      /* удаление файла */
      if L_FILE.STORE_TYPE = 2 then
        ERASE_FTP(SHOST     => L_FILE.HOST,
                  NPORT     => L_FILE.PORT,
                  SUSER     => L_FILE.USERNAME,
                  SPASS     => L_FILE.PASSWORD,
                  SROOT     => L_FILE.ROOTFOLDER,
                  SFOLDER   => L_FILE.FOLDER_NAME,
                  SFILENAME => L_FILE.INT_NAME);
      elsif L_FILE.STORE_TYPE = 1 then
        ERASE_DIRECTORY(SDIRECTORY => L_FILE.ORA_DIRECTORY,
                        SFOLDER    => L_FILE.FOLDER_NAME,
                        SFILENAME  => L_FILE.INT_NAME);
      end if;
    end if;

  end DOC_DELETE;

  function DOWNLOAD_FTP
  (
    SHOST     in varchar2,
    NPORT     in number,
    SUSER     in varchar2,
    SPASS     in varchar2,
    SROOT     in varchar2,
    SFOLDER   in varchar2,
    SFILENAME in varchar2
  ) return blob is
    L_CONN     UTL_TCP.CONNECTION;
    L_FILEDATA blob;
  begin
    L_CONN     := UDO_PKG_FTP_UTIL.LOGIN(P_HOST => SHOST,
                                         P_PORT => NPORT,
                                         P_USER => SUSER,
                                         P_PASS => SPASS);
    L_FILEDATA := UDO_PKG_FTP_UTIL.GET_REMOTE_BINARY_DATA(P_CONN => L_CONN,
                                                          P_FILE => SROOT || '/' || SFOLDER || '/' ||
                                                                    SFILENAME);
    UDO_PKG_FTP_UTIL.LOGOUT(L_CONN);
    return L_FILEDATA;
  end;

  function DOWNLOAD_DIRECTORY
  (
    SDIRECTORY in varchar2,
    SFOLDER    in varchar2,
    SFILENAME  in varchar2
  ) return blob is
  begin
    return UDO_PKG_FILE_API.READ_FILE(P_DIRECTORY_NAME => SDIRECTORY,
                                      P_FILE_NAME      => SFILENAME,
                                      P_FOLDER         => SFOLDER);
  end;

  procedure FILE_TO_BUFFER
  (
    NFILE   in number,
    NBUFFER in number
  ) is
    cursor LC_FILE is
      select T.FILE_DELETED,
             T.REAL_NAME,
             F.RN as FOLDER_RN,
             T.INT_NAME,
             F.NAME as FOLDER_NAME,
             COALESCE(S.IPADDRESS, S.DOMAINNAME) as HOST,
             F.FILECNT as FOLDER_CNT,
             S.PORT,
             S.USERNAME,
             S.PASSWORD,
             S.ROOTFOLDER,
             S.STORE_TYPE,
             S.ORA_DIRECTORY
        from UDO_LINKEDDOCS  T,
             UDO_FILEFOLDERS F,
             UDO_FILESTORES  S
       where T.RN = NFILE
         and F.RN = T.FILESTORE
         and S.RN = F.PRN;
    L_FILE     LC_FILE%rowtype;
    L_FILEDATA blob;
  begin
    /* считывание файла */
    open LC_FILE;
    fetch LC_FILE
      into L_FILE;
    close LC_FILE;
    if L_FILE.STORE_TYPE = 2 then
      L_FILEDATA := DOWNLOAD_FTP(SHOST     => L_FILE.HOST,
                                 NPORT     => L_FILE.PORT,
                                 SUSER     => L_FILE.USERNAME,
                                 SPASS     => L_FILE.PASSWORD,
                                 SROOT     => L_FILE.ROOTFOLDER,
                                 SFOLDER   => L_FILE.FOLDER_NAME,
                                 SFILENAME => L_FILE.INT_NAME);
    elsif L_FILE.STORE_TYPE = 1 then
      L_FILEDATA := DOWNLOAD_DIRECTORY(SDIRECTORY => L_FILE.ORA_DIRECTORY,
                                       SFOLDER    => L_FILE.FOLDER_NAME,
                                       SFILENAME  => L_FILE.INT_NAME);
    end if;
    if DBMS_LOB.GETLENGTH(L_FILEDATA) > 0 then
      P_FILE_BUFFER_INSERT(NIDENT    => NBUFFER,
                           CFILENAME => L_FILE.REAL_NAME,
                           CDATA     => null,
                           BLOBDATA  => L_FILEDATA);
    end if;
  end;

end UDO_PKG_LINKEDDOCS_BASE;
/

create or replace procedure UDO_P_FILERULES_GET_ATTRIB
(
  NRN       in number,
  SUNITNAME out varchar2
) is
  cursor LC_REC is
    select T.RN,
           (select RS.TEXT
              from V_RESOURCES_LOCAL RS
             where RS.TABLE_NAME = 'UNITLIST'
               and RS.COLUMN_NAME = 'UNITNAME'
               and RS.RN = U.RN) as SUNITNAME
      from UDO_FILERULES T,
           UNITLIST      U
     where T.UNITCODE = U.UNITCODE
       and exists (select null
              from V_USERPRIV UP
             where UP.COMPANY = T.COMPANY
               and UP.UNITCODE = 'UdoLinkedFilesRules');
  L_REC LC_REC%rowtype;
begin
  open LC_REC;
  fetch LC_REC
    into L_REC;
  close LC_REC;
  if L_REC.RN is null then
    PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NRN, SUNIT_TABLE => 'UDO_FILERULES');
  end if;
  SUNITNAME := L_REC.SUNITNAME;
end UDO_P_FILERULES_GET_ATTRIB;
/


grant execute on UDO_P_FILERULES_GET_ATTRIB to public;

/* Разрешение ссылок */
create or replace procedure UDO_P_FILERULES_JOINS
(
  NCOMPANY   in number,   -- Регистрационный номер организации
  SFILESTORE in varchar2, -- Место хранения
  SUNITNAME  in varchar2, -- Наименование раздела
  NFILESTORE out number,  -- Место хранения
  SUNITCODE  out varchar2 -- Код раздела
) as
begin
  FIND_UNITLIST_NAME(NFLAG_SMART  => 0,
                     NFLAG_OPTION => 1,
                     SNAME        => SUNITNAME,
                     SCODE        => SUNITCODE,
                     NRN          => PKG_STD.VREF);

  FIND_UDO_FILESTORES_CODE(NFLAG_SMART  => 0,
                           NFLAG_OPTION => 0,
                           NCOMPANY     => NCOMPANY,
                           SCODE        => SFILESTORE,
                           NRN          => NFILESTORE);

end;
/
show errors procedure UDO_P_FILERULES_JOINS;


/* Базовое добавление */
create or replace procedure UDO_P_FILERULES_BASE_INSERT
(
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  SUNITCODE    in varchar2, -- Раздел системы
  NFILESTORE   in number,   -- Место хранения
  NMAXFILES    in number,   -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE in number,   -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME    in number,   -- Срок хранения файла (мес) (0 - неограничено)
  STABLENAME   in varchar2, -- Имя таблицы раздела
  SCTLGFIELD   in varchar2, -- Поле дерева каталогов
  SJPERSFIELD  in varchar2, -- Поле юридического лица
  NRN          out number   -- Регистрационный  номер
) as
  ACTION_NAME                 constant varchar2(20) := 'Присоединенные файлы';
  ACTION_SUFFIX               constant varchar2(6) := 'VFILES';
  LINKEDDOC_UNITCODE          constant varchar2(30) := 'UdoLinkedFiles';
  LINKDOCS_SHOW_METHOD_CODE   constant varchar2(4) := 'main';
  LINKDOCS_SHOW_METHOD_PARAMS constant clob := '<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' ||
                                               CHR(10) || '<Params UnitCode="main">' || CHR(10) ||
                                               '   <Param Name="cond_document">' || CHR(10) ||
                                               '      <Context>key</Context>' || CHR(10) ||
                                               '   </Param>' || CHR(10) ||
                                               '   <Param Name="cond_unitcode">' || CHR(10) ||
                                               '      <Context>unitcode</Context>' || CHR(10) ||
                                               '   </Param>' || CHR(10) || '</Params>';

  cursor L_ACTION is
    select SUBSTR(CODE, 1, INSTR(CODE, '_', -1)) || ACTION_SUFFIX CODE
      from UNITFUNC
     where UNITCODE = SUNITCODE
       and STANDARD = 1;
  L_UNITFUNC             PKG_STD.TREF;
  L_UNITLIST_RN          PKG_STD.TREF;
  L_LINKDOCS_SHOW_METHOD PKG_STD.TREF;
  L_SFUNCCODE            UNITFUNC.CODE%type;
  L_NFUNCNUMB            UNITFUNC.NUMB%type;
begin

  open L_ACTION;
  fetch L_ACTION
    into L_SFUNCCODE;
  close L_ACTION;

  FIND_SHOWMETHODS_CODE(0,
                        0,
                        LINKEDDOC_UNITCODE,
                        LINKDOCS_SHOW_METHOD_CODE,
                        L_LINKDOCS_SHOW_METHOD);

  FIND_UNITLIST_CODE(0, 0, SUNITCODE, L_UNITLIST_RN);

  P_DMSCLACTIONS_POSITION(L_UNITLIST_RN, L_NFUNCNUMB);

  P_UNITFUNC_BASE_INSERT(NPRN              => L_UNITLIST_RN,
                         SDETAILCODE       => null,
                         SCODE             => L_SFUNCCODE,
                         SNAME             => ACTION_NAME,
                         NNUMB             => L_NFUNCNUMB,
                         NSYSIMAGE         => null,
                         NSTANDARD         => 11, -- открыть
                         NOVERRIDE         => null,
                         NUNCOND_ACCESS    => 0,
                         NMETHOD           => null,
                         NPROCESS_MODE     => 1,
                         NTRANSACT_MODE    => 1,
                         NREFRESH_MODE     => 0,
                         NSHOW_DIALOG      => 0,
                         NONLY_CUSTOM_MODE => 0,
                         NTECHNOLOGY       => 1, -- пользовательское
                         SPRODUCER         => null,
                         ISWAP_STANDARD    => 0,
                         NRN               => L_UNITFUNC);
  P_DMSCLACTIONSSTP_BASE_INSERT(NPRN             => L_UNITFUNC,
                                NPOSITION        => 1,
                                NSTPTYPE         => 1,
                                NSHOWMETHOD      => L_LINKDOCS_SHOW_METHOD,
                                NSHOWKIND        => 1,
                                CSHOWPARAMS      => LINKDOCS_SHOW_METHOD_PARAMS,
                                NUSERREPORT      => null,
                                NUAMODULE        => null,
                                NUAMODULE_ACTION => null,
                                NEXEC_PARAM      => null,
                                SPRODUCER        => null,
                                NRN              => PKG_STD.VREF);

  /* генерация регистрационного номера */
  NRN := GEN_ID;

  /* добавление записи в таблицу */
  insert into UDO_FILERULES
    (RN, COMPANY, UNITCODE, FILESTORE, MAXFILES, MAXFILESIZE, LIFETIME, BLOCKED, TABLENAME,
     CTLGFIELD, JPERSFIELD, UNITFUNC)
  values
    (NRN, NCOMPANY, SUNITCODE, NFILESTORE, NMAXFILES, NMAXFILESIZE, NLIFETIME, 0, STABLENAME,
     SCTLGFIELD, SJPERSFIELD, L_UNITFUNC);
end;
/
show errors procedure UDO_P_FILERULES_BASE_INSERT;


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
  NBLOCKED,                             -- Заблокировать добавление
  STABLENAME,                           -- Имя таблицы раздела
  SCTLGFIELD,                           -- Поле дерева каталогов
  SJPERSFIELD                           -- Поле юридического лица
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
  S.CODE,                               -- SFILESTORE
  (select RS.TEXT from V_RESOURCES_LOCAL RS where RS.TABLE_NAME = 'UNITLIST' and RS.COLUMN_NAME = 'UNITNAME' and RS.RN = U.RN), -- SUNITNAME
  T.BLOCKED,                            -- NBLOCKED
  T.TABLENAME,                          -- STABLENAME
  T.CTLGFIELD,                          -- SCTLGFIELD
  T.JPERSFIELD                          -- SJPERSFIELD
from
  UDO_FILERULES T,
  UDO_FILESTORES S,
  UNITLIST U
where T.FILESTORE = S.RN
  and T.UNITCODE = U.UNITCODE
  and exists (select null from V_USERPRIV UP where UP.COMPANY = T.COMPANY and UP.UNITCODE = 'UdoLinkedFilesRules');


grant select on UDO_V_FILERULES to public;

/* Триггер до удаления */
create or replace trigger UDO_T_FILERULES_BDELETE
  before delete on UDO_FILERULES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILERULES', 'D') ) then
    PKG_IUD.REG_RN('RN', :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :old.COMPANY);
    PKG_IUD.REG(1, 'UNITCODE', :old.UNITCODE);
    PKG_IUD.REG('FILESTORE', :old.FILESTORE);
    PKG_IUD.REG('MAXFILES', :old.MAXFILES);
    PKG_IUD.REG('MAXFILESIZE', :old.MAXFILESIZE);
    PKG_IUD.REG('LIFETIME', :old.LIFETIME);
    PKG_IUD.REG('BLOCKED', :old.BLOCKED);
    PKG_IUD.REG('TABLENAME', :old.TABLENAME);
    PKG_IUD.REG('CTLGFIELD', :old.CTLGFIELD);
    PKG_IUD.REG('JPERSFIELD', :old.JPERSFIELD);
    PKG_IUD.REG('UNITFUNC', :old.UNITFUNC);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILERULES_BDELETE;


/* Базовое исправление */
create or replace procedure UDO_P_FILERULES_BASE_UPDATE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  STABLENAME                in varchar2,     -- Имя таблицы раздела
  SCTLGFIELD                in varchar2,     -- Поле дерева каталогов
  SJPERSFIELD               in varchar2,     -- Поле юридического лица
  NFILESTORE                in number,       -- Место хранения
  NMAXFILES                 in number,       -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE              in number,       -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME                 in number        -- Срок хранения файла (мес) (0 - неограничено)
)
as
begin
  /* исправление записи в таблице */
  update UDO_FILERULES
     set FILESTORE = NFILESTORE,
         MAXFILES = NMAXFILES,
         MAXFILESIZE = NMAXFILESIZE,
         LIFETIME = NLIFETIME,
         TABLENAME = STABLENAME,
         CTLGFIELD = SCTLGFIELD,
         JPERSFIELD = SJPERSFIELD
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoLinkedFilesRules' );
  end if;
end;
/
show errors procedure UDO_P_FILERULES_BASE_UPDATE;


/* Базовое удаление */
create or replace procedure UDO_P_FILERULES_BASE_DELETE
(
  NRN      in number, -- Регистрационный  номер
  NCOMPANY in number  -- Организация  (ссылка на COMPANIES(RN))
) as
  L_DOC_CNT number;
  cursor LC_RULE is
    select *
      from UDO_FILERULES T
     where RN = NRN
       and COMPANY = NCOMPANY;
  L_RULE LC_RULE%rowtype;
begin
  /* считывание записи */
  open LC_RULE;
  fetch LC_RULE
    into L_RULE;
  close LC_RULE;
  /* проверка наличия присоединенных файлов */
  select count(*)
    into L_DOC_CNT
    from DUAL
   where exists (select *
            from UDO_LINKEDDOCS T
           where T.COMPANY = L_RULE.COMPANY
             and T.UNITCODE = L_RULE.UNITCODE);
  if L_DOC_CNT > 0 then
    P_EXCEPTION(0,
                'В системе зарегистрированы присоединенные документы по удаляемому правилу.');
  end if;
  /* удаление записи из таблицы */
  delete from UDO_FILERULES
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (sql%notfound) then
    PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFilesRules');
  end if;
  /* удаление действия */
  P_UNITFUNC_BASE_DELETE(L_RULE.UNITFUNC,
                         1 -- nTECHNOLOGY
                         );
end;
/
show errors procedure UDO_P_FILERULES_BASE_DELETE;


/* Триггер до добавления */
create or replace trigger UDO_T_FILERULES_BINSERT
  before insert on UDO_FILERULES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILERULES', 'I') ) then
    PKG_IUD.REG_RN('RN', :new.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES);
    PKG_IUD.REG('MAXFILESIZE', :new.MAXFILESIZE);
    PKG_IUD.REG('LIFETIME', :new.LIFETIME);
    PKG_IUD.REG('BLOCKED', :new.BLOCKED);
    PKG_IUD.REG('TABLENAME', :new.TABLENAME);
    PKG_IUD.REG('CTLGFIELD', :new.CTLGFIELD);
    PKG_IUD.REG('JPERSFIELD', :new.JPERSFIELD);
    PKG_IUD.REG('UNITFUNC', :new.UNITFUNC);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILERULES_BINSERT;


create or replace procedure UDO_P_FILERULES_BASE_STATUS
(
  NRN      in number, -- Регистрационный  номер
  NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
  NBLOCKED in number
) as
begin
  /* исправление записи в таблице */
  update UDO_FILERULES
     set BLOCKED = NBLOCKED
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (sql%notfound) then
    PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFilesRules');
  end if;
end;
/


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


/* Триггер после исправления */
create or replace trigger UDO_T_FILERULES_AUPDATE
  after update on UDO_FILERULES for each row
begin
  /* дополнительная обработка после исправления записи раздела */
  P_LOG_UPDATE( :new.RN,'UdoLinkedFilesRules',null,null,null,null );
end;
/
show errors trigger UDO_T_FILERULES_AUPDATE;


/* Считывание записи */
create or replace procedure UDO_P_FILERULES_EXISTS
(
  NRN       in number,                -- Регистрационный  номер
  NCOMPANY  in number,                -- Организация  (ссылка на COMPANIES(RN))
  RFILERULE out UDO_FILERULES%rowtype -- запись связи с разделом
) as
begin
  /* поиск записи */
  begin
    select *
      into RFILERULE
      from UDO_FILERULES
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFilesRules');
  end;
end;
/
show errors procedure UDO_P_FILERULES_EXISTS;


/* Триггер до исправления */
create or replace trigger UDO_T_FILERULES_BUPDATE
  before update on UDO_FILERULES for each row
begin
  /* проверка неизменности значений полей */
  PKG_UNCHANGE.CHECK_NE('UDO_FILERULES', 'RN', :new.RN, :old.RN);
  PKG_UNCHANGE.CHECK_NE('UDO_FILERULES', 'COMPANY', :new.COMPANY, :old.COMPANY);
  PKG_UNCHANGE.CHECK_NE('UDO_FILERULES', 'UNITCODE', :new.UNITCODE, :old.UNITCODE);

  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILERULES', 'U') ) then
    PKG_IUD.REG_RN('RN', :new.RN, :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY, :old.COMPANY);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE, :old.UNITCODE);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE, :old.FILESTORE);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES, :old.MAXFILES);
    PKG_IUD.REG('MAXFILESIZE', :new.MAXFILESIZE, :old.MAXFILESIZE);
    PKG_IUD.REG('LIFETIME', :new.LIFETIME, :old.LIFETIME);
    PKG_IUD.REG('BLOCKED', :new.BLOCKED, :old.BLOCKED);
    PKG_IUD.REG('TABLENAME', :new.TABLENAME, :old.TABLENAME);
    PKG_IUD.REG('CTLGFIELD', :new.CTLGFIELD, :old.CTLGFIELD);
    PKG_IUD.REG('JPERSFIELD', :new.JPERSFIELD, :old.JPERSFIELD);
    PKG_IUD.REG('UNITFUNC', :new.UNITFUNC, :old.UNITFUNC);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILERULES_BUPDATE;


/* Триггер после удаления */
create or replace trigger UDO_T_FILERULES_ADELETE
  after delete on UDO_FILERULES for each row
begin
  /* дополнительная обработка после удаления записи раздела */
  P_LOG_DELETE( :old.RN,'UdoLinkedFilesRules' );
end;
/
show errors trigger UDO_T_FILERULES_ADELETE;


/* Удаление записи */
create or replace procedure UDO_P_FILERULES_DELETE
(
  NRN      in number, -- Регистрационный  номер
  NCOMPANY in number -- Организация  (ссылка на COMPANIES(RN))
) as
  LFILERULE UDO_FILERULES%rowtype;
begin
  /* Считывание записи */
  UDO_P_FILERULES_EXISTS(NRN, NCOMPANY, LFILERULE);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_DELETE',
                   'UDO_FILERULES',
                   NRN);

  /* Базовое удаление */
  UDO_P_FILERULES_BASE_DELETE(NRN, NCOMPANY);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_DELETE',
                   'UDO_FILERULES',
                   NRN);
end;
/
show errors procedure UDO_P_FILERULES_DELETE;


grant execute on UDO_P_FILERULES_DELETE to public;

create or replace procedure UDO_P_FILERULES_BLOCK
(
  NRN      in number, -- Регистрационный  номер
  NCOMPANY in number -- Организация  (ссылка на COMPANIES(RN))
) as
  LFILERULE UDO_FILERULES%rowtype;
begin
  /* Считывание записи */
  UDO_P_FILERULES_EXISTS(NRN, NCOMPANY, LFILERULE);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_BLOCK',
                   'UDO_FILERULES',
                   NRN);

  /* Базовое удаление */
  UDO_P_FILERULES_BASE_STATUS(NRN, NCOMPANY, 1);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_BLOCK',
                   'UDO_FILERULES',
                   NRN);
end;
/


grant execute on UDO_P_FILERULES_BLOCK to public;

/* Добавление/размножение записи */
create or replace procedure UDO_P_FILERULES_INSERT
(
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  SUNITNAME    in varchar2, -- Наименование раздела
  STABLENAME   in varchar2, -- Имя таблицы раздела
  SCTLGFIELD   in varchar2, -- Поле дерева каталогов
  SJPERSFIELD  in varchar2, -- Поле юридического лица
  SFILESTORE   in varchar2, -- Место хранения
  NMAXFILES    in number,   -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE in number,   -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME    in number,   -- Срок хранения файла (мес) (0 - неограничено)
  NRN          out number   -- Регистрационный  номер
) as
  NFILESTORE PKG_STD.TREF; -- Место хранения
  SUNITCODE  UNITLIST.UNITCODE%type;
begin
  /* Разрешение ссылок */
  UDO_P_FILERULES_JOINS(NCOMPANY, SFILESTORE, SUNITNAME, NFILESTORE, SUNITCODE);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_INSERT',
                   'UDO_FILERULES');

  /* Базовое добавление */
  UDO_P_FILERULES_BASE_INSERT(NCOMPANY,
                              SUNITCODE,
                              NFILESTORE,
                              NMAXFILES,
                              NMAXFILESIZE,
                              NLIFETIME,
                              STABLENAME,
                              SCTLGFIELD,
                              SJPERSFIELD,
                              NRN);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_INSERT',
                   'UDO_FILERULES',
                   NRN);
end;
/
show errors procedure UDO_P_FILERULES_INSERT;


grant execute on UDO_P_FILERULES_INSERT to public;

/* Исправление записи */
create or replace procedure UDO_P_FILERULES_UPDATE
(
  NRN          in number,   -- Регистрационный  номер
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  STABLENAME   in varchar2, -- Имя таблицы раздела
  SCTLGFIELD   in varchar2, -- Поле дерева каталогов
  SJPERSFIELD  in varchar2, -- Поле юридического лица
  SFILESTORE   in varchar2, -- Место хранения
  NMAXFILES    in number,   -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE in number,   -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME    in number    -- Срок хранения файла (мес) (0 - неограничено)
) as
  NFILESTORE PKG_STD.TREF; -- Место хранения
  LFILERULE  UDO_FILERULES%rowtype;
begin
  /* Считывание записи */
  UDO_P_FILERULES_EXISTS(NRN, NCOMPANY, LFILERULE);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UPDATE',
                   'UDO_FILERULES',
                   NRN);

  /* Разрешение ссылок */
  UDO_P_FILERULES_JOINS(NCOMPANY, SFILESTORE, null, NFILESTORE, PKG_STD.VSTRING);

  /* Базовое исправление */
  UDO_P_FILERULES_BASE_UPDATE(NRN,
                              NCOMPANY,
                              STABLENAME,
                              SCTLGFIELD,
                              SJPERSFIELD,
                              NFILESTORE,
                              NMAXFILES,
                              NMAXFILESIZE,
                              NLIFETIME);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UPDATE',
                   'UDO_FILERULES',
                   NRN);
end;
/
show errors procedure UDO_P_FILERULES_UPDATE;


grant execute on UDO_P_FILERULES_UPDATE to public;

create or replace procedure UDO_P_FILERULES_UNBLOCK
(
  NRN      in number, -- Регистрационный  номер
  NCOMPANY in number -- Организация  (ссылка на COMPANIES(RN))
) as
  LFILERULE UDO_FILERULES%rowtype;
begin
  /* Считывание записи */
  UDO_P_FILERULES_EXISTS(NRN, NCOMPANY, LFILERULE);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UNBLOCK',
                   'UDO_FILERULES',
                   NRN);

  /* Базовое удаление */
  UDO_P_FILERULES_BASE_STATUS(NRN, NCOMPANY, 0);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UNBLOCK',
                   'UDO_FILERULES',
                   NRN);
end;
/


grant execute on UDO_P_FILERULES_UNBLOCK to public;
