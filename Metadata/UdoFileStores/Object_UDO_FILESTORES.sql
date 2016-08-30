/* Места хранения присоединенных файлов */
create table UDO_FILESTORES
(
/* Регистрационный  номер */
RN                number( 17 ) not null,
/* Организация  (ссылка на COMPANIES(RN)) */
COMPANY           number( 17 ) not null,
/* Каталог  (ссылка на ACATALOG(RN)) */
CRN               number( 17 ) not null,
/* Мнемокод места хранения */
CODE              varchar2( 20 ) not null
                  constraint UDO_C_FILESTORES_CODE_NB check( RTRIM(CODE) IS NOT NULL ),
/* Наименование места хранения */
NAME              varchar2( 160 ) not null
                  constraint UDO_C_FILESTORES_NAME_NB check( RTRIM(NAME) IS NOT NULL ),
/* Тип места хранения */
STORE_TYPE        number( 1 ) default 1 not null,
/* Директория Oracle */
ORA_DIRECTORY     varchar2( 30 ),
/* Доменное имя */
DOMAINNAME        varchar2( 240 ),
/* IP адрес */
IPADDRESS         varchar2( 15 ),
/* Порт FTP сервера */
PORT              number( 5 ) default 21,
/* Имя пользователя */
USERNAME          varchar2( 30 ),
/* Пароль */
PASSWORD          varchar2( 30 ),
/* Корневая папка для хранения файлов */
ROOTFOLDER        varchar2( 240 ),
/* Максимальное количество файлов в папке */
MAXFILES          number( 6 ) not null
                  constraint UDO_C_FILESTORES_MAXFILES_VAL check( MAXFILES > 0 ),
/* Примечание */
NOTE              varchar2( 4000 ),
/* ключи */
constraint UDO_C_FILESTORES_PK primary key (RN),
constraint UDO_C_FILESTORES_CODE_UK unique (CODE,COMPANY)
);
