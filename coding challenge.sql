--Create databse and tables 

create database crime_management

create table crime (
    crimeid int primary key identity(1,1),
    incidenttype varchar(255) not null,
    incidentdate datetime not null,
    clocation varchar(255) not null,
    cdescription text not null,
    cstatus varchar(20) not null
);

create table victim (
    victimid int primary key identity(1,1),
    crimeid int not null,
    vname varchar(255) not null,
    contactinfo varchar(255),
    injuries varchar(255),
    foreign key (crimeid) references crime(crimeid)
);

create table suspect (
    suspectid int primary key identity(1,1),
    crimeid int not null,
    sname varchar(255) not null,
    sdescription text,
    criminalhistory text,
    foreign key (crimeid) references crime(crimeid)
);

-- Insert sample data

insert into crime (incidenttype, incidentdate, clocation, cdescription, cstatus) 
values ('robbery', '2023-09-15', '123 main st, cityville', 'armed robbery at a convenience store', 'open'); 
insert into crime (incidenttype, incidentdate, clocation, cdescription, cstatus) 
values ('homicide', '2023-09-20', '456 elm st, townsville', 'investigation into a murder case', 'under investigation');
insert into crime (incidenttype, incidentdate, clocation, cdescription, cstatus) 
values ('theft', '2023-09-10', '789 oak st, villagetown', 'shoplifting incident at a mall', 'closed');
insert into crime (incidenttype, incidentdate, clocation, cdescription, cstatus) 
values ('assault', '2024-08-16', '3 main st, villagetown', 'armed robbery at a store', 'open');
insert into crime (incidenttype, incidentdate, clocation, cdescription, cstatus) 
values ('robbery', '2023-05-17', '43,abc', 'at a house', 'open');


insert into victim (crimeid, vname, contactinfo, injuries) 
values (1, 'john doe', 'johndoe@example.com', 'minor injuries'); 
insert into victim (crimeid, vname, contactinfo, injuries) 
values(2, 'jane smith', 'janesmith@example.com', 'deceased');
 insert into victim (crimeid, vname, contactinfo, injuries) 
values(3, 'alice johnson', 'alicejohnson@example.com', 'none');
 insert into victim (crimeid, vname, contactinfo, injuries) 
values(3, 'suspect 1', 'abc@example.com', 'none');


insert into suspect (crimeid, sname, sdescription, criminalhistory) 
values (1, 'robber 1', 'armed and masked robber', 'previous robbery convictions');
insert into suspect (crimeid, sname, sdescription, criminalhistory) 
values  (2, 'unknown', 'investigation ongoing', null); 
insert into suspect (crimeid, sname, sdescription, criminalhistory) 
values (3, 'suspect 1', 'shoplifting suspect', 'prior shoplifting arrests');
insert into suspect (crimeid, sname, sdescription, criminalhistory) 
values (2, 'robber 1', 'ongoing', null);

select * from crime;
select * from victim;
select * from suspect;

--) 1. Select all open incidents.

select * from crime where cstatus = 'open';

-- 2. Find the total number of incidents

select count(*) as total_incidents from crime;

--3. List all unique incident types

select distinct incidenttype from crime;

-- 4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'
select * from crime 
where incidentdate between '2023-09-01' and '2023-09-10';

--5. List persons involved in incidents in descending order of age. 

alter table victim
add  age int;
alter table suspect
add  sage int;

update victim
set age = 30
where victimid = 1;

update victim
set age = 40
where victimid = 2;

update victim
set age = 25
where victimid = 3;

update suspect
set sage = 22
where suspectid = 1;

update suspect
set sage = 35
where suspectid = 2;

update suspect
set sage = 27
where suspectid = 3;

select vName as [name], Age from Victim 
union
select sName, sAge from Suspect order by age desc 

--6. Find the average age of persons involved in incidents.

select avg(age) as average_age
from (select age from victim union all select sage from suspect
) as all_age

--7. List incident types and their counts, only for open cases. 

select incidenttype, count(*) as incident_count,cstatus
from crime
where cstatus = 'open'
group by incidenttype,cstatus

--8. Find persons with names containing 'Doe'. 

select vname from victim where vname like '%doe%' union select sname from suspect where sname like '%doe%';

--9. Retrieve the names of persons involved in open cases and closed cases. 
select v.vname 
from victim v 
join crime c on v.crimeid = c.crimeid
where c.cstatus in ('open', 'closed')

union 

select s.sname 
from suspect s
join crime c on s.crimeid = c.crimeid
where c.cstatus in ('open', 'closed');

--10. List incident types where there are persons aged 30 or 35 involved.

select incidenttype 
from crime 
where crimeid in (
    select crimeid 
    from victim 
    where age in (30, 35) union
    select crimeid 
    from suspect 
    where sage in (30, 35)
);

--11. Find persons involved in incidents of the same type as 'Robbery'. 
select v.name, c.incident_Type
from victim v
join crime c on v.crimeid = c.crimeid
where c.incident_Type = 'Robbery'
union
select s.name, c.incident_Type
from suspect s
join crime c on s.crimeid = c.crimeid
where c.incident_Type = 'Robbery';

--12. List incident types with more than one open case. 

select incidenttype 
from crime 
where cstatus = 'open' 
group by incidenttype 
having count(*) > 1;

--13. List all incidents with suspects whose names also appear as victims in other incidents.

select c.IncidentDate, c.IncidentType, c.cLocation, c.cDescription, c.cStatus,s.sname
from Crime c
JOIN Suspect s on s.CrimeID = c.CrimeID
JOIN Victim v on v.vName = s.sName;

--14.  Retrieve all incidents along with victim and suspect details. 

select *from crime c
left join victim v on c.crimeid = v.crimeid
left join suspect s on c.crimeid = s.crimeid;

--15. Find incidents where the suspect is older than any victim.

select c.IncidentDate, c.IncidentType, c.cLocation, c.cDescription, c.cStatus
from Crime c
join Suspect s on c.CrimeID = s.CrimeID
join Victim v on c.CrimeID = v.CrimeID
where s.sAge > v.Age;

--16. Find suspects involved in multiple incidents: 
select sname 
from suspect 
group by sname 
having count(crimeid) > 1;

--17. List incidents with no suspects involved. 
select * from crime 
where crimeid not in (select  crimeid from suspect);

--18. List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'. 

select * from crime 
where incidenttype = 'homicide' 
or crimeid in (
    select crimeid from crime where incidenttype = 'robbery'
    and crimeid not in (select crimeid from crime where incidenttype != 'robbery'));

--19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none. 

select c.crimeid, c.incidenttype, isnull(s.sname, 'No Suspect') as suspect
from crime c
left join suspect s on c.crimeid = s.crimeid;

--20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault' 

select s.sname , c.incidenttype
from suspect s
join crime c on s.crimeid = c.crimeid 
where c.incidenttype in ('robbery', 'assault');
