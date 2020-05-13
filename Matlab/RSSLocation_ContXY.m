function [MappingPointsInd,LocationXY,TstampRSS]=RSSLocation_ContXY(RSS,TstampRSS,DataFolder)
[RSSN,StationN]=size(RSS);
[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY]=ReadBarnSystemStructure(DataFolder);
StationN=length(StationX);
StationX=StationX'; StationY=StationY'; StationZ=StationZ';
RSS=RSS(:,StationNo);
LocationXY=zeros(RSSN,2);
MappingPointsInd=zeros(RSSN,1);
Qinit=[20 4];
% options=optimoptions('fmincon','StepTolerance',0.01,'OptimalityTolerance',0.001);
options=optimset('Display','off','TolX',1e-2);

% Y=0:0.1:9.8; X=3:0.3:42;
% [XX,YY]=meshgrid(X,Y); ZZ=XX*0;
% RSSmes=RSS(3000,:);
% for i=1:length(X)
%     for j=1:length(Y)
%         ZZ(j,i)=RSSLocationXYObjFunc([XX(j,i) YY(j,i)],RSSmes,StationX,StationY,StationZ);
%     end
% end
% surf(XX,YY,ZZ); hold on;
% xlabel('X [m]'); ylabel('Y [m]'); zlabel('Cost function');
% for i=1:length(MappingPointsX)-1
%     R=RSSLocationXYObjFunc([MappingPointsX(i) MappingPointsY(i)],RSSmes,StationX,StationY,StationZ);
%     plot3(MappingPointsX(i),MappingPointsY(i),R,'*r');
% end

lb=[3 0]; ub=[42 9.8];
for i=1:RSSN
    RSSmes=RSS(i,:);
    [q,fval]=fmincon(@(Q)RSSLocationXYObjFunc(Q,RSSmes,StationX,StationY,StationZ),Qinit,[],[],[],[],lb,ub,[],options);
    LocationXY(i,:)=q;
    dx=MappingPointsX-q(1);
    dy=MappingPointsY-q(2);
    d=dx.*dx+dy.*dy;
    [w,MappingPointsInd(i)]=min(d);
end

% 
% MappingPointsZ=1.5;
% MappingPointsN=length(MappingPointsX);
% 
% %Creating the map
% RSSMap=zeros(MappingPointsN,StationN);
% RSSMapM=zeros(MappingPointsN,1);
% for i=1:MappingPointsN
%     for j=1:StationN
%         dx=MappingPointsX(i)-StationX(j);
%         dy=MappingPointsY(i)-StationY(j);
%         dz=MappingPointsZ-StationZ(j);
%         TagStationDist=sqrt(dx^2+dy^2+dz^2);
%         RSSMap(i,j)=DistToRSSI(TagStationDist);
%     end
%     RSSMapM(i)=mean(RSSMap(i,:));
% end
% % RSSMap=round(RSSMap*10)/10;
% % writetable(array2table(RSSMap),[DataFolder '\RSSDistMap.csv'],'WriteVariableNames',false,'Delimiter',';');
% 
% LocationProbability=zeros(RSSN,MappingPointsN);
% for i=1:RSSN
%     rss_i=RSS(i,:); rss_im=mean(rss_i);
%     for j=1:MappingPointsN
%         er_v=rss_i-rss_im-(RSSMap(j,:)-RSSMapM(j));
% %         er=sum((er_v).^2);
%         er=sum(abs(er_v));
% %         er=sum((rss_i-RSSMap(k,:)).^2);
%         LocationProbability(i,j)=1/er;
%     end
% end
% 
% %Viterbi filtering
% T=readtable([DataFolder '\PassageProbabilityMatrix.csv'],'Delimiter',';','ReadVariableNames',false);
% PP=table2array(T);
% MappingPointsInd=ViterbiCorrection(LocationProbability,PP);
% % [m,MappingPointsInd]=max(LocationProbability,[],2);
% 
% % %actual location filtering
% % X=MappingPointsX(MappingPointsInd);
% % Y=MappingPointsY(MappingPointsInd);
% % X=MovingAverage0(X,200,0);
% % Y=MovingAverage0(Y,200,0);
% % for i=1:RSSN
% %     dx=X(i)-MappingPointsX;
% %     dy=Y(i)-MappingPointsY;
% %     d=dx.*dx+dy.*dy;
% %     [m,k]=min(d);
% %     MappingPointsInd(i)=k;
% % end
% 
% % MappingPointsInd=DiscreteFilterWindowPartial(MappingPointsInd,15,0.3);%,TstampRSS,seconds(5)
% % MappingPointsInd=DiscreteFilterWindowPartial(MappingPointsInd,15,0.4);%,TstampRSS,seconds(5)
% % MappingPointsInd=DiscreteFilterWindowPartial(MappingPointsInd,10,0.3,TstampRSS,seconds(5));
% % MappingPointsInd=DiscreteFilterWindowPartial(MappingPointsInd,150,0.3,TstampRSS,seconds(5));
