/* Триггер до добавления */
create or replace trigger UDO_T_FILERULES_BINSERT
  before insert on UDO_FILERULES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILERULES', 'I') ) then
    PKG_IUD.REG_RN('RN', :new.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES);
    PKG_IUD.REG('MAXFILESIZE', :new.MAXFILESIZE);
    PKG_IUD.REG('LIFETIME', :new.LIFETIME);
    PKG_IUD.REG('BLOCKED', :new.BLOCKED);
    PKG_IUD.REG('TABLENAME', :new.TABLENAME);
    PKG_IUD.REG('CTLGFIELD', :new.CTLGFIELD);
    PKG_IUD.REG('JPERSFIELD', :new.JPERSFIELD);
    PKG_IUD.REG('UNITFUNC', :new.UNITFUNC);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILERULES_BINSERT;
