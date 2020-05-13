function [MappingPointsInd,MappingPointsIndRef,T]=ComparisonWithLocationReference(MappingPointsInd,TstampRSS,TagNo,CurDate,DataFolder,Draw)
% T=readtable([DataFolder '\TagCowNoFitting.csv'],'Delimiter',';','ReadVariableNames',false);
T=readtable([DataFolder '\TagCowNoFittingRef.csv'],'Delimiter',';','ReadVariableNames',false);
ExpDatesStr=string(table2array(T(1,2:end)));%,'InputFormat','yyyy-MM-dd');
Tags=table2array(T(2:end,1));
i=find(ExpDatesStr==CurDate,1);
j=find(Tags==TagNo,1);
if isempty(i) || isempty(j)
    disp('There is no this date in the file TagCowNoFitting.csv');
    MappingPointsInd=[];
    MappingPointsIndRef=[];
    return;
else
    CowNo=str2num(char(table2array(T(j+1,i+1))));
    if isempty(CowNo)
        disp('There is no this date in the file TagCowNoFitting.csv');
        MappingPointsInd=[];
        MappingPointsIndRef=[];
        return;
    end
end
[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo]=ReadBarnSystemStructure(DataFolder);
MappingPointsN=length(MappingPointsX);

% q=MappingPointsInd~=MappingPointsN;
% MappingPointsInd=MappingPointsInd(q);
% TstampRSS=TstampRSS(q);
MappingPointsIndRef=MappingPointsInd*0;

CurDateTime=datetime(CurDate,'Format','yyyy-MM-dd');

if Draw
    cla; hold on;
    plot(TstampRSS,MappingPointsInd,'b.');
    xlabel('Time');
    ylabel('Mapping Points Number');
    offs=0.2;
end
FeedersVideoShift=seconds(-39);%'2019-12-05'
RobotVideoShift=seconds(16);%'2019-12-05'

