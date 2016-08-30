/* ����� �������� �������������� ������ */
create table UDO_FILESTORES
(
/* ���������������  ����� */
RN                number( 17 ) not null,
/* �����������  (������ �� COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* �������  (������ �� ACATALOG(RN)) */
CRN               number( 17 ) not null,
/* �������� ����� �������� */
CODE              varchar2( 20 ) not null
                  constraint UDO_C_FILESTORES_CODE_NB check( RTRIM(CODE) IS NOT NULL ),
/* ������������ ����� �������� */
NAME              varchar2( 160 ) not null
                  constraint UDO_C_FILESTORES_NAME_NB check( RTRIM(NAME) IS NOT NULL ),
/* ��� ����� �������� */
STORE_TYPE        number( 1 ) default 1 not null,
/* ���������� Oracle */
ORA_DIRECTORY     varchar2( 30 ),
/* �������� ��� */
DOMAINNAME        varchar2( 240 ),
/* IP ����� */
IPADDRESS         varchar2( 15 ),
/* ���� FTP ������� */
PORT              number( 5 ) default 21,
/* ��� ������������ */
USERNAME          varchar2( 30 ),
/* ������ */
PASSWORD          varchar2( 30 ),
/* �������� ����� ��� �������� ������ */
ROOTFOLDER        varchar2( 240 ),
/* ������������ ���������� ������ � ����� */
MAXFILES          number( 6 ) not null
                  constraint UDO_C_FILESTORES_MAXFILES_VAL check( MAXFILES > 0 ),
/* ���������� */
NOTE              varchar2( 4000 ),
/* ����� */
constraint UDO_C_FILESTORES_PK primary key (RN),
constraint UDO_C_FILESTORES_CODE_UK unique (CODE,COMPANY)
);


/* ����� �������� ������ (�����) */
create table UDO_FILEFOLDERS
(
/* ���������������  ����� */
RN                number( 17 ) not null,
/* �����������  (������ �� COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* �������  (������ �� ACATALOG(RN)) */
CRN               number( 17 ) not null,
/* ��������������� ����� ������������ ������ */
PRN               number( 17 ) not null,
/* ������������ ����� */
NAME              varchar2( 36 ) not null
                  constraint UDO_C_FILEFOLDERS_NAME_NB check( RTRIM(NAME) IS NOT NULL ),
/* ���������� ������ � ����� */
FILECNT           number( 6 ) default 0 not null
                  constraint UDO_C_FILEFOLDERS_FILECNT_VAL check( FILECNT >= 0 ),
/* ����� */
constraint UDO_C_FILEFOLDERS_PK primary key (RN),
constraint UDO_C_FILEFOLDERS_NAME_UK unique (PRN,NAME)
);


/* ������� ����� ����������� */
create or replace trigger UDO_T_FILESTORES_AUPDATE
  after update on UDO_FILESTORES for each row
begin
  /* �������������� ��������� ����� ����������� ������ ������� */
  P_LOG_UPDATE( :new.RN,'UdoFileStores',:new.CRN,:old.CRN,null,null );
end;
/
show errors trigger UDO_T_FILESTORES_AUPDATE;


/* ������� �������� */
create or replace procedure UDO_P_FILESTORES_BASE_DELETE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number        -- �����������  (������ �� COMPANIES(RN))
)
as
begin
  /* �������� ������ �� ������� */
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


/* ����� �������� �������������� ������ (���������� �������������) */
create or replace force view UDO_V_FILESTORES
(
  NRN,                                  -- ���������������  �����
  NCOMPANY,                             -- �����������  (������ �� COMPANIES(RN))
  NCRN,                                 -- �������  (������ �� ACATALOG(RN))
  SCODE,                                -- �������� ����� ��������
  SNAME,                                -- ������������ ����� ��������
  NSTORE_TYPE,                          -- ��� ����� ��������
  SORA_DIRECTORY,                       -- ���������� Oracle
  SDOMAINNAME,                          -- �������� ���
  SIPADDRESS,                           -- IP �����
  NPORT,                                -- ���� FTP �������
  SUSERNAME,                            -- ��� ������������
  SPASSWORD,                            -- ������
  SROOTFOLDER,                          -- �������� ����� ��� �������� ������
  NMAXFILES,                            -- ������������ ���������� ������ � �����
  SNOTE                                 -- ����������
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

/* ���� ������� ������ */
alter table UDO_FILEFOLDERS
add
(
-- ������ �� ������������
constraint UDO_C_FILEFOLDERS_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- ������ �� ��������� ��������
constraint UDO_C_FILEFOLDERS_CRN_FK foreign key (CRN)
  references ACATALOG(RN),
-- ������ �� ��������
constraint UDO_C_FILEFOLDERS_PRN_FK foreign key (PRN)
  references UDO_FILESTORES(RN) on delete cascade
);


/* ���������� ������ */
create or replace procedure UDO_P_FILEFOLDERS_EXISTS
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NCRN                      out number       -- �������  (������ �� ACATALOG(RN))
)
as
begin
  /* ����� ������ */
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


