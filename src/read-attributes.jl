"""

"""
function read_attributes end

read_attributes(ds::Dataset, var_name::String) = (
    fvar = find_variable(ds, var_name);
    if isnothing(fvar)
        @error "$(var_name) does not exist!";
    end;

    return Dict{String, Any}(k => v for (k, v) in fvar.attrib)
);
