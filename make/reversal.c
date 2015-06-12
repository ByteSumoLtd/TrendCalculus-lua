#include <stdio.h>
#include <stdlib.h>
 
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

int main(int argc, char **argv)
{
   int status;
   lua_State *L = luaL_newstate();
   luaL_openlibs(L);

   /* I will push the commandline args to lua before requiring the linked tcalc code */
   /* hopefully this sets the global args in lua, so they are picked by by pl.lapp ok */


   lua_newtable(L);  /* I create a table on the stack for lua */
   /* now I populate the stack with args from argv, later I call the table args" */
   for (int a = 0; a < argc; a++) {
      lua_pushnumber(L, a);
      lua_pushfstring(L, argv[a], "%s");
      lua_settable(L, -3);
   }
   lua_setglobal(L, "arg");
   /* now the   args table should be set in env L */


   /* lua_getglobal pushes the name of the function to run, which is tcalc the lua prog*/
   lua_getglobal(L, "require");
   lua_pushliteral(L, "reversal");

   status = lua_pcall(L, 1, 0, 0);
   if (status) {
      fprintf(stderr, "Error: %s\n", lua_tostring(L, -1));
      return 1;
   }

   return 0;
}
