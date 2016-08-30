create or replace procedure UDO_P_FILERULES_BASE_STATUS
(
  NRN      in number, -- ���������������  �����
  NCOMPANY in number, -- �����������  (������ �� COMPANIES(RN))
  NBLOCKED in number
) as
begin
  /* ����������� ������ � ������� */
  update UDO_FILERULES
     set BLOCKED = NBLOCKED
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (sql%notfound) then
    PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFilesRules');
  end if;
end;
/
