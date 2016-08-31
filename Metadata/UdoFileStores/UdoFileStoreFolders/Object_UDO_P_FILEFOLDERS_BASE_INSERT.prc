/* ������� ���������� */
create or replace procedure UDO_P_FILEFOLDERS_BASE_INSERT
(
  NCOMPANY                  in number,       -- �����������  (������ �� COMPANIES(RN))
  NPRN                      in number,       -- ��������������� ����� ������������ ������
  SNAME                     in varchar2,     -- ������������ �����
  NFILECNT                  in number,       -- ���������� ������ � �����
  NRN                       out number       -- ���������������  �����
)
as
begin
  /* ��������� ���������������� ������ */
  NRN := gen_id;

  /* ���������� ������ � ������� */
  insert into UDO_FILEFOLDERS
  (
    RN,
    PRN,
    NAME,
    FILECNT
  )
  values
  (
    NRN,
    NPRN,
    SNAME,
    NFILECNT
  );
end;
/
show errors procedure UDO_P_FILEFOLDERS_BASE_INSERT;
