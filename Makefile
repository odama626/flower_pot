generate_models:
	@mkdir out || true
	@openscad -o ./out/shell.3mf -D model='"shell"' -D env='"prod"'  ./main.scad
	@openscad -o ./out/basin.3mf -D model='"basin"' -D env='"prod"' ./main.scad
