% addpath('SVM_lib');
DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
% DataFolder='E:\CowBhave';
CurDate='2019-11-08'; TagVideoShift=seconds(-2);%'2019-11-09', tag 1
% CurDate='2019-12-06'; TagVideoShift=seconds(5);%'2019-12-04', tag 17
FeedersVideoShift=seconds(-39);%'2019-12-05'

TagNo=13;
CollarTag=1;
StartDateTime=[CurDate ' 0:01:00'];
EndDateTime=[CurDate ' 23:59:00'];
FileName=[DataFolder '\AccData_Tag' num2str(TagNo) '_' CurDate '.csv'];
[TstampAcc1, Acc11, Acc21, Acc31]=ReadAccData(FileName);
TstampAcc=TstampAcc1; Acc1=Acc11; Acc2=Acc21; Acc3=Acc31;
% figure; plot(TstampAcc,[Acc1 Acc2 Acc3],'.'); legend('x','y','z');
TstampAcc=TstampAcc+TagVideoShift;

% q=datetime(StartDateTime,'Format','yyyy-MM-dd HH:mm:ss')<TstampAcc & TstampAcc<datetime(EndDateTime,'Format','yyyy-MM-dd HH:mm:ss');
% TstampAcc=TstampAcc(q); Acc1=Acc1(q); Acc2=Acc2(q); Acc3=Acc3(q);
windowSize=100; 
% [Acc1,STD]=STDFilterWindow(Acc1,windowSize,3,-1200,1200);
% [Acc2,STD]=STDFilterWindow(Acc2,windowSize,3,-1200,1200);
% [Acc3,STD]=STDFilterWindow(Acc3,windowSize,3,-1200,1200);
w=ceil(10/0.04);
Acc1=MovingAverage0(Acc1,w,0);
Acc2=MovingAverage0(Acc2,w,0);
Acc3=MovingAverage0(Acc3,w,0);

% [Agrav,A2,A3]=FindTagOrientation(Acc1,Acc2,Acc3,TstampAcc);


% a = [1 0];
% b = [1 1 1];
% b=b*sum(a)/sum(b);
% y = filter(b,a,Acc2);
% cla; hold on;
% plot(TstampAcc,Acc2,'.');
% plot(TstampAcc,y);

% w=Acc1; Acc1=Acc2; Acc2=-w;
% w=Acc1; Acc1=Acc2; Acc2=w;
% Acc2=-Acc2;
[BodyPosition,FeedingBehavior]=AccelerationBehaviourClassification(Acc1,Acc2,Acc3,CollarTag,TstampAcc);
% plot(TstampAcc,BodyPosition,'.')
ComparisonWithBehaviorReference(BodyPosition,FeedingBehavior,TstampAcc,TagNo,CurDate,DataFolder,1);