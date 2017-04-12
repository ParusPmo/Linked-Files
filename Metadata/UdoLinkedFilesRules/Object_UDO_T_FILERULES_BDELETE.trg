/* Триггер до удаления */
create or replace trigger UDO_T_FILERULES_BDELETE
  before delete on UDO_FILERULES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILERULES', 'D') ) then
    PKG_IUD.REG_RN('RN', :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :old.COMPANY);
    PKG_IUD.REG(1, 'UNITCODE', :old.UNITCODE);
    PKG_IUD.REG('FILESTORE', :old.FILESTORE);
    PKG_IUD.REG('MAXFILES', :old.MAXFILES);
    PKG_IUD.REG('MAXFILESIZE', :old.MAXFILESIZE);
    PKG_IUD.REG('LIFETIME', :old.LIFETIME);
    PKG_IUD.REG('BLOCKED', :old.BLOCKED);
    PKG_IUD.REG('UNITFUNC', :old.UNITFUNC);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILERULES_BDELETE;
