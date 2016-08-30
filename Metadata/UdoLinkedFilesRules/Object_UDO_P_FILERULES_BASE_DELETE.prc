/* ������� �������� */
create or replace procedure UDO_P_FILERULES_BASE_DELETE
(
  NRN      in number, -- ���������������  �����
  NCOMPANY in number  -- �����������  (������ �� COMPANIES(RN))
) as
  L_DOC_CNT number;
  cursor LC_RULE is
    select *
      from UDO_FILERULES T
     where RN = NRN
       and COMPANY = NCOMPANY;
  L_RULE LC_RULE%rowtype;
begin
  /* ���������� ������ */
  open LC_RULE;
  fetch LC_RULE
    into L_RULE;
  close LC_RULE;
  /* �������� ������� �������������� ������ */
  select count(*)
    into L_DOC_CNT
    from DUAL
   where exists (select *
            from UDO_LINKEDDOCS T
           where T.COMPANY = L_RULE.COMPANY
             and T.UNITCODE = L_RULE.UNITCODE);
  if L_DOC_CNT > 0 then
    P_EXCEPTION(0,
                '� ������� ���������������� �������������� ��������� �� ���������� �������.');
  end if;
  /* �������� ������ �� ������� */
  delete from UDO_FILERULES
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (sql%notfound) then
    PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFilesRules');
  end if;
  /* �������� �������� */
  P_UNITFUNC_BASE_DELETE(L_RULE.UNITFUNC,
                         1 -- nTECHNOLOGY
                         );
end;
/
show errors procedure UDO_P_FILERULES_BASE_DELETE;
