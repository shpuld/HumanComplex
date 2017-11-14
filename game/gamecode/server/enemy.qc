
void() SUB_Remove =
{
	remove(self);
}

vector(entity ent) getlastseen =
{
	traceline(ent.origin, ent.origin - '0 0 256', 1, ent);
	if(trace_endpos_z > self.origin_z + 32)
	{
		//print(strcat(ftos(trace_endpos_z), ", ", ftos(self.origin_z), "\n"));
		return [trace_endpos_x, trace_endpos_y, self.origin_z];
	}
	else
	{
		return trace_endpos;
	}
}

void(entity tgt) setmovetarget_pathfind =
{
	/*if(!self.targetreached)
		if(tgt == self.pathfind_goal)
			return;*/
	local vector angs;
	traceline(self.origin, tgt.origin, 1, self);
	if(trace_fraction < 1)
	{
		//print("starting pathfinding\n");
		self.pathfind_goal = tgt;
		entity startnode = closest_visible_node(self);
		pathfind(startnode, closest_visible_node(tgt));
		traceline(self.origin, startnode.path_next.origin, 1, self);
		if(trace_fraction < 1)
		{
			//print("going to first node\n");
			self.movetarget = startnode.origin;
		}
		else
		{
			//print("going to second node\n");
			self.movetarget = startnode.path_next.origin;
		}
		
		angs = vectoangles(normalize(self.movetarget - self.origin));
		self.ideal_yaw = angs_y;
		self.targetreached = FALSE;
		
		self.lastpath = time;
		self.pathdone = FALSE;
	}
	else
	{
		//print("final movetarget\n");
		angs = vectoangles(normalize(self.movetarget - self.origin));
		self.ideal_yaw = angs_y;
		self.movetarget = tgt.origin;
		self.targetreached = FALSE;
		self.pathdone = TRUE;
		self.pathfind_goal = world;
	}
}

void(vector tgt) setmovetarget =
{
	if(vlen(self.origin - tgt) < 32)
		return;
	
	if(!self.targetreached)
	{
		if(tgt == self.movetarget)
			return;
	}
		
	local vector angs = vectoangles(normalize(tgt - self.origin));
	self.ideal_yaw = angs_y;
	self.movetarget = tgt;
	self.targetreached = FALSE;
}

void() cancelmove =
{
	self.movetarget = self.origin;
	self.targetreached = TRUE;
}

void() obstacleavoid =
{
	/*if(vlen(self.velocity) > 280)
		return;*/
	makevectors(self.angles);
	traceline(self.origin + (v_right * 16) + '0 0 18', self.origin + (v_right * 16) + '0 0 18' + v_forward * 24, 0, self);
	if(trace_fraction < 1)
	{
		self.velocity -= v_right * 50;
		return;
	}
	traceline(self.origin + (v_right * -16) + '0 0 18', self.origin + (v_right * -16) + '0 0 18' + v_forward * 24, 0, self);
	if(trace_fraction < 1)
	{
		self.velocity += v_right * 50;
		return;
	}
}

void() humandie =
{
	//print("ded\n");
	self.aithink = SUB_Remove;
	self.ainextthink = time + 3;
	self.solid = SOLID_NOT;
	self.touch = 0;
	if(random() < 0.5)
		sound(self, CHAN_VOICE, "sounds/game_urgh.wav", 1, 1);
	else
		sound(self, CHAN_VOICE, "sounds/game_ugh.wav", 1, 1);
}

void() humantouch =
{
	//print("asdasd\n");
	if(other.classname == "player" && other.health > 0)
	{
		self.lastseen = other.origin;
		self.alertness += 1.2;
		if(self.alertness > 4)
			self.alertness = 4;
		self.enemy = other;
	}
}

void() humanshoot =
{
	local vector spread, dir, angs;
	sound(self, CHAN_AUTO, "sounds/game_ai_fire.wav", 1, 0.5, 100 + (random() - 0.5)*7);
	spread = randomvec() * 0.05;
	dir = normalize((self.enemy.origin + (self.enemy.view_ofs * 0.6)) - (self.origin + '0 0 36')) + spread;
	firebullet(self.origin + '0 0 36', dir * 2500, 10, self);
	angs = vectoangles(dir);
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, P_MUZZLEFLASH);
	WriteCoord(MSG_MULTICAST, self.origin_x + (dir_x * 24));
	WriteCoord(MSG_MULTICAST, self.origin_y + (dir_y * 24));
	WriteCoord(MSG_MULTICAST, self.origin_z + 36 +  + (dir_z * 24));
	WriteCoord(MSG_MULTICAST, angs_x);
	WriteCoord(MSG_MULTICAST, angs_y);
	WriteCoord(MSG_MULTICAST, angs_z);
	multicast(self.origin + '0 0 36', MULTICAST_PVS);
	
	self.attack_finished = time + 0.15; 
}

