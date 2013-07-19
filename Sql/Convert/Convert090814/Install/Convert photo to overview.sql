--update Gen_Hotels set 
--Gen_Hotels.OverView=Convert(nvarchar(max),isnull(Gen_Hotels.OverView,''))+Img.ImgPath,
--Gen_Hotels.OverViewCS=Convert(nvarchar(max),isnull(Gen_Hotels.OverViewCS,''))+Img.ImgPath,
--Gen_Hotels.OverViewCT=Convert(nvarchar(max),isnull(Gen_Hotels.OverViewCT,''))+Img.ImgPath
--from 
--(select HotelID,ImgPath=replace(replace(stuff((select ' <img alt="" src="/Web/UplodeFiles/image/'+[PhotoName]+'"><br/>' from Gen_Photo where HotelID=t.HotelID for xml path('')),1,1,''),'&lt;','<'),'&gt;','>')
--from
--  Gen_Photo t
--group by
--  HotelID)Img  
--where Img.HotelID=Gen_Hotels.HotelID






  
  
