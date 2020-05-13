#Processing of the files with raw Ruuvi data achieved from the recieving stations
#Synchronization of the data from different recieving stations.
#Separation of RSS and acceleration data to different files
#INPUT:
# Files with name RuuviData_Tag*TagNo*_2020-02-12-*HourNo*.csv
#contaning data during 1  in the specific date hour collected for the tag TagNo by all the recieving stations
#OUTPUT:
# Files with name RSSData_Tag*TagNo*_2019-12-12.csv
#contaning list of available RSS samplings recorded by all the recieving
#stations for the tag TagNo in the specific date
# Files with name AccData_Tag*TagNo*_2019-12-12.csv
#contaning list of available acceleration samplings for the tag TagNo in the specific date
using DelimitedFiles, Base, Plots, Dates, Statistics#, StatsBase, DataFrames#, Clustering
include("DataProcLib.jl")
clearconsole()
DataFolder="D:/CowBhaveData/Data_Exp30_01_2020"
ProcessedRawDataFolder="RawData"
#inspectdr()#gr()#plotly()

FileList=cd(readdir, DataFolder)
AccSamplesInSendingPacket=5

global DatesList=Array{String}(undef, length(FileList))
n=0
for File_i=1:length(FileList)
    global n
    global DatesList
    FileName=FileList[File_i]
    if occursin("RuuviData_Tag",FileName)
        k=findlast('_',FileName)
        n=n+1
        DatesList[n]=FileName[(k+1):(k+10)]
    end
end
DatesList=DatesList[1:n]
DatesList=unique(DatesList)

