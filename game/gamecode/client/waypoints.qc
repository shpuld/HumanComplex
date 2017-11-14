

float() draw_waypoint =
{
	R_BeginPolygon("waypoint");
	
	R_PolygonVertex(self.origin + [-16, 0, 16], [1, 0, 0], [1, 1, 1], 1);
	R_PolygonVertex(self.origin + [-16, 0, -16], [1, 1, 0], [1, 1, 1], 1);
	R_PolygonVertex(self.origin + [16, 0, -16], [0, 1, 0], [1, 1, 1], 1);
	R_PolygonVertex(self.origin + [16, 0, 16], [0, 0, 0], [1, 1, 1], 1);
	
	R_EndPolygon();
	
	local float i;
	
	for(i = 0; i < 4; i++)
	{
		if(self.link[i] != world)
		{
			R_BeginPolygon("tracers/mg");
	
			R_PolygonVertex(self.origin + [0, 0, 2], [1, 0, 0], [1, 1, 1], 1);
			R_PolygonVertex(self.origin + [0, 0, -2], [1, 1, 0], [1, 1, 1], 1);
			R_PolygonVertex(self.link[i].origin + [0, 0, -2], [0, 1, 0], [1, 1, 1], 1);
			R_PolygonVertex(self.link[i].origin + [0, 0, 2], [0, 0, 0], [1, 1, 1], 1);
			
			R_EndPolygon();
		}
	}
	
	return 0;
}


void(vector pos) add_waypoint =
{
	local entity newpoint = spawn();
	setorigin(newpoint, pos);
	newpoint.classname = "waypoint";
	newpoint.predraw = draw_waypoint;
	newpoint.drawmask = 1;
	newpoint.flags |= FL_FINDABLE_NONSOLID;
}


void(vector pos) delete_waypoint =
{
	local entity tgt;
	tgt = findradius(pos, 32);
	while(tgt)
	{
		if(tgt.classname == "waypoint")
		{
			remove(tgt);
		}
		tgt = tgt.chain;
	}
}


void() write_waypoints =
{
	local float filehandle = fopen(strcat("waypoints/", mapname), FILE_WRITE);
	local entity head;
	
	head =  find(world, classname, "waypoint");
	while(head != world)
	{
		fputs(filehandle, strcat(vtos(head.origin), "\n"));
		head = find(head, classname, "waypoint");
	}
	
	fclose(filehandle);
}


void() clear_links =
{
	local entity head;
	
	head =  find(world, classname, "waypoint");
	while(head != world)
	{
		head.link[0] = world;
		head.link[1] = world;
		head.link[2] = world;
		head.link[3] = world;
		head = find(head, classname, "waypoint");
	}
}


float(entity node) get_free_link =
{
	if(node.classname != "waypoint")
	{
		print("you're doing it wrong\n");
		return -1;
	}
	local float i;
	local float free = -1;
	for(i = 0; i < 4; i++)
	{
		if(node.link[i] == world)
		{
			free = i;
			break;
		}
	}
	return free;
}


void() link_waypoints =
{
	clear_links();
	local entity neighbour;
	local entity head =  find(world, classname, "waypoint");
	while(head != world)
	{
		print("new self\n");
		local float self_free = get_free_link(head);
		while(self_free != -1)
		{
			neighbour = findradius(head.origin, 300);
			
			while(neighbour)
			{
				if(neighbour.classname == "waypoint" && neighbour != head)
				{
					print("new other\n");
					local float other_free = get_free_link(neighbour);
					if(other_free != -1)
					{
						tracebox(head.origin, '-16 -16 0', '16 16 16', neighbour.origin, 0, head);
						if(trace_fraction == 1)
						{
							print(strcat("endpos: ",vtos(trace_endpos),"\n"));
							print(strcat("link: ", vtos(head.origin), ", ", vtos(neighbour.origin),"\n"));
							head.link[self_free] = neighbour;
							neighbour.link[other_free] = head;
							self_free = get_free_link(head);
						}
						else
							print("tracebox failed\n");
	
					}
				}
				neighbour = neighbour.chain;
				if(self_free == -1)
					break;
			}
			if(neighbour == world)
				break;
		}
		head = find(head, classname, "waypoint");
	}
}


void() load_waypoints =
{
	local float filehandle = fopen(strcat("waypoints/", mapname), FILE_READ);
	
	local string line = fgets(filehandle);
	while(line)
	{
		local vector pos = stov(line);
		if(pos)
			add_waypoint(pos);
		line = fgets(filehandle);
	}
	link_waypoints();
	fclose(filehandle);
}