DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
CurDate='2019-11-09';
TagVideoShift=seconds(-2);%'2019-11-09', tag 1
TagNo=3;
CollarTag=1;
StartDateTime=[CurDate ' 0:15:00'];
EndDateTime=[CurDate ' 23:45:00'];
% StartDateTime=[CurDate ' 6:30:00'];
% EndDateTime=[CurDate ' 7:00:00'];
FileName=[DataFolder '\RSSData_Tag' num2str(TagNo) '_' CurDate '.csv'];
[TstampRSS, RSS]=ReadRSSData(FileName);%,DataFolderTagNo, MessageNo1, StationNoN1
TstampRSS=TstampRSS+TagVideoShift;
q=datetime(StartDateTime,'Format','yyyy-MM-dd HH:mm:ss')<TstampRSS & TstampRSS<datetime(EndDateTime,'Format','yyyy-MM-dd HH:mm:ss');
TstampRSS=TstampRSS(q); RSS=RSS(q,:);
[n,StationN]=size(RSS);

figure; hold on;
r=[5];
plot(TstampRSS,RSS(:,r),'.');

w=ceil(300/0.2);
RSS_f1=zeros(size(RSS));
for i=1:StationN
    RSS_=MovingAverage0(RSS(:,i),w,0);
    RSS_f1(:,i)=RSS_;
end
plot(TstampRSS,RSS_f1(:,r),'g-','LineWidth',2);
% plot(TstampRSS,RSS_f1(:,r),'g*');

RSS_f2=zeros(size(RSS));
for i=1:StationN
    RSS_=KalmanFilter1D(RSS(:,i),TstampRSS,1e-9);
    RSS_f2(:,i)=RSS_;
end
plot(TstampRSS,RSS_f2(:,r),'m-','LineWidth',2);
% plot(TstampRSS,RSS_f2(:,r),'ms');

w=ceil(300/0.2);
RSS_f3=zeros(size(RSS));
for i=1:StationN
    RSS_=MedianFilter(RSS(:,i),w);
    RSS_f3(:,i)=RSS_;
end
plot(TstampRSS,RSS_f3(:,r),'k-','LineWidth',2);
% plot(TstampRSS,RSS_f3(:,r),'k^');
xlim([datetime(2019,11,9,6,40,00) datetime(2019,11,9,7,00,00)])
ylim([-80 -40])
xlabel('Time'); ylabel('RSS');
set(gcf,'Position',[500 200 320 300]);

figure; hold on;
disp('Without filter');
[RSS_f0,TstampRSS0]=DecreaseSignalFrequency(RSS,TstampRSS,ceil(5/0.2));
[MappingPointsInd_f0,TstampRSS0]=RSSLocation_XYMap(RSS_f0,TstampRSS0,DataFolder);
ComparisonWithLocationReference(MappingPointsInd_f0,TstampRSS0,TagNo,CurDate,DataFolder,1);
% plot(TstampRSS,MappingPointsInd,'b.');

disp('Average filter');
[RSS_f1,TstampRSS1]=DecreaseSignalFrequency(RSS_f1,TstampRSS,ceil(5/0.2));
[MappingPointsInd_f1,TstampRSS1]=RSSLocation_XYMap(RSS_f1,TstampRSS1,DataFolder);
plot(TstampRSS1,MappingPointsInd_f1,'g*');
ComparisonWithLocationReference(MappingPointsInd_f1,TstampRSS1,TagNo,CurDate,DataFolder,0);

disp('Kalman filter');
[RSS_f2,TstampRSS2]=DecreaseSignalFrequency(RSS_f2,TstampRSS,ceil(5/0.2));
[MappingPointsInd_f2,TstampRSS3]=RSSLocation_XYMap(RSS_f2,TstampRSS3,DataFolder);
plot(TstampRSS2,MappingPointsInd_f2,'ms');
ComparisonWithLocationReference(MappingPointsInd_f2,TstampRSS2,TagNo,CurDate,DataFolder,0);

disp('Median filter');
[RSS_f3,TstampRSS3]=DecreaseSignalFrequency(RSS_f3,TstampRSS,ceil(5/0.2));
[MappingPointsInd_f3,TstampRSS3]=RSSLocation_XYMap(RSS_f3,TstampRSS3,DataFolder);
plot(TstampRSS3,MappingPointsInd_f3,'k^');
ComparisonWithLocationReference(MappingPointsInd_f3,TstampRSS3,TagNo,CurDate,DataFolder,0);

% Markers = {'+';'o';'*';'x';'v';'d';'^';'s';'>';'<'};
% r=[1 2 3 4 5 6 7 8 9 10];
% figure; hold on; s1={}; for i=1:length(r), plot(TstampRSS,RSS(:,r(i)),'.','Marker',Markers{i}); s1{i}=num2str(r(i)); end; legend(s1);
% figure; plot(TstampRSS,RSS,'.'); hold on; legend('1','2','3','4','5','6','7','8','9','10');
