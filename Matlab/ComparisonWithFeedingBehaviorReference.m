function [FeedingBehavior,FeedingBehaviorRef]=ComparisonWithFeedingBehaviorReference(FeedingBehavior,TstampAcc,TagNo,CurDate,DataFolder,Draw)
% T=readtable([DataFolder '\TagCowNoFittingRef.csv'],'Delimiter',';','ReadVariableNames',false);
T=readtable([DataFolder '\TagCowNoFitting.csv'],'Delimiter',';','ReadVariableNames',false);
ExpDatesStr=string(table2array(T(1,2:end)));%,'InputFormat','yyyy-MM-dd');
Tags=table2array(T(2:end,1));
i=find(ExpDatesStr==CurDate,1);
j=find(Tags==TagNo,1);
if isempty(i) || isempty(j)
    disp('There is no this date in the file TagCowNoFitting.csv');
    return;
else
    CowNo=str2num(char(table2array(T(j+1,i+1))));
    if isempty(CowNo)
        disp('There is no this date in the file TagCowNoFitting.csv');
        return;
    end
end
% [StationX,StationY,StationZ,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo]=ReadBarnSystemStructure(DataFolder);
% MappingPointsN=length(MappingPointsX);
CurDateTime=datetime(CurDate,'Format','yyyy-MM-dd');
FeedingM=1; RuminatingM=2; NothingM=3; DrinkingM=4;
LyingM=5; StandingM=6; WalkingM=7;
BodyPositionRef=BodyPosition*0;
FeedingBehaviorRef=FeedingBehavior*0;

if Draw
    cla; hold on;
    plot(TstampAcc,BodyPosition,'b.');
    plot(TstampAcc,FeedingBehavior,'g.');
    xlabel('Time [min]');
    ylabel('Behavior index');
    offs=0.2;
end
FeedersVideoShift=seconds(-39);%'2019-12-05'

