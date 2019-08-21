function num_objects = measure_number_objects(objects)

    % if there are any objects:
    if isstruct(objects)
        
        num_objects = numel(objects);
        
    % otherwise:
    else
        
        num_objects = 0;
        
    end
    
end
