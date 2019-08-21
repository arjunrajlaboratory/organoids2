classdef model < handle
    
    properties
        
        path_file;
        segmentations;
        
    end
    
    methods
        
        % constructor:
        function m = model(path_file)
            
            % get the complete path to the file containing segmentations:
            m.path_file = path_file;

            % load the segmentations:
            m.segmentations = organoids2.utilities.load_structure_from_file(m.path_file);
                
        end
        
        % change connection:
        function m = change_connection(m, segmentation_id, new_object_number)
            
            % get the row of the segmentation to update:
            [~, row] = organoids2.utilities.get_structure_results_matching_number(m.segmentations, 'segmentation_id', segmentation_id);
            
            % update the connection number:
            m.segmentations(row).object_num = new_object_number;
            
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