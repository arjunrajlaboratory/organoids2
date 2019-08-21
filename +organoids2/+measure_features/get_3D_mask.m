function masks = get_3D_mask(objects, image_height, image_width, image_depth)

    % if there are NO objects:
    if ~isstruct(objects)
        
        masks = 'none';
        
    % otherwise:
    else
       
        % get number of objects:
        num_objects = numel(objects);

        % create structure to store mask:
        [masks(1:num_objects).mask_3D] = deal([]);

        % for each object:
        for i = 1:num_objects

            % get list of slices the object is on:
            list_slices = objects(i).slices;

            % get number of slices the object is on:
            num_slices = numel(list_slices);

            % create array to store 3D mask:
            mask_3D = zeros(image_height, image_width, image_depth);

            % get object coordinates:
            coords = objects(i).boundary;

            % for each slice the object is on:
            for j = 1:num_slices

                % get coordinates on the slice:
                coords_slice_rows = coords(:,3) == list_slices(j);
                coords_slice = coords(coords_slice_rows, :);

                % create mask from coordinates on the slice:
                mask_3D(:, :, list_slices(j)) = poly2mask(coords_slice(:,1), coords_slice(:,2), image_height, image_width);
                
                % add boundary coordainates to the mask (they are sometimes
                % left out due to behavior of poly2mask);
                mask_3D(coords_slice(:,2), coords_slice(:,1), list_slices(j)) = 1;

            end

            % save mask:
            masks(i).mask_3D = mask_3D;

        end
        
    end
    
end

