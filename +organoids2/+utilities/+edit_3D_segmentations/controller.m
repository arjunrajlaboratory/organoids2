classdef controller < handle
    
    properties
        
        % GUI data:
        seed_location;
        path_segmentations;
        path_images;
        list_segmentation_files;
        list_images;
        list_channels;
        num_channels;
        num_stacks;
        num_slices;
        current_stack;
        current_slice;
        current_step;
        image_width;
        image_height;
        image_display_stack;
        contrast_max;
        list_channel_names;
        list_channel_colors;
        channels_visibility;
        channels_color;
        axis_limits_x;
        axis_limits_y;
        
        % GUI components:       
        handle_figure;
        handle_axes;
        handle_contrast_slider;
        handle_navigation_stack_next;
        handle_navigation_stack_current;
        handle_navigation_stack_total;
        handle_navigation_stack_previous;
        handle_navigation_slice_next;
        handle_navigation_slice_current;
        handle_navigation_slice_total;
        handle_navigation_slice_previous;
        handle_navigation_step_size;
        handle_tools_draw;
        handle_all_channels;
        
        % model:
        m;
        
    end
    
    methods
        
        % constructor:
        function c = controller(v, gui_data)
                       
            % link to view:
            c.handle_figure =                               v.handle_figure;
            c.handle_axes =                                 v.handle_axes;
            c.handle_contrast_slider =                      v.handle_contrast_slider;
            c.handle_navigation_stack_previous =            v.handle_navigation_stack_previous;
            c.handle_navigation_stack_current =             v.handle_navigation_stack_current;
            c.handle_navigation_stack_total =               v.handle_navigation_stack_total;
            c.handle_navigation_stack_next =                v.handle_navigation_stack_next;
            c.handle_navigation_slice_previous =            v.handle_navigation_slice_previous;
            c.handle_navigation_slice_current =             v.handle_navigation_slice_current;
            c.handle_navigation_slice_total =               v.handle_navigation_slice_total;
            c.handle_navigation_slice_next =                v.handle_navigation_slice_next;
            c.handle_navigation_step_size =                 v.handle_navigation_step_size;
            c.handle_tools_draw =                           v.handle_tools_draw;
            c.handle_all_channels =                         v.handle_all_channels;
            
            % get GUI data:
            c.path_segmentations =          gui_data.path_segmentations;
            c.path_images =                 gui_data.path_images;
            c.list_segmentation_files =     gui_data.list_segmentation_files;
            c.list_images =                 gui_data.list_images;
            c.list_channels =               gui_data.list_channels;
            c.num_channels =                gui_data.num_channels;
           
            % set default slice and stack number:
            c.current_stack = 1;
            c.current_step = 5;
            c.contrast_max = 1;
            
            % get the number of stacks:
            c.num_stacks = numel(c.list_segmentation_files);

            % set only the dapi channel to be visible by default:
            c.channels_visibility = cell(1, c.num_channels);
            [c.channels_visibility{:}] = deal('off');
            c.channels_visibility{contains(c.list_channels, 'dapi')} = 'on';
            
            % set list of channel colors:
            c.list_channel_names = {'gray', 'blue', 'green', 'red'};
            c.list_channel_colors = {[0.5, 0.5, 0.5], [0.0, 0.0, 1.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0]};
            
            % for each channel:
            for i = 1:c.num_channels
                
                % assign list of colors to the popupmenu:
                c.handle_all_channels.(sprintf('popupmenu_%01d', i)).String = c.list_channel_names;
               
                % assign each channel to a color:
                c.channels_color{i} = i;
                c.handle_all_channels.(sprintf('popupmenu_%01d', i)).Value = c.channels_color{i};
                
            end
            
            % load the image and segmentations:
            c = load_data(c);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % function to load data for an image stack:
        function c = load_data(c)
            
            % load the segmentations:
            c.m = organoids2.utilities.edit_3D_segmentations.model(fullfile(c.path_segmentations, c.list_segmentation_files{c.current_stack}));
            
