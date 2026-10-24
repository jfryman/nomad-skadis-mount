out/nomad-skadis-mount.stl: nomad-skadis-mount.scad
	mkdir -p out
	openscad -D print_orientation=true -o $@ $<

.PHONY: clean
clean:
	rm -rf out
