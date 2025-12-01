

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

haskey(dset::NCDataset, name::Union{AbstractString,Symbol}) = name in keys(dset);

keys(dset::NCDataset) = String[nc_inq_varname(dset.ncid, varid) for varid in nc_inq_varids(dset.ncid)];