%             % assign each segmentation a color (based on it's 3D object) -
%             % useful for debugging:
%             list_object_nums = unique(extractfield(c.m.segmentations, 'object_num'));
%             colors = organoids2.utilities.distinguishable_colors(numel(list_object_nums));
%             for i = 1:numel(c.m.segmentations)
%                 c.m.segmentations(i).color = colors(list_object_nums == c.m.segmentations(i).object_num, :);
%             end
            
            % convert the segmentations to the new reference frame:
            c.m.segmentations = c.convert_XY_coords_to_XZ_coords(c.m.segmentations);
            
            % have the segmentations save when the window closes:
            c.handle_figure.CloseRequestFcn = @c.callback_close_window;
            
            % get the image name:
            image_name = c.list_segmentation_files{c.current_stack}(end-9:end-4);
            
            % load the image for display:
            c.image_display_stack = c.load_stack(c.path_images, image_name, c.list_channels);
            
            % if you want to work on buds:
            if contains(c.list_segmentation_files{c.current_stack}, 'buds_guess')
                
                % use a max merge for display:
                c.image_display_stack = max(c.image_display_stack, [], 3);
                
            end
            
            % update number of image size:
            c.num_slices = size(c.image_display_stack, 3);
            c.image_width = size(c.image_display_stack, 2);
            c.image_height = size(c.image_display_stack, 1);
            
            % update the current slice:
            c.current_slice = 1;
           
            % update the zoom:
            c.axis_limits_x = [0.5 c.image_width + 0.5];
            c.axis_limits_y = [0.5 c.image_height + 0.5];
            
            % set the axis limits:
            set(c.handle_axes, 'XLim', c.axis_limits_x);
            set(c.handle_axes, 'YLim', c.axis_limits_y);
            
        end
        
        % function to update the display:
        function c = update_display(c)

            % get the current axis limits:
            c.axis_limits_x = get(c.handle_axes, 'XLim');
            c.axis_limits_y = get(c.handle_axes, 'YLim');
            
            % create a blank image to display:
            image_display_slice = zeros(c.image_height, c.image_width, 3, 'like', c.image_display_stack);
            
            % for each channel:
            for i = 1:numel(c.channels_visibility)
                
                % if the channel should be on:
                if strcmp(c.channels_visibility{i}, 'on')
                    
                    % get the color to use for the channel:
                    temp_color = c.list_channel_colors{c.channels_color{i}};
                    
                    % get the image to use:
                    temp_image = repmat(squeeze(c.image_display_stack(:,:,c.current_slice,i)), [1, 1, 3]);
                    
                    % convert the image to RGB:
                    for j = 1:3
                        temp_image(:,:,j) = temp_image(:,:,j) * temp_color(j);
                    end
                    
                    % add it to the display:
                    image_display_slice = image_display_slice + temp_image;
                    
                end
                
            end
            
            % show the current image slice:
            image_display_slice = imadjust(image_display_slice, [0 c.contrast_max]);
            
            % re-apply the axis limits (this maintains zoom):
            set(c.handle_axes, 'XLim', c.axis_limits_x);
            set(c.handle_axes, 'YLim', c.axis_limits_y);
            
            % if there are any segmentations:
            if ~ischar(c.m.segmentations)
            
                % get segmentations on the slice:
                segmentations_slice = organoids2.utilities.get_structure_results_containing_number(c.m.segmentations, 'slice_xz', c.current_slice);
                
                % if there are any segmentations on the slice:
                    if ~isempty(segmentations_slice)

                    % get list of object numbers on the slice:
                    list_object_nums = unique(extractfield(segmentations_slice, 'object_num'));

                    % get a color for each segmentation:
                    colors = organoids2.utilities.distinguishable_colors(numel(list_object_nums), {'w', 'k'});

                    % for each segmentation on the slice:
                    for i = 1:numel(segmentations_slice)

                        object_num = segmentations_slice(i).object_num;

                        coords = segmentations_slice(i).mask_xz;
                        coords_slice = coords(coords(:,3) == c.current_slice, :);

                        for k = 1:size(coords_slice, 1)
                            image_display_slice(coords_slice(k, 2), coords_slice(k, 1), :) = colors(list_object_nums == object_num, :) * 65535;
                            % image_display_slice(coords_slice(k, 2), coords_slice(k, 1), :) = segmentations_slice(i).color * 65535;
                        end

                    end
                
                end
            
            end
            
            % show the current image slice:
            imshow(image_display_slice, 'Parent', c.handle_axes);
            
            % update the slider position:
            set(c.handle_contrast_slider, 'Value', c.contrast_max);
            
            % display the stack and slice numberss:
            c.handle_navigation_stack_current.String = c.current_stack;
            c.handle_navigation_stack_total.String = c.num_stacks;
            c.handle_navigation_slice_current.String = c.current_slice;
            c.handle_navigation_slice_total.String = c.num_slices;
            c.handle_navigation_step_size.String = c.current_step;
            
            % update previous stack button visibility:
            if c.current_stack == 1
                c.handle_navigation_stack_previous.Enable = 'inactive';
            else
                c.handle_navigation_stack_previous.Enable = 'on';
            end
            
            % update the next stack button visibility:
            if c.current_stack == c.num_stacks
                c.handle_navigation_stack_next.Enable = 'inactive';
            else
                c.handle_navigation_stack_next.Enable = 'on';
            end
            
            % update previous slice button visibility:
            if c.current_slice == 1
                c.handle_navigation_slice_previous.Enable = 'inactive';
            else
                c.handle_navigation_slice_previous.Enable = 'on';
            end
            
            % update the next slice button visibility:
            if c.current_slice == c.num_slices
                c.handle_navigation_slice_next.Enable = 'inactive';
            else
                c.handle_navigation_slice_next.Enable = 'on';
            end
            
        end
        
        % callback to adjust contrast:
        function c = callback_contrast(c, ~, ~)
            
            % update the contrast:
            c.contrast_max = get(c.handle_contrast_slider, 'Value');
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callbcak to go to previous stack:
        function c = callback_stack_previous(c, ~, ~)
            
            % decrease the stack number:
            c.current_stack = max((c.current_stack - 1), 1);
            
            % save the segmentations:
            c.m.save_segmentations;
            
            % load the stack:
            c = load_data(c);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callback to change current stack:
        function c = callback_stack_current(c, ~, ~)
            
            % get the new stack:
            stack_new = str2double(c.handle_navigation_stack_current.String);
            
            % if the new stack is valid:
            if (stack_new >= 1) && (stack_new <= c.num_stacks)
                
                % update the current slice:
                c.current_stack = stack_new;
            
                % save the segmentations:
                c.m.save_segmentations;
                
                % load the stack:
                c = load_data(c);
                
                % update the display:
                c = update_display(c);
                
            % otherwise:
            else 
                
                warndlg('Value is out of range!');
            
            end
            
        end
        
        % callbcak to go to next stack:
        function c = callback_stack_next(c, ~, ~)
            
            % increase the stack number:
            c.current_stack = min((c.current_stack + 1), c.num_stacks);
            
            % save the segmentations:
            c.m.save_segmentations;
            
            % load the stack:
            c = load_data(c);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callbcak to go to previous slice:
        function c = callback_slice_previous(c, ~, ~)
            
            % decrease the slice number:
            c.current_slice = max((c.current_slice - c.current_step), 1);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callback to change current slice:
        function c = callback_slice_current(c, ~, ~)
            
            % get the new slice:
            slice_new = str2double(c.handle_navigation_slice_current.String);
            
            % if the new slice is valid:
            if (slice_new >= 1) && (slice_new <= c.num_slices)
                
                % update the current slice:
                c.current_slice = slice_new;
            
                % update the display:
                c = update_display(c);
                
            % otherwise:
            else 
                
                warndlg('Value is out of range!');
            
            end
            
        end
        
        % callback to go to next slice:
        function c = callback_slice_next(c, ~, ~)
            
            % increase the stack number:
            c.current_slice = min((c.current_slice + c.current_step), c.num_slices);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callback to change the step size:
        function c = callback_step_size(c, ~, ~)
            
            % get the new step size:
            step_new = str2double(c.handle_navigation_step_size.String);
            
            % if the new slice is valid:
            if (step_new >= 1) && (step_new <= c.num_slices)
                
                % update the current slice:
                c.current_step = step_new;
            
                % update the display:
                c = update_display(c);
                
            % otherwise:
            else 
                
                warndlg('Value is out of range!');
            
            end
            
        end
        
        % callback to create a segmentation by drawing:
        function c = callback_draw(c, ~, ~)
            
            % let the user draw on the image:
            coords_drawn = drawline(c.handle_axes, 'Color', 'white');
            
            % if the user actually clicked:
            if isgraphics(coords_drawn)

                % get coordinates:
                coords_drawn = round(coords_drawn.Position);
                
                [coords_drawn_column, coords_drawn_row, ~] = improfile(c.image_display_stack(:,:,1,1), [coords_drawn(1,1) coords_drawn(end,1)], [coords_drawn(1,2) coords_drawn(end,2)]);
                coords_drawn = [round(coords_drawn_column) round(coords_drawn_row)];
                
                % get segmentations on the slice:
                [segmentations_slice, indices_slice] = organoids2.utilities.get_structure_results_containing_number(c.m.segmentations, 'slice_xz', c.current_slice);
                
                % add field to store intersection:
                [segmentations_slice(1:end).intersect] = deal('no');
                
                % for each segmentation on the slice:
                for i = 1:numel(segmentations_slice)
                    
                    % get coordinates of the segmentation on the slice:
                    coords = segmentations_slice(i).mask_xz;
                    coords_slice = coords(coords(:,3) == c.current_slice, :);
                                        
                    % check if the object overlaps with the drawn line:
                    if any(ismember(coords_drawn, coords_slice(:,1:2), 'rows'))
                        segmentations_slice(i).intersect = 'yes';
                    end

                end
                
                % get list of segmentation ids that belong to the new
                % object:
                [~, indices_new_object] = organoids2.utilities.get_structure_results_matching_string(segmentations_slice, 'intersect', 'yes');
                indices_new_object = indices_slice(indices_new_object);
                
                % add object to model:
                c.m = c.m.change_object_number(indices_new_object);

                % update the display:
                c = update_display(c);
            
            end
            
        end
        
        % callback for changing channel toggle:
        function c = callback_channels_change_visibility(c, ~, ~, channel_number)
            
            % depending on the state of the toggle:
            switch c.channels_visibility{channel_number}
               
                % if it is on:
                case 'on'
                    
                    % turn it off:
                    c.channels_visibility{channel_number} = 'off';
                    
                % if it is off:
                case 'off'
                    
                    % turn it on:
                    c.channels_visibility{channel_number} = 'on';
                
            end
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callback for changing channel color:
        function c = callback_channels_change_color(c, ~, ~, channel_number)
            
            % update the channel assignment:
            c.channels_color{channel_number} = get(c.handle_all_channels.(sprintf('popupmenu_%01d', channel_number)), 'Value');
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callback to close the window:
        function callback_close_window(c, ~, ~)
            
            c.m.save_segmentations;
            delete(c.handle_figure);
            
        end
        
    end
    
    methods (Static)
        
        % function to load an image stack:
        function stack_stretched = load_stack(path_images, image_name, list_channels)
            
            % for each channel:
            for i = 1:numel(list_channels)
               
                % load the channel:
                temp_channel = readmm(fullfile(path_images, sprintf('%s_%s.tif', image_name, list_channels{i})));
                temp_channel = temp_channel.imagedata;
                
                if i == 1
                    
                    stack = temp_channel;
                    
                else
                    
                    stack(:,:,:,i) = temp_channel;
                    
                end
                
            end
            
            % adjust the contrast of each slice - this will make deeper
            % slices similar brightness to shallow slices
            for i = 1:size(stack, 4)
               for j = 1:size(stack, 3)
                  stack(:,:,j,i) = imadjust(squeeze(stack(:,:,j,i))); 
               end
            end
            
            % change the order of dimensions:
            stack = permute(stack, [3 2 1 4]);
            
            % stretch the stack in Z:
            stack_stretched = zeros([(6 * size(stack, 1)) size(stack, 2) size(stack, 3) size(stack, 4)], 'like', stack);
            for i = 1:size(stack, 4)
                stack_stretched(:,:,:,i) = imresize3(squeeze(stack(:,:,:,i)), [(6 * size(stack, 1)) size(stack, 2) size(stack, 3)], 'nearest');
            end
            
            % smooth the stack to make the nuclei more round:
            for i = 1:size(stack_stretched, 4)
               for j = 1:size(stack_stretched, 3)
                  stack_stretched(:,:,j,i) = imgaussfilt(squeeze(stack_stretched(:,:,j,i)), [2 0.5]);
               end
            end

        end
        
        % function to get segmentations in XZ:
        function segmentations = convert_XY_coords_to_XZ_coords(segmentations)

            % for each segmentation:
            for i = 1:numel(segmentations)
                
                % get the coordinates:
                boundary_xz = segmentations(i).boundary;
                mask_xz = segmentations(i).mask;
                
                % flip the order of the coordinates:
                boundary_xz = [boundary_xz(:,1), boundary_xz(:,3), boundary_xz(:,2)];
                mask_xz = [mask_xz(:,1), mask_xz(:,3), mask_xz(:,2)];
                
                % scale the coordinates:
                boundary_xz(:,2) = boundary_xz(:,2) * 6;
                mask_xz(:,2) = mask_xz(:,2) * 6;
                
                % adjust coords to fit in middle of stretched pixels:
                boundary_xz(:,2) = boundary_xz(:,2) - 3;
                mask_xz(:,2) = mask_xz(:,2) - 3;
                
                % save:
                segmentations(i).boundary_xz = boundary_xz;
                segmentations(i).mask_xz = mask_xz;
                segmentations(i).slice_xz = unique(boundary_xz(:,3));

            end

        end
        
    end
    
end