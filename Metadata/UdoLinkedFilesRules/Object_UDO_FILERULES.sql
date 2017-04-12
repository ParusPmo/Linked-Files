/* Разделы присоединенных файлов */
create table UDO_FILERULES
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Раздел системы */
UNITCODE          varchar2( 40 ) not null
                  constraint UDO_C_FILERULES_UNITCODE_NB check( RTRIM(UNITCODE) IS NOT NULL ),
/* Место хранения */
FILESTORE         number( 17 ) not null,
/* Максимальное кол-во присоединенных к записи файлов (0 - неограничено) */
MAXFILES          number( 6 ) default 0 not null
                  constraint UDO_C_FILERULES_MAXFILES_VAL check( MAXFILES >= 0 ),
/* Максимальное размер присоединенного файла (Кбайт) (0 - неограничено) */
MAXFILESIZE       number( 15 ) default 0 not null
                  constraint UDO_C_FILERULES_MAXSIZE_VAL check( MAXFILESIZE >= 0 ),
/* Срок хранения файла (мес) (0 - неограничено) */
LIFETIME          number( 4 ) default 0 not null
                  constraint UDO_C_FILERULES_LIFETIME_VAL check( LIFETIME >= 0 ),
/* Заблокировать добавление */
BLOCKED           number( 1 ) default 0 not null
                  constraint UDO_C_FILERULES_BLOCKED_VAL check( BLOCKED IN (0,1) ),
/* Действие системы */
UNITFUNC          number( 17 ) not null,
/* ключи */
constraint UDO_C_FILERULES_PK primary key (RN),
constraint UDO_C_FILERULES_UNITCODE_UK unique (UNITCODE,COMPANY)
);
