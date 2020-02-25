function surface_area = measure_surface_area(objects, masks, voxel_size_XY, voxel_size_Z, method)

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
        
            switch method

                % NOTE THE ALPHA SHAPE METHOD RETURNS SURFACE AREAS THAT
                % ARE 2X WHAT I EXPECT.
                
                case 'alpha shape'

                    % get unqiue coordinates (avoids error with alpha shape function):
                    coordinates = unique(objects(i).boundary_um, 'rows');

                    % create an alpha shape out of the object coordinates:
                    alpha_shape = alphaShape(coordinates);

                    % get the surface area:
                    surface_area(i) = surfaceArea(alpha_shape);

                case 'slice approximation'
                    
                    % get the number of slices in the mask:
                    num_slices = size(masks(i).mask_3D, 3);
                    
                    % create an array to store the perimeter of the object
                    % on each slice:
                    perimeters = zeros(num_slices, 1);

                    % for each slice of the mask:
                    for j = 1:num_slices
                        
                        % get the perimeters of the object on that slice:
                        temp_perimeters = regionprops(masks(i).mask_3D(:,:,j), 'Perimeter');
                        
                        % sum the perimeter for each occurence of the
                        % object on the slice:
                        for k = 1:numel(temp_perimeters)
                            
                            perimeters(j) = perimeters(j) + temp_perimeters(k).Perimeter;
                            
                        end
                        
                    end
                    
                    % get the total perimeter:
                    perimeter_total = sum(perimeters);
                    
                    % get the total perimeter in um:
                    perimeter_total_um = perimeter_total * voxel_size_XY;
                    
                    % get the surface area as the total perimeter times the
                    % Z voxel size:
                    surface_area(i) = perimeter_total_um * voxel_size_Z;
                
            end
        
        end
        
    end

end

