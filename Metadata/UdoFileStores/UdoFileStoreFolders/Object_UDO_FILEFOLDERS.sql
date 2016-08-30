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
