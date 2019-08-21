function [cells, continue_flag, stack_progression] = gui_to_id_cells(image, cells, current_stack, num_stacks)

    % set defaults:
    contrast_min = 0;
    contrast_max = 1;
    current_slice = 1;
    num_slices = size(image, 4);
    stack_progression = 'next';
    continue_flag = 'yes';

    % create GUI:
    handles = create_GUI;
    
    % display the image:
    display_image;

    % function to create GUI:
    function handles = create_GUI
        
        % set sizes:
        margin = 0.01;
        
        width_figure = 1;
        width_image = 0.8;
        width_other = width_figure - 3*margin - width_image;
        width_full = width_figure - 2*margin;
        width_thirds = (width_full - 2*margin)/3;
        
        height_figure = 1;
        height_button = 0.05;
        height_image = height_figure - 6*margin - 4*height_button;
        height_list = height_image - 3*margin - 3*height_button;
        
        start_x_figure = 0;
        start_x_image = start_x_figure + margin;
        start_x_contrast_lower = start_x_image;
        start_x_contrast_upper = start_x_image;
        start_x_slice_previous = start_x_image;
        start_x_slice_num = start_x_slice_previous + width_thirds + margin;
        start_x_slice_next = start_x_slice_num + width_thirds + margin;
        start_x_stack_previous = start_x_slice_previous;
        start_x_stack_num = start_x_slice_num;
        start_x_stack_next = start_x_slice_next;
        start_x_list = start_x_image + width_image + margin;
        start_x_delete = start_x_list;
        start_x_add = start_x_list;
        start_x_done = start_x_list;
        
        start_y_figure = 0;
        start_y_image = start_y_figure + margin;
        start_y_contrast_lower = start_y_image + height_image + margin;
        start_y_contrast_upper = start_y_contrast_lower + height_button + margin;
        start_y_slice_previous = start_y_contrast_upper + height_button + margin;
        start_y_slice_num = start_y_slice_previous;
        start_y_slice_next = start_y_slice_previous;
        start_y_stack_previous = start_y_slice_previous + height_button + margin;
        start_y_stack_num = start_y_stack_previous;
        start_y_stack_next = start_y_stack_previous;
        start_y_list = start_y_image;
        start_y_delete = start_y_image + height_list + margin;
        start_y_add = start_y_delete + height_button + margin;
        start_y_done = start_y_add + height_button + margin;
        
        % create figure;
        handles.figure = figure('Units', 'normalized', ...
            'Position', [start_x_figure, start_y_figure, width_figure, height_figure]);
        
        % create axes for images:
        handles.image = axes('Units', 'normalized', ...
            'Position', [start_x_image, start_y_image, width_image, height_image]);
        
        % create sliders to adjust contrast:
        handles.contrast_lower = uicontrol('Style', 'slider', ...
            'Units', 'normalized', ...
            'Position', [start_x_contrast_lower, start_y_contrast_lower, width_full, height_button], ...
            'Callback', @callback_contrast_lower, ...
            'min', 0, 'max', 1, ...
            'Value', contrast_min);
        handles.contrast_upper = uicontrol('Style', 'slider', ...
            'Units', 'normalized', ...
            'Position', [start_x_contrast_upper, start_y_contrast_upper, width_full, height_button], ...
            'Callback', @callback_contrast_upper, ...
            'min', 0, 'max', 1, ...
            'Value', contrast_max);
        
        % create slice buttons:
        handles.slice_previous = uicontrol('Units', 'normalized', ...
            'Position', [start_x_slice_previous, start_y_slice_previous, width_thirds, height_button], ...
            'Style', 'pushbutton', ...
            'String', 'Previous Slice', ...
            'Callback', @callback_slice_previous);
        handles.slice_next = uicontrol('Units', 'normalized', ...
            'Position', [start_x_slice_next, start_y_slice_next, width_thirds, height_button], ...
            'Style', 'pushbutton', ...
            'String', 'Next Slice', ...
            'Callback', @callback_slice_next);
        
        % create slice num string:
        handles.slice_num = uicontrol('Units', 'normalized', ...
            'Position', [start_x_slice_num, start_y_slice_num, width_thirds, height_button], ...
            'Style', 'text', ...
            'String', get_current_image_string(current_slice, num_slices));
        
        % create stack buttons:
        handles.stack_previous = uicontrol('Units', 'normalized', ...
            'Position', [start_x_stack_previous, start_y_stack_previous, width_thirds, height_button], ...
            'Style', 'pushbutton', ...
            'String', 'Previous Stack', ...
            'Callback', @callback_stack_previous);
        handles.stack_next = uicontrol('Units', 'normalized', ...
            'Position', [start_x_stack_next, start_y_stack_next, width_thirds, height_button], ...
            'Style', 'pushbutton', ...
            'String', 'Next Stack', ...
            'Callback', @callback_stack_next);
        
        % create stack num string:
        handles.stack_num = uicontrol('Units', 'normalized', ...
            'Position', [start_x_stack_num, start_y_stack_num, width_thirds, height_button], ...
            'Style', 'text', ...
            'String', get_current_image_string(current_stack, num_stacks));
        
        % create done button:
        handles.done = uicontrol('Units', 'normalized', ...
            'Position', [start_x_done, start_y_done, width_other, height_button], ...
            'Style', 'pushbutton', ...
            'String', 'Done', ...
            'Callback', @callback_done);
        
        % create add button:
        handles.add = uicontrol('Units', 'normalized', ...
            'Position', [start_x_add, start_y_add, width_other, height_button], ...
            'Style', 'pushbutton', ...
            'String', 'Add', ...
            'Callback', @callback_add);
        
        % create delete button:
        handles.delete = uicontrol('Units', 'normalized', ...
            'Position', [start_x_delete, start_y_delete, width_other, height_button], ...
            'Style', 'pushbutton', ...
            'String', 'Delete', ...
            'Callback', @callback_delete);
        
        % create list:
        handles.list = uicontrol('Units', 'normalized', ...
            'Position', [start_x_list, start_y_list, width_other, height_list], ...
            'Style', 'listbox', ...
            'String', get_cell_list(cells));

        % make all text larger:
        set(findall(handles.figure, '-property', 'FontSize'), 'FontSize', 20);
        
        % resize the GUI:
        set(handles.figure, ...
            'Units', 'normalized', ...
            'Position', [0, 0, .9, .9]);

        % move GUI to the center of the screen:
        movegui(handles.figure, 'center');
        
    end

    % function to string for current image
    function string = get_current_image_string(current, total)
       
        string = sprintf('%03d / %03d', current, total);
        
    end

    % function to get list of cells:
    function list = get_cell_list(cells)
       
        % if there are no cells:
        if isempty(cells)
            
            % the list is empty:
            list = [];
            
        % otherwise:
        else
            
            % get the list of all cells:
            list = unique(cells(:,1));   
            
        end
        
    end

    % function to display image:
    function display_image
        
        % plot image:
        imshow(imadjust(squeeze(image(:,:,:,current_slice)), [contrast_min, contrast_max]), 'Parent', handles.image);
        
        % plot cells:
        plot_all_cells;
        
        % update the slice number:
        set(handles.slice_num, 'String', get_current_image_string(current_slice, num_slices));
        
        % update the slice button visibility:
        if current_slice == 1
            set(handles.slice_previous, 'Enable', 'off');
            set(handles.slice_next, 'Enable', 'on');
        elseif current_slice == num_slices
            set(handles.slice_previous, 'Enable', 'on');
            set(handles.slice_next, 'Enable', 'off');
        else
            set(handles.slice_previous, 'Enable', 'on');
            set(handles.slice_next, 'Enable', 'on');
        end
        
        % update the stack button visibility:
        if current_stack == 1
            set(handles.stack_previous, 'Enable', 'off');
            set(handles.stack_next, 'Enable', 'on');
        elseif current_stack == num_stacks
            set(handles.stack_previous, 'Enable', 'on');
            set(handles.stack_next, 'Enable', 'off');
        else
            set(handles.stack_previous, 'Enable', 'on');
            set(handles.stack_next, 'Enable', 'on');
        end
        
        % establish callback for clicking on the image and arrow keys:
        set(gcf, 'WindowButtonDownFcn', @callback_click, 'keypressfcn', @callback_arrow_keys);
        
        % have program wait:
        uiwait(handles.figure);
         
    end

    % function to plot cells:
    function plot_all_cells
        
        hold on;
        
        % if there are any cells:
        if ~isempty(cells)
        
            % for each cell:
            for i = 1:size(cells, 1)

                % if the coordinate is on this slice:
                if cells(i,4) == current_slice

                    % add to image:
                    text(handles.image, ...
                        cells(i, 2), cells(i, 3), ...
                        num2str(cells(i,1)), ...
                        'Color', 'white', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center');

                end

            end
        
        end
        
        hold off;
        
    end

    % callback to adjust lower bound of contrast:
    function callback_contrast_lower(~, ~)
        
        % get the slider value:
        contrast_min = get(handles.contrast_lower, 'Value');
        
        % update the image:
        display_image;
        
    end

    % callback to adjust upper bound of contrast:
    function callback_contrast_upper(~, ~)
        
        % get the slider value:
        contrast_max = get(handles.contrast_upper, 'Value');
        
        % update the image:
        display_image;
        
    end

    % callback for previous slice:
    function callback_slice_previous(~, ~)
        
        % update the slice number:
        current_slice = max(current_slice - 1, 1);
        
        % display the image:
        display_image;
        
    end

    % callback for next slice:
    function callback_slice_next(~, ~)
        
        % update the slice number:
        current_slice = min(current_slice + 1, num_slices);
        
        % display the image:
        display_image;
        
    end

    % callback for previous stack:
    function callback_stack_previous(~, ~)
        
        % update stack progression:
        stack_progression = 'previous';
        
        % close the GUI:
        close(handles.figure);

    end

    % callback for next stack:
    function callback_stack_next(~, ~)
        
        % update stack progression:
        stack_progression = 'next';
        
        % close the GUI:
        close(handles.figure);

    end
        
    % callback to delete a cell:
    function callback_delete(~,~)
       
        % get list of cells:
        list = get(handles.list, 'String');
        
        % get selected cell:
        index = get(handles.list, 'Value');
        cell_number = list(index);
        
        % remove selected cell from list of cells:
        list = list(~ismember(list, cell_number));
        
        % update list:
        set(handles.list, 'String', list);
        set(handles.list, 'Value', 1);
        
        % remove selected cell from structure:
        row = find(cells(:,1) == str2double(cell_number));
        cells(row, :) = [];
        
        % display image:
        display_image;
        
    end

    % callback to add a cell:
    function callback_add(~, ~)
        
        % get list of cells:
        list_cells = get_cell_list(cells);

        % get number for new cell:
        if isempty(list_cells)
            cell_num = 1;
        else
            cell_num = max(list_cells) + 1;
        end
        
        % add cell (with higher number) to list:
        list_cells = [list_cells; cell_num];
        
        % make object selected:
        set(handles.list, 'String', list_cells);
        set(handles.list, 'Value', numel(list_cells));
        
    end

    % callback for done:
    function callback_done(~, ~)
        
        % update the continue flag:
        continue_flag = 'no';
        
        % close the GUI:
        close(handles.figure);
        
    end

    % callback for clicking on the image:
    function callback_click(~, ~)
        
        % get click type:
        click_type = get(gcf, 'SelectionType');
        
        % get coordinates of selection:
        point = get(gca, 'CurrentPoint');
        
        % format coordinates:
        point = round(point(1,:));
        point(1:2) = point(1:2);
        point(3) = current_slice;
        
        % if the click is within the boundaries of the image:
        if (point(1) > 1 && point(1) < size(image, 2)) && (point(2) > 1 && point(2) < size(image, 1))

            % if the click is right click:
            if strcmp(click_type, 'alt')

                % set radius:
                radius = 10;

                % get coordinates within radius of point:
                coords_x = point(1)-radius:point(1)+radius;
                coords_y = point(2)-radius:point(2)+radius;
                [coords_x, coords_y] = meshgrid(coords_x, coords_y);
                coords = cat(2, coords_x, coords_y);
                coords = reshape(coords, [], 2);
                coords(:,3) = deal(current_slice);

                % create list of rows to remove:
                rows_remove = [];    
                
                % for each cell:
                for i = 1:size(cells, 1)

                    % if the coordinate overlaps with any of the click coords:
                    if any(ismember(cells(i,2:4), coords, 'rows'))

                        % add row to list of rows to remove:
                        rows_remove = [rows_remove, i];

                    end

                end
                
                % remove rows:
                cells(rows_remove,:) = [];

            % otherwise:
            else

                % get the cell number:
                index = get(handles.list, 'Value');
                list = get(handles.list, 'String');
                cell_number = str2double(list(index, :));
                
                % add marker to the list of cells:
                cells(end+1, :) = [cell_number, point];

            end

            % update image:
            display_image;
        
        end
        
    end

    % callback for arrow keys:
    function callback_arrow_keys(~, event_data)
        
        % switch for the key:
        switch event_data.Key
            
            % if the key was the right arrow:
            case 'rightarrow'
                
                % go to next slice:
                callback_slice_next;
                
            % if the key was the left arrow:
            case 'leftarrow'
                
                % go to previous slice:
                callback_slice_previous;
                
        end
        
    end

end