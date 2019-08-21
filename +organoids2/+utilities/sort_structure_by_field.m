function structure_sorted = sort_structure_by_field(structure, field_names, directions)

    % if no direction is given:
    if nargin < 3
        
        % set default directions to ascending:
        [directions{1:numel(field_names)}] = deal('ascend');
        
    end
    
    % if only a single field is given:
    if ischar(field_names)
        
        % convert to cell:
        field_names = cellstr(field_names);
        directions = cellstr(directions);
        
    end
    
    % if you want to sort by one field:
    if numel(field_names) == 1

        % if the field contains numeric data:
        if isnumeric(structure(1).(field_names{1}))

            % get the field:
            field_entries = [structure.(field_names{1})];

        elseif ischar(structure(1).(field_names{1}))

            % get the field:
            field_entries = {structure.(field_names{1})};

        else

            % return an error:
            error('No code for how to sort based on %s class');

        end

        % get the order to sort by:
        [~, order] = sort(field_entries);
        
        % depending on the direction to sort:
        switch directions{1}
            
            case 'ascend'
                
                % do nothing, it already sorts that direction by default
                
            case 'descend'
                
                % reverse the direction:
                order = flip(order);
        end
        
    % if you want to sort by multiple fields:
    elseif numel(field_names) > 1
        
        % get index of field names to sort by:
        [~, field_numbers] = ismember(field_names, fieldnames(structure));
        
        % convert structure to a cell:
        structure_as_cell = squeeze(struct2cell(structure))';
        
        % sort the cell by the field names:
        [~, order] = sortrows(structure_as_cell, field_numbers, directions);
        
    end
    
    % apply the order to the structure:
    structure_sorted = structure(order);

end