/* ������� ����� �������� */
create or replace trigger UDO_T_FILESTORES_ADELETE
  after delete on UDO_FILESTORES for each row
begin
  /* �������������� ��������� ����� �������� ������ ������� */
  P_LOG_DELETE( :old.RN,'UdoFileStores' );
end;
/
show errors trigger UDO_T_FILESTORES_ADELETE;


/* ���� ������� ������ */
alter table UDO_FILESTORES
add
(
-- ������ �� ������������
constraint UDO_C_FILESTORES_COMPANY_FK foreign key (COMPANY)
  references COMPANIES(RN),
-- ������ �� ��������� ��������
constraint UDO_C_FILESTORES_CRN_FK foreign key (CRN)
  references ACATALOG(RN)
);


create or replace procedure UDO_P_FILESTORES_EXISTS
(
  NRN         in number,                 -- ���������������  �����
  NCOMPANY    in number,                 -- �����������  (������ �� COMPANIES(RN))
  FILESTORE   out UDO_FILESTORES%rowtype -- ����� ��������
) as
begin
  /* ����� ������ */
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


/* ������� ���������� */
create or replace procedure UDO_P_FILEFOLDERS_BASE_INSERT
(
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NPRN                      in number,       -- ��������������� ����� ������������ ������
  SNAME                     in varchar2,     -- ������������ �����
  NFILECNT                  in number,       -- ���������� ������ � �����
  NRN                       out number       -- ���������������  �����
)
as
begin
  /* ��������� ���������������� ������ */
  NRN := gen_id;

  /* ���������� ������ � ������� */
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


/* ������� ���������� */
create or replace procedure UDO_P_FILESTORES_BASE_INSERT
(
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NCRN                      in number,       -- �������  (������ �� ACATALOG(RN))
  SCODE                     in varchar2,     -- �������� ����� ��������
  SNAME                     in varchar2,     -- ������������ ����� ��������
  NSTORE_TYPE               in number,       -- ��� ����� ��������
  SORA_DIRECTORY            in varchar2,     -- ���������� Oracle
  SDOMAINNAME               in varchar2,     -- �������� ���
  SIPADDRESS                in varchar2,     -- IP �����
  NPORT                     in number,       -- ���� FTP �������
  SUSERNAME                 in varchar2,     -- ��� ������������
  SPASSWORD                 in varchar2,     -- ������
  SROOTFOLDER               in varchar2,     -- �������� ����� ��� �������� ������
  NMAXFILES                 in number,       -- ������������ ���������� ������ � �����
  SNOTE                     in varchar2,     -- ����������
  NRN                       out number       -- ���������������  �����
)
as
begin
  /* ��������� ���������������� ������ */
  NRN := gen_id;

  /* ���������� ������ � ������� */
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
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  SCODE                     in varchar2,     -- �������� ����� ��������
  SNAME                     in varchar2,     -- ������������ ����� ��������
  SORA_DIRECTORY            in varchar2,     -- ���������� Oracle
  SDOMAINNAME               in varchar2,     -- �������� ���
  SIPADDRESS                in varchar2,     -- IP �����
  NPORT                     in number,       -- ���� FTP �������
  SUSERNAME                 in varchar2,     -- ��� ������������
  SPASSWORD                 in varchar2,     -- ������
  SROOTFOLDER               in varchar2,     -- �������� ����� ��� �������� ������
  NMAXFILES                 in number,       -- ������������ ���������� ������ � �����
  SNOTE                     in varchar2      -- ����������
)
as
begin
  /* ����������� ������ � ������� */
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


