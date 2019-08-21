classdef controller < handle
    
    properties
        
        % segmentation settings:
        structure_to_segment;
        
        % GUI data:
        path_data;
        list_segmentation_files;
        num_job;
        num_stacks;
        current_stack;
        num_slices;
        image_width;
        image_height;
        current_slice;
        image_display;
        contrast_max;
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
        
        handle_segmentations;
        
        % model:
        m;
        
    end
    
    methods
        
        % constructor:
        function c = controller(v, structure_to_segment)
            
            % get structure to segment:
            c.structure_to_segment = structure_to_segment;
            
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
            
            % get GUI data:
            c.path_data = fullfile(pwd, '..');
            c.list_segmentation_files = dir(sprintf('%s_3D_final*.mat', structure_to_segment));
            c.num_stacks = numel(c.list_segmentation_files);
            c.current_stack = 1;
            c.contrast_max = 1;
            
            % load the image and segmentations:
            c = load_data(c);
            
            % update the display:
            c = update_display(c);
            
        end
        
        % function to load data for an image stack:
        function c = load_data(c)
            
            % load the segmentations:
            c.m = organoids2.review_3D_segmentations.model(c.list_segmentation_files(c.current_stack).name);    
            
            % have the segmentations save when the window closes:
            c.handle_figure.CloseRequestFcn = @c.callback_close_window;
            
            % get the image name:
            image_name = c.list_segmentation_files(c.current_stack).name(end-9:end-4);
            
            % load the image to display:
            c.image_display = c.load_stack(fullfile(c.path_data, sprintf('%s_rgb.mat', image_name)));
            
            % get the orthogonal image:
            c.image_display = organoids2.utilities.reslice_stack(c.image_display, 6);
            
            % update number of image size:
            c.num_slices = size(c.image_display, 4);
            c.image_width = size(c.image_display, 2);
            c.image_height = size(c.image_display, 1);
            
            % update the current slice:
            c.current_slice = 200;
           
            % update the zoom:
            c.axis_limits_x = [0.5 c.image_width + 0.5];
            c.axis_limits_y = [0.5 c.image_height + 0.5];
            
            % set the axis limits:
            set(c.handle_axes, 'XLim', c.axis_limits_x);
            set(c.handle_axes, 'YLim', c.axis_limits_y);
            
        end
        
        % function to update the display:
        function c = update_display(c)

            % get the axis limits:
            c.axis_limits_x = get(c.handle_axes, 'XLim');
            c.axis_limits_y = get(c.handle_axes, 'YLim');
            
            % show the current image slice:
            imshow(imadjust(squeeze(c.image_display(:,:,:,c.current_slice)), [0 c.contrast_max]), 'Parent', c.handle_axes);
            
            % set the axis limits:
            set(c.handle_axes, 'XLim', c.axis_limits_x);
            set(c.handle_axes, 'YLim', c.axis_limits_y);
            
            % if there were any segmentations:
            if exist('c.handle_segmentations', 'var')
                
                % delete the ROIs:
                delete(c.handle_segmentations);
                
            end
            
            % if there are any segmentations:
            if ~ischar(c.m.segmentations)
                
                % get a color for each segmentation:
                colors = organoids2.utilities.distinguishable_colors(numel(extractfield(c.m.segmentations, 'object_num')), 'k');
                
                % for each segmentation:
                for i = 1:numel(c.m.segmentations)
                    
                    % if the segmentation is on the slice:
                    if ismember(c.current_slice, c.m.segmentations(i).boundary(:,1))
                    
                        % get the coordinates:
                        coordinates_XY = c.m.segmentations(i).boundary;
                        
                        % convert the coordinates to XZ:
                        coordinates_XZ = [coordinates_XY(:,2), coordinates_XY(:,3), coordinates_XY(:,2)];
                        
                        % scale the coordinates:
                        % coordinates_XZ(:,2) = coordinates_XZ(:,2) * 6;
                        
                        % get the color:
                        color = colors(c.m.segmentations(i).object_num, :);

                        % draw:
                        c.handle_segmentations{i} = drawfreehand(c.handle_axes, ...
                            'Position', coordinates_XZ(:,1:2), ...
                            'Color', color, ...
                            'FaceAlpha', 0, ...
                            'LineWidth', 2.0);

                        % add listener for the segmentation:
                        % addlistener(c.handle_segmentations{i}, 'ROIMoved', @(src, eventdata)c.callback_edit(src, eventdata, segmentations(i).segmentation_id));
                    
                    end
                        
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
            [segmentation_coords_boundary, segmentation_coords_mask] = organoids.utilities.get_boundary_and_mask_from_coords(coords_x, coords_y, c.image_height, c.image_width, c.current_slice);
            
            % update the segmentation:
            c.m.edit_segmentation(segmentation_id, segmentation_coords_boundary, segmentation_coords_mask);
            
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
        function stack = load_stack(path_file)
            
            % get the extension of the file:
            [~, ~, extension] = fileparts(path_file);
            
            % depending on the extension of the file:
            switch extension
                
                case '.tif'
                
                    % load the image:
                    stack = readmm(path_file);
                    stack = stack.imagedata;
                    
                    % flip the order of the channel and slice:
                    stack = permute(stack, [1 2 4 3]);
                
                case '.mat'
                    
                    % load the image:
                    stack = organoids2.utilities.load_structure_from_file(path_file);
                
            end

        end
        
    end
    
end