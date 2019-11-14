-module(tp4).
-compile(export_all).

powerset([]) -> [[]];
powerset([H|T]) -> PT = powerset(T),
  [ [H|X] || X <- PT ] ++ PT.


reflexividad(Alfa,[]) -> ok;
reflexividad(Alfa,F) ->
  Fun = fun(X) -> X /= [] end,
  PA = lists:filtermap(Fun,powerset(Alfa)),
  %% Arreglar list member
  [ {Alfa,X}   || X <- PA , lists:member({Alfa,X}, F) == false  ].

start() -> 
  R = ['A','B','C'],
  F = [ {['A','B'],['E','F']} , {['E','F'],['C']}],

  % Sacamos la lista vacía.
  Partes_list = [X || X <- powerset(R), X /= [] ],

  Resultado = F,
  V = [reflexividad(X,Resultado) || X <- Partes_list].
