function height = measure_height(seg)

    % if there are NO objects:
    if ~isstruct(seg)
        
        height = NaN;
        
    % otherwise:
    else
        
        % get number of objects:
        num_objects = numel(seg);

        % create array to store height:
        height = zeros(num_objects, 1);

        % for each object:
        for i = 1:num_objects

            % get height:
            height(i) = range(seg(i).boundary_um(:,3));

        end
        
    end

end