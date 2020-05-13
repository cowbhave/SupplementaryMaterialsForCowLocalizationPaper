function [v,f,Grouping]=ValueFrequency(A)
v=A*0;
vN=0;
f=A*0;
Grouping=A*0;
GroupN=A*0;
currentVal=-1; prev_j=1;
n=0;
for i=1:length(A)
    q=A(i);
    j=1;
    while j<=vN && q~=v(j)
        j=j+1;
    end
    if j>vN
        vN=vN+1;
        v(vN)=q;
        f(vN)=1;
    else
        f(j)=f(j)+1;
    end
    if currentVal==q
        n=n+1;
    else
        if n~=0
            GroupN(prev_j)=GroupN(prev_j)+1;
            Grouping(prev_j)=Grouping(prev_j)+n;
            n=0;
        end
        currentVal=q;
        prev_j=j;
    end
end
Grouping=(Grouping+1)./(GroupN+1);
[f,q]=sort(f(1:vN),'descend');
v=v(q);
Grouping=Grouping(q);