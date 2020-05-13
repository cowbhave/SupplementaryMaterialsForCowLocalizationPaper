% % DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration\Dist_21-04-2020';
% DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration\DistOrient_22-04-2020';
% FileList=dir(DataFolder);
% Tstamp_Raw=[]; StationNo_Raw=[]; TagNo_Raw=[]; RSS_Raw=[];
% for File_i=1:length(FileList)
%     FileName=FileList(File_i).name;
%     if contains(FileName,'RuuviData_Tag')
%         disp(FileName);
%         [ts,sn,tn,r]=ReadRuuviDataRaspPiCSV([DataFolder '\' FileName]);%,tsr
%         Tstamp_Raw=[Tstamp_Raw; ts];
%         StationNo_Raw=[StationNo_Raw; sn];
%         TagNo_Raw=[TagNo_Raw; tn];
%         RSS_Raw=[RSS_Raw; r];
%     end
% end

% ts=datetime(2020,4,21,11,39,00):seconds(135):datetime(2020,4,21,12,33,15);
% ts(7:25)=ts(7:25)+seconds(15); ts(24:25)=ts(24:25)+seconds(15); ts=ts';
% te=datetime(2020,4,21,11,41,00):seconds(135):datetime(2020,4,21,12,35,15);
% te(7:25)=te(7:25)+seconds(15); te(24:25)=te(24:25)+seconds(15); te=te';
ts=datetime(2020,4,22,13,15,15):seconds(135):datetime(2020,4,22,14,10,15); ts=ts';
ts(9:end)=ts(9:end)-seconds(60);
te=datetime(2020,4,22,13,17,15):seconds(135):datetime(2020,4,22,14,12,15); te=te';
te(8:end)=te(8:end)-seconds(60);

WalkingS=datetime(2020,4,22,14,10,30);
WalkingE=datetime(2020,4,22,14,11,12);

StationList=unique(StationNo_Raw);
% TagList=unique(TagNo_Raw);
TagList=[1 2 5 6 8 14 15 16 18 24]';
% TagList=[10 11 21 22];
Dist=1:15;
RSS_M=zeros(length(StationList)*length(TagList),length(Dist));
RSS_Walking=zeros(length(StationList)*length(TagList),length(Dist));

TagNo=zeros(length(StationList)*length(TagList),1);
StationNo=zeros(length(StationList)*length(TagList),1);
A0_TagStation=zeros(length(StationList)*length(TagList),1);
n_TagStation=zeros(length(StationList)*length(TagList),1);
k=0;
figure; hold on;
for Tag_i=1:length(TagList)
    for Station_i=1:length(StationList)
        q=StationNo_Raw==StationList(Station_i) & TagList(Tag_i)==TagNo_Raw;
        RSS=RSS_Raw(q);
        Tstamp=Tstamp_Raw(q);
        k=k+1;
        for Dist_i=1:length(Dist)
            w=ts(Dist_i)<=Tstamp & Tstamp<=te(Dist_i);
            rss=RSS(w);
            RSS_M(k,Dist_i)=mean(rss);
%             plot(Dist_i+linspace(-0.5,0.5,length(rss)),rss,'.','color',[0.6 0.6 0.6]);
%             plot(Dist_i+[-0.5 0.5],mean(rss)+[0 0],'-r','LineWidth',2);
        end
        [A0_TagStation(k),n_TagStation(k),R2]=LinRegression(-10*log(Dist),RSS_M(k,:),0,0);
        d_t=1:0.1:max(Dist); RSS_t=-10*n*log(d_t)+A0;
        plot(d_t,RSS_t,'b-.','LineWidth',2);

        TagNo(k)=Tag_i;
        StationNo(k)=Station_i;
    end
end

%total line
figure; hold on;
plot(Dist,RSS_M);
plot(Dist,mean(RSS_M),'r','LineWidth',3);
set(gcf,'Position',[500 200 320 300]);
axis tight; xlabel('Distance [m]'); ylabel('RSS [dB]');

RSSreg=reshape(RSS_M',1,length(StationList)*length(TagList)*length(Dist))';
Distreg=repmat(Dist,1,length(StationList)*length(TagList))';
[A0,n,R2]=LinRegression(-10*log(Distreg),RSSreg,0,0);
d_t=1:0.1:max(Dist); RSS_t=-10*n*log(d_t)+A0;
plot(d_t,RSS_t,'b-.','LineWidth',2);
disp(['Propagation model: A0=' num2str(A0) '+-' num2str(std(A0_TagStation)) ...
    ', n=' num2str(n) '+-' num2str(std(n_TagStation))]);
% plot(-10*log(Distreg),RSSreg,'.')

figure; hold on;
% title('Tag lines')
STD=zeros(length(TagList),1);
for Tag_i=1:length(TagList)
    q=TagNo==Tag_i;
    plot(Dist,mean(RSS_M(q,:)),'LineWidth',1);
    STD(Tag_i)=mean(std(RSS_M(q,:)));
%     plot(Dist,mean(RSS_M(q,:))+std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Dist,mean(RSS_M(q,:))-std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Dist,std(RSS_M(q,:)),'-','LineWidth',1);    
end
plot(Dist,mean(RSS_M),'r','LineWidth',3);
axis tight; xlabel('Distance [m]'); ylabel('RSS [dB]');
ylim([-82 -40]);
% title(['STD=' num2str(mean(STD))]);
set(gcf,'Position',[50 300 320 300]);

figure; hold on;
% title('Stations lines')
STD=zeros(length(StationList),1);
for Station_i=1:length(StationList)
    q=StationNo==Station_i;
    plot(Dist,mean(RSS_M(q,:)),'LineWidth',1);
    STD(Station_i)=mean(std(RSS_M(q,:)));
%     plot(Dist,mean(RSS_M(q,:))+std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Dist,mean(RSS_M(q,:))-std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Dist,std(RSS_M(q,:)),'-','LineWidth',1);    
end
plot(Dist,mean(RSS_M),'r','LineWidth',3);
axis tight; xlabel('Distance [m]'); ylabel('RSS [dB]');
ylim([-82 -40]);
% title(['STD=' num2str(mean(STD))]);
% set(gcf,'Position',[400 300 320 300]);

%walking
DD=25:-1:1;
for Tag_i=1:length(TagList)
    for Station_i=1:length(StationList)
        q=StationNo_Raw==StationList(Station_i) & TagList(Tag_i)==TagNo_Raw;
        RSS=RSS_Raw(q);
        Tstamp=Tstamp_Raw(q);
        k=k+1;
        for Dist_i=1:length(Dist)
            w=ts(Dist_i)<=Tstamp & Tstamp<=te(Dist_i);
            rss=RSS(w);
            RSS_M(k,Dist_i)=mean(rss);
        end
        TagNo(k)=Tag_i;
        StationNo(k)=Station_i;
%         plot(Dist,RSS_M(k,:));        
    end
end

return

DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration';
% Dist=1:20;
FileName='Tag_DistanceRes1mDur1.csv';
TBSh=[10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 11 11];
TBSm=[06 09 11 13 14 17 18 20 21 23 24 26 28 29 31 33 34 36 37 39 40 42 43 45 46 48 50 51 53 54 56 57 59 00 02 03 05 07 09 10 12];
TBSs=[00 40 30 25 45 30 50 25 45 30 50 35 00 50 15 05 30 00 15 00 25 05 30 25 45 40 00 45 05 50 10 45 05 40 00 45 00 50 10 50 10];
TBEh=[10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 11 11 11];
TBEm=[07 10 12 14 15 18 20 21 22 24 26 27 29 31 32 34 35 37 38 40 41 43 44 46 47 49 51 52 54 56 57 58 00 01 03 04 06 09 10 12 13];
TBEs=[10 50 40 35 55 40 00 35 55 40 00 45 10 00 25 15 40 10 25 10 35 15 40 35 55 50 10 55 15 00 20 55 15 50 10 55 01 00 20 00 20];
Theta=[0  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90];
Dist=[ 0  1  1  2  2  3  3  4  4  5  5  6  6  7  7  8  8  9  9 10 10 11 11 12 12 13 13 14 14 15 15 16 16 17 17 18 18 19 19 20 20];
MappingPointTime=[datetime(2019,10,18,TBSh,TBSm,TBSs)' datetime(2019,10,18,TBEh,TBEm,TBEs)'];
[RSSM,MappingPoint]=ReadRuuviDataMappingCSV([DataFolder '\' FileName],13,26,MappingPointTime);

cla; hold on, grid on;
q=2:2:length(MappingPoint);
plot(Dist(MappingPoint(q)),RSSM(q))
[A0,n,R2]=LinRegression(-10*log(Dist(MappingPoint(q)))',RSSM(q),0,0,0);
d_t=1:0.1:20; RSS_t=-10*n*log(d_t)+A0;
plot(d_t,RSS_t,'r','LineWidth',2);

q=3:2:length(MappingPoint);
plot(Dist(MappingPoint(q)),RSSM(q))
[A0,n,R2]=LinRegression(-10*log(Dist(MappingPoint(q)))',RSSM(q),0,0,0);
d_t=1:0.1:20; RSS_t=-10*n*log(d_t)+A0;
plot(d_t,RSS_t,'r','LineWidth',2);

xlabel('Dist [m]'); ylabel('RSS [dB]');
return

FileName='Tag_DistanceRes1mDur1.csv';
TBSh= [10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 11 11];
TBSm=[06 09 11 13 14 17 18 20 21 23 24 26 28 29 31 33 34 36 37 39 40 42 43 45 46 48 50 51 53 54 56 57 59 00 02 03 05 07 09 10 12];
TBSs= [00 40 30 25 45 30 50 25 45 30 50 35 00 50 15 05 30 00 15 00 25 05 30 25 45 40 00 45 05 50 10 45 05 40 00 45 00 50 10 50 10];
TBEh= [10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 11 11 11];
TBEm=[07 10 12 14 15 18 20 21 22 24 26 27 29 31 32 34 35 37 38 40 41 43 44 46 47 49 51 52 54 56 57 58 00 01 03 04 06 09 10 12 13];
TBEs= [10 50 40 35 55 40 00 35 55 40 00 45 10 00 25 15 40 10 25 10 35 15 40 35 55 50 10 55 15 00 20 55 15 50 10 55 01 00 20 00 20];
Theta=   [0  0 90  0  90  0  90  0  90  0  90  0  90  0  90  0 90  0  90  0  90  0  90  0  90  0  90  0  90  0  90  0  90  0  90  0  90  0 90  0 90];
Dist=     [ 0  1  1   2   2   3   3   4  4    5  5   6   6   7   7   8  8   9   9 10 10  11 11 12 12 13 13 14 14 15 15 16 16 17 17 18 18 19 19 20 20];

[RSSM,MappingPoint]=ReadRuuviDataMappingCSV([DataFolder '\' FileName],11,5);
[DateTime,StationNo,TagNo,RSS]=ReadRuuviDataCSV([DataFolder '\' FileName]);
RSSM=zeros(length(Dist),1);
D=day(DateTime(1)); M=month(DateTime(1)); Y=year(DateTime(1));
for i=1:length(Dist)
    q=datetime(Y,M,D,TBSh(i),TBSm(i),TBSs(i))<DateTime & DateTime<datetime(Y,M,D,TBEh(i),TBEm(i),TBEs(i));
    RSSM(i)=mean(RSS(q));
end
q=Theta==0 & Dist~=0;
RSSM1=RSSM(q);
Dist1=Dist(q);
q=Theta==90;
RSSM2=RSSM(q);
Dist2=Dist(q);
cla; hold on;
plot(Dist1,RSSM1);
plot(Dist2,RSSM2);
plot(Dist1,RSSM1-RSSM2);