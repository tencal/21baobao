 CREATE Table #Who(spid  int ,ecid  int ,status  nvarchar ( 50 ),loginname  nvarchar ( 50 ),hostname  nvarchar ( 50 ), blk  int ,dbname  nvarchar ( 50 ),cmd  nvarchar ( 50 ),request_ID  int );
 CREATE Table  #Lock(spid  int ,dpid  int ,objid  int ,indld  int ,[ Type ]   nvarchar ( 20 ),Resource  nvarchar ( 50 ),Mode  nvarchar ( 10 ),Status  nvarchar ( 10 ));
 
 INSERT   INTO  #Who EXEC  sp_who active   -- 看哪个引起的阻塞，blk  
 INSERT   INTO  #Lock EXEC  sp_lock   -- 看锁住了那个资源id，objid  
 
 DECLARE @DBName nvarchar ( 20 )='TEHR' 
 declare @myspid int=58
 
 SELECT  #Who. *  FROM  #Who  WHERE  dbname = @DBName and spid<>@myspid
 SELECT  #Lock.*,object_name (objid)  as  objName  
 FROM  #Lock JOIN  #Who ON  #Who.spid = #Lock.spid  
 where dbname = @DBName and #Lock.spid<>@myspid
 
 -- 最后发送到SQL Server的语句 
 DECLARE  crsr  Cursor   FOR SELECT  blk  FROM  #Who  WHERE  dbname = @DBName   AND  blk <> 0 ;
 DECLARE   @blk   int ;
 open  crsr;
 FETCH   NEXT   FROM  crsr  INTO   @blk ;
 WHILE  ( @@FETCH_STATUS   =   0 )
 BEGIN ;
      dbcc  inputbuffer( @blk );
      FETCH   NEXT   FROM  crsr  INTO   @blk ;
 END ;
 close  crsr;
 DEALLOCATE  crsr;
 
 -- 锁定的资源 
 SELECT  #Who.spid,hostname,objid, [ type ] ,mode, object_name (objid)  as  objName  
 FROM  #Lock JOIN  #Who ON  #Who.spid = #Lock.spid AND  dbname = @DBName 
 WHERE  objid <> 0 and #Who.spid<>@myspid;
 
 DROP   Table  #Who;
 DROP   Table  #Lock; 
 
 --kill 58
EXEC  sp_who_lock