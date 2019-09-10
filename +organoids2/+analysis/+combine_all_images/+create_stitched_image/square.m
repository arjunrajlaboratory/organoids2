function [stitch, features] = square(features, image_field_to_use)

    %%% First, we want to set up the layout of the images. For simplicity,
    %%% the stitched image is made to be square (same # tiles in X and Y).
    %%% But, because the number of organoids is not necessarily a square,
    %%% there may be some "empty" tiles.  
    
    % get tile size:
    tile_size_XY = size(features(1).(image_field_to_use), 1);
    tile_size_Z = size(features(1).(image_field_to_use), 3);
    tile_size_channel = size(features(1).(image_field_to_use), 4);
    
    % get number of organoids:
    num_organoids = numel(features);
    
    % determine the number of tiles:
    num_tiles = ceil(sqrt(num_organoids));
    
    % create mapping between organoid number and tile position:
    position_linear = 1:(num_tiles^2);
    position_index = reshape(position_linear, [num_tiles, num_tiles])';
    
    % create fields to store tile position:
    [features(1:end).tile_row_start] = deal(0);
    [features(1:end).tile_row_end] = deal(0);    
    [features(1:end).tile_col_start] = deal(0);
    [features(1:end).tile_col_end] = deal(0);
    
    % get row and column placement for each image:
    for i = 1:num_organoids
        
        % get row and column number of the tile:
        [temp_tile_row, temp_tile_col] = find(position_index == i);
        
        % convert row and column number to indices for placing the image:       
        [features(i).tile_row_start, features(i).tile_row_end, ...
            features(i).tile_col_start, features(i).tile_col_end] = ...
            get_coords_for_placing_tile(tile_size_XY, temp_tile_row, temp_tile_col);
        
    end
    
    %%% Next, we want to create the stitched image.
    
    % get the size of the stitched image:
    stitch_size = [num_tiles*tile_size_XY, num_tiles*tile_size_XY, tile_size_Z, tile_size_channel];
    
    % create empty array to store the stitched image:
    stitch = zeros(stitch_size, 'like', features(i).(image_field_to_use));
    
    % for each image:
    for i = 1:num_organoids
       
        % place into stitched image:
        stitch(...
            features(i).tile_row_start:features(i).tile_row_end, ...
            features(i).tile_col_start:features(i).tile_col_end, ...
            :, :) = features(i).(image_field_to_use);
        
    end
    
end

function [tile_row_start, tile_row_end, tile_col_start, tile_col_end] = get_coords_for_placing_tile(tile_size, tile_row, tile_col)

    tile_row_start = ((tile_row - 1) *  tile_size) + 1;
    tile_row_end = tile_row * tile_size;
    tile_col_start = ((tile_col - 1) *  tile_size) + 1;
    tile_col_end = tile_col * tile_size;

end