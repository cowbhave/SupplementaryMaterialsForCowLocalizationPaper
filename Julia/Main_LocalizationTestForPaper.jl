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
Draw=false
# gr()
# plotly()
# inspectdr()
TagVideoShift=Dates.Second(3);#'2019-12-04', tag 17,6

(StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo)=ReadBarnSystemStructure(DataFolder)
(CowNumber,CowTag,CowDaysN,CowDays)=ReadTagCowNoFitting(DataFolder,1)
CowN=length(CowNumber)
CowLocErrMean=zeros(Float32,CowN)
CowLocErrStd=zeros(Float32,CowN)
CumErrVal=0:0.1:15
CumErr=zeros(Float32,CowN,length(CumErrVal))
CowPointFreqRef=zeros(Float32,CowN,length(MappingPointsY))
RefDurationCow=zeros(Float32,CowN);

CollarTag=1

for CowNo_i=1:CowN
    println(CowNo_i)
    TagNo=CowTag[CowNo_i]
    MappingPointsInd=[]
    MappingPointsIndRef=[]
    for Day_i=1:CowDaysN[CowNo_i]
        CurDate=CowDays[CowNo_i,Day_i]
        FileName=string(DataFolder, "/", "RSSData_Tag",TagNo,"_",CurDate,".csv")
        (TstampRSS,RSS)=ReadRSSData(FileName)
        TstampRSS=TstampRSS.+TagVideoShift
        (n,m)=size(RSS)
        if n==0
            continue
        end

        w=ceil(Int,10/0.2)
        for i=1:m
            RSS[:,i]=MovingAverage0(RSS[:,i],w,0)
            # RSS[:,i]=MedianFilter(RSS[:,i],w)
            # RSS[:,i]=KalmanFilter1D(RSS[:,i],TstampRSS,0.00001)
        end

        (RSS,TstampRSS)=DecreaseSignalFrequency(RSS,TstampRSS,ceil(Int,5/0.2))
        (MappingPointsInd_day,TstampRSS)=RSSLocation_XYMap(RSS,TstampRSS,DataFolder)
        (mi,mir)=ComparisonWithLocationReference(MappingPointsInd_day,TstampRSS,TagNo,CurDate,DataFolder,false)
        MappingPointsInd=[MappingPointsInd; mi]
        MappingPointsIndRef=[MappingPointsIndRef; mir]
    end
    X=MappingPointsX[MappingPointsInd]
    Xref=MappingPointsX[MappingPointsIndRef]
    Y=MappingPointsY[MappingPointsInd]
    Yref=MappingPointsY[MappingPointsIndRef]
    dx=Xref.-X
    dy=Yref.-Y
    d=sqrt.(dx.^2+dy.^2)
    CowLocErrMean[CowNo_i]=mean(d)
    CowLocErrStd[CowNo_i]=std(d)
    n=length(d)
    for j=1:length(CumErrVal)
        CumErr[CowNo_i,j]=sum(d.<CumErrVal[j])/n
    end
    RefDurationCow[i]=length(MappingPointsIndRef)*10;#sec

    for i=1:length(MappingPointsIndRef)
        CowPointFreqRef[CowNo_i,MappingPointsIndRef[i]]=CowPointFreqRef[CowNo_i,MappingPointsIndRef[i]]+1
    end
end

w1=scatter(1:CowN,CowLocErrMean,dpi=1000, label="", markercolor=:red, markersize = 2, markerstrokewidth=0, show = true)
display(w1)
println(string("Total mean error=",mean(CowLocErrMean),"[m]"))
println(string("Total mean std=",mean(CowLocErrStd),"[m]"))
println(string("Total reference time is ",sum(RefDurationCow/60/60/24),"days, average for cow is ",mean(RefDurationCow/60/60/24)))
