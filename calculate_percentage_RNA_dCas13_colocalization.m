%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code calculates the colocalization factor. Prior to running the
% code, please make sure to put all the tif images in the same folder. All
% the tif images in the same folder should have the same channel sequence.
% There should be an excel file named "Channel_sequence.xlsx", noting the
% information for each channel. This code will access this file and
% rearrange the channels in the following order:
% Channel 1: RNA
% Channel 2: dCas13
% Channel 3: OMM
% The user will be asked to mannually select an ROI for the cell to be
% analyzed. For OMM channel, a threshold value will be calculated based on 
% the pixel intensity statistics within the cell ROI. A binary maks will 
% then be created by applying thresholding in the OMM images. For RNA and 
% dCas13, a threshold value will be calculated based on the pixel intensity
% statistics of the entire image. Values lower than the threshold will be 
% set to 0. Pixels covered by the Channel 1 binary mask will be considered 
% as "colocalized".
% If the code has been run on the same dataset before, a MATLAB variable
% file called "channel1_roi_mask.mat" with all the ROIs will be saved in 
% the same folder. If you need to run the analysis again with different 
% threshold conditions, simply run the code again. For this to work, please
% do not modify the ROI file or remove/add any data file.
% The code also saves all the OMM masks and filenames in the same MATLAB
% file named "OMM_mask.mat".
% Written by Xiang Wu, 2024.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

% Define the thresholding factor. Change the value here to adjust threshold
OMM_thres_factor = 1.5;           % * STD
RNA_Cas_thres_factor = 1;        % * STD

% Define the filename for the output data
table_name = 'lcolocalization_analysis-ROI_0627_1h3_averageintensity.csv';

% Ask the user to select the image file folder with all the data
path = uigetdir (pwd, 'Please select the folder with all image files');
cd (path)

% Read the channel sequence file
channel_seq = readtable ('Channel_sequence.xlsx');
channel_name = channel_seq.Channel_name;

% Define the reading sequence of the channels
RNA_idx = find(ismember(channel_name, 'RNA'));
Cas_ind = find(ismember(channel_name, 'dCas13'));
OMM_ind = find(ismember(channel_name, 'OMM'));
channel_ind = [RNA_idx; Cas_ind; OMM_ind];

% Find all 'tif' files in the folder
imagefiles = dir('*.tif');      
nfiles = length(imagefiles);    % Number of files found

% Try to load saved ROI info from previous analysis. If no ROI info has
% been saved before, will ask the user to select ROI for each file.
try
    load('Cell_roi_mask.mat');
    roi_exist = 1;
catch
    roi_exist = 0;
    roi_mask = cell(nfiles, 1);
end

% Preallocate memory
colocal_factor = zeros(nfiles,2);
RNA_background = zeros(nfiles,1);
Cas_background = zeros(nfiles,1);
filenames = cell(nfiles,1);
OMM_mask = cell(nfiles,1);

