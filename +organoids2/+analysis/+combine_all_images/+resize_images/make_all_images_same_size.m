function features = make_all_images_same_size(features, image_type_to_resize, type_label)

    % get number of organoids:
    num_organoids = numel(features);

    % get size of each image:
    image_sizes = zeros(num_organoids, 4);
    for i = 1:num_organoids
       image_sizes(i,:) = size(features(i).(image_type_to_resize)); 
    end
    
    % get the tile size (maximum size of all images in each dimension):
    tile_size_XY = max(max(image_sizes(:, 1:2), [], 1));
    tile_size_Z = max(image_sizes(:,3));
    tile_size_channel = image_sizes(1,4);
    
    % for each organoid:
    for i = 1:num_organoids
        
        % get the image:
        temp_image = features(i).(image_type_to_resize);
       
        % create empty array to store the re-sized image (tile):
        temp_tile = zeros(tile_size_XY, tile_size_XY, tile_size_Z, tile_size_channel, 'like', temp_image);

        % get the coordinates for placing the image within the tile:        
        temp_col_start = max(round((tile_size_XY - image_sizes(i,2)) / 2), 1);
        temp_col_end = temp_col_start + image_sizes(i,2) - 1;
        temp_row_start = max(round((tile_size_XY - image_sizes(i,1)) / 2), 1);
        temp_row_end = temp_row_start + image_sizes(i,1) - 1;
        temp_slice_start = tile_size_Z - image_sizes(i,3) + 1;
        temp_slice_end = tile_size_Z;
        
        % place image into tile:
        temp_tile(temp_row_start:temp_row_end, ...
            temp_col_start:temp_col_end, ...
            temp_slice_start:temp_slice_end, :) = temp_image;
        
        % depending on the label type:
        switch type_label
            
            % if the user wants to add a label for the organoid:
            case {'Organoid Number', 'Both'}

                % get the image stack number:
                stack_num = features(i).name_stack;
                stack_num = str2double(stack_num(7:9));
                
                % add label to stitch:
                temp_tile = organoids.run_analysis.utilities.combine_all_images.create_stitched_image.add_label_to_stitch(temp_tile, sprintf('j%03d i%03d', features(i).job_number, stack_num), 'upper_left', 12);
            
        end
        
        % let tile replace image in the structure:
        features(i).(image_type_to_resize) = temp_tile;
        
    end

end