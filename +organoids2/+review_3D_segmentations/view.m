classdef view < handle
    
    properties

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

        handle_tools_draw;
        
        handle_annotations;
        
        % add controller:
        c;
        
    end
    
    methods
        
        % constructor:
        function v = view(settings)
           
            % set the margin to use between elements:
            margin =                            0.01;
            
            % set the widths:
            width_figure =                      0.9;
            width_half =                        (1 - 3 * margin) / 2;
            
            width_axes =                        width_half;
            width_tools =                       width_half;
            width_navigation =                  width_half;
            width_contrast =                    width_half;

            width_tools_element =               0.2;
            width_tools_text =                  (1 - (4 * margin) - (2 * width_tools_element));
            width_tools_label =                 1 - (2 * margin);
            
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
            
            height_tools_element =              (1 - 11 * margin) / 10;
            height_tools_text =                 (1 - 11 * margin) / 10;
            height_tools_label =                (1 - 11 * margin) / 10;
            
            height_navigation_element =         (1 - 3 * margin) / 2;
            height_navigation_text =            (1 - 3 * margin) / 2;
            
            height_contrast_element =           1 - 2 * margin;
            
            % set the x coords:
            x_figure =                          0;
            
            x_axes =                            margin;
            x_contrast =                        margin + width_axes + margin;
            x_navigation =                      margin + width_axes + margin;
            x_tools =                           margin + width_axes + margin;

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
            x_tools_grow_text =                 margin + width_tools_element + margin;
            x_tools_grow_number =               margin + width_tools_element + margin + width_tools_text + margin;
            x_tools_split_button =              margin;
            x_tools_split_text =                margin + width_tools_element + margin;
            x_tools_redraw_button =             margin;
            x_tools_redraw_text =               margin + width_tools_element + margin;
            x_tools_label_edit =                margin;
            x_tools_draw_button =               margin;
            x_tools_draw_text =                 margin + width_tools_element + margin;
            x_tools_flood_button =              margin;
            x_tools_flood_text =                margin + width_tools_element + margin;
            x_tools_flood_number =              margin + width_tools_element + margin + width_tools_text + margin;
            x_tools_automatic_button =          margin;
            x_tools_automatic_text =            margin + width_tools_element + margin;
            x_tools_label_add =                 margin;
            x_tools_delete_button =             margin;
            x_tools_delete_text =               margin + width_tools_element + margin;
            x_tools_label_delete =              margin;

            % set the y coords:
            y_figure =                          0;
            
            y_axes =                            margin;
            y_contrast =                        margin;
            y_navigation =                      margin + height_contrast + margin;
            y_tools =                           margin + height_contrast + margin+ height_navigation + margin;
            
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
            y_tools_grow_text =                 margin;
            y_tools_grow_number =               margin;
            y_tools_split_button =              margin + height_tools_element + margin;
            y_tools_split_text =                margin + height_tools_element + margin;
            y_tools_redraw_button =             margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_redraw_text =               margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_label_edit =                margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_draw_button =               margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_draw_text =                 margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_flood_button =              margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_flood_text =                margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_flood_number =              margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_automatic_button =          margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_automatic_text =            margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_label_add =                 margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_delete_button =             margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
            y_tools_delete_text =               margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin + height_tools_element + margin;
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
            v.handle_navigation_stack_previous.String = 'Previous Stack';
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
            v.handle_navigation_stack_next.String = 'Next Stack';
            v.handle_navigation_stack_next.Style = 'pushbutton';
            v.handle_navigation_stack_next.BackgroundColor = color_button;
            v.handle_navigation_stack_next.ForegroundColor = color_text;
            
            % create the previous slice button:
            v.handle_navigation_slice_previous = uicontrol(handle_navigation);
            v.handle_navigation_slice_previous.Units = 'normalized';
            v.handle_navigation_slice_previous.Position = [x_navigation_slice_previous y_navigation_slice_previous width_navigation_element height_navigation_element];
            v.handle_navigation_slice_previous.String = 'Previous Slice';
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
            v.handle_navigation_slice_next.String = 'Next Slice';
            v.handle_navigation_slice_next.Style = 'pushbutton';
            v.handle_navigation_slice_next.BackgroundColor = color_button;
            v.handle_navigation_slice_next.ForegroundColor = color_text;
            
            % create the draw button:
            v.handle_tools_draw = uicontrol(handle_tools);
            v.handle_tools_draw.Units = 'normalized';
            v.handle_tools_draw.Position = [x_tools_draw_button y_tools_draw_button width_tools_element height_tools_element];
            v.handle_tools_draw.String = 'Draw (d)';
            v.handle_tools_draw.BackgroundColor = color_button;
            v.handle_tools_draw.ForegroundColor = color_text;
            
            % create the draw instructions box:
            handle_tools_draw_instructions = uicontrol(handle_tools);
            handle_tools_draw_instructions.Units = 'normalized';
            handle_tools_draw_instructions.Position = [x_tools_draw_text y_tools_draw_text width_tools_text height_tools_text];
            handle_tools_draw_instructions.Style = 'text';
            handle_tools_draw_instructions.Enable = 'inactive';
            handle_tools_draw_instructions.String = 'Draw a segmentation.';
            handle_tools_draw_instructions.BackgroundColor = color_background;
            handle_tools_draw_instructions.ForegroundColor = color_text;
            handle_tools_draw_instructions.HorizontalAlignment = 'Left';
           
            % edit GUI to the center of the screen:
            movegui(v.handle_figure, 'center');
            
            % set callbacks for the figure:
            v.handle_figure.KeyPressFcn = @v.callback_key_press;

            % hook up to the controller to the view:
            v.c = organoids2.review_3D_segmentations.controller(v, settings);
            
            % hook up the view to the controller:
            vc = v.c; 
            v.handle_contrast_slider.Callback =             {@vc.callback_contrast};
            v.handle_navigation_stack_previous.Callback =   {@vc.callback_stack_previous};
            v.handle_navigation_stack_current.Callback =    {@vc.callback_stack_current};
            v.handle_navigation_stack_next.Callback =       {@vc.callback_stack_next};
            v.handle_navigation_slice_previous.Callback =   {@vc.callback_slice_previous};
            v.handle_navigation_slice_current.Callback =    {@vc.callback_slice_current};
            v.handle_navigation_slice_next.Callback =       {@vc.callback_slice_next};
            v.handle_tools_draw.Callback =                  {@vc.callback_draw};

            % make all text larger:
            set(findall(gcf, '-property', 'FontSize'), 'FontSize', 16);
            
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
                case 'd'
                    v.c.callback_draw(src, eventdata);

            end
            
        end
        
    end
    
end