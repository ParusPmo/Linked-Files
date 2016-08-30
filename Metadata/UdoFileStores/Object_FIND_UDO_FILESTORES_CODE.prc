create or replace procedure FIND_UDO_FILESTORES_CODE
(
  NFLAG_SMART  in number, -- признак генерации исключения (0 - да, 1 - нет)
  NFLAG_OPTION in number, -- признак генерации исключения для пустого SCODE (0 - да, 1 - нет)
  NCOMPANY     in number, -- организация
  SCODE        in varchar2, -- мнемокод
  NRN          out number -- регистрационный номер записи места хранения
) as
begin
  /* инициализация результата */
  NRN := null;

  /* мнемокод не задан */
  if (RTRIM(SCODE) is null) then
    if (NFLAG_OPTION = 0) then
      P_EXCEPTION(NFLAG_SMART,
                  'Не задан мнемокод места хранения.');
    end if;

    /* мнемокод задан */
  else

    /* поиск записи */
    begin
      select T.RN
        into NRN
        from UDO_FILESTORES T
       where T.CODE = SCODE
         and T.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(NFLAG_SMART,
                    'Место хранения "%s" не определено.',
                    SCODE);
    end;
  end if;
end FIND_UDO_FILESTORES_CODE;
/
