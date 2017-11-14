//
//	Main.qc - mostly functions that will be called from the engine and are expected to exist
//

//called when starting server/loading the map
void() main =
{

}

//called for each frame that QC runs
void() StartFrame =
{
	deathmatch = cvar("deathmatch");
	framecount = framecount + 1;
}

//called when map loaded
void() worldspawn =
{
	print("worldspawn\n");
	precache_sound("sounds/jump.wav");
	precache_sound("sounds/land.wav");
	precache_sound("sounds/game_engaging.wav");
	precache_sound("sounds/game_whosthat.wav");
	precache_sound("sounds/game_urgh.wav");
	precache_sound("sounds/game_ugh.wav");
	precache_sound("sounds/game_someonethere.wav");
	precache_sound("sounds/game_itsenemy.wav");
	precache_sound("sounds/game_huh.wav");
	precache_sound("sounds/game_gothostiles.wav");
	precache_sound("sounds/swing.wav");
	precache_sound("sounds/impact.wav");
	precache_sound("sounds/game_ai_fire.wav");
	precache_sound("sounds/game_footstep.wav");
	precache_sound("sounds/game_hitsound.wav");
	precache_sound("sounds/game_laser_hum.wav");
	precache_sound("sounds/turret_fire.wav");
	precache_sound("sounds/turret_activate.wav");
	precache_model("models/hands.iqm");
	precache_model("models/laser.iqm");
	precache_model("models/laserspin.iqm");
	precache_model("models/turret.iqm");
	precache_model("models/turretbase.iqm");
	precache_model("models/testplayer.iqm");
	precache_model("models/human.iqm");
	precache_model("models/bullet.iqm");
	precache_model("models/exit.iqm");
	load_waypoints();
}

void() SpectatorConnect =
{
	bprint(PRINT_HIGH, self.netname);
	bprint(PRINT_HIGH, " has joined the spectators.\n");
}