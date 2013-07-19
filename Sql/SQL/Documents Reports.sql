 
 --Operation: Documents Reports : Invoice
 select dbo.GetStatusOfInvoice(a.invoiceno,a.bookingno,a.t_totalamount,null,a.postdate,a.voiddate,a.status)[issettle],
   isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'') + InvoiceNo[Number], 
    InvoiceDate[Date] ,  Currency,T_TotalAmount[Amount], 
     isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'') +'B'+ BookingNo[BookingNo],
       (case when F_BookingMaster_ClientType=1 then 'WIC:' + a.Attention  else 'C:' + a.AttentionTo end)[Account],
         (select englishname from gen_user with(readpast) where user_id=a.f_bookingmaster_consultant)[Consultant],
           IssuedDept + '/' + isnull((select englishname from gen_user with(readpast) where user_id=a.IssuedBy),'')[IssuedBy],Printed[Print], 
            Status  from Booking_Invoice a with(readpast) where 1=1  and InvoiceDate>='09/01/2009' and InvoiceDate<='09/23/2009' and exists (select 1 from bc_info with(readpast)
              left join (Select Refno from BC_HandleBy with(readpast)  where HandleByCode='PANYU' union select h.refno from BC_HandleBy h with(readpast)  join Gen_P_Location p with(readpast)
               on h.HandleByCode=p.L_Code  where p.L_Code='SAD') hy on bc_info.refno=bc_info.refno  where bc_info.refno=a.debtor and BCType='Debtor' and status='Active / Approved' )
                 and exists (select bookingno from booking_master c where bookingno=a.bookingno  )  order by InvoiceDate,Invoiceno 
      Go
 
 --Operation: Documents Reports : Exchange Order
 select dbo.GetStatusOfXO(a.xono,a.bookingno,null ,a.postdate,a.voiddate,a.status,a.Concert_No,a.Concert_Date)[IsSettle], 
  isnull(p_bookingmaster_orgunit,'') + XoNo[Number],  CreateDate[Date],  Currency,Amount,LCAmount,
  isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'' )+ (case when XOAttribute<2 then 'B' else ''end) + BookingNo[BookingNo],
  (select englishname from bc_info where refno=a.suppliercode)[Supplier],
  (case when a.XOAttribute = 2 then  (select englishname from gen_user with(readpast) where user_id=a.creator) else  (select c.englishname from Booking_Master b with(readpast)
   left join gen_user c with(readpast) on b.consultant=c.user_id where BookingNo=a.BookingNo) end)[Consultant],  IssuedDept + '/' + isnull((select englishname from gen_user with(readpast)
    where user_id=a.creator),'')[IssuedBy],  ((case when PaymentTerm='no credit' then 'COD' else paymentterm end) + ' / '+PaymentType)[PaymentTerm], Printed[Print],
    (case when Status=1 and Isnull(Concert_No,'')='' then 1 else 0 end)[Status]  from (select *,creator[IssuedBy],p_bookingmaster_orgunit[IssueLocation] from view_ops_xo v with(readpast) )
     a where 1=1  and CreateDate>='09/01/2009' and CreateDate<='09/23/2009' order by CreateDate,XONo 
 Go
 
 --Operation: Documents Reports : Receipt
 select dbo.GetStatusOfReceipt(a.receiptno,a.bookingno, null ,a.postdate,a.voiddate,a.BankInDate,a.status)[IsSettle],
   isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')+ReceiptNo[Number],  ReceiptDate[Date],
    Currency,T_TotalAmount[Amount],  (case when f_bookingmaster_ClientType=1 then 'WIC:' + a.Attention else 'C:' + a.AttentionTo end)[Account],
      (select englishname from gen_user with(readpast) where user_id=a.f_bookingmaster_consultant)[Consultant],  (a.IssueLocation + '/' + 
      isnull((select englishname from gen_user with(readpast) where user_id=a.IssuedBy),''))[IssuedBy],  Payment,(case when paymenttype=1 
      then CheckNo  when paymenttype<>1 and isnull(Cashcharge,0)>0 then cast(cast(Cashcharge as numeric(8,2)) as nvarchar(30)) end )[Cheque No./Card Charge],
      Printed[Print],  Status  from View_Receipt a where 1=1  and ReceiptDate>='09/01/2009' and ReceiptDate<='09/23/2009'   and exists (select 1 from bc_info with(readpast)
       left join (Select Refno from BC_HandleBy with(readpast)  where HandleByCode='PANYU' union select h.refno from BC_HandleBy h with(readpast)  join Gen_P_Location p 
       with(readpast) on h.HandleByCode=p.L_Code  where p.L_Code='SAD') hy on bc_info.refno=bc_info.refno  where bc_info.refno=a.debtor   )  and (( receipttype <> 2 
        and exists (select bookingno from booking_master c where bookingno=a.bookingno  )  ) )  order by ReceiptDate,ReceiptNo 
 Go
 
 select Payment,sum(T_TotalAmount)[TotalAmount] from View_Receipt a where 1=1   and Status=0  and ReceiptDate>='09/01/2009' and ReceiptDate<='09/23/2009'
   and exists (select 1 from bc_info left join (Select Refno from BC_HandleBy with(readpast)  where HandleByCode='PANYU' union select h.refno from BC_HandleBy h with(readpast)
     join Gen_P_Location p with(readpast) on h.HandleByCode=p.L_Code  where p.L_Code='SAD') hy on bc_info.refno=bc_info.refno  where bc_info.refno=a.debtor and status='Active / Approved' )
       and (( receipttype <> 2  and exists (select bookingno from booking_master c where bookingno=a.bookingno  )  ) )  group by payment 
 Go
 
 --Operation: Documents Reports : Credit Note
 select dbo.GetStatusOfCreditNote(a.creditnote_no,a.bookingno, Null ,a.postdate,a.voiddate,a.status)[IsSettle],
    isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')+a.CreditNote_No[Number],
      a.CreateDate[Date],  a.Currrency,a.T_TotalAmount[Amount],  isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')
      +a.InvoiceNo[InvoiceNo],  isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')+a.ReceiptNo[ReceiptNo],
        (select c.englishname from Booking_Master b with(readpast)  left join gen_user c with(readpast) on b.consultant=c.user_id where BookingNo=a.BookingNo)[Consultant],
          a.IssuedDept + '/' + isnull((select englishname from gen_user with(readpast) where user_id=a.IssuedBy),'')[IssuedBy],  a.Payment[PaymentType],a.Printed[Print],
            a.Status  from Booking_CreditNote a with(readpast) where 1=1  and a.CreateDate>='09/01/2009' and a.CreateDate<='09/23/2009'
             and exists (select 1 from bc_info with(readpast) left join (Select Refno from BC_HandleBy with(readpast)  where HandleByCode='PANYU'
              union select h.refno from BC_HandleBy h with(readpast)  join Gen_P_Location p with(readpast) on h.HandleByCode=p.L_Code  where p.L_Code='SAD') hy 
              on bc_info.refno=bc_info.refno  where bc_info.refno=a.debtor and BCType='Debtor' and status='Active / Approved')
                and exists (select bookingno from booking_master c where bookingno=a.bookingno  )  order by CreateDate,CreditNote_No 
 Go
 
 --Operation: Documents Reports : Debit Note
  select dbo.GetStatusOfDebitNote(a.debitnote_no,a.bookingno,a.debittype,a.amount, null ,a.postdate,a.voiddate,a.status)[IsSettle],
    P_OrgUnit+a.DebitNote_No[Number],  a.CreateDate[Date],  a.Currrency[Currency],a.Amount,a.lCAmount,
      (select p_bookingmaster_orgunit+xono from view_all_xo where xono=a.xono)[XoNo],
        P_OrgUnit+(select top 1 paymentno from booking_payment with(readpast) where documentno=a.xono and paymentno <> '')[PaymentNo],
          (select c.englishname from gen_user c with(readpast) where user_id=  isnull((select consultant from Booking_Master b with(readpast)
           where BookingNo=a.BookingNo),  (select creator from view_all_xo where xono=a.xono)))[Consultant],  a.IssuedDept + '/' +
            isnull((select englishname from gen_user with(readpast) where user_id=a.IssuedBy),'')[IssuedBy],  a.Printed[Print],
              a.Status  from view_ops_debitnote a with(readpast) where 1=1  and a.CreateDate>='09/01/2009' and a.CreateDate<='09/23/2009'
               and exists( select 1 from view_all_xo where xono=a.xono )  order by CreateDate,DebitNote_No 
 Go
 
 --Operation: Documents Reports : Internal Order
  select dbo.GetStatusOfXO(a.xono,a.bookingno,null ,a.postdate,a.voiddate,a.status,a.Concert_No,a.Concert_Date)[IsSettle],
    isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'') + XoNo[Number],  CreateDate[Date],
      Currency,Amount,isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')+ 'B'+ BookingNo[BookingNo],
        (select englishname from bc_info where refno=a.suppliercode)[Supplier],  (select c.englishname from Booking_Master b with(readpast)
         left join gen_user c with(readpast) on b.consultant=c.user_id where BookingNo=a.BookingNo)[Consultant],  IssuedDept + '/' +
          isnull((select englishname from gen_user with(readpast) where user_id=a.creator),'')[IssuedBy],
            ((case when PaymentTerm='no credit' then 'COD' else paymentterm end) + ' / '+PaymentType)[PaymentTerm], Printed[Print],
              (case when Status=1 and Isnull(Concert_No,'')='' then 1 else 0 end)[Status]  from (select *,
              creator[IssuedBy] from Booking_TEOrder_XO with(readpast) ) a where 1=1  and CreateDate>='09/01/2009' and CreateDate<='09/23/2009'
               and exists (select bookingno from booking_master c where bookingno=a.bookingno  )  order by CreateDate,XONo
              
               Go
                
 --Operation: Documents Reports : Refund
  select (case when Status=1  then 'V' end)[IsSettle],  isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'') + 
  RefundNo[Number],  IssueDate[Date], (case ProductType when 0 then 'Package' when 1 then 'Flight' when 2 then 'Hotel' when 3 then 'Tour' when 4 
  then 'Misc' when 5 then 'Transfer' when 6 then 'Travel Insurance' end)[Type],  isnull((select orgunit from Booking_Master with(readpast) where
   BookingNo=a.BookingNo),'') + P_Booking_XONO[XoNo],  isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')
    + 'B' + BookingNo[BookingNo],  (select englishname from gen_user with(readpast) where user_id=a.F_BookingMaster_Consultant)[Consultant],
      IssuedDept + '/' + isnull((select englishname from gen_user with(readpast) where user_id=a.IssuedBy),'')[IssuedBy],Printed[Print],
        a.Status  from booking_refund a with(readpast) where 1=1  and IssueDate>='09/01/2009' and IssueDate<='09/23/2009' 
        and exists (select bookingno from booking_master c where bookingno=a.bookingno  )  order by IssueDate,RefundNo
         Go

 --Operation: Documents Reports : Hotel Voucher
  select (case when Status=1  then 'V' end)[IsSettle],  isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'') +
   VoucherNo[Number],  IssuedDate[Date], isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')+'B'+a.BookingNo[BookingNo],
     (select HotelName from Booking_Print_Hotel with(readpast)  where BookingNo=a.BookingNo and Code=b.DocumentCode)[HotelName], 
      (select c.englishname from Booking_Master b  with(readpast)  left join gen_user c with(readpast) on b.consultant=c.user_id where BookingNo=a.BookingNo)[Consultant],
        IssuedDept + '\' + IsNull((select englishname from gen_user with(readpast) where user_id=a.IssuedBy),'')[IssuedBy],  Printed[Print],
          a.Status  from Booking_Voucher a with(readpast) left join Booking_Voucher_Detail b with(readpast) on a.VoucherNo=b.P_BookingVoucher_No  
          where b.ProductType in (2,0)  and IssuedDate>='09/01/2009' and IssuedDate<='09/23/2009' and exists (select bookingno from booking_master c where bookingno=a.bookingno  )
            order by IssuedDate,VoucherNo 
            
            Go
 
 --Operation: Documents Reports : Internal Refund
  select (case when Status=1  then 'V' end)[IsSettle],isnull(p_bookingmaster_orgunit,'')+a.DebitNote_No[Number],  a.CreateDate[Date],
    a.Currrency[Currency],a.Amount,  isnull((select orgunit from Booking_Master with(readpast) where BookingNo=a.BookingNo),'')+a.p_cancelio_no[XoNo],
      null[PaymentNo],  (select c.englishname from Booking_Master b with(readpast)  left join gen_user c with(readpast) on b.consultant=c.user_id
       where BookingNo=a.BookingNo)[Consultant],  a.IssuedDept + '/' + isnull((select englishname from gen_user with(readpast) where user_id=a.IssuedBy),'')[IssuedBy],
         a.Printed[Print],  a.Status  from Booking_TEOrder_DebitNote a with(readpast) where 1=1  and a.CreateDate>='09/01/2009' and a.CreateDate<='09/23/2009'
          and exists (select bookingno from booking_master c where bookingno=a.bookingno  )  order by CreateDate,DebitNote_No 
 
 Go
 
 
      
      