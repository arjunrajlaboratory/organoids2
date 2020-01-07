function radius_Z = measure_radius_Z(seg)

    % if there are NO objects:
    if ~isstruct(seg)
        
        radius_Z = NaN;
        
    % otherwise:
    else
        
        % get number of objects:
        num_objects = numel(seg);

        % create array to store height:
        radius_Z = zeros(num_objects, 1);

        % for each object:
        for i = 1:num_objects

            % get height:
            radius_Z(i) = range(seg(i).boundary_um(:,3));

        end
        
    end

end