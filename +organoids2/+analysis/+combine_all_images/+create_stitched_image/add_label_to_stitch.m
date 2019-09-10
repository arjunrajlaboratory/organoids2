function stitch = add_label_to_stitch(stitch, label, location, font_size)

    % depending on the location:
    switch location
       
        case 'upper_left'
            
            % set where to place label:
            position_row = 0;
            position_col = 0;
            
            % set anchor point for label:
            anchor = 'LeftTop';
            
        case 'lower_right'
            
            % set where to place label:
            position_row = size(stitch, 1) - 10;
            position_col = size(stitch, 2) - 10;
            
            % set anchor point for label:
            anchor = 'RightBottom';
        
    end

    % for each slice:
    for i = 1:size(stitch, 3)

        % add the type of sort to the stitch:
        stitch(:,:,i,:) = insertText(...
            squeeze(stitch(:,:,i,:)), ...
            [position_row, position_col], ...
            label, ...
            'FontSize', font_size, ...
            'TextColor', 'white', ...
            'BoxOpacity', 0, ...
            'AnchorPoint', anchor);

    end

end