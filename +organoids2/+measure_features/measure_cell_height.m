function heights = measure_cell_height(coordinates, voxel_size_z)

    % if there are NO cells:
    if isempty(coordinates)
        
        heights = [];
        
    % otherwise:
    else

        % get list of cells:
        list_cells = unique(coordinates(:,1));

        % get number of cells:
        num_cells = numel(list_cells);

        % create array to store heights:
        heights = zeros(num_cells, 1);

        % for each cell:
        for i = 1:num_cells

            % get the coordinates for the cell:
            coordinates_cell = coordinates(coordinates(:,1) == i, :);

            % get the number of slices the cell is on:
            num_slices = numel(unique(coordinates_cell(:,4)));

            % scale the number of slices by the distance between slices:
            heights(i) = num_slices * voxel_size_z;

        end
    
    end

end