function guess_3D_segmentations_using_orthogonal_segmentations

    % get the list of segmentation files:
    list_files_XY = dir('nuclei_XY_final_2D*.mat');
    list_files_XZ = dir('nuclei_XZ_final_2D*.mat');
    
    % for each file:
    for i = 1:numel(list_files_XY)
        
        % get the image name:
        image_name = list_files_XY(i).name(end-9:end-4);
        
        % print status:
        fprintf('Working on stack %03d / %03d (%s) \n', i, numel(list_files_XY), image_name);
        
        % load the segmentations:
        segmentations_XY = organoids2.utilities.load_structure_from_file(list_files_XY(i).name);
        segmentations_XZ = organoids2.utilities.load_structure_from_file(list_files_XZ(i).name);
        
        % convert the XZ resul
        segmentations_XZ = convert_XZ_to_XY(segmentations_XZ);
        
        % get the 3D segmentation:
        segmentations_XY = convert_to_3D(segmentations_XY, segmentations_XZ);
        
        % remove any segmentations that are not connected to any other segmentations:
        segmentations_XY = remove_unconnected_segmentations(segmentations_XY);
        
        % remove the segmentation id field:
        if ~ischar(segmentations_XY)
            segmentations_XY = rmfield(segmentations_XY, 'segmentation_id');
        end
        
        % save segmentations:
        save(strrep(list_files_XY(i).name, 'XY_final_2D', 'guess_3D'), 'segmentations_XY');
        
    end

end

% function to convert coords from XZ to XY reference frame:
function segmentations_converted = convert_XZ_to_XY(segmentations)

    % create new variable for converted segmentations:
    segmentations_converted = segmentations;

    % for each segmentation:
    for i = 1:numel(segmentations_converted)
        
        % shrink:
        segmentations_converted(i).boundary(:,2) = floor((segmentations_converted(i).boundary(:,2) - 1) / 6) + 1;
        segmentations_converted(i).mask(:,2) = floor((segmentations_converted(i).mask(:,2) - 1) / 6) + 1;

        % convert:
        segmentations_converted(i).boundary = [segmentations_converted(i).boundary(:,1), segmentations_converted(i).boundary(:,3), segmentations_converted(i).boundary(:,2)];
        segmentations_converted(i).mask = [segmentations_converted(i).mask(:,1), segmentations_converted(i).mask(:,3), segmentations_converted(i).mask(:,2)];
        
    end

end

% function to convert 2D segmentations to 3D:
function segmentations_XY = convert_to_3D(segmentations_XY, segmentations_XZ)

    % if there are objects:
    if isstruct(segmentations_XY)

        % get number of objects:
        num_segmentations_XY = numel(segmentations_XY);
        num_segmentations_Z = numel(segmentations_XZ);

        % create array to store adjacency matrix:
        adjacency = zeros(num_segmentations_XY, num_segmentations_XY);

        % for each conn object:
        for i = 1:num_segmentations_Z

            % get Z coords:
            coords_Z = segmentations_XZ(i).boundary;

            % create array to store XY objects connected by a Z object:
            segmentations_connected = [];

            % for each seg object:
            for j = 1:num_segmentations_XY

                % get seg coords:
                coords_XY = segmentations_XY(j).boundary;

                % get intersection:
                overlap = intersectionHull('vert', coords_Z, 'vert', coords_XY);

                % if there is any overlap:
                if size(overlap.vert, 1) > 1

                    % add to list of connected objects:
                    segmentations_connected = cat(2, segmentations_connected, j);

                end

            end

            % add to adjacency matrix:
            adjacency(segmentations_connected, segmentations_connected) = 1;

        end

        % eliminate self-connections:
        adjacency = adjacency - diag(diag(adjacency));
        
        % convert the adjacency matrix to a graph:
        graph_connections = graph(adjacency);
        
        % get the betweenness of each node:
        node_betweenness = centrality(graph_connections, 'betweenness');
        
        % get the indices of nodes with betweenness great than 10:
        nodes_to_eliminate = node_betweenness > 10;

        % eliminate connections of these nodes:
        adjacency(nodes_to_eliminate,:) = 0;
        adjacency(:,nodes_to_eliminate) = 0;

        % update the graph:
        graph_connections = graph(adjacency);
        
        % cluster the objects:
        clusters = conncomp(graph_connections)';

        % add 3D object number to objects structure:
        for i = 1:num_segmentations_XY

            % save cluster assignment:
            segmentations_XY(i).object_num = clusters(i); 

        end
        
    end

end

% function to remove unconnected segmentations:
function segmentations = remove_unconnected_segmentations(segmentations)
        
        % get a list of 3D object numbers:
        list_3D_objects = unique(extractfield(segmentations, 'object_num'));
        
        % get the number of 2D objects in each 3D object:
        number_2D_objects_per_3D_object = zeros(size(list_3D_objects));
        for i = 1:numel(list_3D_objects)
            number_2D_objects_per_3D_object(i) = nnz(extractfield(segmentations, 'object_num') == list_3D_objects(i));
        end
        
        % get a list of 3D objects with only 1 member:
        list_3D_objects_unconnected = list_3D_objects(number_2D_objects_per_3D_object < 2);
        
        % for each unconnected object:
        for i = 1:numel(list_3D_objects_unconnected)
            [~, rows_remove] = organoids2.utilities.get_structure_results_matching_number(segmentations, 'object_num', list_3D_objects_unconnected(i));
            segmentations(rows_remove) = [];
        end

end