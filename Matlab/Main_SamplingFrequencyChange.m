DataFolder='D:\CowBhaveData\Data_Exp08_11_2019';
SaveDataFolder='C:\Users\03138529\Desktop\DataForItaly';
% DataFolder='D:\CowBhaveData\Data_Exp30_01_2020';
TagVideoShift=seconds(5);%'2019-12-04', tag 17
% TagVideoShift=seconds(0);%'2020-01-30', tag 17
FeedersVideoShift=seconds(-39);%'2019-12-05'

[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo]=ReadBarnSystemStructure(DataFolder);

[CowNumber,CowTag,CowDaysN,CowDays]=ReadTagCowNoFitting(DataFolder,'TagCowNoFittingRef.csv',1);
% [n,t,dn,d]=ReadTagCowNoFitting(DataFolder,'TagCowNoFittingRef.csv',0);
% CowNumber=[CowNumber; n]; CowTag=[CowTag; t]; CowDaysN=[CowDaysN; dn]; CowDays=[CowDays; d];
% [CowNumber,q]=sort(CowNumber); CowTag=CowTag(q); CowDaysN=CowDaysN(q); CowDays=CowDays(q,:);

CowN=length(CowNumber);
TagN=max(CowTag);

TagNoPrev=0; Tag_i=0;
CollarTag=1;
for CowNo_i=1:CowN
    disp(CowNo_i);
    TagNo=CowTag(CowNo_i);
    
    Acc=[]; Ts=[];
    
    for Day_i=1:CowDaysN(CowNo_i)
        CurDate=char(CowDays(CowNo_i,Day_i));
        
        FileName=[DataFolder '\AccData_Tag' num2str(TagNo) '_' CurDate '.csv'];
        [TstampAcc, Acc1, Acc2, Acc3]=ReadAccData(FileName);
        [acc,ts]=DecreaseSignalFrequency([Acc1 Acc2 Acc3],TstampAcc,ceil(25/0.2));
        Acc=[Acc; acc];
        Ts=[Ts; ts];
    end
        TstampStr=datestr(Ts,'yyyy-mm-ddTHH:MM:ss.FFF');
        T=table(TstampStr,round(Acc));
        writetable(T,[SaveDataFolder '/AccDataCollar_Cow' num2str(CowNumber(CowNo_i)) '.csv'],'WriteVariableNames',false);

end
% save('LocalizationForPaperData','CowLocErrMean','CowLocErrStd','CumErr');
q=LocErrCowBoxPlotParam(:,1)~=0;
LocErrCowBoxPlotParam=LocErrCowBoxPlotParam(q,:); CowTag=CowTag(q); CowNumber=CowNumber(q);
CumErrTag=CumErrTag(q,:);
