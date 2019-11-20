classdef view < handle
    
    properties
        
        % set keyboard shortcuts:
        shortcut_grow = 'g';
        shortcut_split = 's';
        shortcut_redraw = 'r';
        shortcut_draw = 'd';
        shortcut_flood = 'f';
        shortcut_automatic = 'a';
        shortcut_delete = 'q';
        
        % add GUI components:
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
        
        handle_all_channels
        
        handle_annotations;
        
        % add controller:
        c;
        
    end
    
    methods
        
        % constructor:
        function v = view(gui_data)
            
            % get a list of channels:
            gui_data.list_channels = unique(cellfun(@(x) x(8:end-4), extractfield(gui_data.list_images, 'name'), 'UniformOutput', false));

            % get the number of channels:
            gui_data.num_channels = numel(gui_data.list_channels);
           
            % set the margin to use between elements:
            margin =                            0.01;
            
            % set the widths:
            width_figure =                      0.9;
            width_half =                        (1 - 3 * margin) / 2;
            width_quarter =                     (1 - 5 * margin) / 4;
            
            width_axes =                        width_half;
            width_tools =                       width_quarter;
            width_channels =                    width_quarter;
            width_navigation =                  width_half;
            width_contrast =                    width_half;

            width_tools_element =               (1 - 4 * margin) / 3;
            width_tools_label =                 1 - (2 * margin);
            
            width_channels_group =              0.1; 
            width_channels_radiobutton =        1;
            width_channels_toggle =             0.4;             
            width_channels_dropdown =           1 - 4 * margin - width_channels_group - width_channels_toggle;  
            
            width_navigation_element =          (1 - 4 * margin) / 3;
            width_navigation_text =             (1 - 10 * margin) / 9;
            
            width_contrast_element =            1 - 2 * margin;
            
            % set the heights:
            height_figure =                     0.8;
            height_full =                       1 - (2 * margin);
            
            height_axes =                       height_full;
            height_navigation =                 0.3;
            height_contrast =                   0.1;
            height_tools =                      height_full - (2 * margin) - height_navigation - height_contrast; 
            height_channels =                   height_full - (2 * margin) - height_navigation - height_contrast; 
            
            height_tools_element =              (1 - 11 * margin) / 10;
            height_tools_label =                (1 - 11 * margin) / 10;
            
            height_channels_group =             1 - 2 * margin;
            height_channels_radiobutton =       (1 - (1 + gui_data.num_channels) * margin) / gui_data.num_channels;
            height_channels_toggle =            (1 - (1 + gui_data.num_channels) * margin) / gui_data.num_channels;
            height_channels_dropdown =          (1 - (1 + gui_data.num_channels) * margin) / gui_data.num_channels;
            
            height_navigation_element =         (1 - 3 * margin) / 2;
            height_navigation_text =            (1 - 3 * margin) / 2;
            
            height_contrast_element =           1 - 2 * margin;
            
            % set the x coords:
            x_figure =                          0;
            
            x_axes =                            margin;
            x_contrast =                        margin + width_axes + margin;
            x_navigation =                      margin + width_axes + margin;
            x_tools =                           margin + width_axes + margin;
            x_channels =                        margin + width_axes + margin + width_tools + margin;
            
            x_channels_group =                  margin;
            x_channels_radiobutton =            margin;
            x_channels_toggle =                 margin + width_channels_group + margin;
            x_channels_dropdown =               margin + width_channels_group + margin + width_channels_toggle + margin;

            x_contrast_slider =                 margin;

            x_navigation_stack_previous =       margin;
            x_navigation_stack_current =        margin + width_navigation_element + margin;
            x_navigation_stack_divider =        margin + width_navigation_element + margin + width_navigation_text + margin;
            x_navigation_stack_total =          margin + width_navigation_element + margin + width_navigation_text + margin + width_navigation_text + margin;
            x_navigation_stack_next =           margin + width_navigation_element + margin + width_navigation_text + margin + width_navigation_text + margin + width_navigation_text + margin;
            x_navigation_slice_previous =       margin;
            x_navigation_slice_current =        margin + width_navigation_element + margin;
            x_navigation_slice_divider =        margin + width_navigation_element + margin + width_navigation_text + margin;
            x_navigation_slice_total =          margin + width_navigation_element + margin + width_navigation_text + margin + width_navigation_text + margin;
            x_navigation_slice_next =           margin + width_navigation_element + margin + width_navigation_text + margin + width_navigation_text + margin + width_navigation_text + margin;
            
            x_tools_grow_button =               margin;
            x_tools_grow_number =               margin + width_tools_element + margin;
            x_tools_split_button =              margin;
            x_tools_redraw_button =             margin;
            x_tools_label_edit =                margin;
            x_tools_draw_button =               margin;
            x_tools_flood_button =              margin;
            x_tools_flood_number =              margin + width_tools_element + margin;
            x_tools_automatic_button =          margin;
            x_tools_label_add =                 margin;
            x_tools_delete_button =             margin;
            x_tools_label_delete =              margin;

            % set the y coords:
            y_figure =                          0;
            
            y_axes =                            margin;
            y_contrast =                        margin;
            y_navigation =                      margin + height_contrast + margin;
            y_tools =                           margin + height_contrast + margin+ height_navigation + margin;
            y_channels =                        margin + height_contrast + margin+ height_navigation + margin;
            
            y_contrast_slider =                 margin - 0.4;

            y_navigation_stack_previous =       margin;
            y_navigation_stack_current =        margin;
            y_navigation_stack_divider =        margin;
            y_navigation_stack_total =          margin;
            y_navigation_stack_next =           margin;
            y_navigation_slice_previous =       margin + height_navigation_element + margin;
            y_navigation_slice_current =        margin + height_navigation_element + margin;
            y_navigation_slice_divider =        margin + height_navigation_element + margin;
            y_navigation_slice_total =          margin + height_navigation_element + margin;
            y_navigation_slice_next =           margin + height_navigation_element + margin;
            
            y_tools_grow_button =               margin;
            y_tools_grow_number =               margin;
            y_tools_split_button =              margin + height_tools_element + margin;
            y_tools_redraw_button =             margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_label_edit =                margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_draw_button =               margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_flood_button =              margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_flood_number =              margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_automatic_button =          margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_label_add =                 margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_delete_button =             margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_label_delete =              margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;

            % set the colors:
            color_text = 'white';
            color_background = [0.1 0.1 0.1];
            color_button = [0.25 0.25 0.25];
            
            % create the figure:
            v.handle_figure = figure('Visible', 'off');
            v.handle_figure.Units = 'normalized';
            v.handle_figure.Position = [x_figure y_figure width_figure height_figure];
            v.handle_figure.Color = color_background;
            
            % create the image axes:
            v.handle_axes = axes(v.handle_figure);
            v.handle_axes.Units = 'normalized';
            v.handle_axes.Position = [x_axes y_axes width_half height_axes];
            
            % create the contrast group:
            handle_contrast = uibuttongroup(v.handle_figure);
            handle_contrast.Units = 'normalized';
            handle_contrast.Position = [x_contrast y_contrast width_contrast height_contrast];
            handle_contrast.Title = 'Contrast';
            handle_contrast.BackgroundColor = color_background;
            handle_contrast.ForegroundColor = color_text;
            
            % create the navigation group:
            handle_navigation = uibuttongroup(v.handle_figure);
            handle_navigation.Units = 'normalized';
            handle_navigation.Position = [x_navigation y_navigation width_navigation height_navigation];
            handle_navigation.Title = 'Navigation';
            handle_navigation.BackgroundColor = color_background;
            handle_navigation.ForegroundColor = color_text;
            
            % create the tools group:
            handle_tools = uibuttongroup(v.handle_figure);
            handle_tools.Units = 'normalized';
            handle_tools.Position = [x_tools y_tools width_tools height_tools];
            handle_tools.Title = 'Tools';
            handle_tools.BackgroundColor = color_background;
            handle_tools.ForegroundColor = color_text;
            
            % create the channels group:
            handle_channels = uibuttongroup(v.handle_figure);
            handle_channels.Units = 'normalized';
            handle_channels.Position = [x_channels y_channels width_channels height_channels];
            handle_channels.Title = 'Channels';
            handle_channels.BackgroundColor = color_background;
            handle_channels.ForegroundColor = color_text;
            
            % create the contrast slider:
            v.handle_contrast_slider = uicontrol(handle_contrast);
            v.handle_contrast_slider.Units = 'normalized';
            v.handle_contrast_slider.Position = [x_contrast_slider y_contrast_slider width_contrast_element height_contrast_element];
            v.handle_contrast_slider.Style = 'slider';
            v.handle_contrast_slider.Min = 0;
            v.handle_contrast_slider.Max = 1;
            v.handle_contrast_slider.ForegroundColor = color_button;

            % create the previous stack button:
            v.handle_navigation_stack_previous = uicontrol(handle_navigation);
            v.handle_navigation_stack_previous.Units = 'normalized';
            v.handle_navigation_stack_previous.Position = [x_navigation_stack_previous y_navigation_stack_previous width_navigation_element height_navigation_element];
            v.handle_navigation_stack_previous.String = '<html> Previous Stack (&darr) </html>';
            v.handle_navigation_stack_previous.Style = 'pushbutton';
            v.handle_navigation_stack_previous.BackgroundColor = color_button;
            v.handle_navigation_stack_previous.ForegroundColor = color_text;
            
            % create the stack current edit box:
            v.handle_navigation_stack_current = uicontrol(handle_navigation);
            v.handle_navigation_stack_current.Units = 'normalized';
            v.handle_navigation_stack_current.Position = [x_navigation_stack_current y_navigation_stack_current width_navigation_text height_navigation_text];
            v.handle_navigation_stack_current.Style = 'edit';
            v.handle_navigation_stack_current.BackgroundColor = color_button;
            v.handle_navigation_stack_current.ForegroundColor = color_text;
            
            % create the stack divider edit box:
            handle_navigation_stack_divider = uicontrol(handle_navigation);
            handle_navigation_stack_divider.Units = 'normalized';
            handle_navigation_stack_divider.Position = [x_navigation_stack_divider y_navigation_stack_divider width_navigation_text height_navigation_text];
            handle_navigation_stack_divider.Style = 'edit';
            handle_navigation_stack_divider.String = '/';
            handle_navigation_stack_divider.Enable = 'inactive';
            handle_navigation_stack_divider.BackgroundColor = color_button;
            handle_navigation_stack_divider.ForegroundColor = color_text;
            
            % create the stacks total text box:
            v.handle_navigation_stack_total = uicontrol(handle_navigation);
            v.handle_navigation_stack_total.Units = 'normalized';
            v.handle_navigation_stack_total.Position = [x_navigation_stack_total y_navigation_stack_total width_navigation_text height_navigation_text];
            v.handle_navigation_stack_total.Style = 'edit';
            v.handle_navigation_stack_total.Enable = 'inactive';
            v.handle_navigation_stack_total.BackgroundColor = color_button;
            v.handle_navigation_stack_total.ForegroundColor = color_text;
            
            % create the next stack button:
            v.handle_navigation_stack_next = uicontrol(handle_navigation);
            v.handle_navigation_stack_next.Units = 'normalized';
            v.handle_navigation_stack_next.Position = [x_navigation_stack_next y_navigation_stack_next width_navigation_element height_navigation_element];
            v.handle_navigation_stack_next.String = '<html> Next Stack (&uarr) </html>';
            v.handle_navigation_stack_next.Style = 'pushbutton';
            v.handle_navigation_stack_next.BackgroundColor = color_button;
            v.handle_navigation_stack_next.ForegroundColor = color_text;
            
            % create the previous slice button:
            v.handle_navigation_slice_previous = uicontrol(handle_navigation);
            v.handle_navigation_slice_previous.Units = 'normalized';
            v.handle_navigation_slice_previous.Position = [x_navigation_slice_previous y_navigation_slice_previous width_navigation_element height_navigation_element];
            v.handle_navigation_slice_previous.String = '<html> Previous Slice (&larr) </html>';
            v.handle_navigation_slice_previous.Style = 'pushbutton';
            v.handle_navigation_slice_previous.BackgroundColor = color_button;
            v.handle_navigation_slice_previous.ForegroundColor = color_text;
            
            % create the slice current edit box:
            v.handle_navigation_slice_current = uicontrol(handle_navigation);
            v.handle_navigation_slice_current.Units = 'normalized';
            v.handle_navigation_slice_current.Position = [x_navigation_slice_current y_navigation_slice_current width_navigation_text height_navigation_text];
            v.handle_navigation_slice_current.Style = 'edit';
            v.handle_navigation_slice_current.BackgroundColor = color_button;
            v.handle_navigation_slice_current.ForegroundColor = color_text;
            
            % create the slice divider edit box:
            handle_navigation_slice_divider = uicontrol(handle_navigation);
            handle_navigation_slice_divider.Units = 'normalized';
            handle_navigation_slice_divider.Position = [x_navigation_slice_divider y_navigation_slice_divider width_navigation_text height_navigation_text];
            handle_navigation_slice_divider.Style = 'edit';
            handle_navigation_slice_divider.String = '/';
            handle_navigation_slice_divider.Enable = 'inactive';
            handle_navigation_slice_divider.BackgroundColor = color_button;
            handle_navigation_slice_divider.ForegroundColor = color_text;
            
            % create the slice total edit box:
            v.handle_navigation_slice_total = uicontrol(handle_navigation);
            v.handle_navigation_slice_total.Units = 'normalized';
            v.handle_navigation_slice_total.Position = [x_navigation_slice_total y_navigation_slice_total width_navigation_text height_navigation_text];
            v.handle_navigation_slice_total.Style = 'edit';
            v.handle_navigation_slice_total.Enable = 'inactive';
            v.handle_navigation_slice_total.BackgroundColor = color_button;
            v.handle_navigation_slice_total.ForegroundColor = color_text;
            
            % create the next slice button:
            v.handle_navigation_slice_next = uicontrol(handle_navigation);
            v.handle_navigation_slice_next.Units = 'normalized';
            v.handle_navigation_slice_next.Position = [x_navigation_slice_next y_navigation_slice_next width_navigation_element height_navigation_element];
            v.handle_navigation_slice_next.String = '<html> Next Slice (&rarr) </html>';
            v.handle_navigation_slice_next.Style = 'pushbutton';
            v.handle_navigation_slice_next.BackgroundColor = color_button;
            v.handle_navigation_slice_next.ForegroundColor = color_text;
            
            % create the grow button:
            v.handle_tools_grow = uicontrol(handle_tools);
            v.handle_tools_grow.Units = 'normalized';
            v.handle_tools_grow.Position = [x_tools_grow_button y_tools_grow_button width_tools_element height_tools_element];
            v.handle_tools_grow.String = sprintf('Grow (%s)', v.shortcut_grow);
            v.handle_tools_grow.BackgroundColor = color_button;
            v.handle_tools_grow.ForegroundColor = color_text;
            v.handle_tools_grow.Tooltip = 'Click on any segmentation you want to make larger by the # of pixels in the box.';
            
            % create the grow number:
            v.handle_tools_grow_number = uicontrol(handle_tools);
            v.handle_tools_grow_number.Units = 'normalized';
            v.handle_tools_grow_number.Position = [x_tools_grow_number y_tools_grow_number width_tools_element height_tools_element];
            v.handle_tools_grow_number.Style = 'edit';
            v.handle_tools_grow_number.BackgroundColor = color_button;
            v.handle_tools_grow_number.ForegroundColor = color_text;
            
            % create the split button:
            v.handle_tools_split = uicontrol(handle_tools);
            v.handle_tools_split.Units = 'normalized';
            v.handle_tools_split.Position = [x_tools_split_button y_tools_split_button width_tools_element height_tools_element];
            v.handle_tools_split.String = sprintf('Split (%s)', v.shortcut_split);
            v.handle_tools_split.BackgroundColor = color_button;
            v.handle_tools_split.ForegroundColor = color_text;
            v.handle_tools_split.Tooltip = 'Click on any segmentation you want to split. This works best on snowman-shaped segmentations.';
            
            % create the redraw button:
            v.handle_tools_redraw = uicontrol(handle_tools);
            v.handle_tools_redraw.Units = 'normalized';
            v.handle_tools_redraw.Position = [x_tools_redraw_button y_tools_redraw_button width_tools_element height_tools_element];
            v.handle_tools_redraw.String = sprintf('Redraw (%s)', v.shortcut_redraw);
            v.handle_tools_redraw.BackgroundColor = color_button;
            v.handle_tools_redraw.ForegroundColor = color_text;
            v.handle_tools_redraw.Tooltip = 'Draw a portion of a segmentation.';
            
            % create the edit label:
            handle_tools_edit_label = uicontrol(handle_tools);
            handle_tools_edit_label.Units = 'normalized';
            handle_tools_edit_label.Position = [x_tools_label_edit y_tools_label_edit width_tools_label height_tools_label];
            handle_tools_edit_label.Style = 'text';
            handle_tools_edit_label.Enable = 'inactive';
            handle_tools_edit_label.String = 'Edit Segmentations';
            handle_tools_edit_label.BackgroundColor = color_background;
            handle_tools_edit_label.ForegroundColor = color_text;
            handle_tools_edit_label.HorizontalAlignment = 'Left';
            
            % create the draw button:
            v.handle_tools_draw = uicontrol(handle_tools);
            v.handle_tools_draw.Units = 'normalized';
            v.handle_tools_draw.Position = [x_tools_draw_button y_tools_draw_button width_tools_element height_tools_element];
            v.handle_tools_draw.String = sprintf('Draw (%s)', v.shortcut_draw);
            v.handle_tools_draw.BackgroundColor = color_button;
            v.handle_tools_draw.ForegroundColor = color_text;
            v.handle_tools_draw.Tooltip = 'Draw a segmentation.';
            
            % create the flood button:
            v.handle_tools_flood = uicontrol(handle_tools);
            v.handle_tools_flood.Units = 'normalized';
            v.handle_tools_flood.Position = [x_tools_flood_button y_tools_flood_button width_tools_element height_tools_element];
            v.handle_tools_flood.String = sprintf('Flood (%s)', v.shortcut_flood);
            v.handle_tools_flood.BackgroundColor = color_button;
            v.handle_tools_flood.ForegroundColor = color_text;
            v.handle_tools_flood.Tooltip = 'Click on a part of the image you want to segment by filling outwards from that point until the intensity is not in range of the value in the box.';
            
            % create the flood number:
            v.handle_tools_flood_number = uicontrol(handle_tools);
            v.handle_tools_flood_number.Units = 'normalized';
            v.handle_tools_flood_number.Position = [x_tools_flood_number y_tools_flood_number width_tools_element height_tools_element];
            v.handle_tools_flood_number.Style = 'edit';
            v.handle_tools_flood_number.BackgroundColor = color_button;
            v.handle_tools_flood_number.ForegroundColor = color_text;

            % create the automatic button:            
            v.handle_tools_automatic = uicontrol(handle_tools);
            v.handle_tools_automatic.Units = 'normalized';
            v.handle_tools_automatic.Position = [x_tools_automatic_button y_tools_automatic_button width_tools_element height_tools_element];
            v.handle_tools_automatic.String = sprintf('Automatic (%s)', v.shortcut_automatic);
            v.handle_tools_automatic.BackgroundColor = color_button;
            v.handle_tools_automatic.ForegroundColor = color_text;
            v.handle_tools_automatic.Tooltip = 'NOT YET WORKING';
            
            % create the add label:
            handle_tools_add_label = uicontrol(handle_tools);
            handle_tools_add_label.Units = 'normalized';
            handle_tools_add_label.Position = [x_tools_label_add y_tools_label_add width_tools_label height_tools_label];
            handle_tools_add_label.Style = 'text';
            handle_tools_add_label.Enable = 'inactive';
            handle_tools_add_label.String = 'Add Segmentations';
            handle_tools_add_label.BackgroundColor = color_background;
            handle_tools_add_label.ForegroundColor = color_text;
            handle_tools_add_label.HorizontalAlignment = 'Left';
            
            % create the delete button:
            v.handle_tools_delete = uicontrol(handle_tools);
            v.handle_tools_delete.Units = 'normalized';
            v.handle_tools_delete.Position = [x_tools_delete_button y_tools_delete_button width_tools_element height_tools_element];
            v.handle_tools_delete.String = sprintf('Delete (%s)', v.shortcut_delete);
            v.handle_tools_delete.BackgroundColor = color_button;
            v.handle_tools_delete.ForegroundColor = color_text;
            v.handle_tools_delete.Tooltip = 'Click on any segmentation you want to delete.';
            
            % create the delete label:
            handle_tools_delete_label = uicontrol(handle_tools);
            handle_tools_delete_label.Units = 'normalized';
            handle_tools_delete_label.Position = [x_tools_label_delete y_tools_label_delete width_tools_label height_tools_label];
            handle_tools_delete_label.Style = 'text';
            handle_tools_delete_label.Enable = 'inactive';
            handle_tools_delete_label.String = 'Delete Segmentations';
            handle_tools_delete_label.BackgroundColor = color_background;
            handle_tools_delete_label.ForegroundColor = color_text;
            handle_tools_delete_label.HorizontalAlignment = 'Left';
            
            % create the radiobutton group for channel to use for
            % calculations:
            v.handle_all_channels.handle_button_group = uibuttongroup(handle_channels);
            v.handle_all_channels.handle_button_group.Units = 'normalized';
            v.handle_all_channels.handle_button_group.Position = [x_channels_group margin width_channels_group height_channels_group];
            v.handle_all_channels.handle_button_group.BackgroundColor = color_background;
            v.handle_all_channels.handle_button_group.ForegroundColor = color_background;
            
            % for each channel:
            for i = 1:gui_data.num_channels
                
                % create the channel radiobuttons:
                temp_handle_radiobutton = sprintf('radiobutton_%01d', i);
                v.handle_all_channels.(temp_handle_radiobutton) = uicontrol(v.handle_all_channels.handle_button_group);
                v.handle_all_channels.(temp_handle_radiobutton).Units = 'normalized';
                v.handle_all_channels.(temp_handle_radiobutton).Position = [x_channels_radiobutton ((margin * i) + ((i-1)*(height_channels_radiobutton))) width_channels_radiobutton height_channels_radiobutton];
                v.handle_all_channels.(temp_handle_radiobutton).Style = 'radiobutton';
                v.handle_all_channels.(temp_handle_radiobutton).BackgroundColor = color_background;
                v.handle_all_channels.(temp_handle_radiobutton).ForegroundColor = color_text;
                
                % create the channel toggles:
                temp_handle_pushbutton = sprintf('pushbutton_%01d', i);
                v.handle_all_channels.(temp_handle_pushbutton) = uicontrol(handle_channels);
                v.handle_all_channels.(temp_handle_pushbutton).Units = 'normalized';
                v.handle_all_channels.(temp_handle_pushbutton).Position = [x_channels_toggle ((margin * i) + ((i-1)*(height_channels_toggle))) width_channels_toggle height_channels_toggle];
                v.handle_all_channels.(temp_handle_pushbutton).Style = 'pushbutton';
                v.handle_all_channels.(temp_handle_pushbutton).String = gui_data.list_channels{i};
                v.handle_all_channels.(temp_handle_pushbutton).BackgroundColor = color_button;
                v.handle_all_channels.(temp_handle_pushbutton).ForegroundColor = color_text;
                
                % create the channel color dropdowns:
                temp_handle_popupmenu = sprintf('popupmenu_%01d', i);
                v.handle_all_channels.(temp_handle_popupmenu) = uicontrol(handle_channels);
                v.handle_all_channels.(temp_handle_popupmenu).Units = 'normalized';
                v.handle_all_channels.(temp_handle_popupmenu).Position = [x_channels_dropdown ((margin * i) + ((i-1)*(height_channels_dropdown))) width_channels_dropdown height_channels_dropdown];
                v.handle_all_channels.(temp_handle_popupmenu).Style = 'popupmenu';
                v.handle_all_channels.(temp_handle_popupmenu).String = {'hi'};
                v.handle_all_channels.(temp_handle_popupmenu).BackgroundColor = color_button;
                
            end
            
            % set callbacks for the figure:
            v.handle_figure.KeyPressFcn = @v.callback_key_press;

            % hook up to the controller to the view:
            v.c = organoids2.utilities.edit_2D_segmentations.controller(v, gui_data);
            
            % hook up the view to the controller: 
            vc = v.c; % annoying syntax required by matlab
            v.handle_contrast_slider.Callback =                                 {@vc.callback_contrast};
            v.handle_navigation_stack_previous.Callback =                       {@vc.callback_stack_previous};
            v.handle_navigation_stack_current.Callback =                        {@vc.callback_stack_current};
            v.handle_navigation_stack_next.Callback =                           {@vc.callback_stack_next};
            v.handle_navigation_slice_previous.Callback =                       {@vc.callback_slice_previous};
            v.handle_navigation_slice_current.Callback =                        {@vc.callback_slice_current};
            v.handle_navigation_slice_next.Callback =                           {@vc.callback_slice_next};
            v.handle_tools_delete.Callback =                                    {@vc.callback_delete};
            v.handle_tools_automatic.Callback =                                 {@vc.callback_automatic};
            v.handle_tools_flood.Callback =                                     {@vc.callback_flood};
            v.handle_tools_draw.Callback =                                      {@vc.callback_draw};
            v.handle_tools_redraw.Callback =                                    {@vc.callback_redraw};
            v.handle_tools_split.Callback =                                     {@vc.callback_split};
            v.handle_tools_grow.Callback =                                      {@vc.callback_grow};
            v.handle_all_channels.handle_button_group.SelectionChangedFcn =     {@vc.callback_channels_change_calculation};
            for i = 1:gui_data.num_channels
               v.handle_all_channels.(sprintf('pushbutton_%01d', i)).Callback =     {@vc.callback_channels_change_visibility, i}; 
               v.handle_all_channels.(sprintf('popupmenu_%01d', i)).Callback =      {@vc.callback_channels_change_color, i};
            end
            
            % make all text larger:
            set(findall(gcf, '-property', 'FontSize'), 'FontSize', 16);
            
            % edit GUI to the center of the screen:
            movegui(v.handle_figure, 'center');
            
            % make the figure window visible:
            v.handle_figure.Visible = 'on';

        end
        
        % callback for key press:
        function v = callback_key_press(v, src, eventdata)
            
            % determine the key pressed:
            key_pressed = eventdata.Key;
            
            % depending on the key pressed:
            switch(key_pressed)
                case 'leftarrow'
                    v.c.callback_slice_previous(src, eventdata);
                case 'rightarrow'
                    v.c.callback_slice_next(src, eventdata);
                case 'downarrow'
                    v.c.callback_stack_previous(src, eventdata);
                case 'uparrow'
                    v.c.callback_stack_next(src, eventdata);
                case v.shortcut_grow
                    v.c.callback_grow(src, eventdata);
                case v.shortcut_split
                    v.c.callback_split(src, eventdata);
                case v.shortcut_redraw
                    v.c.callback_redraw(src, eventdata);
                case v.shortcut_draw 
                    v.c.callback_draw(src, eventdata);
                case v.shortcut_flood
                    v.c.callback_flood(src, eventdata);
                case v.shortcut_automatic
                    v.c.callback_automatic(src, eventdata);
                case v.shortcut_delete
                    v.c.callback_delete(src, eventdata);
            end
            
        end
        
    end
    
end