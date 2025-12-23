# extensions to Base functions for NCDataset
close(ds::NCDataset) = (
    try
        nc_close(ds.ncid);
    catch err
        # like Base, allow close on closed file
        if err isa NetCDFError
            if err.code == NC_EBADID
                return nothing
            end;
        end;
        rethrow();
    end;

    # prevent finalize to close file as ncid can reused for future files
    ds.ncid = -1;

    return nothing
);

haskey(ds::NCDataset, name::UnionNameTypes) = String(name) in keys(ds);

keys(ds::NCDataset) = String[nc_inq_varname(ds.ncid, varid) for varid in nc_inq_varids(ds.ncid)];
