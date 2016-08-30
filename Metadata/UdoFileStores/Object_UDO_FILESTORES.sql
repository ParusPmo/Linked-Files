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
