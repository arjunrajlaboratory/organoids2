function data = get_bud_and_cyst_segmentation(data)

    % if there are NO bud segmentations:
    if ischar(data.segmentations.buds)
        
        % the cyst segmentations are exactly the same as the organoid
        % segmentations:
        data.segmentations.cyst = data.segmentations.organoid;
        
    % otherwise:
    else
        
        %%% First, we create a mask. The pixels belonging to the organoid
        %%% are set to 1. Then, we set any pixels beloning to the organoid
        %%% AND within a bud boundary to a number specific to the bud. 
        
        % create an empty mask:
        mask = zeros(data.height, data.width, data.depth);

        % add the organoid segmentation to the mask (I don't use poly2mask
        % because the algorithm sometimes does not fill the exact
        % coordinates):
        for i = 1:numel(data.segmentations.organoid)
            for j = 1:size(data.segmentations.organoid(i).mask, 1)
                mask(data.segmentations.organoid(i).mask(j,1), data.segmentations.organoid(i).mask(j,2), data.segmentations.organoid(i).mask(j,3)) = 1;
            end
        end
        
        % for each bud:
        for i = 1:numel(data.segmentations.buds)

            % for each coordinate:
            for j = 1:size(data.segmentations.buds(i).mask, 1)
                
                % get the coordinate:
                coord = data.segmentations.buds(i).mask(j,:);
                
                % if the pixel overlaps with the organoid segmentation:
                if mask(coord(:,1), coord(:,2), coord(:,3)) == 1
                    
                    % set the pixel to the bud number:
                    mask(coord(:,1), coord(:,2), coord(:,3)) = data.segmentations.buds(i).object_num + 1;
                    
                end
                
            end

        end
        
        %%% Next, we want to get the segmentations of the cyst (all mask
        %%% pixels = 1).
        
        % get the mask of just the cyst:
        mask_cyst = mask == 1;
        
        % create structure to store the cyst segmentations:
        segmentations_cyst = struct;
        
        % for each slice in the mask:
        for i = 1:size(mask_cyst, 3)
            
            % get the mask:
            mask_cyst_slice = mask_cyst(:,:,i);
            
            % if there are any objects on the mask:
            if nnz(mask_cyst_slice) > 0
            
                % get the mask coords:
                [coords_mask_x, coords_mask_y] = find(mask_cyst_slice == 1);
                coords_mask = [coords_mask_y, coords_mask_x];

                % get the boundary coords:
                coords_boundary = bwboundaries(mask_cyst_slice);
                coords_boundary = coords_boundary{1};

                % add slice to the coords:
                coords_mask(:,3) = deal(i);
                coords_boundary(:,3) = deal(i);

                % save:
                segmentations_cyst(end+1).slice = i;
                segmentations_cyst(end).boundary = coords_boundary;
                segmentations_cyst(end).mask = coords_mask;
                segmentations_cyst(end).object_num = 1;
            
            end
            
        end
        
        % save:
        segmentations_cyst(1) = [];
        data.segmentations.cyst = segmentations_cyst;
        
        %%% Next, we want to get the segmentations of the buds (all the mask
        %%% pixels > 1).
        
        % create structure to store the bud segmentations:
        segmentations_bud = struct;
        
        % get list of buds:
        list_buds = unique(mask);
        list_buds = list_buds(list_buds > 1);
        
        % for each bud:
        for i = 1:numel(list_buds)
            
            % get the mask of just the bud:
            mask_bud = mask == list_buds(i);
            
            % for each slice in the mask:
            for j = 1:size(mask_bud, 3)

                % get the mask:
                mask_bud_slice = mask_bud(:,:,j);

                % if there are any objects on the mask:
                if nnz(mask_bud_slice) > 0

                    % get the mask coords:
                    [coords_mask_x, coords_mask_y] = find(mask_bud_slice == 1);
                    coords_mask = [coords_mask_y, coords_mask_x];

                    % get the boundary coords:
                    coords_boundary = bwboundaries(mask_bud_slice);
                    coords_boundary = coords_boundary{1};

                    % add slice to the coords:
                    coords_mask(:,3) = deal(j);
                    coords_boundary(:,3) = deal(j);

                    % save:
                    segmentations_bud(end+1).slice = j;
                    segmentations_bud(end).boundary = coords_boundary;
                    segmentations_bud(end).mask = coords_mask;
                    segmentations_bud(end).object_num = list_buds(i);

                end

            end

        end
        
        % save:
        segmentations_bud(1) = [];
        data.segmentations.buds = segmentations_bud;
        
    end
    
end