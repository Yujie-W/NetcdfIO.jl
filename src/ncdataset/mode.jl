""" Set data mode for NCDataset """
data_mode!(ds::NCDataset) = (
    if ds.isdefmode[]
        nc_enddef(ds.ncid);
        ds.isdefmode[] = false
    end;

    return nothing
);


""" Set define mode for NCDataset """
def_mode!(ds::NCDataset) = (
    if ds.isdefmode[]
        nc_redef(ds.ncid);
        ds.isdefmode[] = true;
    end;

    return nothing
);
