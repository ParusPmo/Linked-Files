/* �������������� ����� */
create table UDO_LINKEDDOCS
(
/* ���������������  ����� */
RN                number( 17 ) not null,
/* �����������  (������ �� COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* ��� ����� �� ������� (GUID) */
INT_NAME          varchar2( 36 ) not null
                  constraint UDO_C_LINKEDDOCS_INTNAME_NB check( RTRIM(INT_NAME) IS NOT NULL ),
/* �������� ������� */
UNITCODE          varchar2( 40 ) not null,
/* ��������������� ����� ��������� � ������� */
DOCUMENT          number( 17 ) not null,
/* ��� ����� */
REAL_NAME         varchar2( 160 ) not null
                  constraint UDO_C_LINKEDDOCS_REAL_NAME_NB check( RTRIM(REAL_NAME) IS NOT NULL ),
/* ���� � ����� �������� */
UPLOAD_TIME       date not null,
/* ���� �������� */
SAVE_TILL         date,
/* ������ ����� */
FILESIZE          number( 15 ),
/* ������������ ����������� �������� */
AUTHID            varchar2( 30 ) not null
                  constraint UDO_C_LINKEDDOCS_AUTHID_NB check( RTRIM(AUTHID) IS NOT NULL ),
/* ���������� */
NOTE              varchar2( 4000 ),
/* ������� ���������� �� ����� ����� */
FILE_DELETED      number( 1 ) default 0 not null
                  constraint UDO_C_LINKEDDOCS_FILE_DEL_VAL check( FILE_DELETED IN (0,1) ),
/* ����� �������� */
FILESTORE         number( 17 ) not null,
/* ����� */
constraint UDO_C_LINKEDDOCS_PK primary key (RN),
constraint UDO_C_LINKEDDOCS_INTNAME_UK unique (INT_NAME,COMPANY),
constraint UDO_C_LINKEDDOCS_REAL_NAME_UK unique (DOCUMENT,REAL_NAME,UNITCODE)
);
