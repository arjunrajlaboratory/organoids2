function radius = measure_radius(objects, masks, pixel_size_x, method)

    % if there are NO objects:
    if ischar(objects)
        
        radius = NaN;
        
    % otherwise:
    else

        %%% First, we need to determine the slice on which the area of the object is
        %%% largest. We use this for estimating radius and major/minor axes
        %%% because many objects are not fully segmented (for example, we do
        %%% not even image the entire organoid and thus the whole organoid
        %%% segmentation is cutoff somewhere after the middle).
        
        % get the slices at where the objects have the largest area:
        slices_middle = organoids2.measure_features.get_slice_largest_area(masks);
        
        % get number of objects:
        num_objects = numel(objects);
        
        % get the masks to use:
        masks_middle = masks;
        for i = 1:num_objects
            
            masks_middle(i).mask_3D = masks(i).mask_3D(:,:,slices_middle(i).slice);
            
        end

        %%% Next, we want to calculate the radius at the slice with the largest
        %%% area. 
        
        % create array to store radii:
        radius = zeros(num_objects, 1);
        
        % for each object:
        for i = 1:num_objects
            
            % get the mask for this object:
            mask_to_use = masks_middle(i).mask_3D;

            % depending on the method to calculate radius:
            switch method
            
                case 'normal'
                    
                    % get the centroid of the mask:
                    centroid = regionprops(mask_to_use, 'Centroid');
                    centroid = centroid.Centroid;

                    % get all coordinates for the object on this slice:
                    boundary_coords = objects(i).boundary;
                    boundary_coords = boundary_coords(boundary_coords(:,3) == slices_middle(i).slice, :); 
                    
                    % get the distance between every boundary point and the
                    % centroid:
                    distances = pdist2(centroid, boundary_coords(:,1:2));
                    
                    % get the mean distance:
                    radius_temp = mean(distances);
                    
                    % convert the mean distance to um:
                    radius_temp = radius_temp * pixel_size_x;
                    
                case 'major'
                    
                    % get the major axis:
                    major_axis = regionprops(mask_to_use, 'MajorAxisLength');
                    major_axis = major_axis.MajorAxisLength;
                    
                    % convert the major axis to radius (AKA semi-major
                    % axis):
                    radius_temp = major_axis / 2;
                    
                    % convert the mean distance to um:
                    radius_temp = radius_temp * pixel_size_x;
                    
                case 'minor'
                    
                    % get the minor axis:
                    minor_axis = regionprops(mask_to_use, 'MinorAxisLength');
                    minor_axis = minor_axis.MinorAxisLength;
                    
                    % convert the minor axis to radius (AKA semi-minor
                    % axis):
                    radius_temp = minor_axis / 2;
                    
                    % convert the mean distance to um:
                    radius_temp = radius_temp * pixel_size_x;
                    
                case 'eccentricity'
                    
                    % get the circularity:
                    eccentricity = regionprops(mask_to_use, 'Eccentricity');
                    radius_temp = eccentricity.Eccentricity;
                
            end

            % save:
            radius(i) = radius_temp;
            
        end
        
    end
    
end