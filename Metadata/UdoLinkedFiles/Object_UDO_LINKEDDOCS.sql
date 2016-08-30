/* Присоединенные файлы */
create table UDO_LINKEDDOCS
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Имя файла на сервере (GUID) */
INT_NAME          varchar2( 36 ) not null
                  constraint UDO_C_LINKEDDOCS_INTNAME_NB check( RTRIM(INT_NAME) IS NOT NULL ),
/* Мнемокод раздела */
UNITCODE          varchar2( 40 ) not null,
/* Регистрационный номер документа в разделе */
DOCUMENT          number( 17 ) not null,
/* Имя файла */
REAL_NAME         varchar2( 160 ) not null
                  constraint UDO_C_LINKEDDOCS_REAL_NAME_NB check( RTRIM(REAL_NAME) IS NOT NULL ),
/* Дата и время загрузки */
UPLOAD_TIME       date not null,
/* Срок хранения */
SAVE_TILL         date,
/* Размер файла */
FILESIZE          number( 15 ),
/* Пользователь выполнивший загрузку */
AUTHID            varchar2( 30 ) not null
                  constraint UDO_C_LINKEDDOCS_AUTHID_NB check( RTRIM(AUTHID) IS NOT NULL ),
/* Примечание */
NOTE              varchar2( 4000 ),
/* Признак удаленного по сроку файла */
FILE_DELETED      number( 1 ) default 0 not null
                  constraint UDO_C_LINKEDDOCS_FILE_DEL_VAL check( FILE_DELETED IN (0,1) ),
/* Папка хранения */
FILESTORE         number( 17 ) not null,
/* ключи */
constraint UDO_C_LINKEDDOCS_PK primary key (RN),
constraint UDO_C_LINKEDDOCS_INTNAME_UK unique (INT_NAME,COMPANY),
constraint UDO_C_LINKEDDOCS_REAL_NAME_UK unique (DOCUMENT,REAL_NAME,UNITCODE)
);
