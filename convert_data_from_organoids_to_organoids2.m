% This script converts data from the format used for the original
% organoids/quantiuspipeline repository to the format used by the new
% organoids2 repository. 

% The script should be run from within a Quantius Job folder. For
% example, it should be run from within Dropbox (RajLab) / LEB_Organoids /
% Data / LAUREN_05 / Quantius_Jobs / Job046_submission_2_redo_2.

% Once this script has been run, the data is in the form it would be if
% prepare_images, guess_2D_segmentations (for all structures), prepare_2D_segmentations_for_review (for all structures),
% and prepare_3D_segmentations_for_review (for nuclei only) steps have
% already been run.

% load the job settings:
job_settings = load('job_settings.mat');
job_settings = job_settings.job_settings;

% get the organoid type:
organoid_type = job_settings.organoid_type;

% get a list of paths to the raw data used in the Quantius job:
list_paths_raw_data = unique(extractfield(job_settings.stack_info.info_rename, 'path_old'));

% for each raw data path:
for i = 1:numel(list_paths_raw_data)
   
    % get the path and the old folder name:
    temp = strfind(list_paths_raw_data{i}(1:end-10), '/');
    path = list_paths_raw_data{i}(1:temp(end));
    folder_name_old = list_paths_raw_data{i}(temp(end)+1:end-10);
    
    % get the new folder name:
    folder_name_new = [folder_name_old '_organoids2'];
    
    % make the new folder:
    mkdir(fullfile(path, folder_name_new));
    
    % create folders to store segmentations:
    mkdir(fullfile(path, folder_name_new, 'segmentations_nuclei'));
    mkdir(fullfile(path, folder_name_new, 'segmentations_lumens'));
    mkdir(fullfile(path, folder_name_new, 'segmentations_organoid'));
    
    % save the organoid type:
    save(fullfile(path, folder_name_new, 'organoid_type.mat'), 'organoid_type');
    
    % load the old image info file:
    image_info_old = load(fullfile(path, folder_name_old, 'info_image_prep.mat'));
    image_info_old = image_info_old.image_info;
    
    % get a list of old images from this folder:
    list_images_old = organoids2.utilities.get_structure_results_matching_string(job_settings.stack_info.info_rename, 'path_old', list_paths_raw_data{i});
    
    % get a list of new images from this folder:
    list_images_new = dir(fullfile(path, folder_name_old, '*.lsm'));
    
    % for each image:
    for j = 1:numel(list_images_old)
       
        % get the old image name:
        image_name_old = list_images_old(j).name_new;
        
        % get the new image name:
        image_name_new = list_images_new(j).name(1:end-4);
        
        % copy the original .lsm file:
        copyfile(fullfile(path, folder_name_old, [image_name_new '.lsm']), fullfile(path, folder_name_new, [image_name_new '.lsm']));
        
        % get a list of channels:
        list_channels = dir(fullfile('16_other_original', sprintf('%s*.tif', image_name_old)));
        
        % get number of channels:
        num_channels = numel(list_channels);
        
        % load one channel to get the image dimensions:
        image_temp = readmm(fullfile('16_other_original', list_channels(1).name));
        [height, width, depth] = size(image_temp.imagedata);
        
        % create an array to store the rgb image:
        image_rgb = zeros(height, width, depth, num_channels, 'like', image_temp.imagedata);
        
        % for each channel:
        for k = 1:num_channels
            
            % get the channel name:
            channel_name = list_channels(k).name(11:end-4);
            
            % copy the channel:
            copyfile(fullfile('16_other_original', list_channels(k).name), fullfile(path, folder_name_new, sprintf('%s_%s.tif', image_name_new, channel_name)));
            
            % load the stack:
            image_temp = readmm(fullfile(path, folder_name_new, sprintf('%s_%s.tif', image_name_new, channel_name)));
            image_temp = image_temp.imagedata;
            
            % add the channel to the rgb image:
            image_rgb(:,:,:,k) = image_temp;
            
        end
        
        % format the rgb image:
        image_rgb = organoids2.utilities.create_rgb_image(image_rgb, cellfun(@(x) x(11:end-4), extractfield(list_channels, 'name'), 'UniformOutput', false));
        
        % save the rgb image:
        save(fullfile(path, folder_name_new, sprintf('%s_rgb.mat', image_name_new)), 'image_rgb');
        
        % get the relevant image info:
        image_info_old_temp = organoids2.utilities.get_structure_results_matching_string(image_info_old, 'image_name_original', [image_name_new '.lsm']);
        
        % make a new image info file:
        image_info = struct;
        image_info.slice_start = image_info_old_temp.slice_start;
        image_info.slice_end = image_info_old_temp.slice_end;
        image_info.height = height;
        image_info.width = width;
        image_info.depth = depth;
        image_info.voxel_size_x = image_info_old_temp.voxel_size_x;
        image_info.voxel_size_y = image_info_old_temp.voxel_size_y;
        image_info.voxel_size_z = image_info_old_temp.voxel_size_z;
        
        % save the image info file:
        save(fullfile(path, folder_name_new, sprintf('image_info_%s.mat', image_name_new)), 'image_info');
        
        % get the name of the 2D segmentation files:
        name_segmentation_file_nuclei = fullfile('16_other_original', sprintf('%s_nuclei.mat', image_name_old));
        name_segmentation_file_lumens = fullfile('16_other_original', sprintf('%s_lumens.mat', image_name_old));
        name_segmentation_file_organoid = fullfile('16_other_original', sprintf('%s_organoid.mat', image_name_old));
        
        % if the segmentation file exists, copy it:
        if isfile(name_segmentation_file_nuclei)
            copyfile(name_segmentation_file_nuclei, fullfile(path, folder_name_new, 'segmentations_nuclei', sprintf('nuclei_XY_final_2D_%s.mat', image_name_new)));
        end
        if isfile(name_segmentation_file_lumens)
            copyfile(name_segmentation_file_lumens, fullfile(path, folder_name_new, 'segmentations_lumens', sprintf('lumens_final_2D_%s.mat', image_name_new)));
        end
        if isfile(name_segmentation_file_organoid)
            copyfile(name_segmentation_file_organoid, fullfile(path, folder_name_new, 'segmentations_organoid', sprintf('organoid_final_2D_%s.mat', image_name_new)));
        end
        
        % get the name of 3D segmentation file:
        name_segmentation_file_3D = fullfile('16_other_original', sprintf('%s_all.mat', image_name_old));
        
        % if the segmentation file exists:
        if isfile(name_segmentation_file_3D)
            
            % load the file:
            segmentations_3D = organoids2.utilities.load_structure_from_file(name_segmentation_file_3D);
            
            % if the 3D nuclear segmentations exist:
            if isfield(segmentations_3D.seg_2D, 'nuclei')
                
                % get the 3D nuclear segmentations:
                segmentations_3D_nuclei = segmentations_3D.seg_2D.nuclei;
                
                % remove the field containing boundary coords in um:
                segmentations_3D_nuclei = rmfield(segmentations_3D_nuclei, 'coordinates_um');
                
                % rename the fields:
                segmentations_3D_nuclei = cell2struct(struct2cell(segmentations_3D_nuclei), {'slices', 'boundary', 'object_num'});
                
                % add a field to store the mask coords:
                [segmentations_3D_nuclei(1:end).mask] = deal([]);
                
                % for each segmentation:
                for k = 1:numel(segmentations_3D_nuclei)
                    
                    % get the mask:
                    mask_temp = zeros(image_info.height, image_info.width);
                    for l = 1:size(segmentations_3D_nuclei(k).boundary, 1)
                        mask_temp(segmentations_3D_nuclei(k).boundary(l,2), segmentations_3D_nuclei(k).boundary(l,1)) = 1; 
                    end
                        
                    % fill in the mask:
                    mask_temp = imfill(mask_temp, 'holes');
                    
                    % get the mask coords:
                    [mask_coords_row, mask_coords_column] = find(mask_temp == 1);
                    mask_coords = [mask_coords_column, mask_coords_row];
                    
                    % add the slice to the mask coords:
                    mask_coords(:,3) = deal(segmentations_3D_nuclei(k).slices);
                    
                    % save the mask coords:
                    segmentations_3D_nuclei(k).mask = mask_coords;
                    
                end
            
                % save the 3D nuclear segmentations:
                save(fullfile(path, folder_name_new, 'segmentations_nuclei', sprintf('nuclei_final_3D_%s.mat', image_name_new)), 'segmentations_3D_nuclei');
                            
            end
            
        end
        
    end
    
end