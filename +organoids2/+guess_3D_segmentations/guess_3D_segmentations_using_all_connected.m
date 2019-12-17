function guess_3D_segmentations_using_all_connected

    % get the list of segmentation files:
    list_files = dir('*final_2D*.mat');
    
    % get the number of files:
    num_files = numel(list_files);

    % for each file:
    parfor i = 1:num_files
        
        % get the image name:
        image_name = list_files(i).name(end-9:end-4);
        
        % print status:
        fprintf('Working on stack %03d / %03d (%s) \n', i, num_files, image_name);
        
        % load the image to get image size:
        image = readmm(fullfile(pwd, '..', sprintf('%s_dapi.tif', image_name)));
        image_height = image.height;
        image_width = image.width;
        image_depth = image.numplanes;
        
        % load the segmentations:
        segmentations = organoids2.utilities.load_structure_from_file(list_files(i).name);
                
        % assign all objects to the same 3D object:
        [segmentations(1:end).object_num] = deal(1); 
        
        % remove the segmentation id field:
        if ~ischar(segmentations)
            segmentations = rmfield(segmentations, 'segmentation_id');
        end
        
        % save segmentations:
        organoids2.utilities.save_within_parfor_loop(strrep(list_files(i).name, 'final_2D', 'guess_3D'), segmentations);
        
    end

end