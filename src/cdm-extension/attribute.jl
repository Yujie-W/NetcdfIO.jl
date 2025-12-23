# extensions to CommonDataModel for Attributes
attrib(ds_var::Union{NCDataset,Variable}, att_name::UnionNameTypes) = nc_get_att(parent_ncid(ds_var), parent_varid(ds_var), att_name);

attribnames(ds_var::Union{NCDataset,Variable}) = (
    natts = nc_inq_varnatts(parent_ncid(ds_var), parent_varid(ds_var));
    names = Vector{String}(undef, natts);

    for attnum = 0:natts-1
        names[attnum+1] = nc_inq_attname(parent_ncid(ds_var), parent_varid(ds_var), attnum);
    end;

    return names
);


# extensions to Base functions for Attributes
get(attrs::Attributes, att_name::UnionNameTypes, default) = haskey(attrs, att_name) ? attrs[att_name] : default;

getindex(attrs::Attributes, att_name::UnionNameTypes) = nc_get_att(parent_ncid(attrs), parent_varid(attrs), att_name);

haskey(attrs::Attributes, att_name::UnionNameTypes) = String(att_name) in keys(attrs);

setindex!(attrs::Attributes, att_data, att_name::UnionNameTypes) = (
    # make sure that the file is in define mode
    def_mode!(parent_dataset(attrs));
    nc_put_att(parent_ncid(attrs), parent_varid(attrs), att_name, att_data);

    return nothing
);
