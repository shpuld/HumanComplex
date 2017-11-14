//
//	Player.qc - Various stuff done for the player, including per-frame functions like PlayerPreThink and PlayerPostThink, also client specific stuff like PutClientInServer etc.
//

void() PlayerJump =
{
	if (!(self.flags & FL_ONGROUND))
		return;

	if (!(self.flags & FL_JUMPRELEASED))
		return;
			
	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
	sound(self, CHAN_VOICE, "sounds/jump.wav", 1, 1.75);
	self.button2 = 0;
}

void() Hit =
{
	makevectors(self.angles);
	traceline(self.origin + self.view_ofs, (self.origin + self.view_ofs) + v_forward * 64, 0, self);
	self.hearable = TRUE;
	self.lastsound_time = time;
	sound(self, CHAN_AUTO, "sounds/swing.wav", 1, 1, 100 + random() * 6);
	if(trace_ent.takedamage)
	{
		trace_ent.velocity += (v_forward * 150) + '0 0 80';
		damage(trace_ent, self, self, 20);
		pointparticles(particleeffectnum("weapons.blood"), trace_endpos, '0 0 0', 1);
	}
	self.weaponframe += 1;
	if(self.weaponframe > 2)
		self.weaponframe = 0;
	self.attack_finished = time + 0.5;
}

void() CheckImpulses =
{
	if(self.impulse == 10)
	{
		self.crouching = TRUE;
	}
	else if(self.impulse == 11)
	{
		self.crouching = FALSE;
	}
	self.impulse = 0;
}

void() PlayerPreThink =
{	
	if(!self.takedamage)
		return;
	
	CheckImpulses();
	
	if(time - 0.3 > self.lastsound_time)
		self.hearable = FALSE;
	
	if(self.health <= 0)
	{
		if(time > self.attack_finished)
		{
			//hack:
			self.attack_finished = time + 2000;
			msg_entity = self;
			WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
			WriteByte(MSG_MULTICAST, P_DEAD);
			multicast('0 0 0', MULTICAST_ONE);
		}
		return;
	}
	
	if(self.crouching && self.maxs_z == 32)
	{
		setsize(self, [-16, -16, -24], [16, 16, 4]);
		self.view_ofs = [0, 0, -6];
		
		msg_entity = self;
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, P_CROUCH);
		multicast('0 0 0', MULTICAST_ONE);
	}
	else if(!self.crouching)
	{
		if(self.maxs_z < 32)
		{
			tracebox(self.origin, [-16, -16, -24], [16, 16, 4], self.origin + '0 0 28', 0, self);
			if(trace_fraction == 1)
			{
				setsize(self, [-16, -16, -24], [16, 16, 32]);
				self.view_ofs = [0, 0, 22];
				
				msg_entity = self;
				
				WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
				WriteByte(MSG_MULTICAST, P_UNCROUCH);
				multicast('0 0 0', MULTICAST_ONE);
			}
		}
	}
	
	if(self.button0)
	{
		if(time > self.attack_finished)
			Hit();
	}
	else
	{

	}
	if(self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;
};

void() PlayerPostThink =
{
	if(self.isspec)
		return;
	
	//landsound
	if((self.oldvelocity_z < -10) && (self.flags & FL_ONGROUND))
	{
		if(self.oldvelocity_z < -220)
			sound(self, CHAN_BODY, "sounds/game_footstep.wav", 1, 1.75);
		self.hearable = TRUE;
		self.lastsound_time = time - 0.15;
	}
	
	//footsteps
	if((vlen(self.velocity) > 315) &&( time - self.lastsound_time > 0.3) && (self.flags & FL_ONGROUND))
	{
		local float movelen = vlen(input_movevalues);
		if(movelen > 300)
		{
			self.hearable = TRUE;
			sound(self, CHAN_BODY, "sounds/game_footstep.wav", 0.5, 2.5);
			self.lastsound_time = time;
		}
	}
	
	self.oldvelocity = self.velocity;
};

void() ClientKill =
{
};

//called when a client connects to the server
void() ClientConnect =
{
	bprint(PRINT_HIGH, self.netname); //print player name
	bprint(PRINT_HIGH, " connected.\n");
};

void() PlayerSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = FALSE;
	self.classname = "player";
	self.solid = SOLID_SLIDEBOX;
	setmodel(self, "models/testplayer.iqm");
	self.movetype = MOVETYPE_WALK;
	self.health = 100;
	self.origin = spawnpoint.origin + [0,0,1];
	self.angles = spawnpoint.angles;
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = '0 0 22';
	self.takedamage = 1;
	self.weaponmodel = "models/hands.iqm";
};

void() SpectatorSpawn =
{
	local entity spawnpoint;
	spawnpoint = find(world, classname, "info_player_start");
	
	self.isspec = TRUE;
	self.classname = "spectator";
	self.solid = SOLID_NOT;
	setmodel(self, "");
	self.movetype = MOVETYPE_FLY;
	self.origin = spawnpoint.origin + [0,0,1];
	self.fixangle = TRUE;
	setsize(self, [-16, -16, -24], [16, 16, 32]);
	self.view_ofs = '0 0 22';
	self.aiment = world;
};

//called when a client loads a map
void() PutClientInServer =
{
	//stuffcmd(self, "promptjoin\n");
	//SpectatorSpawn();
	PlayerSpawn();
};

//called when client disconnects from the server
void() ClientDisconnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has left the game.\n");
};


void() SetNewParms =
{
};

void() SetChangeParms =
{
};

void() info_player_start =
{
	
};

void() tuttouch =
{
	if(other.classname == "player")
	{
		msg_entity = other;
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, P_TUTORIAL);
		WriteByte(MSG_MULTICAST, self.alertness);
		multicast('0 0 0', MULTICAST_ONE);
	}
};

void() info_tut1 =
{
	setsize(self, '-32 -32 -32', '32 32 32');
	self.solid = SOLID_TRIGGER;
	self.alertness = 1;
	self.touch = tuttouch;
};

void() info_tut2 =
{
	setsize(self, '-32 -32 -32', '32 32 32');
	self.solid = SOLID_TRIGGER;
	self.alertness = 2;
	self.touch = tuttouch;
};

void() info_tut3 =
{
	setsize(self, '-32 -32 -32', '32 32 32');
	self.solid = SOLID_TRIGGER;
	self.alertness = 3;
	self.touch = tuttouch;
};

void() info_tut4 =
{
	setsize(self, '-32 -32 -32', '32 32 32');
	self.solid = SOLID_TRIGGER;
	self.alertness = 4;
	self.touch = tuttouch;
};

void() info_tut5 =
{
	setsize(self, '-32 -32 -32', '32 32 32');
	self.solid = SOLID_TRIGGER;
	self.alertness = 5;
	self.touch = tuttouch;
};

void() info_tut6 =
{
	setsize(self, '-32 -32 -32', '32 32 32');
	self.solid = SOLID_TRIGGER;
	self.alertness = 6;
	self.touch = tuttouch;
};



void() exittouch =
{
	if(other.classname == "player" && other.takedamage)
	{
		other.takedamage = 0;
		
		msg_entity = other;
		
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, P_MISSIONCOMPLETE);
		multicast('0 0 0', MULTICAST_ONE);
	}
};

void() info_exit =
{
	setmodel(self, "models/exit.iqm");
	setsize(self, '-32 -32 -32', '32 32 32');
	self.solid = SOLID_TRIGGER;
	self.touch = exittouch;
};

void(string com) SV_ParseClientCommand =
{
	/*if(com == "joingame")
	{
		if(self.isspec)
		{
			//bprint(PRINT_HIGH, self.netname);
			//bprint(PRINT_HIGH, " has joined the game.\n");
			PlayerSpawn();
		}
		else
			sprint(self, PRINT_HIGH, "You're already in game!\n");
	}
	else
	{*/
	clientcommand(self, com);
	//}
};

void() SV_RunClientCommand =
{
	if(!self.takedamage)
	{
		input_movevalues = '0 0 0';
	}
	if((self.maxs_z < 32) && vlen(input_movevalues) > 160)
	{
		input_movevalues = normalize(input_movevalues) * 160;
	}
	runstandardplayerphysics(self);
}