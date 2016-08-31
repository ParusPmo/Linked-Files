/* Места хранения файлов (папки) */
create table UDO_FILEFOLDERS
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Каталог  (ссылка на ACATALOG(RN)) */
CRN               number( 17 ) not null,
/* Регистрационный номер родительской записи */
PRN               number( 17 ) not null,
/* Наименование папки */
NAME              varchar2( 36 ) not null
                  constraint UDO_C_FILEFOLDERS_NAME_NB check( RTRIM(NAME) IS NOT NULL ),
/* Количество файлов в папке */
FILECNT           number( 6 ) default 0 not null
                  constraint UDO_C_FILEFOLDERS_FILECNT_VAL check( FILECNT >= 0 ),
/* ключи */
constraint UDO_C_FILEFOLDERS_PK primary key (RN),
constraint UDO_C_FILEFOLDERS_NAME_UK unique (PRN,NAME)
);
