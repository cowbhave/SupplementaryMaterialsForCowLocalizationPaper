function StateIndex=ViterbiCorrection(LP,PP)%location prob, passage prob
[n,StateN]=size(LP);
CurrentStateVector=zeros(StateN,1)+LP(1,:)';
CurrentStateVectorUpdated=CurrentStateVector*0;
PrevPoint=zeros(n,StateN);
for i=2:n
    for j=1:StateN
        w=CurrentStateVector.*PP(:,j);
        [m,mind]=max(w);
        CurrentStateVectorUpdated(j)=m*LP(i,j);
        PrevPoint(i,j)=mind;
    end
    CurrentStateVector=CurrentStateVectorUpdated/max(CurrentStateVectorUpdated);
end

StateIndex=zeros(n,1);
[m,mind]=max(CurrentStateVector);
StateIndex(n)=mind;
for i=(n-1):-1:1
    StateIndex(i)=PrevPoint(i+1,mind);
    mind=PrevPoint(i+1,mind);
end
