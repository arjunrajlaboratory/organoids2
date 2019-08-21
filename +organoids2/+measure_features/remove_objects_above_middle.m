function objects = remove_objects_above_middle(objects, slice_middle)

    % if there are any objects:
    if isstruct(objects)
    
        % create array to store indices of objects to remove:
        indices_objects_remove = [];

        % for each object:
        for i = 1:numel(objects)

            % get slices the object is on:
            slices = objects(i).slices;

            % get list of slices the object is on below the middle:
            slices_include = slices(slices <= slice_middle);

            % get number of slices the object is on below the middle:
            num_slices_include = numel(slices_include);

            % if the object is not on any slices below the middle:
            if num_slices_include == 0

                % add the object to the list of objects to remove:
                indices_objects_remove = [indices_objects_remove, i];

            % otherwise:
            else

                % get indices of coordinates above the middle:
                indices_coords_remove = find(objects(i).boundary(:,3) > slice_middle);

                % update the coordinates to exclude any above the middle:
                objects(i).boundary(indices_coords_remove, :) = [];
                objects(i).boundary_um(indices_coords_remove, :) = [];

            end

        end

        % remove objects that are entirely above the middle
        objects(indices_objects_remove) = [];
        
        % if there are no objects left:
        if isempty(objects)
            
            % set the objects to none:
            objects = 'none';
            
        end
    
    end

end