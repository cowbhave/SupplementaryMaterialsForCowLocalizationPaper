function DrawBarnMap(DataFolder)%,HeatMap
AddNumbers=0;
[num,txt]=xlsread([DataFolder '\BarnSystemStructure.csv']);
q1=find(txt(:,1)=="PI_Stations");
q2=find(txt(:,1)=="Constructions");
q3=find(txt(:,1)=="Feeding_Stations");
q4=find(txt(:,1)=="Water_Stations");
q5=find(txt(:,1)=="Milking_Robot");
q6=find(txt(:,1)=="Location_Points");

StationX=num(q1:(q2-2),2);
StationY=num(q1:(q2-2),3);
% StationZ=num(q1:(q2-2),4);
StationN=num(q1:(q2-2),1);

MappingPointsX=num(q6:end,2);
MappingPointsY=num(q6:end,3);

ConstrX1=num(q2:(q3-2),1);
ConstrY1=num(q2:(q3-2),2);
ConstrX2=num(q2:(q3-2),3);
ConstrY2=num(q2:(q3-2),4);

FeedingStationX=num(q3:(q4-2),2);
FeedingStationY=num(q3:(q4-2),3);
FeedingStationNo=num(q3:(q4-2),4);
WaterStationX=num(q4:(q5-2),2);
WaterStationY=num(q4:(q5-2),3);
WaterStationNo=num(q4:(q5-2),4);
MilkingRobotX1=num(q5:(q6-2),1);
MilkingRobotY1=num(q5:(q6-2),2);
MilkingRobotX2=num(q5:(q6-2),3);
MilkingRobotY2=num(q5:(q6-2),4);

xmax=max(StationX);
xmin=min(StationX);
ymax=max(StationY);
ymin=min(StationY);
dx=xmax-xmin;
dy=ymax-ymin;
figure;
hold on; axis equal;
xlabel('X [m]'); ylabel('Y [m]');
axis([-0.5 xmax+1.5 ymin-0.5 ymax+2]);
for i=1:length(ConstrX1)
    plot([ConstrX1(i) ConstrX2(i)],[ConstrY1(i) ConstrY2(i)],'k','linewidth',2);
end
patch([MilkingRobotX1 MilkingRobotX1 MilkingRobotX2 MilkingRobotX2],[MilkingRobotY1 MilkingRobotY2 MilkingRobotY2 MilkingRobotY1],[0.7 0.7 0.8]);

for i=1:length(FeedingStationX)
    patch(FeedingStationX(i)+[-0.5 0.5 0.5 -0.5],FeedingStationY(i)+[0 0 1 1],[0 1 0]);
    if AddNumbers
        text(FeedingStationX(i),FeedingStationY(i),num2str(FeedingStationNo(i)),'FontSize',7,'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
end
for i=1:length(WaterStationX)
    patch(WaterStationX(i)+[-0.5 0.5 0.5 -0.5],WaterStationY(i)+[0 0 1 1],[66 165 245]/256);
    if AddNumbers
        text(WaterStationX(i),WaterStationY(i),num2str(WaterStationNo(i)),'FontSize',7,'HorizontalAlignment','center','VerticalAlignment','bottom');
    end
end

% if ~isempty(HeatMap)
%     dx=0.5; dy=1;
%     XPoly=[dx dx -dx -dx];
%     YPoly=[dy -dy -dy dy];
%     HeatMap=log(HeatMap+1);
%     HeatMap=HeatMap/max(HeatMap);
%     for i=1:length(MappingPointsX)-1
%         patch(MappingPointsX(i)+XPoly,MappingPointsY(i)+YPoly,[0 1 0],'FaceAlpha',HeatMap(i),'EdgeColor','none');
%     end
% end

plot(StationX,StationY,'.b','MarkerSize',20);
if AddNumbers
    for StationNo=1:length(StationX)
        if StationY(StationNo)>ymin+dy/8
            text(StationX(StationNo),StationY(StationNo),num2str(StationN(StationNo)),'FontSize',12,'color','blue','HorizontalAlignment','right','VerticalAlignment','middle');
        else
            text(StationX(StationNo),StationY(StationNo),num2str(StationN(StationNo)),'FontSize',12,'color','blue','HorizontalAlignment','right','VerticalAlignment','bottom');
        end
    end
end

n=length(MappingPointsX)-1;
plot(MappingPointsX(1:n),MappingPointsY(1:n),'r.','MarkerSize',4);
if AddNumbers
    for i=1:n
        if MappingPointsY(i)>ymax
            text(MappingPointsX(i)+dx*0.00,MappingPointsY(i),num2str(i),'color',[0 0.3 0.5],'FontSize',6,'HorizontalAlignment','center','VerticalAlignment','top');
        else
            text(MappingPointsX(i)+dx*0.00,MappingPointsY(i),num2str(i),'color',[0 0.3 0.5],'FontSize',6,'HorizontalAlignment','center','VerticalAlignment','bottom');
        end
    end
end

axis tight;
set(gcf,'Position',[50 300 700 300]);

% saveas(gcf,'BarnMap.png');
% saveas(gcf,'BarnMap.pdf');
print([DataFolder '\BarnMap'],'-dpng','-r1000');