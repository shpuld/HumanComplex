

/* android touch stuff start */
struct touch_t {
	float x;
	float y;
	float down;
	float time;
};

touch_t touches[4];

vector stickpos;
vector stickmove;

vector aimdelta, aimold;

float move_id;
float aim_id;

float jump_id;
float crouch_id;
float attack_id;

float dojump;
float docrouch;

const float jump_size = 0.2; // relative
const float crouch_size = 0.2;
const float attack_size = 0.2;

const vector jump_pos = '0.6 0.9 0';
const vector crouch_pos = '0.4 0.9 0';
const vector attack_pos = '0.75 0.55 0';

float con_open;

/* android touch stuff end*/

void() ToggleMenu =
{
	if(serverkey("constate") != "disconnected" && missioncomplete == 0)
	{
		if(in_menu == MENU_NONE)
		{
			in_menu = MENU_MAIN;
			time_in_menu = 0;
			local float i;
			for(i = 0; i < BUTTONS_COUNT; i++)
			{
				buttons[i].active = 1;
			}
			setcursormode(TRUE,"menu/cursor");
			localcmd("pause\n");
		}
		else
		{
			localcmd("pause\n");
			in_menu = MENU_NONE;
			//setcursormode(FALSE);
			setcursormode(TRUE,"menu/cursor");
		}
	}
	else
	{
		in_menu = MENU_MAIN;
		time_in_menu = 0;
		setcursormode(TRUE,"menu/cursor");
	}
}

float(float isnew) enemylisten =
{
	/*if(isnew)
	{
		self.oldangles = self.angles;
	}
	
	local float diffx, diffy;
	
	diffx = self.angles_x - self.oldangles_x;
	if(diffx > 180)
		diffx -= 180;
	else if(diffx < -180)
		diffx += 180;
		
	diffy = self.angles_y - self.oldangles_y;
	if(diffy > 180)
		diffy -= 180;
	else if(diffy < -180)
		diffy += 180;

	self.ideal_yaw = self.angles_y + 180;
	self.idealpitch = self.angles_x;
	self.angles = self.oldangles;
	
	print(ftos(self.angles_y));
	self.yaw_speed = frametime * diffy;
	changeyaw();
	self.pitch_speed = frametime * diffx;
	changepitch(self);
	print(", ");
	print(ftos(self.angles_y));
	print("\n");
	
	self.oldangles = self.angles;*/
	
	return TRUE;
}

float(float isnew) laserlisten = 
{
	makevectors(self.angles);
	traceline(self.origin + v_forward, self.origin + v_forward * 1024, 0, self);
	
	local vector cross1 = normalize(crossproduct( getviewprop(VF_ORIGIN) - trace_endpos, trace_endpos - self.origin));
	local vector cross2 = normalize(crossproduct( getviewprop(VF_ORIGIN) - self.origin, trace_endpos - self.origin));
	
	R_BeginPolygon("laser");
	
	R_PolygonVertex(self.origin - cross2*random(), '0 1 0', '1 0 0', 0.35);
	R_PolygonVertex(self.origin + cross2*random(), '0 0 0', '1 0 0', 0.35);
	R_PolygonVertex(trace_endpos + cross1*random(), '1 0 0', '1 0 0', 0.35);
	R_PolygonVertex(trace_endpos - cross1*random(), '1 1 0', '1 0 0', 0.35);
	
	R_EndPolygon();
	
	return TRUE;
}

noref void(float apiver, string enginename, float enginever) CSQC_Init =
{
	registercommand("togglemenu");
	registercommand("startwalk");
	registercommand("stopwalk");
	registercommand("promptjoin");
	registercommand("wp_add");
	registercommand("wp_save");
	registercommand("wp_load");
	registercommand("wp_delete");
	registercommand("wp_relink");

	if(serverkey("constate") == "disconnected")
	{
		localcmd("music 3");
		ToggleMenu();
	}
	//bgpos = 0;
	camlerp = 0;
	missioncomplete = 0;
	
	particleeffectnum("weapons.impact");
	particleeffectnum("weapons.blood");
	precache_model("models/muzzle.iqm");
	deltalisten("models/laser.iqm", laserlisten, 0);
	deltalisten("models/laserspin.iqm", laserlisten, 0);
	
	float i;
	for(i = 0; i < 4; i++)
	{
		touches[i].down = 0;
		touches[i].time = 0;
	}
	move_id = -1;
	aim_id = -1;
	jump_id = -1;
	dojump = 0;
	crouch_id = -1;
	docrouch = 0;
	attack_id = -1;
	con_open = 0;
};

