"""

    save_nc!(file::String,
             var_name::String,
             var_data::Array{T,N},
             var_attribute::Union{Dict{String,Any}, OrderedDict{String,Any}};
             var_dims::Vector{String} = N == 2 ? ["lon", "lat"] : ["lon", "lat", "ind"],
             compress::Int = 4,
             growable::Bool = false) where {T<:Union{AbstractFloat,Integer,String},N}

Save the 1D, 2D, or 3D data as netcdf file, given
- `file` Path to save the dataset
- `var_name` Variable name for the data in the NC file
- `var_data` Data to save
- `var_attribute` Variable attributes for the data, such as unit and long name
- `var_dims` Dimension name of each dimension of the variable data
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

Note that this is a wrapper function of create_nc and append_nc:
- If var_data is 1D, the dim is set to ind
- If var_data is 2D, and no var_dims are given, the dims are set to lon and lat
- If var_data is 3D, and no var_dims are given, the dims are set to lon, lat, and ind

#
    save_nc!(file::String,
             df::DataFrame,
             var_names::Vector{String},
             var_attributes::Union{Vector{Dict{String,Any}},Vector{OrderedDict{String,Any}}};
             compress::Int = 4,
             growable::Bool = false)
    save_nc!(file::String, df::DataFrame; compress::Int = 4, growable::Bool = false)

Save DataFrame to NetCDF, given
- `file` Path to save the data
- `df` DataFrame to save
- `var_names` The label of data in DataFrame to save
- `var_attributes` Variable attributes for the data to save
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

"""
function save_nc! end

save_nc!(file::String,
         var_name::String,
         var_data::Array{T,N},
         var_attribute::Union{Dict{String,Any}, OrderedDict{String,Any}};
         var_dims::Vector{String} = N == 2 ? ["lon", "lat"] : ["lon", "lat", "ind"],
         compress::Int = 4,
         growable::Bool = false
) where {T<:Union{AbstractFloat,Integer,String},N} = (
    @assert 1 <= N <= 3 "Variable must be a 1D, 2D, or 3D dataset!";
    @assert 0 <= compress <= 9 "Compression rate must be within 0 to 9";
    @assert N == 1 || "lon" in var_dims "2D or 3D data must have a dimension named lon";
    @assert N == 1 || "lat" in var_dims "2D or 3D data must have a dimension named lat";
    @assert N < 3 || "ind" in var_dims "3D data must have a dimension named ind";

    # create the file
    _dset = Dataset(file, "c");

    # global title attribute
    for (_title,_notes) in ATTR_ABOUT
        _dset.attrib[_title] = _notes;
    end;

    # the case if the dimension is 1D
    if N==1
        _n_ind = (growable ? Inf : length(var_data));
        _inds  = collect(eachindex(var_data));
        add_nc_dim!(_dset, "ind", _n_ind);
        append_nc!(_dset, "ind", _inds, ATTR_CYC, ["ind"]; compress=compress);
        append_nc!(_dset, var_name, var_data, var_attribute, ["ind"]; compress=compress);

        close(_dset);

        return nothing
    end;

    # if the dimension is 2D or 3D
    _lon = findfirst(isequal("lon"), var_dims);
    _lat = findfirst(isequal("lat"), var_dims);

    _n_lon   = size(var_data, _lon);
    _n_lat   = size(var_data, _lat);
    _res_lon = 360 / _n_lon;
    _res_lat = 180 / _n_lat;
    _lons    = collect(_res_lon/2:_res_lon:360) .- 180;
    _lats    = collect(_res_lat/2:_res_lat:180) .- 90;
    add_nc_dim!(_dset, "lon", _n_lon);
    add_nc_dim!(_dset, "lat", _n_lat);
    append_nc!(_dset, "lon", _lons, ATTR_LON, ["lon"]; compress=compress);
    append_nc!(_dset, "lat", _lats, ATTR_LAT, ["lat"]; compress=compress);

    if N==2
        append_nc!(_dset, var_name, var_data, var_attribute, var_dims; compress=compress);
    elseif N==3
        _ind = findfirst(isequal("ind"), var_dims);
        _n_ind = (growable ? Inf : size(var_data, _ind));
        _inds  = collect(1:_n_ind);
        add_nc_dim!(_dset, "ind", _n_ind);
        append_nc!(_dset, "ind", _inds, ATTR_CYC, ["ind"]; compress=compress);
        append_nc!(_dset, var_name, var_data, var_attribute, var_dims; compress=compress);
    end;

    close(_dset);

    return nothing
);

save_nc!(file::String,
         df::DataFrame,
         var_names::Vector{String},
         var_attributes::Union{Vector{Dict{String,Any}},Vector{OrderedDict{String,Any}}};
         compress::Int = 4,
         growable::Bool = false) = (
    @assert 0 <= compress <= 9 "Compression rate must be within 0 to 9";
    @assert length(var_names) == length(var_attributes) "Variable name and attributes lengths must match!";

    # create the file
    _dset = Dataset(file, "c");

    # global title attribute
    for (_title,_notes) in ATTR_ABOUT
        _dset.attrib[_title] = _notes;
    end;

    # define dimension related variables
    _n_ind = (growable ? Inf : size(df)[1]);
    _inds  = collect(1:size(df)[1]);

    # save the variables
    add_nc_dim!(_dset, "ind", _n_ind);
    append_nc!(_dset, "ind", _inds, ATTR_CYC, ["ind"]; compress=compress);
    for _i in eachindex(var_names)
        append_nc!(_dset, var_names[_i], df[:, var_names[_i]], var_attributes[_i], ["ind"]; compress = compress);
    end;

    close(_dset);

    return nothing
);

# TODO : use attribute parser to generate variable attributes automatically
save_nc!(file::String, df::DataFrame; compress::Int = 4, growable::Bool = false) = (
    _var_names = names(df);
    _var_attrs = [OrderedDict{String,Any}(_vn => _vn) for _vn in _var_names];

    save_nc!(file, df, _var_names, _var_attrs; compress=compress, growable = growable);

    return nothing
);
