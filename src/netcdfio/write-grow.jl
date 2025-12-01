"""

    grow_nc!(ds::Dataset, var_name::String, in_data::Union{AbstractFloat,Array,Integer,String}, pending::Bool)
    grow_nc!(file::String, var_name::String, in_data::Union{AbstractFloat,Array,Integer,String}, pending::Bool)

Grow the netcdf dataset, given
- `ds` A `NCDatasets.Dataset` type dataset
- `var_name` New variable name to write to
- `in_data` New data to grow, can be integer, float, and string with N dimens
- `pending` If true, the new data is appened to the end (growth); if false, the data will replace the ones from the bottom (when dimension has already growed)
- `file` Path of the netcdf dataset

Note that if there are more variables to grow at the same time, set `pending` to `true` only for the first time you call this function, and set `pending` to `false` for the rest variables.

"""
function grow_nc! end

grow_nc!(ds::Dataset, var_name::String, in_data::Union{AbstractFloat,Array,Integer,String}, pending::Bool) = (
    # make sure the data to grow has -1 or the same dimensions as the target, e.g., a 3D dataset can grow with 2D or 3D input
    dim_ds = length(size(ds[var_name]));
    dim_in = length(size(in_data));
    @assert dim_in in [dim_ds, dim_ds - 1] "Data to grow must have same or -1 dimensions compared to data in the netcdf file!";
    @assert dim_ds <= 3 "This function only supports 1D to 3D datasets!";

    # calculate how many layers to add
    n = (dim_in < dim_ds) ? 1 : (typeof(in_data) <: Array ? size(in_data)[end] : 1);

    # if the data need to pend to the end (grow in unlimited dimension)
    if pending
        if dim_ds == 1
            ds[var_name][end+1:end+n] = in_data;
        elseif dim_ds == 2
            ds[var_name][:,end+1:end+n] = in_data;
        elseif dim_ds == 3
            ds[var_name][:,:,end+1:end+n] = in_data;
        end;
    end;

    # if the unlimited dimension has grown already
    if dim_ds == 1
        ds[var_name][end+1-n:end] = in_data;
    elseif dim_ds == 2
        ds[var_name][:,end+1-n:end] = in_data;
    elseif dim_ds == 3
        ds[var_name][:,:,end+1-n:end] = in_data;
    end;

    return nothing
);

grow_nc!(file::String, var_name::String, in_data::Union{AbstractFloat,Array,Integer,String}, pending::Bool) = (
    dset = Dataset(file, "a");
    grow_nc!(dset, var_name, in_data, pending);
    close(dset);

    return nothing
);

grow_nc!(ds::Dataset, df::DataFrame) = (
    dim_ind = size_nc(ds, "ind");
    grow_nc!(ds, "ind", collect(axes(df,1) .+ dim_ind[2][1]), true);

    for var in names(df)
        grow_nc!(ds, var, df[:,var], false);
    end;

    return nothing
);

grow_nc!(file::String, in_data::DataFrame) = (
    dset = Dataset(file, "a");
    grow_nc!(dset, in_data);
    close(dset);

    return nothing
);
