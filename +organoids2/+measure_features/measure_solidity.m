function solidities = measure_solidity(masks)

    % if there are any objects:
    if isstruct(masks)

        % get number of objects:
        number_objects = numel(masks);

        % create array to store volumes:
        solidities = zeros(number_objects, 1);

        % for each object:
        for i = 1:number_objects

            % get the solidity of the object:
            solidity = regionprops3(masks(i).mask_3D, 'Solidity');
            solidities(i) = solidity.Solidity;

        end
        
    % otherwise:
    else
        
        solidities = NaN;
        
    end

end