# julia implementation of libnetcdf functions
""" Get netcdf error string from error code """
nc_strerror(ncerr::Integer) = unsafe_string(ccall((:nc_strerror, NetCDF_jll.libnetcdf), Cstring, (Cint,), ncerr));


# type definition and error handling
""" Struct for netcdf error """
Base.@kwdef mutable struct NetCDFError <: Exception
    "Error code from NetCDF library"
    code::Cint
    "Error message from NetCDF library"
    msg::String = nc_strerror(code)
end;

showerror(io::IO, err::NetCDFError) = (
    println(io, "NetCDF error code: $(err.code)");
    println(io, "NetCDF error message:");
    printstyled(io, err.msg, color=:red);
    println(io, "");
);


""" Check the status code from a libnetcdf function call """
function check_status!(code::Cint)
    return code == Cint(0) ? nothing : throw(NetCDFError(code))
end;
