function AFiltered=MovingAverage0(A,WindowSize,Zer)
% Applying the moving average filter in window 2*WindowSize.
% Doesn't take into account the undefined values Zer.
n=length(A);
AFiltered=zeros(n,1);
if n<=2*WindowSize
    AFiltered(:)=mean(A);
    return;
end

WindowSum=0;
WindowN=0;
for i=1:(1+WindowSize)
    if A(i)~=Zer
        WindowSum=WindowSum+A(i);
        WindowN=WindowN+1;
    end
end

if WindowN~=0
    AFiltered(1)=WindowSum/WindowN;
else
    AFiltered(1)=Zer;
end

for i=2:WindowSize
    if A(i+WindowSize)~=Zer
        WindowSum=WindowSum+A(i+WindowSize);
        WindowN=WindowN+1;
    end
    if WindowN~=0
        AFiltered(i)=WindowSum/WindowN;
    else
        AFiltered(i)=AFiltered(i-1);
    end
end

for i=(WindowSize+1):(n-WindowSize-1)
    if A(i+WindowSize)~=Zer
        WindowSum=WindowSum+A(i+WindowSize);
        WindowN=WindowN+1;
    end
    if A(i-WindowSize)~=Zer
        WindowSum=WindowSum-A(i-WindowSize);
        WindowN=WindowN-1;
    end
    if WindowN~=0
        AFiltered(i)=WindowSum/WindowN;
    else
        AFiltered(i)=AFiltered(i-1);
    end
end

for i=(n-WindowSize):n
    if A(i-WindowSize)~=Zer
        WindowSum=WindowSum-A(i-WindowSize);
        WindowN=WindowN-1;
    end
    if WindowN~=0
        AFiltered(i)=WindowSum/WindowN;
    else
        AFiltered(i)=AFiltered(i-1);
    end
end