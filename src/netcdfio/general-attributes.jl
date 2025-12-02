ATTR_ABOUT = OrderedDict{String,Any}(
    "about" => "This is a file generated using NetcdfIO.jl",
);


"""

    detect_attribute(varname::String, wavelength::Union{Int,Nothing} = nothing; showwarning::Bool = true)

Return an ordered dictionary of variable attributes, given
- `varname` Name of the variable
- `wavelength` Wavelength in nm for wavelength-dependent variables like SIF, default is `nothing`
- `showwarning` If true, show a warning when the variable name is not recognized, default is true

"""
function detect_attribute(varname::String, wavelength::Union{Int,Nothing} = nothing; showwarning::Bool = true)
    #
    #
    # with exact match
    #
    #
    # if the varname is latitude
    if varname in ["lat", "LAT", "latitude", "Latitude"]
        return OrderedDict{String,Any}(
            "about" => "Latitude from -90 to 90 degrees",
            "input_varname" => varname,
        )
    end;

    # if the varname is longitude
    if varname in ["lon", "LON", "longitude", "Longitude"]
        return OrderedDict{String,Any}(
            "about" => "Longitude from -180 to 180 degrees",
            "input_varname" => varname,
        )
    end;

    # if the varname is index
    if varname in ["cycle", "CYC", "ind", "IND", "index", "Index"]
        return OrderedDict{String,Any}(
            "about" => "Time index",
            "input_varname" => varname,
        )
    end;

    # if the varname is ET
    if varname == "ET"
        return OrderedDict{String,Any}(
            "about" => "Evapotranspiration",
            "unit" => "mol m⁻² s⁻¹",
            "input_varname" => varname,
        )
    end;

    # if the varname is GPP
    if varname == "GPP"
        return OrderedDict{String,Any}(
            "about" => "Gross Primary Production",
            "unit" => "μmol m⁻² s⁻¹",
            "input_varname" => varname,
        )
    end;

    # if the varname is SIF
    if varname == "SIF" && !isnothing(wavelength)
        return OrderedDict{String,Any}(
            "about" => "Solar-Induced chlorophyll Fluorescence at $wavelength nm",
            "unit" => "W m⁻² sr⁻¹ μm⁻¹",
            "input_varname" => varname,
        )
    end;

    #
    #
    # with partial match
    #
    #
    # read number digits from the varname
    if occursin("SIF", varname) && !isnothing(match(r"\d+", varname))
        wl = parse(Int, match(r"\d+", varname).match);

        return OrderedDict{String,Any}(
            "about" => "Solar-Induced chlorophyll Fluorescence at $wl nm",
            "unit" => "W m⁻² sr⁻¹ μm⁻¹",
            "input_varname" => varname,
        )
    end;

    #
    #
    # with no match
    #
    #
    # display that the name is not recognized
    if showwarning
        @warn "Attribute name '$varname' is not recognized, use default attribute (varname => varname) instead...";
    end;

    return OrderedDict{String,Any}(
        "input_varname" => varname
    )
end;
