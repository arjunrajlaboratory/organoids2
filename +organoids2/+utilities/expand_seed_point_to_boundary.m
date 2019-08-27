function [boundary_coords, mask_coords] = expand_seed_point_to_boundary(image, slice_num, point, type, tolerance)

    % threshold the image:
    image_min = image(point(2), point(1)) - tolerance;
    image_max = image(point(2), point(1)) + tolerance;
    image_binary = (image <= image_max) & (image >= image_min);

    % if the type of segmentation is inside:
    if strcmp(type, 'inside')

        % get boundaries for all objects on the slice:
        [boundary_all, label_all] = bwboundaries(image_binary, 'holes');

        % get object number of the object containing seed:
        boundary_index = label_all(point(2), point(1));

        % get boundary of object containing seed point:
        boundary_coords = boundary_all{boundary_index};

    % if the type of segmentation is outside:
    elseif strcmp(type, 'outside')

        % convert seed to linear indices:
        point_linear = sub2ind(size(image_binary), point(2), point(1));

        % get all connected components:
        connected_components_all = bwconncomp(image_binary, 8);

        % get connected component containing seed point:
        contains = cellfun(@(x) ismember(point_linear, x), connected_components_all.PixelIdxList);
        index = contains == 1;
        connected_component_seed = connected_components_all.PixelIdxList{index};

        % create inverted mask from the connected component:
        mask_seed = zeros(size(image_binary));
        mask_seed(connected_component_seed) = 1;
        mask_seed = ~mask_seed;

        % get new connected components:
        connected_components_new = bwconncomp(mask_seed, 8);

        % get largest connected component:
        sizes = cellfun(@(x) numel(x), connected_components_new.PixelIdxList);
        [~, index] = max(sizes);
        if isempty(index)
            
            
            boundary_coords = [1 1; 1 size(image_binary, 2); size(image_binary, 1) size(image_binary, 2); size(image_binary, 1) 1];
            
        else
            
            % get the connected component:
            connected_component_organoid = connected_components_new.PixelIdxList{index};
            
            % create mask from the connected component:
            mask_organoid = zeros(size(image_binary));
            mask_organoid(connected_component_organoid) = 1;

            % get boundary:
            boundary_coords = bwboundaries(mask_organoid);
            boundary_coords = boundary_coords{1};
        end

    end

    
    
    % switch x and y of the boundary coords:
    boundary_coords = fliplr(boundary_coords);

    % get mask from boundary:
    mask = poly2mask(boundary_coords(:,2), boundary_coords(:,1), size(image_binary, 1), size(image_binary, 2));

    % get mask coordinates:
    [mask_x, mask_y] = find(mask == 1);
    mask_coords = [mask_x, mask_y];

    % add slice to coordinates:
    mask_coords = add_slice(mask_coords, slice_num);
    boundary_coords = add_slice(boundary_coords, slice_num);

end

function coords_3D = add_slice(coords_2D, slice_num)

    % create array to store 3D coords:
    coords_3D = coords_2D;

    % add slice number:
    coords_3D(:,3) = deal(slice_num);

end