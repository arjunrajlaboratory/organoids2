function segmentations = remove_segmentations_touching_corners(segmentations, image_width, image_height)

    % if there are any segmentations:
    if isstruct(segmentations)

        % set the corners:
        corners = [1 1; 1 image_width; image_height 1; image_height image_width];

        % get number of segmentations:
        num_segmentations = numel(segmentations);

        % create array to store rows to remove:
        rows_remove = false(num_segmentations, 1);

        % for each segmentation:
        for i = 1:num_segmentations

            % if the segmentation contains any corner coordinates:
            if any(ismember(corners, segmentations(i).boundary(:,1:2), 'rows'))

                % add that segmentation to list of rows to remove:
                rows_remove(i) = 1;

            end

        end

        % remove any segmentations:
        segmentations(rows_remove) = [];

        % if there are no segmentations:
        if isempty(segmentations)

            % set the value to none:
            segmentations = 'none';

        end
    
    end

end