#!/usr/bin/env python3
import argparse
import sys

def fdata(FileF_path):
  F = []
  with open(FileF_path,'r') as FileDP:
    for line in FileDP:
      for x in line.splitlines():
        F.append(tuple([ set(y.split(',')) for y in x.split('->') if y != [] ]))
  return F

def rdata(FileR_path):
  R = set([])
  with open(FileR_path,'r') as FileR:
    for line in FileR:
      for x in line.splitlines():
        R = R.union(x)
  return R

def PowerSet(A):
  if A == []: 
    yield []
  else:
    a = A[0]
    for tail in PowerSet(A[1:]):
      yield tail
      yield [a] + tail

def busqueda(alfa,fplus):
  for x,y in fplus:
    if x == alfa:
      yield (x,y)

''' F+ '''
def fmas(R,F): 
  RList = list(R)
  partes_list = [ x for x in PowerSet(RList) if x != [] ]

  fplus = F
  for alfa in partes_list:
    # Regla de reflexividad:
    PowersetAlfa = [ x for x in PowerSet(alfa) ]
    for y in PowersetAlfa:
      if y != []:
        if (set(alfa),set(y)) not in fplus:
          #print("Reflexividad({}) = {}".format(alfa,(alfa,y)))
          fplus.append((set(alfa),set(y)))

    NuevosCambios,ViejosCambios = 0,0
    while 1:
      for alfa,beta in fplus:
        for r in R:
          if (alfa.union(r),beta.union(r)) not in fplus:
            #print("Aumento({},{})={}".format((alfa,beta),r,(alfa.union(r),beta.union(r))))
            fplus.append((alfa.union(r),beta.union(r))) # ({A,C},{B,D})
            NuevosCambios += 1

        for gamma,delta in busqueda(beta,fplus):
          #print("Transitividad({},{})={}".format((alfa,beta),(gamma,delta),(alfa,delta)))
          if (alfa,delta) not in fplus:
            fplus.append((alfa,delta))
            NuevosCambios += 1

        sys.stdout.write("\rCalculando ... {0}".format(len(fplus)))
        sys.stdout.flush()
      
      if (ViejosCambios == NuevosCambios):
        break
      ViejosCambios = NuevosCambios

  return fplus


''' A+ '''
def ca(F,alfa):
  resultado = alfa

  ViejosCambios = len(resultado)
  while 1:
    for beta,gamma in F:
      if beta.issubset(resultado):
        resultado = resultado.union(gamma)

    if (ViejosCambios == len(resultado)):
      break
    ViejosCambios = len(resultado)

  return resultado

def clavescandidatas(R,F):
  RList = list(R)
  resultado = []
  max_len = 0

  partes_list = [ set(x) for x in PowerSet(RList) if x != [] ]
  # Lo ordenamos para que no tome conjuntos más grandes de superclaves.
  partes_list.sort(key=len)

  for item in partes_list:
    # Pruebo si el item de la lista si es una superclave.
    if (ca(F,item) == R and len(item)==1):
      resultado.append(item)

    elif (ca(F,item) == R):
      posible = True;

      partes_x = [set(x) for x in PowerSet(list(item)) if x != [] and x != list(item)]
      for x in partes_x:
        if ca(F,x) == R:
          posible = False;
      if posible == True:
        resultado.append(item)
        

  return resultado

def main():
  # Definimos los argumentos.
  parser = argparse.ArgumentParser()

  parser.add_argument('r_data',help='Archivo donde se encuentra el esquema de relaciones.')
  parser.add_argument('f_data',help='Archivo donde se encuentra el conjunto de dependencias funcionales.')

  parser.add_argument('-f',action='store_true',help='Calcular F+')
  parser.add_argument('-a',help='Calcular A+. Ejemplo de entrada: A,B')
  parser.add_argument('-ca',action='store_true',help='Calcula las claves candidatas')
  args = parser.parse_args()


  print("Entrada:")
  R = rdata(args.r_data)
  print("R: ",R)
  F = fdata(args.f_data)
  print("F: ",F)

  if args.f:
    print("\nCardinalidad final de F+: ",len(fmas(R,F)))
    print("")

  if args.a:
    alfa = set(args.a.split(','))
    print("Alfa: ",alfa)
    print("Alfa+: ",ca(F,alfa))

  if args.ca:
    print("")
    print("Claves candidatas obtenidas",clavescandidatas(R,F))


if __name__ == '__main__':
  main()
