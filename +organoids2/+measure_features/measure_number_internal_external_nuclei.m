function [number_nuclei_internal, number_nuclei_external] = measure_number_internal_external_nuclei(seg_lumens, seg_nuclei)

    % if there are any lumens:
    if isstruct(seg_lumens)
        
        % get the centroid of each nucleus:
        coords_nuclei_centroid = zeros(numel(seg_nuclei), 3);
        for i = 1:numel(seg_nuclei)
            coords_nuclei_centroid(i,:) = mean(seg_nuclei(i).boundary);
        end

        % get the boundary coordinates of ALL lumens:
        coords_lumens_all = [];
        for i = 1:numel(seg_lumens)
           coords_lumens_all = [coords_lumens_all; seg_lumens(i).boundary]; 
        end
        
        % determine which nuclear centroids are within the convex hull of
        % the lumens:
        inside = tsearchn(coords_lumens_all, delaunay(coords_lumens_all), coords_nuclei_centroid);
        
        % get the number of internal and external nuclei:
        number_nuclei_internal = nnz(~isnan(inside));
        number_nuclei_external = nnz(isnan(inside));
        
    % otherwise:
    else
        
        % get the number of internal and external nuclei:
        number_nuclei_internal = 0;
        number_nuclei_external = numel(seg_nuclei);
        
    end

end