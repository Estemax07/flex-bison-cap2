# Capítulo 2 - Flex

Este repositorio contiene la implementación de los ejercicios 1, 2 y 3 del Capítulo 2 del libro de Flex.

---

## Ejercicio 1

**Objetivo:**  
Procesar el archivo de entrada en "chunks" grandes (líneas completas) sin romper el reconocimiento de `#include`.

**Idea clave:**  
No se puede usar una regla general como `^.*\n` porque Flex elige el match más largo y capturaría también las líneas `#include`.  
Se implementó una regla específica para `#include` y reglas separadas para las demás líneas.

---

## Ejercicio 2

**Objetivo:**  
Modificar el programa de concordancia para que trate mayúsculas y minúsculas como la misma palabra.

**Cambios realizados:**
- En `symhash()` se usa `tolower()` para que el hash ignore el case.
- En `lookup()` se usa `strcasecmp()` para comparar palabras sin distinguir mayúsculas/minúsculas.

---

## Ejercicio 3

**Objetivo:**  
Evitar el overflow de la tabla hash cuando se llena.

**Solución implementada:**  
Se utilizó **rehashing**.  
Cuando la ocupación supera aproximadamente el 70%, se crea una tabla nueva más grande y se reinserta todo.

**¿Por qué no chaining?**  
Porque chaining genera listas enlazadas por bucket, lo que hace más complejo recorrer y ordenar los símbolos para la cross-reference.

---

## Compilación (macOS)

Ejemplo para cualquier ejercicio:

```bash
flex ejX.l
gcc lex.yy.c -o ejX
