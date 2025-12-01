""" Set data mode for NCDataset """
data_mode!(dset::NCDataset) = (
    if dset.isdefmode[]
        nc_enddef(dset.ncid);
        dset.isdefmode[] = false
    end;

    return nothing
);


""" Set define mode for NCDataset """
def_mode!(dset::NCDataset) = (
    if !dset.isdefmode[]
        nc_redef(dset.ncid);
        dset.isdefmode[] = true;
    end;

    return nothing
);
