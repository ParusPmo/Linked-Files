/* Базовое добавление */
create or replace procedure UDO_P_FILEFOLDERS_BASE_INSERT
(
  NCOMPANY                  in number,       -- Организация  (ссылка на COMPANIES(RN))
  NPRN                      in number,       -- Регистрационный номер родительской записи
  SNAME                     in varchar2,     -- Наименование папки
  NFILECNT                  in number,       -- Количество файлов в папке
  NRN                       out number       -- Регистрационный  номер
)
as
begin
  /* генерация регистрационного номера */
  NRN := gen_id;

  /* добавление записи в таблицу */
  insert into UDO_FILEFOLDERS
  (
    RN,
    PRN,
    NAME,
    FILECNT
  )
  values
  (
    NRN,
    NPRN,
    SNAME,
    NFILECNT
  );
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_INSERT;
