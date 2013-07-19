update Gen_Rooms set OldRoomInfo=[UAT].[dbo].[gen_hot_room].RoomName,
                     RefNo_ForRoom=[UAT].[dbo].[gen_hot_room].RefNo_ForRoom,
                     BedSize=[UAT].[dbo].[gen_hot_room].BedSize 
from Gen_Rooms inner join [UAT].[dbo].[gen_hot_room] on RoomID COLLATE SQL_Latin1_General_CP1_CI_AS=convert(nvarchar(18) ,[UAT].[dbo].[gen_hot_room].Id )   