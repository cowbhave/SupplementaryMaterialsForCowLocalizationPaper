function [DateTimeStartRef, DateTimeEndRef, StartPointRef, EndPointRef, BodyPositionStringRef]=ReadReferenceBodyPositionData(FileName,CowNo)
T=readtable(FileName,'Delimiter',';','ReadRowNames',false);
R=table2array(T(:,2));
R=strrep(R,'T',' ');
DateTimeStartRef=datetime(R,'InputFormat','yyyy-MM-dd HH:mm:ss');
R=table2array(T(:,3));
R=strrep(R,'T',' ');
DateTimeEndRef=datetime(R,'InputFormat','yyyy-MM-dd HH:mm:ss');
CowNoRef=table2array(T(:,1));
BodyPositionStringRef=table2array(T(:,4));
StartPointRef=table2array(T(:,5));
EndPointRef=table2array(T(:,6));

if CowNo~=0
    q=CowNoRef==CowNo;
    DateTimeStartRef=DateTimeStartRef(q);
    DateTimeEndRef=DateTimeEndRef(q);
    StartPointRef=StartPointRef(q);
    EndPointRef=EndPointRef(q);
    BodyPositionStringRef=BodyPositionStringRef(q);
end
