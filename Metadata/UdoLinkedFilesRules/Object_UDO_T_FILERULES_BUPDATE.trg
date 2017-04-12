/* Триггер до исправления */
create or replace trigger UDO_T_FILERULES_BUPDATE
  before update on UDO_FILERULES for each row
begin
  /* проверка неизменности значений полей */
  PKG_UNCHANGE.CHECK_NE('UDO_FILERULES', 'RN', :new.RN, :old.RN);
  PKG_UNCHANGE.CHECK_NE('UDO_FILERULES', 'COMPANY', :new.COMPANY, :old.COMPANY);
  PKG_UNCHANGE.CHECK_NE('UDO_FILERULES', 'UNITCODE', :new.UNITCODE, :old.UNITCODE);

  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILERULES', 'U') ) then
    PKG_IUD.REG_RN('RN', :new.RN, :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY, :old.COMPANY);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE, :old.UNITCODE);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE, :old.FILESTORE);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES, :old.MAXFILES);
    PKG_IUD.REG('MAXFILESIZE', :new.MAXFILESIZE, :old.MAXFILESIZE);
    PKG_IUD.REG('LIFETIME', :new.LIFETIME, :old.LIFETIME);
    PKG_IUD.REG('BLOCKED', :new.BLOCKED, :old.BLOCKED);
    PKG_IUD.REG('UNITFUNC', :new.UNITFUNC, :old.UNITFUNC);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILERULES_BUPDATE;
