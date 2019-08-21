function data_struct_new = exclude_features_from_data(data_struct, list_feature_strings_to_remove)

    % get list of fieds:
    list_fields = fieldnames(data_struct);

    % get list of fields to remove:
    list_fields_remove = list_fields(contains(list_fields, list_feature_strings_to_remove));

    % remove those features from the structure:
    data_struct_new = rmfield(data_struct, list_fields_remove);
    
end