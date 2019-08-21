function segmentation_closest = get_segmentation_nearest_point(segmentations, point)

    % if there are any segmentations:
    if isstruct(segmentations)

        % get the segmentations on the slice:
        segmentations_slice = organoids2.utilities.get_structure_results_matching_number(segmentations, 'slice', point(3));

        % get number of segmentations:
        num_segmentations = numel(segmentations_slice);

        % create array to store distance between each segmentation and point:
        distances = zeros(num_segmentations, 1);

        % for each segmentation:
        for i = 1:num_segmentations

            % get the minimum distance between the segmentation coordinates and
            % the point:
            distances(i) = min(pdist2(segmentations_slice(i).boundary, point));

        end

        % get the index of the segmentation that is closest:
        [~, index] = min(distances);

        % get the segmentation that is closest:
        segmentation_closest = segmentations_slice(index);
    
    % otherwise:
    else
        
        % set to none:
        segmentation_closest = segmentations;
        
    end

end