noref void() CSQC_WorldLoaded =
{
	setcursormode(TRUE,"menu/cursor");
};

noref void(float isnew) CSQC_Ent_Update =
{
	
}	

noref void(float width, float height, float menushown) CSQC_UpdateView =
{
	clearscene();
	g_width = width;
	g_height = height;

	setviewprop(VF_DRAWENGINESBAR, 0);	
	setviewprop(VF_DRAWCROSSHAIR, 0);
	
	local vector vorg;
	vorg = getproperty(VF_ORIGIN);
	
	if(camlerp < 0)
		camlerp += frametime * 600;
	else if(camlerp > 0)
	{
		camlerp -= frametime * 600;
		if(camlerp < 0)
			camlerp = 0;
	}
	
	setviewprop(VF_ORIGIN, vorg + [0,0,camlerp]);
			
	addentities(MASK_ENGINE + MASK_VIEWMODEL);

	//dynamiclight_add(vorg, 800, '0.7 0.7 0.7');
	renderscene();

	if(dmgflash > 0)
	{
		if(dmgflash > 25)
			dmgflash = 25;
		dmgflash -= frametime * 5;
		drawfill([0, 0, 0], [g_width, g_height, 0], [1, 0.2, 0.1], dmgflash * (1/30), 1);
	}
	
	if(in_menu)
	{
		Draw_Menu();
	}
	else
	{
		if(time < tuttime)
		{
			drawjustifiedstring([g_width / 2, (g_height / 2) - 40], tutstring, [10, 10], [1, 1, 1], 1, ANC_MID_C);
		}
		drawjustifiedstring([g_width / 2, g_height - 24], "Health", [10, 10], [1, 1, 1], 0.8, ANC_MID_C);
		drawjustifiedstring([g_width / 2, g_height - 12], ftos(getstatf(STAT_HEALTH)), [16 + dmgflash * 0.2, 16 + dmgflash * 0.2], [1, 1, 1], 0.8, ANC_MID_C);
	}
	
	float i = 0;
	/*for(i = 0; i < 4; i++)
	{
		drawstring([200, 120 + i * 16, 0], strcat(
			"Touch: ", 
			ftos(i), 
			", pos: '", 
			ftos(rint(touches[i].x)),
			" ",
			ftos(rint(touches[i].y)),
			"', time: ",
			ftos(touches[i].time)
			), [16, 16, 0], [1, 1, 1], 1, 0);
	}*/
	if(move_id != -1)
	{
		float size = g_height / 6;
		drawpic(stickpos - [size / 2, size / 2, 0], "gfx/joystick_base", [size, size, 0], [1, 1, 1], 1, 0);
		drawpic(stickmove - [size / 2, size / 2, 0], "gfx/joystick_stick", [size, size, 0], [1, 1, 1], 1, 0);
	}
	drawpic([jump_pos_x * g_width - (jump_size * g_height * 0.5), 
		jump_pos_y * g_height - (jump_size * g_height * 0.5), 0],
		"gfx/joystick_base", [jump_size * g_height, jump_size * g_height, 0],
		[1, 1, 1], 1, 0);
	drawpic([crouch_pos_x * g_width - (crouch_size * g_height * 0.5), 
		crouch_pos_y * g_height - (crouch_size * g_height * 0.5), 0],
		"gfx/joystick_base", [crouch_size * g_height, crouch_size * g_height, 0],
		[1, 1, 1], 1, 0);
	drawpic([attack_pos_x * g_width - (attack_size * g_height * 0.5), 
		attack_pos_y * g_height - (attack_size * g_height * 0.5), 0],
		"gfx/joystick_base", [attack_size * g_height, attack_size * g_height, 0],
		[1, 1, 1], 1, 0);
};

noref float(string cmd) CSQC_ConsoleCommand =
{
	//self = theplayer;
	//if (!self)
	//	return FALSE;

	tokenize(cmd);
	switch(argv(0))
	{
		case "togglemenu":
			ToggleMenu();
			return TRUE;
			break;
		case "map":
			return FALSE;
			break;
		case "startwalk":
			walk = TRUE;
			return FALSE;
		case "stopwalk":
			walk = FALSE;
			return FALSE;
		case "promptjoin":
			menu_join();
			return TRUE;
		case "wp_add":
			add_waypoint(getentity(player_localentnum, GE_ORIGIN));
			link_waypoints();
			return TRUE;
		case "wp_save":
			write_waypoints();
			return TRUE;
		case "wp_load":
			load_waypoints();
			return TRUE;
		case "wp_delete":
			delete_waypoint(getentity(player_localentnum, GE_ORIGIN));
			link_waypoints();
			return TRUE;
		case "wp_relink":
			link_waypoints();
			return TRUE;
		default:
			return FALSE;
	}
	return FALSE;
};

