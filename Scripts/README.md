После формирования скриптов действием "Генерация сценария раздела" необходимо
1. В скрипте раздела UdoLinkedFiles после оператора
  create or replace and compile java source named "FileHandler"
  ...
  }
  необходимо добавить строку
  /

2. Объеденить файлы скриптов разделов UdoFileStores, UdoLinkedFiles, UdoLinkedFilesRules в один файл в указанной последовательности

3. В полученном файле перенести оператор создания таблицы UDO_FILERULES 
  create table UDO_FILERULES
  ...
  сразу после оперератора создания таблицы UDO_LINKEDDOCS 
  create table UDO_LINKEDDOCS
  ...
  
4. Полученный файл сохранить как Linked-Files-Script.sql