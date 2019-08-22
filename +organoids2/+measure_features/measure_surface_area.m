function surface_area = measure_surface_area(objects)

    % if there are NO objects:
    if ischar(objects)
        
        surface_area = NaN;
        
    % otherwise:
    else
        
        % get number of objects:
        num_objects = numel(objects);

        % create array to store surface area:
        surface_area = zeros(num_objects, 1);

        % for each object:
        for i = 1:num_objects

            % get unqiue coordinates (avoids error with alpha shape function):
            coordinates = unique(objects(i).boundary_um, 'rows');

            % create an alpha shape out of the object coordinates:
            alpha_shape = alphaShape(coordinates);

            % get the surface area:
            surface_area(i) = surfaceArea(alpha_shape);

        end
        
    end

end

