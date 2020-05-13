function [a,b,R2]=LinRegression(x,y,OutlierErrorSigma,Draw) %en.wikipedia.org/wiki/Simple_linear_regression
xm=mean(x);
ym=mean(y);
Cov=mean(x.*y)-xm*ym;
Var=mean(x.^2)-mean(x)^2;
b=Cov/Var;
a=ym-b*xm;
R2=(Cov/sqrt(Var*(mean(y.^2)-mean(y)^2)))^2;
%y=a+b*x
if Draw
    hold on;
    plot(x,y,'.');
    plot([min(x) max(x)],a+b*[min(x) max(x)]);
    disp(['Line equation: y=' num2str(b) '+' num2str(a) ', R2=' num2str(R2)])
end
if OutlierErrorSigma~=0
    e=abs(a+b*x-y);
    s=mean(e);
    q=e<s*OutlierErrorSigma;
    x1=x(q);
    y1=y(q);
    [a,b,R2]=LinRegression(x1,y1,0,Draw);
end
