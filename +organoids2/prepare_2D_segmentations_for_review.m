function prepare_2D_segmentations_for_review

    % get the name of the structure to segment:
    [~, structure_to_segment, ~] = fileparts(pwd);
    structure_to_segment = structure_to_segment(15:end);
    
    % if that structure is nuclei:
    if strcmp(structure_to_segment, 'nuclei')
        
        % format the results from nucleaizer:
        process_nucleaizer_results('slices_XY', 'nuclei_XY');
        process_nucleaizer_results('slices_XZ', 'nuclei_XZ');
        
    end

    % get a list of the 2D segmentation files:
    list_files = dir('*guess_2D*.mat');
    
    % for each file:
    for i = 1:numel(list_files)
        
        % get the original file name:
        file_name_original = list_files(i).name;

        % get the new file name:
        file_name_new = strrep(file_name_original, 'guess', 'final');
        
        % depending on the name of the structure:
        switch structure_to_segment
            
            % for buds:
            case 'buds'
                
                % load the segmentations:
                segmentations_guess = organoids2.utilities.load_structure_from_file(file_name_original);
                
                % create the structure to store segmentations:
                segmentations_final = organoids2.review_2D_segmentations.model(file_name_new);
                
                % if there are no segmentations:
                if ischar(segmentations_guess)
                    
                    % do nothing:
                    
                % otherwise
                else
                    
                    % load the image:
                    image = readmm(fullfile(list_files(i).folder, '..', sprintf('%s_dapi.tif', list_files(i).name(end-9:end-4))));
                    num_slices = image.numplanes;
                    
                    % get the number of annotations on each slice:
                    num_annotations_per_slice = numel(segmentations_guess);

                    % for each annotation:
                    for j = 1:num_annotations_per_slice

                        % for each slice:
                        for k = 1:num_slices

                            % get the boundary coords:
                            coords_boundary = segmentations_guess(j).boundary;

                            % get the mask coords:
                            coords_mask = segmentations_guess(j).mask;

                            % update the slice number on the coords:
                            coords_boundary(:,3) = deal(k);
                            coords_mask(:,3) = deal(k);

                            % add the data:
                            segmentations_final = segmentations_final.add_segmentation(coords_boundary, coords_mask);

                        end

                    end

                end
                
                % save the segmentations:
                segmentations_final.save_segmentations;
                
            % for everything else:
            otherwise

                % copy and rename the file:
                copyfile(file_name_original, file_name_new);
                
        end

        
    end

end

% function to format nucleaizer results:
function process_nucleaizer_results(folder, structure_name)

    % get a list of all results files:
    list_files = dir(fullfile(folder, 'results', 'pos*.tiff'));
    
    % get a list of all image stacks:
    list_images = unique(cellfun(@(x) x(1:6), extractfield(list_files, 'name'), 'UniformOutput', false));
    
    % for each image stack:
    for i = 1:numel(list_images)
       
        % create a structure to store the results:
        results = struct;

        % start the index tracker:
        index = 1;

        % get a list of all relevant results files:
        list_files_image_stack = organoids2.utilities.get_structure_results_containing_string(list_files, 'name', list_images{i});
        
        % for each results file:
        for j = 1:numel(list_files_image_stack)
            
            % load the mask:
            mask = readmm(fullfile(list_files_image_stack(j).folder, list_files_image_stack(j).name));
            mask = mask.imagedata;

            % get a list of object numbers:
            list_object_nums = unique(mask);
            list_object_nums(list_object_nums == 0) = [];

            % get the number of objects:
            num_objects = numel(list_object_nums);
            
            % for each object:
            for k = 1:num_objects

                % get the mask for just that object:
                mask_object = mask == list_object_nums(k);

%                 % erode the mask:
%                 mask_object = imerode(mask_object, strel('disk', 1));

                % get the boundary:
                boundary = bwboundaries(mask_object);

                % if there are any boundaries:
                if numel(boundary) ~= 0

                    % get the slice number:
                    num_slice = str2double(list_files_image_stack(j).name(9:11));

                    % get boundary:
                    coords_x = boundary{1}(:,2);
                    coords_y = boundary{1}(:,1);

                    % format boundary and mask (like I normally do):
                    [coords_boundary, coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(coords_x, coords_y, size(mask, 2), size(mask, 1), num_slice);

                    % save:
                    results(index).slice = num_slice;
                    results(index).segmentation_id = index;
                    results(index).boundary = coords_boundary;
                    results(index).mask = coords_mask;

                    % increment the index:
                    index = index + 1;

                end

            end
            
        end

        % save the results:
        save(sprintf('%s_guess_2D_%s.mat', structure_name, list_images{i}), 'results');
        
    end

end