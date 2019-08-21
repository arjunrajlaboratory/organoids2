function [features, color_key] = assign_color_scheme(features, scheme)

    %%% First, we want to establish a color key (map between value and
    %%% specific color).

    % depending on the scheme, set the colormap:
    switch scheme
        
        case 'color by number lumens'
            
            % get the list of the number of lumens:
            list_values = unique(extractfield(features, 'feature_number_lumens'));
            
            % convert to cell:
            list_values = num2cell(list_values);
            
            % get color key:
            color_key = create_color_key(list_values);
            
            % set 1 lumen to black:
            [~, index] = quantiuspipeline.utilities.get_structure_results_matching_number(color_key, 'value', 1);
            color_key(index).color = [0.0 0.0 0.0];
            
        case 'color by condition'
            
            % get the list of conditions:
            list_values = unique(extractfield(features, 'number_condition'));
            
            % convert to cell:
            list_values = num2cell(list_values);
            
            % get color key:
            color_key = create_color_key(list_values);
            
            % set normal to black:
            color_key(1).color = [0.0 0.0 0.0];
            
            % set DMSO to gray:
            color_key(2).color = [0.5 0.5 0.5];
            
        case 'color by drug'
            
            % get the list of conditions:
            list_values = unique(extractfield(features, 'drug'));
            
            % create array to store order for values:
            order = zeros(numel(list_values), 1);
            
            % get order to use for values:
            for i = 1:numel(list_values)
                temp = quantiuspipeline.utilities.get_structure_results_matching_string(features, 'drug', list_values{i});
                order(i) = temp(1).number_condition;
            end
            [~, order] = sort(order);
            
            % sort the conditions in order: 
            list_values = list_values(order);
            
            % get color key:
            color_key = create_color_key(list_values);
            
            % set normal to black:
            color_key(1).color = [0.0 0.0 0.0];
            
            % set DMSO to gray:
            color_key(2).color = [0.5 0.5 0.5];
            
        case 'color by perfection'
            
            % set the list of values:
            list_values = {'perfect', 'imperfect'};
            
            % get the color key:
            color_key = create_color_key(list_values);
            
        case 'color by job'
            
            % set the list of values:
            list_values = unique(extractfield(features, 'job_number'));
            
            % convert to cell:
            list_values = num2cell(list_values);
            
            % get the color key:
            color_key = create_color_key(list_values);
            
    end
    
    %%% Next, we want to assign a color to each organoid based on it's
    %%% value and the color key.
   
    % create field to store color:
    [features(1:end).color] = deal([]);
    
    % for each organoid:
    for i = 1:numel(features)
        
        % depending on the scheme:
        switch scheme
                
            case 'color by number lumens'
                
                % get the number of lumens:
                temp_value = features(i).feature_number_lumens;
                
                % get the matching color key entry:
                temp_color_key = quantiuspipeline.utilities.get_structure_results_matching_number(color_key, 'value', temp_value);
                
            case 'color by condition'

                % get condition:
                temp_value = features(i).number_condition;
                
                % get the matching color key entry:
                temp_color_key = quantiuspipeline.utilities.get_structure_results_matching_number(color_key, 'value', temp_value);
                
            case 'color by drug'
                
                % get the drug:
                temp_value = features(i).drug;
                
                % get the matching color key entry:
                temp_color_key = quantiuspipeline.utilities.get_structure_results_matching_string(color_key, 'value', temp_value);
                
            case 'color by perfection'
                
                % get the name of stack:
                temp_stack = features(i).name_stack;
                
                % get the list of "perfect" organoids:
                list_perfect_organoids = get_list_perfect_organoids;
                
                % if the organoid is perfect:
                if contains(temp_stack, list_perfect_organoids)
                    
                    % get the matching part of the key:
                    temp_color_key = quantiuspipeline.utilities.get_structure_results_matching_string(color_key, 'value', 'perfect');
  
                % otherwise:
                else
                    
                    % get the matching part of the key:
                    temp_color_key = quantiuspipeline.utilities.get_structure_results_matching_string(color_key, 'value', 'imperfect');
                    
                end
                
            case 'color by job'
                
                % get the job number:
                temp_value = features(i).job_number;
                
                % get the matching part of the key:
                temp_color_key = quantiuspipeline.utilities.get_structure_results_matching_number(color_key, 'value', temp_value);
                
        end
        
        % save:
        features(i).color = temp_color_key.color;
        
    end

end

function color_key = create_color_key(list_values)
    
    % get number of values:
    num_values = numel(list_values);
    
    % get color for each value:
    colors = distinguishable_colors(num_values, {'w', 'k'});
    
    % create structure to store color key:
    [color_key(1:num_values).value] = deal('');
    [color_key(1:num_values).color] = deal([]);
    
    % for each value:
    for i = 1:num_values
        
        % get value:
        color_key(i).value = list_values{i};
        
        % get color:
        color_key(i).color = colors(i, :);
        
    end
    
end

function list_perfect = get_list_perfect_organoids

    list_perfect = {'j046_i007','j046_i009','j046_i013','j046_i025','j046_i033','j046_i034','j046_i040','j046_i042','j046_i043','j046_i045','j046_i052','j046_i055',...
        'j048_i003','j048_i016','j048_i034','j048_i055','j048_i059','j048_i068','j048_i075','j048_i078',...
        'j054_i003','j054_i007','j054_i008','j054_i011','j054_i013','j054_i016','j054_i019','j054_i026','j054_i032','j054_i033','j054_i036','j054_i038',...
        'j058_i022','j058_i035','j058_i043','j058_i045','j058_i049','j058_i050','j058_i062','j058_i096','j058_i136','j058_i143','j058_i150'};

end