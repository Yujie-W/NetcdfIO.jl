# extensions to Base functions for Variables
size(var::Variable{T,N}) where {T,N} = ntuple(i -> nc_inq_dimlen(parent_ncid(var), var.dimids[i]), Val(N));


# extensions to CommonDataModel for Variables
variable(ds::NCDataset, varid::Integer) = (
    dimids = nc_inq_vardimid(ds.ncid, varid);
    T = _jltype(ds.ncid, nc_inq_vartype(ds.ncid, varid));
    N = length(dimids);
    TDS = typeof(ds);

    # reverse dimids to have the dimension order in Fortran style
    return Variable{T,N,TDS}(ds, varid, (reverse(dimids)...,))
);

variable(ds::NCDataset, var_name::UnionNameTypes) = variable(ds, nc_inq_varid(ds.ncid, var_name));


# Function to map NetCDF types to Julia types
function _jltype(ncid::Integer, xtype::Integer)
    return if xtype >= NC_FIRSTUSERTYPEID
        _,_,base_nc_type,_,class = nc_inq_user_type(ncid, xtype);
        # assume here variable-length type
        if class == NC_VLEN
            Vector{JL_TYPES[base_nc_type]}
        else
            @warn "unsupported type: class=$(class)";
            Nothing
        end
    else
        JL_TYPES[xtype]
    end;
end;
