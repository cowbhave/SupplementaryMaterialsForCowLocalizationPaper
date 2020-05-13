%Calculate tag location for a single tag for a single day and compare it with reference
%INPUT: 
% File with name RSSData_Tag*_2020-02-12.csv
%contaning RSS from all stations for the tag Tag during a day
%OUTPUT: 
% Graph with comparison and cumulative accuracy

DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
% DataFolder='D:\CowBhaveData\Data_Exp30_01_2020';
% DrawBarnMap(DataFolder);
% CurDate='2019-11-09';
CurDate='2019-12-04';
% CurDate='2020-01-30';
TagVideoShift=seconds(3);%'2019-12-04', tag 17,6
% TagVideoShift=seconds(-2);%'2019-11-09', tag 1
% FeedersVideoShift=seconds(-39);%'2019-12-05'
TagNo=15;
CollarTag=1;
% StartDateTime=[CurDate ' 6:45:00'];
% EndDateTime=[CurDate ' 7:00:00'];
StartDateTime=[CurDate ' 0:01:00'];
EndDateTime=[CurDate ' 23:59:00'];

FileName=[DataFolder '\RSSData_Tag' num2str(TagNo) '_' CurDate '.csv'];
[TstampRSS1, RSS1]=ReadRSSData(FileName);%,DataFolderTagNo, MessageNo1, StationNoN1
TstampRSS=TstampRSS1; RSS=RSS1;% MessageNo=MessageNo1;
TstampRSS=TstampRSS+TagVideoShift;
q=datetime(StartDateTime,'Format','yyyy-MM-dd HH:mm:ss')<TstampRSS & TstampRSS<datetime(EndDateTime,'Format','yyyy-MM-dd HH:mm:ss');
TstampRSS=TstampRSS(q); RSS=RSS(q,:);

% FileName=[DataFolder '\AccData_Tag' num2str(TagNo) '_' CurDate '.csv'];
% [TstampAcc1, Acc11, Acc21, Acc31]=ReadAccData(FileName);
% TstampAcc=TstampAcc1; Acc1=Acc11; Acc2=Acc21; Acc3=Acc31;
% TstampAcc=TstampAcc+TagVideoShift;
% q=datetime(StartDateTime,'Format','yyyy-MM-dd HH:mm:ss')<TstampAcc & TstampAcc<datetime(EndDateTime,'Format','yyyy-MM-dd HH:mm:ss');
% TstampAcc=TstampAcc(q); Acc1=Acc1(q); Acc2=Acc2(q); Acc3=Acc3(q);
% windowSize=10;
% [Acc1,STD]=STDFilterWindow(Acc1,windowSize,3,-1200,1200);
% [Acc2,STD]=STDFilterWindow(Acc2,windowSize,3,-1200,1200);
% [Acc3,STD]=STDFilterWindow(Acc3,windowSize,3,-1200,1200);
% plot(TstampAcc,[Acc1 Acc2 Acc3],'.'); legend('x','y','z')
% Acc1_rss=zeros(length(TstampRSS),1); Acc2_rss=Acc1_rss; Acc3_rss=Acc1_rss;
% j=3;
% for i=1:length(TstampRSS)
%     while TstampRSS(i)>TstampAcc(j) && j<length(TstampAcc)-3
%         j=j+1;
%     end
%     Acc1_rss(i)=mean(Acc1(j+[-2:2]));
%     Acc2_rss(i)=mean(Acc2(j+[-2:2]));
%     Acc3_rss(i)=mean(Acc3(j+[-2:2]));
% end

% Markers = {'+';'o';'*';'x';'v';'d';'^';'s';'>';'<'};
% r=[1 2 3 4 5 6 7 8 9 10];
% figure; hold on; s1={}; for i=1:length(r), plot(TstampRSS,RSS(:,r(i)),'.','Marker',Markers{i}); s1{i}=num2str(r(i)); end; legend(s1);
% figure; plot(TstampRSS,RSS,'.'); hold on; legend('1','2','3','4','5','6','7','8','9','10');
% figure; plot(TstampRSS,RSS(:,[2 4 5 6 8 9]),'.'); legend('2','4','5','6','8','9');
% figure; plot(TstampRSS,RSS(:,[2 3 5 6 9 10]),'.'); legend('2','3','5','6','9','10');
% figure; plot(TstampRSS,RSS(:,[2 3 5 6 8 9]),'.'); legend('2','3','5','6','8','9');
% xlim([datetime(2019,12,5,8,55,0) datetime(2019,12,5,8,56,0)])
% ylim([-80 -50]);
[n,StationNoN]=size(RSS);
w=ceil(10/0.2);
for i=1:StationNoN
    RSS(:,i)=MovingAverage0(RSS(:,i),w,0);
%     RSS(:,i)=KalmanFilter1D(RSS(:,i),TstampRSS,0.0001);
%     RSS(:,i)=MedianFilter0(RSS(:,i),w,0);
end

[RSS,TstampRSS]=DecreaseSignalFrequency(RSS,TstampRSS,ceil(5/0.2));

% plot(TstampRSS,RSS(:,1),'.');
% CreateLocationOrientationMapRef(DataFolder);
% CreatePassageProbabilityMatrix(DataFolder);
% [MappingPointsInd]=RSSLocation_NearestStation(RSS,TstampRSS,DataFolder);
[MappingPointsInd]=RSSLocation_XYMap(RSS,TstampRSS,DataFolder);
ComparisonWithLocationReference(MappingPointsInd,TstampRSS,TagNo,CurDate,DataFolder,1);

