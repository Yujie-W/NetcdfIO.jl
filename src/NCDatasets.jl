import NetCDF_jll
import NCDatasets: nc_inq_varids, nc_open

using NCDatasets: NC_NOERR, NetCDFError, check, nc_strerror

const LIBNETCDF = deepcopy(NetCDF_jll.libnetcdf);


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2023-Jul-19: add function switch_netcdf_lib! to add support to read HDF4 files
#
#######################################################################################################################################################################################################
"""

    switch_netcdf_lib!(; use_default::Bool = true, user_defined::String = "$(homedir())/.julia/conda/3/lib/libnetcdf.so")

Switch between the default NetCDF library and a user-defined one, given
- `use_default` Whether to use the default libnetcdf library shipped with NCDatasets.jl
- `user_defined` The path to the user-defined libnetcdf library (used only when `use_default` is false)

"""
function switch_netcdf_lib!(; use_default::Bool = true, user_defined::String = "$(homedir())/.julia/conda/3/lib/libnetcdf.so")
    if use_default
        NetCDF_jll.libnetcdf = LIBNETCDF;
        NetCDF_jll.libnetcdf_path = LIBNETCDF;
        Base.Libc.Libdl.dlclose(NetCDF_jll.libnetcdf_handle);
        NetCDF_jll.libnetcdf_handle = Base.Libc.Libdl.dlopen(LIBNETCDF);
    else
        if isfile(user_defined)
            NetCDF_jll.libnetcdf = user_defined;
            NetCDF_jll.libnetcdf_path = user_defined;
            Base.Libc.Libdl.dlclose(NetCDF_jll.libnetcdf_handle);
            NetCDF_jll.libnetcdf_handle = Base.Libc.Libdl.dlopen(user_defined);
        else
            @warn "File '$(user_defined)' not found!";
            @info "Hint: You may libnetcdf shipped with Conda.jl using Conda.add(\"libnetcdf\"). A version above 4.8.1 is recommended.";
            @warn "The file '$(user_defined)' does not exist, please make sure you have provided the correct path!";
        end;
    end;

    return nothing
end


#######################################################################################################################################################################################################
#
# Changes to the function
# General
#     2023-Jul-19: use sym to refer to the handle so as to dynamically switch between libnetcdf libraries
#
#######################################################################################################################################################################################################
function nc_open(path,mode::Integer)
    @debug "nc_open $path with mode $mode";
    ncidp = Ref(Cint(0));

    _sym = Base.Libc.Libdl.dlsym(NetCDF_jll.libnetcdf_handle, :nc_open);
    code = ccall(_sym,Cint,(Cstring,Cint,Ptr{Cint}),path,mode,ncidp);

    if code == NC_NOERR
        return ncidp[]
    else
        # otherwise throw an error message
        # with a more helpful error message (i.e. with the path)
        throw(NetCDFError(code, "Opening path $(path): $(nc_strerror(code))"))
    end
end

function nc_inq_varids(ncid::Integer)::Vector{Cint}
    _sym = Base.Libc.Libdl.dlsym(NetCDF_jll.libnetcdf_handle, :nc_inq_varids);

    # first get number of variables
    nvarsp = Ref(Cint(0));
    check(ccall(_sym,Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nvarsp,C_NULL));
    nvars = nvarsp[];

    varids = zeros(Cint,nvars);
    check(ccall(_sym,Cint,(Cint,Ptr{Cint},Ptr{Cint}),ncid,nvarsp,varids));

    return varids
end
