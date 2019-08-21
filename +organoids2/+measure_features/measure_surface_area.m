function surface_area = measure_surface_area(masks, voxel_size)

    % if there are NO objects:
    if ~isstruct(objects)
        
        surface_area = NaN;
        
    % otherwise:
    else
        
        % get number of objects:
        % num_objects = numel(objects);
        num_objects = numel(masks);

        % create array to store surface area:
        surface_area = zeros(num_objects, 1);

        % for each object:
        for i = 1:num_objects
            
            surface_area(i) = regionprops3(masks(i).mask_3D);
            
            surface_area(i) = surface_area(i) * voxel_size(1) * voxel_size(3);

            % get unqiue coordinates (avoids error with alpha shape function):
            coordinates = unique(objects(i).boundary_um, 'rows');

            % create an alpha shape out of the object coordinates:
            alpha_shape = alphaShape(coordinates);

            % get the surface area:
            surface_area(i) = surfaceArea(alpha_shape);

        end
        
    end

end

