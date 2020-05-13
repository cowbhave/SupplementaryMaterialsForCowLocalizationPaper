function [TstampAcc, Acc1, Acc2, Acc3]=ReadAccData(FileName)
if ~isfile(FileName)
    TstampAcc=[]; Acc1=[]; Acc2=[]; Acc3=[];
    disp(['No file ' FileName]);
    return;
end
T=readtable(FileName,'Delimiter',',','ReadRowNames',false);
R=table2array(T(:,1));
R=strrep(R,'T',' ');
TstampAcc=datetime(R,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
Acc1=table2array(T(:,2));
Acc2=table2array(T(:,3));
Acc3=table2array(T(:,4));