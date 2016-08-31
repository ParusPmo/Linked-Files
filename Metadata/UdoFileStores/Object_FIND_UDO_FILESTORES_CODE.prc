create or replace procedure FIND_UDO_FILESTORES_CODE
(
  NFLAG_SMART  in number, -- ������� ��������� ���������� (0 - ��, 1 - ���)
  NFLAG_OPTION in number, -- ������� ��������� ���������� ��� ������� SCODE (0 - ��, 1 - ���)
  NCOMPANY     in number, -- �����������
  SCODE        in varchar2, -- ��������
  NRN          out number -- ��������������� ����� ������ ����� ��������
) as
begin
  /* ������������� ���������� */
  NRN := null;

  /* �������� �� ����� */
  if (RTRIM(SCODE) is null) then
    if (NFLAG_OPTION = 0) then
      P_EXCEPTION(NFLAG_SMART,
                  '�� ����� �������� ����� ��������.');
    end if;

    /* �������� ����� */
  else

    /* ����� ������ */
    begin
      select T.RN
        into NRN
        from UDO_FILESTORES T
       where T.CODE = SCODE
         and T.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(NFLAG_SMART,
                    '����� �������� "%s" �� ����������.',
                    SCODE);
    end;
  end if;
end FIND_UDO_FILESTORES_CODE;
/
