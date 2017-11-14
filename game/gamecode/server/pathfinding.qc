
//-------------------------------------------------------------------------
//				WAYPOINT STUFF
//-------------------------------------------------------------------------

void(vector pos) add_waypoint =
{
	local entity newpoint = spawn();
	setorigin(newpoint, pos);
	newpoint.classname = "waypoint";
	newpoint.flags |= FL_FINDABLE_NONSOLID;
	newpoint.inset = 0;
	//setmodel(newpoint,"models/testenemy.iqm");
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
		dprint("you're doing it wrong\n");
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
	//print("starting linking\n");
	clear_links();
	local entity neighbour;
	local entity head =  find(world, classname, "waypoint");
	while(head != world)
	{
		//dprint("new self\n");
		local float self_free = get_free_link(head);
		while(self_free != -1)
		{
			neighbour = findradius(head.origin, 300);
			
			while(neighbour)
			{
				if(neighbour.classname == "waypoint" && neighbour != head)
				{
					//dprint("new other\n");
					local float other_free = get_free_link(neighbour);
					if(other_free != -1)
					{
						tracebox(head.origin, '-16 -16 0', '16 16 16', neighbour.origin, 0, head);
						if(trace_fraction == 1)
						{
							//dprint(strcat("endpos: ",vtos(trace_endpos),"\n"));
							//dprint(strcat("link: ", vtos(head.origin), ", ", vtos(neighbour.origin),"\n"));
							head.link[self_free] = neighbour;
							neighbour.link[other_free] = head;
							self_free = get_free_link(head);
						}
						//else
							//dprint("tracebox failed\n");
	
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
	//print("done linking\n");
}

// put this to defs or something and set it to
// 0 in worldspawn() before calling load_waypoints
float waypoints_loading;

// moved to global to keep file reference for
// longer than a single func call, put into defs
float wp_filehandle;

// call this once in worldspawn() after setting
// waypoints_loading to 0.
// Then somewhere in StartFrame() you need to do:
// "if(waypoints_loading == 1) load_waypoints();"
void() load_waypoints =
{
	// don't open file again on later calls
	if(waypoints_loading == 0)
		wp_filehandle = fopen(strcat("waypoints/", mapname), FILE_READ);
	
	// keep track of new waypoints added per frame
	local float counter = 0;
	 
	if(wp_filehandle == -1)
	{
		dprint("error reading waypoints\n");
		// mark this to be done to make sure it's not called again
		waypoints_loading = -1;
		return;
	}
	
	local string line = fgets(wp_filehandle);
	while(line)
	{
		// replace 10 with highest number that doesn't crash ))
		if(counter > 10)
		{
			// 1 means still loading, continue next frame/tick
			waypoints_loading = 1;
			return;
		}
		
		local vector pos = stov(line);
		if(pos)
			add_waypoint(pos);
		line = fgets(wp_filehandle);
		counter++;
	}
	link_waypoints();
	fclose(filehandle);
	
	// we're done here, don't continue next time
	waypoints_loading = -1;
}


//-------------------------------------------------------------------------
//		LINKED LIST STUFF FOR OPEN/CLOSED SET
//-------------------------------------------------------------------------

void() clear_closedset =
{
	local entity iter = closedset_first.set_next;
	if(closedset_first != world)
		closedset_first.inset = 0;
	closedset_first = world;
	while(iter != world)
	{
		iter.inset = 0;
		iter.set_prev.set_next = world;
		iter.set_prev = world;
		iter = iter.set_next;
	}
	if(closedset_first != world)
		closedset_last.inset = 0;
	closedset_last = world;
}


void() clear_openset =
{
	local entity iter = openset_first.set_next;
	if(openset_first != world)
		openset_first.inset = 0;
	openset_first = world;
	while(iter != world)
	{
		iter.inset = 0;
		iter.set_prev.set_next = world;
		iter.set_prev = world;
		iter = iter.set_next;
	}
	if(openset_last != world)
		openset_last.inset = 0;
	openset_last = world;
}


void(entity node) closedset_remove =
{
	local entity iter = closedset_first;
	while(iter != world)
	{
		if(iter == node)
		{
			if(iter == closedset_first && iter == closedset_last)
			{
				closedset_first = closedset_last = world; 
			}
			else if(iter == closedset_first)
			{
				closedset_first = iter.set_next;
				iter.set_next.set_prev = world;
			}
			else if(iter == closedset_last)
			{
				closedset_last = iter.set_prev;
				iter.set_prev.set_next = world;
			}
			else
			{
				node.set_next.set_prev = node.set_prev;
				node.set_prev.set_next = node.set_next;
			}
			node.set_next = node.set_prev = world;
			node.inset = 0;
			return;
		}
		iter = iter.set_next;
	}
	dprint("tried to remove non-closedset node from closedset\n");
}


void(entity node) openset_remove =
{
	local entity iter = openset_first;
	while(iter != world)
	{
		if(iter == node)
		{
			if(iter == openset_first && iter == openset_last)
			{
				openset_first = openset_last = world; 
			}
			else if(iter == openset_first)
			{
				openset_first = iter.set_next;
				iter.set_next.set_prev = world;
			}
			else if(iter == openset_last)
			{
				openset_last = iter.set_prev;
				iter.set_prev.set_next = world;
			}
			else
			{
				node.set_next.set_prev = node.set_prev;
				node.set_prev.set_next = node.set_next;
			}
			node.set_next = node.set_prev = world;
			node.inset = 0;
			return;
		}
		iter = iter.set_next;
	}
	dprint("tried to remove non-openset node from openset\n");
}


void(entity node) closedset_add =
{
	if(node.inset & S_CLOSED)
		return;
	if(node.inset & S_OPEN)
		openset_remove(node);
	
	if(closedset_first == world)
	{
		closedset_first = node;
		closedset_last = node;
		node.set_next = node.set_prev = world;
	}
	else
	{
		closedset_last.set_next = node;
		node.set_prev = closedset_last;
		closedset_last = node;
	}
	
	node.inset = S_CLOSED;
}


void(entity node) openset_add =
{
	if(node.inset & S_OPEN)
		return;
	if(node.inset & S_CLOSED)
		closedset_remove(node);
	
	if(openset_first == world)
	{
		openset_first = node;
		openset_last = node;
		node.set_next = node.set_prev = world;
	}
	else
	{
		openset_last.set_next = node;
		node.set_prev = openset_last;
		openset_last = node;
	}
	
	node.inset = S_OPEN;
}


//-------------------------------------------------------------------------
//				A* PATHFINDING
//-------------------------------------------------------------------------

entity(entity ent) closest_visible_node =
{
	local entity head, best;
	local float dist, tempd;
	dist = 32000;
	best = world;
	head = find(world, classname, "waypoint");
	
	while(head != world)
	{
		tempd = vlen(head.origin - ent.origin);
		if(tempd < dist)
		{
			traceline(ent.origin, head.origin, MOVE_NOMONSTERS, ent);
			if(trace_fraction == 1)
			{
				dist = tempd;
				best = head;
			}
		}
		head = find(head, classname, "waypoint");
	}
	if(best == world)
		dprint("can't see nodes\n");
	
	return best;
}

void(entity start, entity end) pathfind =
{
	//closest_visible_node has failed us, let's not waste time here
	if(start == world || end == world)
		return;
	
	//clear some stuff first
	clear_openset();
	clear_closedset();
	
	openset_add(start);
	start.path_prev = world;
	start.path_next = world;
	end.path_prev = world;
	end.path_next = world;
	start.g_score = 0;
	start.f_score = start.g_score + vlen(start.origin - end.origin);
	
	local entity current = world;
	local float bestf, i;
	local entity iter;
	
	while(openset_first != world)
	{
		iter = openset_first;
		bestf = 32000;
	
		//set current as the node in openset with lowest f_score
		while(iter != world)
		{
			if(iter.f_score < bestf)
			{
				current = iter;
				bestf = iter.f_score;
			}
			iter = iter.set_next;
		}
	
		//done with this node itself
		closedset_add(current);
		
		//we found a path
		if(current == end)
		{
			current.path_next = world;
			while(current != world)
			{
				if(current.path_prev == world)
				{
					return;
				}
				current.path_prev.path_next = current;
				current = current.path_prev;
			}
		}
		
		//local entity test1, test2;
		//update the values/sets of the neighbours
		for(i = 0; i < 4; i++)
		{
			iter = current.link[i];
			if(!(iter.inset & S_CLOSED) && iter != world)
			{
				bestf = current.g_score + vlen(iter.origin - current.origin);
				if(!(iter.inset & S_OPEN) || (bestf < iter.g_score))
				{
					iter.path_prev = current;
					iter.g_score = bestf;
					iter.f_score = bestf + vlen(iter.origin - end.origin);
	
					if(!(iter.inset & S_OPEN))
						openset_add(iter);
				}
			}
		}
	}
	//no path found if we're here
	local float shit = current.inset;
	start.path_next = world;
}
