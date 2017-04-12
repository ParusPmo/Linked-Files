create or replace package body UDO_PKG_LINKEDDOCS is
  FUNC_STANDART_INSERT  constant integer := 1;
  FUNC_STANDART_UPDATE  constant integer := 2;
  FUNC_STANDART_DELETE  constant integer := 3;
  LINKEDDOC_FUNC_INSERT constant varchar2(30) := 'UDO_LINKEDDOCS_INSERT';
  LINKEDDOC_FUNC_UPDATE constant varchar2(30) := 'UDO_LINKEDDOCS_UPDATE';
  LINKEDDOC_FUNC_DELETE constant varchar2(30) := 'UDO_LINKEDDOCS_DELETE';
  LINKEDDOC_FUNC_DLOAD  constant varchar2(30) := 'UDO_LINKEDDOCS_DOWNLOAD';
  LINKEDDOC_TABLENAME   constant varchar2(30) := 'UDO_LINKEDDOCS';
  LINKEDDOC_UNITCODE    constant varchar2(30) := 'UdoLinkedFiles';
  NOPRIV_INS_MSG        constant varchar2(200) := 'в том числе на присоединение файлов к этой записи раздела.';
  NOPRIV_UPD_MSG        constant varchar2(200) := 'в том числе на изменение присоединенных к этой записи раздела файлов.';
  NOPRIV_DEL_MSG        constant varchar2(200) := 'в том числе на удаление присоединенных к этой записи раздела файлов.';
  EXMSG_ADD_NOTALLOW    constant varchar2(200) := 'Добавление присоединенных файлов к записи раздела «%S» невозможно.';
  EXMSG_ADD_BLOCKED     constant varchar2(200) := 'Добавление присоединенных файлов к записи раздела «%S» заблокировано администратором.';
  EXMSG_EMPTY_FILE      constant varchar2(200) := 'Добавление пустого файла недопустимо.';
  EXMSG_TOOBIG_FILE     constant varchar2(200) := 'Добавление невозможно. Размер файла не должен превышать %S Кбайт.';
  EXMSG_TOOMANY_FILES   constant varchar2(200) := 'Добавление невозможно. Максимальное количество присоединенных файлов - %S.';

  procedure GET_UNIT_ATTRIBUTES
  (
    NCOMPANY       in number,
    NDOCUMENT      in number,
    SUNITCODE      in varchar2,
    NCRN           out number,
    NJUR_PERS      out number,
    NSHARE_COMPANY out number,
    SMASTERCODE    out varchar2
  ) is
    cursor LC_UNITPARAMS is
      select R.RN,
             NVL(U.MASTERCODE, U.UNITCODE) MASTERCODE
        from UDO_FILERULES R,
             UNITLIST      U
       where R.COMPANY = NCOMPANY
         and R.UNITCODE = SUNITCODE
         and R.UNITCODE = U.UNITCODE;
    L_UNITPARAMS LC_UNITPARAMS%rowtype;
    L_FOUND      boolean;
    L_COMPANY    COMPANIES.RN%type;
    L_VERSION    VERSIONS.RN%type;
    L_HIERARCHY  HIERARCHY.RN%type;
  begin
    /* определяем параметры раздела */
    open LC_UNITPARAMS;
    fetch LC_UNITPARAMS
      into L_UNITPARAMS;
    close LC_UNITPARAMS;

    if L_UNITPARAMS.RN is null then
      return;
    end if;
    PKG_DOCUMENT.GET_ATTRS(NFLAG_SMART => 0,
                           SUNITCODE   => SUNITCODE,
                           NDOCUMENT   => NDOCUMENT,
                           BFOUND      => L_FOUND,
                           NCOMPANY    => L_COMPANY,
                           NVERSION    => L_VERSION,
                           NCATALOG    => NCRN,
                           NJUR_PERS   => NJUR_PERS,
                           NHIERARCHY  => L_HIERARCHY);

    if L_VERSION is not null then
      NSHARE_COMPANY := NCOMPANY;
    else
      NSHARE_COMPANY := L_COMPANY;
    end if;
    SMASTERCODE := L_UNITPARAMS.MASTERCODE;
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
    L_FUNC          UNITFUNC.CODE%type;
    L_CRN           ACATALOG.RN%type;
    L_JURPERS       JURPERSONS.RN%type;
    L_SHARE_COMPANY COMPANIES.RN%type;
    L_MASTERCODE    UNITLIST.UNITCODE%type;
  begin
    open LC_FUNCCODE;
    fetch LC_FUNCCODE
      into L_FUNC;
    close LC_FUNCCODE;
    GET_UNIT_ATTRIBUTES(NCOMPANY, NDOCUMENT, SUNITCODE, L_CRN, L_JURPERS, L_SHARE_COMPANY, L_MASTERCODE);
    PKG_ENV.ACCESS(NCOMPANY  => L_SHARE_COMPANY,
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
                                              '  from UDO_LINKEDDOCS T,' || CHR(10) || '       USERLIST       U' ||
                                              CHR(10) || ' where T.AUTHID = U.AUTHID' || CHR(10) ||
                                              '   and T.DOCUMENT = :1' || CHR(10) || '   and T.UNITCODE = :2';
    C_SQL_CTLG_PRIV  constant PKG_STD.TSQL := CHR(10) ||
                                              '   and exists(select * from V_USERPRIV UP where UP.CATALOG  = :3)';
    C_SQL_JPERS_PRIV constant PKG_STD.TSQL := CHR(10) ||
                                              '   and exists( select * from V_USERPRIV UP where UP.JUR_PERS = :4 and UP.UNITCODE=:5)';
    L_CRN           ACATALOG.RN%type;
    L_JURPERS       JURPERSONS.RN%type;
    L_RES_ROW       CUR_LINKEDDOCS%rowtype;
    L_SHARE_COMPANY COMPANIES.RN%type;
    L_MASTERCODE    UNITLIST.UNITCODE%type;
  begin
    GET_UNIT_ATTRIBUTES(NCOMPANY, NDOCUMENT, SUNITCODE, L_CRN, L_JURPERS, L_SHARE_COMPANY, L_MASTERCODE);

    if L_CRN is null and L_JURPERS is null then
      open L_RES_CUR for C_SQL
        using NDOCUMENT, SUNITCODE;
    elsif L_CRN is not null and L_JURPERS is null then
      open L_RES_CUR for C_SQL || C_SQL_CTLG_PRIV
        using NDOCUMENT, SUNITCODE, L_CRN;
    elsif L_CRN is null and L_JURPERS is not null then
      open L_RES_CUR for C_SQL || C_SQL_JPERS_PRIV
        using NDOCUMENT, SUNITCODE, L_JURPERS, L_MASTERCODE;
    else
      /*      P_EXCEPTION(0,C_SQL || C_SQL_CTLG_PRIV || C_SQL_JPERS_PRIV || CR ||
            'NDOCUMENT=%S'||CR||'SUNITCODET=%S'||CR||'L_CRNT=%S'||CR||'L_JURPERST=%S'||CR||'SUNITCODE=%S',
            NDOCUMENT, SUNITCODE, L_CRN, L_JURPERS, SUNITCODE
            );
      */
      open L_RES_CUR for C_SQL || C_SQL_CTLG_PRIV || C_SQL_JPERS_PRIV
        using NDOCUMENT, SUNITCODE, L_CRN, L_JURPERS, L_MASTERCODE;
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
    PKG_ENV.PROLOGUE(NCOMPANY, null, null, null, null, LINKEDDOC_UNITCODE, LINKEDDOC_FUNC_INSERT, LINKEDDOC_TABLENAME);
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
       where T.NRN in (select S.DOCUMENT from SELECTLIST S where S.IDENT = NIDENT);
    L_FILE LC_FILES%rowtype;
  begin
    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_DLOAD,
                     LINKEDDOC_TABLENAME,
                     NDOCUMENT);
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
    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     null,
                     null,
                     null,
                     LINKEDDOC_UNITCODE,
                     LINKEDDOC_FUNC_DLOAD,
                     LINKEDDOC_TABLENAME,
                     NDOCUMENT);
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
