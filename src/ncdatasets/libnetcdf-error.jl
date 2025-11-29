""" Get netcdf error string from error code """
nc_strerror(ncerr::Integer) = unsafe_string(ccall((:nc_strerror,libnetcdf), Cstring, (Cint,), ncerr));


""" Struct for netcdf error """
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


""" Check the status code from a libnetcdf function call """
check_status!(code::Cint) = code == Cint(0) ? nothing : throw(NetCDFError(code));