FileName=[DataFolder, '\FeedingData.csv'];
% FileName=[DataFolder, '\FeedingData_' CurDate '.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef, StationNo]=ReadReferenceFeedingData(FileName,CowNo,CurDateTime);
    DateTimeStartRef=DateTimeStartRef+FeedersVideoShift;
    DateTimeEndRef=DateTimeEndRef+FeedersVideoShift;
    for i=1:length(DateTimeStartRef)
        q=DateTimeStartRef(i)<TstampRSS & TstampRSS<DateTimeEndRef(i);
        MappingPointsIndRef(q)=FeedingStationPointsNo(StationNo(i));
        if i>1 && abs(StationNo(i)-StationNo(i-1))==0 && DateTimeStartRef(i)-DateTimeEndRef(i-1)<seconds(120)
            q=DateTimeEndRef(i-1)<TstampRSS & TstampRSS<DateTimeStartRef(i);
            MappingPointsIndRef(q)=FeedingStationPointsNo(StationNo(i));
        end
%         if Draw
%             plot([DateTimeStartRef(i) DateTimeEndRef(i)],[a a]+offs,'b');
%         end
    end
else
    disp(['File ' FileName ' does not exist']);
end

FileName=[DataFolder, '\DrinkingData.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef, StationNo]=ReadReferenceFeedingData(FileName,CowNo,CurDateTime);
    DateTimeStartRef=DateTimeStartRef+FeedersVideoShift;
    DateTimeEndRef=DateTimeEndRef+FeedersVideoShift;
    for i=1:length(DateTimeStartRef)
        q=DateTimeStartRef(i)<TstampRSS & TstampRSS<DateTimeEndRef(i);
        MappingPointsIndRef(q)=WaterStationPointsNo(StationNo(i));
%         if Draw
%             plot([DateTimeStartRef(i) DateTimeEndRef(i)],[a a]+offs,'b');
%         end
    end
else
    disp(['File ' FileName ' does not exist']);
end

FileName=[DataFolder, '\MilkingData.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef]=ReadReferenceMilkingData(FileName,CowNo,CurDateTime);
    DateTimeStartRef=DateTimeStartRef+RobotVideoShift;
    DateTimeEndRef=DateTimeEndRef+RobotVideoShift;
    for i=1:length(DateTimeStartRef)
        q=DateTimeStartRef(i)<TstampRSS & TstampRSS<DateTimeEndRef(i);
        MappingPointsIndRef(q)=147;%??
%         if Draw
%             plot([DateTimeStartRef(i) DateTimeEndRef(i)],[a a]+offs,'b');
%         end
    end
else
    disp(['File ' FileName ' does not exist']);
end

FileName=[DataFolder, '\Reference_BodyPosition_' strrep(CurDate,'_','-') '.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef, StartPointRef, EndPointRef, BodyPositionStringRef]=ReadReferenceBodyPositionData(FileName,CowNo);
    for i=1:length(DateTimeStartRef)
        if DateTimeEndRef(i)-DateTimeStartRef(i)<seconds(3)
            DateTimeEndRef(i)=DateTimeStartRef(i)+seconds(3);
        end
        q=DateTimeStartRef(i)<TstampRSS & TstampRSS<=DateTimeEndRef(i);
        if BodyPositionStringRef{i}(1)=='L'
            MappingPointsIndRef(q)=StartPointRef(i);
        elseif BodyPositionStringRef{i}(1)=='S'
            MappingPointsIndRef(q)=StartPointRef(i);
        elseif BodyPositionStringRef{i}(1)=='W'
%             MappingPointsIndRef(q)=StartPointRef(i);%??
        end
%         if Draw
%             plot([DateTimeStartRef(i) DateTimeEndRef(i)],[a a]+offs,'b');
%         end
    end
else
    disp(['File ' FileName ' does not exist']);
end

qRef=MappingPointsIndRef~=0;% & MappingPointsInd~=MappingPointsN;
if Draw
    MappingPointsIndRef(~qRef)=NaN;
    plot(TstampRSS,MappingPointsIndRef+offs,'r','LineWidth',2);
    legend('Calculated','Reference');
end

% figure;
% load('LocationProbability');
% [n,m]=size(LocationProbability);
% LocationProbabilityImg=uint8(zeros(m,n,3));
% for i=1:n
%     pmax=max(LocationProbability(i,:));
%     LocationProbabilityImg(m:-1:1,i,2)=uint8(LocationProbability(i,:)/pmax*256);
%     
%     LocationProbabilityImg(m+1-MappingPointsInd(i),i,:)=[0 0 256];
%     if ~isnan(MappingPointsIndRef(i))
%         LocationProbabilityImg(m+1-MappingPointsIndRef(i),i,:)=[256 0 0];
%     end
% end
% imshow(LocationProbabilityImg);
% xlabel('Time [s]'); ylabel('Location Point Number');

T=TstampRSS(qRef);
MappingPointsInd=MappingPointsInd(qRef);
MappingPointsIndRef=MappingPointsIndRef(qRef);
if Draw
    X=MappingPointsX(MappingPointsInd);
    Xref=MappingPointsX(MappingPointsIndRef);
    Y=MappingPointsY(MappingPointsInd);
    Yref=MappingPointsY(MappingPointsIndRef);
    dx=Xref-X;
    dy=Yref-Y;
    d=sqrt(dx.^2+dy.^2);
    n=sum(qRef);
% disp(['Location accuracy']);
    disp(['<0.5m ' num2str(sum(d<0.5)/n*100) '%']);
    disp(['<1m ' num2str(sum(d<1)/n*100) '%']);
    disp(['<2m ' num2str(sum(d<2)/n*100) '%']);
    disp(['<3m ' num2str(sum(d<3)/n*100) '%']);
    disp(['<5m ' num2str(sum(d<5)/n*100) '%']);
%     disp(['<10m ' num2str(sum(d<10)/n*100) '%']);
    disp(['mean accuracy ' num2str(mean(d)) 'm']);
    nmin=min(MappingPointsInd); nmax=max(MappingPointsInd); dn=(nmax-nmin)/10;
%     k=min(ceil(length(TstampRSS)/10),1000);
%     text(TstampRSS(k),nmax-dn,['<0.5m ' num2str(sum(d<0.5)/n*100,2) '%']);
%     text(TstampRSS(k),nmax-dn*2,['<1m ' num2str(sum(d<1)/n*100,2) '%']);
%     text(TstampRSS(k),nmax-dn*3,['<2m ' num2str(sum(d<2)/n*100,2) '%']);
%     text(TstampRSS(k),nmax-dn*4,['<3m ' num2str(sum(d<3)/n*100,2) '%']);
%     text(TstampRSS(k),nmax-dn*5,['<5m ' num2str(sum(d<5)/n*100,2) '%']);
%     text(TstampRSS(k),nmax-dn*6,['<10m ' num2str(sum(d<10)/n*100,2) '%']);
end