/* ������� �� ����������� */
create or replace trigger UDO_T_FILEFOLDERS_BUPDATE
  before update on UDO_FILEFOLDERS for each row
begin
  /* �������� ������������ �������� ����� */
  PKG_UNCHANGE.CHECK_NE('UDO_FILEFOLDERS', 'RN', :new.RN, :old.RN);
  PKG_UNCHANGE.CHECK_NE('UDO_FILEFOLDERS', 'COMPANY', :new.COMPANY, :old.COMPANY);
  PKG_UNCHANGE.CHECK_NE('UDO_FILEFOLDERS', 'PRN', :new.PRN, :old.PRN);

  /* ��� ��������� ���������� ��������� ��������� ������� �� ������������ */
  if (CMP_NUM(:old.CRN,:new.CRN) = 0) then
    return;
  end if;

  /* ����������� ������� */
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


/* ������� �� �������� */
create or replace trigger UDO_T_FILEFOLDERS_BDELETE
  before delete on UDO_FILEFOLDERS for each row
begin
  /* ����������� ������� */
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


/* ����� �������� �������������� ������ (�����) (���������� �������������) */
create or replace force view UDO_V_FILEFOLDERS
(
  NRN,                                  -- ���������������  �����
  NCOMPANY,                             -- �����������  (������ �� COMPANIES(RN))
  NCRN,                                 -- �������  (������ �� ACATALOG(RN))
  NPRN,                                 -- ��������������� ����� ������������ ������
  SNAME,                                -- ������������ �����
  NFILECNT                              -- ���������� ������ � �����
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

/* ������� ����������� */
create or replace procedure UDO_P_FILEFOLDERS_BASE_UPDATE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  SNAME                     in varchar2,     -- ������������ �����
  NFILECNT                  in number        -- ���������� ������ � �����
)
as
begin
  /* ����������� ������ � ������� */
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


/* ������� ����� �������� */
create or replace trigger UDO_T_FILEFOLDERS_ADELETE
  after delete on UDO_FILEFOLDERS for each row
begin
  /* �������������� ��������� ����� �������� ������ ������� */
  P_LOG_DELETE( :old.RN,'UdoFileStoreFolders' );
end;
/
show errors trigger UDO_T_FILEFOLDERS_ADELETE;


/* ������� �� ����������� */
create or replace trigger UDO_T_FILESTORES_BUPDATE
  before update on UDO_FILESTORES for each row
begin
  /* �������� ������������ �������� ����� */
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'RN', :new.RN, :old.RN);
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'COMPANY', :new.COMPANY, :old.COMPANY);
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'STORE_TYPE', :new.STORE_TYPE, :old.STORE_TYPE);

  /* ����������� ������� */
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


/* ������� �� ���������� */
create or replace trigger UDO_T_FILEFOLDERS_BINSERT
  before insert on UDO_FILEFOLDERS for each row
begin
  /* ���������� ���������� ������ master-������� */
  select COMPANY,CRN
    into :new.COMPANY,:new.CRN
    from UDO_FILESTORES
   where RN = :new.PRN;

  /* ����������� ������� */
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
  NFLAG_SMART  in number, -- ������� ��������� ���������� (0 - ��, 1 - ���)
  NFLAG_OPTION in number, -- ������� ��������� ���������� ��� ������� SCODE (0 - ��, 1 - ���)
  NCOMPANY     in number, -- �����������
  SCODE        in varchar2, -- ��������
  NRN          out number -- ��������������� ����� ������ ����� ��������
) as
begin
  /* ������������� ���������� */
  NRN := null;

  /* �������� �� ����� */
  if (RTRIM(SCODE) is null) then
    if (NFLAG_OPTION = 0) then
      P_EXCEPTION(NFLAG_SMART,
                  '�� ����� �������� ����� ��������.');
    end if;

    /* �������� ����� */
  else

    /* ����� ������ */
    begin
      select T.RN
        into NRN
        from UDO_FILESTORES T
       where T.CODE = SCODE
         and T.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(NFLAG_SMART,
                    '����� �������� "%s" �� ����������.',
                    SCODE);
    end;
  end if;
end FIND_UDO_FILESTORES_CODE;
/


grant execute on FIND_UDO_FILESTORES_CODE to public;

