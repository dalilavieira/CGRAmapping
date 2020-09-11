import sys
import os
import math
import random
from numpy import binary_repr

name = sys.argv[1]

e_a = []
e_b = []
grid = []
pos_x = []
pos_y = []
cic_arestas = []
benchs = ['chebyshev', 'mibench', 'poly5', 'poly6', 'poly8', 'qspline', 'sgfilter']
grid_size = rand_width = n_edge = 0
#soma_cic = 0
seed = int(random.randrange(1, 157925920365361))
n_lines = 256

#Atualiza os parametros do testbench
for bench in benchs:
    if bench in name:
        if bench == 'chebyshev':
            grid_size = 4
            rand_width = 3
            n_edge = 19
        elif bench == 'mibench':
            grid_size = 6
            rand_width = 3
            n_edge = 32
        elif bench == 'poly5':
            grid_size = 7
            rand_width = 3
            n_edge = 60
        elif bench == 'poly6':
            grid_size = 11
            rand_width = 4
            n_edge = 125
        elif bench == 'poly8':
            grid_size = 9
            rand_width = 4
            n_edge = 83
        elif bench == 'qspline':
            grid_size = 9
            rand_width = 4
            n_edge = 85
        elif bench == 'sgfilter':
            grid_size = 6
            rand_width = 3
            n_edge = 42

#Recebe as linhas do testbench.v
verilog = open("testbench.v", 'r')
linhas = verilog.readlines()
verilog.close()

#Realiza as alteracoes de acordo com o benchmark recebido
linhas[2] = "    parameter grid_size = " + str(grid_size) + ",\n"
linhas[3] = "    parameter rand_width = " + str(rand_width) + ",\n"
linhas[29] = "    seed = " + str(seed) + ";\n"
linhas[30] = "    n_edge = " + str(n_edge) + ";\n"
verilog = open("testbench.v", 'w')
for i in range(len(linhas)):
    verilog.write(linhas[i])
verilog.close()

#Cria arquivo edgeData.txt e inicializa e_a/e_b
arquivo_in = open(name+'.in', 'r')
arquivo_out = open('edgeData.txt', 'w')
i = 0
for linha in arquivo_in:
    if i == 0:
        linha = linha.split(" ")
        nodes = int(linha[0])
        edges = int(linha[1])
    if i < 2:
        i = i + 1 
    elif i == 2:
        linha = linha.split(" ")
        a = int(linha[0])
        b = int(linha[1])
        e_a.append(a)
        e_b.append(b)
        a = binary_repr(a, width=8)
        b = binary_repr(b, width=8)
        arquivo_out.write(str(b) + str(a) + '\n')
arquivo_in.close()
count = n_lines - edges
for j in range(count):
    arquivo_out.write("0000000000000000\n")
arquivo_out.close()
print("Arquivo edgeData.txt criado com sucesso!")
print

#Incializa pos_x/pos_y e grid
n = int(math.ceil(math.sqrt(nodes)))
for i in range(nodes):
    pos_x.append(0)
    pos_y.append(0)
for i in range(n):
    grid.append([])
for lista in grid:
    for j in range(n):
        lista.append(-1)

#Executa o verilog
print("RUNNING Verilog")
os.system("iverilog testbench.v -o testbench.vvp")
os.system("vvp testbench.vvp > temp.txt")
print

#Escreve todos os resultados em result_nome_do_arquivo.txt
arquivo_in = open("temp.txt", 'r')
arquivo_out = open("result_" + name + ".txt", 'w')
saida = arquivo_in.readlines()
if saida[len(saida)-6] == "No solution\n":
    arquivo_out.write("No solution!\n")
else:
    i = 0
    cost_mesh = cost_1hop = ciclos = 0
    for linha in saida:
        if"(" in linha:
            cic_arestas.append(linha)
            #linha = linha.split(":")
            #linha[1].replace(" ", "")
            #soma_cic = soma_cic + int(linha[1])
        else:
            if i < nodes:
                linha = linha.split(":")
                node = int(linha[0])
                pos = linha[1].split(",")
                x = int(pos[0])
                y = int(pos[1])
                pos_x[node] = x
                pos_y[node] = y
                grid[x][y] = node
            if i == nodes + 1:
                linha = linha.split(":")
                cost_mesh = int(linha[1])
            if i == nodes + 2:
                linha = linha.split(":")
                cost_1hop = int(linha[1])
            if i == nodes + 3:
                linha = linha.split(":")
                ciclos = int(linha[1]) - (2 * edges) - 8
            i = i + 1

    arquivo_out.write("Grid:\n")
    for linha in grid:
        row = ''
        for j in range(len(linha)):
            row += str(linha[j]) + ' '
        arquivo_out.write(row+'\n')
    arquivo_out.write('\n')
    arquivo_out.write("Custo Mesh: " + str(cost_mesh) + '\n')
    arquivo_out.write("Custo 1-hop: " + str(cost_1hop) + '\n')
    arquivo_out.write("Ciclos: " + str(ciclos) + '\n')
    arquivo_out.write('\n')
    arquivo_out.write("Ciclos/Estados por aresta:" + '\n')
    for aresta in cic_arestas:
        arquivo_out.write(aresta)
    #arquivo_out.write("Total: " + str(soma_cic) + '\n')    
    arquivo_out.write('\n')
    arquivo_out.write("Custo por aresta - mesh:" + '\n')
    soma = 0
    for i in range(edges):
        a = e_a[i]
        b = e_b[i]

        diff_pos_x = pos_x[a]-pos_x[b]
        if diff_pos_x < 0:
            diff_pos_x = diff_pos_x * -1
        
        diff_pos_y = pos_y[a]-pos_y[b]
        if diff_pos_y < 0:
            diff_pos_y = diff_pos_y * -1

        cost = diff_pos_x + diff_pos_y - 1
        soma += cost
        arquivo_out.write("(" + str(a) + "," + str(b) + ")" + ": " + str(cost) + '\n')
    arquivo_out.write('\n')
    arquivo_out.write("Custo por aresta - 1hop:" + '\n')
    for i in range(edges):
        a = e_a[i]
        b = e_b[i]

        diff_pos_x = pos_x[a]-pos_x[b]
        if diff_pos_x < 0:
            diff_pos_x = diff_pos_x * -1
        
        diff_pos_y = pos_y[a]-pos_y[b]
        if diff_pos_y < 0:
            diff_pos_y = diff_pos_y * -1
        
        cost_1hop = ((diff_pos_x >> 1) + diff_pos_x%2) + ((diff_pos_y >> 1) + diff_pos_y%2) - 1
        arquivo_out.write("(" + str(a) + "," + str(b) + ")" + ": " + str(cost_1hop) + '\n')
arquivo_in.close()
arquivo_out.close()
print("Arquivo de saida gerado com sucesso!")