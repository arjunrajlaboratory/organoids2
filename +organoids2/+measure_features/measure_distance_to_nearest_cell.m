function distances = measure_distance_to_nearest_cell(coordinates)

    % if there are NO cells:
    if isempty(coordinates)
        
        distances = [];
        
    % otherwise:
    else

        % get number of cells:
        num_cells = numel(unique(coordinates(:,1)));

        % create array to store mean cell coordinates:
        coordinates_mean = zeros(num_cells, 3);

        % for each cell:
        for i = 1:num_cells

            % get coordinates for the cell:
            coordinates_cell = coordinates(coordinates(:,1) == i, 2:4);

            % get mean coordinate:
            coordinates_mean(i,:) = mean(coordinates_cell, 1);

        end

        % create array to store distances:
        distances = zeros(num_cells, 1);

        % for each cell:
        for i = 1:num_cells

            % get the cell coordinate:
            coordinates_mean_cell = coordinates_mean(i,:);

            % get the coordinates of all other cells:
            coordinates_mean_others = coordinates_mean;
            coordinates_mean_others(i,:) = [];

            % get the distance between the cell and all other cells:
            distances_cells = pdist2(coordinates_mean_cell, coordinates_mean_others);

            % get the minimum distance between the cell and other cells:
            distances(i) = min(distances_cells);

        end
    
    end
    
end