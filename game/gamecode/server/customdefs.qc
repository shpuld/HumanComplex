.float crouching;

.float inset;
.float g_score;
.float f_score;
.entity link[4];
.entity path_prev;
.entity path_next;
.entity set_next;
.entity set_prev;
entity openset_first;
entity openset_last;
entity closedset_first;
entity closedset_last;

const float S_OPEN = 1;
const float S_CLOSED = 2;


.void() aiattack;
.void() aithink;
.float ainextthink;
.float alertness;
.float alert_cooldown;
.vector lastseen;
.vector lastseen2;
.vector movetarget;
.entity pathfind_goal;
.float targetreached;
.float lastpath;
.float pathdone;
.entity home;
.float onpatrol;
.float movespeed;
.float anim_cooldown;
.float moveshoot;

.float takedamage;
.float attack_finished;
.float hearable;

.void() die;