function DrawHeatMap(DataFolder,Prob)
[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo,ConstructionsXY]=ReadBarnSystemStructure(DataFolder);
hold on;
Prob=Prob/max(Prob);
% Prob=sqrt(sqrt(Prob));
Prob=sqrt(Prob);
[Prob,q]=sort(Prob,'ascend');
for i=1:length(Prob)
    plot(MappingPointsX(q(i)),MappingPointsY(q(i)),'.','color',[Prob(i)*0 Prob(i)*0.6+0.4 Prob(i)*0],'MarkerSize',45);
end
for i=1:length(ConstructionsXY)
    plot([ConstructionsXY(i,1) ConstructionsXY(i,3)],[ConstructionsXY(i,2) ConstructionsXY(i,4)],'k','linewidth',1);
end
xlabel('X [m]'); ylabel('Y [m]');