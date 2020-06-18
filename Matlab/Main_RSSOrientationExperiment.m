%% Processing of data from the RSS orientation experiment
% % Fig. 8 a

DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration\Orient_28-04-2020';
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

StationList=unique(StationNo_Raw);
TagList=[1 6 12];% Tags participated in the RSS-propagation experiment
Theta=[zeros(8,1)+0; zeros(8,1)+45; zeros(8,1)+90; zeros(8,1)+135];
Phi=0:45:315; Phi=Phi'; Phi=repmat(Phi,4,1);
RSS_M=zeros(length(StationList)*length(TagList),length(Theta));
RSS_MM=zeros(length(Theta),1);

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
% % Fig. 8 a
figure; hold on; xlabel('\phi [deg]'); ylabel('RSS [dB]');
RSS_MM=mean(RSS_M,1);
% for Theta_i=1:4
%     plot([Phi(1:8); 360],RSS_M(:,(Theta_i-1)*8+[1:8 1]),'color',cc1(Theta_i,:));
% end

BoxW=3;
BoxFaceAlpha=0.5;
WhiskersColor=[0.5 0.5 0.5];
for Orient_i=1:length(Theta)
    q=ts(Orient_i)<=Tstamp_Raw & Tstamp_Raw<=te(Orient_i);
    rss=RSS_Raw(q);
%     RSS_MM(Orient_i)=mean(rss);
    n=length(rss);
    rss=sort(rss); BoxPlotParam=[rss(floor(n*0.5)) rss(floor(n*0.25)) rss(floor(n*0.75)) rss(floor(n*0.05)+1) rss(floor(n*0.95))];
    x=Phi(Orient_i)+7*ceil(Orient_i/8)-15;
    plot(x+[BoxW -BoxW],BoxPlotParam(1)+[0 0],'color',cc(ceil(Orient_i/8),:),'LineWidth',3);
    patch(x+[BoxW BoxW -BoxW -BoxW],[BoxPlotParam(2) BoxPlotParam(3) BoxPlotParam(3) BoxPlotParam(2)],cc(ceil(Orient_i/8),:),'FaceAlpha',BoxFaceAlpha);
    plot(x+[0 0],[BoxPlotParam(2) BoxPlotParam(4)],'--','color',WhiskersColor);
    plot(x+[BoxW -BoxW]/2,BoxPlotParam(4)+[0 0],'color',WhiskersColor,'LineWidth',2);
    plot(x+[0 0],[BoxPlotParam(3) BoxPlotParam(5)],'--','color',WhiskersColor);
    plot(x+[BoxW -BoxW]/2,BoxPlotParam(5)+[0 0],'color',WhiskersColor,'LineWidth',2);
end

for Theta_i=1:4
    p(Theta_i)=plot([Phi(1:8); 360],RSS_MM((Theta_i-1)*8+[1:8 1]),'color',cc(Theta_i,:),'LineWidth',3);
end
legend(p,ThetaT);
set(gcf,'Position',[100 200 320 300]);
xlim([-20 360]); ylim([-75 -50]);
disp(['Maximal average deviation is ' num2str(max(max(RSS_MM)-min(RSS_MM))) 'dB']);
disp(['Maximal deviation for a specific tag is ' num2str(max(max(RSS_M)-min(RSS_M))) 'dB']);

%% Processing of data from the RSS orientation experiment in the barn
% % Fig. 8 b
DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\TagStationCalibration\BarnOrient_16_06_2020';
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
ts=datetime(2020,6,16,9,29,00):seconds(75):datetime(2020,6,16,10,23,45); ts=ts(1:4*8)';
ts(9:end)=ts(9:end)+seconds(10*60+30);
ts(11:end)=ts(11:end)+seconds(1*60+30);
ts(17:end)=ts(17:end)+seconds(1*60+0);
ts(25:end)=ts(25:end)+seconds(2*60+0);
te=datetime(2020,6,16,9,30,00):seconds(75):datetime(2020,6,16,10,23,45); te=te(1:4*8)';
te(9:end)=te(9:end)+seconds(10*60+30);
te(11:end)=te(11:end)+seconds(1*60+30);
te(17:end)=te(17:end)+seconds(1*60+0);
te(25:end)=te(25:end)+seconds(2*60+0);

ts(1:8)=ts(8:-1:1); te(1:8)=te(8:-1:1);

StationList=unique(StationNo_Raw);
TagList=[1 3 5 15 18 24];% Tags participated in the RSS-propagation experiment
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
            j=Orient_i;
            if StationList(Station_i)==6
                j=j+4; m=ceil(Orient_i/8)*8;
                if j>m
                    j=j-m;
                end
            end
            w=ts(j)<=Tstamp & Tstamp<=te(j);
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
% % Fig. 8 b
figure; hold on; xlabel('\phi [deg]'); ylabel('RSS [dB]');
RSS_MM=mean(RSS_M,1);
% for Theta_i=1:4
%     plot([Phi(1:8); 360],RSS_M(:,(Theta_i-1)*8+[1:8 1]),'color',cc1(Theta_i,:));
% end

BoxW=3;
BoxFaceAlpha=0.5;
BoxColor=[0 0 1; 0 0.5 1; 1 0.5 0]; BoxColor=repmat(BoxColor,10,1);
WhiskersColor=[0.5 0.5 0.5];

for Orient_i=1:length(Theta)
    q=ts(Orient_i)<=Tstamp_Raw & Tstamp_Raw<=te(Orient_i);
    rss=RSS_Raw(q);
%     RSS_MM(Orient_i)=mean(rss);
    n=length(rss);
    rss=sort(rss); BoxPlotParam=[rss(floor(n*0.5)) rss(floor(n*0.25)) rss(floor(n*0.75)) rss(floor(n*0.05)+1) rss(floor(n*0.95))];
    x=Phi(Orient_i)+7*ceil(Orient_i/8)-15;
    plot(x+[BoxW -BoxW],BoxPlotParam(1)+[0 0],'color',cc(ceil(Orient_i/8),:),'LineWidth',3);
    patch(x+[BoxW BoxW -BoxW -BoxW],[BoxPlotParam(2) BoxPlotParam(3) BoxPlotParam(3) BoxPlotParam(2)],cc(ceil(Orient_i/8),:),'FaceAlpha',BoxFaceAlpha);
    plot(x+[0 0],[BoxPlotParam(2) BoxPlotParam(4)],'--','color',WhiskersColor);
    plot(x+[BoxW -BoxW]/2,BoxPlotParam(4)+[0 0],'color',WhiskersColor,'LineWidth',2);
    plot(x+[0 0],[BoxPlotParam(3) BoxPlotParam(5)],'--','color',WhiskersColor);
    plot(x+[BoxW -BoxW]/2,BoxPlotParam(5)+[0 0],'color',WhiskersColor,'LineWidth',2);
end

for Theta_i=1:4
    p(Theta_i)=plot([Phi(1:8); 360],RSS_MM((Theta_i-1)*8+[1:8 1]),'color',cc(Theta_i,:),'LineWidth',3);
end
set(gcf,'Position',[500 200 320 300]);
legend(p,ThetaT);
xlim([-20 360]); ylim([-75 -50]);
disp(['Maximal average deviation is ' num2str(max(max(RSS_MM)-min(RSS_MM))) 'dB']);
disp(['Maximal deviation for a specific tag is ' num2str(max(max(RSS_M)-min(RSS_M))) 'dB']);
