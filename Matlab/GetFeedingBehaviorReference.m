function [FeedingBehaviorRef]=GetFeedingBehaviorReference(TstampRef,TagNo,CurDate,DataFolder,Draw)
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
CurDateTime=datetime(CurDate,'Format','yyyy-MM-dd');
FeedingM=1; RuminatingM=2; NothingM=3; DrinkingM=4;
FeedingBehaviorRef=zeros(length(TstampRef),1);

if Draw
    cla; hold on;
    xlabel('Time [min]');
    ylabel('Behavior index');
end
FeedersVideoShift=seconds(-39);%'2019-12-05'
RobotVideoShift=seconds(16);%'2019-12-05'

FileName=[DataFolder, '\FeedingData.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef]=ReadReferenceFeedingData(FileName,CowNo,CurDateTime);
    DateTimeStartRef=DateTimeStartRef+FeedersVideoShift;
    DateTimeEndRef=DateTimeEndRef+FeedersVideoShift;
    for i=1:length(DateTimeStartRef)
        q=DateTimeStartRef(i)<TstampRef & TstampRef<DateTimeEndRef(i);
        FeedingBehaviorRef(q)=FeedingM;
    end
else
    disp(['File ' FileName ' does not exist']);
end

FileName=[DataFolder, '\DrinkingData.csv'];
if isfile(FileName)
    [DateTimeStartRef, DateTimeEndRef]=ReadReferenceFeedingData(FileName,CowNo,CurDateTime);
    DateTimeStartRef=DateTimeStartRef+FeedersVideoShift;
    DateTimeEndRef=DateTimeEndRef+FeedersVideoShift;
    for i=1:length(DateTimeStartRef)
        q=DateTimeStartRef(i)<TstampRef & TstampRef<DateTimeEndRef(i);
        FeedingBehaviorRef(q)=DrinkingM;
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
        q=DateTimeStartRef(i)<TstampRef & TstampRef<DateTimeEndRef(i);
        FeedingBehaviorRef(q)=NothingM*0;
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
        q=DateTimeStartRef(i)<TstampRef & TstampRef<DateTimeEndRef(i);
        FeedingBehaviorRef(q)=a;
    end
else
    disp(['File ' FileName ' does not exist']);
end

if Draw
    qRefFB=FeedingBehaviorRef~=0;
    fb=FeedingBehaviorRef;
    fb(~qRefFB)=NaN;
    plot(TstampRef,fb,'.g','MarkerSize',3);
    w=0.1;
    text(TstampRef(end),FeedingM+w,'Feeding');
    text(TstampRef(end),RuminatingM+w,'Ruminating');
    text(TstampRef(end),NothingM+w,'Nothing');
    text(TstampRef(end),DrinkingM+w,'Drinking');
end
