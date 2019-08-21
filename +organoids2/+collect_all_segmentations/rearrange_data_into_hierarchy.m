function data = rearrange_data_into_hierarchy(data, organoid_type)

    % get levels of data organization:
    % NOTE: level 1 should include only 1 object.
    % NOTE: level 2 objects should fit entirely in level 1 object
    % NOTE: level 3 objects will be split into either level 2 object
    switch organoid_type
        case 'MDCK'
            list_objects_level_1 = {'organoid'};
            list_objects_level_2 = {'lumens', 'nuclei'};
            list_objects_level_3 = {};
        case 'Intestine'
            list_objects_level_1 = {'organoid'};
            list_objects_level_2 = {'buds', 'cyst'};
            list_objects_level_3 = {'lumens', 'cells_Paneth', 'cells_Lgr5'};
    end
    
    % for each type of object in the second level of organization:
    for i = 1:numel(list_objects_level_2)
        
        % assign to the first level of organization:
        data.segmentations.(list_objects_level_1{1}).children.(list_objects_level_2{i}) = data.segmentations.(list_objects_level_2{i});
        
        % remove:
        data.segmentations = rmfield(data.segmentations, list_objects_level_2{i});
        
        % for each type of object in the third level of organization:
        for j = 1:numel(list_objects_level_3)
            
            % assign to the first level of organization:
            data.segmentations.(list_objects_level_1{1}).children.(list_objects_level_2{i}).children.(list_objects_level_3{j}) = data.segmentations.(list_objects_level_3{j});
            
        end
        
    end
    
    % remove:
    data.segmentations = rmfield(data.segmentations, list_objects_level_3);
    
    %%% Next, we want to remove level 3 objects (or parts of objects) that
    %%% are not within the bounds of level 2 objects. For example, we need
    %%% to make sure that the lumen coordinates saved under organoids.buds
    %%% are the lumen coordinates within the bud (and not the cyst).
    
    % for each level 2 organization:
    for i = 1:numel(list_objects_level_2)
        
        % get the level 2 data:
        data_level_2 = data.segmentations.organoid.children.(list_objects_level_2{i});
        
        % if the level 2 data is empty:
        if ischar(data_level_2)
            
            % set the level 3 objects to empty:
            for j = 1:numel(list_objects_level_3)
                data_leveL_2.children.(list_objects_level_3{j}) = 'none';
            end
            
            
        % otherwise:
        else
            
            % for each level 3 object:
            for j = 1:numel(list_objects_level_3)
                
                
                
            end
            
        end
        
        % save:
        data.segmentations.organoid.children.(list_objects_level_2{i}) = data_level_2;
        
    end

    temp = 4;

end