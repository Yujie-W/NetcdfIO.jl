"""

    defVar(ds::NCDataset,
           var_name::UnionNameTypes,
           var_type::DataType,
           var_attrib::UnionAttrTypes,
           dim_names::Vector{String};
           deflatelevel::Union{Int,Nothing} = nothing)

Create a new variable in the dataset, given
- `ds` A netcdf dataset
- `name` Name of the variable
- `vtype` Type of the variable, for example `Float64`, `Int32`, `String`, etc.
- `attrib` Variable attributes
- `dimnames` Dimension names in the netcdf file
- `deflatelevel` Compression level fro NetCDF, default is `nothing`

"""
defVar(ds::NCDataset,
       var_name::UnionNameTypes,
       var_type::DataType,
       var_attrib::UnionAttrTypes,
       dim_names::Vector{String};
       deflatelevel::Union{Int,Nothing} = nothing) = (
    # make sure that the file is in define mode
    def_mode!(ds);

    dimids = Cint[nc_inq_dimid(ds.ncid, dim_name) for dim_name in dim_names[end:-1:1]];
    typeid = (var_type <: Vector) ? nc_def_vlen(ds.ncid, nothing, NC_TYPES[eltype(var_type)]) : NC_TYPES[var_type];
    varid = nc_def_var(ds.ncid, var_name, typeid, dimids);

    if !isnothing(deflatelevel)
        nc_def_var_deflate(ds.ncid, varid, false, true, deflatelevel);
    end;

    # note: element type of ds[name] potentially changed, so do not directly return v here
    var = ds[var_name];
    for (attname,attval) in var_attrib
        var.attrib[attname] = attval;
    end;

    return ds[var_name]
);
