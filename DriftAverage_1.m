%step 1 in AUTO ANALYSIS of RC-bio replication rates. 
%Requires a table produced by ImageJ Finder, Fitter, Tracker plugin, named
%drift from DNA channel

Drift=dlmread('drift.csv',',',1,0); 
max=max(Drift(:,5))+1; 
for i=1:max
    traj=find(Drift(:,5)==i-1); 
    Drift(traj,6)=Drift(traj,2)-mean(Drift(traj,2)); 
    Drift(traj,7)=Drift(traj,3)-mean(Drift(traj,3)); 
    DS(i,1)=std(Drift(traj,6)); 
    DS(i,2)=std(Drift(traj,7));
end

Filt=find(DS(:,1)<1 & DS(:,2)<2); 
Xdrift=[];
Ydrift=[];
for j=1:length(Filt)-1 
    traj=find(Drift(:,5)==Filt(j))-1; 
    Xdrift(:,j)=Drift(traj,6);  
    Ydrift(:,j)=Drift(traj,7); 
end

meanDrift(:,1)=mean(Xdrift,2);  
meanDrift(:,2)=mean(Ydrift,2);

header={'x','y'}; 
filename=('avgDrift.xls'); 
txt=sprintf('%s\t',header{:}); 
txt(end)='';
dlmwrite(filename,txt,''); 
dlmwrite(filename,meanDrift,'-append','delimiter','\t'); 