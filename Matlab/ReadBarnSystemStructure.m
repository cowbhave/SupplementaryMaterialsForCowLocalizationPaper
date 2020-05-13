function [StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo,ConstructionsXY]=ReadBarnSystemStructure(DataFolder)
T=readtable([DataFolder '\BarnSystemStructure.csv'],'Delimiter',';','ReadVariableNames',false);
q1=find(string(table2array(T(:,1)))=="Feeding_Stations",1);
q2=find(string(table2array(T(:,1)))=="Water_Stations",1);
q3=find(string(table2array(T(:,1)))=="Milking_Robot",1);
q4=find(string(table2array(T(:,1)))=="Location_Points",1);
FeedingStationNo=str2double(table2array(T(q1+1:(q2-1),4)));
PointsNo=str2double(table2array(T(q1+1:(q2-1),1)));
FeedingStationPointsNo(FeedingStationNo)=PointsNo;
WaterStationNo=str2double(table2array(T(q2+1:(q3-1),4)));
PointsNo=str2double(table2array(T(q2+1:(q3-1),1)));
WaterStationPointsNo(WaterStationNo)=PointsNo;
MappingPointsX=str2double(table2array(T(q4+1:end,2)));
MappingPointsY=str2double(table2array(T(q4+1:end,3)));
% MappingPointsN=length(MappingPointsX);
q5=find(string(table2array(T(:,1)))=="PI_Stations",1);
q6=find(string(table2array(T(:,1)))=="Constructions",1);
StationX=str2double(table2array(T(q5+1:(q6-1),2)));
StationY=str2double(table2array(T(q5+1:(q6-1),3)));
StationZ=str2double(table2array(T(q5+1:(q6-1),4)));
StationNo=str2double(table2array(T(q5+1:(q6-1),1)));
% StationT=str2double(table2array(T(q5+1:(q6-1),5)));
% StationF=str2double(table2array(T(q5+1:(q6-1),6)));

ConstructionsXY=str2double(table2array(T(q6+1:(q1-1),1:4)));

