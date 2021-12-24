"""
NCDatasets.jl does not have a convenient function (1 line command) to append dataset into a file. Thus, we provide a few methods as supplements:

$(METHODLIST)

"""
function append_nc! end


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
Examples
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
        if !(atts_name[_i] in listVar(_dset.ncid))
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
