create or replace and compile java source named "FileHandler" as
import java.util.*;
import java.lang.*;
import java.io.*;
import oracle.sql.*;
import java.sql.*;

public class FileHandler
{
  private static int SUCCESS = 1;
  private static  int FAILURE = 0;

  public static int exists (String path)
  {
    File lFile = new File (path);
    if (lFile.exists()) return SUCCESS;
    else return FAILURE;
  }

  public static int write(String path, BLOB blob)
  throws    Exception,
            SQLException,
            IllegalAccessException,
            InstantiationException,
            ClassNotFoundException
  {
    try
    {
      File              lFile   = new File(path);
      FileOutputStream  lOutStream  = new FileOutputStream(lFile);
      InputStream       lInStream   = blob.getBinaryStream();

      int     lLength  = -1;
      int     lSize    = blob.getBufferSize();
      byte[]  lBuffer  = new byte[lSize];

      while ((lLength = lInStream.read(lBuffer)) != -1)
      {
        lOutStream.write(lBuffer, 0, lLength);
        lOutStream.flush();
      }

      lInStream.close();
      lOutStream.close();
      return SUCCESS;
    }
    catch (Exception e)
    {
      e.printStackTrace();
      throw e;
    }
  }

  public static int delete (String path) {
    File lFile = new File (path);
    if (lFile.delete()) return SUCCESS; else return FAILURE;
  }

  public static int isDirectory (String path) {
    File lFile = new File (path);
    if (lFile.isDirectory()) return SUCCESS; else return FAILURE;
  }

  public static String getPathSeparator() {
    return File.separator;
  }

  public static int isFile (String path) {
    File lFile = new File (path);
    if (lFile.isFile()) return SUCCESS; else return FAILURE;
  }

  public static int createDirectory (String path)
  throws    Exception,
            IllegalAccessException,
            InstantiationException,
            ClassNotFoundException
  {
    File lDir = new File (path);
    if (!lDir.exists()) {
       try {
        lDir.mkdir();
        return SUCCESS;
       }
       catch(Exception e){
          e.printStackTrace();
          throw e;
       }
    } else {
        return FAILURE;
    }
  }
}

