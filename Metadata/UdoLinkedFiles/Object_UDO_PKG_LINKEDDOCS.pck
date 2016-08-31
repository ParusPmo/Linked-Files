create or replace package UDO_PKG_LINKEDDOCS is

  -- Author  : IGOR-GO
  -- Created : 15.01.2016 9:32:04
  -- Purpose :

  cursor CUR_LINKEDDOCS is
    select
    /* ���������������  ����� */
     T.RN as NRN,
     /* �����������  (������ �� COMPANIES(RN)) */
     T.COMPANY as NCOMPANY,
     /* ��� ����� �� ������� (GUID) */
     T.INT_NAME as SINT_NAME,
     /* �������� ������� */
     T.UNITCODE as SUNITCODE,
     /* ��������������� ����� ��������� � ������� */
     T.DOCUMENT as NDOCUMENT,
     /* ��� ����� */
     T.REAL_NAME as SREAL_NAME,
     /* ���� � ����� �������� */
     T.UPLOAD_TIME as DUPLOAD_TIME,
     /* ���� �������� */
     T.SAVE_TILL as DSAVE_TILL,
     /* ����� �������� */
     T.FILESTORE as NFILESTORE,
     /* ������ ����� */
     T.FILESIZE as NFILESIZE,
     /* ������������ ����������� �������� */
     T.AUTHID as SAUTHID,
     /* ������ ��� ������������ */
     U.NAME as SUSERFULLNAME,
     /* ���������� */
     T.NOTE as SNOTE,
     /* ������� ���������� �� ����� �����*/
     T.FILE_DELETED as NFILE_DELETED
      from UDO_LINKEDDOCS T,
           USERLIST       U
     where T.AUTHID = U.AUTHID;

  type T_LINKEDDOCS is table of CUR_LINKEDDOCS%rowtype;

  function V
  (
    NCOMPANY  in number,
    NDOCUMENT in number,
    SUNITCODE in varchar2
  ) return T_LINKEDDOCS
    pipelined;

  procedure DOC_INSERT
  (
    NCOMPANY   in number, -- �����������  (������ �� COMPANIES(RN))
    SUNITCODE  in varchar2, -- �������� �������
    NDOCUMENT  in number, -- ��������������� ����� ��������� � �������
    SREAL_NAME in varchar2, -- ��� �����
    SNOTE      in varchar2, -- ����������
    BFILEDATA  in blob, -- ����
    NRN        out number -- ���������������  �����
  );

  procedure DOC_UPDATE
  (
    NCOMPANY in number, -- �����������  (������ �� COMPANIES(RN))
    NRN      in number, -- ���������������  �����
    SNOTE    in varchar2 -- ����������
  );

  procedure DOC_DELETE
  (
    NCOMPANY in number, -- �����������  (������ �� COMPANIES(RN))
    NRN      in number -- ���������������  �����
  );

  procedure DOWNLOAD
  (
    NCOMPANY  in number, -- �����������  (������ �� COMPANIES(RN))
    NIDENT    in number, -- ������������� ������ ������
    NDOCUMENT in number, -- RN ������ ��������� �������
    SUNITCODE in varchar2, -- ��� ��������� �������
    NFBIDENT  in number -- ������������� ��������� ������
  );

  procedure CLEAR_EXPIRED(NCOMPANY in number);

end UDO_PKG_LINKEDDOCS;
/
