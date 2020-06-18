% Processing of data from the RSS propagation experiment
% Creating an averaged RSS propagation model
% % Fig. 6

DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration\DistOrient_22-04-2020';
% % Collection of the available data
FileList=dir(DataFolder);
Tstamp_Raw=[]; StationNo_Raw=[]; TagNo_Raw=[]; RSS_Raw=[];
for File_i=1:length(FileList)
    FileName=FileList(File_i).name;
    if contains(FileName,'RuuviData_Tag')
        disp(FileName);
        [ts,sn,tn,r]=ReadRuuviDataRaspPiCSV([DataFolder '\' FileName]);%,tsr
        Tstamp_Raw=[Tstamp_Raw; ts];
        StationNo_Raw=[StationNo_Raw; sn];
        TagNo_Raw=[TagNo_Raw; tn];
        RSS_Raw=[RSS_Raw; r];
    end
end

% % Setting the measuring time
ts=datetime(2020,4,22,13,15,15):seconds(135):datetime(2020,4,22,14,10,15); ts=ts';
ts(9:end)=ts(9:end)-seconds(60);
te=datetime(2020,4,22,13,17,15):seconds(135):datetime(2020,4,22,14,12,15); te=te';
te(8:end)=te(8:end)-seconds(60);

StationList=unique(StationNo_Raw);
TagList=[1 2 5 6 8 14 15 16 18 24]';% Tags participated in the RSS-propagation experiment
Dist=1:15;
RSS_M=zeros(length(StationList)*length(TagList),length(Dist));

% % Example of the RSS propagation experiment Fig. 6 a
figure; hold on;
Tag_i=1;
Station_i=1;
q=StationNo_Raw==StationList(Station_i) & TagList(Tag_i)==TagNo_Raw;
RSS=RSS_Raw(q);
Tstamp=Tstamp_Raw(q);
for Dist_i=1:length(Dist)
    w=ts(Dist_i)<=Tstamp & Tstamp<=te(Dist_i);
    rss=RSS(w);
    rss_M(Dist_i)=mean(rss);
    plot(Dist_i+linspace(-0.5,0.5,length(rss)),rss,'.','color',[0.6 0.6 0.6]);
    plot(Dist_i+[-0.5 0.5],mean(rss)+[0 0],'-r','LineWidth',2);
end
[A0,n,R2]=LinRegression(-10*log(Dist),rss_M,0,0);
d_t=1:0.1:max(Dist); RSS_t=-10*n*log(d_t)+A0;
plot(d_t,RSS_t,'b-.','LineWidth',2);
set(gcf,'Position',[100 200 320 300]);
axis tight; xlabel('Distance [m]'); ylabel('RSS [dB]');

% % Extracting data for each tag-receiving station combination
TagNo=zeros(length(StationList)*length(TagList),1);
StationNo=zeros(length(StationList)*length(TagList),1);
A0_TagStation=zeros(length(StationList)*length(TagList),1);
n_TagStation=zeros(length(StationList)*length(TagList),1);
k=0;
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
        [A0_TagStation(k),n_TagStation(k),R2]=LinRegression(-10*log(Dist),RSS_M(k,:),0,0);
        TagNo(k)=Tag_i;
        StationNo(k)=Station_i;
    end
end

% % All tag-recieving station combinations and the total avereged line Fig. 6 b
figure; hold on;
% plot(Dist,RSS_M,'color',[0.8 0.8 0.8]);

MedianColor=[1 0 0];
BoxW=0.2;
BoxFaceAlpha=0.5;
BoxColor=[1 0 0; 0 0.5 1; 1 0.5 0]; BoxColor=repmat(BoxColor,10,1);
WhiskersColor=[0.5 0.5 0.5];
for Dist_i=1:length(Dist)
    w=ts(Dist_i)<=Tstamp_Raw & Tstamp_Raw<=te(Dist_i);
    rss=RSS_Raw(w);
    n=length(rss);
    rss=sort(rss); BoxPlotParam=[rss(floor(n*0.5)) rss(floor(n*0.25)) rss(floor(n*0.75)) rss(floor(n*0.05)+1) rss(floor(n*0.95))];
    x=Dist_i;
    plot(x+[BoxW -BoxW],BoxPlotParam(1)+[0 0],'color',MedianColor,'LineWidth',3);
    patch(x+[BoxW BoxW -BoxW -BoxW],[BoxPlotParam(2) BoxPlotParam(3) BoxPlotParam(3) BoxPlotParam(2)],BoxColor(1,:),'FaceAlpha',BoxFaceAlpha);
    plot(x+[0 0],[BoxPlotParam(2) BoxPlotParam(4)],'--','color',WhiskersColor);
    plot(x+[BoxW -BoxW]/2,BoxPlotParam(4)+[0 0],'color',WhiskersColor,'LineWidth',2);
    plot(x+[0 0],[BoxPlotParam(3) BoxPlotParam(5)],'--','color',WhiskersColor);
    plot(x+[BoxW -BoxW]/2,BoxPlotParam(5)+[0 0],'color',WhiskersColor,'LineWidth',2);
end

plot(Dist,mean(RSS_M),'r','LineWidth',3);
set(gcf,'Position',[300 200 320 300]);
axis tight; xlabel('Distance [m]'); ylabel('RSS [dB]');

% % Averaged RSS propagation model Fig. 6 b
RSSreg=reshape(RSS_M',1,length(StationList)*length(TagList)*length(Dist))';
Distreg=repmat(Dist,1,length(StationList)*length(TagList))';
[A0,n,R2]=LinRegression(-10*log(Distreg),RSSreg,0,0);
d_t=1:0.1:max(Dist); RSS_t=-10*n*log(d_t)+A0;
plot(d_t,RSS_t,'b-.','LineWidth',2);
disp(['Propagation model: A0=' num2str(A0) '+-' num2str(std(A0_TagStation)) ...
    ', n=' num2str(n) '+-' num2str(std(n_TagStation))]);
% plot(-10*log(Distreg),RSSreg,'.')

% % Averaged RSS achieved from all 10 tags Fig. 6 c
figure; hold on;
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
set(gcf,'Position',[500 200 320 300]);

% % Averaged RSS achieved from all 10 receiving stations Fig. 6 d
figure; hold on;
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
set(gcf,'Position',[700 200 320 300]);