void() humanthink =
{
	local float vis = FALSE;
	local vector dir, angs;
	makevectors(self.angles);
	local entity head = find(world, classname, "player");
	while(head)
	{
		dir = head.origin - self.origin;
		if(((normalize(dir)*v_forward) > 0.5 || (head.hearable && vlen(dir) < 96)) && head.health > -50 && head.takedamage)
		{
			traceline(self.origin + '0 0 22', head.origin + other.view_ofs, 1, self);
			if(trace_ent == head || trace_fraction >= 1)
			{
				local float dist = vlen(dir);
				if(dist < 80)
					self.alertness += 0.8;
				else if(dist < 200)
					self.alertness += 0.6;
				else if(dist < 400)
					self.alertness += 0.4;
				else if(dist < 600)
					self.alertness += 0.2;
				else
					self.alertness += 0.1;
			
				if(self.alertness > 4)
					self.alertness = 4;
					
				self.enemy = head;
				self.lastseen = getlastseen(head);
				vis = TRUE;
			}
		}
		
		head = find(head, classname, "player");
	}
	if(!vis)
	{
		if(time > self.alert_cooldown)
			self.alertness -= 0.1;
		
		if(self.alertness <= 0)
		{
			self.movespeed = 120;
			self.alertness = 0;
			self.lastsound_time = 0;
			
			if(vlen(self.origin - self.home.origin) > 42)
			{
				if(!self.pathfind_goal && !self.onpatrol)
					setmovetarget_pathfind(self.home);
			}
			else
			{
				if(self.target != "" && self.onpatrol == FALSE)
				{
					self.onpatrol = TRUE;
					self.path_next = find(world, targetname, self.target);
				}
				self.ideal_yaw = self.home.angles_y;
			}
		}
	}
	
	if(self.alertness >= 1)
	{
		traceline(self.lastseen, self.enemy.origin, 1, self);
		if(trace_fraction == 1)
			self.lastseen2 = getlastseen(self.enemy);
	}
	else if(self.onpatrol)
	{
		//print("patrol: starting move\n");
		setmovetarget(self.path_next.origin);
		if(vlen(self.path_next.origin - self.origin) < 40)
			self.path_next = find(world, targetname, self.path_next.target);
	}
	
	if(self.enemy && self.enemy.health <= -50)
	{
		self.alertness = 1.9;
		self.alert_cooldown = time + 1;
		self.enemy = world;
	}
	
	//self.colormod = [self.alertness * (1/4), 1 - self.alertness * (1/4), 1 - self.alertness * (1/4)];
		
	if(self.alertness > 3)
	{
		self.onpatrol = FALSE;
		self.movespeed = 340;
		if(vis)
		{
			if(self.lastsound_time < 2)
			{
				self.lastsound_time = 2;
				local float rn = random();
				if(rn < 0.4)
					sound(self, CHAN_VOICE, "sounds/game_engaging.wav", 1, 0.8);
				else if(rn < 0.8)
					sound(self, CHAN_VOICE, "sounds/game_gothostiles.wav", 1, 0.8);
				else
					sound(self, CHAN_VOICE, "sounds/game_itsenemy.wav", 1, 0.8);
			}
			self.alert_cooldown = time + 6;
			dir = normalize(self.lastseen - self.origin);
			angs = vectoangles(dir);
			self.ideal_yaw = angs_y;
			if(vlen(self.origin - self.enemy.origin) < 250)
			{
				self.moveshoot = FALSE;
				cancelmove();
			}
			else
			{
				self.moveshoot = TRUE;
				setmovetarget(self.lastseen);
			}
			if((dir * v_forward) > 0.6)
			{
				if(time > self.attack_finished)
				{
					if(!self.moveshoot || time > self.anim_cooldown + 1.5)
					{
						self.frame = 3;
						self.anim_cooldown = time + 1;
						if(self.enemy.takedamage)
							self.aiattack();
					}
				}
			}
		}
		else
		{
			if(vlen(self.origin - self.lastseen) < 42)
			{
				setmovetarget(self.lastseen2);
				self.lastseen = self.lastseen2;
			}
			else
				setmovetarget(self.lastseen);
		}
	}
	else if(self.alertness > 2)
	{
		self.movespeed = 120;
		self.onpatrol = FALSE;
		if(vis)
		{
			self.alert_cooldown = time + 8;
			setmovetarget(self.lastseen);
		}
		else if(self.targetreached)
		{
			self.alert_cooldown = time + 4;
			dir = normalize(self.lastseen2 - self.origin);
			angs = vectoangles(dir);
			self.ideal_yaw = angs_y;
		}
	}
	else if(self.alertness > 1)
	{
		self.movespeed = 120;
		if(vis)
		{
			if(self.lastsound_time == 0)
			{
				self.lastsound_time = 1;
				local float rnb = random();
				if(rnb < 0.4)
					sound(self, CHAN_VOICE, "sounds/game_huh.wav", 1, 0.8);
				else if(rnb < 0.7)
					sound(self, CHAN_VOICE, "sounds/game_whosthat.wav", 1, 0.8);
				else
					sound(self, CHAN_VOICE, "sounds/game_someonethere.wav", 1, 0.8);
			}
			cancelmove();
			self.alert_cooldown = time + 1;
			dir = normalize(self.lastseen - self.origin);
			angs = vectoangles(dir);
			self.ideal_yaw = angs_y;
		}
	}

	if(!self.targetreached)
		obstacleavoid();
		
	self.ainextthink = time + 0.1;
	self.aithink = humanthink;
}

