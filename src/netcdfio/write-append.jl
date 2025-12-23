"""

    append_nc!(ds::Dataset,
               var_name::UnionNameTypes,
               var_data::Array{T,N},
               var_attributes::UnionAttrTypes,
               dim_names::Vector{String};
               deflatelevel::Union{Int,Nothing} = 4) where {T<:Union{AbstractFloat,Integer,String},N}
    append_nc!(file::String,
               var_name::UnionNameTypes,
               var_data::Array{T,N},
               var_attributes::UnionAttrTypes,
               dim_names::Vector{String};
               args...) where {T<:Union{AbstractFloat,Integer,String},N}

Append data to existing netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `var_name` New variable name to write to
- `var_data` New variable data to write, can be integer, float, and string with N dimens
- `var_attributes` New variable attributes
- `dim_names` Dimension names in the netcdf file
- `deflatelevel` Compression level fro NetCDF, default is 4
- `file` Path of the netcdf dataset

"""
function append_nc! end

append_nc!(ds::Dataset,
           var_name::UnionNameTypes,
           var_data::Array{T,N},
           var_attributes::UnionAttrTypes,
           dim_names::Vector{String};
           deflatelevel::Union{Int,Nothing} = 4) where {T<:Union{AbstractFloat,Integer,String},N} = (
    # only if variable does not exist create the variable
    @assert !(var_name in keys(ds)) "You can only add new variable to the dataset!";
    @assert length(dim_names) ==  N "Dimension must match!";
    @assert isnothing(deflatelevel) || (0 <= deflatelevel <= 9) "Compression rate must be within 0 to 9";

    # if type of variable is string, set deflatelevel to 0
    if T == String
        deflatelevel = nothing;
    end;

    ds_var = defVar(ds, var_name, T, var_attributes, dim_names; deflatelevel = deflatelevel);
    ds_var[axes(var_data)...] = var_data;

    return nothing
);

append_nc!(file::String,
           var_name::UnionNameTypes,
           var_data::Array{T,N},
           var_attributes::UnionAttrTypes,
           dim_names::Vector{String};
           args...) where {T<:Union{AbstractFloat,Integer,String},N} = (
    ds = Dataset(file, "a");
    append_nc!(ds, var_name, var_data, var_attributes, dim_names; args...);
    close(ds);

    return nothing
);
