function snap_bud_boundary_to_organoid_segmentation

    % get the list of segmentation files:
    list_files = dir('*guess_3D*.mat');
    
    % for each file:
    for i = 2:numel(list_files)

        % create array to store any rows to remove:
        rows_remove = [];
        
        % load the file that contains the bud boundaries:
        buds = organoids2.utilities.load_structure_from_file(list_files(i).name);
        
        % if there are any buds:
        if ~ischar(buds)

            % get the stack name:
            stack_name = list_files(i).name(end-9:end-4);
            
            % load the file that contains the organoid segmentation:
            organoid = organoids2.utilities.load_structure_from_file(fullfile(pwd, '..', 'segmentations_organoid', sprintf('organoid_final_2D_%s.mat', stack_name)));

            % get the image size:
            image_info = organoids2.utilities.load_structure_from_file(fullfile(pwd, '..', sprintf('image_info_%s.mat', stack_name)));
            width = image_info.height;
            height = image_info.width;

            % for each bud boundary:
            for j = 1:numel(buds)

                % get the organoid segmentations on the slice of the bud boundary:
                organoid_slice = organoids2.utilities.get_structure_results_matching_number(organoid, 'slice', buds(j).slice);

                % if there are any organoid segmentations on the slice:
                if numel(organoid_slice) > 0
                
                    % for each organoid segmentation on the slice:
                    for k = 1:numel(organoid_slice)

                        % get the indices of organoid coordinates within the bud
                        % boundary:
                        organoid_slice(k).indices_inside = inpolygon(organoid_slice(k).mask(:,1), organoid_slice(k).mask(:,2), buds(j).boundary(:,1), buds(j).boundary(:,2));
                        organoid_slice(k).indices_inside = find(organoid_slice(k).indices_inside);

                        % get the nuber of coordinates inside:
                        organoid_slice(k).number_coords_inside = nnz(organoid_slice(k).indices_inside);

                    end

                    % get the amount of overlap for each organoid segmentation:
                    overlap = extractfield(organoid_slice, 'number_coords_inside');

                    % if no segmentations overlap:
                    if nnz(overlap) == 0

                        % add this row to the list of segmentations to remove:
                        rows_remove = [rows_remove, j];

                    else

                        % get the segmentation with the largest overlap to keep:
                        [~, index] = max(overlap);
                        coords = organoid_slice(index).mask(organoid_slice(index).indices_inside, :);
                        
                        coords_boundary = bwboundaries(coords);
                        coords_boundary = fliplr(coords_boundary{1});
                        
                        coords(:,3) = deal(organoid_slice(index).slice);
                        coords_boundary(:,3) = deal(organoid_slice(index).slice);
                        
                        buds(j).mask_final = coords;
                        buds(j).boundary_final = coords_boundary;
                        
%                         [buds(j).boundary_final, buds(j).mask_final] = organoids2.utilities.get_boundary_and_mask_from_coords(coords(:,1), coords(:,2), width, height, organoid_slice(index).slice);

                    end
                
                elseif numel(organoid_slice) == 0
                    
                    % add this row to the list of segmentations to remove:
                    rows_remove = [rows_remove, j];
                    
                end
                
            end       

            % remove extra fields:
            buds = rmfield(buds, 'boundary');
            buds = rmfield(buds, 'mask');

            % rename the fields:
            buds = cell2struct(struct2cell(buds), {'slice', 'segmentation_id', 'object_num', 'boundary', 'mask'});
            
            % remove any rows that did not have overlapping segmentation:
            buds(rows_remove) = [];
            
            % save the file:
            save(list_files(i).name, 'buds');
        
        end
        
    end

end