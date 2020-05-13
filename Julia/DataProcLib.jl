function ComparisonWithLocationReference(MappingPointsInd,TstampRSS,TagNo,CurDate,DataFolder,Draw)
  A=readdlm(string(DataFolder,"/TagCowNoFittingRef.csv"),';')
  ExpDatesStr=Array{String}(A[1,2:end])
  Tags=Array{Int32}(A[2:end,1])
  global i=1
  while i<=length(ExpDatesStr) && ExpDatesStr[i]!=CurDate
    global i=i+1
  end
  global j=1
  while j<=length(Tags) && Tags[j]!=TagNo
    global j=j+1
  end
  if i>length(ExpDatesStr) || j>length(Tags)
    println(string("There is no this date in the file TagCowNoFitting.csv"))
    MappingPointsInd=[]
    MappingPointsIndRef=[]
    return
  else
    CowNo=A[j+1,i+1]
    if isempty(CowNo)
      println(string("There is no this date in the file TagCowNoFitting.csv"))
      MappingPointsInd=[]
      MappingPointsIndRef=[]
      return
    end
  end
  (StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo)=ReadBarnSystemStructure(DataFolder)
  MappingPointsN=length(MappingPointsX)

  MappingPointsIndRef=MappingPointsInd.*0

  CurDateTime=DateTime(CurDate,"yyyy-mm-dd")
  FeedersVideoShift=Dates.Second(-39)#'2019-12-05'
  RobotVideoShift=Dates.Second(16);#'2019-12-05'

  if Draw
    w1=scatter(TstampRSS,MappingPointsInd,dpi=1000, label="Calculated", markercolor=:blue, markersize = 3, markerstrokewidth=0, show = true)
    xlabel!("Time")
    ylabel!("Mapping point")
    offs=0.1
    display(w1)
  end

  FileName=string(DataFolder, "/", "FeedingData.csv")
  if isfile(FileName)
    (DateTimeStartRef, DateTimeEndRef, StationNo)=ReadReferenceFeedingData(FileName,CowNo,CurDateTime)
    DateTimeStartRef=DateTimeStartRef+FeedersVideoShift
    DateTimeEndRef=DateTimeEndRef+FeedersVideoShift
    for i=1:length(DateTimeStartRef)
        q=(DateTimeStartRef[i].<TstampRSS) .& (TstampRSS.<DateTimeEndRef[i])
        MappingPointsIndRef[q].=FeedingStationPointsNo[StationNo[i]]
        if i>1 && abs(StationNo[i]-StationNo[i-1])==0 && DateTimeStartRef[i]-DateTimeEndRef[i-1]<Dates.Second(120)
            q=(DateTimeEndRef[i-1].<TstampRSS) .& (TstampRSS.<DateTimeStartRef[i])
            MappingPointsIndRef[q].=FeedingStationPointsNo[StationNo[i]]
        end
    end
  else
    println(string("File ",FileName," does not exist"))
  end

  FileName=string(DataFolder, "/", "DrinkingData.csv")
  if isfile(FileName)
    (DateTimeStartRef, DateTimeEndRef, StationNo)=ReadReferenceFeedingData(FileName,CowNo,CurDateTime)
    DateTimeStartRef=DateTimeStartRef+FeedersVideoShift
    DateTimeEndRef=DateTimeEndRef+FeedersVideoShift
    for i=1:length(DateTimeStartRef)
        q=(DateTimeStartRef[i].<TstampRSS) .& (TstampRSS.<DateTimeEndRef[i])
        MappingPointsIndRef[q].=WaterStationPointsNo[StationNo[i]]
        if i>1 && abs(StationNo[i]-StationNo[i-1])==0 && DateTimeStartRef[i]-DateTimeEndRef[i-1]<Dates.Second(120)
            q=(DateTimeEndRef[i-1].<TstampRSS) .& (TstampRSS.<DateTimeStartRef[i])
            MappingPointsIndRef[q].=FeedingStationPointsNo[StationNo[i]]
        end
    end
  else
    println(string("File ",FileName," does not exist"))
  end

  FileName=string(DataFolder, "/", "MilkingData.csv")
  if isfile(FileName)
    (DateTimeStartRef, DateTimeEndRef)=ReadReferenceMilkingData(FileName,CowNo,CurDateTime)
    DateTimeStartRef=DateTimeStartRef+RobotVideoShift
    DateTimeEndRef=DateTimeEndRef+RobotVideoShift
    for i=1:length(DateTimeStartRef)
        q=(DateTimeStartRef[i].<TstampRSS) .& (TstampRSS.<DateTimeEndRef[i])
        MappingPointsIndRef[q].=147
    end
  else
    println(string("File ",FileName," does not exist"))
  end

  FileName=string(DataFolder, "/", "Reference_BodyPosition_",CurDate,".csv")
  if isfile(FileName)
    (DateTimeStartRef, DateTimeEndRef, StartPointRef, EndPointRef, BodyPositionStringRef)=ReadReferenceBodyPositionData(FileName,CowNo)
    for i=1:length(DateTimeStartRef)
      if DateTimeEndRef[i]-DateTimeStartRef[i]<Dates.Second(3)
        DateTimeEndRef[i]=DateTimeStartRef[i]+Dates.Second(3)
      end
      q=(DateTimeStartRef[i].<TstampRSS) .& (TstampRSS.<=DateTimeEndRef[i])
      if BodyPositionStringRef[i][1]=='L'
          MappingPointsIndRef[q].=StartPointRef[i]
      elseif BodyPositionStringRef[i][1]=='S'
          MappingPointsIndRef[q].=StartPointRef[i]
      elseif BodyPositionStringRef[i][1]=='W'
          MappingPointsIndRef[q].=StartPointRef[i]
      end
    end
  else
    println(string("File ",FileName," does not exist"))
  end

  qRef=MappingPointsIndRef.!=0
  if Draw
    w1=scatter!(TstampRSS[qRef[:,1]],MappingPointsIndRef[qRef].+offs,dpi=1000, label="Reference", markercolor=:red, markersize = 2, markerstrokewidth=0, show = true)
    display(w1)
  end

  MappingPointsInd=MappingPointsInd[qRef]
  MappingPointsIndRef=MappingPointsIndRef[qRef]
  if Draw
    X=MappingPointsX[MappingPointsInd]
    Xref=MappingPointsX[MappingPointsIndRef]
    Y=MappingPointsY[MappingPointsInd]
    Yref=MappingPointsY[MappingPointsIndRef]
    dx=Xref-X
    dy=Yref-Y
    d=sqrt.(dx.^2+dy.^2)
    n=sum(qRef)
    println("Location accuracy");
    println("<0.5m ", Trunc(sum(d.<0.5)/n*100,4), "%")
    println("<1m ", Trunc(sum(d.<1)/n*100,4), "%")
    println("<2m ", Trunc(sum(d.<2)/n*100,4), "%")
    println("<3m ", Trunc(sum(d.<3)/n*100,4), "%")
    println("<5m ", Trunc(sum(d.<5)/n*100,4), "%")
    println("Mean accuracy ", Trunc(mean(d),4), "m")
  end

  return MappingPointsInd,MappingPointsIndRef
