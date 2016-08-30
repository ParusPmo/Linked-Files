create or replace procedure UDO_P_FILERULES_UNBLOCK
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
                   'UDO_FILERULES_UNBLOCK',
                   'UDO_FILERULES',
                   NRN);

  /* ������� �������� */
  UDO_P_FILERULES_BASE_STATUS(NRN, NCOMPANY, 0);

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UNBLOCK',
                   'UDO_FILERULES',
                   NRN);
end;
/
