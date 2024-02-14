# `Dimensions` is a collection of named dimensions
# each dimension has a name and a size (possibly unlimited)

"""
    keys(d::Dimensions)

Return a list of all dimension names in NCDataset `ds`.

# Examples

```julia-repl
julia> ds = NCDataset("results.nc", "r");
julia> dimnames = keys(ds.dim)
```
"""
function keys(d::Dimensions)
    return String[nc_inq_dimname(d.ds.ncid,dimid)
                  for dimid in nc_inq_dimids(d.ds.ncid,false)]
end


"""
    setindex!(d::Dimensions,len,name::AbstractString)

Defines the dimension called `name` to the length `len`.
Generally dimension are defined by indexing, for example:

```julia
ds = NCDataset("file.nc","c")
ds.dim["longitude"] = 100
```

If `len` is the special value `Inf`, then the dimension is considered as
`unlimited`, i.e. it will grow as data is added to the NetCDF file.
"""
function setindex!(d::Dimensions,len,name::AbstractString)
    defmode(d.ds) # make sure that the file is in define mode
    dimid = nc_def_dim(d.ds.ncid,name,(isinf(len) ? NC_UNLIMITED : len))
    return len
end
