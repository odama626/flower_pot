// include <./fillets_and_rounds.scad>

env = "dev";
model = "none";
explode = true;

height = 100; // 100

width = 90;  // 100
depth = 200; // 200

thickness = 10;
spacing = 2;
water_hole = 10;
pour_spout_radius = 15;
pour_spout_length = 20;
cylinder_fragments = 128;
spout_lip = 0;
basin_lip = 5;
resevoir_height = 20;
drainage_hole_radius = 10;

points = [ [ 0, 0, 0 ], [ width, 0, 0 ], [ width, depth, 0 ], [ 0, depth, 0 ] ];
drainage_points = [for (x = [0:1]) for (y = [0:4])[width / 4 + x * (width / 2), depth / 10 + y *(depth / 5), 0]];

module rounded_box(points, radius, height, center)
{
    hull()
    {
        for (p = points)
        {
            translate(p) cylinder(r = radius, h = height, $fn = cylinder_fragments, center = center);
        }
    }
}

module shell()
{
    union()
    {
        difference()
        {
            rounded_box(points, 5 + spacing * 2, height);
            translate([ 0, 0, spacing ]) rounded_box(points, 5 + spacing, height);
        }
        difference()
        {
            cylinders(drainage_points, water_hole, resevoir_height, thickness = spacing / 2);
            cylinders(drainage_points, water_hole - spacing, resevoir_height + spacing, thickness = spacing / 2);
            translate([ 0, 0, 2 ])
                water_holes(drainage_points, water_hole, drainage_hole_radius, thickness = spacing / 2);
        }
    }
}

module cylinders(points, radius, height, thickness)
{
    for (p = points)
    {
        translate(p) cylinder(r = radius, h = height, $fn = cylinder_fragments);
    }
}

module mesh(points, radius, height, thickness)
{
    for (p = points)
    {
        translate(p) translate([ 0, 0, thickness / 2 ]) union()
        {
            cube(
                [
                    radius * 2,
                    spacing / 2,
                    thickness,
                ],
                center = true);
            // translate([ 0, spacing * 2, 0 ])
            rotate(90, [ 0, 0, 1 ]) cube([ radius * 2, spacing / 2, thickness ], center = true);
        }
    }
}

module drainage(points, radius, height, thickness)
{
    for (p = points)
    {
        translate(p) difference()
        {
            cylinder(r = radius, h = height, $fn = cylinder_fragments);
            translate([ 0, 0, height / 2 ]) rotate(90, [ 1, 0, 0 ])
                cylinder(r = height / 4, h = radius * 2, center = true, $fn = cylinder_fragments);
        }
    }
}

module water_holes(points, radius, height, thickness)
{
    for (p = points)
    {
        translate(p) translate([ 0, 0, height / 2 ]) union()
        {
            rotate(90, [ 1, 0, 0 ]) cylinder(r = height / 4, h = radius * 2, center = true, $fn = cylinder_fragments);
            rotate(90, [ 0, 1, 0 ]) cylinder(r = height / 4, h = radius * 2, center = true, $fn = cylinder_fragments);
        }
    }
}

if (env == "dev")
{
    shell();
    offset_height = [resevoir_height, resevoir_height + (height * 1.25)][explode ? 1 : 0];
    echo(offset_height);
    translate([ 0, 0, offset_height ]) basin();
}
else
{
    echo(str("Generating ", model));
    if (model == "shell")
        shell();
    if (model == "basin")
        basin();
}

echo(model == "shell");

module basin()
{
    union()
    {
        height = height - resevoir_height + basin_lip;
        difference()
        {
            spout_height = height + spout_lip;
            union()
            {
                offset = spacing * .75;
                // pour channel skin
                difference()
                {
                    hull()
                    {
                        translate([ width / 2, -water_hole / 2, spout_height / 2 ])
                        {
                            rounded_box([ [ 0, 0, 0 ], [ 0, pour_spout_length, 0 ] ], pour_spout_radius, spout_height,
                                        center = true);

                            // translate([ 0, pour_spout_length, spout_height / 2])
                            //     sphere(pour_spout_radius, $fn = cylinder_fragments);
                        }
                    }
                    translate([ 0, -depth - 6.5, -spacing / 2 ]) cube([ width, depth, spout_height * 2 ]);
                }

                // box
                difference()
                {
                    rounded_box(points, 5 + offset, height);
                    translate([ 0, 0, spacing ]) rounded_box(points, 5 + offset - spacing, height);
                }
            }
            // pour channel cut out
            translate([ width / 2, -water_hole / 2, spout_height ])
                rounded_box([ [ 0, 0, 0 ], [ 0, pour_spout_length, 0 ] ], pour_spout_radius - spacing,
                            (spout_height + spacing) * 2, center = true);

            // drainage holes
            translate([ 0, 0, -1 ])
                cylinders(drainage_points, water_hole * 0.75, 10, thickness = spacing / 2, $fn = cylinder_fragments);
        }
        // drainage mesh
        mesh(drainage_points, water_hole * 0.75, 10, thickness = spacing);
    }
}

echo(version = version());
