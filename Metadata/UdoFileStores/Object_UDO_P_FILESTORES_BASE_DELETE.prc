/* ������� �������� */
create or replace procedure UDO_P_FILESTORES_BASE_DELETE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number        -- �����������  (������ �� COMPANIES(RN))
)
as
begin
  /* �������� ������ �� ������� */
  delete
    from UDO_FILESTORES
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoFileStores' );
  end if;
end;
/
show errors procedure UDO_P_FILESTORES_BASE_DELETE;
