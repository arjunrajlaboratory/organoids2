classdef view < handle
    
    properties
        
        % set keyboard shortcuts:
        shortcut_draw = 'f';

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
        handle_navigation_step_size;

        handle_tools_draw;
        
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
            width_full =                        1 - 2 * margin;
            width_third =                       (1 - 4 * margin) / 3;
            width_half =                        (1 - 3 * margin) / 2;
            
            width_axes =                        width_full;
            width_tools =                       width_third;
            width_channels =                    width_third;
            width_navigation =                  width_third;

            width_tools_element =               (1 - 3 * margin) / 2;
            
            width_channels_toggle =             (1 - (1 + gui_data.num_channels) * margin) / gui_data.num_channels;             
            width_channels_dropdown =           (1 - (1 + gui_data.num_channels) * margin) / gui_data.num_channels;  
            width_channels_contrast =           width_full;
            
            width_navigation_element =          (1 - 4 * margin) / 3;
            width_navigation_text =             (1 - 10 * margin) / 9;
            
            % set the heights:
            height_figure =                     0.8;
            height_big =                        0.8;
            height_small =                      1 - height_big - (3 * margin);
            
            height_axes =                       height_big;
            height_navigation =                 height_small;
            height_tools =                      height_small; 
            height_channels =                   height_small; 
            
            height_tools_element =              1 - 2 * margin;
            
            height_channels_dropdown =          0.1;
            height_channels_contrast =          0.1;
            height_channels_toggle =            1 - (4 * margin) - height_channels_dropdown - height_channels_contrast - 0.2;
            
            height_navigation_element =         (1 - 4 * margin) / 3;
            height_navigation_text =            (1 - 4 * margin) / 3;
            
            % set the x coords:
            x_figure =                          0;
            
            x_axes =                            margin;
            
            x_channels =                        margin;
            x_tools =                           margin + width_channels + margin;
            x_navigation =                      margin + width_channels + margin + width_tools + margin;
            
            x_channels_contrast =               margin;

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
            x_navigation_step_label =           margin;
            x_navigation_step_size =            margin + width_navigation_element + margin;
            
            x_tools_draw_button =               margin;

            % set the y coords:
            y_figure =                          0;
            
            y_navigation =                      margin;
            y_tools =                           margin;
            y_channels =                        margin;
            y_axes =                            margin + height_small + margin;
            
            y_channels_contrast =               margin;
            y_channels_dropdown =               margin + height_channels_contrast + margin + 0.1;
            y_channels_toggle =                 margin + height_channels_contrast + margin + height_channels_dropdown + margin + 0.2;

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
            y_navigation_step_label =           margin + height_navigation_element + margin + height_navigation_element + margin;
            y_navigation_step_size =            margin + height_navigation_element + margin + height_navigation_element + margin;
            
            y_tools_draw_button =               margin;

            % set the colors:
            color_text = 'white';
            color_background = [0.1 0.1 0.1];
            color_button = [0.25 0.25 0.25];
            
            % create the figure:
            v.handle_figure = figure('Visible', 'on');
            v.handle_figure.Units = 'normalized';
            v.handle_figure.Position = [x_figure y_figure width_figure height_figure];
            v.handle_figure.Color = color_background;
            
            % create the image axes:
            v.handle_axes = axes(v.handle_figure);
            v.handle_axes.Units = 'normalized';
            v.handle_axes.Position = [x_axes y_axes width_axes height_axes];
            
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
            v.handle_contrast_slider = uicontrol(handle_channels);
            v.handle_contrast_slider.Units = 'normalized';
            v.handle_contrast_slider.Position = [x_channels_contrast y_channels_contrast width_channels_contrast height_channels_contrast];
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
            
            % create the step size label box:
            handle_navigation_step_label = uicontrol(handle_navigation);
            handle_navigation_step_label.Units = 'normalized';
            handle_navigation_step_label.Position = [x_navigation_step_label y_navigation_step_label width_navigation_element height_navigation_element];
            handle_navigation_step_label.Style = 'edit';
            handle_navigation_step_label.String = 'Step Size:';
            handle_navigation_step_label.Enable = 'inactive';
            handle_navigation_step_label.BackgroundColor = color_button;
            handle_navigation_step_label.ForegroundColor = color_text;
            
            % create the step size box:
            v.handle_navigation_step_size = uicontrol(handle_navigation);
            v.handle_navigation_step_size.Units = 'normalized';
            v.handle_navigation_step_size.Position = [x_navigation_step_size y_navigation_step_size width_navigation_text height_navigation_text];
            v.handle_navigation_step_size.Style = 'edit';
            v.handle_navigation_step_size.BackgroundColor = color_button;
            v.handle_navigation_step_size.ForegroundColor = color_text;
            
            % create the draw button:
            v.handle_tools_draw = uicontrol(handle_tools);
            v.handle_tools_draw.Units = 'normalized';
            v.handle_tools_draw.Position = [x_tools_draw_button y_tools_draw_button width_tools_element height_tools_element];
            v.handle_tools_draw.String = sprintf('Draw (%s)', v.shortcut_draw);
            v.handle_tools_draw.BackgroundColor = color_button;
            v.handle_tools_draw.ForegroundColor = color_text;
            v.handle_tools_draw.Tooltip = 'Draw a segmentation.';
            
            % for each channel:
            for i = 1:gui_data.num_channels
                
                % create the channel toggles:
                temp_handle_pushbutton = sprintf('pushbutton_%01d', i);
                v.handle_all_channels.(temp_handle_pushbutton) = uicontrol(handle_channels);
                v.handle_all_channels.(temp_handle_pushbutton).Units = 'normalized';
                v.handle_all_channels.(temp_handle_pushbutton).Position = [((margin * i) + ((i-1)*(width_channels_toggle))) y_channels_toggle width_channels_toggle height_channels_toggle];
                v.handle_all_channels.(temp_handle_pushbutton).Style = 'pushbutton';
                v.handle_all_channels.(temp_handle_pushbutton).String = gui_data.list_channels{i};
                v.handle_all_channels.(temp_handle_pushbutton).BackgroundColor = color_button;
                v.handle_all_channels.(temp_handle_pushbutton).ForegroundColor = color_text;
                
                % create the channel color dropdowns:
                temp_handle_popupmenu = sprintf('popupmenu_%01d', i);
                v.handle_all_channels.(temp_handle_popupmenu) = uicontrol(handle_channels);
                v.handle_all_channels.(temp_handle_popupmenu).Units = 'normalized';
                v.handle_all_channels.(temp_handle_popupmenu).Position = [((margin * i) + ((i-1)*(width_channels_dropdown))) y_channels_dropdown width_channels_dropdown height_channels_dropdown];
                v.handle_all_channels.(temp_handle_popupmenu).Style = 'popupmenu';
                v.handle_all_channels.(temp_handle_popupmenu).String = {'hi'};
                v.handle_all_channels.(temp_handle_popupmenu).BackgroundColor = color_button;
                
            end
            
            % set callbacks for the figure:
            v.handle_figure.KeyPressFcn = @v.callback_key_press;

            % hook up to the controller to the view:
            v.c = organoids2.utilities.edit_3D_segmentations.controller(v, gui_data);
            
            % hook up the view to the controller: 
            vc = v.c; % annoying syntax required by matlab
            v.handle_contrast_slider.Callback =                                 {@vc.callback_contrast};
            v.handle_navigation_stack_previous.Callback =                       {@vc.callback_stack_previous};
            v.handle_navigation_stack_current.Callback =                        {@vc.callback_stack_current};
            v.handle_navigation_stack_next.Callback =                           {@vc.callback_stack_next};
            v.handle_navigation_slice_previous.Callback =                       {@vc.callback_slice_previous};
            v.handle_navigation_slice_current.Callback =                        {@vc.callback_slice_current};
            v.handle_navigation_slice_next.Callback =                           {@vc.callback_slice_next};
            v.handle_navigation_step_size.Callback =                            {@vc.callback_step_size};
            v.handle_tools_draw.Callback =                                      {@vc.callback_draw};
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
                case v.shortcut_draw 
                    v.c.callback_draw(src, eventdata);
            end
            
        end
        
    end
    
end