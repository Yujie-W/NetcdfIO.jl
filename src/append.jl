#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2021-Dec-24: move the function from PkgUtility to NetcdfIO
#     2022-Jan-28: fix documentation
#
#######################################################################################################################################################################################################
"""
NCDatasets.jl does not have a convenient function (1 line command) to append or grow dataset into a file. Thus, we provide a few methods as supplements:

$(METHODLIST)

"""
function append_nc! end


#######################################################################################################################################################################################################
#
# Changes to the method
# General:
#     2022-Jan-28: add this method to add data to Dataset
#     2022-Jan-28: add documentation
#
#######################################################################################################################################################################################################
"""

    append_nc!(ds::Dataset, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N}

Append data to existing netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `var_name` New variable name to write to
- `var_data` New variable data to write, can be integer, float, and string with N dimens
- `var_attributes` New variable attributes
- `dim_names` Dimension names in the netcdf file
- `compress` Compression level fro NetCDF, default is 4

---
# Examples
```julia
create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, 5]);
dset = Dataset("test.nc", "a");
append_nc!(dset, "str", ["A" for i in 1:18], Dict("longname" => "test strings"), ["lat"]);
append_nc!(dset, "lat", collect(1:18), Dict("longname" => "latitude"), ["lat"]);
append_nc!(dset, "lon", collect(1:36), Dict("longname" => "longitude"), ["lon"]; compress=4);
append_nc!(dset, "ind", collect(1:5), Dict("longname" => "index"), ["ind"]);
append_nc!(dset, "d2d", rand(36,18), Dict("longname" => "a 2d dataset"), ["lon", "lat"]);
append_nc!(dset, "d3d", rand(36,18,5), Dict("longname" => "a 3d dataset"), ["lon", "lat", "ind"]);
close(dset);
```
"""
append_nc!(ds::Dataset, var_name::String, var_data::Array{T,N}, var_attributes::Dict{String,String}, dim_names::Vector{String}; compress::Int = 4) where {T<:Union{AbstractFloat,Int,String},N} = (
    # only if variable does not exist create the variable
    @assert !(var_name in keys(ds)) "You can only add new variable to the dataset!";
    @assert length(dim_names) ==  N "Dimension must be match!";

    _ds_var = defVar(ds, var_name, T, dim_names; attrib = var_attributes, deflatelevel = compress);
    _ds_var[:,:] = var_data;

    return nothing
);






"""
This method append data to an exisiting NC file. If the attributes exist already, then only save the data:

    append_nc!(file::String,
               var_name::String,
               var_attr::Dict{String,String},
               var_data::Array{FT,N},
               atts_name::Vector{String},
               atts_attr::Vector{Dict{String,String}},
               atts_data::Vector;
               compress::Int = 4
    ) where {FT<:AbstractFloat,N}

Append data to existing file, given
- `file` Path to save the dataset
- `var_name` Variable name for the data in the NC file
- `var_attr` Variable attributes for the data, such as unit and long name
- `var_data` Data to save
- `atts_name` vector of supporting attribute labels, such as `lat` and `lon`
- `atts_attr` Vector of attributes for the supporting attributes, such as unit
- `atts_data` Vector of attributes data, such as the latitude range
- `compress` Compression level fro NetCDF, default is 4

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
atts_data1 = Any[lats];
atts_data2 = Any[lons, lats];
atts_data3 = Any[lons, lats, inds];
notes = Dict("description" => "This is a file generated using PkgUtility.jl", "notes" => "PkgUtility.jl uses NCDatasets.jl to create NC files");

# save data as NC files (1D, 2D, and 3D)
append_nc!("data1.nc", "datax", attrn, data1, atts_name1, atts_attr1, atts_data1);
append_nc!("data2.nc", "datax", attrn, data2, atts_name2, atts_attr2, atts_data2);
append_nc!("data3.nc", "datax", attrn, data3, atts_name3, atts_attr3, atts_data3);
```
"""
append_nc!(file::String,
           var_name::String,
           var_attr::Dict{String,String},
           var_data::Array{FT,N},
           atts_name::Vector{String},
           atts_attr::Vector{Dict{String,String}},
           atts_data::Vector;
           compress::Int = 4
) where {FT<:AbstractFloat,N} = (
    # make sure the data provided match in dimensions and ranges
    @assert length(atts_attr) == length(atts_data) == length(atts_name) == N;
    @assert 0 <= compress <= 9;

    # read a dataset using "a" mode
    _dset = Dataset(file, "a");

    # dimensions for each attribute with their own sizes if not exisiting
    for _i in 1:N
        if !(atts_name[_i] in keys(_dset.dim))
            defDim(_dset, atts_name[_i], length(atts_data[_i]));
            _var = defVar(_dset, atts_name[_i], eltype(atts_data[_i]), atts_name[_i:_i]; attrib=atts_attr[_i], deflatelevel=compress);
            _var[:,:] = atts_data[_i];
        end;
    end;

    # define variable with attribute units and copy data into it
    _data = defVar(_dset, var_name, FT, atts_name; attrib=var_attr, deflatelevel=compress);
    _data[:,:] = var_data;

    # close dataset file
    close(_dset);

    return nothing
);
