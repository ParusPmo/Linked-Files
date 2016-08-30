/* Триггер до добавления */
create or replace trigger UDO_T_LINKEDDOCS_BINSERT
  before insert on UDO_LINKEDDOCS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_LINKEDDOCS', 'I') ) then
    PKG_IUD.REG('RN', :new.RN);
    PKG_IUD.REG('COMPANY', :new.COMPANY);
    PKG_IUD.REG('INT_NAME', :new.INT_NAME);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE);
    PKG_IUD.REG(2, 'DOCUMENT', :new.DOCUMENT);
    PKG_IUD.REG(3, 'REAL_NAME', :new.REAL_NAME);
    PKG_IUD.REG('UPLOAD_TIME', :new.UPLOAD_TIME);
    PKG_IUD.REG('SAVE_TILL', :new.SAVE_TILL);
    PKG_IUD.REG('FILESIZE', :new.FILESIZE);
    PKG_IUD.REG('AUTHID', :new.AUTHID);
    PKG_IUD.REG('NOTE', :new.NOTE);
    PKG_IUD.REG('FILE_DELETED', :new.FILE_DELETED);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_LINKEDDOCS_BINSERT;
