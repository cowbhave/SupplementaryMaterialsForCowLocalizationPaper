function [RSS,TstampRSS]=DecreaseSignalFrequency(RSS,TstampRSS,n)
[RSSN,StationN]=size(RSS);
n2=ceil(n/2);
RSSN=floor(RSSN/n);
for i=1:RSSN
    RSS(i,:)=mean(RSS(1+(i-1)*n:i*n,:));
    TstampRSS(i)=TstampRSS(i*n-n2);
end
RSS=RSS(1:RSSN,:);
TstampRSS=TstampRSS(1:RSSN);