create or replace package UDO_PKG_FILE_API is

  /*
  ��� ������������� � ������� SYSDBA ����������
  1. C������ ����������. ��������:
    create or replace directory UDO_PARUS_LINKED_FILES as '/home/oracle/linkfilesstore';
  2. ���� ����� ��������� ����� ����� �� ������ � ������ � ���� ����������. ��������:
    grant read, write on directory UDO_PARUS_LINKED_FILES to PARUS;
  3. ���� Java ���������� �� �������� � ����� ������������ ������� ��������������� ����������. ��������:
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
