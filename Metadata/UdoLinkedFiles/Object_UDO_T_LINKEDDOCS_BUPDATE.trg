create or replace trigger UDO_T_LINKEDDOCS_BUPDATE
  before update on UDO_LINKEDDOCS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_LINKEDDOCS', 'U') ) then
    PKG_IUD.REG_RN('RN', :new.RN, :old.RN);
    PKG_IUD.REG('COMPANY', :new.COMPANY, :old.COMPANY);
    PKG_IUD.REG('INT_NAME', :new.INT_NAME, :old.INT_NAME);
    PKG_IUD.REG(1, 'UNITCODE', :new.UNITCODE, :old.UNITCODE);
    PKG_IUD.REG(2, 'DOCUMENT', :new.DOCUMENT, :old.DOCUMENT);
    PKG_IUD.REG(3, 'REAL_NAME', :new.REAL_NAME, :old.REAL_NAME);
    PKG_IUD.REG('UPLOAD_TIME', :new.UPLOAD_TIME, :old.UPLOAD_TIME);
    PKG_IUD.REG('SAVE_TILL', :new.SAVE_TILL, :old.SAVE_TILL);
    PKG_IUD.REG('FILESIZE', :new.FILESIZE, :old.FILESIZE);
    PKG_IUD.REG('AUTHID', :new.AUTHID, :old.AUTHID);
    PKG_IUD.REG('NOTE', :new.NOTE, :old.NOTE);
    PKG_IUD.REG('FILE_DELETED', :new.FILE_DELETED, :old.FILE_DELETED);
    PKG_IUD.REG('FILESTORE', :new.FILESTORE, :old.FILESTORE);
    PKG_IUD.EPILOGUE;
  end if;
end;

/
