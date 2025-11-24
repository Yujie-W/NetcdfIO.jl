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
    dset = Dataset(file, "c");

    # global title attribute
    for (attr, note) in ATTR_ABOUT
        dset.attrib[attr] = note;
    end;

    # the case if the dimension is 1D
    if N==1
        n_ind = (growable ? Inf : length(var_data));
        inds  = collect(eachindex(var_data));
        add_nc_dim!(dset, "ind", n_ind);
        append_nc!(dset, "ind", inds, detect_attribute("ind"), ["ind"]; compress=compress);
        append_nc!(dset, var_name, var_data, var_attribute, ["ind"]; compress=compress);
        close(dset);

        return nothing
    end;

    # if the dimension is 2D or 3D
    lon = findfirst(isequal("lon"), var_dims);
    lat = findfirst(isequal("lat"), var_dims);

    n_lon   = size(var_data, lon);
    n_lat   = size(var_data, lat);
    res_lon = 360 / n_lon;
    res_lat = 180 / n_lat;
    lons    = collect(res_lon/2:res_lon:360) .- 180;
    lats    = collect(res_lat/2:res_lat:180) .- 90;
    add_nc_dim!(dset, "lon", n_lon);
    add_nc_dim!(dset, "lat", n_lat);
    append_nc!(dset, "lon", lons, detect_attribute("lon"), ["lon"]; compress=compress);
    append_nc!(dset, "lat", lats, detect_attribute("lat"), ["lat"]; compress=compress);

    if N==2
        append_nc!(dset, var_name, var_data, var_attribute, var_dims; compress=compress);
    elseif N==3
        ind = findfirst(isequal("ind"), var_dims);
        n_ind = (growable ? Inf : size(var_data, ind));
        inds  = collect(1:n_ind);
        add_nc_dim!(dset, "ind", n_ind);
        append_nc!(dset, "ind", inds, detect_attribute("ind"), ["ind"]; compress=compress);
        append_nc!(dset, var_name, var_data, var_attribute, var_dims; compress=compress);
    end;

    close(dset);

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
    dset = Dataset(file, "c");

    # global title attribute
    for (attr,note) in ATTR_ABOUT
        dset.attrib[attr] = note;
    end;

    # define dimension related variables
    n_ind = (growable ? Inf : size(df)[1]);
    inds  = collect(1:size(df)[1]);

    # save the variables
    add_nc_dim!(dset, "ind", n_ind);
    append_nc!(dset, "ind", inds, detect_attribute("ind"), ["ind"]; compress=compress);
    for i in eachindex(var_names)
        append_nc!(dset, var_names[i], df[:, var_names[i]], var_attributes[i], ["ind"]; compress = compress);
    end;

    close(dset);

    return nothing
);

save_nc!(file::String, df::DataFrame; compress::Int = 4, growable::Bool = false) = (
    var_names = names(df);
    var_attrs = [detect_attribute(vn; showwarning = false) for vn in var_names];

    save_nc!(file, df, var_names, var_attrs; compress=compress, growable = growable);

    return nothing
);
