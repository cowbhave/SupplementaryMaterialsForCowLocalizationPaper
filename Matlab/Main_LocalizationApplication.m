%Application of the localization algorithm on all data collected in the experiment

DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';

[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo]=ReadBarnSystemStructure(DataFolder);

[CowNumber,CowTag,CowDaysN,CowDays]=ReadTagCowNoFitting(DataFolder,'TagCowNoFitting.csv',1);
CowN=length(CowNumber);
CowPointFreq=zeros(CowN,length(MappingPointsY));
CollarTag=1;
for CowNo_i=1:CowN
    disp(CowNo_i);
    TagNo=CowTag(CowNo_i);
    MappingPointsInd=[];
    MappingPointsIndRef=[];
    for Day_i=1:CowDaysN(CowNo_i)
        CurDate=char(CowDays(CowNo_i,Day_i));
        
        FileName=[DataFolder '\RSSData_Tag' num2str(TagNo) '_' CurDate '.csv'];
        if ~isfile(FileName)
            disp(['No file ' FileName]);
            continue;
        end
        [TstampRSS, RSS]=ReadRSSData(FileName);
        TstampRSS=TstampRSS+TagVideoShift;
        [n,m]=size(RSS);
        if n==0
            continue;
        end
        w=ceil(10/0.2);
        for i=1:m
        %     RSS(:,i)=KalmanFilter1D(RSS(:,i),TstampRSS,0.0001);
        %     RSS(:,i)=MedianFilter0(RSS(:,i),w,0);
            RSS(:,i)=MovingAverage0(RSS(:,i),w,0);
        end
        [RSS,TstampRSS]=DecreaseSignalFrequency(RSS,TstampRSS,ceil(5/0.2));
        [MappingPointsInd_day]=RSSLocation_XYMap(RSS,TstampRSS,DataFolder);
        % [MappingPointsInd]=RSSLocation_OrientationMap(RSS,TstampRSS,DataFolder);%,Acc1_rss,Acc2_rss,Acc3_rss
        MappingPointsInd=[MappingPointsInd; MappingPointsInd_day];
    end
    
    for i=1:length(MappingPointsInd)
        CowPointFreq(CowNo_i,MappingPointsInd(i))=CowPointFreq(CowNo_i,MappingPointsInd(i))+1;
    end
end

%% Example of a behavior histogram Fig. 13. e
CowNo_i=1;
fr=CowPointFreq(CowNo_i,:);
BehHist(1)=sum(fr([1:25 51:61 75:84]));
BehHist(2)=sum(fr(213:234));
BehHist(3)=sum(fr([212 235]));
BehHist(4)=sum(fr(147));
BehHist(5)=sum(fr(138:146));
BehHist(6)=sum(fr)-sum(BehHist(1:5));
bar(BehHist/sum(BehHist)*100);
ylabel('Time [%]');
set(gca,'xticklabel',{'Pens'; 'Feeding'; 'Drinking'; 'Milking'; 'Waiting'; 'Isle'});
set(gcf,'Position',[50 300 320*2 300]);

%% Example of preferable cow locations Fig. 13. a
CowNo_i=1;
figure;
DrawHeatMap(DataFolder,CowPointFreq(CowNo_i,1:end-1));
set(gcf,'Position',[50 300 400 100]);

%% Total preferable locations in the barn Fig. 13. b
figure;
DrawHeatMap(DataFolder,sum(CowPointFreq(:,1:end-1)));
set(gcf,'Position',[50 300 400 100]);