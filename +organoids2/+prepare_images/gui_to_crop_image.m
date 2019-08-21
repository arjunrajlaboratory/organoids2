function [image_cropped, slice_start, slice_end] = gui_to_crop_image(image, channel_names, type_crop)

    % depending on the type of stack to crop:
    switch type_crop
       
        % for xy stacks:
        case 'xy'
            
            % get the image to display:
            image_display = get_rgb_image(image, channel_names);
            
        % for orthogonal stacks
        case 'ortho'
            
            % use the input image for the display:
            image_display = image;
        
    end

    % run the GUI to get the start/end slices:
    [slice_start, slice_end] = gui(image_display);

    % crop the stack in z:
    image_cropped = image(:, :, slice_start:slice_end, :);

end

% function to get RGB image:
function image_rgb = get_rgb_image(image, channel_names)
    
    % image dimensions:
    [num_rows, num_columns, num_slices, num_channels] = size(image);
    
    % create array for rgb version of image (with same class as image):
    image_rgb = zeros(num_rows, num_columns, num_slices, 3, 'like', image);

    % for each channel:
    for j = 1:num_channels

        % depending on the channel name:
        switch channel_names{j}
            case 'dapi'
                color = [0 0 1];
            case 'gfp'
                color = [0 1 0];
            case 'cy3'
                color = [1 0 0];
            case '594'
                color = [1 0 1];
            otherwise 
                error('No color set for channel %s', channel_names{j});
        end

        % for each rgb channel:
        for k = 1:3

            % add channel to rgb image:
            image_rgb(:,:,:,k) = image_rgb(:,:,:,k) + (image(:,:,:,j) * color(k));

        end

    end

end

% function to run GUI and get start/end slices:
function varargout = gui(image)

    % set the starting slice:
    slice_current = 1;
    
    % set the slices:
    slice_start = 1;
    slice_end = size(image, 3);
    
    % create the GUI;
    create_GUI;
        
    % display the image:
    display_image;
    
    % move gui to the center of the screen:
    movegui(handles.figure, 'center');

    % make all text larger:
    set(findall(handles.figure, '-property', 'FontSize'), 'FontSize', 16);
    
    % make the window visible:
    handles.figure.Visible = 'on';

    % have the function wait:
    uiwait(handles.figure);

    % output the parameters:
    varargout{1} = slice_start;
    varargout{2} = slice_end;
    
    % function to create the GUI:
    function create_GUI
        
        % get figure dimensions:
        margin = 0.01;
        
        figure_height = 1.0;
        image_height = 0.8;
        element_height = (1 - image_height - (5 * margin)) / 3;
        button_height = element_height;
        label_height = element_height;
        slider_height = element_height;
        
        figure_width = 0.5;
        image_width = 1 - (2 * margin);
        button_width = (image_width - margin)/2;
        label_width = button_width;
        slider_width = image_width;
        
        figure_start_x = 0;
        button_start_x = margin;
        button_end_x = button_start_x + button_width + margin;
        label_start_x = margin;
        label_end_x = button_start_x + button_width + margin;
        slider_start_x = margin;
        image_start_x = margin;

        figure_start_y = 0;
        button_start_y = margin;
        button_end_y = margin;
        label_start_y = button_start_y + button_height + margin;
        label_end_y = button_start_y + button_height + margin;
        slider_start_y = label_start_y + label_height + margin;
        image_start_y = slider_start_y + slider_height + margin;

        % create the figure:
        handles.figure = figure('Visible', 'off', ...
            'Units', 'Normalized', ...
            'Position', [figure_start_x, figure_start_y, figure_width, figure_height]);

        % create the axis for the image:
        handles.image = axes(handles.figure, 'Units', 'Normalized', 'Position', [image_start_x, image_start_y, image_width, image_height]);

        % create the slider:
        handles.slider = uicontrol(handles.figure, ...
            'Style', 'slider', ...
            'Units', 'Normalized', ...
            'Position', [slider_start_x, slider_start_y, slider_width, slider_height], ...
            'Callback', @callback_slider, ...
            'min', 1, 'max', size(image, 3), 'Value', 1);
        
        % create the labels:
        handles.label_start = uicontrol(handles.figure, ...
            'Style', 'text', ...
            'Units', 'normalized', ...
            'Position', [label_start_x, label_start_y, label_width, label_height], ...
            'String', 'Starting Slice:');
        handles.label_end = uicontrol(handles.figure, ...
            'Style', 'text', ...
            'Units', 'normalized', ...
            'Position', [label_end_x, label_end_y, label_width, label_height], ...
            'String', 'Ending Slice:');
        
        % create the buttons:
        handles.button_start = uicontrol(handles.figure, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [button_start_x, button_start_y, button_width, button_height], ...
            'String', slice_start, 'Callback', @callback_button_start);
        handles.button_end = uicontrol(handles.figure, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [button_end_x, button_end_y, button_width, button_height], ...
            'String', slice_end, 'Callback', @callback_button_end);
        
    end
    
    % function to display the image:
    function display_image
        
        % display the image:
        imshow(scale(squeeze(image(:,:,slice_current,:))), 'Parent', handles.image, 'InitialMagnification', 'fit'); 
        
    end
    
    % callback for the slider:
    function callback_slider(~,~)
       
        % get the slider value:
        slice_current = round(get(handles.slider, 'Value'));

        % update the image:
        display_image;
        
    end
    
    % callback for the start slice:
    function callback_button_start(~,~)
       
        % get the slider value:
        slice_current = round(get(handles.slider, 'Value'));
        
        % update the starting slice:
        slice_start = slice_current;
        
        % update the button description:
        set(handles.button_start, 'String', num2str(slice_current));
        
    end

    % callback for the end slice:
    function callback_button_end(~,~)
       
        % get the slider value:
        slice_current = round(get(handles.slider, 'Value'));
        
        % update the starting slice:
        slice_end = slice_current;
        
        % update the button description:
        set(handles.button_end, 'String', num2str(slice_current));
        
    end

end