end

# function CreatePassageProbabilityMatrix(FileName)
#   (StationX,StationY,StationZ,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo,ConstructionsXY)=ReadBarnSystemStructure(DataFolder)
#
#   MappingPointN=length(MappingPointsX)
#   PointLongTerm=vcat(1:25,51:61,75:84,147,141,138,144,212:235)
#   PointLongTermInd=zeros(Int32,MappingPointN)
#   PointLongTermInd[PointLongTerm]=1
#   global ObstacleN
#   [ObstacleN,w]=size(ConstructionsXY)
#   Pobst=0.000
#   PP=zeros(Float64,MappingPointN).+Pobst
#
#   PointN=length(PointX)
#   DistMatr=Array{Float64}(undef,PointN,PointN)
#   for i=1:MappingPointN
#     global ObstacleN
#     for j=i+1:MappingPointN
#       global ObstacleN
#       dXY=sqrt((MappingPointsX[i]-MappingPointsX[j])^2+(MappingPointsY[i]-MappingPointsY[j])^2)
#       f=false
#       k=1
#       while !f && k<=ObstacleN
#         f=f || IntervalIntersection(MappingPointsX[i],MappingPointsY[i],MappingPointsX[j],MappingPointsY[j],ConstructionsXY[k,1],ConstructionsXY[k,2],ConstructionsXY[k,3],ConstructionsXY[k,4])
#         k=k+1
#       end
#       if !f
#         if dXY<4
#           PP[i,j]=1/dXY
#           PP[j,i]=1/dXY
#         end
#       end
#     end
#     if PointLongTerm[i]==1
#       PP[i,i]=50
#     else
#       PP[i,i]=5
#     end
#   end
#
#   s=";"
#   for i=1:PointN
#     s=string(s,i,";")
#   end
#   s=string(s,"\r\n")
#   for i=1:PointN
#     s=string(s,i,";")
#     for j=1:PointN
#       s=string(s,Trunc(PP[i,j],2),";")
#     end
#     s=string(s,"\r\n")
#   end
#   io = open(string(DataFolder,"/PassageProbabilityMatrix.csv"), "w")
#   println(io, s)
#   close(io)
# end

