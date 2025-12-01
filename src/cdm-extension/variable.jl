# extensions to Base functions for Variables
size(var::Variable{T,N}) where {T,N} = ntuple(i -> nc_inq_dimlen(parent_ncid(var), var.dimids[i]), Val(N));


# extensions to CommonDataModel for Variables
variable(dset::NCDataset, varid::Integer) = (
    dimids = nc_inq_vardimid(dset.ncid, varid);
    T = _jltype(dset.ncid, nc_inq_vartype(dset.ncid, varid));
    N = length(dimids);
    TDS = typeof(dset);

    # reverse dimids to have the dimension order in Fortran style
    return Variable{T,N,TDS}(dset, varid, (reverse(dimids)...,))
);

variable(dset::NCDataset, varname::AbstractString) = variable(dset, nc_inq_varid(dset.ncid, varname));


""" Function to map NetCDF types to Julia types """
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
