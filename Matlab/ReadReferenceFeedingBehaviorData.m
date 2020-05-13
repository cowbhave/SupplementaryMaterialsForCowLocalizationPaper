function [DateTimeStartRef, DateTimeEndRef, FeedingBehaviorStringRef]=ReadReferenceFeedingBehaviorData(FileName,CowNo)
[num,txt]=xlsread(FileName);
CowNoRef=num(:,1);
n=length(CowNoRef);
DateTimeStartRef=NaT(n,1); DateTimeEndRef=NaT(n,1);
FeedingBehaviorStringRef=strings(n,1);
for i=1:n
    s=strrep(txt{i+1,2},'T',' ');
    DateTimeStartRef(i)=datetime(s,'Format','yyyy-MM-dd HH:mm:ss');
    s=strrep(txt{i+1,3},'T',' ');
    DateTimeEndRef(i)=datetime(s,'Format','yyyy-MM-dd HH:mm:ss');
    FeedingBehaviorStringRef(i)=txt{i+1,4};
end

q=CowNoRef==CowNo;
DateTimeStartRef=DateTimeStartRef(q);
DateTimeEndRef=DateTimeEndRef(q);
FeedingBehaviorStringRef=FeedingBehaviorStringRef(q);

