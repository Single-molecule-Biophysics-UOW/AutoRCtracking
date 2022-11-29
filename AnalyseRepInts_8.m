% Step 8 of automatic analysis of RC replication. 
% Requires folder "Molecules" containing data produced from MeasureRepInts_7.ijm
% Calculates corrected intensities


SMInt= XXX; %insert measured intensity of single-molecule

Mainfolder=cd('Molecules');
names=dir ('Molecule*'); 
names = {names.name};
names=natsort(names);
for s=1:length(names)
    oldFolder = cd(names{s}); 
    Int{s}=dlmread('Intensity.xls','\t',1,0);
    bg{s}=dlmread('BgInt.xls','\t',1,0);
    traj{s}=dlmread('Trajectory.xls','\t',1,0);
    cd(oldFolder)
end

cd(Mainfolder);

int={};
constant=0.83;%% constant for correcting background (5*5/11*5-5*5)
for k=1:length(names)
    N(k,:)=size(bg{k},1);
    frames(k,:)=size(traj{k},1);
    f=frames(k,:);
    int{k}(:,1)=[0:f];
    int{k}(:,2:7)=[0];
end
for s=1:length(names)
    for i=1:N(s,:)
        bg{s}(i,6)=bg{s}(i,2)-Int{s}(i,2);
        bg{s}(i,7)=bg{s}(i,6)*constant;
        Int{s}(i,6)=Int{s}(i,2)-bg{s}(i,7);
        Int{s}(i,7)=Int{s}(i,6)/SMInt;
        track=find(int{s}(:,1)==Int{s}(i,5));
        int{s}(track,2:end)=Int{s}(i,2:end);  
        int{s}(:,4)=s-1;
        int{s}(:,5)=int{s}(:,1);
    end
end

ConcatInt=[];
for t=1:length(names)
    ConcatInt=vertcat(ConcatInt,int{t}); 
end

header={'row','IntDen','RawIntDen','trajectory','slice','corrected_Int','nRep'}; 
filename=('RepIntensities.xls');
txt=sprintf('%s\t',header{:});
txt(end)='';
dlmwrite(filename,txt,''); 
dlmwrite(filename,ConcatInt,'-append','delimiter','\t'); 

%%Plot
numfigs=ceil(length(names)/6); % The number of figures needed
%open all empty figures
 for f=1:numfigs
    fig=figure('Name', ['figure ' num2str(f)]);
 end

figcounter=1; %counter to keep track of figure number
splot=1; %counter to keep track of subplot number
for t=1:length(names)
    fignum=floor(figcounter);
    figure(fignum)
    subplot(3,2,splot);
    track=find(ConcatInt(:,4)==t-1);
    plot(ConcatInt(track,1),ConcatInt(track,7))
    Min=(min(ConcatInt(track,7)))-1;
    Max=(max(ConcatInt(track,7)))+1;
    ylim([Min Max])
    text=num2str(t-1);
    L=legend(text);
    xlabel('Time (frames)');
    ylabel('# Rep');
    %After 15 subplots, change to new figure and reset splot to 1.
    if splot<6
        splot=splot+1;
    else
        set(gcf,'position',[-1300 100 1020 840]);
        splot=1;
        figcounter=figcounter+1;
    end
end
set(gcf,'position',[-1300 100 1020 840]);

