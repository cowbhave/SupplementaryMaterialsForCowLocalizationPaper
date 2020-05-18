% Processing of data from the RSS propagation experiment
% Creating an averaged RSS propagation model
% % Fig. 8

DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration\Orient_28-04-2020';
% DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration\DistOrient_22-04-2020';
FileList=dir(DataFolder);
Tstamp_Raw=[]; StationNo_Raw=[]; TagNo_Raw=[]; RSS_Raw=[];
for File_i=1:length(FileList)
    FileName=FileList(File_i).name;
    if contains(FileName,'RuuviData_Tag')
        disp(FileName);
        [ts,sn,tn,r]=ReadRuuviDataRaspPiCSV([DataFolder '\' FileName]);%,tsr
        Tstamp_Raw=[Tstamp_Raw; ts];
        StationNo_Raw=[StationNo_Raw; sn];
        TagNo_Raw=[TagNo_Raw; tn];
        RSS_Raw=[RSS_Raw; r];
    end
end

% % Setting the measuring time
% Orient_28-04-2020
ts=datetime(2020,4,28,10,38,00):seconds(75):datetime(2020,4,28,11,28,00); ts=ts(1:4*8)';
ts(9:end)=ts(9:end)+seconds(3*60+30);
ts(17:end)=ts(17:end)+seconds(3*60+30);
ts(25:end)=ts(25:end)+seconds(3*60+30);
ts(26:end)=ts(26:end)+seconds(15);
te=datetime(2020,4,28,10,39,00):seconds(75):datetime(2020,4,28,11,29,00); te=te(1:4*8)';
te(9:end)=te(9:end)+seconds(3*60+30);
te(17:end)=te(17:end)+seconds(3*60+30);
te(25:end)=te(25:end)+seconds(3*60+30);
te(26:end)=te(26:end)+seconds(15);
% % DistOrient_22-04-2020
% ts=datetime(2020,4,22,12,25,30):seconds(75):datetime(2020,4,22,13,10,15); ts=ts(1:4*8)';
% ts(17:end)=ts(17:end)+seconds(6*60);
% te=datetime(2020,4,22,12,26,30):seconds(75):datetime(2020,4,22,13,11,15); te=te(1:4*8)';
% te(17:end)=te(17:end)+seconds(6*60);

StationList=unique(StationNo_Raw);
TagList=[1 6 12];% Tags participated in the RSS-propagation experiment
Theta=[zeros(8,1)+0; zeros(8,1)+45; zeros(8,1)+90; zeros(8,1)+135];
Phi=0:45:315; Phi=Phi'; Phi=repmat(Phi,4,1);
RSS_M=zeros(length(StationList)*length(TagList),length(Theta));

% % Extracting data for each tag-receiving station combination
TagNo=zeros(length(StationList)*length(TagList),1);
StationNo=zeros(length(StationList)*length(TagList),1);
k=0;
for Tag_i=1:length(TagList)
    for Station_i=1:length(StationList)
        q=StationNo_Raw==StationList(Station_i) & TagList(Tag_i)==TagNo_Raw;
        RSS=RSS_Raw(q);
        Tstamp=Tstamp_Raw(q);
        k=k+1;
        for Orient_i=1:length(Theta)
            w=ts(Orient_i)<=Tstamp & Tstamp<=te(Orient_i);
            rss=RSS(w);
            RSS_M(k,Orient_i)=mean(rss);
        end
        TagNo(k)=Tag_i;
        StationNo(k)=Station_i;
    end
end

ThetaT={'\theta=0','\theta=45°','\theta=90°','\theta=135°'};
cc=[1 0 0; 0 1 0; 0 0 1; 0 1 1];
cc1=[1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1; 0.5 1 1];

% % All tag-recieving station combinations and the total avereged line
% % Fig. 8
figure; hold on; xlabel('\phi [deg]'); ylabel('RSS [dB]');
RSS_MM=mean(RSS_M,1);
for Theta_i=1:4
    plot([Phi(1:8); 360],RSS_MM((Theta_i-1)*8+[1:8 1]),'color',cc(Theta_i,:),'LineWidth',3);
end
legend(ThetaT); axis tight;
for Theta_i=1:4
    plot([Phi(1:8); 360],RSS_M(:,(Theta_i-1)*8+[1:8 1]),'color',cc1(Theta_i,:));
end

% RSS_M=RSS_M-mean(RSS_M,2)*ones(1,8*4);
for Theta_i=1:4
%     plot(Phi(1:8),RSS_M(:,(Theta_i-1)*8+(1:8)),'color',cc1(Theta_i,:));
    plot([Phi(1:8); 360],RSS_MM((Theta_i-1)*8+[1:8 1]),'color',cc(Theta_i,:),'LineWidth',3);
%     text(Phi(Theta_i*2),RSS_MM((Theta_i-1)*8+Theta_i),ThetaT{Theta_i})
end
legend(ThetaT); axis tight;
% ylim([-70 -45]);
xlim([0 360]);
set(gcf,'Position',[50+50*Theta_i 200 320 300]);

% ThetaPhiRSSMap=zeros(8,5);
% for i=1:4
%     ThetaPhiRSSMap(i,:)=RSS_MM((i-1)*8+[3 2 1 8 7]);
%     ThetaPhiRSSMap(i+4,:)=RSS_MM((i-1)*8+[3 4 5 6 7]);
% end
% writetable(array2table(ThetaPhiRSSMap),[DataFolder '\RSSDirectionMap.csv'],'WriteVariableNames',false,'Delimiter',';');

% % Averaged RSS achieved from all 3 tags 
figure; hold on;
Theta_i=3;
STD=zeros(length(TagList),1);
for Tag_i=1:length(TagList)
    q=TagNo==Tag_i;
    plot(Phi(1:8),mean(RSS_M(q,(Theta_i-1)*8+(1:8))),'color',cc(Theta_i,:));
    STD(Tag_i)=mean(std(RSS_M(q,(Theta_i-1)*8+(1:8))));
%     plot(Dist,mean(RSS_M(q,:))+std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Dist,mean(RSS_M(q,:))-std(RSS_M(q,:)),'-.','LineWidth',1);
end
plot(Phi(1:8),RSS_MM((Theta_i-1)*8+(1:8)),'color',cc(Theta_i,:),'LineWidth',3);
disp(['STD=' num2str(mean(STD))]);
ylim([-70 -45]);
set(gcf,'Position',[50 100 320 300]);
xlabel('\phi [deg]'); ylabel('RSS [dB]');

% % Averaged RSS achieved from all 10 receiving stations 
figure; hold on;
Theta_i=3;
STD=zeros(length(TagList),1);
for Station_i=1:length(StationList)
    q=StationNo==Station_i;
    plot(Phi(1:8),mean(RSS_M(q,(Theta_i-1)*8+(1:8))),'color',cc(Theta_i,:));
    STD(Station_i)=mean(std(RSS_M(q,(Theta_i-1)*8+(1:8))));
%     plot(Dist,mean(RSS_M(q,:))+std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Dist,mean(RSS_M(q,:))-std(RSS_M(q,:)),'-.','LineWidth',1);
end
plot(Phi(1:8),RSS_MM((Theta_i-1)*8+(1:8)),'color',cc(Theta_i,:),'LineWidth',3);
disp(['STD=' num2str(mean(STD))]);
ylim([-70 -45]);
set(gcf,'Position',[150 100 320 300]);

% for k=1:length(StationNo)
%     RSS_Orient=reshape(RSS_M(k,:),8,4)';
%     plot(Phi(1:8),RSS_Orient(Theta_i,:));
% end
% % plot(Phi(1:8),RSS_Orient);
% % legend('\theta=180','\theta=225','\theta=270','\theta=315');
% legend('S 1','S 2','S 3','S 4','S 5','S 6','S 7','S 8','S 9','S 10');
% set(gcf,'Position',[100 200 320 300]);
% axis tight; xlabel('\phi'); ylabel('RSS [dB]');

% % Rotation experiment
% Orient_28-04-2020
ts=datetime(2020,4,28,11,32,30):seconds(75):datetime(2020,4,28,11,46,00); ts=ts(1:8)';
ts(2:end)=ts(2:end)+seconds(30); ts(4:end)=ts(4:end)+seconds(60*2+30);
ts(6:end)=ts(6:end)+seconds(30); ts(8:end)=ts(8:end)+seconds(75);
te=datetime(2020,4,28,11,33,30):seconds(75):datetime(2020,4,28,11,47,00); te=te(1:8)';
te(2:end)=te(2:end)+seconds(30); te(4:end)=te(4:end)+seconds(60*2+30);
te(6:end)=te(6:end)+seconds(30); te(8:end)=te(8:end)+seconds(75);

TagList=[1 6 8 12];
Alpha=0:45:315; Alpha=Alpha';
RSS_M=zeros(length(StationList)*length(TagList),length(Alpha));
TagNo=zeros(length(StationList)*length(TagList),1);
StationNo=zeros(length(StationList)*length(TagList),1);
k=0;

for Tag_i=1:length(TagList)
    for Station_i=1:length(StationList)
        q=StationNo_Raw==StationList(Station_i) & TagList(Tag_i)==TagNo_Raw;
        RSS=RSS_Raw(q);
        Tstamp=Tstamp_Raw(q);
        k=k+1;
        for Orient_i=1:length(Alpha)
            w=ts(Orient_i)<=Tstamp & Tstamp<=te(Orient_i);
            rss=RSS(w);
            RSS_M(k,Orient_i)=mean(rss);
        end
        TagNo(k)=Tag_i;
        StationNo(k)=Station_i;
    end
end

%total line
figure; hold on;
plot(Alpha,RSS_M);
plot(Alpha,mean(RSS_M),'r','LineWidth',3);
% set(gcf,'Position',[500 200 320 300]);
axis tight; xlabel('\alpha [deg]'); ylabel('RSS [dB]');
set(gcf,'Position',[150 200 320 300]);

figure; hold on;
% title('Tag lines')
STD=zeros(length(TagList),1);
for Tag_i=1:length(TagList)
    q=TagNo==Tag_i;
    plot(Alpha,mean(RSS_M(q,:)),'LineWidth',1);
    STD(Tag_i)=mean(std(RSS_M(q,:)));
%     plot(Alpha,mean(RSS_M(q,:))+std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Alpha,mean(RSS_M(q,:))-std(RSS_M(q,:)),'-.','LineWidth',1);
end
plot(Alpha,mean(RSS_M),'r','LineWidth',3);
axis tight; xlabel('\alpha [deg]'); ylabel('RSS [dB]');
ylim([-82 -40]);
disp(['STD=' num2str(mean(STD))]);
set(gcf,'Position',[50 300 320 300]);

figure; hold on;
% title('Stations lines')
STD=zeros(length(StationList),1);
for Station_i=1:length(StationList)
    q=StationNo==Station_i;
    plot(Alpha,mean(RSS_M(q,:)),'LineWidth',1);
    STD(Station_i)=mean(std(RSS_M(q,:)));
%     plot(Alpha,mean(RSS_M(q,:))+std(RSS_M(q,:)),'-.','LineWidth',1);
%     plot(Alpha,mean(RSS_M(q,:))-std(RSS_M(q,:)),'-.','LineWidth',1);
end
plot(Alpha,mean(RSS_M),'r','LineWidth',3);
axis tight; xlabel('\alpha [deg]'); ylabel('RSS [dB]');
ylim([-82 -40]);
disp(['STD=' num2str(mean(STD))]);
set(gcf,'Position',[400 300 320 300]);
