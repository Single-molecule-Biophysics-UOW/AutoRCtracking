% Step 4 of automatic analysis of RC replication. 
% Requires folder "Molecules" containing data produced from LineProfiler_3.ijm

Threshold=0.5;

Mainfolder=cd('Molecules');
names=dir ('Molecule*'); 
names = {names.name};
names=natsort(names);
XPos={};
for s=1:length(names)
    Raw=[];
    Smooth=[];
    oldFolder = cd(names{s}); 
    Profile=dlmread('ProfileForXpos.xls','\t',1,0); 
    height=max(Profile(:,4));
    Window=3;
    for i=0:height;
        slice=find(Profile(:,4)==i);
        traj=Profile(slice,:);
        Raw(:,i+1)=Profile(slice,2);
        Smooth(:,i+1)=tsmovavg(Profile(slice,2),'s',Window,1); 
        Mean=mean(Smooth,2); 
        Max=max(Mean); 
        mid=find(Mean==Max); 
        if mid<10|mid>25  
           Max=max(Mean(10:25,:)); 
           mid=find(Mean==Max);
        end 
        del=isnan(Mean); 
        del=length(find(del==1));
        XPos{s}=mid-del;  
    end  
    cd(oldFolder)
end
cd(Mainfolder);

FOV=dlmread('Profiles.xls','\t',1,0);
Mainfolder=cd('Molecules');
Window=20; 
NumSlices=max(FOV(:,4));
NumTrajs=max(FOV(:,5));

Raw=[];
Smooth=[];
Mean=[];
Trajectories=[];
for t=0:NumTrajs
    Raw=[];
    Smooth=[];
    traj=find(FOV(:,5)==t);
    Traj=FOV(traj,:);
    for s=1:NumSlices
        slice=find(Traj(:,4)==s);
        Raw(:,s)=Traj(slice,2);
        Smooth(:,s)=tsmovavg(Traj(slice,2),'s',Window,1); 
    end

    Y=[]; % matrix for Y pos
    for s=1:NumSlices
        TH=[];
        Mean(t+1,1)=mean(mean(Smooth(end-10:end,:))); 
        Std(t+1,1)=2.5*std(std(Smooth(Window:end-Window,:))); 
        Thresh(t+1,1)=Mean(t+1,1)+Threshold*(Mean(t+1,1)+Std(t+1,1)); 
        TH=find(Smooth(:,s)>Thresh(1));  
        if isempty(TH)==1 && s<Window 
            Y(s,1)=Window;
        elseif isempty(TH)==1 
            Y(s,1)=Y(s-1); 
        else
            Y(s,1)=TH(end);  
        end
    end

    %3-level discrete Wavelet transform
    D=diff(Y); 
    Ynew=[];  
    Ynew2=[];
    Ynew3=[];
    Ds1(t+1)=std(diff(Y));  
    for s=1:NumSlices-1 
        if s==1     
            Ynew(1)=Y(1);  
        elseif s==2  
            Ynew(2)=Y(1);  
        elseif D(s)<std(D) && D(s)>-std(D)  
            Ynew(s)=Y(s); 
        else
            Ynew(s)=Y(s-2);
        end
    end
    Ynew(NumSlices)=Y(NumSlices); 
    
    Ds2(t+1)=std(diff(Ynew)); 
    D=diff(Ynew); 
    for s=1:NumSlices-1 
        if s==1 
            Ynew2(1)=Ynew(1);
        elseif s==2  
            Ynew2(2)=Ynew(1);
        elseif D(s)<std(D) && D(s)>-std(D) 
            Ynew2(s)=Ynew(s); 
        else
            Ynew2(s)=Ynew(s-2); 
        end
    end
    Ynew2(NumSlices)=Ynew(NumSlices); 
    
    Ds3(t+1)=std(diff(Ynew));  
    D=diff(Ynew2);  
    for s=1:NumSlices-1 
        if s==1  
            Ynew3(1)=Ynew2(1);
        elseif s==2 
            Ynew3(2)=Ynew2(1);
        elseif D(s)<std(D) && D(s)>-std(D) 
            Ynew3(s)=Ynew2(s); 
        else
            Ynew3(s)=Ynew2(s-2); 
        end
    end
    Ynew3(NumSlices)=Ynew2(NumSlices); 
    
    for s=1:Window 
        if Ynew3(s)==Window  
            Ynew3(s)=Ynew3(Window+1); 
        end
    end
    Ynew3=Ynew3';  
    Ynew3(:,2)=[0:1:length(Ynew3)-1]; 
    Ynew3(:,3)=t; 
    Ynew3(:,4)=XPos{t+1}; 
    Trajectories=vertcat(Trajectories,Ynew3); 
    
    
    oldFolder = cd(names{t+1}); 
    header={'y','slice','trajectory','x'}; 
    filename=('Trajectory.xls');
    txt=sprintf('%s\t',header{:});
    txt(end)='';
    dlmwrite(filename,txt,''); 
    dlmwrite(filename,Ynew3,'-append','delimiter','\t'); 
    cd(oldFolder);
end
cd(Mainfolder);
numfigs=ceil(NumTrajs/15); 

%open all empty figures
 for f=1:numfigs
    fig=figure('Name', ['figure ' num2str(f)]);
 end
    
figcounter=1; %counter to keep track of figure number
splot=1; %counter to keep track of subplot number
for t=1:NumTrajs+1
    fignum=floor(figcounter);
    figure(fignum)
    subplot(5,3,splot);
    traj=find(Trajectories(:,3)==t-1);
    plot(Trajectories(traj,2),Trajectories(traj,1))
    ylim([0 max(Trajectories(:,1))+10])
    text=num2str(t);
    L=legend(text);
    %After 15 subplots, change to new figure and reset splot to 1.
    if splot<15
        splot=splot+1;
    else
        splot=1;
        figcounter=figcounter+1;
    end
end

header={'y','slice','trajectory'}; %column names
filename=('Trajectories.xls');
txt=sprintf('%s\t',header{:});
txt(end)='';
dlmwrite(filename,txt,'');
dlmwrite(filename,Trajectories,'-append','delimiter','\t'); %write data

