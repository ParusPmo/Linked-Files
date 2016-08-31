create or replace package UDO_PKG_LINKEDDOCS_BASE is
  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- �����������  (������ �� COMPANIES(RN))
    SUNITCODE  in varchar2, -- �������� �������
    NDOCUMENT  in number, -- ��������������� ����� ��������� � �������
    SREAL_NAME in varchar2, -- ��� �����
    SNOTE      in varchar2, -- ����������
    NFILESIZE  in number, -- ������ �����
    NFILESTORE in number, -- ���������
    NLIFETIME  in number, -- ���� ��������
    BFILEDATA  in blob, -- ����
    NRN        out number -- ���������������  �����
  );

  procedure DOC_UPDATE
  (
    NRN           in number, -- ���������������  �����
    NCOMPANY      in number, -- �����������  (������ �� COMPANIES(RN))
    SREAL_NAME    in varchar2, -- ��� �����
    SNOTE         in varchar2, -- ����������
    NFILE_DELETED in number -- ������� ���������� �� ����� �����
  );

  /* ���������� ������ */
  procedure DOC_EXISTS
  (
    NRN      in number, -- ���������������  �����
    NCOMPANY in number, -- �����������  (������ �� COMPANIES(RN))
    REC      out UDO_LINKEDDOCS%rowtype
  );

  /* �������� ������ */
  procedure DOC_DELETE
  (
    NCOMPANY      in number, -- �����������  (������ �� COMPANIES(RN))
    NRN           in number, -- ���������������  �����
    ONLY_IN_STORE in boolean default false -- ������� ������ � ���������
  );

  procedure FILE_TO_BUFFER
  (
    NFILE   in number,
    NBUFFER in number
  );

end UDO_PKG_LINKEDDOCS_BASE;
/
