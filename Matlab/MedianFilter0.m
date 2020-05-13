function Afiltered=MedianFilter0(A,WindowSize,Zer)
N=length(A);
Afiltered=zeros(N,1);

w=sort(A(1:2*WindowSize));
% TimeInt=1:2*WindowSize;
% [w,q]=sort(A(1:2*WindowSize));
% SortingInd=q;
% TimeInt=TimeInt(q);
Afiltered(1)=w(WindowSize);

for i=2:WindowSize
    w=sort(A(1:i+WindowSize));
    n=sum(w~=Zer);
    if n~=0
        Afiltered(i)=w(ceil(n/2));
    else
        Afiltered(i)=Afiltered(i-1);
    end
%     Afiltered(i)=w(ceil((i+WindowSize)/2));
end

for i=WindowSize+1:N-WindowSize-1
    w=sort(A(i-WindowSize:i+WindowSize));
    n=sum(w~=Zer);
    if n~=0
        Afiltered(i)=w(ceil(n/2));
    else
        Afiltered(i)=Afiltered(i-1);
    end
%     Afiltered(i)=w(WindowSize);
end

for i=N-WindowSize:N
    w=sort(A(i-WindowSize:N));
    n=sum(w~=Zer);
    if n~=0
        Afiltered(i)=w(ceil(n/2));
    else
        Afiltered(i)=Afiltered(i-1);
    end
%     Afiltered(i)=w(ceil((N-i+WindowSize)/2));
end