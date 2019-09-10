function [stitch, features] = rows(features, image_field_to_use)

    %%% First, we want to arrange the organoids from each perturbation into
    %%% 1 row. 

    % get list of conditions:
    list_conditions = unique(extractfield(features, 'number_condition'));
    
    % get number of conditions:
    num_conditions = numel(list_conditions);
    
    % create structure to store the rows:
    [rows(1:num_conditions).image] = deal('');
    [rows(1:num_conditions).name_condition] = deal('');
    
    % for each condition:
    for i = 1:num_conditions
        
        % get the organoids for the condition:
        features_condition = quantiuspipeline.utilities.get_structure_results_matching_number(features, 'number_condition', list_conditions(i));
        
        % get name of the condition:
        name_condition = features_condition(1).name_condition;
        
        % create image to store the row:
        temp_row = [];
        
        % for each organoid:
        for j = 1:numel(features_condition)
           
            % add image to the row:
            temp_row = cat(2, temp_row, features_condition(j).(image_field_to_use));
            
        end
        
        % save the row:
        rows(i).image = temp_row;
        rows(i).name_condition = name_condition;
        
    end
    
    %%% Next, we want to make it so that each row is the same size. This
    %%% means padding smaller rows with zeros. 

    % get size of each row:
    size_rows = zeros(num_conditions, 4);
    for i = 1:num_conditions
       size_rows(i,:) = size(rows(i).image); 
    end
    
    % get maximum size of row to fit all rows:
    size_row_max = max(size_rows, [], 1);
    
    % for each row:
    for i = 1:numel(rows)
       
        % get row:
        temp_row = rows(i).image;
        
        % create empty array to store the resized row:
        temp_row_resize = zeros(size_row_max, 'like', temp_row);
        
        % get coords for placing row into resized row:
        col_start = max(round((size_row_max(2) - size(temp_row, 2))/2), 1);
        col_end = col_start + size(temp_row, 2) - 1;
        
        % place row into resized row:
        temp_row_resize(:, col_start:col_end, :, :) = temp_row;
        
        % save the resized row:
        rows(i).image = temp_row_resize;
        
    end
    
    %%% Next, we want to label each row with the name of the condition:
    
    % for each row:
    for i = 1:numel(rows)
       
        % add label to stitch:
        rows(i).image = organoids.run_analysis.utilities.combine_all_images.create_stitched_image.add_label_to_stitch(rows(i).image, rows(i).name_condition, 'upper_left', 12);
        
    end
    
    %%% Next, we want to arrange all rows into one stitched image. 
    
    % create empty array to store the stitch:
    stitch = [];
    
    % for each row:
    for i = 1:numel(rows)
       
        % add row to the stitch:
        stitch = cat(1, stitch, rows(i).image);
        
    end
    
end