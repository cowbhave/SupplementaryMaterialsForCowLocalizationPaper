function RSS=DistToRSSI(D)%developed when tag t=0, f=0
n=0.84; A0=-48.77;%28-04-2020, 1:15m
% n=1.15; A0=-34.2;%22-04-2020, 1:25m
% n=0.9; A0=-48.1;%2019,10,18
RSS=-10*n*log(D)+A0;
% 
% %distance
% [SamplingDateTime,StationNo,TagNo,RSS,MessageNo,Acc,TstampRecieved]=ReadRuuviDataCSV('C:\Users\L1921\Desktop\CowBhave\DataAnalysis\TagStationCalibration\Tag_DistanceRes1mDur1.csv');
% % (SamplingDateTime, StationNo, TagNo, RSS, MessageNo, Acc, Points, DateTimeString)=ReadCSVDataFileC_v3('C:\Users\L1921\Desktop\CowBhave\DataAnalysis\TagStationCalibration/Tag_DistanceRes1mDur1.csv')
% TBSh=[10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 11 11];
% TBSm=[06 09 11 13 14 17 18 20 21 23 24 26 28 29 31 33 34 36 37 39 40 42 43 45 46 48 50 51 53 54 56 57 59 00 02 03 05 07 09 10 12];
% TBSs=[00 40 30 25 45 30 50 25 45 30 50 35 00 50 15 05 30 00 15 00 25 05 30 25 45 40 00 45 05 50 10 45 05 40 00 45 00 50 10 50 10];
% TBEh=[10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 11 11 11];
% TBEm=[07 10 12 14 15 18 20 21 22 24 26 27 29 31 32 34 35 37 38 40 41 43 44 46 47 49 51 52 54 56 57 58 00 01 03 04 06 09 10 12 13];
% TBEs=[10 50 40 35 55 40 00 35 55 40 00 45 10 00 25 15 40 10 25 10 35 15 40 35 55 50 10 55 15 00 20 55 15 50 10 55 01 00 20 00 20];
% Theta=[0  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90  0 90];
% Dist=[ 0  1  1  2  2  3  3  4  4  5  5  6  6  7  7  8  8  9  9 10 10 11 11 12 12 13 13 14 14 15 15 16 16 17 17 18 18 19 19 20 20];
% TBS=NaT(length(TBSh),1);
% TBE=NaT(length(TBSh),1);
% for i=1:length(TBSh)
%     TBS(i)=datetime(2019,10,18,TBSh(i),TBSm(i),TBSs(i),0);
%     TBE(i)=datetime(2019,10,18,TBEh(i),TBEm(i),TBEs(i),0);
% end
% TagRSS_Dist0=zeros(floor((length(TBSh)-1)/2),1);
% TagRSS_Dist90=zeros(floor((length(TBSh)-1)/2),1);
% i=0;
% for d_i=1:floor((length(TBSh)-1)/2)
%     i=i+1;
%     q=TBS(i)<SamplingDateTime & SamplingDateTime<TBE(i);
%     Q=RSS(q);
%     TagRSS_Dist0(d_i)=mean(Q);
%     i=i+1;
%     q=TBS(i)<SamplingDateTime & SamplingDateTime<TBE(i);
%     Q=RSS(q);
%     TagRSS_Dist90(d_i)=mean(Q);
% end
% d=1:1:20;
% cla; hold on;
% plot(d,TagRSS_Dist0);
% plot(d,TagRSS_Dist90);

