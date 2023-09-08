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
