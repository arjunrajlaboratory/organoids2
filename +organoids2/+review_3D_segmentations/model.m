classdef model < handle
    
    properties
        
        path_file;
        max_num_segmentations;
        segmentations;
        
    end
    
    methods
        
        % constructor:
        function m = model(path_file)
            
            % get the complete path to the file containing segmentations:
            m.path_file = path_file;
            
            % set the maximum number of segmentations:
            m.max_num_segmentations = 100000;
            
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
        
        % change object number:
        function m = change_object_number(m, segmentation_ids, object_number)
            
            % for each segmentation to update:
            for i = 1:numel(segmentations_ids)
            
                % get the row of the segmentation to update:
                [~, row] = organoids2.utilities.get_structure_results_matching_number(m.segmentations, 'segmentation_id', segmentation_ids(i));

                % update the object number:
                m.segmentations(row).object_number = object_number;
                
            end
            
        end
        
        % save segmentations:
        function save_segmentations(m)
            
%             % if there are any segmentations:
%             if ~ischar(m.segmentations)
% 
%                 % sort the segmentations by slice they appear on:
%                 m.segmentations = organoids2.utilities.sort_structure_by_field(m.segmentations, 'slice');
% 
%             end
%             
%             % save the data:
%             data_to_save = m.segmentations;
%             save(m.path_file, 'data_to_save');
            
        end
        
    end
    
end