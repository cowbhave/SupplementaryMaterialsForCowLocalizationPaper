function [DateTimeStartRef,DateTimeEndRef]=ReadReferenceMilkingData(FileName,CowNo,CurDateTime)
T=readtable(FileName,'Delimiter',';','ReadRowNames',false);
CowNoRef=table2array(T(:,1));
R=table2array(T(:,5));
DateTimeStartRef=datetime(R,'InputFormat','dd.MM.yyyy HH.mm.ss');
R=table2array(T(:,6));
DateTimeEndRef=datetime(R,'InputFormat','dd.MM.yyyy HH.mm.ss');

q=(CowNo==CowNoRef) & (CurDateTime<DateTimeStartRef) & (DateTimeEndRef<CurDateTime+days(1));
DateTimeStartRef=DateTimeStartRef(q);
DateTimeEndRef=DateTimeEndRef(q);
