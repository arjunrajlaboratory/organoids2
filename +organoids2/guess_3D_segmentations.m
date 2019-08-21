function guess_3D_segmentations

    % get the name of the structure to segment:
    name_structure = organoids2.utilities.ask_user_what_structure_to_segment;
    
    % ask user how they want to segment the data:
    list_segmentation_methods = {'using orthogonal segmentations', 'using connected components'};
    [index, ~] = listdlg('ListString', list_segmentation_methods, 'SelectionMode', 'single');
    segmentation_method = list_segmentation_methods{index};
    
    % depending on the structure to segment:
    switch segmentation_method
        
        case 'using orthogonal segmentations'
            
            organoids2.guess_3D_segmentations.guess_3D_segmentations_using_orthogonal_segmentations;
            
        case 'using connected components'
            
            organoids2.guess_3D_segmentations.guess_3D_segmentations_using_connected_components;
            
    end

end