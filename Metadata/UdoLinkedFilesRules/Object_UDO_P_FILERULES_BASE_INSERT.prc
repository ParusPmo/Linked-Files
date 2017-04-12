create or replace procedure UDO_P_FILERULES_BASE_INSERT
(
  NCOMPANY     in number,   -- Организация  (ссылка на COMPANIES(RN))
  SUNITCODE    in varchar2, -- Раздел системы
  NFILESTORE   in number,   -- Место хранения
  NMAXFILES    in number,   -- Максимальное кол-во присоединенных к записи файлов (0 - неограничено)
  NMAXFILESIZE in number,   -- Максимальное размер присоединенного файла (Кбайт) (0 - неограничено)
  NLIFETIME    in number,   -- Срок хранения файла (мес) (0 - неограничено)
  NRN          out number   -- Регистрационный  номер
) as
  ACTION_NAME_UK              constant varchar2(15) := 'Приєднані файли';
  ACTION_NAME_RU              constant varchar2(20) := 'Присоединенные файлы';
  ACTION_SUFFIX               constant varchar2(6) := 'VFILES';
  LINKEDDOC_UNITCODE          constant varchar2(30) := 'UdoLinkedFiles';
  LINKDOCS_SHOW_METHOD_CODE   constant varchar2(4) := 'main';
  LINKDOCS_SHOW_METHOD_PARAMS constant clob := '<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' ||
                                               CHR(10) || '<Params UnitCode="main">' || CHR(10) ||
                                               '   <Param Name="cond_document">' || CHR(10) ||
                                               '      <Context>key</Context>' || CHR(10) || '   </Param>' || CHR(10) ||
                                               '   <Param Name="cond_unitcode">' || CHR(10) ||
                                               '      <Context>unitcode</Context>' || CHR(10) || '   </Param>' ||
                                               CHR(10) || '</Params>';

  cursor L_ACTION is
    select SUBSTR(CODE, 1, INSTR(CODE, '_', -1)) || ACTION_SUFFIX CODE
      from UNITFUNC
     where UNITCODE = SUNITCODE
       and standard = 1;
  L_UNITFUNC             PKG_STD.TREF;
  L_UNITLIST_RN          PKG_STD.TREF;
  L_LINKDOCS_SHOW_METHOD PKG_STD.TREF;
  L_SFUNCCODE            UNITFUNC.CODE%type;
  L_NFUNCNUMB            UNITFUNC.NUMB%type;
begin

  open L_ACTION;
  fetch L_ACTION
    into L_SFUNCCODE;
  close L_ACTION;

  FIND_SHOWMETHODS_CODE(0, 0, LINKEDDOC_UNITCODE, LINKDOCS_SHOW_METHOD_CODE, L_LINKDOCS_SHOW_METHOD);

  FIND_UNITLIST_CODE(0, 0, SUNITCODE, L_UNITLIST_RN);

  P_DMSCLACTIONS_POSITION(L_UNITLIST_RN, L_NFUNCNUMB);

  P_UNITFUNC_BASE_INSERT(NPRN              => L_UNITLIST_RN,
                         SDETAILCODE       => null,
                         SCODE             => L_SFUNCCODE,
                         SNAME             => ACTION_NAME_RU,
                         NNUMB             => L_NFUNCNUMB,
                         NSYSIMAGE         => null,
                         NSTANDARD         => 11, -- открыть
                         NOVERRIDE         => null,
                         NUNCOND_ACCESS    => 0,
                         NMETHOD           => null,
                         NPROCESS_MODE     => 1,
                         NTRANSACT_MODE    => 1,
                         NREFRESH_MODE     => 0,
                         NSHOW_DIALOG      => 0,
                         NONLY_CUSTOM_MODE => 0,
                         NTECHNOLOGY       => 1, -- пользовательское
                         SPRODUCER         => null,
                         ISWAP_STANDARD    => 0,
                         NRN               => L_UNITFUNC);

  insert into RESOURCES
    (RN, TABLE_NAME, TABLE_ROW, RESOURCE_NAME, RESOURCE_LANG, RESOURCE_TEXT)
  values
    (GEN_ID, 'UNITFUNC', L_UNITFUNC, 'NAME', 'UKRAINIAN', ACTION_NAME_UK);

  P_DMSCLACTIONSSTP_BASE_INSERT(NPRN             => L_UNITFUNC,
                                NPOSITION        => 1,
                                NSTPTYPE         => 1,
                                NSHOWMETHOD      => L_LINKDOCS_SHOW_METHOD,
                                NSHOWKIND        => 1,
                                CSHOWPARAMS      => LINKDOCS_SHOW_METHOD_PARAMS,
                                NUSERREPORT      => null,
                                NUAMODULE        => null,
                                NUAMODULE_ACTION => null,
                                NEXEC_PARAM      => null,
                                SPRODUCER        => null,
                                NRN              => PKG_STD.VREF);

  /* генерация регистрационного номера */
  NRN := GEN_ID;

  /* добавление записи в таблицу */
  insert into UDO_FILERULES
    (RN, COMPANY, UNITCODE, FILESTORE, MAXFILES, MAXFILESIZE, LIFETIME, BLOCKED, UNITFUNC)
  values
    (NRN, NCOMPANY, SUNITCODE, NFILESTORE, NMAXFILES, NMAXFILESIZE, NLIFETIME, 0, L_UNITFUNC);
end;
/