void(float id) touch_down =
{
	if(vlen([jump_pos_x * g_width, jump_pos_y * g_height, 0] - [touches[id].x, touches[id].y, 0]) < g_height * jump_size * 0.5)
		jump_id = id;
	else if(vlen([crouch_pos_x * g_width, crouch_pos_y * g_height, 0] - [touches[id].x, touches[id].y, 0]) < g_height * crouch_size * 0.5)
		crouch_id = id;
	else if(vlen([attack_pos_x * g_width, attack_pos_y * g_height, 0] - [touches[id].x, touches[id].y, 0]) < g_height * attack_size * 0.5)
		attack_id = id;
		
	if(touches[id].x > 0.05 * g_width && touches[id].x < 0.4 * g_width)
	{
		if(touches[id].y > 0.4 * g_height && touches[id].y < 0.95 * g_height)
		{
			move_id = id;
			stickpos = [touches[id].x, touches[id].y, 0];
			stickmove = stickpos = [touches[id].x, touches[id].y, 0];
		}
	}
	else if(touches[id].x > 0.5 * g_width && touches[id].x < 1 * g_width)
	{
		if(touches[id].y > 0.4 * g_height && touches[id].y < 1 * g_height)
		{
			aim_id = id;
			aimold = [touches[id].x, touches[id].y, 0];
			aimdelta = [0, 0, 0];
		}
	}
};

void(float id) touch_move =
{
	if(id == move_id)
	{
		float size = g_height / 6;
		float dist = vlen(stickpos - [touches[id].x, touches[id].y, 0]);
		if(dist < size * 0.6)
		{
			stickmove = [touches[id].x, touches[id].y, 0];
		}
		else
		{
			vector dir = normalize([touches[id].x, touches[id].y, 0] - stickpos);
			stickmove = stickpos + dir * size * 0.6;
		}
	}
	if(id == aim_id)
	{
		aimdelta = ([touches[id].x, touches[id].y, 0] - aimold) / (g_height * 0.01);
		//aimold = [touches[id].x, touches[id].y, 0];
	}
};

void(float id) touch_up =
{
	if(id == move_id)
		move_id = -1;
	if(id == aim_id)
	{
		aimdelta = [0, 0, 0];
		aim_id = -1;
	}
	if(id == jump_id)
	{
		jump_id = -1;
		dojump = 1;
	}
	if(id == crouch_id)
	{
		crouch_id = -1;
		docrouch = 1;
	}
	if(id == attack_id)
		attack_id = -1;
};

noref float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch(evtype)
	{
	case IE_KEYDOWN:
		if(scanx == K_MOUSE1)
		{
			if(devid < 4)
			{
				touches[devid].down = 1;
				touches[devid].time = 0;
			}
			if(in_menu != MENU_NONE)
			{
				if(scanx == K_MOUSE1)
				{
					Menu_Click();
					return TRUE;
				}
			}
			return TRUE;
		}
		if(scanx == K_ESCAPE)
		{
			//localcmd("toggleconsole\n");
			//return TRUE;
		}
	case IE_KEYUP:
		if(scanx == K_MOUSE1 || scanx == K_MOUSE2)
		{
			if(devid < 4)
			{
				print(strcat("touch up: ", ftos(devid), "\n"));
				touches[devid].down = 0;
				touch_up(devid);
				touches[devid].time = 0;
			}
		}
		return TRUE;
	case IE_MOUSEDELTA:
		return TRUE;
	case IE_MOUSEABS:
		//if(devid != 0 && devid != 1)
		//	return FALSE;
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		
		if(devid < 4)
		{
			touches[devid].x = scanx;
			touches[devid].y = chary;
			if(touches[devid].down)
			{
				if(touches[devid].time == 0)
				{
					touch_down(devid);
				}
				else
				{
					touch_move(devid);
				}
				touches[devid].time += frametime;
			}
		}
		return TRUE;
	}
	return FALSE;
};

