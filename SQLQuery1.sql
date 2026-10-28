--טבלת אחיות
create table Nurses
(
NursesCode int identity  (1,1) primary key,
N_id nvarchar(20) not null,
lname nvarchar (20) not null,
fname nvarchar (20) not null,
EntranceHour nvarchar (5),
ExitHour nvarchar (5),
NumRoom int 
)

--טבלת חדרים
Create table Rooms
(
NumRoom int identity (1,1) primary key,
NumBed int not null,
FloorRoom int not null,
NursesCode int,
vip bit,
CostRoom float

constraint fk_NursesRoom foreign key(NursesCode)
References Nurses (NursesCode)
)


--טבלת השכרת ציוד רפואי
Create table Equipment
(
PCode int primary key,
PName nvarchar (20),
PDate date,
PPrice int,
CountAvailabil int
)

--טבלת פעילויות
Create table Activities
(
CodeAct int identity (100,3) primary key,
typeA nvarchar(20),
DayA nvarchar (20),
CountP int,
HourAct nvarchar (5),
DurationOfActivity int
)

--טבלת מטופלים
Create table Patients
(
 P_Id nvarchar(20) primary key,
 Fname nvarchar (20),
 Lname nvarchar (20),
 Birthdate date,
 P_Address nvarchar(20),
 P_Phone nvarchar(10),
 ActCode int,
 PayMent float,
 ProductCode int,
 NumRoom int
 
 constraint fk_patientActivities foreign key(ActCode)
 References Activities (CodeAct),

 constraint fk_patientEquipment foreign key(ProductCode)
 References Equipment (PCode),

 constraint fk_patientNumRoom foreign key(NumRoom)
 References Rooms(NumRoom)
)


insert  into Nurses(N_id,Lname,Fname,EntranceHour,ExitHour,NumRoom)
values('021222324','שלמה','לוי','07:55','13:00',1),
	  ('021222424','דוד','לוי','07:50','13:00',1),
      ('336598511','יעל','אלקיים','08:00','14:30',3),
      ('032456859','עדן','אזולאי','14:25','19:00',6),
      ('025897465','חדוה','כהן','13:00','18:30',2),
      ('222658947','שמעון','אהרון','12:26','18:54',5)


insert  into Rooms (NumBed,floorRoom,NursesCode,Vip,CostRoom)
values(3,6,5,0,18300),
      (4,3,2,0,17000),
      (3,5,6,0,18300),
      (2,2,3,0,18500),
      (1,8,1,1,22000),
      (3,1,4,0,19000)                                                                                        
	  
	 
insert  into Equipment(PCode,PName,PDate,PPrice,CountAvailabil)
values(454,'הליכון','05/08/2020',500,6),				   
      (136,'מקל הליכה','03/03/2019',300,20),			  
      (436,'כסא גלגלים','01/09/2023',2500,4)


insert into Activities(typeA,DayA,CountP,HourAct)
values('יוגה','רביעי',18,'18:00'),
	  ('סריגה','שלישי',33,'10:45'),
	  ('ציור','חמישי',21,'11:30'),
	  ('מוזיקה','ראשון',25,'14:00'),
	  ('גינון','שני',34,'17:00')


insert  into Patients (P_Id,Fname,Lname,Birthdate,P_Address,P_Phone,ActCode,PayMent,ProductCode,NumRoom)
values('031542658','דוד','שם טוב','1941/04/22','ירושלים','0564214526',112,18500,436,1),
	  ('332656988','גילה','אמסאלם','1922/10/16','בית שמש','0536421987',109,19000,436,3), 
      ('012355555','אברהם','יצחק','1936/12/13','מודיעין','0545547852',103,16000,454,5),
	  ('065485646','שושנה','שושני','1948/05/19','חולון','0547966635',100,15000,436,2),
	  ('365254588','רוחמה','לוי','1940/07/04','ירושלים','0589754865',100,14000,136,6),
      ('468555849','שמעון','שמעוני','1923/06/06','מודיעין','0555245879',106,14000,454,4)

	  

