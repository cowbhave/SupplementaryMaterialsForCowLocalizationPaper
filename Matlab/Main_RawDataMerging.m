%Processing of the files with raw Ruuvi data achieved from the recieving stations
%Synchronization of the data from different recieving stations.
%Separation of RSS and acceleration data to different files
%INPUT: 
% Files with name RuuviData_Tag*TagNo*_2020-02-12-*HourNo*.csv
%contaning data during 1  in the specific date hour collected for the tag TagNo by all the recieving stations
%OUTPUT: 
% Files with name RSSData_Tag*TagNo*_2019-12-12.csv
%contaning list of available RSS samplings recorded by all the recieving
%stations for the tag TagNo in the specific date
% Files with name AccData_Tag*TagNo*_2019-12-12.csv
%contaning list of available acceleration samplings for the tag TagNo in the specific date

% DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\Data_Exp08_11_2019';
% DataFolder='C:\Users\03138529\Desktop\CowBhave\DataAnalysis\Data_Exp30_01_2020';
% DataFolder='E:\CowBhave';
DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
ProcessedRawDataFolder='RawData';
% DatesList={'2019-11-08', '2019-11-09', '2019-11-10', '2019-11-20', '2019-11-21', '2019-11-22', '2019-11-27', '2019-11-28', '2019-11-29', '2019-12-04', '2019-12-05', '2019-12-06'};
% DatesList={'2019-11-20'};
% dd=datetime(2019,11,8,0,0,0):days(1):datetime(2019,12,17,0,0,0);
% DatesList=datestr(dd,'yyyy-mm-dd');
% CurDate='2019-12-05';
% CurDate='2020-01-30';
AccSamplesInSendingPacket=5;
FileList=dir(DataFolder);
DatesList=cell(10,1); n=0;
for File_i=1:length(FileList)
    FileName=FileList(File_i).name;
    if contains(FileName,'RuuviData_Tag')
        k=strfind(FileName,'_');
        n=n+1;
        DatesList{n}=FileName(k(2)+(1:10));
    end
end
DatesList=unique(DatesList);

for CurDate_i=1:length(DatesList)
    CurDate=string(DatesList(CurDate_i,:));
    for TagNo_i=1:25
        Tstamp_Raw=[]; StationNo_Raw=[]; TagNo_Raw=[]; RSS_Raw=[]; MessageNo_Raw=[]; Acc_Raw=[]; TstampRecieved_Raw=[];
        for File_i=1:length(FileList)
            FileName=FileList(File_i).name;
            if contains(FileName,['Tag' num2str(TagNo_i) '_']) && contains(FileName,'RuuviData_Tag') && contains(FileName,CurDate)
                disp(FileName);
                [ts,sn,tn,r,mn,a]=ReadRuuviDataCSV([DataFolder '\' FileName]);%,tsr
                Tstamp_Raw=[Tstamp_Raw; ts];
                StationNo_Raw=[StationNo_Raw; sn];
                TagNo_Raw=[TagNo_Raw; tn];
                RSS_Raw=[RSS_Raw; r];
                MessageNo_Raw=[MessageNo_Raw; mn];
                Acc_Raw=[Acc_Raw; a];
%                 TstampRecieved_Raw=[TstampRecieved_Raw; tsr];
%                 if ~isempty(ProcessedRawDataFolder)
%                     movefile([DataFolder '\' FileName],[DataFolder '\' ProcessedRawDataFolder '\' FileName]);
%                 end
            end
        end
        if isempty(Tstamp_Raw)
            disp(['No data for Tag ' num2str(TagNo_i)])
            continue;
        end

        StationNo=max(StationNo_Raw);
        N=length(MessageNo_Raw);
        [MessageNoMin,qMessageNoMin]=min(MessageNo_Raw);
        MessageNoMax=max(MessageNo_Raw);
        if MessageNoMax-MessageNoMin>10000000
            dn=0;
            for i=2:N
                MessageNo_Raw(i)=MessageNo_Raw(i)+dn;
                if abs(MessageNo_Raw(i)-MessageNo_Raw(i-1))>1000000
                    MessageNo_Raw(i)=MessageNo_Raw(i)-dn;
                    dn=MessageNo_Raw(i-1)-MessageNo_Raw(i)+1;
                    MessageNo_Raw(i)=MessageNo_Raw(i)+dn;
                end
            end
            [MessageNoMin,qMessageNoMin]=min(MessageNo_Raw);
            MessageNoMax=max(MessageNo_Raw);
        end
        DataN=0;
        MN=MessageNoMax-MessageNoMin+1;

        StationN=unique(StationNo_Raw);
        RSS=zeros(MN,StationNo);
        MessageNo=zeros(MN,1);
        TstampStation=NaT(MN,StationNo);
        Tstring=zeros(MN,1);
        TagNo=zeros(MN,1);
        Acc_Raw1=zeros(MN,AccSamplesInSendingPacket*3);
        TstampValue_Raw=datenum(Tstamp_Raw);
        CurDateValue=floor(TstampValue_Raw(10000));
%         TstampStationValue=zeros(MN,StationNo);

        for i=1:N
            k=MessageNo_Raw(i)-MessageNoMin+1;
            RSS(k,StationNo_Raw(i))=RSS_Raw(i);
            MessageNo(k)=MessageNo_Raw(i);
            TagNo(k)=TagNo_Raw(i);
%             if sum(abs(Acc_Raw(i,:)))~=0
                Acc_Raw1(k,:)=Acc_Raw(i,:);
%             end
        end

        MessageNoNo=(1:MN)';
        [k0,k1,R2]=LinRegression(MessageNo_Raw-MessageNoMin+1,TstampValue_Raw-CurDateValue,0,0);
        TstampValue=k0+MessageNoNo*k1+CurDateValue;
        TstampStr=datestr(TstampValue,'yyyy-mm-ddTHH:MM:ss.FFF');

        q=MessageNo~=0;
        RSS=RSS(q,:);
        MessageNo=MessageNo(q);
        TstampStr=TstampStr(q,:);
        TagNo=TagNo(q);
        Acc_Raw1=Acc_Raw1(q,:);
        MN=sum(q);
        T=table(TagNo,MessageNo,TstampStr,RSS);
        writetable(T,[DataFolder '/RSSData_Tag' num2str(TagNo_i) '_' char(CurDate) '.csv'],'WriteVariableNames',false);

        Acc=zeros(MN*AccSamplesInSendingPacket,3);
%         dt=1/24/60/60/25;%25Hz
%         TagNoAcc=zeros(MN*AccSamplesInSendingPacket,1);
        MessageNoAcc=zeros(MN*AccSamplesInSendingPacket,1);

        j=0;
        for i=1:MN
            for k=1:AccSamplesInSendingPacket
                j=j+1;
                Acc(j,1)=Acc_Raw1(i,3*k-2);
                Acc(j,2)=Acc_Raw1(i,3*k-1);
                Acc(j,3)=Acc_Raw1(i,3*k);
                MessageNoAcc(j)=MessageNo(i)+(k-1)/AccSamplesInSendingPacket;%*dt;
            end
        end
        TstampAccValue=k0+(MessageNoAcc-MessageNoMin+1)*k1+CurDateValue;
        TstampStr=datestr(TstampAccValue,'yyyy-mm-ddTHH:MM:ss.FFF');
        T=table(TstampStr,Acc);
        writetable(T,[DataFolder '/AccData_Tag' num2str(TagNo_i) '_' char(CurDate) '.csv'],'WriteVariableNames',false);
    end
end