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
        image_width;
        image_height;
        image_display_stack;
        image_calculate_stack;
        contrast_max;
        list_channel_names;
        list_channel_colors;
        channels_visibility;
        channels_color;
        channel_for_calculation;
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
        handle_tools_delete;
        handle_tools_automatic;
        handle_tools_flood;
        handle_tools_flood_number;
        handle_tools_draw;
        handle_tools_split;
        handle_tools_redraw;
        handle_tools_grow;
        handle_tools_grow_number;
        handle_all_channels;
        handle_segmentations;
        
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
            c.handle_tools_delete =                         v.handle_tools_delete;
            c.handle_tools_automatic =                      v.handle_tools_automatic;
            c.handle_tools_flood =                          v.handle_tools_flood;
            c.handle_tools_flood_number =                   v.handle_tools_flood_number;
            c.handle_tools_draw =                           v.handle_tools_draw;
            c.handle_tools_split =                          v.handle_tools_split;
            c.handle_tools_redraw =                         v.handle_tools_redraw;
            c.handle_tools_grow =                           v.handle_tools_grow;
            c.handle_tools_grow_number =                    v.handle_tools_grow_number;
            c.handle_all_channels =                         v.handle_all_channels;
            
            % get GUI data:
            c.seed_location =               gui_data.seed_location;
            c.path_segmentations =          gui_data.path_segmentations;
            c.path_images =                 gui_data.path_images;
            c.list_segmentation_files =     gui_data.list_segmentation_files;
            c.list_images =                 gui_data.list_images;
            c.list_channels =               gui_data.list_channels;
            c.num_channels =                gui_data.num_channels;
           
            % set default slice and stack number:
            c.current_stack = 1;
            c.contrast_max = 1;
            
            % get the number of stacks:
            c.num_stacks = numel(c.list_segmentation_files);
            
            % set the default channel for calculation:
            c.channel_for_calculation = 1;
            set(c.handle_all_channels.handle_button_group, 'SelectedObject', c.handle_all_channels.(sprintf('radiobutton_%01d', c.channel_for_calculation)));
            
            % set all channels to be visible by default:
            c.channels_visibility = cell(1);
            c.channels_visibility{1} = 'on';
            c.channels_visibility = repmat(c.channels_visibility, 1, c.num_channels);
            
            % set list of channel colors:
            c.list_channel_names = {'blue', 'green', 'red', 'gray'};
            c.list_channel_colors = {[0.0, 0.0, 1.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0], [0.5, 0.5, 0.5]};
            
            % for each channel:
            for i = 1:c.num_channels
                
                % assign list of colors to the popupmenu:
                c.handle_all_channels.(sprintf('popupmenu_%01d', i)).String = c.list_channel_names;
               
                % assign each channel to a color:
                c.channels_color{i} = i;
                c.handle_all_channels.(sprintf('popupmenu_%01d', i)).Value = c.channels_color{i};
                
            end
            
            % set the default numbers for various tools:
            set(c.handle_tools_flood_number, 'String', 1000);
            set(c.handle_tools_grow_number, 'String', 1);
            
            % load the image and segmentations:
            c = load_data(c);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % function to load data for an image stack:
        function c = load_data(c)
            
            % load the segmentations:
            c.m = organoids2.utilities.edit_2D_segmentations.model(fullfile(c.path_segmentations, c.list_segmentation_files{c.current_stack}));
            
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
            
            % get the image for calculations:
            c.image_calculate_stack = squeeze(c.image_display_stack(:,:,:,c.channel_for_calculation));
            
            % smooth the image to use for calculations:
            for i = 1:c.num_slices
                c.image_calculate_stack(:,:,i) = imgaussfilt(c.image_calculate_stack(:,:,i), 1);
            end

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
            imshow(imadjust(image_display_slice, [0 c.contrast_max]), 'Parent', c.handle_axes);
            
            % re-apply the axis limits (this maintains zoom):
            set(c.handle_axes, 'XLim', c.axis_limits_x);
            set(c.handle_axes, 'YLim', c.axis_limits_y);
            
            % if there were any segmentations:
            if exist('c.handle_segmentations', 'var')
                
                % delete the ROIs:
                delete(c.handle_segmentations);
                
            end
            
            % if there are any segmentations:
            if ~ischar(c.m.segmentations)
            
                % get segmentations on the slice:
                segmentations_slice = organoids2.utilities.get_structure_results_matching_number(c.m.segmentations, 'slice', c.current_slice);
                
                % get number of segmentations on the slice:
                num_segmentations_slice = numel(segmentations_slice);
                
                % get a color for each segmentation:
                colors = organoids2.utilities.distinguishable_colors(num_segmentations_slice, {'w', 'k'});
                
                % for each segmentation on the slice:
                for i = 1:num_segmentations_slice

                    % draw:
                    c.handle_segmentations{i} = drawfreehand(c.handle_axes, ...
                        'Position', segmentations_slice(i).boundary(:,1:2), ...
                        'Color', colors(i,:), ...
                        'FaceAlpha', 0, ...
                        'LineWidth', 2.0);

                    % add listener for the segmentation:
                    addlistener(c.handle_segmentations{i}, 'ROIMoved', @(src, eventdata)c.callback_edit(src, eventdata, segmentations_slice(i).segmentation_id));
                    
                end
            
            end
            
            % update the slider position:
            set(c.handle_contrast_slider, 'Value', c.contrast_max);
            
            % display the stack and slice numberss:
            c.handle_navigation_stack_current.String = c.current_stack;
            c.handle_navigation_stack_total.String = c.num_stacks;
            c.handle_navigation_slice_current.String = c.current_slice;
            c.handle_navigation_slice_total.String = c.num_slices;
            
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
            c.current_slice = max((c.current_slice - 1), 1);
            
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
        
        % callbcak to go to next slice:
        function c = callback_slice_next(c, ~, ~)
            
            % increase the stack number:
            c.current_slice = min((c.current_slice + 1), c.num_slices);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callback to delete a segmentation:
        function c = callback_delete(c, ~, ~)
            
            % let user click on image:
            point = drawpoint(c.handle_axes, 'Color', 'white');
            
            % if the user actually clicked:
            if isgraphics(point)
            
                % get coordinates of selection:
                point = round(point.Position);

                % get coordinates within radius of point:
                point = organoids2.utilities.get_all_coordinates_within_radius(point, 5);

                % add slice to the coordinates:
                point(:,3) = deal(c.current_slice);

                % get segmentations that touch any of the coordinates:
                segmentations_delete = organoids2.utilities.get_segmentations_containing_point(c.m.segmentations, point);

                % if there are any segmentations to delete:
                if ~ischar(segmentations_delete)

                    % get list of segmentation ids to delete:
                    segmentation_ids_delete = extractfield(segmentations_delete, 'segmentation_id');

                    % delete any objects that overlap with the coordinates:
                    c.m = c.m.delete_segmentation(segmentation_ids_delete);

                end

                % update the display:
                c = update_display(c);
            
            end
            
        end
        
        % callback to create a segmentation automatically:
        function c = callback_automatic(c, ~, ~)
            
