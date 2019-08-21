function slice_largest_area = get_slice_largest_area(object_masks)

    % get number of objects:
    num_objects = numel(object_masks);

    % create structure to store slice with largest area:
    [slice_largest_area(1:num_objects).slice] = deal(0);

    % for each object:
    for i = 1:num_objects

        % get number of slices the object is on:
        num_slices = size(object_masks(i).mask_3D, 3);

        % create array to store area of object on each slice:
        area_per_slice = zeros(num_slices, 1);

        % for each slice:
        for j = 1:num_slices

            % get the area of the object on the slice:
            area_per_slice(j) = nnz(object_masks(i).mask_3D(:,:,j));

        end

        % get slice with the largest area:
        [~, slice_largest_area(i).slice] = max(area_per_slice);

    end

end