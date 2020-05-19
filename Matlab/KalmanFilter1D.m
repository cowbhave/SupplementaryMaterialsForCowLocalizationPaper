function x=KalmanFilter1D(z,t_DateTime,Qk)
if isempty(z)
	x=0;
    return;
end
ni=min(100,floor(length(z)/10));
t=(datenum(t_DateTime)-floor(datenum(t_DateTime(1))))*24*60*60;
x_prev=[mean(z(1:ni)); 0];
% # F=[1.0 Dates.value(t_DateTime[2]-t_DateTime[1])/1000; 0 1];
F=[1.0 t(2)-t(1); 0 1];
B=[0.0; 0.0]; u=0.0; Q=[1.0 0.0; 0.0 1.0]*Qk;
H=[1.0 0]; R=1;
P_prev=[1.0 0; 0 1];
x=zeros(length(z),2);
for i=1:length(z)-1
    if z(i)~=0
        x_pred=F*x_prev+B*u;
        P_pred=F*P_prev*F'+Q;
        
        K=P_pred*H'/(H*P_pred*H'+R);
        x_upd=x_pred+K*(z(i)-H*x_pred);
        P=P_pred-K*H*P_pred;
        x(i,:)=x_upd;
        x_prev=x_upd;
        P_prev=P;
        F(1,2)=t(i+1)-t(i);
    else
        if i>5
            [b,k]=LinRegression(t(i-5:i-1),x(i-5:i-1,1),0,0);
            x(i,1)=k*t(i)+b;
            [b,k]=LinRegression(t(i-5:i-1),x(i-5:i-1,2),0,0);
            x(i,2)=k*t(i)+b;
%             x(i,1)=interp1(t(i-5:i-1),x(i-5:i-1,1),t(i),'spline','extrap');
%             x(i,2)=interp1(t(i-5:i-1),x(i-5:i-1,2),t(i),'spline','extrap');
        else
            x(i,:)=x_prev;
        end
    end
end
x(length(z),:)=x(length(z)-1,:);
x=x(:,1);