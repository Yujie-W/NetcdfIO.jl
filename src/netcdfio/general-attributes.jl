ATTR_ABOUT = OrderedDict{String,Any}(
    "about" => "This is a file generated using NetcdfIO.jl",
);


"""

    detect_attribute(var_name::String, wavelength::Union{Int,Nothing} = nothing; showwarning::Bool = true)

Return an ordered dictionary of variable attributes, given
- `var_name` Name of the variable
- `wavelength` Wavelength in nm for wavelength-dependent variables like SIF, default is `nothing`
- `showwarning` If true, show a warning when the variable name is not recognized, default is true

"""
function detect_attribute end;

detect_attribute(var_name::String, wavelength::Union{Int,Nothing} = nothing; showwarning::Bool = true) = (
    #
    #
    # with exact match for dimension-related names
    #
    #
    # if the var_name is latitude
    if var_name in ["lat", "LAT", "latitude", "Latitude"]
        return OrderedDict{String,Any}(
            "about" => "Latitude from -90 to 90 degrees",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is longitude
    if var_name in ["lon", "LON", "longitude", "Longitude"]
        return OrderedDict{String,Any}(
            "about" => "Longitude from -180 to 180 degrees",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is index
    if var_name in ["cycle", "CYC", "ind", "IND", "index", "Index"]
        return OrderedDict{String,Any}(
            "about" => "Time index",
            "input_varname" => var_name,
        )
    end;

    #
    #
    # with exact match for general variables
    #
    #
    # if the var_name is APAR
    if var_name == "APAR"
        return OrderedDict{String,Any}(
            "about" => "Photosynthetically Active Radiation photons absorbed by vegetation",
            "unit" => "μmol m⁻² s⁻¹",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is Ci, PCi, or PCI
    if var_name in ["Ci", "PCi", "PCI"]
        return OrderedDict{String,Any}(
            "about" => "Intercellular CO₂ partial pressure",
            "unit" => "Pa",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ET
    if var_name == "ET"
        return OrderedDict{String,Any}(
            "about" => "Evapotranspiration",
            "unit" => "mol m⁻² s⁻¹",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is GPP
    if var_name == "GPP"
        return OrderedDict{String,Any}(
            "about" => "Gross Primary Production",
            "unit" => "μmol m⁻² s⁻¹",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is PAR
    if uppercase(var_name) in ["PAR", "PPFD"]
        return OrderedDict{String,Any}(
            "about" => "Photosynthetically Active Radiation photons",
            "unit" => "μmol m⁻² s⁻¹",
            "input_varname" => var_name,
        )
    end;

    # if the name is PPAR
    if var_name == "PPAR"
        return OrderedDict{String,Any}(
            "about" => "Photosynthetically Active Radiation photons that goes into the Photosystems",
            "unit" => "μmol m⁻² s⁻¹",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is SIF
    if var_name == "SIF" && !isnothing(wavelength)
        return OrderedDict{String,Any}(
            "about" => "Solar-Induced chlorophyll Fluorescence at $wavelength nm",
            "unit" => "W m⁻² sr⁻¹ μm⁻¹",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ΦD
    if var_name == "ΦD"
        return OrderedDict{String,Any}(
            "about" => "Heat dissipation Quantum Yield",
            "unit" => "-",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ΦF
    if var_name == "ΦF"
        return OrderedDict{String,Any}(
            "about" => "Fluorescence Quantum Yield",
            "unit" => "-",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ΦN
    if var_name == "ΦN"
        return OrderedDict{String,Any}(
            "about" => "Non-photochemical Quantum Yield",
            "unit" => "-",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ΦP
    if var_name == "ΦP"
        return OrderedDict{String,Any}(
            "about" => "Photochemical Quantum Yield",
            "unit" => "-",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ΣSIF
    if var_name == "ΣSIF"
        return OrderedDict{String,Any}(
            "about" => "Total Solar-Induced chlorophyll Fluorescence over all measured wavelengths that escape from the canopy",
            "unit" => "W m⁻²",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ΣSIF_CHL
    if var_name == "ΣSIF_CHL"
        return OrderedDict{String,Any}(
            "about" => "Total Solar-Induced chlorophyll Fluorescence over all measured wavelengths emitted by the chlorophyll",
            "unit" => "W m⁻²",
            "input_varname" => var_name,
        )
    end;

    # if the var_name is ΣSIF_LEAF
    if var_name == "ΣSIF_LEAF"
        return OrderedDict{String,Any}(
            "about" => "Total Solar-Induced chlorophyll Fluorescence over all measured wavelengths that escape from the leaf",
            "unit" => "W m⁻²",
            "input_varname" => var_name,
        )
    end;

    #
    #
    # with partial match
    #
    #
    # read number digits from the var_name
    if occursin("SIF", var_name) && !isnothing(match(r"\d+", var_name))
        wl = parse(Int, match(r"\d+", var_name).match);

        return OrderedDict{String,Any}(
            "about" => "Solar-Induced chlorophyll Fluorescence at $wl nm",
            "unit" => "W m⁻² sr⁻¹ μm⁻¹",
            "input_varname" => var_name,
        )
    end;

    #
    #
    # with no match
    #
    #
    # display that the name is not recognized
    if showwarning
        @warn "Attribute name '$var_name' is not recognized, use default attribute (var_name => var_name) instead...";
    end;

    return OrderedDict{String,Any}(
        "input_varname" => var_name
    )
);

detect_attribute(var_name::Symbol, wavelength::Union{Int,Nothing} = nothing; args...) = detect_attribute(String(var_name), wavelength; args...);
