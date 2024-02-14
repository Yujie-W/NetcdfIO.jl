# `Attributes` is a collection of named attributes


"Return all attribute names"
function listAtt(ncid,varid)
    natts = nc_inq_varnatts(ncid,varid)
    names = Vector{String}(undef,natts)

    for attnum = 0:natts-1
        names[attnum+1] = nc_inq_attname(ncid,varid,attnum)
    end

    return names
end


function get(a::BaseAttributes, name::Union{Symbol, AbstractString},default)
    if haskey(a,name)
        return a[name]
    else
        return default
    end
end


"""
    getindex(a::Attributes,name::Union{Symbol, AbstractString})

Return the value of the attribute called `name` from the
attribute list `a`. Generally the attributes are loaded by
indexing, for example:

```julia
ds = NCDataset("file.nc")
title = ds.attrib["title"]
```
"""
function getindex(a::Attributes,name::Union{Symbol, AbstractString})
    return nc_get_att(a.ds.ncid,a.varid,name)
end


"""
    setindex!(a::Attributes,data,name::Union{Symbol, AbstractString})

Set the attribute called `name` to the value `data` in the
attribute list `a`. `data` can be a vector or a scalar. A scalar
is handeld as a vector with one element in the NetCDF data model.

Generally the attributes are defined by indexing, for example:

```julia
ds = NCDataset("file.nc","c")
ds.attrib["title"] = "my title"
close(ds)
```

If `data` is a string, then attribute is saved as a list of
NetCDF characters (`NC_CHAR`) with the appropriate length. To save the attribute
as a string (`NC_STRING`) you can use the following:

```julia
ds = NCDataset("file.nc","c")
ds.attrib["title"] = ["my title"]
close(ds)
```


"""
function setindex!(a::Attributes,data,name::Union{Symbol, AbstractString})
    defmode(a.ds) # make sure that the file is in define mode
    return nc_put_att(a.ds.ncid,a.varid,name,data)
end

"""
    keys(a::Attributes)

Return a list of the names of all attributes.
"""
keys(a::Attributes) = listAtt(a.ds.ncid,a.varid)
