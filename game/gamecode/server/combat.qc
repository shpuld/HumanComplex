

void(entity victim, entity source, entity attacker, float amount) damage =
{
	victim.health -= amount;
	
	if(victim.classname == "player")
	{
		//REMEMBER TO REMOVE
		victim.health = 100;
		
		msg_entity = victim;
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, P_DAMAGE);
		WriteByte(MSG_MULTICAST, amount);
		multicast('0 0 0', MULTICAST_ONE);
		if(victim.health <= 0)
		{
			victim.health -= 1;
			victim.attack_finished = time + 2.5;
			victim.solid = SOLID_CORPSE;
			victim.view_ofs = '0 0 -6';
		}
		victim.velocity *= 0.8;
		victim.velocity += normalize((victim.origin + victim.view_ofs) - source.origin) * 60;
		sound(victim, CHAN_AUTO, "sounds/game_hitsound.wav", 1, 1.2, 93 + (random()*14));
	}
	else
	{
		if(victim.classname == "enemy_human" && victim.health > 0)
		{
			victim.attack_finished = time + 2;
			victim.enemy = attacker;
			victim.alertness = 4;
			victim.frame = 5;
			victim.anim_cooldown = time + 1.5;
			sound(victim, CHAN_AUTO, "sounds/game_hitsound.wav", 1, 1.2, 93 + (random()*14));
		}
		
		if(victim.health <= 0)
		{
			sound(victim, CHAN_AUTO, "sounds/game_hitsound.wav", 1, 1.2, 93 + (random()*14));
			local entity oself = self;
			self = victim;
			self.die();
			self = oself;
		}
	}
}

void() bullettouch =
{
	if(other == self.owner)
		return;
		
	if(other.takedamage)
	{
		damage(other, self, self.owner, 9 + rint(random() * 3));
		pointparticles(particleeffectnum("weapons.blood"), self.origin, '0 0 0', 1);
	}	
	else
	{
		sound(self, CHAN_AUTO, "sounds/impact.wav", 1, 1, 93 + (random()*14));
		pointparticles(particleeffectnum("weapons.impact"), self.origin, '0 0 0', 1);
	}
	
	remove(self);
}

void(vector start, vector dir, float damage, entity shooter) firebullet =
{
	local entity proj;
	proj = spawn();
	setorigin(proj, start);
	setmodel(proj, "models/bullet.iqm");
	setsize(proj, '0 0 0', '0 0 0');
	proj.velocity = dir;
	proj.angles = vectoangles(dir);
	proj.touch = bullettouch;
	proj.solid = SOLID_BBOX;
	proj.movetype = MOVETYPE_FLYMISSILE;
	proj.owner = shooter;
}
