function organoid_type = get_organoid_type

    organoid_type = load(fullfile('..', 'organoid_type.mat'));
    organoid_type = organoid_type.organoid_type;

end