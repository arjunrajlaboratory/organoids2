function prepare_2D_segmentations_for_review

    % get the name of the structure to segment:
    name_structure = organoids2.utilities.ask_user_what_structure_to_segment;

    % get a list of the 2D segmentation files:
    list_files = dir('*guess_2D*.mat');
    
    % for each file:
    for i = 1:numel(list_files)
        
        % get the original file name:
        file_name_original = list_files(i).name;

        % get the new file name:
        file_name_new = strrep(file_name_original, 'guess', 'final');
        
        % depending on the name of the structure:
        switch name_structure
            
            % for buds:
            case 'buds_guess'
                
                % load the segmentations:
                segmentations_guess= organoids2.utilities.load_structure_from_file(file_name_original);
                
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