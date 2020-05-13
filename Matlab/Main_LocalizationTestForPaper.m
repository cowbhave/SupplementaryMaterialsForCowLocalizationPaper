DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
% DataFolder='C:\Users\03138529\Desktop\DataForItaly';
% DataFolder='D:\CowBhaveData\Data_Exp30_01_2020';
TagVideoShift=seconds(5);%'2019-12-04', tag 17
% TagVideoShift=seconds(0);%'2020-01-30', tag 17
FeedersVideoShift=seconds(-39);%'2019-12-05'

[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo]=ReadBarnSystemStructure(DataFolder);

[CowNumber,CowTag,CowDaysN,CowDays]=ReadTagCowNoFitting(DataFolder,'TagCowNoFittingRef.csv',0);
% [n,t,dn,d]=ReadTagCowNoFitting(DataFolder,'TagCowNoFittingRef.csv',0);
% CowNumber=[CowNumber; n]; CowTag=[CowTag; t]; CowDaysN=[CowDaysN; dn]; CowDays=[CowDays; d];
% [CowNumber,q]=sort(CowNumber); CowTag=CowTag(q); CowDaysN=CowDaysN(q); CowDays=CowDays(q,:);

CowN=length(CowNumber);
TagN=max(CowTag);
LocErrCowMean=zeros(CowN,1);
LocErrCowStd=zeros(CowN,1);
LocErrCowBoxPlotParam=zeros(CowN,5);
RefDurationCow=zeros(CowN,1);
LocErrTagMean=zeros(TagN,1);
LocErrTagStd=zeros(TagN,1);
LocErrTagBoxPlotParam=zeros(TagN,5);

CumErrVal=0:0.1:15;
CumErrCow=zeros(CowN,length(CumErrVal));
CumErrTag=zeros(TagN,length(CumErrVal));
CowPointFreqRef=zeros(CowN,length(MappingPointsY));

TagNoPrev=0; Tag_i=0;
CollarTag=1;
for CowNo_i=1:CowN
    disp(CowNo_i);
    TagNo=CowTag(CowNo_i);
    
    Acc=[]; Ts=[];
    
    MappingPointsIndCow=[];
    MappingPointsIndRefCow=[];
    if TagNo~=TagNoPrev
        MappingPointsIndTag=[];
        MappingPointsIndRefTag=[];
        TagNoPrev=TagNo;
    end
    for Day_i=1:CowDaysN(CowNo_i)
        CurDate=char(CowDays(CowNo_i,Day_i));
        
%         FileName=[DataFolder '\AccData_Tag' num2str(TagNo) '_' CurDate '.csv'];
%         [TstampAcc, Acc1, Acc2, Acc3]=ReadAccData(FileName);
%         [acc,ts]=DecreaseSignalFrequency([Acc1 Acc2 Acc3],TstampAcc,ceil(25/0.2));
%         Acc=[Acc; acc];
%         Ts=[Ts; ts];
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
%         [MappingPointsInd_day]=RSSLocation_XYTMap(RSS,TstampRSS,DataFolder);%,Acc1_rss,Acc2_rss,Acc3_rss
        [mi,mir,t]=ComparisonWithLocationReference(MappingPointsInd_day,TstampRSS,TagNo,CurDate,DataFolder,0);
        MappingPointsIndCow=[MappingPointsIndCow; mi];
        MappingPointsIndRefCow=[MappingPointsIndRefCow; mir];
        MappingPointsIndTag=[MappingPointsIndTag; mi];
        MappingPointsIndRefTag=[MappingPointsIndRefTag; mir];
    end
