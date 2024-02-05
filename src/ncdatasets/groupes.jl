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

"""
    defGroup(ds::NCDataset,groupname, attrib = []))

Create the group with the name `groupname` in the dataset `ds`.
`attrib` is a list of attribute name and attribute value pairs (see `NCDataset`).
"""
function defGroup(ds::NCDataset,groupname::SymbolOrString; attrib = [])
    defmode(ds) # make sure that the file is in define mode
    grp_ncid = nc_def_grp(ds.ncid,groupname)
    ds = NCDataset(grp_ncid,ds.iswritable,ds.isdefmode; parentdataset = ds)

    # set global attributes for group
    for (attname,attval) in attrib
        ds.attrib[attname] = attval
    end

    return ds
end
export defGroup


groupnames(ds::AbstractNCDataset) = keys(ds.group)
group(ds::AbstractNCDataset,groupname::AbstractString) = ds.group[groupname]

"""
    name(ds::NCDataset)

Return the group name of the NCDataset `ds`
"""
name(ds::NCDataset) = nc_inq_grpname(ds.ncid)
groupname(ds::NCDataset) = name(ds)

export groupname