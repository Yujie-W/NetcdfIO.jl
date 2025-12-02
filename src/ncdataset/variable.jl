"""

    defVar(dset::NCDataset,
           name::Union{AbstractString,Symbol},
           vtype::DataType,
           dimnames::Vector{String};
           deflatelevel::Union{Int,Nothing} = nothing,
           attrib::Union{Dict{String,Any}, OrderedDict{String,Any}} = Dict{String,Any}())

Create a new variable in the dataset, given
- `dset` A netcdf dataset
- `name` Name of the variable
- `vtype` Type of the variable, for example `Float64`, `Int32`, `String`, etc.
- `dimnames` Dimension names in the netcdf file
- `deflatelevel` Compression level fro NetCDF, default is `nothing`
- `attrib` Variable attributes, default is an empty dictionary

"""
defVar(dset::NCDataset,
       name::Union{AbstractString,Symbol},
       vtype::DataType,
       dimnames::Vector{String};
       deflatelevel::Union{Int,Nothing} = nothing,
       attrib::Union{Dict{String,Any}, OrderedDict{String,Any}} = Dict{String,Any}()) = (
    # make sure that the file is in define mode
    def_mode!(dset);

    dimids = Cint[nc_inq_dimid(dset.ncid, dimname) for dimname in dimnames[end:-1:1]];
    typeid = (vtype <: Vector) ? nc_def_vlen(dset.ncid, nothing, NC_TYPES[eltype(vtype)]) : NC_TYPES[vtype];
    varid = nc_def_var(dset.ncid, name, typeid, dimids);

    if !isnothing(deflatelevel)
        nc_def_var_deflate(dset.ncid, varid, false, true, deflatelevel);
    end;

    # note: element type of ds[name] potentially changed, so do not directly return v here
    v = dset[name];
    for (attname,attval) in attrib
        v.attrib[attname] = attval;
    end;

    return dset[name]
);
