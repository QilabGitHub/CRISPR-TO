%clear;
% Author : Yanyu Zhu;
% calculate the RNA distribution, number of RNA puncta per cell, 
%clear;
PathName = fileparts(matlab.desktop.editor.getActiveFilename);
%[FileName_cell, PathName] = uigetfile({'*.csv';'*.*'},'Open cell center csv file', PathName);
[FileName_RNA, PathName] = uigetfile({'*.csv';'*.*'},'Open csv file', PathName,'MultiSelect','on');
cd(PathName);
T = {};
len=[];
cell = gThNDUFS2Centroid;  % change to name of your file
RNA_x=[]; % centroid of RNAx per cell
RNA_y=[]; % centroid of RNAy per cell
cell_x=table2array(cell(:,4))*pixel;
cell_y=table2array(cell(:,5))*pixel;
pixel= 162.5; % pixel in nm
for i = 1 :size(FileName_RNA,2)
    T{i} = readtable([PathName FileName_RNA{i}]);
    T{i} = table2array(T{i}(:,1:5));
    len(i)=size(T{i},1); 
    x=T{i}
    RNA_x(i)=nanmean(T{i}(:,3));
    RNA_y(i)=nanmean(T{i}(:,4));
  
end


%%
All_len=[];
%All_Rg=evalin('base','All_Rg');
for j=1:size(Rg,2)
     All_Rg=[All_Rg; Rg{j}];
end


