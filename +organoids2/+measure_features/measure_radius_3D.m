function radius_3D = measure_radius_3D(objects, pixel_size_z)

    % if there are NO objects:
    if ischar(objects)
        
        radius_3D = NaN;
        
    % otherwise:
    else
        
        % throw error to user if there is more than one
        % object (it is intended for organoid only);
        if numel(objects) > 1
            
            error('The 3D radius feature currently works for segmentations where there is only 1 object.');
            
        else
            
            % determine the middle slice of the organoid (in pixels):
            slice_middle_pixels = max(extractfield(objects, 'slices'));
            
            % determine the middle slice of the organoid (in um):
            slice_middle_um = slice_middle_pixels * pixel_size_z;
            
            % get the centroid at the middle slice:
            coords_middle_slice = objects.boundary_um(objects.boundary_um(:,3) == slice_middle_um, :);
            centroid = mean(coords_middle_slice);

            % measure radius (distance between each boundary coordinate and the
            % centroid):
            num_coords_3D = size(objects.boundary_um, 1);
            radius_3D = zeros(num_coords_3D, 1);
            for i = 1:num_coords_3D
                radius_3D(i) = pdist([centroid; objects.boundary_um(i,:)]);
            end
            
        end

    end

end