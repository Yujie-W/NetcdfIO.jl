"""

    defVar(dset::NCDataset,
           name::UnionNameTypes,
           vtype::DataType,
           attrib::Union{Dict{String,Any},OrderedDict{String,Any}},
           dimnames::Vector{String};
           deflatelevel::Union{Int,Nothing} = nothing)

Create a new variable in the dataset, given
- `dset` A netcdf dataset
- `name` Name of the variable
- `vtype` Type of the variable, for example `Float64`, `Int32`, `String`, etc.
- `attrib` Variable attributes
- `dimnames` Dimension names in the netcdf file
- `deflatelevel` Compression level fro NetCDF, default is `nothing`

"""
defVar(dset::NCDataset,
       name::UnionNameTypes,
       vtype::DataType,
       attrib::UnionAttrTypes,
       dimnames::Vector{String};
       deflatelevel::Union{Int,Nothing} = nothing) = (
    # make sure that the file is in define mode
    def_mode!(dset);

    dimids = Cint[nc_inq_dimid(dset.ncid, dimname) for dimname in dimnames[end:-1:1]];
    typeid = (vtype <: Vector) ? nc_def_vlen(dset.ncid, nothing, NC_TYPES[eltype(vtype)]) : NC_TYPES[vtype];
    varid = nc_def_var(dset.ncid, name, typeid, dimids);

    if !isnothing(deflatelevel)
        nc_def_var_deflate(dset.ncid, varid, false, true, deflatelevel);
    end;

    # note: element type of ds[name] potentially changed, so do not directly return v here
    v = dset[String(name)];
    for (attname,attval) in attrib
        v.attrib[attname] = attval;
    end;

    return dset[String(name)]
);
