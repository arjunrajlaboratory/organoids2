classdef model < handle
    
    properties
        
        path_file;
        max_num_objects;
        segmentations;
        
    end
    
    methods
        
        % constructor:
        function m = model(path_file)
            
            % get the complete path to the file containing segmentations:
            m.path_file = path_file;
            
            % set the maximum number of objects:
            m.max_num_objects = 100000;
            
            % if the file already exists:
            if exist(m.path_file, 'file')
            
                % load it:
                m.segmentations = organoids2.utilities.load_structure_from_file(m.path_file);
           
            % otherwise:
            else
                
                % set segmentations to none:
                m.segmentations = 'none';
                
            end
                
        end
        
        % add segmentation:
        function m = change_object_number(m, indices_new_object)
            
            % get list of all possible object nums:
            list_object_nums = 1:m.max_num_objects;

            % get list of used object nums:
            list_object_nums_used = unique(extractfield(m.segmentations, 'object_num'));
            
            % get list of unused object nums:
            list_object_nums_unused = setdiff(list_object_nums, list_object_nums_used);
            
            % choose unused object num at random:
            object_num = datasample(list_object_nums_unused, 1, 'Replace', false);
            
            % update the object numbers:
            for i = 1:numel(indices_new_object)
               m.segmentations(indices_new_object(i)).object_num = object_num; 
            end
            
        end
        
        % save segmentations:
        function save_segmentations(m)
            
            % if there are any segmentations:
            if ~ischar(m.segmentations)

                % sort the segmentations by slice they appear on:
                m.segmentations = organoids2.utilities.sort_structure_by_field(m.segmentations, 'slice');

            end
            
            % save the data:
            data_to_save = m.segmentations;
            save(m.path_file, 'data_to_save');
            
        end
        
    end
    
end