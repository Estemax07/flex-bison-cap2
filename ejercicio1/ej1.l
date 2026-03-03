%option noyywrap yylineno

%{
#include <stdio.h>
#include <string.h>
%}

%%
^#[ \t]*include[ \t]*[\"<][^ \t\n\">]+[\">][^\n]*\n {
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

  printf("INCLUDE encontrado (linea %d): %s\n", yylineno - 1, name);
}

^[^#\n][^\n]*\n {
  printf("LINEA normal %d: %s", yylineno - 1, yytext);
}

^#[^\n]*\n {
  printf("LINEA # (no include) %d: %s", yylineno - 1, yytext);
}

^[^\n]+ {
  printf("ULTIMA linea %d: %s\n", yylineno, yytext);
}
%%
int main(void) {
  yylex();
  return 0;
}
