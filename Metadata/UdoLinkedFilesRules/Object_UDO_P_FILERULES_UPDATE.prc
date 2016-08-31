/* ����������� ������ */
create or replace procedure UDO_P_FILERULES_UPDATE
(
  NRN          in number,   -- ���������������  �����
  NCOMPANY     in number,   -- �����������  (������ �� COMPANIES(RN))
  STABLENAME   in varchar2, -- ��� ������� �������
  SCTLGFIELD   in varchar2, -- ���� ������ ���������
  SJPERSFIELD  in varchar2, -- ���� ������������ ����
  SFILESTORE   in varchar2, -- ����� ��������
  NMAXFILES    in number,   -- ������������ ���-�� �������������� � ������ ������ (0 - ������������)
  NMAXFILESIZE in number,   -- ������������ ������ ��������������� ����� (�����) (0 - ������������)
  NLIFETIME    in number    -- ���� �������� ����� (���) (0 - ������������)
) as
  NFILESTORE PKG_STD.TREF; -- ����� ��������
  LFILERULE  UDO_FILERULES%rowtype;
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
                   'UDO_FILERULES_UPDATE',
                   'UDO_FILERULES',
                   NRN);

  /* ���������� ������ */
  UDO_P_FILERULES_JOINS(NCOMPANY, SFILESTORE, null, NFILESTORE, PKG_STD.VSTRING);

  /* ������� ����������� */
  UDO_P_FILERULES_BASE_UPDATE(NRN,
                              NCOMPANY,
                              STABLENAME,
                              SCTLGFIELD,
                              SJPERSFIELD,
                              NFILESTORE,
                              NMAXFILES,
                              NMAXFILESIZE,
                              NLIFETIME);

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE(NCOMPANY,
                   null,
                   null,
                   null,
                   null,
                   'UdoLinkedFilesRules',
                   'UDO_FILERULES_UPDATE',
                   'UDO_FILERULES',
                   NRN);
end;
/
show errors procedure UDO_P_FILERULES_UPDATE;
