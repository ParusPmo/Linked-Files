/* Триггер до удаления */
create or replace trigger UDO_T_FILEFOLDERS_BDELETE
  before delete on UDO_FILEFOLDERS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILEFOLDERS', 'D') ) then
    PKG_IUD.REG_RN('RN', :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :old.COMPANY);
    PKG_IUD.REG_CRN('CRN', :old.CRN);
    PKG_IUD.REG_PRN('PRN', :old.PRN);
    PKG_IUD.REG(1, 'NAME', :old.NAME);
    PKG_IUD.REG('FILECNT', :old.FILECNT);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILEFOLDERS_BDELETE;
