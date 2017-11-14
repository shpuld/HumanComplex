const float ANC_TOP_L = 0;
const float ANC_TOP_C = 1;
const float ANC_TOP_R = 2;
const float ANC_MID_L = 3;
const float ANC_MID_C = 4;
const float ANC_MID_R = 5;
const float ANC_BOT_L = 6;
const float ANC_BOT_C = 7;
const float ANC_BOT_R = 8;

void(vector pos, string str, vector scl, vector col, float alp, float anc, optional float flg) drawjustifiedstring =
{
	switch(anc)
	{
		case ANC_TOP_L:
			drawstring([pos_x, pos_y, 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_TOP_C:
			drawstring([pos_x - (scl_x / 2)*strlen(str), pos_y, 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_TOP_R:
			drawstring([pos_x - (scl_x)*strlen(str), pos_y, 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_L:
			drawstring([pos_x, pos_y - (scl_y / 2), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_C:
			drawstring([pos_x - (scl_x / 2)*strlen(str), pos_y - (scl_y / 2), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_R:
			drawstring([pos_x - (scl_x)*strlen(str), pos_y  - (scl_y / 2), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_L:
			drawstring([pos_x, pos_y - (scl_y), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_C:
			drawstring([pos_x - (scl_x / 2)*strlen(str), pos_y - (scl_y), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_R:
			drawstring([pos_x - (scl_x)*strlen(str), pos_y  - (scl_y), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		default:
			dprint("drawjustifiedstring: invalid anchor\n");
			break;
	}
}

void(vector pos, string str, vector scl, vector col, float alp, float anc, optional float flg) drawjustifiedpic =
{
	switch(anc)
	{
		case ANC_TOP_L:
			drawpic([pos_x, pos_y, 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_TOP_C:
			drawpic([pos_x - (scl_x / 2), pos_y, 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_TOP_R:
			drawpic([pos_x - (scl_x), pos_y, 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_L:
			drawpic([pos_x, pos_y - (scl_y / 2), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_C:
			drawpic([pos_x - (scl_x / 2), pos_y - (scl_y / 2), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_R:
			drawpic([pos_x - (scl_x), pos_y  - (scl_y / 2), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_L:
			drawpic([pos_x, pos_y - (scl_y), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_C:
			drawpic([pos_x - (scl_x / 2), pos_y - (scl_y), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_R:
			drawpic([pos_x - (scl_x), pos_y  - (scl_y), 0], str, [scl_x, scl_y, 0], col, alp, flg);
			break;
		default:
			dprint("drawjustifiedpic: invalid anchor\n");
			break;
	}
}


void(vector pos, vector scl, vector col, float alp, float anc, optional float flg) drawjustifiedfill =
{
	switch(anc)
	{
		case ANC_TOP_L:
			drawfill([pos_x, pos_y, 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_TOP_C:
			drawfill([pos_x - (scl_x / 2), pos_y, 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_TOP_R:
			drawfill([pos_x - (scl_x), pos_y, 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_L:
			drawfill([pos_x, pos_y - (scl_y / 2), 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_C:
			drawfill([pos_x - (scl_x / 2), pos_y - (scl_y / 2), 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_MID_R:
			drawfill([pos_x - (scl_x), pos_y  - (scl_y / 2), 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_L:
			drawfill([pos_x, pos_y - (scl_y), 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_C:
			drawfill([pos_x - (scl_x / 2), pos_y - (scl_y), 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		case ANC_BOT_R:
			drawfill([pos_x - (scl_x), pos_y  - (scl_y), 0], [scl_x, scl_y, 0], col, alp, flg);
			break;
		default:
			dprint("drawjustifiedfill: invalid anchor\n");
			break;
	}
}