void() enemythink =
{
	if(time > self.ainextthink)
	{
		self.aithink();
	}
	if(self.health > 0)
	{
		if(time > self.anim_cooldown)
		{
			if(vlen(self.velocity) > 20)
			{
				if(self.movespeed > 130)
					self.frame = 2;
				else
					self.frame = 1;
			}
			else
			{
				if(self.alertness >= 1)
					self.frame = 4;
				else
					self.frame = 0;
			}
		}
		changeyaw();
		if(!self.targetreached)
		{
			
			if(vlen(self.velocity) < self.movespeed && time > self.anim_cooldown)
				self.velocity += normalize(self.movetarget - self.origin) * (4 + (self.movespeed * 0.1));
			
			if(vlen(self.movetarget - self.origin) < 42)
			{
				self.velocity *= 0.5;
				self.targetreached = TRUE;
				if(!self.pathdone && self.pathfind_goal)
					setmovetarget_pathfind(self.pathfind_goal);
			}
		}
	}
	else
	{
		self.frame = 6;
	}
	if(self.flags & FL_ONGROUND)
	{
		if(vlen(self.velocity) > 10)
		{
			self.velocity *= 0.85;
		}
		else
			self.velocity = '0 0 0';
	}
	self.nextthink = time + 0.05;
	self.think = enemythink;
}

void() turretshoot =
{
	local vector spread, dir, angs;
	spread = randomvec() * 0.05;
	
	dir = normalize((self.enemy.origin + (self.enemy.view_ofs * 0.6)) - (self.origin + '0 0 36')) + spread;
	firebullet(self.origin + '0 0 42', dir * 2500, 10, self);
	sound(self, CHAN_AUTO, "sounds/turret_fire.wav", 1, 0.5);
	
	angs = vectoangles(dir);
	
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, P_MUZZLEFLASH);
	WriteCoord(MSG_MULTICAST, self.origin_x + (dir_x * 24));
	WriteCoord(MSG_MULTICAST, self.origin_y + (dir_y * 24));
	WriteCoord(MSG_MULTICAST, self.origin_z + 42 +  + (dir_z * 24));
	WriteCoord(MSG_MULTICAST, angs_x);
	WriteCoord(MSG_MULTICAST, angs_y);
	WriteCoord(MSG_MULTICAST, angs_z);
	multicast(self.origin + '0 0 36', MULTICAST_PVS);
	
	self.attack_finished = time + 0.1; 
}

void() turretthink =
{	
	if(self.alertness == -1)
	{
		if(self.alert_cooldown > time)
			changeyaw();
		else
			self.alertness = 0;
			
		self.nextthink = time + 0.05;
		self.think = turretthink;
		return;
	}
	
	if(self.alertness == 0)
	{
		self.nextthink = -1;
		self.think = 0;
	}
	else if(self.alert_cooldown > time)
	{
		local vector angs = vectoangles(self.enemy.origin - self.origin);
		changeyaw();
		
		traceline(self.origin + '0 0 42', self.enemy.origin + '0 0 16', 1, self);
		if(trace_fraction < 1)
		{
			
		}
		else
		{
			if(self.enemy.health > -50)
			{
				local float diff;
				diff = self.angles_y - self.ideal_yaw;
				if(diff > 180)
					diff -= 180;
				else if(diff < -180)
					diff += 180;
				if(fabs(diff) < 4)
				{
					if(time > self.attack_finished)
						turretshoot();
				}
				self.ideal_yaw = angs_y;
				self.alert_cooldown = time + 3;
			}
		}
		
		self.nextthink = time + 0.05;
		self.think = turretthink;
	}
	else
	{
		sound(self, CHAN_AUTO, "sounds/turret_activate.wav", 0.6, 1.2);
		self.frame = 2;
		self.alertness = -1;
		self.alert_cooldown = time + 1;
		self.ideal_yaw = self.home.angles_y;
		self.nextthink = time + 0.05;
		self.think = turretthink;
	}
}

