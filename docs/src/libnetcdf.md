# libnetcdf functions
```@meta
CurrentModule = NetcdfIO
```

# Dataset IO
```@docs
nc_open
nc_close
nc_create
nc_redef
nc_enddef
nc_inq_path
```

# Attribute related
```@docs
nc_get_att
nc_inq_att
nc_inq_attname
nc_put_att
nc_put_att_string
```

# Dimension related
```@docs
nc_def_dim
nc_inq_dimid
nc_inq_dimids
nc_inq_dimlen
nc_inq_dimname
nc_inq_ndims
nc_inq_unlimdims
```

# Group related
```@docs
nc_inq_grp_ncid
nc_inq_grpname
nc_inq_grps
```

# Variable related
```@docs
VariableLength
nc_def_vlen
nc_free_vlen
nc_def_var
nc_def_var_deflate
nc_get_var!
nc_get_var1
nc_get_vara!
nc_get_vars!
nc_put_var
nc_put_var1
nc_put_vara
nc_put_vars
nc_inq_user_type
nc_inq_varnatts
nc_inq_vardimid
nc_inq_varndims
nc_inq_varid
nc_inq_varids
nc_inq_varname
nc_inq_vartype
```

# Error handling
```@docs
NetCDFError
nc_strerror
check_status!
```
