function list_features = get_list_features(data_struct)

    % get all structure fields:
    list_fields = fieldnames(data_struct);
    
    % get all fields containing the name feature:
    list_features = list_fields(contains(list_fields, 'feature'));
    
end