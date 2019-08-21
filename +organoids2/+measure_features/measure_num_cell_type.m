function num_cells = measure_num_cell_type(coordinates)

    % if there are any coordinates:
    if ~isempty(coordinates)

        % get number of cells:
        num_cells = numel(unique(coordinates(:,1)));
    
    % otherwise:
    else
        
        num_cells = 0;
        
    end

end