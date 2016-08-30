/* ���������� ������ */
create or replace procedure UDO_P_FILERULES_JOINS
(
  NCOMPANY   in number,   -- ��������������� ����� �����������
  SFILESTORE in varchar2, -- ����� ��������
  SUNITNAME  in varchar2, -- ������������ �������
  NFILESTORE out number,  -- ����� ��������
  SUNITCODE  out varchar2 -- ��� �������
) as
begin
  FIND_UNITLIST_NAME(NFLAG_SMART  => 0,
                     NFLAG_OPTION => 1,
                     SNAME        => SUNITNAME,
                     SCODE        => SUNITCODE,
                     NRN          => PKG_STD.VREF);

  FIND_UDO_FILESTORES_CODE(NFLAG_SMART  => 0,
                           NFLAG_OPTION => 0,
                           NCOMPANY     => NCOMPANY,
                           SCODE        => SFILESTORE,
                           NRN          => NFILESTORE);

end;
/
show errors procedure UDO_P_FILERULES_JOINS;
