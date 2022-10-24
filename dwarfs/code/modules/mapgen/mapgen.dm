GLOBAL_VAR_INIT(temperature_seed, 0)

/datum/map_generator/caves
	var/name = "Caves"

/datum/map_generator/caves/generate_terrain(list/turfs)
	if(CONFIG_GET(flag/disable_generation))
		return
	if(!GLOB.temperature_seed)
		GLOB.temperature_seed = rand(1, 2000)
	var/start_time = REALTIMEOFDAY
	var/list/height_values = fbm3d(world.maxx, world.maxy, turfs[1].z * 2, GLOB.temperature_seed * 10)
	var/list/moist_values = fbm(world.maxx, world.maxy, GLOB.temperature_seed * 15)
	var/list/temp_values = fbm3d(world.maxx, world.maxy, turfs[1].z, GLOB.temperature_seed, frequency=0.006, lacunarity=0.4, persistence=0.4)
	for(var/turf/T in turfs)
		var/height = text2num(height_values[world.maxx * (T.y - 2) + T.x])
		var/temp = text2num(temp_values[world.maxx * (T.y - 2) + T.x])
		var/moist = text2num(moist_values[world.maxx * (T.y - 2) + T.x])
		var/turf/turf_type
		switch(height)
			if(-INFINITY to -0.2)
				if(moist > 0.5)
					turf_type = /turf/open/water
				else if(moist > 0.3)
					turf_type = /turf/open/floor/dirt
				else if(temp > 0)
					turf_type = /turf/open/floor/sand
				else
					turf_type = /turf/open/floor/rock
			if(-0.2 to INFINITY)
				if(temp > 0)
					turf_type = /turf/closed/mineral/random/sand
				else
					turf_type = /turf/closed/mineral/random/dwarf_lustress
		if(T.z != 2)
			var/turf/turf_below = SSmapping.get_turf_below(T)
			var/list/turfs_openable = list(/turf/open/floor/sand, /turf/open/floor/rock, /turf/open/openspace, /turf/open/floor/dirt, /turf/open/water)
			if(isopenturf(turf_below))
				if(turf_type in turfs_openable)
					turf_type = /turf/open/openspace
		var/list/turfs_growable = list(/turf/open/floor/rock = 1, /turf/open/floor/dirt = 8)
		if(turf_type in turfs_growable)
			generate_turf_flora(T, turfs_growable.Find(turf_type))
		T.ChangeTurf(turf_type, initial(turf_type.baseturfs))
	to_chat(world, span_green(" -- #<b>[name]</b>:> <b>[(REALTIMEOFDAY - start_time)/10]s</b> -- "))
	log_world("[name] is done job for [(REALTIMEOFDAY - start_time)/10]s!")

/datum/map_generator/caves/generate_turf_flora(turf, chance)
	if(prob(chance))
		var/obj/structure/plant/tree/towercap/temp = new (turf)
		temp.growthstage = rand(0, 7)
		temp.growthdelta = rand(80, 400) SECONDS
		temp.update_appearance()

/datum/map_generator/caves/upper
	name = "Upper Caves"

/datum/map_generator/caves/middle
	name = "Middle Caves"

/datum/map_generator/caves/bottom
	name = "Bottom Caves"

/area/dwarf/cavesgen
	name = "Caverns"
	icon_state = "cavesgen"
	static_lighting = TRUE
	base_lighting_alpha = 0
	ambientsounds = AWAY_MISSION
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	sound_environment = SOUND_ENVIRONMENT_CAVE
	ambientsounds = list('sound/ambience/caves8.ogg', 'sound/ambience/caves_old.ogg')
	map_generator = /datum/map_generator/caves

/area/dwarf/cavesgen/upper_level
	map_generator = /datum/map_generator/caves/upper

/area/dwarf/cavesgen/middle_level
	map_generator = /datum/map_generator/caves/middle

/area/dwarf/cavesgen/bottom_level
	map_generator = /datum/map_generator/caves/bottom
