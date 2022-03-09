/obj/item/pizza_bomb
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'zzzz_modular_occulus/icons/obj/food.dmi'
	icon_state = "pizzabox1"
	var/timer = 10 //Adjustable timer
	var/timer_set = FALSE
	var/primed = FALSE
	var/disarmed = FALSE
	var/wires = list("orange", "green", "blue", "yellow", "aqua", "purple")
	var/correct_wire
	var/armer //Used for admin purposes

/obj/item/pizza_bomb/New()
	..()
	correct_wire = pick(wires)

/obj/item/pizza_bomb/attack_self(mob/user)
	if(disarmed)
		to_chat(user, "<span class='notice'>\The [src] is disarmed.</span>")
		return
	if(!timer_set)
		name = "pizza bomb"
		desc = "It seems inactive."
		icon_state = "pizzabox_bomb"
		timer_set = TRUE
		timer = (input(user, "Set a timer, from one second to ten seconds.", "Timer", "[timer]") as num) * 10
		if(!in_range(src, usr) || issilicon(usr) || !usr.canmove || usr.restrained())
			timer_set = FALSE
			name = "pizza box"
			desc = "A box suited for pizzas."
			icon_state = "pizzabox1"
			return
		timer = clamp(timer, 10, 100)
		icon_state = "pizzabox1"
		to_chat(user, "<span class='notice'>You set the timer to [timer / 10] before activating the payload and closing \the [src].")
		message_admins("[key_name_admin(usr)] has set a timer on a pizza bomb to [timer/10] seconds at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
		log_game("[key_name(usr)] has set the timer on a pizza bomb to [timer/10] seconds ([loc.x],[loc.y],[loc.z]).")
		armer = usr
		name = "pizza box"
		desc = "A box suited for pizzas."
		return
	if(!primed)
		name = "pizza bomb"
		desc = "OH GOD THAT'S NOT A PIZZA"
		icon_state = "pizzabox_bomb"
		audible_message("<span class='warning'> *beep* *beep*</span>")
		to_chat(user, "<span class='danger'>That's no pizza! That's a bomb!</span>")
		message_admins("[key_name_admin(usr)] has triggered a pizza bomb armed by [armer] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
		log_game("[key_name(usr)] has triggered a pizza bomb armed by [armer] ([loc.x],[loc.y],[loc.z]).")
		primed = TRUE
		sleep(timer)
		return go_boom()

/obj/item/pizza_bomb/proc/go_boom()
	if(disarmed)
		visible_message("<span class='danger'> Sparks briefly jump out of the [correct_wire] wire on \the [src], but it's disarmed!")
		return
	to_chat(usr, "Enjoy the pizza!")
	src.visible_message("<span class='userdanger'>\The [src] violently explodes!</span>")
	explosion(src.loc,0,2,4) //Identical to a minibomb
	qdel(src)

/obj/item/pizza_bomb/attackby(obj/item/I, mob/user, params)
	if(QUALITY_WIRE_CUTTING in I.tool_qualities && primed)
		to_chat(user, "<span class='danger'>Oh God, what wire do you cut?!</span>")
		var/chosen_wire = input(user, "OH GOD OH GOD", "WHAT WIRE?!") in wires
		if(!in_range(src, usr) || issilicon(usr) || !usr.canmove || usr.restrained())
			return
		user.visible_message("<span class='warning'>[user] cuts the [chosen_wire] wire!</span>", "<span class='danger'>You cut the [chosen_wire] wire!</span>")
		sleep(5)
		if(chosen_wire == correct_wire)
			src.audible_message("<span class='warning'> \The [src] suddenly stops beeping and seems lifeless.</span>")
			to_chat(user, "<span class='notice'>You did it!</span>")
			icon_state = "pizzabox_bomb_[correct_wire]"
			name = "pizza bomb"
			desc = "A devious contraption, made of a small explosive payload hooked up to pressure-sensitive wires. It's disarmed."
			disarmed = TRUE
			primed = FALSE
			return
		else
			to_chat(user, "<span class='userdanger'>WRONG WIRE!</span>")
			go_boom()
			return
	if(QUALITY_WIRE_CUTTING in I.tool_qualities && disarmed)
		if(!in_range(user, src))
			to_chat(user, "<span class='warning'>You can't see the box well enough to cut the wires out.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts removing the payload and wires from \the [src].</span>")
		if(do_after(user, 40 , target = src))
			user.unEquip(src)
			user.visible_message("<span class='notice'>[user] removes the insides of \the [src]!</span>")
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(src.loc)
			C.amount = 3
			new /obj/item/pizzabox(src.loc)
			qdel(src)
		return
	..()

/obj/item/pizza_bomb/autoarm
	timer_set = TRUE
	timer = 30 // 3 seconds
