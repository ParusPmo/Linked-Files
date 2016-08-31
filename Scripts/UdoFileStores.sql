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
