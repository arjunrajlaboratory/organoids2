function [features_table, features_mat] = reformat_data(features_struct_all)
    
    % convert the features structure to a table:
    features_table = struct2table(features_struct_all);

    % get list of fields:
    list_fields = fieldnames(features_struct_all);
    
    % get list of features:
    list_features = organoids2.analysis.get_list_features(features_struct_all);
    
    % get list of fields to remove (everything that is not a feature):
    list_fields_remove = setdiff(list_fields, list_features);
    
    % remove non-feature fields:
    features_struct_data = rmfield(features_struct_all, list_fields_remove);

    % convert the features structure to a matrix:
    features_mat = squeeze(struct2cell(features_struct_data));
    features_mat = cell2mat(features_mat)';

end