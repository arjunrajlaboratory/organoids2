function [coords_boundary, coords_mask] = get_boundary_and_mask_from_coords(coords_x, coords_y, image_width, image_height, num_slice)
    
    % create a mask from the vertices:
    mask = poly2mask(coords_x, coords_y, image_height, image_width);
    
    % add boundary coordinates to the mask (they are sometimes left out due to behavior of poly2mask);
    for i = 1:numel(coords_x)
        mask(coords_y(i), coords_x(i)) = 1;
    end

    % get the coordinates of the mask:
    [coords_mask_x, coords_mask_y] = find(mask == 1);
    coords_mask = [coords_mask_y, coords_mask_x];

    % get the coordinates of the boundary:
    coords_boundary = bwboundaries(mask);
    coords_boundary = fliplr(coords_boundary{1});
    
    % add slice number to the coordinates:
    coords_mask(:,3) = deal(num_slice);
    coords_boundary(:,3) = deal(num_slice);
    
    %%% Note that I get the boundary coordinates of the mask instead of
    %%% using the boundary coordinates of the drawfreehand object
    %%% (coords_vertices). This is because drawfreehand coordinates include
    %%% only vertices of the shape and I want the coordinate of every pixel
    %%% on the boundary. 

end