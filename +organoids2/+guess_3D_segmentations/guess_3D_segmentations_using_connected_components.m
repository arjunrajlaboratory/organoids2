function guess_3D_segmentations_using_connected_components

    % get the list of segmentation files:
    list_files = dir('*final_2D*.mat');
    
    % get the number of files:
    num_files = numel(list_files);

    % for each file:
    parfor i = 1:num_files
        
        % get the image name:
        image_name = list_files(i).name(end-9:end-4);
        
        % print status:
        fprintf('Working on stack %03d / %03d (%s) \n', i, num_files, image_name);
        
        % load the image to get image size:
        image = readmm(fullfile(pwd, '..', sprintf('%s_dapi.tif', image_name)));
        image_height = image.height;
        image_width = image.width;
        image_depth = image.numplanes;
        
        % load the segmentations:
        segmentations = organoids2.utilities.load_structure_from_file(list_files(i).name);
        
        % assign 3D object number:
        segmentations = assign_3D_object_number(segmentations, image_height, image_width, image_depth);
        
        % remove the segmentation id field:
        if ~ischar(segmentations)
            segmentations = rmfield(segmentations, 'segmentation_id');
        end
        
        % save segmentations:
        organoids2.utilities.save_within_parfor_loop(strrep(list_files(i).name, 'final_2D', 'guess_3D'), 'segmentations');
        
    end
    
end

% function to assign 3D object number:
function seg_2D = assign_3D_object_number(seg_2D, image_height, image_width, image_depth)

    % if there are objects:
    if isstruct(seg_2D)

        % create array to store mask:
        mask = zeros(image_height, image_width, image_depth, 'logical');

        % get number of 2D objects:
        num_objects_2D = numel(seg_2D);

        % for each 2D object:
        for k = 1:num_objects_2D

            % get object coordinates:
            coords = seg_2D(k).boundary;

            % NOTE: I do not use poly2mask because it works differently
            % from bwconncomp (the function used to obtain the
            % outlines). More info here:
            % https://blogs.mathworks.com/steve/2014/03/27/comparing-the-geometries-of-bwboundaries-and-poly2mask/.

            % for each coordinate:
            for l = 1:size(coords, 1)

                % add to mask:
                mask(coords(l,2), coords(l,1), coords(l,3)) = 1; 

            end

        end

        % NOTE: I do this per-slice because it does not work in 3D.

        % fill holes in the mask:
        for k = 1:image_depth
            mask(:,:,k) = imfill(mask(:,:,k), 'holes');
        end

        % convert to labeled mask:
        label = bwlabeln(mask);

        % for each 2D object:
        for k = 1:num_objects_2D

            % get object coordinates:
            coords = seg_2D(k).boundary;

            % determine which 3D object the 2D object belongs to:
            object_num = label(coords(1,2), coords(1,1), coords(1,3));

            % save:
            seg_2D(k).object_num = object_num;

        end

    end
    
end