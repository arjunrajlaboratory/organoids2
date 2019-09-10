function [features, type_sort_string] = sort_organoids(features, list_features, type_sort)

    % depending on the type of sort:
    switch type_sort
        
        % if you want to sort by feature:
        case {'By_Feature', 'By_Perturbation_Then_Feature'}
    
            % get feature number to sort by:
            feature_sort = listdlg('ListString', list_features, 'SelectionMode', 'single');

            % get feature name to sort by:
            feature_sort = list_features{feature_sort};
            
            % get string of feature to sort by:
            feature_sort_string = regexprep(feature_sort, '_', ' ');
            
    end

    % start the label for how images were sorted:
    type_sort_string = 'sorted ';
    
    % depending on the type of sort:
    switch type_sort

        case 'By_Perturbation'

            % sort the features:
            features = quantiuspipeline.utilities.sort_structure_by_field(features, 'number_condition');
            
            % finish the label for how the images were sorted:
            type_sort_string = [type_sort_string 'by drug'];
            
        case 'By_Perturbation_Then_Feature'
            
            % sort the features:
            features = quantiuspipeline.utilities.sort_structure_by_field(features, {'number_condition', feature_sort});

            % finish the label for how the images were sorted:
            type_sort_string = [type_sort_string sprintf('by drug then %s', feature_sort_string)];
            
        case 'By_Feature'

            % sort structure by that field:
            features = quantiuspipeline.utilities.sort_structure_by_field(features, feature_sort);
            
            % finish the label for how the images were sorted:
            type_sort_string = [type_sort_string feature_sort_string];

        case 'Randomly'
            
            % get number of organoids:
            num_organoids = numel(features);

            % randomly shuffle the order of the organoids:
            temp_new_order = randperm(num_organoids);

            % create new structure to store shuffled organoids:
            temp_features = features;

            % shuffle structure:
            for i = 1:num_organoids
                temp_features(i) = features(temp_new_order(i));
            end

            % replace structure:
            features = temp_features;
            
            % finish the label for how the images were sorted:
            type_sort_string = [type_sort_string 'randomly'];

        otherwise

            % return error:
            error('No code for sorting images using on this method');

    end

end