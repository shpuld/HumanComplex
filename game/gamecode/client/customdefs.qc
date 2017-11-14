//Various globals that are used in this FTEQW example are defined here, they are not used by the engine itself

//#pragma warning disable Q302
vector cursor_pos; /* Current mouse cursor position, updated in csqc_inputevent */
float g_width, g_height; /* Globals for screen width and height */

float walk;
//Menu stuff
float in_menu; //what menu are we in
float time_in_menu;
float camlerp;
float crouching;
float dmgflash;
float missioncomplete;
float tuttime;
string tutstring;

.vector oldangles;

entity player;

.entity link[4];

const float MENU_NONE = 0;
const float MENU_MAIN = 1;
const float MENU_SINGLE = 2;
const float MENU_MULTI = 4;
const float MENU_SETTINGS = 8;
const float MENU_ABOUT = 16;
const float MENU_JOIN = 32;
const float MENU_GAMEOVER = 64;