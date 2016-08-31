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
