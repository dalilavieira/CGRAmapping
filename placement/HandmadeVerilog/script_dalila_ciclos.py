import sys
import os
import math
from numpy import binary_repr


n_lines = 256
final_list = []
out = open("r.txt", 'w')

#res_chebyshev0.txt

for i in range(101): 
    e_a = []
    e_b = []
    grid = []
    pos_x = []
    pos_y = []

    os.system("cat res_"+sys.argv[1]+str(i)+".txt")
    name = sys.argv[1]+"_"+str(i)+".in"

    print(name)
    #Cria arquivo edgeData.txt e inicializa e_a/e_b
    arquivo_in = open(name, 'r')
    arquivo_out = open('edgeData.txt', 'w')
    i = 0
    for linha in arquivo_in:
        print(linha)