for CurDate_i=1:length(DatesList)
    global CurDate
    CurDate=DatesList[CurDate_i]
    for TagNo_i=1:25
        TagNo_=TagNo_i#TagNoList[TagNo_i]
        global Tstamp_Raw, StationNo_Raw, TagNo_Raw, RSS_Raw, MessageNo_Raw, Tstring_Raw, Acc_Raw, r
        Tstamp_Raw=Array{DateTime}(undef,0); StationNo_Raw=Array{Int32}(undef,0); TagNo_Raw=Array{Int32}(undef,0); RSS_Raw=Array{Int32}(undef,0); MessageNo_Raw=Array{Int64}(undef,0); Acc_Raw=Array{Int32}(undef, 0,15); Tstring_Raw=Array{String}(undef,0);
        TagNoStr=string(TagNo_)
        global MessageNo_prev, j
        for File_i=1:length(FileList)
            FileName=FileList[File_i]
            if occursin(string("Tag",TagNoStr,"_"),FileName) && occursin(CurDate,FileName) && occursin("RuuviData_Tag",FileName)
                println(FileName)
                (ts,sn,tn,r,mn,a)=ReadRuuviDataCSV(string(DataFolder, "/", FileName))
                global Tstamp_Raw=[Tstamp_Raw; ts]
                global StationNo_Raw=[StationNo_Raw; sn]
                global TagNo_Raw=[TagNo_Raw; tn]
                global RSS_Raw=[RSS_Raw; r]
                global MessageNo_Raw=[MessageNo_Raw; mn]
                global Acc_Raw=[Acc_Raw; a]
                if ProcessedRawDataFolder!=""
                    mv(string(DataFolder, "/", FileName),string(DataFolder, "/", ProcessedRawDataFolder, "/", FileName))
                end
            end
        end
        if isempty(Tstamp_Raw)
            println(string("No data for Tag ",TagNo_))
            continue;
        end

        StationNo=findmax(StationNo_Raw)[1]
        N=length(MessageNo_Raw)
        (MessageNoMin,qMessageNoMin)=findmin(MessageNo_Raw)
        (MessageNoMax,q)=findmax(MessageNo_Raw)
        if MessageNoMax-MessageNoMin>10000000
            dn=0
            for i=2:N
                MessageNo_Raw[i]=MessageNo_Raw[i]+dn
                if abs(MessageNo_Raw[i]-MessageNo_Raw[i-1])>1000000
                    MessageNo_Raw[i]=MessageNo_Raw[i]-dn
                    dn=MessageNo_Raw[i-1]-MessageNo_Raw[i]+1
                    MessageNo_Raw[i]=MessageNo_Raw[i]+dn
                end
            end
            (MessageNoMin,qMessageNoMin)=findmin(MessageNo_Raw);
            (MessageNoMax,q)=findmax(MessageNo_Raw);
        end
        DataN=0
        MN=MessageNoMax-MessageNoMin+1

        StationN=unique(StationNo_Raw)
        RSS=zeros(Int32, MN, findmax(StationN)[1])
        MessageNo=zeros(Int32,MN)
        TstampStation=Array{DateTime}(undef, MN, 10)
        Tstring=Array{String}(undef, MN)
        TagNo=Array{Int32}(undef, MN)
        Acc_Raw1=Array{Int32}(undef, MN, AccSamplesInSendingPacket*3)
        h=Dates.hour.(Tstamp_Raw)
        m=Dates.minute.(Tstamp_Raw)
        s=Dates.second.(Tstamp_Raw)
        ms=Dates.millisecond.(Tstamp_Raw)
        TstampValue_Raw=ms+s.*1000 .+m.*1000*60 .+h.*1000*60*60
        TstampValue_Raw=TstampValue_Raw./(1000*60*60*24)

        for i=1:N
            k=MessageNo_Raw[i]-MessageNoMin+1
            RSS[k,StationNo_Raw[i]]=RSS_Raw[i]
            MessageNo[k]=MessageNo_Raw[i]
            TagNo[k]=TagNo_Raw[i]
            Acc_Raw1[k,:]=Acc_Raw[i,:]
        end

        MessageNoNo=collect(1:MN)
        (s,r2)=Regression(MessageNo_Raw.-MessageNoMin.+1,TstampValue_Raw)#.-CurDateValue
        k0=s[1]
        k1=s[2]
        TstampValue=k0.+MessageNoNo.*k1

        TstampValue=trunc.(Int,TstampValue.*(1000*60*60*24))
        ms=TstampValue.%1000
        TstampValue=TstampValue.÷1000
        s=TstampValue .% 60
        TstampValue=TstampValue.÷60
        m=TstampValue .% 60
        TstampValue=TstampValue.÷60
        h=TstampValue
        y=h.*0 .+Dates.year(DateTime(CurDate))
        mo=h.*0 .+Dates.month(DateTime(CurDate))
        d=h.*0 .+Dates.day(DateTime(CurDate))
        q=h.>=24
        d[q]=d[q].+Dates.day(1)
        h[q].=0
        Tstamp=DateTime.(y,mo,d,h,m,s,ms)
        TstampStr=Dates.format.(Tstamp, "yyyy-mm-ddTHH:MM:SS.sss")

        q=MessageNo.!=0
        RSS=RSS[q,:]
        MessageNo=MessageNo[q]
        TstampStr=TstampStr[q]
        TagNo=TagNo[q]
        Acc_Raw1=Acc_Raw1[q,:]
        MN=sum(q)

        writedlm(string(DataFolder, "/RSSData_Tag",TagNoStr,"_",CurDate,".csv"), [TagNo MessageNo TstampStr RSS], ',')

        Acc=Array{Int32}(undef, MN*AccSamplesInSendingPacket, 3)
        MessageNoAcc=Array{Float32}(undef, MN*AccSamplesInSendingPacket)

        j=0
        for i=1:MN
            for k=1:AccSamplesInSendingPacket
                global j=j+1
                i
                Acc[j,1]=Acc_Raw1[i,3*k-2]
                Acc[j,2]=Acc_Raw1[i,3*k-1]
                Acc[j,3]=Acc_Raw1[i,3*k]
                MessageNoAcc[j]=MessageNo[i]+(k-1)/AccSamplesInSendingPacket
            end
        end
        TstampAccValue=k0.+(MessageNoAcc.-MessageNoMin.+1).*k1
        TstampAccValue=trunc.(Int,TstampAccValue.*(1000*60*60*24))
        ms=TstampAccValue.%1000
        TstampAccValue=TstampAccValue.÷1000
        s=TstampAccValue .% 60
        TstampAccValue=TstampAccValue.÷60
        m=TstampAccValue .% 60
        TstampAccValue=TstampAccValue.÷60
        h=TstampAccValue
        y=h.*0 .+Dates.year(DateTime(CurDate))
        mo=h.*0 .+Dates.month(DateTime(CurDate))
        d=h.*0 .+Dates.day(DateTime(CurDate))
        q=h.>=24
        d[q]=d[q].+Dates.day(1)
        h[q].=0
        Tstamp=DateTime.(y,mo,d,h,m,s,ms)
        TstampStr=Dates.format.(Tstamp, "yyyy-mm-ddTHH:MM:SS.sss")

        writedlm(string(DataFolder, "/AccData_Tag",TagNoStr,"_",CurDate,".csv"), [TstampStr Acc], ',')
    end
end
