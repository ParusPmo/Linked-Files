/* ���������� ������ */
create or replace procedure UDO_P_FILERULES_EXISTS
(
  NRN       in number,                -- ���������������  �����
  NCOMPANY  in number,                -- �����������  (������ �� COMPANIES(RN))
  RFILERULE out UDO_FILERULES%rowtype -- ������ ����� � ��������
) as
begin
  /* ����� ������ */
  begin
    select *
      into RFILERULE
      from UDO_FILERULES
     where RN = NRN
       and COMPANY = NCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NRN, 'UdoLinkedFilesRules');
  end;
end;
/
show errors procedure UDO_P_FILERULES_EXISTS;