/* ������� �������� */
create or replace procedure UDO_P_FILEFOLDERS_BASE_DELETE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number        -- �����������  (������ �� COMPANIES(RN))
)
as
begin
  /* �������� ������ �� ������� */
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


/* ������� �� ���������� */
create or replace trigger UDO_T_FILESTORES_BINSERT
  before insert on UDO_FILESTORES for each row
begin
  /* ����������� ������� */
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


/* ������� �� �������� */
create or replace trigger UDO_T_FILESTORES_BDELETE
  before delete on UDO_FILESTORES for each row
begin
  /* ����������� ������� */
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
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number        -- �����������  (������ �� COMPANIES(RN))
)
as
  LFILESTORE      UDO_FILESTORES%rowtype;    -- ������ ����� ��������
begin
  /* ���������� ������ */
  UDO_P_FILESTORES_EXISTS
  (
    NRN,
    NCOMPANY,
    LFILESTORE
  );

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );

  /* ������� �������� */
  UDO_P_FILESTORES_BASE_DELETE
  (
    NRN,
    NCOMPANY
  );

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );
end;

/


grant execute on UDO_P_FILESTORES_DELETE to public;

create or replace procedure UDO_P_FILESTORES_UPDATE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  SCODE                     in varchar2,     -- �������� ����� ��������
  SNAME                     in varchar2,     -- ������������ ����� ��������
  SORA_DIRECTORY            in varchar2,     -- ���������� Oracle
  SDOMAINNAME               in varchar2,     -- �������� ���
  SIPADDRESS                in varchar2,     -- IP �����
  NPORT                     in number,       -- ���� FTP �������
  SUSERNAME                 in varchar2,     -- ��� ������������
  SPASSWORD                 in varchar2,     -- ������
  SROOTFOLDER               in varchar2,     -- �������� ����� ��� �������� ������
  NMAXFILES                 in number,       -- ������������ ���������� ������ � �����
  SNOTE                     in varchar2      -- ����������
)
as
  LFILESTORE      UDO_FILESTORES%rowtype;    -- ������ ����� ��������
  LORA_DIRECTORY  UDO_FILESTORES.ORA_DIRECTORY%type;
  LDOMAINNAME     UDO_FILESTORES.DOMAINNAME%type;
  LIPADDRESS      UDO_FILESTORES.IPADDRESS%type;
  LPORT           UDO_FILESTORES.PORT%type;
  LUSERNAME       UDO_FILESTORES.USERNAME%type;
  LPASSWORD       UDO_FILESTORES.PASSWORD%type;
  LROOTFOLDER     UDO_FILESTORES.ROOTFOLDER%type;

begin
  /* ���������� ������ */
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

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_UPDATE','UDO_FILESTORES',NRN );

  /* ������� ����������� */
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

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_UPDATE','UDO_FILESTORES',NRN );
end;

/


grant execute on UDO_P_FILESTORES_UPDATE to public;

create or replace procedure UDO_P_FILESTORES_INSERT
(
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NCRN                      in number,       -- �������  (������ �� ACATALOG(RN))
  SCODE                     in varchar2,     -- �������� ����� ��������
  SNAME                     in varchar2,     -- ������������ ����� ��������
  NSTORE_TYPE               in number,       -- ��� ����� ��������
  SORA_DIRECTORY            in varchar2,     -- ���������� Oracle
  SDOMAINNAME               in varchar2,     -- �������� ���
  SIPADDRESS                in varchar2,     -- IP �����
  NPORT                     in number,       -- ���� FTP �������
  SUSERNAME                 in varchar2,     -- ��� ������������
  SPASSWORD                 in varchar2,     -- ������
  SROOTFOLDER               in varchar2,     -- �������� ����� ��� �������� ������
  NMAXFILES                 in number,       -- ������������ ���������� ������ � �����
  SNOTE                     in varchar2,     -- ����������
  NRN                       out number       -- ���������������  �����
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

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE( NCOMPANY,null,NCRN,null,null,'UdoFileStores','UDO_FILESTORES_INSERT','UDO_FILESTORES' );

  /* ������� ���������� */
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

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE( NCOMPANY,null,NCRN,null,null,'UdoFileStores','UDO_FILESTORES_INSERT','UDO_FILESTORES',NRN );
end;

/


grant execute on UDO_P_FILESTORES_INSERT to public;
