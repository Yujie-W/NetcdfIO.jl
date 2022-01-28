"""
NCDatasets.jl does not have a convenient function (1 line command) to save dataset as a file. Thus, we provide a few methods as supplements:

$(METHODLIST)

"""
function save_nc! end


"""
This method is a case if one wants to save both variable and attributes into the target file. This method support saving multiple (N) dimension arrays:

    save_nc!(file::String,
             var_name::String,
             var_attr::Dict{String,String},
             var_data::Array{T,N},
             atts_name::Vector{String},
             atts_attr::Vector{Dict{String,String}},
             atts_data::Vector{Vector},
             notes::Dict{String,String};
             compress::Int = 4,
             growable::Bool = false
    ) where {T<:Union{AbstractFloat,Int,String},N}

Save dataset as NC file, given
- `file` Path to save the dataset
- `var_name` Variable name for the data in the NC file
- `var_attr` Variable attributes for the data, such as unit and long name
- `var_data` Data to save
- `atts_name` vector of supporting attribute labels, such as `lat` and `lon`
- `atts_attr` Vector of attributes for the supporting attributes, such as unit
- `atts_data` Vector of attributes data, such as the latitude range
- `notes` Global attributes (notes)
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

---
# Examples
```julia
# generate data to write into NC file
lats = collect(Float64, -85:10:85);
lons = collect(Float64, -175:10:175);
inds = collect(Int, 1:12);
data1 = rand(18) .+ 273.15;
data2 = rand(36,18) .+ 273.15;
data3 = rand(36,18,12) .+ 273.15;

# define the attributes of the dimensions and data
attrn = Dict("description" => "Random temperature", "unit" => "K");
latat = Dict("description" => "Latitude", "unit" => "°");
lonat = Dict("description" => "Longitude", "unit" => "°");
indat = Dict("description" => "Cycle index", "unit" => "-");

# define attributes names, information, and data
atts_name1 = ["lat"];
atts_name2 = ["lon", "lat"];
atts_name3 = ["lon", "lat", "ind"];
atts_attr1 = [latat];
atts_attr2 = [lonat, latat];
atts_attr3 = [lonat, latat, indat];
atts_data1 = Vector[lats];
atts_data2 = Vector[lons, lats];
atts_data3 = Vector[lons, lats, inds];
notes = Dict("description" => "This is a file generated using PkgUtility.jl", "notes" => "PkgUtility.jl uses NCDatasets.jl to create NC files");

# save data as NC files (1D, 2D, and 3D)
save_nc!("data1.nc", "data1", attrn, data1, atts_name1, atts_attr1, atts_data1, notes);
save_nc!("data2.nc", "data2", attrn, data2, atts_name2, atts_attr2, atts_data2, notes);
save_nc!("data3.nc", "data3", attrn, data3, atts_name3, atts_attr3, atts_data3, notes);
```
"""
save_nc!(file::String,
         var_name::String,
         var_attr::Dict{String,String},
         var_data::Array{T,N},
         atts_name::Vector{String},
         atts_attr::Vector{Dict{String,String}},
         atts_data::Vector{Vector},
         notes::Dict{String,String};
         compress::Int = 4,
         growable::Bool = false
) where {T<:Union{AbstractFloat,Int,String},N} = (
    # make sure the data provided match in dimensions and ranges
    @assert length(atts_attr) == length(atts_data) == length(atts_name) == N;
    @assert 0 <= compress <= 9;

    # create a dataset using "c" mode
    _dset = Dataset(file, "c");

    # global title attribute
    for (_title,_notes) in notes
        _dset.attrib[_title] = _notes;
    end;

    # dimensions for each attribute with their own sizes
    for _i in 1:N
        if growable && atts_name[_i] == "ind"
            defDim(_dset, atts_name[_i], Inf);
        else
            defDim(_dset, atts_name[_i], length(atts_data[_i]));
        end;
        _var = defVar(_dset, atts_name[_i], eltype(atts_data[_i]), atts_name[_i:_i]; attrib=atts_attr[_i], deflatelevel=compress);
        _var[:,:] = atts_data[_i];
    end;

    # define variable with attribute units and copy data into it
    _data = defVar(_dset, var_name, T, atts_name; attrib=var_attr, deflatelevel=compress);
    _data[:,:] = var_data;

    # close dataset file
    close(_dset);

    return nothing
);