%         TstampStr=datestr(Ts,'yyyy-mm-ddTHH:MM:ss.FFF');
%         T=table(TstampStr,round(Acc));
%         writetable(T,[DataFolder '/AccData_Cow' num2str(CowNumber(CowNo_i)) '.csv'],'WriteVariableNames',false);

    X=MappingPointsX(MappingPointsIndCow);
    Xref=MappingPointsX(MappingPointsIndRefCow);
    Y=MappingPointsY(MappingPointsIndCow);
    Yref=MappingPointsY(MappingPointsIndRefCow);
    dx=Xref-X;
    dy=Yref-Y;
    d=sqrt(dx.^2+dy.^2);
    n=length(d);
    if n<50
        continue;
    end
    LocErrCowMean(CowNo_i)=mean(d);
    LocErrCowStd(CowNo_i)=std(d);
    d=sort(d); LocErrCowBoxPlotParam(CowNo_i,:)=[d(floor(n*0.5)) d(floor(n*0.25)) d(floor(n*0.75)) d(floor(n*0.05)+1) d(floor(n*0.95))];
    for j=1:length(CumErrVal)
        CumErrCow(CowNo_i,j)=sum(d<CumErrVal(j))/n;
    end
    RefDurationCow(i)=length(MappingPointsIndRefCow)*5;%sec
    
    if CowNo_i==CowN || TagNo~=CowTag(CowNo_i+1)
        Tag_i=Tag_i+1;
        X=MappingPointsX(MappingPointsIndTag);
        Xref=MappingPointsX(MappingPointsIndRefTag);
        Y=MappingPointsY(MappingPointsIndTag);
        Yref=MappingPointsY(MappingPointsIndRefTag);
        dx=Xref-X;
        dy=Yref-Y;
        d=sqrt(dx.^2+dy.^2);
        n=length(d);
        LocErrTagMean(Tag_i)=mean(d);
        LocErrTagStd(Tag_i)=std(d);
        d=sort(d); LocErrTagBoxPlotParam(Tag_i,:)=[d(floor(n*0.5)) d(floor(n*0.25)) d(floor(n*0.75)) d(floor(n*0.05)+1) d(floor(n*0.95))];
        for j=1:length(CumErrVal)
            CumErrTag(Tag_i,j)=sum(d<CumErrVal(j))/n;
        end
    end
    
    for i=1:length(MappingPointsIndRefCow)
        CowPointFreqRef(CowNo_i,MappingPointsIndRefCow(i))=CowPointFreqRef(CowNo_i,MappingPointsIndRefCow(i))+1;
    end
end
% save('LocalizationForPaperData','CowLocErrMean','CowLocErrStd','CumErr');
q=LocErrCowBoxPlotParam(:,1)~=0;
LocErrCowBoxPlotParam=LocErrCowBoxPlotParam(q,:); CowTag=CowTag(q); CowNumber=CowNumber(q);
CumErrTag=CumErrTag(q,:);

disp(['Total reference time is ' num2str(sum(RefDurationCow/60/60/24)) 'days, average for cow is ' num2str(mean(RefDurationCow/60/60/24))]);

%% Accuracy estimation for cows
figure; cla; hold on; grid on;
MedianColor=[1 0 0];
BoxW=0.4;
BoxFaceAlpha=0.5;
BoxColor=[0 0 1; 0 0.5 1; 1 0.5 0]; BoxColor=repmat(BoxColor,10,1);
WhiskersColor=[0.5 0.5 0.5];

for i=1:length(CowNumber)
    plot(i+[BoxW -BoxW],LocErrCowBoxPlotParam(i,1)+[0 0],'color',MedianColor,'LineWidth',3);
    patch(i+[BoxW BoxW -BoxW -BoxW],[LocErrCowBoxPlotParam(i,2) LocErrCowBoxPlotParam(i,3) LocErrCowBoxPlotParam(i,3) LocErrCowBoxPlotParam(i,2)],BoxColor(CowTag(i),:),'FaceAlpha',BoxFaceAlpha);
    plot(i+[0 0],[LocErrCowBoxPlotParam(i,2) LocErrCowBoxPlotParam(i,4)],'--','color',WhiskersColor);
    plot(i+[BoxW -BoxW]/2,LocErrCowBoxPlotParam(i,4)+[0 0],'color',WhiskersColor,'LineWidth',2);
    plot(i+[0 0],[LocErrCowBoxPlotParam(i,3) LocErrCowBoxPlotParam(i,5)],'--','color',WhiskersColor);
    plot(i+[BoxW -BoxW]/2,LocErrCowBoxPlotParam(i,5)+[0 0],'color',WhiskersColor,'LineWidth',2);
    text(i,LocErrCowBoxPlotParam(i,5),num2str(CowTag(i)),'HorizontalAlignment','center','VerticalAlignment','bottom')
end
ylabel('Error [m]'); xlabel('Cow number');
xlim([0 CowN+1]);
set(gcf,'Position',[50 300 320*2 300]);
disp(['Total mean error=' num2str(mean(LocErrCowMean)) '[m]'])
disp(['Total mean std=' num2str(mean(LocErrCowStd)) '[m]'])

%Cumulative error graph
figure; cla; hold on; grid on; ylabel('%'); xlabel('Error [m]');
for CowNo_i=1:length(CowNumber)
    plot(CumErrVal,CumErrCow(CowNo_i,:)*100);
end
plot(CumErrVal,mean(CumErrCow)*100,'r','LineWidth',3);
set(gcf,'Position',[50 300 320 300]);

%% Example of preferable cow locations
CowNo_i=1;
figure;
DrawHeatMap(DataFolder,CowPointFreqRef(CowNo_i,1:end-1));
set(gcf,'Position',[50 300 400 100]);

%% Total preferable locations in the barn
figure;
DrawHeatMap(DataFolder,sum(CowPointFreqRef(:,1:end-1)));
set(gcf,'Position',[50 300 400 100]);
