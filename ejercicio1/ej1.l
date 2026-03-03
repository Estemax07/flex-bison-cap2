%option noyywrap yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct bufstack {
  struct bufstack *prev;
  YY_BUFFER_STATE bs;
  int lineno;
  char *filename;
  FILE *f;
} *curbs = 0;

char *curfilename = 0;

int newfile(char *fn) {
  FILE *f = fopen(fn, "r");
  if(!f) {
    perror(fn);
    return 0;
  }

  struct bufstack *n = malloc(sizeof(*n));
  if(!n) { perror("malloc"); exit(1); }

  n->prev = curbs;
  n->bs = YY_CURRENT_BUFFER;
  n->lineno = yylineno;
  n->filename = curfilename;
  n->f = yyin;

  curbs = n;

  yyin = f;
  yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));

  yylineno = 1;
  curfilename = fn;

  return 1;
}

int popfile(void) {
  if(!curbs) return 0;

  fclose(yyin);
  yy_delete_buffer(YY_CURRENT_BUFFER);

  struct bufstack *p = curbs;
  curbs = p->prev;

  yyin = p->f;
  yy_switch_to_buffer(p->bs);

  yylineno = p->lineno;
  curfilename = p->filename;

  free(p);
  return 1;
}
%}

%%
^#[ \t]*include[ \t]*[\"<][^\n]*\n {
  char name[512];
  int i = 0;

  char *p = yytext;
  while(*p && *p != '<' && *p != '"') p++;
  if(*p == '<' || *p == '"') p++;

  while(*p && *p != '>' && *p != '"' && *p != ' ' && *p != '\t' && *p != '\n') {
    if(i < (int)sizeof(name) - 1) name[i++] = *p;
    p++;
  }
  name[i] = '\0';

  if(!newfile(strdup(name))) yyterminate();
}

^[^#\n][^\n]*\n                  { fputs(yytext, stdout); }

^#[^\n]*\n                       { fputs(yytext, stdout); }

<<EOF>>                          { if(!popfile()) yyterminate(); }

.                                { fputc(yytext[0], stdout); }
%%

int main(int argc, char **argv) {
  if(argc > 1) {
    curfilename = strdup(argv[1]);
    if(!newfile(strdup(argv[1]))) return 1;
  } else {
    curfilename = "(stdin)";
  }
  yylex();
  return 0;
}
