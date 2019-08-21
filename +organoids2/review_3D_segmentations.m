function review_3D_segmentations

    % get the name of the structure to segment:
    structure_to_segment = organoids2.utilities.get_structure_to_segment;

    % run the gui to review the segmentations:
    organoids2.review_3D_segmentations.view(structure_to_segment);

end