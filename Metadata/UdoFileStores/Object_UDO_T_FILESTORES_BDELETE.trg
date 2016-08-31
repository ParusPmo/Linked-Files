/* Триггер до удаления */
create or replace trigger UDO_T_FILESTORES_BDELETE
  before delete on UDO_FILESTORES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILESTORES', 'D') ) then
    PKG_IUD.REG_RN('RN', :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :old.COMPANY);
    PKG_IUD.REG_CRN('CRN', :old.CRN);
    PKG_IUD.REG(1, 'CODE', :old.CODE);
    PKG_IUD.REG('NAME', :old.NAME);
    PKG_IUD.REG('STORE_TYPE', :old.STORE_TYPE);
    PKG_IUD.REG('ORA_DIRECTORY', :old.ORA_DIRECTORY);
    PKG_IUD.REG('DOMAINNAME', :old.DOMAINNAME);
    PKG_IUD.REG('IPADDRESS', :old.IPADDRESS);
    PKG_IUD.REG('PORT', :old.PORT);
    PKG_IUD.REG('USERNAME', :old.USERNAME);
    PKG_IUD.REG('PASSWORD', :old.PASSWORD);
    PKG_IUD.REG('ROOTFOLDER', :old.ROOTFOLDER);
    PKG_IUD.REG('MAXFILES', :old.MAXFILES);
    PKG_IUD.REG('NOTE', :old.NOTE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILESTORES_BDELETE;
