/* ������� �������������� ������ */
create table UDO_FILERULES
(
/* ���������������  ����� */
RN                number( 17 ) not null,
/* �����������  (������ �� COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* ������ ������� */
UNITCODE          varchar2( 40 ) not null
                  constraint UDO_C_FILERULES_UNITCODE_NB check( RTRIM(UNITCODE) IS NOT NULL ),
/* ����� �������� */
FILESTORE         number( 17 ) not null,
/* ������������ ���-�� �������������� � ������ ������ (0 - ������������) */
MAXFILES          number( 6 ) default 0 not null
                  constraint UDO_C_FILERULES_MAXFILES_VAL check( MAXFILES >= 0 ),
/* ������������ ������ ��������������� ����� (�����) (0 - ������������) */
MAXFILESIZE       number( 15 ) default 0 not null
                  constraint UDO_C_FILERULES_MAXSIZE_VAL check( MAXFILESIZE >= 0 ),
/* ���� �������� ����� (���) (0 - ������������) */
LIFETIME          number( 4 ) default 0 not null
                  constraint UDO_C_FILERULES_LIFETIME_VAL check( LIFETIME >= 0 ),
/* ������������� ���������� */
BLOCKED           number( 1 ) default 0 not null
                  constraint UDO_C_FILERULES_BLOCKED_VAL check( BLOCKED IN (0,1) ),
/* �������� ������� */
UNITFUNC          number( 17 ) not null,
/* ����� */
constraint UDO_C_FILERULES_PK primary key (RN),
constraint UDO_C_FILERULES_UNITCODE_UK unique (UNITCODE,COMPANY)
);