function DecreaseSignalFrequency(RSS,TstampRSS,n)
  (RSSN,StationN)=size(RSS)
  n2=ceil(Int,n/2)
  RSSN=floor(Int,RSSN/n)
  for i=1:RSSN
      RSS[i,:]=mean(RSS[1+(i-1)*n:i*n,:],dims=1)
      TstampRSS[i]=TstampRSS[i*n-n2]
  end
  RSS=RSS[1:RSSN,:];
  TstampRSS=TstampRSS[1:RSSN]

  return RSS,TstampRSS
end

function DistToRSSI(D)
  n=0.84
  A0=-48.77
  # RSS=[-10*n*log(d)+A0 for d in D]
  RSS=-10*n*log.(D)+A0
  return RSS
end

function DrawRSS(TstampRSS,RSS,New)
  N=size(RSS)
  if length(N)==1
    n=N
    m=1
  else
    (n,m)=size(RSS)
  end
  q=RSS[:,1].!=0
  r=RSS[q,1]
  if New==1
    w1=scatter([TstampRSS[1]],[r[1]],reuse=false,label="",dpi=1000,xlabel="T [min]",ylabel="RSS [dB]")
  end

  for i=1:m
    q=RSS[:,i].!=0
    w1=scatter!(TstampRSS[q],RSS[q,i],label="", markerstrokewidth=0, show = true)#string(i)
    annotate!([(TstampRSS[q][1],RSS[q,i][1], string(i),20)])
  end
  # display(w1)
end

function KalmanFilter1D(z,t_DateTime,Qk)
  if isempty(z)
    return Array{Float32}(undef,0);
  end
  ni=findmin([100 trunc(Int32,length(z)/10)])[1]
  t=Dates.value.(t_DateTime)/1000
  x_prev=[mean(z[1:ni]); 0]
  # F=[1.0 Dates.value(t_DateTime[2]-t_DateTime[1])/1000; 0 1];
  F=[1.0 t[2]-t[1]; 0 1];
  B=[0.0; 0.0]; u=0.0; Q=[1.0 0.0; 0.0 1.0]*Qk;
  H=[1.0 0]; R=1;
  P_prev=[1.0 0; 0 1];
  x=Array{Float32}(undef, length(z), 2);
  for i=1:length(z)-1
    x_pred=F*x_prev+B*u
    P_pred=F*P_prev*F'+Q

    K=P_pred*H'/(H*P_pred*H'.+R)
    x_upd=x_pred+K*(z[i].-H*x_pred)
    P=P_pred-K*H*P_pred
    x[i,:]=x_upd
    x_prev=x_upd
    P_prev=P
    # F[1,2]=Dates.value(t_DateTime[i+1]-t_DateTime[i])/1000
    F[1,2]=t[i+1]-t[i]
  end
  x[length(z),:]=x[length(z)-1,:]
  x1=x[:,1]
  return x1
end

function MedianFilter(A,WindowSize)
    N=length(A)
    Afiltered=zeros(Float32,N,1)

    for i=1:WindowSize
        w=sort(A[1:i+WindowSize])
        Afiltered[i]=w[ceil(Int32,(i+WindowSize)/2)]
    end

    for i=WindowSize+1:N-WindowSize-1
        w=sort(A[i-WindowSize:i+WindowSize])
        Afiltered[i]=w[WindowSize]
    end

    for i=N-WindowSize:N
        w=sort(A[i-WindowSize:N])
        Afiltered[i]=w[ceil(Int32,(N-i+WindowSize)/2)]
    end

    return Afiltered
