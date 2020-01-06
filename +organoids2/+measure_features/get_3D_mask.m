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
            
            % get object coordinates:
            coords = objects(i).mask;
            
            % create array to store 3D mask:
            mask_3D = zeros(image_height, image_width, image_depth);
            
            % create the mask using linear indexing:
            mask_3D(sub2ind(size(mask_3D), coords(:,2), coords(:,1), coords(:,3))) = 1;
                
            % save mask:
            masks(i).mask_3D = mask_3D;

        end
        
    end
    
end