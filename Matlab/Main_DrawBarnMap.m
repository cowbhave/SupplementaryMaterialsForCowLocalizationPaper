%Draw barn map, Fig 2 (a)
DataFolder='E:\CowBhaveData\Data_Exp08_11_2019';
DrawBarnMap(DataFolder);
DataFolder='E:\CowBhaveData\Data_Exp30_01_2020';
% DrawBarnMap(DataFolder);
[num,txt]=xlsread([DataFolder '\BarnSystemStructure.csv']);
q1=find(txt(:,1)=="PI_Stations");
q2=find(txt(:,1)=="Constructions");
q6=find(txt(:,1)=="Location_Points");

StationX=num(q1:(q2-2),2);
StationY=num(q1:(q2-2),3);
StationN=num(q1:(q2-2),1);

MappingPointsX=num(q6:end,2);
MappingPointsY=num(q6:end,3);

Px=[2.8 2.8 4 7.7 7.7 3.8 3.8 2.8];
Py=[4.7 3.6 2.5 2.5 7 7 5.1 4.7];

patch(Px,Py,[1 1 0],'FaceAlpha',0.3);

plot(StationX,StationY,'*b','MarkerSize',6);

n=length(MappingPointsX)-1;
plot(MappingPointsX(1:n),MappingPointsY(1:n),'r*','MarkerSize',2);
% for i=1:n
% %     if MappingPointsY(i)>ymax
%         text(MappingPointsX(i),MappingPointsY(i),num2str(i),'color',[0 0.3 0.5],'FontSize',5,'HorizontalAlignment','center','VerticalAlignment','top');
% %     else
% %         text(MappingPointsX(i)+dx*0.00,MappingPointsY(i),num2str(i),'color',[0 0.3 0.5],'FontSize',5,'HorizontalAlignment','center','VerticalAlignment','bottom');
% %     end
% end

