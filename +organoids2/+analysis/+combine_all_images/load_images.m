function features = load_images(features, paths)

    % add field to store images to features struct:
    [features(1:end).images] = deal(struct);
    [features(1:end).outlines] = deal(struct);
    [features(1:end).images_outlines] = deal(struct);

    % for each organoid:
    for i = 1:numel(features)

        % get image name:
        temp_name_image = features(i).name_stack;
        
        disp(temp_name_image);

        % get the job number:
        temp_job = features(i).job_number;

        % get the path to the image:
        temp_path = paths{contains(paths, num2str(temp_job))};

        % load RGB image:
        temp_image = load(fullfile(temp_path, '16_other_original', [temp_name_image '_rgb.mat']));
        temp_image = temp_image.image_save;
        
        % swap order of channel and z-slice:
        temp_image = permute(temp_image, [1 2 4 3]);

        % load the segmentations:
        temp_objects = quantiuspipeline.utilities.load_structure_from_file(fullfile(temp_path, '16_other_original', [temp_name_image '_all.mat']));
        
        % use the segmentations to crop the image stack to be ONLY the
        % bottom half of the organoid:
        temp_image = crop_images(temp_image, temp_objects);
        
        % create blank image to store outlines:
        temp_outlines = temp_image;
        temp_outlines(:) = 0;
        temp_images_outlines = temp_image;
        
        % get outline types:
        temp_types_outlines = fieldnames(temp_objects.seg_2D);

        % for each type of object:
        for j = 1:numel(temp_types_outlines)
            
            % get segmentation type:
            temp_segmentation_type = temp_types_outlines{j};
            
            % depending on the segmentation type:
            switch temp_segmentation_type
               
                case 'nuclei'
                    
                    temp_color_outlines = [0 0 0];
                    temp_color_image_outlines = [0 0 0];
                    temp_type_fill_outlines = 'outline';
                    temp_type_fill_image_outlines = 'outline';
                    
                case 'lumens'
                    
                    temp_color_outlines = [0 1 0];
                    temp_color_image_outlines = [1 0 0];
                    temp_type_fill_outlines = 'outline';
                    temp_type_fill_image_outlines = 'outline';
                    
                case 'organoid'
                    
                    temp_color_outlines = [0 1 0];
                    temp_color_image_outlines = [1 0 0];
                    temp_type_fill_outlines = 'outline';
                    temp_type_fill_image_outlines = 'outline';
                
            end
            
            % add outlines:
            temp_outlines = add_outlines_to_image(temp_outlines, temp_objects.seg_2D.(temp_segmentation_type), temp_color_outlines, temp_type_fill_outlines);
            temp_images_outlines = add_outlines_to_image(temp_images_outlines, temp_objects.seg_2D.(temp_segmentation_type), temp_color_image_outlines, temp_type_fill_image_outlines);
            
        end
        
        % save:
        features(i).images = temp_image;
        features(i).outlines = temp_outlines;
        features(i).images_outlines = temp_images_outlines;

    end

end

function image = crop_images(image, objects)

    % create a 3D mask of the organoid segmentations:
    masks_organoid = organoids.measure_features.measure_features_automatic.get_3D_mask(objects.seg_3D.organoid, objects.height, objects.width, objects.depth);
    
    % get the slice at the middle of the organoid (where area largest):
    slice_middle = organoids.measure_features.measure_features_automatic.get_slice_largest_area(masks_organoid);
    slice_middle = slice_middle.slice;

    % remove slices above the middle slice:
    image(:,:,slice_middle+1:end,:) = [];

end

function image = add_outlines_to_image(image, objects, color, type_fill)

    % format color for image's bit depth:
    if isa(color, 'char') == 0
        if isa(image, 'uint8')
            color = color * (2^8);
        elseif isa(image, 'uint16')
            color = color * (2^16);
        elseif isa(image, 'uint32')
            color = color * (2^32);
        elseif isa(image, 'uint64')
            color = color * (2^64);
        end
    end
    
    % for each object:
    for i = 1:numel(objects)
        
        % if there are any objects:
        if ~ischar(objects)
        
            % if the object is on the image (it may not be given that the
            % images were cropped):
            if objects(i).slices <= size(image, 3)

                % format coords:
                coords_formatted = quantiuspipeline.utilities.add_result_to_image.format_coords_for_plotting(objects(i).coordinates(:,1:2));

                % if there are at least 5 coords:
                if numel(coords_formatted) >= 6

                    % depending on the fill:
                    switch type_fill

                        case 'filled'

                            % add to image:
                            image(:,:,objects(i).slices,:) = insertShape(...
                                squeeze(image(:,:,objects(i).slices,:)), ...
                                'FilledPolygon', coords_formatted, ...
                                'Color', color, ...
                                'Opacity', 1, ...
                                'LineWidth', 3);

                        case 'filled_black'

                            % add to image:
                            image(:,:,objects(i).slices,:) = insertShape(...
                                squeeze(image(:,:,objects(i).slices,:)), ...
                                'FilledPolygon', coords_formatted, ...
                                'Color', [0 0 0], ...
                                'Opacity', 1, ...
                                'LineWidth', 3);

                            % add to image:
                            image(:,:,objects(i).slices,:) = insertShape(...
                                squeeze(image(:,:,objects(i).slices,:)), ...
                                'Polygon', coords_formatted, ...
                                'Color', color, ...
                                'LineWidth', 3);

                        case 'outline'

                            % add to image:
                            image(:,:,objects(i).slices,:) = insertShape(...
                                squeeze(image(:,:,objects(i).slices,:)), ...
                                'Polygon', coords_formatted, ...
                                'Color', color, ...
                                'LineWidth', 3);

                    end

                end

            end
        
        end

    end

end