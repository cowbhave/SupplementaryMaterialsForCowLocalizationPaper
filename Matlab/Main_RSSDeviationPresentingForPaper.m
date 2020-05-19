% Illustration of RSS nois and deviation, Fig. 5, Fig. 6 a, Fig. 7

%% Static RSS deviation Fig. 5 a
DataFolder='D:\CowBhaveData\TagStationExperiments\DistOrient_22-04-2020';
FileName='RuuviData_Tag1_St1_2020-04-22.csv';
ts=datetime(2020,4,22,13,15,15):seconds(135):datetime(2020,4,22,14,10,15); ts=ts';
ts(9:end)=ts(9:end)-seconds(60);
te=datetime(2020,4,22,13,17,15):seconds(135):datetime(2020,4,22,14,12,15); te=te';
te(8:end)=te(8:end)-seconds(60);
[Tstamp,StationNo,TagNo,RSS]=ReadRuuviDataRaspPiCSV([DataFolder '\' FileName]);

figure
DD=[5 10 15 20];
j=0;
for k=DD
    q=ts(k)<=Tstamp & Tstamp<=te(k);
    RSS_q=RSS(q,1);
    Tstamp_q=Tstamp(q); Tstamp_q=Tstamp_q-Tstamp_q(1);
    j=j+1;
    subplot(2,length(DD),j); hold on;
    plot(Tstamp_q,RSS_q,'.','color',[0.6 0.6 0.6]);
    plot(Tstamp_q,RSS_q*0+mean(RSS_q),'r','LineWidth',2);
    xlabel('Time [h:m:s]'); ylabel('RSS [dB]');
    ylim([min(RSS_q)-1 max(RSS_q)+1]);

    [v,f,Grouping]=ValueFrequency(RSS_q);
    f=f/sum(f)*100;
    j=j+1;
    subplot(2,length(DD),j);
    for i=1:length(v)
        patch([0 f(i) f(i) 0],v(i)+[-0.4 -0.4 0.4 0.4],'blue');
    end
    xlabel('%'); ylabel('RSS [dB]');
    ylim([min(RSS_q)-1 max(RSS_q)+1]);
end

%% RSS from barn Fig. 5 b
DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
TagNo=7;
DateTimeStartRef=datetime(2019,11,09,07,14,00);
DateTimeEndRef=datetime(2019,11,09,07,18,00);
FileName=[DataFolder '\RSSData_Tag' num2str(TagNo) '_2019-11-09.csv'];
[Tstamp,RSS]=ReadRSSData(FileName);
q=DateTimeStartRef<Tstamp & Tstamp<DateTimeEndRef;
StationNo=8;
w=ceil(10/0.2);
RSS_F=RSS(:,StationNo);
RSS_F=MovingAverage0(RSS_F,w,0);
RSS_F=MovingAverage0(RSS_F,w,0);

RSS_q=RSS(q,StationNo); RSS_F=RSS_F(q);
Tstamp_q=Tstamp(q); Tstamp_q=Tstamp_q-Tstamp_q(1);
q=RSS_q~=0;
RSS_q=RSS_q(q); Tstamp_q=Tstamp_q(q); RSS_F=RSS_F(q);

figure; hold on;
plot(Tstamp_q,RSS_q,'.','color',[0.6 0.6 0.6]);
plot(Tstamp_q,RSS_F,'r','LineWidth',2);
xlabel('Time [h:m:s]'); ylabel('RSS [dB]');
set(gcf,'Position',[300 200 320 300]);

[v,f,Grouping]=ValueFrequency(RSS_q);
f=f/sum(f)*100;
figure;
for i=1:length(v)
    patch([0 f(i) f(i) 0],v(i)+[-0.4 -0.4 0.4 0.4],'blue');
end
xlabel('%'); ylabel('RSS [dB]');
set(gcf,'Position',[500 200 320 300]);

%% Walking in barn Fig. 7
figure; hold on;
X=3:0.1:23;
RSSMap=DistToRSSI(X);
plot(X,RSSMap,'b-.','LineWidth',2);
StationNo=7;
w=ceil(5/0.2);
[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo,ConstructionsXY]=ReadBarnSystemStructure(DataFolder);

%case 1
DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
CurDate='2019-12-04';
TagNo=15;%871
StartDateTime=[CurDate ' 14:59:18']; EndDateTime=[CurDate ' 14:59:47'];
Pstart=71; Pend=141; t=90; TagRSSDirectionNormalization=0;%left
TagVideoShift=seconds(5);%'2019-12-04', tag 17

FileName=[DataFolder '\RSSData_Tag' num2str(TagNo) '_' CurDate '.csv'];
[TstampRSS,RSS]=ReadRSSData(FileName);
TstampRSS=TstampRSS+TagVideoShift;
q=datetime(StartDateTime,'Format','yyyy-MM-dd HH:mm:ss')<TstampRSS & TstampRSS<datetime(EndDateTime,'Format','yyyy-MM-dd HH:mm:ss');
RSSraw=RSS(:,StationNo);
RSS=MovingAverage0(RSSraw,w,0);
TstampRSS=TstampRSS(q); RSS=RSS(q);  RSSraw=RSSraw(q);
RSS=RSS+TagRSSDirectionNormalization; RSSraw=RSSraw+TagRSSDirectionNormalization;

N=length(TstampRSS);
X=linspace(MappingPointsX(Pstart),MappingPointsX(Pend),N);
Y=linspace(MappingPointsY(Pstart),MappingPointsY(Pend),N);
Z=X*0+1.5;
dx=X-StationX(StationNo);
dy=Y-StationY(StationNo);
dz=Z-StationZ(StationNo);
TagStationDist=sqrt(dx.^2+dy.^2+dz.^2);
plot(TagStationDist,RSSraw,'.','color',[0.6 0.6 0.6]);
plot(TagStationDist,RSS,'r');
plot(TagStationDist(1:10:end),RSS(1:10:end),'r.');

%case 2
CurDate='2019-12-04';
TagNo=5;%791
StartDateTime=[CurDate ' 13:30:12']; EndDateTime=[CurDate ' 13:30:36'];
Pstart=71; Pend=142; t=-90; TagRSSDirectionNormalization=(-63.24--70.40)*0;%right

FileName=[DataFolder '\RSSData_Tag' num2str(TagNo) '_' CurDate '.csv'];
[TstampRSS,RSS]=ReadRSSData(FileName);
TstampRSS=TstampRSS+TagVideoShift;
q=datetime(StartDateTime,'Format','yyyy-MM-dd HH:mm:ss')<TstampRSS & TstampRSS<datetime(EndDateTime,'Format','yyyy-MM-dd HH:mm:ss');
RSSraw=RSS(:,StationNo);
RSS=MovingAverage0(RSSraw,w,0);
TstampRSS=TstampRSS(q); RSS=RSS(q); RSSraw=RSSraw(q);
RSS=RSS+TagRSSDirectionNormalization; RSSraw=RSSraw+TagRSSDirectionNormalization;

N=length(TstampRSS);
X=linspace(MappingPointsX(Pstart),MappingPointsX(Pend),N);
Y=linspace(MappingPointsY(Pstart),MappingPointsY(Pend),N);
Z=X*0+1.5;
dx=X-StationX(StationNo);
dy=Y-StationY(StationNo);
dz=Z-StationZ(StationNo);
TagStationDist=sqrt(dx.^2+dy.^2+dz.^2);
plot(TagStationDist,RSSraw,'*','color',[0.6 0.6 0.6]);
plot(TagStationDist,RSS,'r');
plot(TagStationDist(1:10:end),RSS(1:10:end),'r*');

xlabel('Distance [m]'); ylabel('RSS [dB]');
axis tight;
ylim([-85 -50]);
set(gcf,'Position',[700 200 320 300]);
