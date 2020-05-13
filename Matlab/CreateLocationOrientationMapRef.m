function CreateLocationOrientationMapRef(DataFolder)
T=readtable([DataFolder '\RSSDirectionMap.csv'],'Delimiter',';','ReadVariableNames',false);
ThetaPhiRSSMap=table2array(T);
[ThetaRSSMapN,PhiRSSMapN]=size(ThetaPhiRSSMap);
%Theta=[0 .. 315]:8, Phi=[-90 .. 90]:5

[StationX,StationY,StationZ,StationNo,MappingPointsX,MappingPointsY]=ReadBarnSystemStructure(DataFolder);
StationN=length(StationX);
MappingPointsN=length(MappingPointsX);

MappingPointsT1N=8;
MappingPointsT2N=MappingPointsT1N/2+1;
MappingPointsT3N=MappingPointsT1N;
T1=linspace(0,2*pi*(1-1/MappingPointsT1N),MappingPointsT1N);
T2=linspace(0,pi,MappingPointsT2N);%*(1-1/MappingPointsT2N)
T3=linspace(0,2*pi*(1-1/MappingPointsT3N),MappingPointsT3N);
MappingRSS=zeros(MappingPointsN*MappingPointsT1N*MappingPointsT2N*MappingPointsT3N,StationN);
MappingRSST2T3StartInd=zeros(MappingPointsT2N,MappingPointsT3N);
TagRSSDirectionNormalization=ThetaPhiRSSMap(1,floor(PhiRSSMapN/2)+1);
ThetaPhiRSSMap=ThetaPhiRSSMap-TagRSSDirectionNormalization;

MappingRSSN=0;
TagZ=1.5;
for T2_i=1:MappingPointsT2N
    TagT2=-T2(T2_i);
    Ry2=[cos(TagT2) 0 -sin(TagT2); 0 1 0; sin(TagT2) 0 cos(TagT2)];
    for T3_i=1:MappingPointsT3N
        TagT3=T3(T3_i);
        Rz3=[cos(TagT3) sin(TagT3) 0; -sin(TagT3) cos(TagT3) 0; 0 0 1];
        MappingRSST2T3StartInd(T2_i,T3_i)=MappingRSSN+1;
        for T1_i=1:MappingPointsT1N
            TagT1=T1(T1_i);
            Rz1=[cos(TagT1) sin(TagT1) 0; -sin(TagT1) cos(TagT1) 0; 0 0 1];
            T=Rz3*Ry2*Rz1;
            for MappingPointsN_i=1:MappingPointsN
                TagX=MappingPointsX(MappingPointsN_i);
                TagY=MappingPointsY(MappingPointsN_i);
                MappingRSSN=MappingRSSN+1;
%                 disp(MappingRSSN);
                for Station_i=1:StationN
                    TagStationVect=[StationX(Station_i)-TagX StationY(Station_i)-TagY StationZ(Station_i)-TagZ]';
                    TagStationDist=sqrt(TagStationVect(1)^2+TagStationVect(2)^2+TagStationVect(3)^2);
                    qRSS=T*TagStationVect./TagStationDist;%radiation direction in tag coordinates
                    t=atan2(qRSS(2),qRSS(1));
                    f=atan(qRSS(3)/sqrt(qRSS(1)^2+qRSS(2)^2));
                    if t<0; t=t+2*pi; end
                    t_i=round(t*(ThetaRSSMapN-1)/(7/4*pi))+1;
                    f_i=round((PhiRSSMapN-1)/pi*f+1+(PhiRSSMapN-1)/2);
                    if t_i==0; t_i=ThetaRSSMapN; end
                    if t_i==ThetaRSSMapN+1; t_i=1; end
                    if f_i==0; f_i=1; end
                    if f_i==PhiRSSMapN+1; f_i=PhiRSSMapN; end
                    RSS_Dist=DistToRSSI(TagStationDist);
                    DirDistFixingCoef=TagRSSDirectionNormalization/RSS_Dist;%direction deviation changes with the distance
                    RSSFix_TagDir=ThetaPhiRSSMap(t_i,f_i)*DirDistFixingCoef;%direction deviation
                    MappingRSS(MappingRSSN,Station_i)=RSS_Dist+RSSFix_TagDir;
                    if f_i<=1%assumed influence of cow body to the direction of the tag bottom
                        MappingRSS(MappingRSSN,Station_i)=MappingRSS(MappingRSSN,Station_i)-10;
                    end
%                     if f_i>1%floor(TagRSS_PhiTableN/2)+1%radiation upwards, not into cow body
%                         MappingRSS(MappingRSSN,Station_i)=RSS_Dist+RSSFix_TagDir;
%                     else%unknown influence of cow body to the direction of the tag bottom
%                         MappingRSS(MappingRSSN,Station_i)=-100;
%                     end
                end
            end
        end
    end
end

MappingRSS=round(MappingRSS*10)/10;
writetable(array2table(MappingRSS),[DataFolder '\RSSTriOrientMap.csv'],'WriteVariableNames',false,'Delimiter',';');
writetable(array2table(MappingRSST2T3StartInd),[DataFolder '\RSSTriOrientMapT2T3Start.csv'],'WriteVariableNames',false,'Delimiter',';');
