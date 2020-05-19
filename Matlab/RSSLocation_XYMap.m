function [MappingPointsInd,TstampRSS]=RSSLocation_XYMap(RSS,TstampRSS,DataFolder)
[RSSN,StationN]=size(RSS);
[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo]=ReadBarnSystemStructure(DataFolder);
StationN=length(StationX);
RSS=RSS(:,StationNo);
MappingPointsZ=1.5;
MappingPointsN=length(MappingPointsX);

%Creating the map
RSSMap=zeros(MappingPointsN,StationN);
RSSMapM=zeros(MappingPointsN,1);
for i=1:MappingPointsN
    for j=1:StationN
        dx=MappingPointsX(i)-StationX(j);
        dy=MappingPointsY(i)-StationY(j);
        dz=MappingPointsZ-StationZ(j);
        TagStationDist=sqrt(dx^2+dy^2+dz^2);
        RSSMap(i,j)=DistToRSSI(TagStationDist);
    end
    RSSMapM(i)=mean(RSSMap(i,:));
end
% RSSMap=round(RSSMap*10)/10;
% writetable(array2table(RSSMap),[DataFolder '\RSSDistMap.csv'],'WriteVariableNames',false,'Delimiter',';');

LocationProbability=zeros(RSSN,MappingPointsN);%emisition matrix
for i=1:RSSN
    rss_i=RSS(i,:); rss_im=mean(rss_i);
    for j=1:MappingPointsN
        er_v=rss_i-rss_im-(RSSMap(j,:)-RSSMapM(j));
        er=sum((er_v).^2);
%         er=sum(abs(er_v));
%         er=sum((rss_i-RSSMap(k,:)).^2);
        LocationProbability(i,j)=1/er;
    end
end

%Viterbi filtering
T=readtable([DataFolder '\PassageProbabilityMatrix.csv'],'Delimiter',';','ReadVariableNames',false);
PP=table2array(T);%transition matrix 
MappingPointsInd=ViterbiCorrection(LocationProbability,PP);
save('LocationProbability','LocationProbability');
% [m,MappingPointsInd]=max(LocationProbability,[],2);