end

function MovingAverage0(A,WindowSize,Zer)
  n=length(A)
  AFiltered=Array{Float64}(undef, n)
  if n<=2*WindowSize
      AFiltered.=mean(A)
      return AFiltered
  end

  WindowSum=0
  WindowN=0
  for i=1:(1+WindowSize)
      if A[i]!=Zer
          WindowSum=WindowSum+A[i]
          WindowN=WindowN+1
      end
  end

  AFiltered[1]=Zer
  for i=2:WindowSize
      if A[i+WindowSize]!=Zer
          WindowSum=WindowSum+A[i+WindowSize]
          WindowN=WindowN+1
      end
      if WindowN!=0
          AFiltered[i]=WindowSum/WindowN
      else
          AFiltered[i]=AFiltered[i-1]
      end
  end

  for i=(WindowSize+1):(n-WindowSize-1)
      if A[i+WindowSize]!=Zer
          WindowSum=WindowSum+A[i+WindowSize]
          WindowN=WindowN+1
      end
      if A[i-WindowSize]!=Zer
          WindowSum=WindowSum-A[i-WindowSize]
          WindowN=WindowN-1
      end
      if WindowN!=0
          AFiltered[i]=WindowSum/WindowN
      else
          AFiltered[i]=AFiltered[i-1]
      end
  end

  for i=(n-WindowSize):n
      if A[i-WindowSize]!=Zer
          WindowSum=WindowSum-A[i-WindowSize]
          WindowN=WindowN-1
      end
      if WindowN!=0
          AFiltered[i]=WindowSum/WindowN
      else
          AFiltered[i]=AFiltered[i-1]
      end
  end
  return AFiltered
end

function ReadBarnSystemStructure(DataFolder)
  A=readdlm(string(DataFolder, "/", "BarnSystemStructure.csv"),';')
  q1=findall(A[:,1].=="Feeding_Stations")
  q2=findall(A[:,1].=="Water_Stations")
  q3=findall(A[:,1].=="Milking_Robot")
  q4=findall(A[:,1].=="Location_Points")

  FeedingStationNo=Array{Int32}(A[q1[1]+1:q2[1]-1,4])
  PointsNo=Array{Int32}(A[q1[1]+1:q2[1]-1,1])
  FeedingStationPointsNo=zeros(Int32, findmax(FeedingStationNo)[1])
  FeedingStationPointsNo[FeedingStationNo]=PointsNo
  WaterStationNo=Array{Int32}(A[q2[1]+1:q3[1]-1,4])
  PointsNo=Array{Int32}(A[q2[1]+1:q3[1]-1,1])
  WaterStationPointsNo=zeros(Int32, findmax(WaterStationNo)[1])
  WaterStationPointsNo[WaterStationNo]=PointsNo
  MappingPointsX=Array{Float32}(A[q4[1]+1:end,2])
  MappingPointsY=Array{Float32}(A[q4[1]+1:end,3])
  MappingPointsN=length(MappingPointsX)
  q5=findall(A[:,1].=="PI_Stations")
  q6=findall(A[:,1].=="Constructions")
  StationX=Array{Float32}(A[q5[1]+1:q6[1]-1,2])
  StationY=Array{Float32}(A[q5[1]+1:q6[1]-1,3])
  StationZ=Array{Float32}(A[q5[1]+1:q6[1]-1,4])
  StationNo=Array{Int32}(A[q5[1]+1:q6[1]-1,1])
  ConstructionsXY=Array{Float32}(A[q6[1]+1:q1[1]-1,1:4])
  return StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo,ConstructionsXY
end

function ReadReferenceBodyPositionData(FileName,CowNo)
  A=readdlm(FileName,';')

  CowNoRef=Array{Int32}(A[2:end,1])
  DateTimeStartRef=DateTime.(A[2:end,2], "y-m-dTH:M:S")
  DateTimeEndRef=DateTime.(A[2:end,3], "y-m-dTH:M:S")
  BodyPositionStringRef=Array{String}(A[2:end,4])
  StartPointRef=Array{Int32}(A[2:end,5])
  EndPointRef=Array{Int32}(A[2:end,6])

  q=CowNoRef.==CowNo
  DateTimeStartRef=DateTimeStartRef[q]
  DateTimeEndRef=DateTimeEndRef[q]
  StartPointRef=StartPointRef[q]
  EndPointRef=EndPointRef[q]
  BodyPositionStringRef=BodyPositionStringRef[q]

  return DateTimeStartRef, DateTimeEndRef, StartPointRef, EndPointRef, BodyPositionStringRef
