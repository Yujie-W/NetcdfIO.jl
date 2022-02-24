using DataFrames
using NCDatasets
using NetcdfIO
using Test


@testset verbose = true "NetcdfIO Test" begin
    @testset "Create" begin
        create_nc!("test.nc");
        @test true;
        create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, 0]);
        @test true;
        create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, Inf]);
        @test true;

        rm("test.nc"; force=true);
    end;

    @testset "Add dim" begin
        create_nc!("test.nc");

        add_nc_dim!("test.nc", "dim1", 0);
        @test true;
        add_nc_dim!("test.nc", "dim2", 10);
        @test true;
        @info "Expecting a warning here!";
        add_nc_dim!("test.nc", "dim2", 10);
        @test true;
        add_nc_dim!("test.nc", "dim3", 10.0);
        @test true;
        add_nc_dim!("test.nc", "dim4", Inf);
        @test true;

        _dset = Dataset("test.nc", "a");

        add_nc_dim!(_dset, "dim5", 0);
        @test true;
        add_nc_dim!(_dset, "dim6", 10);
        @test true;
        add_nc_dim!(_dset, "dim7", 10.0);
        @test true;
        add_nc_dim!(_dset, "dim8", Inf);
        @test true;

        close(_dset);

        rm("test.nc"; force=true);
    end;

    @testset "Append" begin
        create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, 5]);
        _dset = Dataset("test.nc", "a");

        append_nc!(_dset, "str", ["A" for i in 1:18], Dict("longname" => "test strings"), ["lat"]);
        @test true;
        append_nc!(_dset, "lat", collect(1:18), Dict("longname" => "latitude"), ["lat"]);
        @test true;
        append_nc!(_dset, "lon", collect(1:36), Dict("longname" => "longitude"), ["lon"]; compress=4);
        @test true;
        append_nc!(_dset, "ind", collect(1:5), Dict("longname" => "index"), ["ind"]);
        @test true;
        append_nc!(_dset, "d2d", rand(36,18), Dict("longname" => "a 2d dataset"), ["lon", "lat"]);
        @test true;
        append_nc!(_dset, "d3d", rand(36,18,5), Dict("longname" => "a 3d dataset"), ["lon", "lat", "ind"]);
        @test true;

        close(_dset);

        create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, 5]);

        append_nc!("test.nc", "str", ["A" for i in 1:18], Dict("longname" => "test strings"), ["lat"]);
        @test true;
        append_nc!("test.nc", "lat", collect(1:18), Dict("longname" => "latitude"), ["lat"]);
        @test true;
        append_nc!("test.nc", "lon", collect(1:36), Dict("longname" => "longitude"), ["lon"]; compress=4);
        @test true;
        append_nc!("test.nc", "ind", collect(1:5), Dict("longname" => "index"), ["ind"]);
        @test true;
        append_nc!("test.nc", "d2d", rand(36,18), Dict("longname" => "a 2d dataset"), ["lon", "lat"]);
        @test true;
        append_nc!("test.nc", "d3d", rand(36,18,5), Dict("longname" => "a 3d dataset"), ["lon", "lat", "ind"]);
        @test true;

        rm("test.nc"; force=true);
    end;

    @testset "Grow" begin
        create_nc!("test.nc", String["lon", "lat", "ind"], [36, 18, 0]);
        _dset = Dataset("test.nc", "a");
        append_nc!(_dset, "lat", collect(1:18), Dict("longname" => "latitude"), ["lat"]);
        append_nc!(_dset, "lon", collect(1:36), Dict("longname" => "longitude"), ["lon"]; compress=4);
        append_nc!(_dset, "ind", collect(1:5), Dict("longname" => "index"), ["ind"]);
        append_nc!(_dset, "d2d", rand(36,5), Dict("longname" => "a 2d dataset"), ["lon", "ind"]);
        append_nc!(_dset, "d3d", rand(36,18,5), Dict("longname" => "a 3d dataset"), ["lon", "lat", "ind"]);

        grow_nc!(_dset, "ind", 6, true);
        @test true;
        grow_nc!(_dset, "ind", 6, false);
        @test true;
        grow_nc!(_dset, "ind", [8,9], true);
        @test true;
        grow_nc!(_dset, "ind", [10,11], false);
        @test true;
        grow_nc!(_dset, "d2d", rand(36), true);
        @test true;
        grow_nc!(_dset, "d2d", rand(36), false);
        @test true;
        grow_nc!(_dset, "d2d", rand(36,2), true);
        @test true;
        grow_nc!(_dset, "d2d", rand(36,2), false);
        @test true;
        grow_nc!(_dset, "d3d", rand(36,18), true);
        @test true;
        grow_nc!(_dset, "d3d", rand(36,18), false);
        @test true;
        grow_nc!(_dset, "d3d", rand(36,18, 2), true);
        @test true;
        grow_nc!(_dset, "d3d", rand(36,18, 2), false);
        @test true;

        close(_dset);

        grow_nc!("test.nc", "ind", 15, true);
        @test true;
        grow_nc!("test.nc", "d3d", rand(36,18), false);
        @test true;

        # do not delete the file so as to test other functions
        # rm("test.nc"; force=true);
    end;

    @testset "Info" begin
        @test dimname_nc("test.nc") == ["lon", "lat", "ind"];
        @test varname_nc("test.nc") == ["lat", "lon", "ind", "d2d", "d3d"];
        @test size_nc("test.nc", "d2d") == (2, (36,15));
        @test size_nc("test.nc", "d3d") == (3, (36,18,15));

        # do not delete the file so as to test other functions
        # rm("test.nc"; force=true);
    end;

    @testset "Read" begin
        read_nc(Float32, "test.nc", "d2d");
        @test true;
        read_nc(Float32, "test.nc", "d2d"; transform=false);
        @test true;
        read_nc(Float32, "test.nc", "d3d");
        @test true;
        read_nc(Float32, "test.nc", "d3d"; transform=false);
        @test true;
        read_nc(Float32, "test.nc", "lat", 1);
        @test true;
        read_nc(Float32, "test.nc", "lat", 1; transform=false);
        @test true;
        read_nc(Float32, "test.nc", "d3d", 1);
        @test true;
        read_nc(Float32, "test.nc", "d3d", 1; transform=false);
        @test true;
        read_nc(Float32, "test.nc", "d2d", 1, 1);
        @test true;
        read_nc(Float32, "test.nc", "d2d", 1, 1; transform=false);
        @test true;
        read_nc(Float32, "test.nc", "d3d", 1, 1);
        @test true;
        read_nc(Float32, "test.nc", "d3d", 1, 1; transform=false);
        @test true;
        read_nc(Float32, "test.nc", "d3d", 1, 1, 1);
        @test true;
        read_nc(Float32, "test.nc", "d3d", 1, 1, 1; transform=false);
        @test true;

        append_nc!("test.nc", "A", collect(1:15), Dict("longname" => "DataFrame A"), ["ind"]);
        append_nc!("test.nc", "B", collect(1:15), Dict("longname" => "DataFrame B"), ["ind"]);
        append_nc!("test.nc", "C", collect(1:15), Dict("longname" => "DataFrame C"), ["ind"]);

        read_nc("test.nc", ["A", "B", "C"]);
        @test true;
        read_nc("test.nc", ["A", "B", "C"]; transform=false);
        @test true;

        rm("test.nc"; force=true);
    end;

    @testset "Save" begin
        data1 = rand(12) .+ 273.15;
        data2 = rand(36,18) .+ 273.15;
        data3 = rand(36,18,12) .+ 273.15;

        save_nc!("data1.nc", "data1", data1, Dict("description" => "Random temperature", "unit" => "K"));
        @test true;
        save_nc!("data2.nc", "data2", data2, Dict("description" => "Random temperature", "unit" => "K"));
        @test true;
        save_nc!("data3.nc", "data3", data3, Dict("description" => "Random temperature", "unit" => "K"));
        @test true;

        _df = DataFrame();
        _df[!,"A"] = rand(5);
        _df[!,"B"] = rand(5);
        _df[!,"C"] = rand(5);
        save_nc!("dataf.nc", _df, ["A","B"], [Dict("A" => "Attribute A"), Dict("B" => "Attribute B")]);
        @test true;
        save_nc!("datag.nc", _df);
        @test true;

        rm("data1.nc"; force=true);
        rm("data2.nc"; force=true);
        rm("data3.nc"; force=true);
        rm("dataf.nc"; force=true);
        rm("datag.nc"; force=true);
    end;
end;
