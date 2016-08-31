create or replace procedure UDO_P_FILESTORES_DELETE
(
  NRN                       in number,       -- ���������������  �����
  NCOMPANY                  in number        -- �����������  (������ �� COMPANIES(RN))
)
as
  LFILESTORE      UDO_FILESTORES%rowtype;    -- ������ ����� ��������
begin
  /* ���������� ������ */
  UDO_P_FILESTORES_EXISTS
  (
    NRN,
    NCOMPANY,
    LFILESTORE
  );

  /* �������� ������ ���������� �������� */
  PKG_ENV.PROLOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );

  /* ������� �������� */
  UDO_P_FILESTORES_BASE_DELETE
  (
    NRN,
    NCOMPANY
  );

  /* �������� ��������� ���������� �������� */
  PKG_ENV.EPILOGUE( NCOMPANY,null,LFILESTORE.CRN,null,null,'UdoFileStores','UDO_FILESTORES_DELETE','UDO_FILESTORES',NRN );
end;

/
