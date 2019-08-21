function channel_names = gui_to_get_channel_names(image)

    % image dimensions:
    [num_rows, num_columns, ~, num_channels] = size(image);

    % create array to store max merge (for each channel):
    image_max = zeros(num_rows, num_columns, 1, num_channels, 'like', image);
    
    % for each channel:
    for j = 1:num_channels

        % get max merge:
        image_max(:,:,:,j) = max(image(:,:,:,j), [], 3);

    end

    % get channel names from GUI:
    channel_names = gui(image_max, num_channels);
    
end

% function to create gui and return channels:
function varargout = gui(image_max, num_channels)

    % get figure dimensions:
    margin = 0.05;
    figure_start_x = 0;
    figure_start_y = 0;
    figure_width = 0.9;
    figure_height = 0.9;
    image_width = (figure_width - (num_channels+1)*margin) / num_channels;
    image_height = image_width;
    menu_width = image_width;
    menu_height = figure_height - 3*margin - image_height;
    
    % set master list of channels:
    list_channels = {'gfp', 'dapi', 'cy3', '594'};
    
    % set default channels:
    channels = list_channels(1:num_channels);
    
    %  create the figure:
    handles.figure = figure('Visible', 'off', 'Units', 'Normalized', 'Position', [figure_start_x, figure_start_y, figure_width, figure_height]);

    % for each channel:
    for j = 1:num_channels
        
        % get the image dimensions:
        image_start_x = (j * margin) + ((j - 1) * image_width);
        image_start_y = figure_height - margin - image_height;
        
        % create the axis for the image:
        handles.image = axes('Units', 'Normalized', 'Position', [image_start_x, image_start_y, image_width, image_height]);
        
        % display the image:
        imshow(scale(squeeze(image_max(:,:,:,j))), 'Parent', handles.image); 
        
        % get the menu dimensions:
        menu_start_x = image_start_x;
        menu_start_y = margin;
        
        % create the dropdown menu:
        handles.(sprintf('menu_%02d', j)) = uicontrol('Style', 'listbox', ...
            'String', list_channels, ...
            'Units', 'Normalized', ...
            'Position', [menu_start_x, menu_start_y, menu_width, menu_height], ...
            'Callback', {@callback_set_channel, j}, ...
            'Value', j);
        
    end
    
    % move gui to the center of the screen:
    movegui(handles.figure, 'center');

    % make all text larger:
    set(findall(handles.figure, '-property', 'FontSize'), 'FontSize', 16);
    
    % make the window visible:
    handles.figure.Visible = 'on';

    % have the function wait:
    uiwait(handles.figure);

    % output the parameters:
    varargout{1} = channels;
    
    % callback to set channel:
    function callback_set_channel(~, ~, channel_number)
        
        % update channel:
        channels{channel_number} = list_channels{get(handles.(sprintf('menu_%02d', channel_number)), 'Value')};
        
    end

end