function assign_cell_type

    % ask user what cell type they are working on:
    cell_type = questdlg('What cell type do you want to identify?', '', 'Paneth', 'Lgr5', 'Paneth');
    
    % depending on the cell type:
    switch cell_type
        
        % Paneth cells:
        case 'Paneth'
            
            channel_to_display = 'cy3';
            
        % Lgr5:
        case 'Lgr5'
            
            channel_to_display = 'gfp';
        
    end
    
    % get a list of stacks:
    list_stacks = dir(fullfile(pwd, '..', 'pos*_rgb.mat'));
   
    % set the continue flag:
    continue_flag = 'yes';
    
    % set the starting stack number:
    stack_current = 1;
    num_stacks = numel(list_stacks);
    
    % while the user wants to continue:
    while strcmp(continue_flag, 'yes')
        
        % get name of the image:
        name_image = list_stacks(stack_current).name;
        
        % load the rgb image:
        image = load(fullfile(list_stacks(stack_current).folder, name_image));
        image = image.image_rgb;
        
        % get the name of the stack:
        name_stack = name_image(1:6);
                
        % get the name of cell file:
        file_name_cells = sprintf('cells_%s_%s.mat', cell_type, name_stack);
        
        % if the cell file exists:
        if isfile(file_name_cells)
            
            % load the file:
            cells = organoids2.utilities.load_structure_from_file(file_name_cells);
            
        % otherwise:
        else
            
            % create an array to store the cells:
            cells = [];
            
        end

        % run the GUI:
        [cells, continue_flag, stack_progression] = organoids2.assign_cell_type.gui_to_id_cells(image, cells, stack_current, num_stacks);
        
        % save the features:
        save(file_name_cells, 'cells'); 
        
        % depending on how the user wants to progress:
        switch stack_progression
            case 'previous'
                stack_current = max(stack_current - 1, 1);
            case 'next'
                stack_current = min(stack_current + 1, num_stacks);
        end
 
    end

end