FileName=[DataFolder, '\FeedingData.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef, StationNo]=ReadReferenceFeedingData(FileName,CowNo,CurDateTime);
    DateTimeStartRef=DateTimeStartRef+FeedersVideoShift;
    DateTimeEndRef=DateTimeEndRef+FeedersVideoShift;
    for i=1:length(DateTimeStartRef)
        q=DateTimeStartRef(i)<TstampAcc & TstampAcc<DateTimeEndRef(i);
        BodyPositionRef(q)=StandingM;
        FeedingBehaviorRef(q)=FeedingM;
        if i>1 && abs(StationNo(i)-StationNo(i-1))<3 && DateTimeStartRef(i)-DateTimeEndRef(i-1)<seconds(10)
            BodyPositionRef(DateTimeEndRef(i-1)<TstampAcc & TstampAcc<DateTimeStartRef(i))=StandingM;
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
        q=DateTimeStartRef(i)<TstampAcc & TstampAcc<DateTimeEndRef(i);
        BodyPositionRef(q)=StandingM;
        FeedingBehaviorRef(q)=FeedingM;
%         if Draw
%             plot([DateTimeStartRef(i) DateTimeEndRef(i)],[a a]+offs,'b');
%         end
    end
else
    disp(['File ' FileName ' does not exist']);
end

FileName=[DataFolder, '\MilkingData.csv'];
FileName=[DataFolder, '\Reference_BodyPosition_' strrep(CurDate,'_','-') '.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef, StartPointRef, EndPointRef, BodyPositionStringRef]=ReadReferenceBodyPositionData(FileName,CowNo);
    for i=1:length(DateTimeStartRef)
        if BodyPositionStringRef{i}(1)=='L' || BodyPositionStringRef{i}(1)=='l'
            a=LyingM;
        elseif BodyPositionStringRef{i}(1)=='S' || BodyPositionStringRef{i}(1)=='s'
            a=StandingM;
        elseif BodyPositionStringRef{i}(1)=='W' || BodyPositionStringRef{i}(1)=='w'
            a=WalkingM;
        end
        q=DateTimeStartRef(i)<TstampAcc & TstampAcc<DateTimeEndRef(i);
        BodyPositionRef(q)=a;
%         if Draw
%             plot([DateTimeStartRef(i) DateTimeEndRef(i)],[a a]+offs,'b');
%         end
    end
else
    disp(['File ' FileName ' does not exist']);
end

FileName=[DataFolder, '\Reference_FeedingBehavior_' strrep(CurDate,'_','-') '.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef, FeedingBehaviorStringRef]=ReadReferenceFeedingBehaviorData(FileName,CowNo);
    for i=1:length(DateTimeStartRef)
        if FeedingBehaviorStringRef{i}(1)=='F' || FeedingBehaviorStringRef{i}(1)=='f'
            a=FeedingM;
        elseif FeedingBehaviorStringRef{i}(1)=='R' || FeedingBehaviorStringRef{i}(1)=='r'
            a=RuminatingM;
        elseif FeedingBehaviorStringRef{i}(1)=='N' || FeedingBehaviorStringRef{i}(1)=='n'
            a=NothingM;
        elseif FeedingBehaviorStringRef{i}(1)=='D' || FeedingBehaviorStringRef{i}(1)=='d'
            a=DrinkingM;
        end
        q=DateTimeStartRef(i)<TstampAcc & TstampAcc<DateTimeEndRef(i);
        FeedingBehaviorRef(q)=a;
%         if Draw
%             plot([DateTimeStartRef(i) DateTimeEndRef(i)],[a a]+offs,'b');
%         end
    end
else
    disp(['File ' FileName ' does not exist']);
end
qRefBP=BodyPositionRef~=0;
BodyPosition=BodyPosition(qRefBP);
BodyPositionRef=BodyPositionRef(qRefBP);
qRefFB=FeedingBehaviorRef~=0;
FeedingBehavior=FeedingBehavior(qRefFB);
FeedingBehaviorRef=FeedingBehaviorRef(qRefFB);

if Draw
%     BodyPositionRef(~qRefBP)=NaN;
%     FeedingBehaviorRef(~qRefFB)=NaN;
    plot(TstampAcc(qRefBP),BodyPositionRef+offs,'.b','MarkerSize',3);
    plot(TstampAcc(qRefFB),FeedingBehaviorRef+offs,'.g','MarkerSize',3);
%     legend('Body Position','Feeding Behavior','Body Position Ref','Feeding Behavior Ref','Location','Best');
    w=0.1;
    text(TstampAcc(end),FeedingM+w,'Feeding');
    text(TstampAcc(end),RuminatingM+w,'Ruminating');
    text(TstampAcc(end),NothingM+w,'Nothing');
    text(TstampAcc(end),DrinkingM+w,'Drinking');
    text(TstampAcc(end),LyingM+w,'Lying');
    text(TstampAcc(end),StandingM+w,'Standing');
    text(TstampAcc(end),WalkingM+w,'Walking');
    legend('BodyPosition','FeedingBehavior','BodyPositionRef','FeedingBehaviorRef');
    %Total
    NRef=sum(BodyPositionRef~=0 & BodyPosition~=0);
    NTP=sum(BodyPositionRef==BodyPosition & BodyPositionRef~=0 & BodyPosition~=0);
    disp(['Body position sensitivity ' num2str(NTP/NRef*100) '%']);
    %Lying
    NRef=sum(BodyPositionRef==LyingM);
    NTP=sum(BodyPositionRef==LyingM & BodyPosition==LyingM);
    disp(['Lying sensitivity ' num2str(NTP/NRef*100) '%']);
    %Standing
    NRef=sum(BodyPositionRef==StandingM);
    NTP=sum(BodyPositionRef==StandingM & BodyPosition==StandingM);
    disp(['Standing sensitivity ' num2str(NTP/NRef*100) '%']);
    %Walking
    NRef=sum(BodyPositionRef==WalkingM);
    NTP=sum(BodyPositionRef==WalkingM & BodyPosition==WalkingM);
    disp(['Walking sensitivity ' num2str(NTP/NRef*100) '%']);

    NRef=sum(FeedingBehaviorRef~=0);
    NTP=sum(FeedingBehaviorRef==FeedingBehavior & FeedingBehaviorRef~=0);
    disp(['Feeding behavior sensitivity ' num2str(NTP/NRef*100) '%']);
end
