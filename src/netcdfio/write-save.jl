"""

    save_nc!(file::String,
             var_name::UnionNameTypes,
             var_data::Array{T,N},
             var_attributes::Union{Dict{String,Any}, OrderedDict{String,Any}};
             var_dims::Vector{String} = N == 2 ? ["lon", "lat"] : ["lon", "lat", "ind"],
             deflatelevel::Union{Int,Nothing} = 4,
             growable::Bool = false) where {T<:Union{AbstractFloat,Integer,String},N}

Save the 1D, 2D, or 3D data as netcdf file, given
- `file` Path to save the dataset
- `var_name` Variable name for the data in the NC file
- `var_data` Data to save
- `var_attributes` Variable attributes for the data, such as unit and long name
- `var_dims` Dimension name of each dimension of the variable data
- `deflatelevel` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

Note that this is a wrapper function of create_nc and append_nc:
- If var_data is 1D, the dim is set to ind
- If var_data is 2D, and no var_dims are given, the dims are set to lon and lat
- If var_data is 3D, and no var_dims are given, the dims are set to lon, lat, and ind

#
    save_nc!(file::String,
             df::DataFrame,
             var_names::Vector{<:UnionNameTypes},
             var_attributes_vec::UnionAttrVecTypes;
             deflatelevel::Union{Int,Nothing} = 4,
             growable::Bool = false)
    save_nc!(file::String, df::DataFrame; deflatelevel::Union{Int,Nothing} = 4, growable::Bool = false)

Save DataFrame to NetCDF, given
- `file` Path to save the data
- `df` DataFrame to save
- `var_names` The label of data in DataFrame to save
- `var_attributes` Variable attributes for the data to save
- `deflatelevel` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

"""
function save_nc! end

save_nc!(file::String,
         var_name::UnionNameTypes,
         var_data::Array{T,N},
         var_attributes::Union{Dict{String,Any}, OrderedDict{String,Any}};
         var_dims::Vector{String} = N == 2 ? ["lon", "lat"] : ["lon", "lat", "ind"],
         deflatelevel::Union{Int,Nothing} = 4,
         growable::Bool = false
) where {T<:Union{AbstractFloat,Integer,String},N} = (
    @assert 1 <= N <= 3 "Variable must be a 1D, 2D, or 3D dataset!";
    @assert isnothing(deflatelevel) || (0 <= deflatelevel <= 9) "Compression rate must be within 0 to 9";
    @assert N == 1 || "lon" in var_dims "2D or 3D data must have a dimension named lon";
    @assert N == 1 || "lat" in var_dims "2D or 3D data must have a dimension named lat";
    @assert N < 3 || "ind" in var_dims "3D data must have a dimension named ind";

    # create the file
    ds = Dataset(file, "c");

    # global title attribute
    for (attr, note) in ATTR_ABOUT
        ds.attrib[attr] = note;
    end;

    # the case if the dimension is 1D
    if N == 1
        n_ind = (growable ? Inf : length(var_data));
        inds  = collect(eachindex(var_data));
        add_nc_dim!(ds, "ind", n_ind);
        append_nc!(ds, "ind", inds, detect_attribute("ind"), ["ind"]; deflatelevel = deflatelevel);
        append_nc!(ds, var_name, var_data, var_attributes, ["ind"]; deflatelevel = deflatelevel);
        close(ds);

        return nothing
    end;

    # if the dimension is 2D or 3D
    lon = findfirst(isequal("lon"), var_dims);
    lat = findfirst(isequal("lat"), var_dims);

    n_lon   = size(var_data, lon);
    n_lat   = size(var_data, lat);
    res_lon = 360 / n_lon;
    res_lat = 180 / n_lat;
    lons    = collect(Float32, res_lon/2:res_lon:360) .- 180;
    lats    = collect(Float32, res_lat/2:res_lat:180) .- 90;
    add_nc_dim!(ds, "lon", n_lon);
    add_nc_dim!(ds, "lat", n_lat);
    append_nc!(ds, "lon", lons, detect_attribute("lon"), ["lon"]; deflatelevel = deflatelevel);
    append_nc!(ds, "lat", lats, detect_attribute("lat"), ["lat"]; deflatelevel = deflatelevel);

    if N == 2
        append_nc!(ds, var_name, var_data, var_attributes, var_dims; deflatelevel = deflatelevel);
    elseif N == 3
        ind = findfirst(isequal("ind"), var_dims);
        n_ind = (growable ? Inf : size(var_data, ind));
        inds  = collect(1:n_ind);
        add_nc_dim!(ds, "ind", n_ind);
        append_nc!(ds, "ind", inds, detect_attribute("ind"), ["ind"]; deflatelevel = deflatelevel);
        append_nc!(ds, var_name, var_data, var_attributes, var_dims; deflatelevel = deflatelevel);
    end;

    close(ds);

    return nothing
);

save_nc!(file::String,
         nt::NamedTuple,
         var_attributes_vec::UnionAttrVecTypes;
         deflatelevel::Union{Int,Nothing} = 4,
         growable::Bool = false) = (
    @assert isnothing(deflatelevel) || (0 <= deflatelevel <= 9) "Compression rate must be within 0 to 9";
    @assert length(nt) == length(var_attributes_vec) "Variable name and attributes lengths must match!";

    # create the file
    ds = Dataset(file, "c");

    # global title attribute
    for (attr,note) in ATTR_ABOUT
        ds.attrib[attr] = note;
    end;

    # define dimension related variables
    n_ind = (growable ? Inf : length(nt[1]));
    inds  = collect(eachindex(nt[1]));

    # save the variables
    add_nc_dim!(ds, "ind", n_ind);
    append_nc!(ds, "ind", inds, detect_attribute("ind"), ["ind"]; deflatelevel = deflatelevel);
    for i in 1:length(nt)
        var_name = keys(nt)[i];
        var_data = nt[var_name];
        var_attributes = var_attributes_vec[i];
        append_nc!(ds, var_name, var_data, var_attributes, ["ind"]; deflatelevel = deflatelevel);
    end;

    close(ds);

    return nothing
);

save_nc!(file::String, nt::NamedTuple; args...) = save_nc!(file, nt, [detect_attribute(vn; showwarning = false) for vn in keys(nt)]; args...);

save_nc!(file::String, df::DataFrame; args...) = (
    nt = NamedTuple{Tuple(Symbol.(names(df)))}(Tuple([df[:,k] for k in names(df)]));
    var_attributes_vec = [detect_attribute(vn; showwarning = false) for vn in names(df)];

    return save_nc!(file, nt, var_attributes_vec; args...)
);

save_nc!(file::String, df::DataFrame, var_names::Vector{<:UnionNameTypes}, var_attributes_vec::UnionAttrVecTypes; args...) = (
    nt = NamedTuple{Tuple(Symbol.(var_names))}(Tuple([df[:,k] for k in var_names]));

    return save_nc!(file, nt, var_attributes_vec; args...)
);
