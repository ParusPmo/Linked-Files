create or replace package UDO_PKG_LINKEDDOCS_BASE is
  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- Организация  (ссылка на COMPANIES(RN))
    SUNITCODE  in varchar2, -- Мнемокод раздела
    NDOCUMENT  in number, -- Регистрационный номер документа в разделе
    SREAL_NAME in varchar2, -- Имя файла
    SNOTE      in varchar2, -- Примечание
    NFILESIZE  in number, -- размер файла
    NFILESTORE in number, -- хранилище
    NLIFETIME  in number, -- срок хранения
    BFILEDATA  in blob, -- файл
    NRN        out number -- Регистрационный  номер
  );

  procedure DOC_UPDATE
  (
    NRN           in number, -- Регистрационный  номер
    NCOMPANY      in number, -- Организация  (ссылка на COMPANIES(RN))
    SREAL_NAME    in varchar2, -- Имя файла
    SNOTE         in varchar2, -- Примечание
    NFILE_DELETED in number -- Признак удаленного по сроку файла
  );

  /* Считывание записи */
  procedure DOC_EXISTS
  (
    NRN      in number, -- Регистрационный  номер
    NCOMPANY in number, -- Организация  (ссылка на COMPANIES(RN))
    REC      out UDO_LINKEDDOCS%rowtype
  );

  /* Удаление записи */
  procedure DOC_DELETE
  (
    NCOMPANY      in number, -- Организация  (ссылка на COMPANIES(RN))
    NRN           in number, -- Регистрационный  номер
    ONLY_IN_STORE in boolean default false -- удалять только в хранилище
  );

  procedure FILE_TO_BUFFER
  (
    NFILE   in number,
    NBUFFER in number
  );

end UDO_PKG_LINKEDDOCS_BASE;
/
