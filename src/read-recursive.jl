"""

    find_variable(ds::Dataset, var_name::String)

Return the path to dataset if it exists, given
- `ds` NCDatasets.Dataset type dataset
- `var_name` Variable to read

"""
function find_variable(ds::Dataset, var_name::String)
    # if var_name is in the current dataset, return it
    if var_name in keys(ds)
        return ds[var_name]
    end;

    # loop through the groups and find the data
    dvar = nothing;
    for group in keys(ds.group)
        dvar = find_variable(ds.group[group], var_name)
        if !isnothing(dvar)
            break;
        end;
    end;

    # return the variable if it exists, otherwise return nothing
    return dvar
end;
