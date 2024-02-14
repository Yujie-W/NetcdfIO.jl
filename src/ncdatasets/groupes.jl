############################################################
# Groups
############################################################
"""
    Base.keys(g::Groups)

Return the names of all subgroubs of the group `g`.
"""
function Base.keys(g::Groups)
    return String[nc_inq_grpname(ncid)
                  for ncid in nc_inq_grps(g.ds.ncid)]
end


"""
    group = getindex(g::Groups,groupname::AbstractString)

Return the NetCDF `group` with the name `groupname`.
For example:

```julia-repl
julia> ds = NCDataset("results.nc", "r");
julia> forecast_group = ds.group["forecast"]
julia> forecast_temp = forecast_group["temperature"]
```

"""
function Base.getindex(g::Groups,groupname::SymbolOrString)
    grp_ncid = nc_inq_grp_ncid(g.ds.ncid,groupname)
    ds = NCDataset(grp_ncid,g.ds.iswritable,g.ds.isdefmode; parentdataset = g.ds)
    return ds
end