%             circle = drawfreehand(c.handle_axes, 'Color', 'white');
%             
%             coords = round(circle.Position);
%             [coords_boundary, coords_mask] = utilities.get_boundary_and_mask_from_coords(coords(:,1), coords(:,2), c.image_height, c.image_width, c.current_slice);
%             
%             coords_mask(:,4) = deal(0);
%             for i = 1:size(coords_mask, 1)
%                 coords_mask(i,4) = c.image_display_stack(coords_mask(i,2), coords_mask(i,1), 1, c.current_slice);
%             end
%             
%             [counts, edges] = histcounts(coords_mask(:,4));
%             is_minima = islocalmin(counts);
%             index_minima = find(is_minima);
%             index_minima = index_minima(1);
%             threshold = mean(edges(index_minima:(index_minima+1)));
%             BW = c.image_display_stack(:, :, 1, c.current_slice) > threshold;
%             
%             boundaries = bwboundaries(BW);
%             
%             BW2 = imdilate(BW, strel('disk', 1));
%             
%             D = bwdist(~BW2);
%             D = -D;
%             D(~BW2) = Inf;
%             L = watershed(D);
%             L(~BW2) = 0;
%             figure; imshow(label2rgb(L));
% 
%             minima = islocalmin(counts);
%             threshold = find(minima);
%             threshold = edges(threshold(2));
%             
%             BW = imbinarize(c.image_display_stack(:, :, 1, c.current_slice), 1404);
%             figure; imshow(BW);
%             
%             % add object to model:
%             c.m = c.m.add_segmentation(coords_boundary, coords_mask);
% 
%             % update the display:
%             c = update_display(c);
            
        end
        
        % callback to create a segmentation by flooding:
        function c = callback_flood(c, ~, ~)
            
            % let user click on image:
            point = drawpoint(c.handle_axes, 'Color', 'white');
            
            % if the user actually clicked:
            if isgraphics(point)
            
                % get coordinates of selection:
                point = round(point.Position);

                % get the tolerance:
                tolerance = str2double(get(c.handle_tools_flood_number, 'String'));

                % expand from the seed point to get the boundary:
                [coords_boundary, coords_mask] = organoids2.utilities.expand_seed_point_to_boundary(c.image_calculate_stack(:,:,c.current_slice), c.current_slice, point, c.seed_location, tolerance);

                % add object to model:
                c.m = c.m.add_segmentation(coords_boundary, coords_mask);

                % update the display:
                c = update_display(c);
            
            end
            
        end
        
        % callback to create a segmentation by drawing:
        function c = callback_draw(c, ~, ~)
            
            % let the user draw on the image:
            coords_drawn = drawfreehand(c.handle_axes, 'Closed', true, 'Color', 'white');
            
            % if the user actually clicked:
            if isgraphics(coords_drawn)

                % get coordinates:
                coords_drawn = round(coords_drawn.Position);
                coords_drawn_x = coords_drawn(:,1);
                coords_drawn_y = coords_drawn(:,2);

                % format the coordinates:
                [coords_boundary, coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(coords_drawn_x, coords_drawn_y, c.image_height, c.image_width, c.current_slice);

                % add object to model:
                c.m = c.m.add_segmentation(coords_boundary, coords_mask);

                % update the display:
                c = update_display(c);
            
            end
            
        end
        
        % callback to redraw a segmentation:
        function c = callback_redraw(c, ~, ~)
            
            % let the user draw on the image:
            coords_redraw = drawfreehand(c.handle_axes, 'Closed', false, 'Color', 'white');
            
            % if the user actually clicked:
            if isgraphics(coords_redraw)

                % get the coordinates of the redraw:
                coords_redraw = round(coords_redraw.Position);
                coords_redraw(:,3) = deal(c.current_slice);

                % get the annotation the user wants to redraw (the one closest to
                % the first redraw coordinate):
                segmentation_to_redraw = organoids2.utilities.get_segmentation_nearest_point(c.m.segmentations, coords_redraw(1,:));

                % if there is a segmentation to redraw:
                if ~ischar(segmentation_to_redraw)

                    % get the coordinates of the redrawn segmentation:
                    coords_new = organoids2.utilities.redraw_segmentation(segmentation_to_redraw.boundary, coords_redraw, c.image_height, c.image_width);
                    coords_new_x = coords_new(:,1);
                    coords_new_y = coords_new(:,2);

                    % format the coordinates:
                    [segmentation_coords_boundary, segmentation_coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(coords_new_x, coords_new_y, c.image_height, c.image_width, c.current_slice);

                    % update the segmentation:
                    c.m.edit_segmentation(segmentation_to_redraw.segmentation_id, segmentation_coords_boundary, segmentation_coords_mask);

                end

                % update the display:
                c = update_display(c);
            
            end
            
        end    
        
        % callback to grow a segmentation:
        function c = callback_grow(c, ~, ~)
            
            % let user click on image:
            point = drawpoint(c.handle_axes, 'Color', 'white');
            
            % if the user actually clicked:
            if isgraphics(point)
            
                % get the growth diameter:
                growth_diameter = str2double(get(c.handle_tools_grow_number, 'String'));
                
                % get coordinates of selection:
                point = round(point.Position);

                % get coordinates within radius of point:
                point = organoids2.utilities.get_all_coordinates_within_radius(point, 5);

                % add slice to the coordinates:
                point(:,3) = deal(c.current_slice);

                % get segmentations that touch any of the coordinates:
                segmentations_grow = organoids2.utilities.get_segmentations_containing_point(c.m.segmentations, point);

                % if there are any segmentations to grow:
                if ~ischar(segmentations_grow)
                    
                    % for each segmentation to grow:
                    for i = 1:numel(segmentations_grow)
                        
                        % get the segmentation id and mask coords:
                        segmentation_id = segmentations_grow(i).segmentation_id;
                        mask_coords = segmentations_grow(i).mask(:,1:2);
                        
                        % create mask from the coords:
                        mask = zeros(c.image_height, c.image_width);
                        for j = 1:size(mask_coords, 1)
                            mask(mask_coords(j,2), mask_coords(j,1)) = 1;
                        end
                        
                        % grow/erode the mask:
                        if growth_diameter > 0
                            mask = imdilate(mask, strel('disk', growth_diameter));
                        elseif growth_diameter < 0
                            mask = imerode(mask, strel('disk', abs(growth_diameter)));
                        end
                        
                        % get coords from mask:
                        boundary = bwboundaries(mask);
                        boundary = boundary{1};
                        
                        % format coords:
                        [coords_boundary, coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(boundary(:,2), boundary(:,1), c.image_height, c.image_width, c.current_slice);

                        % update the segmentations:
                        c.m = c.m.edit_segmentation(segmentation_id, coords_boundary, coords_mask);
                        
                    end

                end

                % update the display:
                c = update_display(c);
            
            end
            
        end
        
        % callback to split a segmentation:
        function c = callback_split(c, ~, ~)
            
            % let user click on image:
            point = drawpoint(c.handle_axes, 'Color', 'white');
            
            % if the user actually clicked:
            if isgraphics(point)
            
                % get coordinates of selection:
                point = round(point.Position);
                point(3) = c.current_slice;

                % get segmentation the user wants to split:
                segmentation_to_split = organoids2.utilities.get_segmentations_containing_point(c.m.segmentations, point);

                % if there is only 1 segmentation to split:
                if ~ischar(segmentation_to_split) && numel(segmentation_to_split) == 1

                    % delete the original segmentation:
                    c.m = c.m.delete_segmentation(segmentation_to_split.segmentation_id);

                    % get the mask of the original segmentaiton:
                    image_mask = poly2mask(segmentation_to_split.boundary(:,2), segmentation_to_split.boundary(:,1), c.image_height, c.image_width);

                    % use watershed to split the object:
                    image_distance = bwdist(~image_mask);
                    image_distance = -image_distance;
                    image_distance(~image_mask) = Inf;
                    image_label = watershed(image_distance);
                    image_label(~image_mask) = 0;

                    % get the boundaries of the new objects:
                    boundaries = bwboundaries(image_label, 4, 'noholes');

                    % for each new object:
                    for j = 1:numel(boundaries)

                        boundary_x = boundaries{j}(:,1);
                        boundary_y = boundaries{j}(:,2);

                        % format the coordinates:
                        [coords_boundary, coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(boundary_x, boundary_y, c.image_height, c.image_width, c.current_slice);

                        % add object to model:
                        c.m = c.m.add_segmentation(coords_boundary, coords_mask);

                    end
                    
                    % update the display:
                    c = update_display(c);

                end
            
            end
            
        end
        
        % callback for real-time editing of a segmentation:
        function c = callback_edit(c, ~, ~, segmentation_id)
            
            % get segmentations on the slice:
            segmentations_slice = organoids2.utilities.get_structure_results_matching_number(c.m.segmentations, 'slice', c.current_slice);
            
            % get the index of the segmentation being edited:
            [~, index] = organoids2.utilities.get_structure_results_matching_number(segmentations_slice, 'segmentation_id', segmentation_id);
            
            % get the coordinates:
            coords = round(c.handle_segmentations{index}.Position);
            coords_x = coords(:,1);
            coords_y = coords(:,2);
            
            % format the coordinates:
            [segmentation_coords_boundary, segmentation_coords_mask] = organoids2.utilities.get_boundary_and_mask_from_coords(coords_x, coords_y, c.image_height, c.image_width, c.current_slice);
            
            % update the segmentation:
            c.m.edit_segmentation(segmentation_id, segmentation_coords_boundary, segmentation_coords_mask);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % callback for changing the channel for calculation:
        function c = callback_channels_change_calculation(c, ~, ~)
            
            % get the value of each radiobutton:
            values = zeros(1, c.num_channels);
            for i = 1:c.num_channels
                values(i) = c.handle_all_channels.(sprintf('radiobutton_%01d', i)).Value;
            end
            
            % updaet the channel to use for calculations:
            c.channel_for_calculation = find(values == 1);
            
            % update the display:
            c = update_display(c);
            
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
        function stack = load_stack(path_images, image_name, list_channels)
            
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

        end
        
    end
    
end