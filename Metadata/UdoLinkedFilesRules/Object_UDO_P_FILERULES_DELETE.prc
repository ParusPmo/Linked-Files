/* �������� ������ */
create or replace procedure UDO_P_FILERULES_DELETE
(
  NRN      in number, -- ���������������  �����
  NCOMPANY in number -- �����������  (������ �� COMPANIES(RN))
) as
  LFILERULE UDO_FILERULES%rowtype;
begin
  /* ���������� ������ */
  UDO_P_FILERULES_EXISTS(NRN, NCOMPANY, LFILERULE);

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_DELETE',
                   'UDO_FILERULES',
                   NRN);

  /* ������� �������� */
  UDO_P_FILERULES_BASE_DELETE(NRN, NCOMPANY);

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_DELETE',
                   'UDO_FILERULES',
                   NRN);
end;
/
show errors procedure UDO_P_FILERULES_DELETE;
