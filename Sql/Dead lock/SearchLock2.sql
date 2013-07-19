/*--����ʾ��
 exec p_lockinfo 0,1
--*/
--create proc p_lockinfo
--	@kill_lock_spid bit=0,  --�Ƿ�ɱ�������Ľ���,1 ɱ��, 0 ����ʾ
--	@show_spid_if_nolock bit=0 --���û�������Ľ���,�Ƿ���ʾ����������Ϣ,1 ��ʾ,0 ����ʾ
--as

declare @kill_lock_spid bit=0
declare @show_spid_if_nolock bit=0
declare @count int,@s nvarchar(1000),@i int
select id=identity(int,1,1),��־,����ID=spid,�߳�ID=kpid,�����ID=blocked,���ݿ�ID=dbid,���ݿ���=db_name(dbid),
	�û�ID=uid,�û���=loginame,�ۼ�CPUʱ��=cpu,��½ʱ��=login_time,��������=open_tran, ����״̬=status,
	����վ��=hostname,Ӧ�ó�����=program_name,����վ����ID=hostprocess,
	����=nt_domain,������ַ=net_address
into #t from(
	select ��־=N'�����Ľ���',spid,kpid,a.blocked,dbid,uid,loginame,cpu,login_time,open_tran,
		status,hostname,program_name,hostprocess,nt_domain,net_address,
		s1=a.spid,s2=0
	from master..sysprocesses a join (
		select blocked from master..sysprocesses group by blocked
	)b on a.spid=b.blocked where a.blocked=0
	union all
	select N'|_����Ʒ_>',
		spid,kpid,blocked,dbid,uid,loginame,cpu,login_time,open_tran,
		status,hostname,program_name,hostprocess,nt_domain,net_address,
		s1=blocked,s2=1
	from master..sysprocesses a where blocked<>0
)a order by s1,s2

select @count=@@rowcount,@i=1

if @count=0 and @show_spid_if_nolock=1
begin
	insert #t
	select ��־=N'�����Ľ���',spid,kpid,blocked,dbid,db_name(dbid),uid,loginame,cpu,login_time,
		open_tran,status,hostname,program_name,hostprocess,nt_domain,net_address
	from master..sysprocesses
	
	set @count=@@rowcount
end

if @count>0
begin
	create table #t1(id int identity(1,1),a nvarchar(MAX),b Int,EventInfo nvarchar(MAX))
	if @kill_lock_spid=1
	begin
		declare @spid varchar(10),@��־ varchar(10)
		while @i<=@count
		begin
			select @spid=����ID,@��־=��־ from #t where id=@i
			insert #t1 exec('dbcc inputbuffer('+@spid+')')
			if @��־='�����Ľ���' exec('kill '+@spid)
			set @i=@i+1
		end
	end
	else
	while @i<=@count
	begin
		select @s='dbcc inputbuffer('+cast(����ID as varchar)+')' from #t where id=@i
		insert #t1 exec(@s)
		set @i=@i+1
	end
 
	insert into Tmp_lock
	select a.*,���̵�SQL���=b.EventInfo, GETDATE() as InputDate
	from #t a join #t1 b on a.id=b.id
	
	drop table #t1
end

drop table #t