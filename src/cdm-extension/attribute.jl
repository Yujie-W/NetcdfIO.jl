# extensions to CommonDataModel for Attributes
attrib(ds::Union{NCDataset,Variable}, name::UnionNameTypes) = nc_get_att(parent_ncid(ds), parent_varid(ds), name);

attribnames(ds::Union{NCDataset,Variable}) = (
    natts = nc_inq_varnatts(parent_ncid(ds), parent_varid(ds));
    names = Vector{String}(undef, natts);

    for attnum = 0:natts-1
        names[attnum+1] = nc_inq_attname(parent_ncid(ds), parent_varid(ds), attnum);
    end;

    return names
);


# extensions to Base functions for Attributes
get(attrs::Attributes, name::UnionNameTypes, default) = haskey(attrs, name) ? attrs[name] : default;

getindex(attrs::Attributes, name::UnionNameTypes) = nc_get_att(parent_ncid(attrs), parent_varid(attrs), name);

haskey(attrs::Attributes, name::UnionNameTypes) = name in keys(attrs);

setindex!(attrs::Attributes, data, name::UnionNameTypes) = (
    # make sure that the file is in define mode
    def_mode!(parent_dataset(attrs));
    nc_put_att(parent_ncid(attrs), parent_varid(attrs), name, data);

    return nothing
);
