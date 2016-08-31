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
