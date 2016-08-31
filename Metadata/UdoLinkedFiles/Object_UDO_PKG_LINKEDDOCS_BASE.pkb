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
