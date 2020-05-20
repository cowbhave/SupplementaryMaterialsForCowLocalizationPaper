#Calculate tag location for a single tag for a single day and compare it with reference
#INPUT:
# File with name RSSData_Tag*_2020-02-12.csv
#contaning RSS from all stations for the tag Tag during a day
#OUTPUT:
# Graph with comparison and cumulative accuracy

using DelimitedFiles, Base, Plots, Dates, Statistics
include("DataProcLib.jl")
clearconsole()
DataFolder="D:/CowBhaveData/Data_Exp08_11_2019"
Draw=true
CurDate="2019-11-09"
# CurDate="2019-12-04"
# gr()
# plotly()
# inspectdr()
TagVideoShift=Dates.Second(3);#'2019-12-04', tag 17,6
# TagVideoShift=seconds(-2);%'2019-11-09', tag 1
FeedersVideoShift=Dates.Second(-39);#'2019-12-05'
RSSSamplingFequency=5;#Hz

TagNo=7
CollarTag=1
StartDateTime=string(CurDate, " 0:01:00");
EndDateTime=string(CurDate, " 23:59:00");

#Reading RSS data
FileName=string(DataFolder, "/", "RSSData_Tag",TagNo,"_",CurDate,".csv")
(TstampRSS1,RSS1,MessageNo1)=ReadRSSData(FileName)
TstampRSS=TstampRSS1; RSS=RSS1
TstampRSS=TstampRSS.+TagVideoShift
q=(DateTime(StartDateTime, "y-m-d H:M:S").<TstampRSS) .& (TstampRSS.<DateTime(EndDateTime, "y-m-d H:M:S"))
TstampRSS=TstampRSS[q]; RSS=RSS[q,:];

(n,StationNoN)=size(RSS);
w=ceil(Int,10*RSSSamplingFequency)
for i=1:StationNoN
    # RSS[:,i]=KalmanFilter1D(RSS[q,i],SamplingDateTime[q],0.0001)
    RSS[:,i]=MovingAverage0(RSS[:,i],w,0)
end
# DrawRSS(TstampRSS,RSS[:,1],1)
# DrawRSS(SamplingDateTime,RSS[:,[4,5,6]],1)
# DrawRSS(SamplingDateTime,RSS[:,[1,2,3,4,5,6,7,8,9]],1)

# CreateLocationOrientationMap(DataFolder)
# CreatePassageProbabilityMatrix(DataFolder)
(RSS,TstampRSS)=DecreaseSignalFrequency(RSS,TstampRSS,ceil(Int,5/0.2))
(MappingPointsInd,TstampRSS)=RSSLocation_XYMap(RSS,TstampRSS,DataFolder)
ComparisonWithLocationReference(MappingPointsInd,TstampRSS,TagNo,CurDate,DataFolder,true)
