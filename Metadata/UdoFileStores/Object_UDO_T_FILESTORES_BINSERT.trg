/* Триггер до добавления */
create or replace trigger UDO_T_FILESTORES_BINSERT
  before insert on UDO_FILESTORES for each row
begin
  /* регистрация события */
  if ( PKG_IUD.PROLOGUE('UDO_FILESTORES', 'I') ) then
    PKG_IUD.REG_RN('RN', :new.RN);
    PKG_IUD.REG_COMPANY('COMPANY', :new.COMPANY);
    PKG_IUD.REG_CRN('CRN', :new.CRN);
    PKG_IUD.REG(1, 'CODE', :new.CODE);
    PKG_IUD.REG('NAME', :new.NAME);
    PKG_IUD.REG('STORE_TYPE', :new.STORE_TYPE);
    PKG_IUD.REG('ORA_DIRECTORY', :new.ORA_DIRECTORY);
    PKG_IUD.REG('DOMAINNAME', :new.DOMAINNAME);
    PKG_IUD.REG('IPADDRESS', :new.IPADDRESS);
    PKG_IUD.REG('PORT', :new.PORT);
    PKG_IUD.REG('USERNAME', :new.USERNAME);
    PKG_IUD.REG('PASSWORD', :new.PASSWORD);
    PKG_IUD.REG('ROOTFOLDER', :new.ROOTFOLDER);
    PKG_IUD.REG('MAXFILES', :new.MAXFILES);
    PKG_IUD.REG('NOTE', :new.NOTE);
    PKG_IUD.EPILOGUE;
  end if;
end;
/
show errors trigger UDO_T_FILESTORES_BINSERT;
