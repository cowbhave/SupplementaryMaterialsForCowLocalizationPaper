function [DateTimeStartRef,DateTimeEndRef,StationNo]=ReadReferenceFeedingData(FileName,CowNo,CurDateTime)%
T=readtable(FileName,'Delimiter',';','ReadRowNames',false);
CowNoRef=table2array(T(:,1));
StationNo=table2array(T(:,2));
R=table2array(T(:,3));
R=strrep(R,'T',' ');
DateTimeStartRef=datetime(R,'InputFormat','yyyy-MM-dd HH:mm:ss');
R=table2array(T(:,4));
R=strrep(R,'T',' ');
DateTimeEndRef=datetime(R,'InputFormat','yyyy-MM-dd HH:mm:ss');

q=(CowNo==CowNoRef) & (CurDateTime<DateTimeStartRef) & (DateTimeEndRef<CurDateTime+days(1));
StationNo=StationNo(q);
DateTimeStartRef=DateTimeStartRef(q);
DateTimeEndRef=DateTimeEndRef(q);
