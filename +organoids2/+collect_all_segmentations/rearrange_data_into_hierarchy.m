function data = rearrange_data_into_hierarchy(data, organoid_type)

    %%% First, we want to split the data into the different ways we will
    %%% analyze it (compare each organoid, compare each bud, etc).

    % create structure to store the different organizations:
    organization_list = struct;
    
    % depending on the organoid type:
    switch organoid_type
        
        case 'MDCK'
            
            % per-organoid:
            organization_list(1).name = 'per_organoid';
            organization_list(1).segmentation_parent = 'organoid';
            organization_list(1).segmentations_children = {'lumens', 'nuclei'};
            
        case 'Intestine'
            
            % per-organoid:
            organization_list(1).name = 'per_organoid';
            organization_list(1).segmentation_parent = 'organoid';
            organization_list(1).segmentations_children = {'buds', 'cyst', 'lumens', 'cells_Lgr5', 'cells_Paneth'};
            
            % per-bud:
            organization_list(2).name = 'per_bud';
            organization_list(2).segmentation_parent = 'buds';
            organization_list(2).segmentations_children = {'lumens', 'cells_Lgr5', 'cells_Paneth'};
            
            % per-bud:
            organization_list(3).name = 'per_cyst';
            organization_list(3).segmentation_parent = 'cyst';
            organization_list(3).segmentations_children = {'lumens', 'cells_Lgr5', 'cells_Paneth'};
            
    end
    
    % for each organization:
    for i = 1:numel(organization_list)
        
        % get the name of the organization:
        name_organization = organization_list(i).name;
        
        % get the parent segmentations:
        segmentations_parent = data.segmentations.(organization_list(i).segmentation_parent);
        
        % create a structure to store the organized segmentations:
        data_organized = struct;
        
        % if there are no parent segmentations:
        if ischar(segmentations_parent)
            
            data_organized = 'none';
            
        % otherwise:
        else
        
            % for each parent segmentation:
            for k = 1:numel(segmentations_parent)
            
                % create a mask from the parent segmentation:
                mask_parent = zeros(data.height, data.width, data.depth);
                for j = 1:size(segmentations_parent(k).mask, 1)
                    mask_parent(segmentations_parent(k).mask(j,2), segmentations_parent(k).mask(j,1), segmentations_parent(k).mask(j,3)) = 1;
                end

                % for each type of child segmentation:
                for j = 1:numel(organization_list(i).segmentations_children)
                    
                    % if the child segmentations exist:
                    if isfield(data.segmentations, organization_list(i).segmentations_children{j})

                        % get the child segmentations:
                        segmentations_child = data.segmentations.(organization_list(i).segmentations_children{j});

                        % cut segmentations to make sure they fit within the parent
                        % segmentation:
                        segmentations_child = get_child_segmentations_within_parent(segmentations_child, mask_parent);

                        % save:
                        data_organized(k).(organization_list(i).segmentations_children{j}) = segmentations_child;
                    
                    end

                end
                
                % save the parent segmentations as the organoid segmentations:
                data_organized(k).organoid = segmentations_parent(k);

            end
        
        end
        
        % save:
        data.segmentations.(name_organization) = data_organized;
        
    end
    
    % remove non-organized segmentations:
    list_fields = fieldnames(data.segmentations);
    list_segmentations = list_fields(~contains(list_fields, 'per'));
    data.segmentations = rmfield(data.segmentations, list_segmentations);

end

% function to get child segmentations within parent:
function segmentations_child_new = get_child_segmentations_within_parent(segmentations_child, mask_parent)

    % create structure to stoew new child segmentations:
    segmentations_child_new = struct;
    
    % if there are no child segmentations:
    if ischar(segmentations_child)
        
        segmentations_child_new = 'none';
        
    % otherwise
    else
    
        % for each child segmentation:
        for i = 1:numel(segmentations_child)

            % create mask from the segmentations (pixels of parent and child overlap will be 2):
            mask_overlap = mask_parent;
            for j = 1:size(segmentations_child(i).mask)
                mask_overlap(segmentations_child(i).mask(j,2), segmentations_child(i).mask(j,1), segmentations_child(i).mask(j,3)) = mask_overlap(segmentations_child(i).mask(j,2), segmentations_child(i).mask(j,1), segmentations_child(i).mask(j,3)) + 1;
            end
            mask_overlap = mask_overlap == 2;

            % if there is any overlap:
            if nnz(mask_overlap) > 0

                % create arrays to store new child segmentations:
                slices = [];
                boundary = [];
                mask = [];

                % for each mask slice:
                for j = 1:size(mask_overlap, 3)

                    % get the slice number:
                    num_slice_temp = j;

                    % get the mask on the slice:
                    mask_overlap_slice = mask_overlap(:,:,num_slice_temp);

                    % if there is overlap on the slice:
                    if nnz(mask_overlap_slice) > 0

                        % get the mask coords:
                        [mask_x, mask_y] = find(mask_overlap_slice == 1);
                        mask_temp = [mask_y, mask_x];

                        % get the boundary coords:
                        boundary_temp = bwboundaries(mask_overlap_slice);
                        boundary_temp = boundary_temp{1};

                        % add slice to the coords:
                        mask_temp(:,3) = deal(j);
                        boundary_temp(:,3) = deal(j);

                        % save:
                        slices = [slices, num_slice_temp];
                        boundary = [boundary; boundary_temp];
                        mask = [mask; mask_temp];

                    end

                end

                % save:
                segmentations_child_new(end+1).object_num = segmentations_child(i).object_num;
                segmentations_child_new(end).slices = slices;
                segmentations_child_new(end).boundary = boundary;
                segmentations_child_new(end).mask = mask;

            end

        end

        % if there are no child segmentations left, set to none:
        if numel(fieldnames(segmentations_child_new)) == 0
            segmentations_child_new = 'none';
        else
            segmentations_child_new(1) = [];
        end
    
    end

end