function key = get_key_of_features(features)

    % get list of features in the data:
    list_features = organoids2.analysis.get_list_features(features);
    
    % create structure to store key:
    key = struct;
    
    %%% First, we'll assign each feature a more formatted name and a
    %%% category.
    
    % for each feature:
    for i = 1:numel(list_features)
        
        % get the feature name - unformatted:
        name_unformatted = list_features{i};
        
        % get the feature name - formatted:
        switch name_unformatted
            
            case 'feature_volume_organoid_mean'
                name_formatted = 'organoid volume (um^3)';
                
            case 'feature_surface_area_organoid_mean'
                name_formatted = 'organoid surface area (um^2)';
                
            case 'feature_height_organoid_mean'
                name_formatted = 'organoid height (um)';
                
            case 'feature_radius_organoid_mean'
                name_formatted = 'organoid mean radius (um)';
                
            case 'feature_radius_equivalent_organoid_mean'
                name_formatted = 'organoid equivalent radius (um)';
                
            case 'feature_radius_major_axis_organoid_mean'
                name_formatted = 'organoid major axis (um)';
                
            case 'feature_radius_minor_axis_organoid_mean'
                name_formatted = 'organoid minor axis (um)';
                
            case 'feature_major_to_minor_axis_organoid_mean'
                name_formatted = 'organoid major:minor axis';
            
            case 'feature_eccentricity_organoid_mean'
                name_formatted = 'organoid eccentricity';
                
            case 'feature_height_to_width_organoid_mean'
                name_formatted = 'organoid height:width';
                
            case 'feature_volume_lumens_mean'
                name_formatted = 'lumen mean volume (um^3)';
                
            case 'feature_volume_total_lumens'
                name_formatted = 'lumen total volume (um^3)';
                
            case 'feature_surface_area_lumens_mean'
                name_formatted = 'lumen mean surface area (um^2)';
                
            case 'feature_height_lumens_mean'
                name_formatted = 'lumen mean height (um)';
                
            case 'feature_radius_lumens_mean'
                name_formatted = 'lumen mean radius (um)';
                
            case 'feature_radius_equivalent_lumens_mean'
                name_formatted = 'lumen mean equivalent radius (um)';
                
            case 'feature_radius_major_axis_lumens_mean'
                name_formatted = 'lumen mean major axis (um)';
                
            case 'feature_radius_minor_axis_lumens_mean'
                name_formatted = 'lumen mean minor axis (um)';
                
            case 'feature_major_to_minor_axis_lumens_mean'
                name_formatted = 'lumen mean major:minor axis';
                
            case 'feature_eccentricity_lumens_mean'
                name_formatted = 'lumen mean eccentricity';
                
            case 'feature_height_to_width_lumens_mean'
                name_formatted = 'lumen mean height:width';
                
            case 'feature_number_lumens'
                name_formatted = 'lumen number';
                
            case 'feature_volume_lumens_st_dev'
                name_formatted = 'lumen st dev volume (um^3)';
                
            case 'feature_surface_area_lumens_st_dev'
                name_formatted = 'lumen st dev surface area (um^2)';
                
            case 'feature_height_lumens_st_dev'
                name_formatted = 'lumen st dev height (um)';
                
            case 'feature_radius_lumens_st_dev'
                name_formatted = 'lumen st dev radius (um)';
                
            case 'feature_radius_equivalent_lumens_st_dev'
                name_formatted = 'lumen st dev equivalent radius (um)';
                
            case 'feature_radius_major_axis_lumens_st_dev'
                name_formatted = 'lumen st dev major axis (um)';
                
           case 'feature_radius_minor_axis_lumens_st_dev'
                name_formatted = 'lumen st dev minor axis (um)'; 
                
            case 'feature_major_to_minor_axis_lumens_st_dev'
                name_formatted = 'lumen st dev major:minor axis';
                
            case 'feature_eccentricity_lumens_st_dev'
                name_formatted = 'lumen st dev eccentricity';
                
            case 'feature_height_to_width_lumens_st_dev'
                name_formatted = 'lumen st dev height:width';
                
            case 'feature_volume_nuclei_mean'
                name_formatted = 'nuclei mean volume (um^3)';
                
            case 'feature_volume_total_nuclei'
                name_formatted = 'nuclei total volume (um^3)';
                
            case 'feature_surface_area_nuclei_mean'
                name_formatted = 'nuclei mean surface area (um^2)';
                
            case 'feature_height_nuclei_mean'
                name_formatted = 'nuclei mean height (um)';
                
            case 'feature_radius_nuclei_mean'
                name_formatted = 'nuclei mean radius (um)';
                
            case 'feature_radius_equivalent_nuclei_mean'
                name_formatted = 'nuclei mean equivalent radius (um)';
                
            case 'feature_radius_major_axis_nuclei_mean'
                name_formatted = 'nuclei mean major axis (um)';
                
            case 'feature_radius_minor_axis_nuclei_mean'
                name_formatted = 'nuclei mean minor axis (um)';
                
            case 'feature_major_to_minor_axis_nuclei_mean'
                name_formatted = 'nuclei mean major:minor axis';
                
            case 'feature_eccentricity_nuclei_mean'
                name_formatted = 'nuclei mean eccentricity';
                
            case 'feature_height_to_width_nuclei_mean'
                name_formatted = 'nuclei mean height:width';
                
            case 'feature_number_nuclei'
                name_formatted = 'nuclei number';
                
            case 'feature_volume_nuclei_st_dev'
                name_formatted = 'nuclei st dev volume (um^3)';
                
            case 'feature_surface_area_nuclei_st_dev'
                name_formatted = 'nuclei st dev surface area (um^2)';
                
            case 'feature_height_nuclei_st_dev'
                name_formatted = 'nuclei st dev height (um)';
                
            case 'feature_radius_nuclei_st_dev'
                name_formatted = 'nuclei st dev radius (um)';
                
            case 'feature_radius_equivalent_nuclei_st_dev'
                name_formatted = 'nuclei st dev equivalent radius (um)';
                
            case 'feature_radius_major_axis_nuclei_st_dev'
                name_formatted = 'nuclei st dev major axis (um)';
                
            case 'feature_radius_minor_axis_nuclei_st_dev'
                name_formatted = 'nuclei st dev minor axis (um)';
                
            case 'feature_major_to_minor_axis_nuclei_st_dev'
                name_formatted = 'nuclei st dev major:minor axis';
                
            case 'feature_eccentricity_nuclei_st_dev'
                name_formatted = 'nuclei st dev eccentricity';
                
            case 'feature_height_to_width_nuclei_st_dev'
                name_formatted = 'nuclei st dev height:width';
                
            case 'feature_wall_thickness_mean'
                name_formatted = 'wall thickness mean (um)';
                
            case 'feature_wall_thickness_st_dev'
                name_formatted = 'wall thickness st dev (um)';
                
            case 'feature_volume_fractional_lumens'
                name_formatted = 'lumen fractional volume';
                
            case 'feature_volume_fractional_nuclei'
                name_formatted = 'nuclei fractional volume';
                
            case 'feature_density_lumens'
                name_formatted = 'lumen density (#/um^3)';
                
            case 'feature_density_nuclei'
                name_formatted = 'nuclei density (#/um^3)';
                
            otherwise
                error('The %s feature has not been assigned an unformatted name in the key', name_unformatted);
        end
        
        % get the feature category:
        switch name_unformatted
            
            case {...
                    'feature_volume_organoid_mean', ...
                    'feature_surface_area_organoid_mean', ...
                    'feature_height_organoid_mean', ...
                    'feature_radius_organoid_mean', ...
                    'feature_radius_equivalent_organoid_mean', ...
                    'feature_radius_major_axis_organoid_mean', ...
                    'feature_radius_minor_axis_organoid_mean'}
                category = 'organoid size';
                
            case {...
                    'feature_major_to_minor_axis_organoid_mean', ...
                    'feature_eccentricity_organoid_mean', ...
                    'feature_height_to_width_organoid_mean'}
                category = 'organoid shape';
                
            case {...
                    'feature_volume_lumens_mean', ...
                    'feature_volume_total_lumens', ...
                    'feature_surface_area_lumens_mean', ...
                    'feature_height_lumens_mean', ...
                    'feature_radius_lumens_mean', ...
                    'feature_radius_equivalent_lumens_mean', ...
                    'feature_radius_major_axis_lumens_mean', ...
                    'feature_radius_minor_axis_lumens_mean'}
                category = 'lumen size';
                
            case {...
                    'feature_major_to_minor_axis_lumens_mean', ...
                    'feature_eccentricity_lumens_mean', ...
                    'feature_height_to_width_lumens_mean'}
                category = 'lumen shape';
                
            case {...
                    'feature_number_lumens', ...
                    'feature_volume_lumens_st_dev', ...
                    'feature_surface_area_lumens_st_dev', ...
                    'feature_height_lumens_st_dev', ...
                    'feature_radius_lumens_st_dev', ...
                    'feature_radius_equivalent_lumens_st_dev', ...
                    'feature_radius_major_axis_lumens_st_dev', ...
                    'feature_radius_minor_axis_lumens_st_dev', ...
                    'feature_major_to_minor_axis_lumens_st_dev', ...
                    'feature_eccentricity_lumens_st_dev', ...
                    'feature_height_to_width_lumens_st_dev'}
                category = 'lumen number';
                
            case {...
                    'feature_volume_nuclei_mean', ...
                    'feature_volume_total_nuclei', ...
                    'feature_surface_area_nuclei_mean', ...
                    'feature_height_nuclei_mean', ...
                    'feature_radius_nuclei_mean', ...
                    'feature_radius_equivalent_nuclei_mean', ...
                    'feature_radius_major_axis_nuclei_mean', ...
                    'feature_radius_minor_axis_nuclei_mean'}
                category = 'nuclei size';
                
            case {...
                    'feature_major_to_minor_axis_nuclei_mean', ...
                    'feature_eccentricity_nuclei_mean', ...
                    'feature_height_to_width_nuclei_mean'}
                category = 'nuclei shape';
                
            case {...
                    'feature_number_nuclei', ...
                    'feature_volume_nuclei_st_dev', ...
                    'feature_surface_area_nuclei_st_dev', ...
                    'feature_height_nuclei_st_dev', ...
                    'feature_radius_nuclei_st_dev', ...
                    'feature_radius_equivalent_nuclei_st_dev', ...
                    'feature_radius_major_axis_nuclei_st_dev', ...
                    'feature_radius_minor_axis_nuclei_st_dev', ...
                    'feature_major_to_minor_axis_nuclei_st_dev', ...
                    'feature_eccentricity_nuclei_st_dev', ...
                    'feature_height_to_width_nuclei_st_dev'}
                category = 'nuclei number';
                
            case {...
                    'feature_wall_thickness_mean', ...
                    'feature_wall_thickness_st_dev', ...
                    'feature_volume_fractional_lumens', ...
                    'feature_volume_fractional_nuclei', ...
                    'feature_density_lumens', ...
                    'feature_density_nuclei'}
                category = 'other';
                
            otherwise
                error('The %s feature has not been assigned a category in the key', name_unformatted);
        end
        
        % save to key:
        key(i).name_unformatted = name_unformatted;
        key(i).name_formatted = name_formatted;
        key(i).category = category;
        
    end
    
    %%% Next, we want to sort the feature key by category. 
    key = organoids2.utilities.sort_structure_by_field(key, {'category'});
    
    %%% Next, we want to assign each category a color.
    
    % for each feature:
    for i = 1:numel(key)
        
        % determine the category:
        temp_category = key(i).category;
        
        % depending on the category:
        switch temp_category
            
            % get the color to assign:
            case 'organoid size'
                temp_color = [0.0 0.5 0.0];
            case 'organoid shape'
                temp_color = [0.0 1.0 0.0];
            case 'lumen size'
                temp_color = [0.5 0.0 0.0];
            case 'lumen shape'
                temp_color = [1.0 0.0 0.0];
            case 'lumen number'
                temp_color = [1.0 0.5 0.5];
            case 'nuclei size'
                temp_color = [0.0 0.0 0.5];
            case 'nuclei shape'
                temp_color = [0.0 0.0 1.0];
            case 'nuclei number'
                temp_color = [0.5 0.5 1.0];
            case 'other'
                temp_color = [0.5 0.5 0.5];
            otherwise 
                error('no color has been assigned for %s feature category');
            
        end
        
        % save color:
        key(i).color = temp_color;
        
    end
    
end