end

function ReadReferenceFeedingData(FileName,CowNo,CurDateTime)
  A=readdlm(FileName,';')

  CowNoRef=Array{Int32}(A[2:end,1])
  StationNo=Array{Int32}(A[2:end,2])
  DateTimeStartRef=DateTime.(A[2:end,3], "y-m-dTH:M:S")
  DateTimeEndRef=DateTime.(A[2:end,4], "y-m-dTH:M:S")

  q=(CowNoRef.==CowNo) .& (CurDateTime.<DateTimeStartRef) .& (DateTimeEndRef.<CurDateTime.+Dates.Day(1))
  StationNo=StationNo[q]
  DateTimeStartRef=DateTimeStartRef[q]
  DateTimeEndRef=DateTimeEndRef[q]

  return DateTimeStartRef,DateTimeEndRef,StationNo
end

function ReadReferenceMilkingData(FileName,CowNo,CurDateTime)
  A=readdlm(FileName,';')
  CowNoRef=Array{Int32}(A[2:end,1])
  DateTimeStartRef=DateTime.(A[2:end,5], "d.mm.yyyy H.MM.S")
  DateTimeEndRef=DateTime.(A[2:end,6], "d.mm.yyyy H.MM.S")

  q=(CowNoRef.==CowNo) .& (CurDateTime.<DateTimeStartRef) .& (DateTimeEndRef.<CurDateTime.+Dates.Day(1))
  DateTimeStartRef=DateTimeStartRef[q]
  DateTimeEndRef=DateTimeEndRef[q]

  return DateTimeStartRef,DateTimeEndRef
end

function ReadRSSData(FileName)
  if !isfile(FileName)
    println(string("File ",FileName," does not exist"))
    TstampRSS=[]; RSS=[]; MessageNo=[]
    return TstampRSS,RSS,MessageNo
  end
  A=readdlm(FileName,',')
  (n,k)=size(A)
  MessageNo=Array{Int32}(A[:,2])
  TstampRSS=DateTime.(A[:,3], "y-m-dTH:M:S.s")
  RSS=Array{Float32}(A[:,4:end])
  return TstampRSS,RSS,MessageNo
end

function InList(List,ListN,a)
  i=1
  while i<=ListN && List[i]!=a
      i=i+1
  end
  return i
end

