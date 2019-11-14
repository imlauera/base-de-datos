## Algoritmo para calcular F+
Sea F un conjunto de dependencias funcionales definido sobre R. El cierre de F, denotado por F+
es el conjunto de todas las dependencias funcionales que F implica lógicamente. El siguiente
algoritmo escrito en pseudocódigo nos permite calcular F+. Éste se basa en los axiomas de Armstrong.
```
resultado := F;
for each a in P(R):
  aplicar las reglas de reflexividad a a;
  agregar las nuevas dependencias funcionales obtenidas a resultado;
while (hay cambios en resultado):
  for each DF f in resultado:
    aplicar las reglas de aumentatividad a f;
    agregar las nuevas DF obtenidas a resultado;
  for each DF f1 in resultado:
    for each DF f2 in resultado:
      if f1 y f2 pueden combinarse por transitivdad 
      then
        agregar la nueva DF a resultado;
return resultado;
```
### Ejemplo 
```
Sea R = (A,B,C,G,H,I) y  
F = {A -> B,A -> C,CG -> H, CG -> I, B -> H}  
Algunos miembros de F+ serán: A -> H  
```
## Algoritmo para calcular ![rightarrow](https://github.com/allikn0w/tbd/blob/master/TP4/img/alpha%2B.gif).  

Entrada: un conjunto F de DF y el conjunto ![rightarrow](https://github.com/allikn0w/tbd/blob/master/TP4/img/alpha.gif) de atributos.  
Salida: se almacena en la variable resultado.

```
resultado := a;
while(cambios en resultado):
  for each DF b -> c in F:  
      if B está en resultado 
      then
        resultado:=resultado lo uno con c;  
```

#### Ejemplo  tomando `resultado = AG`

La primera vez que ejecutamos el bucle while para probar cada DF encontramos que
- A ![rightarrow](https://github.com/allikn0w/tbd/blob/master/TP4/img/rightarrow.gif) B nos hace incluir B en resultado.
- A ![rightarrow](https://github.com/allikn0w/tbd/blob/master/TP4/img/rightarrow.gif) B está en F, A is in resultado(AG), por lo tanto resultado :=
resultado U B.
- A ![rightarrow](https://github.com/allikn0w/tbd/blob/master/TP4/img/rightarrow.gif) C hace que resultado se convierta en ABCG.
- CG ![rightarrow](https://github.com/allikn0w/tbd/blob/master/TP4/img/rightarrow.gif) H hace que resultado se convierta en ABCGH.
- CG ![rightarrow](https://github.com/allikn0w/tbd/blob/master/TP4/img/rightarrow.gif) I hace que resultado se converita en ABCGHI.