% Loop through all images files and calculate the colocalization factors
for jj = 1: 1: nfiles
    % Get the info for the current file
    currentfilename = imagefiles(jj).name;
    filenames{jj} = currentfilename;
    info = imfinfo(currentfilename);
    ImageHeight = info(1).Height;
    ImageWidth = info(1).Width;
    ImgMatrix_whole = zeros(ImageHeight, ImageWidth, length(channel_ind));
    ImgMatrix_sub = ImgMatrix_whole;
    
    % Read the image file
    for ii = 1: 1: length(channel_ind)
        ImgMatrix_whole(:, :, ii) = double(imread(currentfilename, channel_ind(ii)));
        Current_Img = ImgMatrix_whole(:, :, ii);

        % For Channel 1 (RNA) and Channel 2 (dCas13), use the global pixel intensity statistics to calculate the threshold value
        if ii < 3
            Current_Img_Vec = Current_Img(:);
        
            % Find the probability distribution of all pixel values
            [freq, Pix_Int] = ksdensity (Current_Img_Vec);
        
            % Use the 2 most abundant pixel value as the background (weighted average)
            [max_freq_a, ind_a] = max(freq);
            freq(ind_a) = 0;
            [max_freq_b, ind_b] = max(freq);
            background = (max_freq_a^2 * Pix_Int(ind_a) + max_freq_b^2 * Pix_Int(ind_b)) / (max_freq_a^2 + max_freq_b^2);
            background = background+ std(Current_Img_Vec) * RNA_Cas_thres_factor;

            % Subtract the background and set all negative values to 0
            Current_Img = Current_Img - background;
            Current_Img(Current_Img < 0) = 0;

            if ii == 1
                RNA_background(jj) = background;
            elseif ii == 2
                Cas_background(jj) = background;
            end
        end

        ImgMatrix_sub(:,:,ii) = Current_Img;
    end
    
    % Load existing ROIs or ask the user to draw new ROIs
    if roi_exist == 1
        bw = roi_mask{jj};
    else
        % Create new ROI
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The following code is just for displaying a fused image
        % Create a fused image using the RNA and Cas channels
        imfuse_image1 = ImgMatrix_whole(:,:,1);
        imfuse_image1_vec = imfuse_image1(:);
        threshold1 = mean(imfuse_image1_vec) + 100 * std(imfuse_image1_vec);
        imfuse_image1 (imfuse_image1 > threshold1) = threshold1;
    
        imfuse_image2 = ImgMatrix_whole(:,:,2);
        imfuse_image2_vec = imfuse_image2(:);
        threshold2 = mean(imfuse_image2_vec) + 2 * std(imfuse_image2_vec);
        imfuse_image2 (imfuse_image2 > threshold2) = threshold2;
    
        % Show the fused image
        %C = imfuse(imfuse_image1,imfuse_image2,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
        C = imfuse(imfuse_image1,imfuse_image2,'falsecolor','ColorChannels',[1 2 0]);
        figure;
        imshow(C);
        caxis([0,0.2])
        title (['Please select an ROI for the cell, file #', num2str(jj)]);
        % End of image display code
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % Ask the user to select ROI
        roi = drawpolygon;
        bw = createMask(roi);
        roi_mask{jj} = bw;
        close all
    end
  
    % Adjust the background value for channel 3 (OMM) based on the ROI
    OMM_Img = ImgMatrix_sub(:,:,3);
    ROI_Img_Vec = OMM_Img(bw);      % Extract pixels within ROI

    % Find the probability distribution of ROI pixel values
    [freq, Pix_Int] = ksdensity(ROI_Img_Vec);
    
    % Use the 2 most abundant pixel value in the ROI as the background (weighted average)
    [max_freq_a, ind_a] = max(freq);
    freq(ind_a) = 0;
    [max_freq_b, ind_b] = max(freq);
    roi_background = (max_freq_a^2 * Pix_Int(ind_a) + max_freq_b^2 * Pix_Int(ind_b)) / (max_freq_a^2 + max_freq_b^2);
    roi_background = roi_background + std(ROI_Img_Vec) * OMM_thres_factor;
    ImgMatrix_sub(:,:,3) = ImgMatrix_sub(:,:,3) - roi_background;
    ImgMatrix_roi = ImgMatrix_sub .* bw;

    % Calculate the colocalization factor
    channel_mask = ImgMatrix_roi(:,:,3) > 0;   
    colocal_factor(jj, 1) = sum(ImgMatrix_roi(:,:,1).*channel_mask, "all") / sum(ImgMatrix_roi(:,:,1), "all") ;
    colocal_factor(jj, 2) = sum(ImgMatrix_roi(:,:,2).*channel_mask, "all") / sum(ImgMatrix_roi(:,:,2), "all") ;

    OMM_mask{jj} = channel_mask;
end

RNA_colocal = colocal_factor(:, 1);
Cas_colocal = colocal_factor(:, 2);
output_table = table (RNA_colocal, Cas_colocal, RNA_background, Cas_background, 'RowNames', filenames);
output_table.Properties.DimensionNames{1} = 'Filenames';
writetable(output_table, table_name, 'WriteRowNames', true);

% Save the ROI file, if it doesn't exist
if roi_exist == 0
    save ("Cell_roi_mask.mat", "roi_mask");
end

% Save the OMM mask and the file name in the same Matlab variable
save("OMM_mask.mat", "filenames", "OMM_mask");
