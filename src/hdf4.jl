# overwrite the default open function in NCDatasets.jl
libnetcdf = "$(homedir())/.julia/conda/3/lib/libnetcdf.so.19";
function nc_open(path,mode::Integer)
    @debug "nc_open $path with mode $mode"
    ncidp = Ref(Cint(0))

    code = ccall((:nc_open,libnetcdf),Cint,(Cstring,Cint,Ptr{Cint}),path,mode,ncidp)

    if code == NC_NOERR
        return ncidp[]
    else
        # otherwise throw an error message
        # with a more helpful error message (i.e. with the path)
        @info "Error here";
        throw(NetCDFError(code, "Opening path $(path): $(nc_strerror(code))"))
    end
end
