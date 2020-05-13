function [Tstamp,StationNo,TagNo,RSS,MessageNo,Acc]=ReadRuuviDataCSV(FileName)%,TstampRecieved
T=readtable(FileName,'Delimiter',',','ReadRowNames',false);
StationNo=table2array(T(:,1));
TagNo=table2array(T(:,3));
RSS=table2array(T(:,4));
MessageNo=table2array(T(:,5));
R=table2array(T(:,2));
R=strrep(R,'T',' ');
Tstamp=datetime(R,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
AccInPacket=5;
Acc=table2array(T(:,5+(1:(3*AccInPacket))));

% if m>21
%     y=table2array(T(:,5+3*AccInPacket+1));
%     M=table2array(T(:,5+3*AccInPacket+2));
%     D=table2array(T(:,5+3*AccInPacket+3));
%     h=table2array(T(:,5+3*AccInPacket+4));
%     m=table2array(T(:,5+3*AccInPacket+5));
%     s=table2array(T(:,5+3*AccInPacket+6));
%     ms=table2array(T(:,5+3*AccInPacket+7));
%     TstampRecieved=datetime(y,M,D,h,m,s,ms);
% else
%     TstampRecieved=[];
% end
