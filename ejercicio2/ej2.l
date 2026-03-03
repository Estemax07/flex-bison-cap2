%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <strings.h>

#define NHASH 1009

struct symbol {
  char *name;
  int count;
};

static struct symbol symtab[NHASH];

static unsigned symhash(const char *s) {
  unsigned int h = 0;
  unsigned c;
  while ((c = (unsigned char)*s++)) {
    h = h * 9 ^ (unsigned)tolower(c);
  }
  return h;
}

static struct symbol *lookup(const char *s) {
  struct symbol *sp = &symtab[symhash(s) % NHASH];
  int scount = NHASH;

  while (--scount >= 0) {
    if (sp->name && !strcasecmp(sp->name, s)) return sp;
    if (!sp->name) {
      sp->name = strdup(s);
      sp->count = 0;
      return sp;
    }
    if (++sp >= symtab + NHASH) sp = symtab;
  }

  fprintf(stderr, "symbol table overflow\n");
  exit(1);
}

static int cmp_syms(const void *a, const void *b) {
  const struct symbol *sa = *(const struct symbol * const *)a;
  const struct symbol *sb = *(const struct symbol * const *)b;
  return strcasecmp(sa->name, sb->name);
}
%}

%%
[A-Za-z]+   { lookup(yytext)->count++; }
[ \t\r\n]+  { }
.           { }
%%

int main(void) {
  yylex();

  struct symbol **list = malloc(NHASH * sizeof(*list));
  int n = 0;

  for (int i = 0; i < NHASH; i++) {
    if (symtab[i].name) list[n++] = &symtab[i];
  }

  qsort(list, n, sizeof(*list), cmp_syms);

  for (int i = 0; i < n; i++) {
    printf("%s\t%d\n", list[i]->name, list[i]->count);
    free(list[i]->name);
  }

  free(list);
  return 0;
}
