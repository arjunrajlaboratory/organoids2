function [segmentations, slice_middle] = crop_segmentations(segmentations, method, image_height, image_width, image_depth)

    % depending on the method for cropping:
    switch method
        
        % if you want to crop the organoid:
        case {'crop at slice where organoid area largest', 'crop at slice where cyst area largest'}
            
            % depending on the method for cropping:
            switch method
                
                % set the segmentation to use:
                case 'crop at slice where organoid area largest'
                    segmentation_to_use = 'organoid';
                case 'crop at slice where cyst area largest'
                    segmentation_to_use = 'cyst';
                    
            end

            % make a mask from the segmentation to use for cropping:
            mask_organoid = organoids2.measure_features.get_3D_mask(segmentations.(segmentation_to_use), image_height, image_width, image_depth);
            
            % get the slice at the middle of the segmentation (where area largest):
            slice_middle = organoids2.measure_features.get_slice_largest_area(mask_organoid);
            slice_middle = slice_middle.slice;

            % get list of segmentation types:
            list_segmentation_types = fieldnames(segmentations);

            % for each type of segmentation:
            for i = 1:numel(list_segmentation_types)

                % remove objects above the middle:
                segmentations.(list_segmentation_types{i}) = organoids2.measure_features.remove_objects_above_middle(segmentations.(list_segmentation_types{i}), slice_middle);

            end 
            
        % if you don't want to crop the organoid:
        case 'none'
            
            % set the middle slice to none:
            slice_middle = 'none';
        
    end

end