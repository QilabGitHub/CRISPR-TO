% Author: Yanyu Zhu 
% Date: 4/15/2024
% purpose: to calculate the polarization index and dispersion index for
% continuous mRNA (pixel based) inside cell
[filename,filepath]=uigetfile({'*.tif', 'Tiff File (*.tif)'}, 'Select a file','MultiSelect','on');  % select tiff image file to get cell outline
cd(filepath);
[filename_RNA,filepath]=uigetfile({'*.tif', 'Tiff File (*.tif)'}, 'Select mRNA file', filepath,'MultiSelect','on');  % select tiff image file to get RNA
%%
All_PI=[];
All_DI=[];
for i= 1: size(filename,2)
I=imread([filepath '\' filename{i}]); % Read the cell image into a matrix to get cell outline.
stats = regionprops(imbinarize(I), 'Centroid');
centroid = stats.Centroid;
[row,col] = find(I); % Find the positions of non-zero pixels in the matrix.
pixel=162.5;
%coord = pixel*([col,row]-0.5); % Col = x, Row = y
% calculate Rg of the cell
distance = sqrt((col - centroid(1)).^2 + (row - centroid(2)).^2); % in pixel
Rg=sqrt(mean(distance.^2))*pixel; % Rg in nm
I_RNA=imread([filepath '\' filename_RNA{i}]); % Read the RNA image into a matrix.
[row_RNA,col_RNA] = find(I_RNA);
total_intensity=sum(I_RNA(:));
[X, Y]=meshgrid(1:size(I_RNA,2), 1:size(I_RNA,1));
RNA_X = sum(double(I_RNA(:)).*X(:))/total_intensity; % RNA center X
RNA_Y = sum(double(I_RNA(:)).*Y(:))/total_intensity; % RNA center Y
 %polarization index PI
PI=sqrt((RNA_X*pixel-centroid(1)*pixel).^2 + (RNA_Y*pixel-centroid(2)*pixel).^2)./Rg;
%%
 %dispersion index DI
     u2=[];
     for m=1:size(I_RNA,1)
         for n=1:size(I_RNA,2)
             if I_RNA(m,n)>0
                 u2(m,n)=(((m-centroid(2)).^2+(n-centroid(1)).^2)*I_RNA(m,n))*pixel*pixel/total_intensity;
             end
         end
     end
 u2_RNA=sum(sum(u2));    
u2_cell=nanmean((col*pixel-RNA_X*pixel).^2+(row*pixel-RNA_Y*pixel).^2);
DI= u2_RNA/u2_cell;
All_PI(i)=PI;
All_DI(i)=DI;

end

