-- Query 2 
 --Begin   Tran 
 --   SELECT   *   FROM  Lock1
 --   WaitFor  Delay  ' 00:00:20 ' ;
 --   SELECT   *   FROM  Lock1
 --Rollback   Tran ; 


-- Query 2 
 Begin   Tran 
    Update  Lock2  Set  C1 = C1 + 1 ;
    WaitFor  Delay  ' 00:00:20 ' ;
    SELECT   *   FROM  Lock1
 Rollback   Tran ; 
 
 ---- Query2 --��˳�����
 --Begin   Tran 
 --   SELECT   *   FROM  Lock1 -- ��Lock1������S�� 
 --   WaitFor  Delay  ' 00:01:00 ' ;
 --   Update  Lock2  Set  C1 = C1 + 1 ; -- Lock2:RID:X 
 --Rollback   Tran ; 
 
 -- Query 2  --��with(nolock)
 --Begin   Tran 
 --   Update  Lock2  Set  C1 = C1 + 1 ;
 --   WaitFor  Delay  ' 00:00:10 ' ;
 --   SELECT   *   FROM  Lock1 with(nolock)
 --Rollback   Tran ; 
 
 -- -- Query 2  --�����Լ���ȫ����
 --SET LOCK_TIMEOUT 1000 
 --Begin   Tran 
 --   Update  Lock2  Set  C1 = C1 + 1 ;
    
 --   WaitFor  Delay  ' 00:00:10 ' ;
    
 --   SELECT   *   FROM  Lock1
 --Rollback   Tran ; 
 --SET LOCK_TIMEOUT -1
 
-- -- Query 2 --ʹ�õ͸��뼶��
 --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
 --Begin   Tran 
 --   Update  Lock2  Set  C1 = C1 + 1 ;
    
 --   WaitFor  Delay  ' 00:00:10 ' ;
    
 --   SELECT   *   FROM  Lock1
 --Rollback   Tran ;
 --SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
 
 

---- -- Query 2 --�ⷽ����û�о�����
--SET  ALLOW_SNAPSHOT_ISOLATION  ON 
--SET  READ_COMMITTED_SNAPSHOT  ON 
-- Begin   Tran 
--    Update  Lock2  Set  C1 = C1 + 1 ;
    
--    WaitFor  Delay  ' 00:00:10 ' ;
    
--    SELECT   *   FROM  Lock1
-- Rollback   Tran ;
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
-- SET  ALLOW_SNAPSHOT_ISOLATION  OFF 
--SET  READ_COMMITTED_SNAPSHOT  OFF