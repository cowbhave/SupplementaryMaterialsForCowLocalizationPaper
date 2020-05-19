%Example illustrating of the localization algorithm, Fig 11

%% Example of tag localization and comparisom with the reference Fig. 11 a
DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
% DataFolder='D:\CowBhaveData\Data_Exp30_01_2020';
% DrawBarnMap(DataFolder);
CurDate='2019-11-09';
% CurDate='2019-12-04';
% CurDate='2020-01-30';
% TagVideoShift=seconds(3);%'2019-12-04', tag 17,6
TagVideoShift=seconds(-2);%'2019-11-09', tag 1
% FeedersVideoShift=seconds(-39);%'2019-12-05'
TagNo=1;
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

[n,StationNoN]=size(RSS);
w=ceil(10/0.2);
for i=1:StationNoN
    RSS(:,i)=MovingAverage0(RSS(:,i),w,0);
end

[RSS,TstampRSS]=DecreaseSignalFrequency(RSS,TstampRSS,ceil(5/0.2));

[MappingPointsInd]=RSSLocation_XYMap(RSS,TstampRSS,DataFolder);
% [MappingPointsInd]=RSSLocation_XYTMap(RSS,TstampRSS,DataFolder);%,Acc1_rss,Acc2_rss,Acc3_rss

[MappingPointsInd_r,MappingPointsIndRef_r,TstampRSS_r]=ComparisonWithLocationReference(MappingPointsInd,TstampRSS,TagNo,CurDate,DataFolder,1);
set(gcf,'Position',[50 100 700 300]);
legend off;

%% Definition and adding the presented moments Fig. 11 a
PresentedMoments=[800 3000 6000 7400];%Indeces for CurDate='2019-11-09'; TagNo=1;
j=0;
for Time_i=PresentedMoments
    plot([TstampRSS_r(Time_i) TstampRSS_r(Time_i)],[1 max(MappingPointsInd)],'g');
    j=j+1;
    text(TstampRSS_r(Time_i),max(MappingPointsInd),num2str(j),'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','bottom')
end

%% Heating maps for all the presented moments Fig. 11 b
load('LocationProbability');%calculated and saved in RSSLocation_XYMap
[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo,ConstructionsXY]=ReadBarnSystemStructure(DataFolder);
j=0;
for Time_i=PresentedMoments
    figure;
    cla; hold on;
    Prob=LocationProbability(Time_i,1:end-1);
    Prob=Prob/max(Prob);
    [Prob,q]=sort(Prob,'ascend');
    for i=1:length(Prob)
        plot(MappingPointsX(q(i)),MappingPointsY(q(i)),'.','color',[Prob(i)*0 Prob(i)*0.6+0.4 Prob(i)*0],'MarkerSize',45);
    end
    for i=1:length(ConstructionsXY)
        plot([ConstructionsXY(i,1) ConstructionsXY(i,3)],[ConstructionsXY(i,2) ConstructionsXY(i,4)],'k','linewidth',1);
    end

    set(gcf,'Position',[50+j*50 300-j*50 400 100]);
    axis([0 42 0 10]);
    axis equal;
%     axis tight; 
    xlabel('X [m]'); ylabel('Y [m]');
    j=j+1;

    plot(MappingPointsX(MappingPointsIndRef_r(Time_i)),MappingPointsY(MappingPointsIndRef_r(Time_i)),'*r');
    plot(MappingPointsX(MappingPointsInd_r(Time_i)),MappingPointsY(MappingPointsInd_r(Time_i)),'o','color',[0 0 256]/256,'LineWidth',2);
    disp(TstampRSS(Time_i))
end