/*
noref float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{
	switch(evtype)
	{
	case IE_KEYDOWN:
		if(in_menu != MENU_NONE)
		{
			if(scanx == K_MOUSE1)
			{
				Menu_Click();
				return TRUE;
			}
		}
		return FALSE;
	case IE_KEYUP:
		return FALSE;
	case IE_MOUSEDELTA:
		return TRUE;
	case IE_MOUSEABS:
		//if(devid != 0 && devid != 1)
		//	return FALSE;
		cursor_pos_x = scanx;
		cursor_pos_y = chary;
		
		return FALSE;
	}
	return FALSE;
};
*/

void() touch_frame =
{
	if(aim_id != -1)
	{
		//print(vtos(aimdelta));
		aimdelta_x *= 0.7 + (0.2 * fabs(aimdelta_x + 1));
		aimdelta_y *= 0.7 + (0.2 * fabs(aimdelta_y + 1));
		input_angles_y += aimdelta_x * -1;
		input_angles_x += aimdelta_y * 1;
		setviewprop(VF_CL_VIEWANGLES, input_angles);
		//input_angles_x += 60;
		aimold = [touches[aim_id].x, touches[aim_id].y, 0];
		aimdelta = [0, 0, 0];
	}
	if(move_id != -1)
	{
		float size = g_height / 6;
		vector dir = stickmove - stickpos;
		dir *= 1.2;
		if(vlen(dir) > size)
			dir = normalize(dir) * size;
		dir = (dir * (1/size)) * 320;
		makevectors([input_angles_x, 0, 0]);
		//right = getentity(player_localentnum, GE_RIGHT);
		//forward = normalize(crossproduct([0, 0, 1], right));
		input_movevalues = v_forward * (-1 * dir_y);
		input_movevalues += v_right * (-1 * dir_x);
	}
	input_buttons = 0;
	if(attack_id != -1)
		input_buttons = 1;
	if(dojump)
	{
		localcmd("toggleconsole\n");
		input_buttons = 2;
		dojump = 0;
	}
	if(docrouch)
	{
		if(crouching)
			localcmd("-crouch\n");
		else
			localcmd("+crouch\n");
			
		docrouch = 0;
	}
};

noref void() CSQC_Input_Frame =
{
	touch_frame();
	
	if(walk || crouching)
	{
		input_movevalues *= 0.5;
	}
	
	//input_angles += [45, 45, 0];
}

float() muzzle_predraw =
{
	self.alpha -= frametime * 48;
	self.scale += frametime * 30;
	if(self.alpha < 0.02)
		remove(self);
	
	return PREDRAW_AUTOADD;
}

noref void() CSQC_Parse_Event =
{
	local float first = readbyte();
	
	switch(first)
	{
		case P_CROUCH:
			crouching = TRUE;
			camlerp = 28;
			break;
		case P_UNCROUCH:
			crouching = FALSE;
			camlerp = -28;
			break;
		case P_DAMAGE:
			dmgflash = readbyte() * 1;
			break;
		case P_DEAD:
			time_in_menu = 0;
			in_menu = MENU_GAMEOVER;
			setcursormode(TRUE, "menu/cursor");
			break;
		case P_MUZZLEFLASH:
			local vector pos, ang;
			pos = '0 0 0';
			ang = '0 0 0';
			pos_x = readcoord();
			pos_y = readcoord();
			pos_z = readcoord();
			ang_x = readcoord();
			ang_y = readcoord();
			ang_z = readcoord();
			local entity muzzle = spawn();
			setorigin(muzzle, pos);
			muzzle.angles = ang;
			muzzle.predraw = muzzle_predraw;
			muzzle.drawmask = 1;
			setmodel(muzzle, "models/muzzle.iqm");
			muzzle.alpha = 1;
			muzzle.scale = 0.85;
			muzzle.angles_z = random() * 360;
			break;
		case P_MISSIONCOMPLETE:
			missioncomplete = time;
			in_menu = MENU_MULTI;
			time_in_menu = 0;
			setcursormode(TRUE,"menu/cursor");
			break;
		case P_TUTORIAL:
			local float num = readbyte();
			tuttime = time + 5;
			if(num == 1)
				tutstring = "Move with WASD, look with mouse";
			else if(num == 2)
				tutstring = "Hold CTRL to crouch (silent)";
			else if(num == 3)
				tutstring = "Press SPACE to jump";
			else if(num == 4)
				tutstring = "Sneak upon enemies and hit them with MOUSE1";
			else if(num == 5)
				tutstring = "Touching a laser activates a turret";
			else
				tutstring = "Try to reach EXIT in every level";
			break;
		default:
			break;
	}
}