/* Триггер до исправления */
create or replace trigger UDO_T_FILESTORES_BUPDATE
  before update on UDO_FILESTORES for each row
begin
  /* проверка неизменности значений полей */
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'RN', :new.RN, :old.RN);
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'COMPANY', :new.COMPANY, :old.COMPANY);
  PKG_UNCHANGE.CHECK_NE('UDO_FILESTORES', 'STORE_TYPE', :new.STORE_TYPE, :old.STORE_TYPE);

  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILESTORES', 'U') ) then
    PKG_IUD.REG_RN('RN', :new.RN, :old.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY, :old.COMPANY);
    PKG_IUD.REG_CRN('CRN', :new.CRN, :old.CRN);
    PKG_IUD.REG(1, 'CODE', :new.CODE, :old.CODE);
    PKG_IUD.REG('NAME', :new.NAME, :old.NAME);
    PKG_IUD.REG('STORE_TYPE', :new.STORE_TYPE, :old.STORE_TYPE);
    PKG_IUD.REG('ORA_DIRECTORY', :new.ORA_DIRECTORY, :old.ORA_DIRECTORY);
    PKG_IUD.REG('DOMAINNAME', :new.DOMAINNAME, :old.DOMAINNAME);
    PKG_IUD.REG('IPADDRESS', :new.IPADDRESS, :old.IPADDRESS);
    PKG_IUD.REG('PORT', :new.PORT, :old.PORT);
    PKG_IUD.REG('USERNAME', :new.USERNAME, :old.USERNAME);
    PKG_IUD.REG('PASSWORD', :new.PASSWORD, :old.PASSWORD);
    PKG_IUD.REG('ROOTFOLDER', :new.ROOTFOLDER, :old.ROOTFOLDER);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES, :old.MAXFILES);
    PKG_IUD.REG('NOTE', :new.NOTE, :old.NOTE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILESTORES_BUPDATE;
