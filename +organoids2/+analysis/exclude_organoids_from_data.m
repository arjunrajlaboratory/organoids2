function features_struct = exclude_organoids_from_data(features_struct, list_stacks_remove)

    % create array to store list of rows to remove:
    features_rows_remove = [];
    
    % for each organoid to remove:
    for i = 1:size(list_stacks_remove, 1)
        
        % figure out which row of the features table that organoid is in:
        [~, temp] = quantiuspipeline.utilities.get_structure_results_matching_string(features_struct, 'name_stack', sprintf('j%03d_i%03d', list_stacks_remove(i,1), list_stacks_remove(i,2)));
        
        % add that row to the list of rows to remove:
        features_rows_remove = [features_rows_remove, temp];
        
    end
    
    % remove organoids from the list of features:
    features_struct(features_rows_remove) = [];

end