"""
To save the code and effort to redefine the common attributes like latitude, longitude, and cycle index, we provide a shortcut method that handles these within the function:

    save_nc!(file::String,
             var_name::String,
             var_attr::Dict{String,String},
             var_data::Array{T,N};
             notes::Dict{String,String} = ATTR_ABOUT,
             compress::Int = 4,
             growable::Bool = false
    ) where {T<:Union{AbstractFloat,Int,String},N}

Save the 2D or 3D data as NC file, given
- `file` Path to save the dataset
- `var_name` Variable name for the data in the NC file
- `var_attr` Variable attributes for the data, such as unit and long name
- `var_data` Data to save
- `notes` Global attributes (notes)
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

---
# Examples
```julia
# generate data to write into NC file
data2 = rand(36,18) .+ 273.15;
data3 = rand(36,18,12) .+ 273.15;

# define the attributes and notes
attrn = Dict("description" => "Random temperature", "unit" => "K");
notes = Dict("description" => "This is a file generated using PkgUtility.jl", "notes" => "PkgUtility.jl uses NCDatasets.jl to create NC files");

# save data as NC files (2D and 3D)
save_nc!("data2.nc", "data2", attrn, data2);
save_nc!("data2.nc", "data2", attrn, data2; notes=notes);
save_nc!("data3.nc", "data3", attrn, data3);
save_nc!("data3.nc", "data3", attrn, data3; notes=notes);
```
"""
save_nc!(file::String,
         var_name::String,
         var_attr::Dict{String,String},
         var_data::Array{T,N};
         notes::Dict{String,String} = ATTR_ABOUT,
         compress::Int = 4,
         growable::Bool = false
) where {T<:Union{AbstractFloat,Int,String},N} = (
    @assert 1 <= N <= 3;
    @assert 0 <= compress <= 9;

    # generate lat and lon information based on the dimensions of the data

    # the case if the dimension is 1D
    if N==1
        _inds      = collect(Int, eachindex(var_data));
        _atts_name = ["ind"];
        _atts_attr = [ATTR_CYC];
        _atts_data = Vector[_inds];
        save_nc!(file, var_name, var_attr, var_data, _atts_name, _atts_attr, _atts_data, notes; compress=compress);

        return nothing;
    end;

    # the case if the dimension is 2D or 3D
    _N_lat   = size(var_data, 2);
    _N_lon   = size(var_data, 1);
    _res_lat = 180 / _N_lat;
    _res_lon = 360 / _N_lon;
    _lats    = collect(_res_lat/2:_res_lat:180) .- 90;
    _lons    = collect(_res_lon/2:_res_lon:360) .- 180;
    if N==2
        _atts_name = ["lon", "lat"];
        _atts_attr = [ATTR_LON, ATTR_LAT];
        _atts_data = Vector[_lons, _lats];
    else
        _inds      = collect(Int, 1:size(var_data,3));
        _atts_name = ["lon", "lat", "ind"];
        _atts_attr = [ATTR_LON, ATTR_LAT, ATTR_CYC];
        _atts_data = Vector[_lons, _lats, _inds];
    end;
    save_nc!(file, var_name, var_attr, var_data, _atts_name, _atts_attr, _atts_data, notes; compress=compress, growable = growable);

    return nothing
);


"""
This method saves DataFrame as a NetCDF file to save more space (compared to a CSV file).

    save_nc!(file::String, var_names::Vector{String}, var_attrs::Vector{Dict{String,String}}, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4, growable::Bool = false)

Save DataFrame to NetCDF, given
- `file` Path to save the data
- `var_names` The label of data in DataFrame to save
- `var_attrs` Variable attributes for the data to save
- `df` DataFrame to save
- `notes` Global attributes (notes)
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

---
# Examples
```julia
df = DataFrame();
df[!,"A"] = rand(5);
df[!,"B"] = rand(5);
df[!,"C"] = rand(5);
save_nc!("test.nc", ["A","B"], [Dict("A" => "Attribute A"), Dict("B" => "Attribute B")], df);
```
"""
save_nc!(file::String, var_names::Vector{String}, var_attrs::Vector{Dict{String,String}}, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4, growable::Bool = false) = (
    @assert 0 <= compress <= 9;

    # save the data to the NetCDF file
    save_nc!(file, var_names[1], var_attrs[1], df[:,var_names[1]]; notes = notes, compress = compress, growable = growable);
    for _i in 2:length(var_names)
        append_nc!(file, var_names[_i], var_attrs[_i], df[:,var_names[_i]], ["ind"], [ATTR_CYC], [collect(eachindex(df[:,var_names[_i]]))]; compress = compress);
    end;

    return nothing
);


"""
This method is a simplified version of the method above, namely when users do not want to define the attributes.

    save_nc!(file::String, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4, growable::Bool = false)

Save DataFrame to NetCDF, given
- `file` Path to save the data
- `df` DataFrame to save
- `notes` Global attributes (notes)
- `compress` Compression level fro NetCDF, default is 4
- `growable` If true, make index growable, default is false

---
# Examples
```julia
df = DataFrame();
df[!,"A"] = rand(5);
df[!,"B"] = rand(5);
df[!,"C"] = rand(5);
save_nc!("test.nc", df);
```
"""
save_nc!(file::String, df::DataFrame; notes::Dict{String,String} = ATTR_ABOUT, compress::Int = 4, growable::Bool = false) = (
    _var_names = names(df);
    _var_attrs = [Dict{String,String}(_vn => _vn) for _vn in _var_names];

    save_nc!(file, _var_names, _var_attrs, df; notes=notes, compress=compress, growable = growable);

    return nothing
);