void() path_corner =
{
}

void() laserthink =
{
	makevectors(self.angles);
	traceline(self.origin/* + v_forward*/, self.origin + v_forward * 1024, 0, self);
	if(trace_ent.classname == "player")
	{
		//print("hit\n");
		local entity tgt = find(world, targetname, self.target);
		
		if(tgt.alertness != 1 && trace_ent.health > 0)
		{	
			tgt.frame = 1;
			tgt.nextthink = time + 1;
			tgt.think = turretthink;
			tgt.alertness = 1;
			tgt.alert_cooldown = time + 6;
			local vector angs = vectoangles(trace_ent.origin - tgt.origin);
			tgt.ideal_yaw = angs_y;
			tgt.enemy = trace_ent;
			sound(tgt, CHAN_AUTO, "sounds/turret_activate.wav", 0.6, 1);
		}
	}
	self.nextthink = time + 0.05;
	self.think = laserthink;
}

void() laserthink_spin =
{
	makevectors(self.angles);
	traceline(self.origin/* + v_forward*/, self.origin + v_forward * 1024, 0, self);
	if(trace_ent.classname == "player")
	{
		//print("hit\n");
		local entity tgt = find(world, targetname, self.target);
		
		if(tgt.alertness != 1 && trace_ent.health > 0)
		{	
			tgt.frame = 1;
			tgt.nextthink = time + 1;
			tgt.think = turretthink;
			tgt.alertness = 1;
			tgt.alert_cooldown = time + 3;
			local vector angs = vectoangles(trace_ent.origin - tgt.origin);
			tgt.ideal_yaw = angs_y;
			tgt.enemy = trace_ent;
			sound(tgt, CHAN_AUTO, "sounds/turret_activate.wav", 0.6, 1);
		}
	}
	self.angles_y += 2;
	self.nextthink = time + 0.05;
	self.think = laserthink_spin;
}

void() enemy_laser =
{
	setmodel(self, "models/laser.iqm");
	setsize(self, '-4 -4 -4', '4 4 4');
	//traceline(self.origin + v_forward, self.origin + v_forward * 1024, 0, self);
	self.think = laserthink;
	self.nextthink = time + 0.05;
	ambientsound(self.origin, "sounds/game_laser_hum.wav", 0.2, 1.6);
}

void() enemy_laser_spin =
{
	setmodel(self, "models/laserspin.iqm");
	setsize(self, '-4 -4 -4', '4 4 4');
	//traceline(self.origin + v_forward, self.origin + v_forward * 1024, 0, self);
	self.think = laserthink_spin;
	self.nextthink = time + 0.05;
	ambientsound(self.origin, "sounds/game_laser_hum.wav", 0.2, 1.6);
}

void() enemy_turret =
{
	setmodel(self, "models/turret.iqm");
	setsize(self, '-16 -16 0', '16 16 48');
	self.solid = SOLID_BBOX;
	self.scale = 1.5;
	self.frame = 0;
	self.yaw_speed = 15;
	
	local entity base;
	base = spawn();
	setorigin(base, self.origin);
	base.angles = self.angles;
	setmodel(base, "models/turretbase.iqm");
	setsize(base, '-16 -16 0', '16 16 48');
	base.solid = SOLID_NOT;
	base.scale = 1.5;
	base.owner = self;
	self.home = base;
}

void() enemy_human =
{
	//sanity check for the weirdest bug:
	setmodel(self, "models/human.iqm");
	setsize(self, [-16, -16, 0], [16, 16, 56]);
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.takedamage = 1;
	self.gravity = 1;
	self.alertness = 0;
	self.yaw_speed = 10;
	self.health = 60;
	self.movespeed = 120;
	self.ideal_yaw = self.angles_y;
	self.targetreached = TRUE;
	self.touch = humantouch;
	self.die = humandie;
	
	/*if(self.target != "")
	{
		print("onpatrol\n");
		self.onpatrol = TRUE;
		self.path_next = find(world, targetname, self.target);
	}*/
	
	self.home = spawn();
	setorigin(self.home, self.origin + '0 0 16');
	setsize(self.home, '0 0 0', '0 0 0');
	self.home.solid = SOLID_NOT;
	self.home.angles = self.angles;
	
	self.aiattack = humanshoot;
	
	self.aithink = humanthink;
	self.ainextthink = time + 0.2;
	self.think = enemythink;
	self.nextthink = time + 0.05;
}