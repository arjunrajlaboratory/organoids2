function data = format_data(data, name_stack)

    % get a list of segmentations and cell types:
    list_fields = fieldnames(data.segmentations);
    
    % for each segmentation:
    for i = 1:numel(list_fields)
        
        % get the segmentation name:
        name_segmentation = list_fields{i};
        
        % get the segmentations:
        segmentations_temp_2D = data.segmentations.(name_segmentation);
        
        % get the structure where each entry is a 3D (not 2D) object:
        segmentations_temp_3D = get_structure_per_3D_segmentation(segmentations_temp_2D);
        
        % if the object is cyst/organoid and there is more than one object:
        if (contains('organoid', name_segmentation) || contains('cyst', name_segmentation)) && numel(segmentations_temp_3D) > 1
            
            % give the user an error:
            error(sprintf('There are two 3D %s objects for %s! Go back and fix the segmentations.', name_segmentation, name_stack));
            
        end
        
        % save:
        data.segmentations.(name_segmentation) = segmentations_temp_3D;

    end
    
end

% function to get structure with entry for each 3D segmentation:
function seg_3D = get_structure_per_3D_segmentation(seg_2D)

    % if there are NO objects:
    if ischar(seg_2D)
        
        % save the structure as an empty:
        seg_3D = seg_2D;
        
    % otherwise:
    else
        
        % get list of 3D objects:
        list_objects_3D = unique(extractfield(seg_2D, 'object_num'));
        num_objects_3D = numel(list_objects_3D);
        
        % create structure to save 3D objects:
        seg_3D = struct;
        [seg_3D(1:num_objects_3D).object_num] = deal([]);
        [seg_3D(1:num_objects_3D).slices] = deal([]);
        [seg_3D(1:num_objects_3D).boundary] = deal([]);
        [seg_3D(1:num_objects_3D).mask] = deal([]);

        % for each 3D object:
        for k = 1:num_objects_3D

            % get all 2D objects:
            seg_2D_object = organoids2.utilities.get_structure_results_matching_number(seg_2D, 'object_num', list_objects_3D(k));

            % combine all coordinates:
            coords_boundary = seg_2D_object(1).boundary;
            coords_mask = seg_2D_object(1).mask;
            for l = 2:numel(seg_2D_object)
               coords_boundary = [coords_boundary; seg_2D_object(l).boundary]; 
               coords_mask = [coords_mask; seg_2D_object(l).mask];
            end

            % save to structure:
            seg_3D(k).object_num = seg_2D_object(1).object_num;
            seg_3D(k).slices = unique(coords_boundary(:,3));
            seg_3D(k).boundary = coords_boundary;
            seg_3D(k).mask = coords_mask;

        end
    
    end

end