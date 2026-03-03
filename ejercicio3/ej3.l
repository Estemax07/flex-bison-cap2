%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <strings.h>

struct symbol {
  char *name;
  int count;
};

struct symtab {
  struct symbol *tab;
  size_t size;
  size_t used;
};

static struct symtab ST = {0};

static unsigned symhash(const char *s) {
  unsigned int h = 0;
  unsigned c;
  while ((c = (unsigned char)*s++)) {
    h = h * 9 ^ (unsigned)tolower(c);
  }
  return h;
}

static void st_init(size_t initial) {
  ST.size = initial;
  ST.used = 0;
  ST.tab = calloc(ST.size, sizeof(*ST.tab));
  if (!ST.tab) { perror("calloc"); exit(1); }
}

static void st_grow(void);

static struct symbol *st_lookup(const char *s) {
  if (!ST.tab) st_init(1021);

  if (ST.used * 10 >= ST.size * 7) st_grow();

  size_t idx = symhash(s) % ST.size;

  for (size_t tries = 0; tries < ST.size; tries++) {
    struct symbol *sp = &ST.tab[idx];

    if (sp->name && !strcasecmp(sp->name, s)) return sp;

    if (!sp->name) {
      sp->name = strdup(s);
      sp->count = 0;
      ST.used++;
      return sp;
    }

    idx = (idx + 1) % ST.size;
  }

  st_grow();
  return st_lookup(s);
}

static void st_grow(void) {
  struct symbol *old = ST.tab;
  size_t oldsz = ST.size;

  ST.size = ST.size * 2 + 1;
  ST.used = 0;
  ST.tab = calloc(ST.size, sizeof(*ST.tab));
  if (!ST.tab) { perror("calloc"); exit(1); }

  for (size_t i = 0; i < oldsz; i++) {
    if (!old[i].name) continue;

    size_t idx = symhash(old[i].name) % ST.size;
    while (ST.tab[idx].name) idx = (idx + 1) % ST.size;

    ST.tab[idx] = old[i];
    ST.used++;
  }

  free(old);
}

static int cmp_syms(const void *a, const void *b) {
  const struct symbol *sa = *(const struct symbol * const *)a;
  const struct symbol *sb = *(const struct symbol * const *)b;
  return strcasecmp(sa->name, sb->name);
}
%}

%%
[A-Za-z0-9]+   { st_lookup(yytext)->count++; }
[ \t\r\n]+     { }
.              { }
%%

int main(void) {
  yylex();

  struct symbol **list = malloc(ST.used * sizeof(*list));
  size_t n = 0;

  for (size_t i = 0; i < ST.size; i++) {
    if (ST.tab[i].name) list[n++] = &ST.tab[i];
  }

  qsort(list, n, sizeof(*list), cmp_syms);

  for (size_t i = 0; i < n; i++) {
    printf("%s\t%d\n", list[i]->name, list[i]->count);
  }

  for (size_t i = 0; i < ST.size; i++) free(ST.tab[i].name);
  free(ST.tab);
  free(list);
  return 0;
}
