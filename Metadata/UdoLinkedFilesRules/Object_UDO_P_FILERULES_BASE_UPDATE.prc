create or replace procedure UDO_P_FILERULES_BASE_UPDATE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NFILESTORE                in number,       -- ����� ��������
  NMAXFILES                 in number,       -- ������������ ���-�� �������������� � ������ ������ (0 - ������������)
  NMAXFILESIZE              in number,       -- ������������ ������ ��������������� ����� (�����) (0 - ������������)
  NLIFETIME                 in number        -- ���� �������� ����� (���) (0 - ������������)
)
as
begin
  /* ����������� ������ � ������� */
  update UDO_FILERULES
     set FILESTORE = NFILESTORE,
         MAXFILES = NMAXFILES,
         MAXFILESIZE = NMAXFILESIZE,
         LIFETIME = NLIFETIME
   where RN = NRN
     and COMPANY = NCOMPANY;

  if (SQL%NOTFOUND) then
    PKG_MSG.RECORD_NOT_FOUND( NRN,'UdoLinkedFilesRules' );
  end if;
end;

/
