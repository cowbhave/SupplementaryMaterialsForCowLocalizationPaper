DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
CurDate='2019-11-09';
TagVideoShift=seconds(-2);%'2019-11-09', tag 1
TagNo=3;
CollarTag=1;
StationNo=5;
Fr=5;%Hz, RSS sampling frequency

FileName=[DataFolder '\RSSData_Tag' num2str(TagNo) '_' CurDate '.csv'];
[TstampRSS, RSS]=ReadRSSData(FileName);%,DataFolderTagNo, MessageNo1, StationNoN1
TstampRSS=TstampRSS+TagVideoShift;

StartDateTime=datetime(2019,11,09,6,40,00);
EndDateTime=[datetime(2019,11,09,6,42,00) datetime(2019,11,09,6,45,00) datetime(2019,11,09,6,50,00) datetime(2019,11,09,7,00,00)];
WS=[2 10 60 300];
QQ=[10^-3 10^-5 10^-7 10^-9];
for i=1:length(WS)
    q=StartDateTime<TstampRSS & TstampRSS<EndDateTime(i);
    TstampRSS_i=TstampRSS(q); RSS_i=RSS(q,StationNo);
    figure; hold on;
    plot(TstampRSS_i,RSS_i,'.','color',[0.6 0.6 0.6]);

    w=WS(i)*Fr;
    RSS_ma=MovingAverage0(RSS_i,w,0);
    plot(TstampRSS_i,RSS_ma,'r-','LineWidth',2);
    
    RSS_mf=MedianFilter0(RSS_i,w,0);
    plot(TstampRSS_i,RSS_mf,'g-','LineWidth',2);

    RSS_kf=KalmanFilter1D(RSS_i,TstampRSS_i,QQ(i));
    plot(TstampRSS_i,RSS_kf,'b-','LineWidth',2);

    ylim([-82 -40]);
    set(gcf,'Position',[100+(i-1)*200 200 320 300]);
end
