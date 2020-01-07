function cell_volume_mean = measure_cell_volume(volume_organoid, volume_total_lumens, number_nuclei)

    % determine organoid volume for cells:
    if isnan(volume_total_lumens)
        volume_cells = volume_organoid;
    else
        volume_cells = volume_organoid - volume_total_lumens;
    end
    
    % determine mean cell volume:
    cell_volume_mean = volume_cells / number_nuclei;
    
end