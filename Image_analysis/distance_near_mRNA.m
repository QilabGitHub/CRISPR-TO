[filename,filepath]=uigetfile({'*.tif', 'Tiff File (*.tif)'}, 'Select a file');
cd(filepath);
I=imread([filepath '\' filename]); % Read the image into a matrix.
[row,col] = find(I); % Find the positions of non-zero pixels in the matrix.
coord = 275*([col,row]-0.5); % Col = x, Row = y

%%
[filename,filepath]=uigetfile({'*.csv', 'ThunderSTORM File (*.csv)'}, 'Select a file', filepath);
TS=importdata([filepath '\' filename]).data(:,3:4); % Read the ThunderSTORM table.
dist=pdist2(TS,coord); % Calculate the paired-wise distance between mRNA puncta and CAAX-Crimson.
mindist=min(dist,[],2); % Calculate the minimum distance for each mRNA puncta. '2' means the horizontal dimention.
histogram(mindist,1000) % '1000' is the number of the bins.
sum(mindist<194) % Calculate the number of mRNA puncta with distance < a cutoff distance. You can adjust the cutoff "194".  、

bb = mindist>194;
RNA_in=[TS(bb,1),TS(bb,2)];   % RNA inside CAAS

figure(1)
scatter(TS(:,1),-TS(:,2)); % plot all mRNA
hold on;
scatter(RNA_in(:,1),-RNA_in(:,2)); % plot mRNA within CAAX
axis equal

sort_RNA=[];                  % sort RNA within CAAX according to their y axis if neuron is vertical
    [s,I]= sort(RNA_in(:,2));
    for j= 1:size(I,1)
       sort_RNA(j,1)=RNA_in(I(j),1);
       sort_RNA(j,2)=RNA_in(I(j),2);
       sort_RNA(j,3)=j;
    end

% sort_RNA=[];                  % sort RNA within CAAX according to their x axis if neuron is horizontal
%     [s,I]= sort(RNA_in(:,1));
%     for j= 1:size(I,1)
%        sort_RNA(j,1)=RNA_in(I(j),1);
%        sort_RNA(j,2)=RNA_in(I(j),2);
%        sort_RNA(j,3)=j;
%     end


figure(2)       % plot all sorted RNA and connect them 
scatter(sort_RNA(:,1),-sort_RNA(:,2),10, sort_RNA(:,3));
axis equal
patch([transpose(sort_RNA(:,1)) nan],[-transpose(sort_RNA(:,2)) nan],[transpose(sort_RNA(:,3)) nan],'FaceColor','none','EdgeColor','interp')
c = colorbar;

% calculate distance of neighboring RNA 
for k=1:size(I,1)-1
     Dis_nei(k)=sqrt((sort_RNA(k,1)-sort_RNA(k+1,1))^2+(sort_RNA(k,2)-sort_RNA(k+1,2))^2);
end
figure(3)   % distribution of distance
hist(Dis_nei,10);

bin_size=1;
bin= 0:bin_size:max(distance);
Hist_dis = histc(distance,bin);
