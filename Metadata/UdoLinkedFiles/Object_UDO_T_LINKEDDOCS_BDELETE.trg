create or replace trigger UDO_T_LINKEDDOCS_BDELETE
  before delete on UDO_LINKEDDOCS for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_LINKEDDOCS', 'D') ) then
    PKG_IUD.REG_RN('RN', :old.RN);
    PKG_IUD.REG('COMPANY', :old.COMPANY);
    PKG_IUD.REG('INT_NAME', :old.INT_NAME);
    PKG_IUD.REG(1, 'UNITCODE', :old.UNITCODE);
    PKG_IUD.REG(2, 'DOCUMENT', :old.DOCUMENT);
    PKG_IUD.REG(3, 'REAL_NAME', :old.REAL_NAME);
    PKG_IUD.REG('UPLOAD_TIME', :old.UPLOAD_TIME);
    PKG_IUD.REG('SAVE_TILL', :old.SAVE_TILL);
    PKG_IUD.REG('FILESIZE', :old.FILESIZE);
    PKG_IUD.REG('AUTHID', :old.AUTHID);
    PKG_IUD.REG('NOTE', :old.NOTE);
    PKG_IUD.REG('FILE_DELETED', :old.FILE_DELETED);
    PKG_IUD.REG('FILESTORE', :old.FILESTORE);
    PKG_IUD.EPILOGUE;
  end if;
end;

/
