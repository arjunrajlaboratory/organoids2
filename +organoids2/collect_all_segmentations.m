function collect_all_segmentations

    % get a list of stacks:
    list_image_stacks = dir('pos*.lsm');
    list_image_stacks = extractfield(list_image_stacks, 'name');
    list_image_stacks = cellfun(@(x) x(1:6), list_image_stacks, 'UniformOutput', false);

    % get the organoid type:
    organoid_type = organoids2.utilities.load_structure_from_file('organoid_type.mat');
    
    % get the number of image stacks:
    num_stacks = numel(list_image_stacks);
    
    % for each image stack:
    parfor i = 1:num_stacks
        
        % get the name of the stack:
        name_stack = list_image_stacks{i};
        
        % display status:
        fprintf('Working on %s\n', name_stack);
        
        % collect all data into one structure:
        data = organoids2.collect_all_segmentations.collect_all_data_into_one_structure(name_stack);
        
        % if the organoids are Intestine:
        if strcmp('Intestine', organoid_type)
            
            % get the bud and cyst segmentations:
            data = organoids2.collect_all_segmentations.get_bud_and_cyst_segmentation(data);
            
        end
        
        % format the data (convert coords to um and get structure per 3D
        % object)
        data = organoids2.collect_all_segmentations.format_data(data, name_stack);
        
        % re-arrange the segmentations into a structure reflecting their
        % heirarchy (ie buds    and cysts belong to an organoid, cells belong
        % to a bud or a cyst).
        data = organoids2.collect_all_segmentations.rearrange_data_into_hierarchy(data, organoid_type);
        
        % convert to um:
        data = organoids2.collect_all_segmentations.get_coords_in_um(data);
        
        % save the segmentations:
        organoids2.utilities.save_within_parfor_loop(sprintf('all_segmentations_%s.mat', name_stack), data);
        
    end
    
end