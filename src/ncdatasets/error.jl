#######################################################################################################################################################################################################
#
# Changes to the struct
# General:
#     2024-Feb-14: move error handling struct to error.jl
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Struct for netcdf error

$(TYPEDFIELDS)

"""
mutable struct NetCDFError <: Exception
    "Error code from NetCDF library"
    code::Cint
    "Error message from NetCDF library"
    msg::String
end;

NetCDFError(code::Cint) = NetCDFError(code, nc_strerror(code));

showerror(io::IO, err::NetCDFError) = (
    println(io, "NetCDF error code: $(err.code)");
    println(io, "NetCDF error message:");
    printstyled(io, err.msg, color=:red);
    println(io, "");
);


#######################################################################################################################################################################################################
#
# Changes to the function
# General:
#     2024-Feb-14: rename the function to check_status!
#
#######################################################################################################################################################################################################
"""

    check_status!(code::Cint)

Check the NetCDF status code, raising an error if nonzero, given
- `code` NetCDF status code

"""
function check_status!(code::Cint)
    # if code is not 0, throw an error
    if code != Cint(0)
        throw(NetCDFError(code))
    end;

    return nothing
end;
