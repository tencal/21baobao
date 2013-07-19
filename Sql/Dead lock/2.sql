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
 
 ---- Query2 --按顺序访问
 --Begin   Tran 
 --   SELECT   *   FROM  Lock1 -- 在Lock1上申请S锁 
 --   WaitFor  Delay  ' 00:01:00 ' ;
 --   Update  Lock2  Set  C1 = C1 + 1 ; -- Lock2:RID:X 
 --Rollback   Tran ; 
 
 -- Query 2  --用with(nolock)
 --Begin   Tran 
 --   Update  Lock2  Set  C1 = C1 + 1 ;
 --   WaitFor  Delay  ' 00:00:10 ' ;
 --   SELECT   *   FROM  Lock1 with(nolock)
 --Rollback   Tran ; 
 
 -- -- Query 2  --牺牲自己成全别人
 --SET LOCK_TIMEOUT 1000 
 --Begin   Tran 
 --   Update  Lock2  Set  C1 = C1 + 1 ;
    
 --   WaitFor  Delay  ' 00:00:10 ' ;
    
 --   SELECT   *   FROM  Lock1
 --Rollback   Tran ; 
 --SET LOCK_TIMEOUT -1
 
-- -- Query 2 --使用低隔离级别
 --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
 --Begin   Tran 
 --   Update  Lock2  Set  C1 = C1 + 1 ;
    
 --   WaitFor  Delay  ' 00:00:10 ' ;
    
 --   SELECT   *   FROM  Lock1
 --Rollback   Tran ;
 --SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
 
 

---- -- Query 2 --这方法还没研究出来
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