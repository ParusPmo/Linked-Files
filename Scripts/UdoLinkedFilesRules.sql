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
/* Действие системы */
UNITFUNC          number( 17 ) not null,
/* ключи */
constraint UDO_C_FILERULES_PK primary key (RN),
constraint UDO_C_FILERULES_UNITCODE_UK unique (UNITCODE,COMPANY)
);


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
     where T.RN = NRN
       and T.UNITCODE = U.UNITCODE
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


create or replace procedure UDO_P_FILERULES_BASE_INSERT
(
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  SUNITCODE    in varchar2, -- Раздел системы
  NFILESTORE   in number,   -- Место хранения
  NMAXFILES    in number,   -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE in number,   -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME    in number,   -- Срок хранения файла (мес) (0 - неограничено)
  NRN          out number   -- Регистрационный  номер
) as
  ACTION_NAME_UK              constant varchar2(15) := 'Приєднані файли';
  ACTION_NAME_RU              constant varchar2(20) := 'Присоединенные файлы';
  ACTION_SUFFIX               constant varchar2(6) := 'VFILES';
  LINKEDDOC_UNITCODE          constant varchar2(30) := 'UdoLinkedFiles';
  LINKDOCS_SHOW_METHOD_CODE   constant varchar2(4) := 'main';
  LINKDOCS_SHOW_METHOD_PARAMS constant clob := '<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' ||
                                               CHR(10) || '<Params UnitCode="main">' || CHR(10) ||
                                               '   <Param Name="cond_document">' || CHR(10) ||
                                               '      <Context>key</Context>' || CHR(10) || '   </Param>' || CHR(10) ||
                                               '   <Param Name="cond_unitcode">' || CHR(10) ||
                                               '      <Context>unitcode</Context>' || CHR(10) || '   </Param>' ||
                                               CHR(10) || '</Params>';

  cursor L_ACTION is
    select SUBSTR(CODE, 1, INSTR(CODE, '_', -1)) || ACTION_SUFFIX CODE
      from UNITFUNC
     where UNITCODE = SUNITCODE
       and standard = 1;
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

  FIND_SHOWMETHODS_CODE(0, 0, LINKEDDOC_UNITCODE, LINKDOCS_SHOW_METHOD_CODE, L_LINKDOCS_SHOW_METHOD);

  FIND_UNITLIST_CODE(0, 0, SUNITCODE, L_UNITLIST_RN);

  P_DMSCLACTIONS_POSITION(L_UNITLIST_RN, L_NFUNCNUMB);

  P_UNITFUNC_BASE_INSERT(NPRN              => L_UNITLIST_RN,
                         SDETAILCODE       => null,
                         SCODE             => L_SFUNCCODE,
                         SNAME             => ACTION_NAME_RU,
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

  insert into RESOURCES
    (RN, TABLE_NAME, TABLE_ROW, RESOURCE_NAME, RESOURCE_LANG, RESOURCE_TEXT)
  values
    (GEN_ID, 'UNITFUNC', L_UNITFUNC, 'NAME', 'UKRAINIAN', ACTION_NAME_UK);

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
    (RN, COMPANY, UNITCODE, FILESTORE, MAXFILES, MAXFILESIZE, LIFETIME, BLOCKED, UNITFUNC)
  values
    (NRN, NCOMPANY, SUNITCODE, NFILESTORE, NMAXFILES, NMAXFILESIZE, NLIFETIME, 0, L_UNITFUNC);
end;
/


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
  (select RS.TEXT from V_RESOURCES_LOCAL RS where RS.TABLE_NAME = 'UNITLIST' and RS.COLUMN_NAME = 'UNITNAME' and RS.RN = U2.RN), -- SUNITNAME
  T.BLOCKED                             -- NBLOCKED
from
  UDO_FILERULES T,
  UDO_FILESTORES U,
  UNITLIST U2
where T.FILESTORE = U.RN
  and T.UNITCODE = U2.UNITCODE
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
    PKG_IUD.REG('UNITFUNC', :old.UNITFUNC);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILERULES_BDELETE;


create or replace procedure UDO_P_FILERULES_BASE_UPDATE
(
  NRN                       in number,       -- Регистрационный  номер
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
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
         LIFETIME = NLIFETIME
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoLinkedFilesRules' );
  end if;
end;

/


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

create or replace procedure UDO_P_FILERULES_INSERT
(
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  SUNITNAME    in varchar2, -- Наименование раздела
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


grant execute on UDO_P_FILERULES_INSERT to public;

create or replace procedure UDO_P_FILERULES_UPDATE
(
  NRN          in number,   -- Регистрационный  номер
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
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
