DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
IntervalLength=60;%sec
Fs=25;            % Sampling frequency
IntervalN=ceil(IntervalLength*Fs);
IntervalOverlap=0;% %
FeedingM=1; RuminatingM=2; NothingM=3; DrinkingM=4;
FeedersVideoShift=seconds(-39);%'2019-12-05'
TagVideoShift=seconds(5);%'2019-12-04', tag 17

[CowNumber,CowTag,CowDaysN,CowDays]=ReadTagCowNoFitting(DataFolder,'TagCowNoFittingRef.csv',0);
CowN=length(CowNumber);

% AccFeatures=[];
% AccTimeRef=[];
% BodyPosition=[];
% BodyPositionRef=[];
% CowNoRef=[];
FeedingBehaviorRef=[];
AccValues=[];
AccFFT=[];

for CowNo_i=1:CowN
    disp(CowNo_i);
    TagNo=CowTag(CowNo_i);
    for Day_i=1:CowDaysN(CowNo_i)
        CurDate=char(CowDays(CowNo_i,Day_i));
        
        FileName=[DataFolder '\AccData_Tag' num2str(TagNo) '_' CurDate '.csv'];
        if ~isfile(FileName)
            disp(['No file ' FileName]);
            continue;
        end
        [TstampAcc, Acc1, Acc2, Acc3]=ReadAccData(FileName);
        TstampAcc=TstampAcc+TagVideoShift;        
        
        [n,m]=size(Acc1);
        if n==0
            continue;
        end
        w=ceil(2*Fs);
        Acc1=MovingAverage0(Acc1,w,0);
        Acc2=MovingAverage0(Acc2,w,0);
        Acc3=MovingAverage0(Acc3,w,0);
        A=sqrt(Acc1.^2+Acc2.^2+Acc3.^2)-1000;
        fbr=GetFeedingBehaviorReference(TstampAcc,TagNo,CurDate,DataFolder,0);
        
        for j=1:floor(length(A)/IntervalN)
            f=fbr((j-1)*IntervalN+1:j*IntervalN);
            v=ValueFrequency(f);
            if v~=0
                FeedingBehaviorRef=[FeedingBehaviorRef; v];
                ai=A((j-1)*IntervalN+1:j*IntervalN);
                AccValues=[AccValues; ai'];

                L=length(ai);             % Length of signal
                ai=ai-mean(ai);
                Y = fft(ai);
                P2 = abs(Y/L);
                P1 = P2(1:floor(L/2)+1);
                P1(2:end-1) = 2*P1(2:end-1);
    %                     P1=MovingAverage0(P1,3,0);
    %                     P1=MovingAverage0(P1,3,0);
    %                     P1=MovingAverage0(P1,3,0);
                AccFFT=[AccFFT; P1'];
            end
        end
    end
end
save([DataFolder '\FeedingBehaviorLearningReference_' num2str(IntervalLength) 'sInterval'],'FeedingBehaviorRef','AccValues','AccFFT');