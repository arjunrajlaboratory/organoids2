function [legend_markers, legend_labels] = format_legend(structure_with_colors, field_label, field_color)

    % get a list of the labels:
    list_legend_values = unique(extractfield(structure_with_colors, field_label), 'stable');
    
    % if the list is an array: 
    if isvector(list_legend_values)
        list_legend_values = num2cell(list_legend_values);
    end
    
    % get a list of the colors:
    list_legend_colors = cell(size(list_legend_values));
    for k = 1:numel(list_legend_values)
        
        % get the legend value:
        temp_value = list_legend_values{k};
        
        % if the value is a string:
        if iscell(temp_value)
            temp_key_features = organoids2.utilities.get_structure_results_matching_string(structure_with_colors, field_label, temp_value);
        % if the value is a number:
        else
            temp_key_features = organoids2.utilities.get_structure_results_matching_number(structure_with_colors, field_label, temp_value);
        end

        % get the color:
        list_legend_colors{k} = temp_key_features(1).(field_color);
        
    end
    
    % get the number of items:
    num_items = numel(list_legend_values);
    
    % create cell to store labels:
    list_legend_values_new = {num_items, 1};
    for i = 1:num_items
        if isnumeric(list_legend_values{i})
            list_legend_values_new{i} = num2str(list_legend_values{i});
        else
            list_legend_values_new{i} = list_legend_values{i}{1};
        end
    end
    
    % create cells to store markers and labels:
    legend_markers = zeros(num_items, 1);
    legend_labels = cell(num_items, 1);
    
    % for each item:
    for i = 1:num_items
        legend_markers(i) = scatter(nan, nan, 70, list_legend_colors{i}, 'filled', 'MarkerEdgeColor', 'none');
        legend_labels{i} = ['\color[rgb]' sprintf('{%d,%d,%d} %s', list_legend_colors{i}(1), list_legend_colors{i}(2), list_legend_colors{i}(3), list_legend_values_new{i})];
    end

end