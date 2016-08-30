create or replace package UDO_PKG_LINKEDDOCS is

  -- Author  : IGOR-GO
  -- Created : 15.01.2016 9:32:04
  -- Purpose :

  cursor CUR_LINKEDDOCS is
    select
    /* Регистрационный  номер */
     T.RN as NRN,
     /* Организация  (ссылка на COMPANIES(RN)) */
     T.COMPANY as NCOMPANY,
     /* Имя файла на сервере (GUID) */
     T.INT_NAME as SINT_NAME,
     /* Мнемокод раздела */
     T.UNITCODE as SUNITCODE,
     /* Регистрационный номер документа в разделе */
     T.DOCUMENT as NDOCUMENT,
     /* Имя файла */
     T.REAL_NAME as SREAL_NAME,
     /* Дата и время загрузки */
     T.UPLOAD_TIME as DUPLOAD_TIME,
     /* Срок хранения */
     T.SAVE_TILL as DSAVE_TILL,
     /* Папка хранения */
     T.FILESTORE as NFILESTORE,
     /* Размер файла */
     T.FILESIZE as NFILESIZE,
     /* Пользователь выполнивший загрузку */
     T.AUTHID as SAUTHID,
     /* Полное имя пользователя */
     U.NAME as SUSERFULLNAME,
     /* Примечание */
     T.NOTE as SNOTE,
     /* Признак удаленного по сроку файла*/
     T.FILE_DELETED as NFILE_DELETED
      from UDO_LINKEDDOCS T,
           USERLIST       U
     where T.AUTHID = U.AUTHID;

  type T_LINKEDDOCS is table of CUR_LINKEDDOCS%rowtype;

  function V
  (
    NCOMPANY  in number,
    NDOCUMENT in number,
    SUNITCODE in varchar2
  ) return T_LINKEDDOCS
    pipelined;

  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- Организация  (ссылка на COMPANIES(RN))
    SUNITCODE  in varchar2, -- Мнемокод раздела
    NDOCUMENT  in number, -- Регистрационный номер документа в разделе
    SREAL_NAME in varchar2, -- Имя файла
    SNOTE      in varchar2, -- Примечание
    BFILEDATA  in blob, -- файл
    NRN        out number -- Регистрационный  номер
  );

  procedure DOC_UPDATE
  (
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN      in number, -- Регистрационный  номер
    SNOTE    in varchar2 -- Примечание
  );

  procedure DOC_DELETE
  (
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN      in number -- Регистрационный  номер
  );

  procedure DOWNLOAD
  (
    NCOMPANY  in number, -- Организация  (ссылка на COMPANIES(RN))
    NIDENT    in number, -- Идентификатор списка выбора
    NDOCUMENT in number, -- RN записи основного раздела
    SUNITCODE in varchar2, -- Код основного раздела
    NFBIDENT  in number -- Идентификатор файлового буфера
  );

  procedure CLEAR_EXPIRED(NCOMPANY in number);

end UDO_PKG_LINKEDDOCS;
/