--אילוצים
Alter table Nurses Add constraint NursesID unique (N_id)-- עמודה יחודית
Alter table Patients Add constraint PatientsID unique (P_Id)-- עמודה יחודית
Alter table Patients Add constraint AgePatients check (year(Birthdate)<=year(getDate())-60)--בודק את תקינות גיל המטופל
Alter table Patients Add constraint PhoneLength check (len(P_Phone)=10)--בודק שבמספר טלפון יש 10 מספרים
Alter table Activities Add constraint DurationOfActivity default 60 for DurationOfActivity--משך הפעילות תיהיה ברירת מחדל שעה
Alter table Rooms Add constraint CostRooms check(CostRoom between 14000 and 25000)--תווך מחיר החדרים
Alter table Rooms Alter column NursesCode int not null 


select Fname+' '+Lname,P_Id,PPrice+CostRoom as price from Patients P inner join Rooms R on P.NumRoom=R.NumRoom inner join Equipment E on P.ProductCode= E.PCode 

--שאילתות
--1. מציג אנשים שהשכירו כסא גלגלים
select P_Id,Fname,Lname 
from Patients p inner join Equipment E on p.ProductCode =E.PCode 
where p.ProductCode=436

--2. מציג את סוג הפעילות ואת מספר המטופלים הרשומים אליה
select count(Lname),typeA 
from Activities A inner join Patients P on A.CodeAct=P.ActCode 
group by typeA

--3. מציג מי הקשיש ביותר ובאיזו פעילות הוא משתתף
select Fname,Lname,typeA
from Patients P inner join Activities A on A.CodeAct=P.ActCode
where P.Birthdate=(select min(Birthdate)from Patients)
order by Birthdate asc

--מטופלים הנמצאים בחדרים שבהם אחות מסוימת עובדת .4
select P.Fname,P.Lname, P.NumRoom
from Patients P      
where P.NumRoom in
  (select R.NumRoom 
     from Nurses N inner join Rooms R 
     on N.NursesCode=R.NursesCode 
     where N.NursesCode=5)


--5. טבלה מדומה
create view PatientsView(PatientName,NumRoom,NameAct)
as
select P.Fname+' '+P.Lname,P.NumRoom,A.typeA
from Patients P left join Activities A on P.ActCode=A.CodeAct

select* from PatientsView

select* from Patients
select* from Nurses
select* from Rooms
select* from Equipment 
select* from Activities



--פונקציה שמחשבת את גיל המטופל לפי תאריך הלידה
create function PatientAge (@BirthDate date)
returns int
as 
begin  
declare @Age int
set @Age = datediff (year, @BirthDate, getdate())
if(
(month(@BirthDate)>month(getdate())) 
or (month(@BirthDate) = month(getdate()) 
and day(@BirthDate) > day(getdate()))
)
set @Age = @Age-1
return @Age
end

--שאילתה שמשתמשת בפונקציה
select Fname,Lname,PatientAge(BirthDate) as p_Age
from Patients 
order by Fname,Lname


--פרוצדורות
--1. אפשרות להכנסת מטופל חדש
create procedure NewPatient
@P_Id nvarchar(20),
@Fname nvarchar(20),
@Lname nvarchar(20),
@Birthdate date,
@P_Address nvarchar(20),
@P_Phone nvarchar(10),
@ActCode int,
@PayMent float,
@ProductCode int,
@NumRoom int
as
begin
insert into Patients (P_Id,Fname,Lname,Birthdate,P_Address,P_Phone,ActCode,PayMent,ProductCode,NumRoom)
       values(@P_Id,@Fname,@Lname,@Birthdate,@P_Address,@P_Phone,@ActCode,@PayMent,@ProductCode,@NumRoom)
end

--הכנסת מטופל חדש
exec NewPatient
@P_Id = '369256418',
@Fname = 'מנחם',
@Lname = 'אברהמי',
@Birthdate = '1965-02-18',
@P_Address ='באר שבע',
@P_Phone = '0524879689',
@ActCode = 106, 
@PayMent = 16700,
@ProductCode = 136, 
@NumRoom = 3     



--2. העברת מטופל לחדר חדש ועדכון התשלום
create procedure MoveRoom
@p_Id nvarchar(20), @NewNumRoom int
as
begin
set nocount on
 declare @CurrentRoomCost float
 declare @NewRoomCost float
 declare @CurrentPayment float
 declare @NewPayment float
begin transaction
begin try

select @CurrentRoomCost = R.CostRoom, @CurrentPayment = P.PayMent
        from Patients P inner join Rooms R 
		on P.NumRoom = R.NumRoom
        where P.P_Id = @p_Id

select @NewRoomCost = CostRoom
       from Rooms
       where NumRoom = @NewNumRoom

