function guess_3D_segmentations(varargin)

    % set the list of segmentation methods:
    list_segmentation_methods = {'using orthogonal segmentations', 'using connected components'};

    % if the user supplied a single input:
    if nargin == 1
        
        % set the segmentation method to use as the input:
        index = varargin{1};
        
    % otherwise:
    else
        
        % ask user how they want to segment the data:
        [index, ~] = listdlg('ListString', list_segmentation_methods, 'SelectionMode', 'single');
        
    end
    
    % depending on the segmentation method to use:
    switch list_segmentation_methods{index}
        
        case 'using orthogonal segmentations'
            
            organoids2.guess_3D_segmentations.guess_3D_segmentations_using_orthogonal_segmentations;
            
        case 'using connected components'
            
            organoids2.guess_3D_segmentations.guess_3D_segmentations_using_connected_components;
            
    end

end