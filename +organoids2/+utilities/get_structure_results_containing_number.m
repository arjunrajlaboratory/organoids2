function [structure_match, rows_output] = get_structure_results_containing_number(structure, field, number)
    
    % create array to store list of rows to keep:
    rows = [];
    
    % for each entry in the structure:
    for i = 1:numel(structure)
       
        % determine if number is in the entry:
        if ismember(number, structure(i).(field), 'rows')
            
            % add to list of rows to keep:
            rows = [rows, i];
            
        end
        
    end
    
    % get rows to return:
    structure_match = structure(1, rows);

    % return rows if prompted:
    if nargout > 1

        rows_output = rows;

    end

end