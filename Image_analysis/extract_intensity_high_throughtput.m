% purpose: use mRNA localization (x,y) to extract the intensity in the
% region 5 pixel x 5 pixel around (x,y) in another channel
% Author: Yanyu Zhu
% Date: 7-27-2024
% batch process of many files
[filename,filepath]=uigetfile({'*.tif', 'Tiff File (*.tif)'}, 'Select a file','MultiSelect','on');  % select green channel
cd(filepath);
[filename_RNA_int,filepath]=uigetfile({'*.tif', 'Tiff File (*.tif)'}, 'Select mRNA file', filepath,'MultiSelect','on');  % select mRNA channel
[FileName_RNA, filepath] = uigetfile({'*.csv';'*.*'},'Open file', filepath,'MultiSelect','on'); % select mRNA localization 
%%
All_signal=[];
pixel=162.5; 
roi_size=5; 
%%
for k= 1: size(filename,2)
locs_mRNA = readtable([filepath, FileName_RNA{k}]); % read the mRNA locolization from ThunderStorm csv

tiff_info=imfinfo(filename{k});   % read the green channel
green_channel=imread(filename{k}, 1);
RNA_channel=imread(filename_RNA_int{k},1);

signal=nan(1,size(locs_mRNA,1));
for i = 1:size(locs_mRNA,1)
    xunit=locs_mRNA.x_nm_(i)/pixel;
    yunit=locs_mRNA.y_nm_(i)/pixel;
    col=floor(xunit)+1; 
    row=floor(yunit)+1;
    cropped_roi_RNA=RNA_channel(row-floor(roi_size/2): row+floor(roi_size/2),col-floor(roi_size/2):col+floor(roi_size/2));
    cropped_roi_green=green_channel(row-floor(roi_size/2): row+floor(roi_size/2),col-floor(roi_size/2):col+floor(roi_size/2));
    signal(i)=sum(sum(cropped_roi_green))/(roi_size.^2);
end

All_signal=[All_signal, signal];  % this is all the signals

end

figure
histogram(All_signal,50);
   