if @CurrentRoomCost is null or @NewRoomCost is null
 begin
  raiserror('החדר לא נמצא או שמחיר החדר לא תקין.', 16, 1)
  rollback transaction
  return     
 end
set @NewPayment = @NewRoomCost
update Patients
set       
NumRoom = @NewNumRoom,
PayMent = @NewPayment
where 
P_Id = @p_Id
commit transaction
print 'העברת המטופל והעדכון בוצעו בהצלחה!'
end try
begin catch 
if @@trancount > 0
begin
rollback transaction
end
raiserror('אירעה שגיאה בלתי צפויה במהלך עדכון נתוני המטופל. אנא בדוק את הפרטים או פנה למנהל.', 16, 1)
end catch
end

--3. השכרת ציוד רפואי למטופל
create procedure Assign
@P_Id nvarchar(20),
@ProductCode int
as
begin
set nocount on 
declare @EquipmentAvailableCount int
declare @CurrentPatientEquipmentCode int
begin transaction 
begin try
--בודק שהמטופל קיים
if not exists(select 1 from Patients where P_Id = @P_Id)
begin
raiserror('המטופל עם תעודת זהות %s אינו קיים במערכת.', 16, 1, @P_Id)
rollback transaction
return
end
--בודק שהמוצר קיים
if not exists(select 1 from Equipment where PCode=@ProductCode)
begin
raiserror(' הציוד עם קוד %d לא קיים במערכת',16,1,@ProductCode)
rollback transaction
return
end
--בודק שהמוצר קיים במלאי
if(select CountAvailabil 
from Equipment 
where PCode=@ProductCode)<=0
begin
raiserror('הציוד המבוקש לא נמצא במלאי כעת',16,1)
rollback transaction
return
end
update Patients
set ProductCode=@ProductCode
where P_Id=@P_Id
update Equipment
set CountAvailabil=CountAvailabil-1
where PCode=@ProductCode

print 'הפעולה בוצעה בהצלחה'
commit transaction
end try
begin catch
if @@trancount>0
begin
rollback transaction
end 
end catch
end


--4. עדכון מחיר ציוד רפואי
create procedure UpdateEquipmentPrice 
@PCode int,
@NewPrice int
as
begin
set nocount on 
begin transaction 
begin try
--בודק האם המוצר קיים 
if not exists(select 1 from Equipment where PCode=@PCode)
begin
raiserror(' הציוד עם קוד %d לא קיים במערכת',16,1,@PCode)
rollback transaction
return
end
-- בודק שהמחיר חיובי
if @NewPrice<=0
begin
raiserror('המחיר חייב ליהיות חיובי',16,1)
rollback transaction
return
end

update Equipment
set PPrice=@NewPrice
where PCode=@PCode
commit transaction
print 'המחיר עודכן בהצלחה'
end try
begin catch
if @@trancount>0
begin
rollback transaction
end 
end catch
end

--5.עדכון פרטים של מטופל
create procedure UpdatePatient
@P_Id nvarchar(20),
@NewPhone nvarchar(20)=null,
@NewAddress nvarchar(20)=null
as
begin
set nocount on 
begin transaction 
begin try
--בודק שהמטופל קיים
if not exists(select 1 from Patients where P_Id = @P_Id)
begin
raiserror('לא קיים במערכת מטופל %s',16,1,@P_Id)
rollback transaction
return
end
update Patients
set 
P_Phone = isnull(@NewPhone,P_Phone),
P_Address = isnull(@NewAddress,P_Address)
where P_Id = @P_Id
commit transaction
print 'הפרטים עודכנו בהצלחה'
end try
begin catch
if @@trancount>0
begin
rollback transaction
end
raiserror('אירעה שגיאה נסה שוב',16,1)
end catch
end
		
--טריגר
--מעדכן אוטומטית את כמות המטופלים בפעילות כאשר מטופל משנה פעילות או מצטרף
create trigger UpdateActivityCount
on Patients
after insert
as
begin
set nocount on 
if exists(select 1 from inserted where ActCode is not null)
begin
update Activities
set CountP = A.CountP + I.NumPatientsAdded
from Activities A inner join (select ActCode, count(P_Id) as NumPatientsAdded from inserted where ActCode is not null
group by ActCode)
as I on A.CodeAct = I.ActCode
end
end

select * from Activities where CodeAct=@@IDENTITY
select @@error
