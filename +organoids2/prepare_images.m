function prepare_images

    % input the organoid type:
    organoid_type = questdlg('What type of organoids are these?', 'Organoid Selection', 'MDCK', 'Intestine', 'MDCK');

    % save the organoid type:
    save('organoid_type.mat', 'organoid_type');
    
    % get list of all images:
    list_images = dir('pos*.lsm');
    
    % load the first image:
    [image, ~] = organoids2.utilities.load_lsm_stack(list_images(1).name);
    
    % get the channel names:
    channel_names = organoids2.prepare_images.gui_to_get_channel_names(image);
    
    % get number of images:
    num_images = numel(list_images);
    
    % for each image:
    for i = 1:num_images
        
        % get the image name:
        image_name = list_images(i).name;
        image_name_no_ext = organoids2.utilities.get_file_name_without_extension(image_name);
        
        % display the number of the image you are working on:
        fprintf('Working on stack %s\n', image_name_no_ext);
        
        % read the image:
        [image, image_properties] = organoids2.utilities.load_lsm_stack(image_name);
        
        % get number of channels:
        num_channels = size(image, 4);
        
        % crop image in z:
        [image_cropped, slice_start, slice_end] = organoids2.prepare_images.gui_to_crop_image(image, channel_names, 'xy');
        
        % save individual channels (as grayscale):
        for j = 1:num_channels
           
            % get name of channel:
            channel_name = sprintf('%s_%s.tif', image_name_no_ext, channel_names{j});
            
            % save:
            organoids2.utilities.save_stack(squeeze(image_cropped(:,:,:,j)), channel_name);
            
        end
        
        % make an rgb image:
        image_rgb = organoids2.utilities.create_rgb_image(image_cropped, channel_names);
        
        % save the rgb image:
        save(sprintf('%s_rgb.mat', image_name_no_ext), 'image_rgb');
        
        % save:
        image_info = struct;
        image_info.slice_start = slice_start;
        image_info.slice_end = slice_end;
        image_info.height = size(image_cropped, 1);
        image_info.width = size(image_cropped, 2);
        image_info.depth = size(image_cropped, 3);
        image_info.voxel_size_x = image_properties.voxSizeX*1000000;
        image_info.voxel_size_y = image_properties.voxSizeY*1000000;
        image_info.voxel_size_z = image_properties.voxSizeZ*1000000;
            
        % save the image info:
        save(sprintf('image_info_%s.mat', image_name_no_ext), 'image_info');
        
    end

end