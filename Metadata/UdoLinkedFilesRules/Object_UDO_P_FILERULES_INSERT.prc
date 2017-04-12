create or replace procedure UDO_P_FILERULES_INSERT
(
  NCOMPANY     in number,   -- �����������  (������ �� COMPANIES(RN))
  SUNITNAME    in varchar2, -- ������������ �������
  SFILESTORE   in varchar2, -- ����� ��������
  NMAXFILES    in number,   -- ������������ ���-�� �������������� � ������ ������ (0 - ������������)
  NMAXFILESIZE in number,   -- ������������ ������ ��������������� ����� (�����) (0 - ������������)
  NLIFETIME    in number,   -- ���� �������� ����� (���) (0 - ������������)
  NRN          out number   -- ���������������  �����
) as
  NFILESTORE PKG_STD.TREF; -- ����� ��������
  SUNITCODE  UNITLIST.UNITCODE%type;
begin
  /* ���������� ������ */
  UDO_P_FILERULES_JOINS(NCOMPANY, SFILESTORE, SUNITNAME, NFILESTORE, SUNITCODE);

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_INSERT',
                   'UDO_FILERULES');

  /* ������� ���������� */
  UDO_P_FILERULES_BASE_INSERT(NCOMPANY,
                              SUNITCODE,
                              NFILESTORE,
                              NMAXFILES,
                              NMAXFILESIZE,
                              NLIFETIME,
                              NRN);

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_INSERT',
                   'UDO_FILERULES',
                   NRN);
end;

/
