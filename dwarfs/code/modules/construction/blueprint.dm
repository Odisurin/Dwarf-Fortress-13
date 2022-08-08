/obj/structure/blueprint
	name = "blueprint"
	desc = "Build it."
	max_integrity = 1
	icon = 'dwarfs/icons/structures/32x64.dmi'
	icon_state = "blueprint"
	//What are we building
	var/obj/structure/target_structure
	//What do we need to build it
	var/list/reqs = list()
	//The size of our blueprint = list(x,y)
	var/list/dimensions = list(0,0)
	var/cat = "misc"

/obj/structure/blueprint/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_BUILDER_HAMMER)
		var/list/contained = list()
		for(var/obj/O in contents)
			if(!(O.type in contained))
				contained[O.type] = 0
			contained[O.type] += 1
		for(var/i in reqs)
			if(!(i in contained) || reqs[i] != contained[i])
				to_chat(user, span_warning("[src] is is missing materials to be built!"))
				return
		to_chat(user, span_notice("You build [initial(target_structure.name)]."))
		new target_structure(get_turf(src))
		qdel(src)
	else
		var/_type
		var/contained = 0
		//Check the hard way because of subtypes
		for(var/i in reqs)
			if(istype(I, i))
				_type = i
				//figure out how much we actually need
				for(var/obj/O in contents)
					if(istype(O, I.type))
						contained++
				break
		if(!_type)
			return ..()
		if(reqs[_type] == contained)
			to_chat(user, span_warning("There are already enough [I]!"))
			return
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			var/required = reqs[_type] - contained
			while(!S.use(required))
				required--
			for(var/i in 1 to required)
				new S.type(src)
		else
			I.forceMove(src)
		to_chat(user, span_notice("You add [I] to the blueprint."))

/obj/structure/blueprint/proc/structure_overlay()
	var/mutable_appearance/M = mutable_appearance(initial(target_structure.icon), initial(target_structure.icon_state), layer=ABOVE_MOB_LAYER)
	M.color = "#5e8bdf"
	M.alpha = 120
	return M

/obj/structure/blueprint/update_overlays()
	. = ..()
	var/mutable_appearance/M = structure_overlay()
	. += M

/obj/structure/blueprint/large //2x1 size
	name = "big boi blueprint"
	desc = "Big chugus."
	icon = 'dwarfs/icons/structures/64x32.dmi'
	icon_state = "blueprint"
	dimensions = list(1,0)

/obj/structure/blueprint/large/brewery
	name = "brewery blueprint"
	target_structure = /obj/structure/brewery/spawner
	reqs = list(/obj/item/stack/sheet/stone=1)

/obj/structure/blueprint/large/workbench
	name = "workbench blueprint"
	target_structure = /obj/structure/workbench
	reqs = list(/obj/item/stack/sheet/planks=1)

/obj/structure/blueprint/stove
	name = "stove blueprint"
	target_structure = /obj/structure/stove
	reqs = list(/obj/item/stack/sheet/stone=1)

/obj/structure/blueprint/oven
	name = "oven blueprint"
	target_structure = /obj/structure/oven
	reqs = list(/obj/item/stack/sheet/stone=1)

/obj/structure/blueprint/smelter
	name = "smelter blueprint"
	target_structure = /obj/structure/smelter
	reqs = list(/obj/item/stack/sheet/stone=1)

/obj/structure/blueprint/forge
	name = "forge blueprint"
	target_structure = /obj/structure/forge
	reqs = list(/obj/item/stack/sheet/stone=1)

/obj/structure/blueprint/quern
	name = "quern blueprint"
	target_structure = /obj/structure/quern
	reqs = list(/obj/item/stack/sheet/stone=1)
