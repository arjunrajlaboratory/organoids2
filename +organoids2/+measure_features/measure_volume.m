function volumes = measure_volume(masks, voxel_size)

    % if there are any objects:
    if isstruct(masks)
        
        % get volume of each voxel:
        volume_per_voxel = prod(voxel_size);

        % get number of objects:
        number_objects = numel(masks);

        % create array to store volumes:
        volumes = zeros(number_objects, 1);

        % for each object:
        for i = 1:number_objects

            % get the volume of the object:
            volumes(i) = sum(masks(i).mask_3D(:)) * volume_per_voxel;

        end
        
    % otherwise:
    else
        
        volumes = NaN;
        
    end
    
end