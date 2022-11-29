% Step 6 of automatic analysis of RC replication. 
% Requires folder "Molecules" containing data produced from GetRepInts_5.ijm
% Tests colocalization with replication fork and saves those ROIs 

Mainfolder=cd('Molecules');
names=dir ('Molecule*'); 
names = {names.name};
names=natsort(names);
Slice={};
THy=10;
THx=5;
RepColoc={};
for s=1:length(names)
    Molfolder=cd(names{s});
    DNAROI=dlmread('Trajectory.xls','\t',1,0);
    Slicefolder=cd('Slice');  
    Names=dir('Slice_*');
    Names={Names.name};
    Names=natsort(Names);
    Slice=cell(1,numel(Names));
    for i=1:numel(Names)
        filename=Names{i};
        T=readtable(filename); 
        n=size(T,1);
        if n==0
           continue 
        else 
           Slice{i}=table2array(T(:,4:7)); 
        end
    end
    for r=1:length(DNAROI) 
           track=Slice{r};
        if isempty(track) 
           track=NaN; 
           RepColoc{r}=NaN;
        else 
           track(:,5)=r;
           for t=1:size(track,1) 
               Coloc(t,1)=((abs((DNAROI(r,1)-10)-track(t,2)))<THy|(abs((DNAROI(r,1)-10)-track(t,2)))==THy);
               Coloc(t,2)=((abs(DNAROI(r,4)-track(t,1)))<THx|(abs(DNAROI(r,4)-track(t,1)))==THx);
               RC=find(Coloc(:,1)==1 & Coloc(:,2)==1);
               RepColoc{r}=track(RC,:);
               for idx = 1:numel(RepColoc) 
                   RepColoc(cellfun(@isempty, RepColoc)) = {nan};
               end
           end 
           Coloc=[];
         end 
    end 
    %  % delete cells containing NaN - Rep ROIs not coloc 
    f = @(x) any(isnan(x));
    B = cellfun(f, RepColoc,'UniformOutput',false);
    C = cellfun(@all,B);
    RepColoc(:,C) = [];
    Repcoloc=cell2mat(RepColoc'); 
    %Save Rep ROIs in main mol folder 
    cd(Slicefolder)
    header={'X','Y','Width','Height','slice'}; 
    filename=('RepColoc.xls');
    txt=sprintf('%s\t',header{:});
    txt(end)='';
    dlmwrite(filename,txt,''); 
    dlmwrite(filename, Repcoloc, '-append','delimiter','\t');
    cd(Molfolder);
end 

cd(Molfolder);
cd(Mainfolder);