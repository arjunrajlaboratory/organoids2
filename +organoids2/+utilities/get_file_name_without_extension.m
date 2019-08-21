function file_name_no_ext = get_file_name_without_extension(file_name)

    file_name_no_ext = file_name(1:strfind(file_name, '.') - 1);

end