/* Триггер до добавления */
create or replace trigger UDO_T_FILEFOLDERS_BINSERT
  before insert on UDO_FILEFOLDERS for each row
begin
  /* считывание параметров записи master-таблицы */
  select COMPANY,CRN
    into :new.COMPANY,:new.CRN
    from UDO_FILESTORES
   where RN = :new.PRN;

  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILEFOLDERS', 'I') ) then
    PKG_IUD.REG_RN('RN', :new.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY);
    PKG_IUD.REG_CRN('CRN', :new.CRN);
    PKG_IUD.REG_PRN('PRN', :new.PRN);
    PKG_IUD.REG(1, 'NAME', :new.NAME);
    PKG_IUD.REG('FILECNT', :new.FILECNT);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILEFOLDERS_BINSERT;
