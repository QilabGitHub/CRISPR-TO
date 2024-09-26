% Author Yanyu Zhu 
% Date 4/12/2024
% purpose: to calculate the polarization index and dispersion index for
% mRNA or other puncta shape dots inside cell
[filename,filepath]=uigetfile({'*.tif', 'Tiff File (*.tif)'}, 'Select a file','MultiSelect','on');  % select tiff image file to get cell outline
cd(filepath);
[filename_RNA,filepath]=uigetfile({'*.csv', 'ThunderSTORM File (*.csv)'}, 'Select mRNA file', filepath,'MultiSelect','on'); % load the RNA information

for i= 1: size(filename,2)
I=imread([filepath '\' filename{i}]); % Read the image into a matrix.
stats = regionprops(imbinarize(I), 'Centroid');
centroid = stats.Centroid;
[row,col] = find(I); % Find the positions of non-zero pixels in the matrix.
pixel=162.5;
coord = pixel*([col,row]-0.5); % Col = x, Row = y
%[filename_cell,filepath]=uigetfile({'*.csv', 'centroid file (*.csv)'}, 'Select centroid file', filepath); % load the centroid information 
%centroid=readtable(filename_cell);
 RNA=readtable(filename_RNA{i});
RNA_x=nanmean(RNA.x_nm_);
RNA_y=nanmean(RNA.y_nm_);
% calculate Rg of the cell
distance = sqrt((col - centroid(1)).^2 + (row - centroid(2)).^2); % in pixel
Rg=sqrt(mean(distance.^2))*pixel; % Rg in nm

 %polarization index PI
PI=sqrt((RNA_x-centroid(1)*pixel).^2 + (RNA_y-centroid(2)*pixel).^2)./Rg;
 %dispersion index DI
u2_RNA= nanmean((RNA.x_nm_-RNA_x).^2+(RNA.y_nm_-RNA_y).^2);
u2_cell=nanmean((col*pixel-RNA_x).^2+(row*pixel-RNA_y).^2);
DI= u2_RNA/u2_cell;

All_PI(i)=PI;
All_DI(i)=DI;

end

