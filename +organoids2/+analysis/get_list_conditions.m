function list_conditions = get_list_conditions(features_struct, formatting)

    % get conditions names:
    list_conditions_names = unique(extractfield(features_struct, 'name_condition'), 'stable');
    
    % get condition numbers (do not sort):
    list_condition_numbers = unique(extractfield(features_struct, 'number_condition'), 'stable');
    
    % sort condition names so they appear in order of condition number:
    [~, order] = sort(list_condition_numbers);
    list_conditions = list_conditions_names(order);
    
    % depending on the formatting:
    switch formatting
        
        case 'on'
            
            % get the condition key:
            condition_key = organoids.run_analysis.get_key_of_conditions;
            
            % for each condition in the list:
            for i = 1:numel(list_conditions)
                
                % get the matching entry of the condition key:
                temp = quantiuspipeline.utilities.get_structure_results_matching_string(condition_key, 'name_condition', list_conditions{i});
                
                % update the entry with the formatted text:
                list_conditions{i} = [temp.concentration_value ' ' temp.concentration_units ' ' temp.drug];
                
            end
            
        case 'off'
            
            % do nothing
           
    end

end