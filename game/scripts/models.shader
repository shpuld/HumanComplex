additive
{
	cull disable
	{
		map $diffuse
		blendFunc GL_SRC_ALPHA GL_ONE
		rgbGen identity
		alphaGen entity
	}
}

laser
{
	//cull disable
	{
		map textures/laser
		blendFunc GL_SRC_ALPHA GL_ONE
		rgbGen identity
		alphaGen vertex
	}
}

muzzle
{
	nomipmap
	cull disable
	{
		map models/muzzle
		blendFunc GL_SRC_ALPHA GL_ONE
		rgbGen identity
		alphaGen entity
	}
}


bullet
{
	nomipmap
	{
		map $diffuse
		blendFunc GL_SRC_ALPHA GL_ONE
		rgbGen identity
		alphaGen entity
	}
}

vc
{
	program shaders/vcol.glsl
	{
		rgbGen entity
		alphaGen entity
	}
}

vc_cel
{
	//program shaders/vcol_cel.glsl
	{
		rgbGen entity
		alphaGen entity
	}
}

waypoint
{
	cull front
	deformVertexes autosprite
	{
		map textures/waypoint.tga
		rgbGen entity
		alphaGen entity
		blendfunc blend
	}
}

exit
{
	//cull front
	deformVertexes autosprite
	{
		map models/exit.tga
		rgbGen entity
		alphaGen entity
		blendfunc additive
	}
}


blood
{
	{
		map particles/blood.tga
		blendFunc blend
		rgbGen vertex
		alphaGen vertex
	}
}