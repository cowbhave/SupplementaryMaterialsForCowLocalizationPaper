function [CowNo,CowTag,CowDaysN,CowDays]=ReadTagCowNoFitting(DataFolder,FileName,CollarTag)
T=readtable([DataFolder '\' FileName],'Delimiter',';','ReadVariableNames',false);
CowNo=zeros(200,1);
CowTag=zeros(200,1);
CowDays=strings(200,10);
CowDaysN=zeros(200,1);
CowN=0;

[n,m]=size(T);
for i=2:n
    tag=table2array(T(i,1));
    if mod(tag,2)~=CollarTag
        continue;
    end
    for j=2:m
        cn=str2double(table2array(T(i,j)));
        if ~isnan(cn)
            k=InList(CowNo,CowN,cn);
            if CowN<k
                CowN=CowN+1;
                CowNo(CowN)=cn;
                CowTag(CowN)=tag;
                k=CowN;
            end
            CowDaysN(k)=CowDaysN(k)+1;
            CowDays(k,CowDaysN(k))=string(table2array(T(1,j)));
        end
    end
end

CowNo=CowNo(1:CowN);
CowTag=CowTag(1:CowN);
CowDaysN=CowDaysN(1:CowN);
CowDays=CowDays(1:CowN,:);