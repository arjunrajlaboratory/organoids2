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
        
        % add segmentation:
        function m = add_segmentation(m, coords_boundary, coords_mask)
            
            % get list of all possible segmentation ids:
            list_segmentation_ids = 1:m.max_num_segmentations;
            
            % if there are any segmentations:
            if ischar(m.segmentations)
                
                % get list of used segmentation ids:
                list_segmentation_ids_used = [];
                
            % otherwise:
            else
                
                % get list of used segmentation ids:
                list_segmentation_ids_used = extractfield(m.segmentations, 'segmentation_id');
                
            end
            
            % get list of used segmentation ids:
            segmentation_ids_unused = setdiff(list_segmentation_ids, list_segmentation_ids_used);
            
            % choose unused segmentation id at random:
            segmentation_id = datasample(segmentation_ids_unused, 1, 'Replace', false);
            
            % if the structure contains no segmentations:
            if ischar(m.segmentations)
                
                % get index to add:
                index = 1;
                
                % convert segmentations to structure:
                m.segmentations = struct;
                m.segmentations.slice = 0;
                m.segmentations.boundary = [];
                m.segmentations.mask = [];
                m.segmentations.segmentation_id = 0;
                
            % otherwise:
            else
                
                % get index to add:
                index = numel(m.segmentations) + 1;
                
            end
            
            % add data to structure:
            m.segmentations(index) = struct('slice', coords_boundary(1,3), 'boundary', coords_boundary, 'mask', coords_mask, 'segmentation_id', segmentation_id);
            
        end
        
        % delete segmentation:
        function m = delete_segmentation(m, segmentation_ids)
            
            % get number of segmentations to remove:
            num_segmentations_remove = numel(segmentation_ids);
            
            % create array to store rows to remove:
            rows_remove = zeros(num_segmentations_remove, 1);
            
            % for each annotation id:
            for i = 1:num_segmentations_remove
                
                % get row of matching segmentation:
                [~, rows_remove(i)] = organoids2.utilities.get_structure_results_matching_number(m.segmentations, 'segmentation_id', segmentation_ids(i));
                
            end
            
            % remove rows:
            m.segmentations(rows_remove) = [];

            % if the structure is empty now:
            if isempty(m.segmentations)

                % set structure to none:
                m.segmentations = 'none';

            end
            
        end
        
        % edit segmentation:
        function m = edit_segmentation(m, segmentation_id, coords_boundary, coords_mask)
            
            % get the row of the segmentation to update:
            [~, row] = organoids2.utilities.get_structure_results_matching_number(m.segmentations, 'segmentation_id', segmentation_id);
            
            % update the segmentation:
            m.segmentations(row).boundary = coords_boundary;
            m.segmentations(row).mask = coords_mask;
            
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