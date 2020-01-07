function external_cell_width = measure_external_cell_width(seg_lumens, seg_nuclei)

    % get the centroid of each nucleus:
    coords_nuclei_centroid = zeros(numel(seg_nuclei), 3);
    for i = 1:numel(seg_nuclei)
        coords_nuclei_centroid(i,:) = mean(seg_nuclei(i).boundary_um);
    end

    % get the boundary coordinates of ALL lumens:
    coords_lumens_all = [];
    for i = 1:numel(seg_lumens)
       coords_lumens_all = [coords_lumens_all; seg_lumens(i).boundary_um]; 
    end

    % determine which nuclear centroids are within the convex hull of
    % the lumens:
    inside = tsearchn(coords_lumens_all, delaunay(coords_lumens_all), coords_nuclei_centroid);

    % get the number of external nuclei:
    number_nuclei_external = nnz(isnan(inside));

    % get the external nuclei:
    coords_nuclei_centroid_external = coords_nuclei_centroid(isnan(inside), :);

    % create an array to store distance between each external nucleus
    % and it's closest neighbor:
    external_cell_width = zeros(number_nuclei_external, 1);

    % for each external nucleus:
    for i = 1:number_nuclei_external

        % nucleus to use:
        coords_use = coords_nuclei_centroid_external(i,:);

        % all other nuclei:
        coords_other = coords_nuclei_centroid_external;
        coords_other(i,:) = [];

        % get the distance between the nucleus and all other nuclei:
        distances = pdist2(coords_use, coords_other);

        % get the distance to the closest neighbor:
        external_cell_width(i) = min(distances);

    end

end