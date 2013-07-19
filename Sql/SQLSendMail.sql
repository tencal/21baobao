exec send_mail

--send mail
Declare @ret int
exec sp_sendmail 'smtp.tom.com',
                 'tencal',
                 'll887033',
                 'tencal@tom.com',
                 'tencal@163.com',
                 'nello.liao@163.com;',
                 'Mail from sp_Sendmail',
                 'body',
                 @ret output