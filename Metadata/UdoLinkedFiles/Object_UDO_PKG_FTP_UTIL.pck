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
