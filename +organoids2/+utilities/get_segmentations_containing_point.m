function segmentations = get_segmentations_containing_point(segmentations, point)

    % if there are any segmentations:
    if isstruct(segmentations)
        
        % get number of segmentations:
        num_segmentations = numel(segmentations);
        
        % create array to store whether or not each row contains the point
        rows_status = zeros(num_segmentations, 1);

        % for each segmentation:
        for i = 1:num_segmentations

            % if any coordinate of the point is within the mask of the segmentation:
            if any(ismember(point, segmentations(i).mask, 'rows'))

                % set this row to remove (1 = contains, 0 = does not contain):
                rows_status(i) = 1;

            end

        end
        
        % get list of rows to remove (that do not contain the point):
        rows_remove = find(rows_status == 0);

        % remove rows:
        segmentations(rows_remove) = [];

        % if the structure is empty now:
        if isempty(segmentations)

            segmentations = 'none';

        end

    % otherwise:
    else
        
        % do nothing (return none as segmentations)
        
    end

end