function ReadTagCowNoFitting(DataFolder,CollarTag)
  T=readdlm(string(DataFolder,"/TagCowNoFittingRef.csv"),';')
  CowNo=zeros(Int32,200)
  CowTag=zeros(Int32,200)
  # CowDays=Array{Any}(0,200,20)
  CowDays=["" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" "";"" "" "" "" "" "" "" "" "" ""]
  CowDaysN=zeros(Int32,200)
  CowN=0

  (n,m)=size(T)
  for i=2:n
      tag=T[i,1]
      if (tag % 2) != CollarTag
          continue
      end
      for j=2:m
          cn=T[i,j]
          if cn!=""
              k=InList(CowNo,CowN,cn)
              if CowN<k
                  CowN=CowN+1
                  CowNo[CowN]=cn
                  CowTag[CowN]=tag
                  k=CowN
              end
              CowDaysN[k]=CowDaysN[k]+1
              CowDays[k,CowDaysN[k]]=T[1,j]
          end
      end
  end

  CowNo=CowNo[1:CowN]
  CowTag=CowTag[1:CowN]
  CowDaysN=CowDaysN[1:CowN]
  CowDays=CowDays[1:CowN,:]
  return CowNo,CowTag,CowDaysN,CowDays
end

function ReadRuuviDataCSV(FileName)
  if !isfile(FileName)
    println(string("File ",FileName," does not exist"))
    Tstamp=[]; StationNo=[]; TagNo=[]; RSS=[]; MessageNo=[]; Acc=[];
    return Tstamp,StationNo,TagNo,RSS,MessageNo,Acc
  end
  A=readdlm(FileName,',')
  StationNo=Array{Int32}(A[:,1])
  Tstamp=DateTime.(A[:,2], "y-m-dTH:M:S.s")
  TagNo=Array{Int32}(A[:,3])
  RSS=Array{Int32}(A[:,4])
  MessageNo=Array{Int32}(A[:,5])
  Acc=Array{Int32}(A[:,6:20])
  # Acc=zeros(Int32,length(MessageNo),15)
  # if k>=6#28
  #   # Points=Array{Int32}(A[:,28])
  #   Points=Array{Int32}(A[:,6])
  # else
  #   Points=MessageNo*0
  # end

  return Tstamp,StationNo,TagNo,RSS,MessageNo,Acc#,TstampRecieved
end

function Regression(X,y)
  if length(y)<3
    return 0,0
  end
  o=X[:,1].*0 .+1
  X=[o X]#ones(size(X))
  k=inv(X'*X)*X'*y
  yt=mean(y)
  SStot=sum((y.-yt).^2)
  f=X*k
  SSres=sum((f.-y).^2)
  r2=1-SSres/SStot
  return k,r2
end

function RSSLocation_XYMap(RSS,TstampRSS,DataFolder)
  (RSSN,StationN)=size(RSS)
  (StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY,FeedingStationPointsNo,WaterStationPointsNo)=ReadBarnSystemStructure(DataFolder)
  StationN=length(StationX)
  RSS=RSS[:,StationNo]
  MappingPointsZ=1.5
  MappingPointsN=length(MappingPointsX)
  RSSMap=zeros(Float32,MappingPointsN,StationN)
  RSSMapM=zeros(Float32,MappingPointsN)
  for i=1:MappingPointsN
      for j=1:StationN
          dx=MappingPointsX[i]-StationX[j]
          dy=MappingPointsY[i]-StationY[j]
          dz=MappingPointsZ-StationZ[j]
          TagStationDist=sqrt(dx^2+dy^2+dz^2)
          RSSMap[i,j]=DistToRSSI(TagStationDist)
      end
      RSSMapM[i]=mean(RSSMap[i,:])
  end

  LocationProbability=zeros(Float32,RSSN,MappingPointsN)
  for i=1:RSSN
    rss_i=RSS[i,:]
    rss_im=mean(rss_i)
    for j=1:MappingPointsN
      er_v=rss_i.-rss_im.-(RSSMap[j,:].-RSSMapM[j])
      # er_v=rss_i.-RSSMap[j,:]
      # er=sum(abs.(er_v))
      er=sum(er_v.*er_v)
      LocationProbability[i,j]=1/er
    end
  end

  A=readdlm(string(DataFolder, "/", "PassageProbabilityMatrix.csv"),';')
  PP=Array{Float32}(A)
  MappingPointsInd=ViterbiCorrection(LocationProbability,PP)
  # MappingPointsInd=zeros(Int32,RSSN)
  # for i=1:RSSN
  #   (m,MappingPointsInd[i])=findmin(LocationProbability[i,:])
  # end

  return MappingPointsInd,TstampRSS
end

function Trunc(a,n)
  if length(a)==1
    a=floor(a*10^n)/10^n
  else
    for i=1:length(a)
      a[i]=floor(a[i]*10^n)/10^n
    end
  end
  return a
end

function ViterbiCorrection(LP,PP)
  (n,StateN)=size(LP)
  CurrentStateVector=zeros(Float32,StateN)+LP[1,:]
  CurrentStateVectorUpdated=CurrentStateVector.*0
  PrevPoint=zeros(Int32,n,StateN);
  global CurrentStateVector
  for i=2:n
    global CurrentStateVector
    for j=1:StateN
      w=CurrentStateVector.*PP[:,j]
      (m,mind)=findmax(w)
      CurrentStateVectorUpdated[j]=m*LP[i,j]
      PrevPoint[i,j]=mind
    end
    CurrentStateVector=CurrentStateVectorUpdated./findmax(CurrentStateVectorUpdated)[1]
  end

  StateIndex=zeros(Int32,n,1);
  global mind
  (m,mind)=findmax(CurrentStateVector)
  StateIndex[n]=mind
  for i=(n-1):-1:1
    global mind
    StateIndex[i]=PrevPoint[i+1,mind]
    mind=PrevPoint[i+1,mind]
  end

   return StateIndex
end
