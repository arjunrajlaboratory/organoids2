function external_cell_height = measure_external_cell_height(method, seg_lumens, seg_organoid)

    % if there are any lumens:
    if isstruct(seg_lumens)

        % depending on what method the user specifies:
        switch method

            case 'nearest_lumen_point'

                external_cell_height = measure_using_nearest_lumen_point(seg_lumens, seg_organoid);
                
        end
        
        external_cell_height = mean(external_cell_height);
    
    % otherwise:
    else
        
        external_cell_height = NaN;
        
    end

end

function external_cell_height = measure_using_nearest_lumen_point(seg_lumens, seg_organoid)

    % get coordinates of the organoid:
    coords_organoid = seg_organoid.boundary_um;

    % get coordinates of lumen:
    coords_lumens = [];
    for i = 1:numel(seg_lumens)
        coords_lumens = [coords_lumens; seg_lumens(i).boundary_um];
    end

    % get number of organoid coordinates:
    num_coords_organoid = size(coords_organoid, 1);
    
    % create empty array to store cell height:
    external_cell_height = zeros(num_coords_organoid, 1);
    
    % for each organoid coordinate:
    for i = 1:num_coords_organoid
       
        % get the cell height as the distance between the organoid
        % coordinate and the nearest lumen coordinate:
        external_cell_height(i) = min(pdist2(coords_organoid(i,:), coords_lumens, 'euclidean'));
        
    end

end