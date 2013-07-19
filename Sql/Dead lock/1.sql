-- Query 1 
 Begin   Tran  
    Update  Lock1 with(tablock)  Set  C1 = C1 + 1 ;
    WaitFor  Delay  ' 00:00:30 ' ;
    SELECT   *   FROM  Lock2
 Rollback   Tran ; 
 
 