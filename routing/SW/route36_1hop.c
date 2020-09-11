#include <stdio.h> 
#include <limits.h> 
#include "inputs.h"

//TODO: definir um valor pra INT_MAX, se der problemas cm limits.h
//TODO: fazer flag e remover exit(1)

#define V 400
#define TAM 20

int grid[V];

void bubble(int *ordena, int*a, int *b, int *jafoi){
	int aux1, aux2, aux3, aux4;
	for(int u=0; u<edges; u++){
		for(int v=0; v<edges; v++){
			if(ordena[u] < ordena[v]){
				aux1 = ordena[v];
				ordena[v] = ordena[u];
				ordena[u] =  aux1;

				aux2 = a[v];
				a[v] = a[u];
				a[u] = aux2;

				aux3 = b[v];
				b[v] = b[u];
				b[u] = aux3;
		
				aux4 = jafoi[v];
				jafoi[v] = jafoi[u];
				jafoi[u] = aux4;
			}
		}
	}
}

int printPath(int parent[], int j) 
{ 
//	PTAM += 1;
	// Base Case : If j is source 
	int contador = 0;

	while(parent[j] != -1){
		contador ++;
		//printf("%d ", j);
		//printf("%d\n",contador);
		j = parent[j];
	}

	return contador;
} 

int minDistance(int dist[], int sptSet[]) 
{ 
	
	// Initialize min value 
	int min = INT_MAX, min_index; 

	for (int v = 0; v < V; v++) 
		if (sptSet[v] == 0 && 
				dist[v] <= min) 
			min = dist[v], min_index = v; 

	return min_index; 
} 

int dijkstra(int graph[V][V], int src, int dest, int * parent) 
{ 
	int dist[V]; 
	int sptSet[V]; 

	for (int i = 0; i < V; i++) 
	{ 
		parent[src] = -1; 
		dist[i] = INT_MAX; 
		sptSet[i] = 0; 
	} 

	dist[src] = 0; 
 
	for (int count = 0; count < V - 1; count++) 
	{ 
		int u = minDistance(dist, sptSet); 

		sptSet[u] = 1; 
 
		for (int v = 0; v < V; v++) 
			if (!sptSet[v] && graph[u][v] && 
				dist[u] + graph[u][v] < dist[v]) 
			{ 
				parent[v] = u; 
				dist[v] = dist[u] + graph[u][v]; 
			} 
	} 

	return dist[dest];
} 

int main(){
	int ordena[edges];
	int FLAG = 0;
	int parent[V];

	int i,j;
	int m[V][V];

	int a[edges], b[edges];
	int A, B;

	int origem, destino;

	int entradas[V][4];
	int saidas[V][4];

	int ALU[V];
	int ALUREG[V];	
	int BYPASS[V];

	for (int j=0; j<TAM; j++){
		for (int i=0; i<TAM; i++){
			grid[j*TAM+i] = 255;
			if(i >= 5 && j >= 5 && i < 5+tam && j < 5+tam)
				grid[j*TAM+i] = place[(j-5)*tam+(i-5)];
		}
	}
	
	/*for (int j=0; j<TAM; j++){
		for (int i=0; i<TAM; i++){
			printf("%d ",grid[j*TAM+i]);

		}
		printf("\n");
	}*/

	//forma vetor de vertices de origem
	for (int j=0; j<edges; j++){
		for (int i=0; i<TAM*TAM; i++){
			if(e_a[j] == grid[i]){
				a[j] = i;
				//printf("II %d\n", e_ a[j]);
			}
		}
	}
	//printf("\n");
	for (int j=0; j<edges; j++){
		for (int i=0; i<TAM*TAM; i++){
			if(e_b[j] == grid[i]){
				b[j] = i;
				//printf("jj %d\n", i);
			}
		}
	}

	//TODO VERTICE USA ALU
	for (int j=0; j<edges; j++){
		ALU[b[j]] = 1;
		ALU[a[j]] = 1;
		//printf("%d %d\n", b[j], a[j]);
	}
	


	for(i=0; i<V; i++){
		//indice_e[i] = 0;
		//indice_s[i] = 0;
		//ALU[i] = 0;
		ALUREG[i] = 0;
		BYPASS[i] = 0;
		//printf("BYPASS %d = %d", i, BYPASS[i]);
		for(j=0; j<V; j++){
			m[i][j] = 0;
			//printf("%d",m);
		}
	}

	int peso = 100;
	for(i=0; i<TAM; i++){
		for(j=0; j<TAM; j++){
			if(i<TAM-1 & j<TAM-1){
				m[i*TAM+j][i*TAM+(j+1)] = peso; 
				m[i*TAM+(j+1)][i*TAM+j] = peso; 
				m[i*TAM+j][(i+1)*TAM+j] = peso; 
				m[(i+1)*TAM+j][i*TAM+j] = peso; 
			}else if(i<TAM-1){
				m[i*TAM+j][(i+1)*TAM+j] = peso; 
				m[(i+1)*TAM+j][i*TAM+j] = peso; 
			}else if(j<TAM-1){
				m[i*TAM+j][i*TAM+(j+1)] = peso; 
				m[i*TAM+(j+1)][i*TAM+j] = peso; 
			}
			if(i<TAM-2 & j<TAM-2){
				m[i*TAM+j][i*TAM+(j+2)] = peso; 
				m[i*TAM+(j+2)][i*TAM+j] = peso; 
				m[i*TAM+j][(i+2)*TAM+j] = peso; 
				m[(i+2)*TAM+j][i*TAM+j] = peso; 
			}else if(i<TAM-2){
				m[i*TAM+j][(i+2)*TAM+j] = peso; 
				m[(i+2)*TAM+j][i*TAM+j] = peso; 
			}else if(j<TAM-2){
				m[i*TAM+j][i*TAM+(j+2)] = peso; 
				m[i*TAM+(j+2)][i*TAM+j] = peso; 
			}
		}
	}

	int jafoi[edges];
	for(i=0; i<edges; i++)
		jafoi[i] = 0;

	for(i=0; i<edges; i++){
		A = a[i]; //origem no dataflow
		B = b[i]; //destino no dataflow

		//printf("A%d B%d",A,B);
		int ret = dijkstra(m, A, B, parent);
		//printf("\n");

		//printf("ret %d",ret);
		if(ret > V*1000 || ret < -V*1000 ){
			printf("distancia infinita no dijkstra\n");
			printf("DEU RUIM\n");
			//break;
			return 1;
		}

		int cont = printPath(parent, B);
		ordena[i] = cont;
		//printf("\n\n %d %d %d \n",cont, A, B);
		//PASSO1: faz roteamento trivial
		if(cont == 1){	
			jafoi[i] = 1;		
			j = 0;
			while(1){
				if(j ==0 ){
					destino = B;
				}else{
					destino = origem;
				}

				origem = parent[destino];
				if(origem == -1)
					break;

				//printf("origem=%d dest=%d\n",origem,destino);

				if(destino == origem-1){
					entradas[destino][0] = origem;
					saidas[origem][2] = destino;
				}else if(destino == origem-TAM){
					entradas[destino][1] = origem; 
					saidas[origem][3] = destino; 
				}else if(destino == origem+1){
					entradas[destino][2] = origem; 
					saidas[origem][0] = destino; 
				}else if(destino == origem+TAM){
					entradas[destino][3] = origem;
					saidas[origem][1] = destino;  
				}else{
					printf("DEU RUIM\n");
					FLAG = 1;
					//exit(1);
					break;
				}
				//aumenta peso das arestas que levam a esse mesmo destino, SE != ZERO
				for(int aux=0; aux<V;aux++)
					if(m[aux][destino] != 0)
						m[aux][destino]++;
				//marca ALU como usada
				ALU[destino] = 1; 
				//remove aresta usada
				//printf("\n od %d %d\n",origem,destino);
				m[origem][destino] = 0;

				j++;		
			}
			if(FLAG == 1)
				break;
			//printf("\n");
		}

	}

	//printf("INICIA PASSO 2\n");

	for(i=0; i<edges; i++){
		//ordena as arestas 
		bubble(ordena, a, b, jafoi);	
	
		//int flag_multicast = 0;
		//Não refazer dijkstra para arestas ja roteadas
		//printf("\nAi %d Bi %d foi %d i%d \n",a[i],b[i],jafoi[i], i);
		while(jafoi[i] == 1){ //|| a[i] == b[i]
			i++;
		}
		if(i >= edges)
			break;

		//printf("VALOR DE i %d a%d b%d jafoi%d\n", i,a[i],b[i],jafoi[i]);

		A = a[i]; //origem no dataflow
		B = b[i]; //destino no dataflow		

		//printf("A%d B%d",A,B);
		//printf("chaama dijkistra\n");
		int ret = dijkstra(m, A, B, parent);
		//printf("ret %d\n", ret);

		//printf("\n");
		if(ret > V*1000 || ret < -V*1000 ){
			printf("distancia infinita no dijkstra\n");
			printf("DEU RUIM\n");
			break;
		}

		int cont = printPath(parent, B);
		ordena[i] = cont;
		//printf("conta \n");
		//printf("\n");

		if(cont != 1){	
			j = 0;
			while(1){
				if(j == 0){
					destino = B;
				}else{
					destino = origem;
				}

				origem = parent[destino];

				if(origem == -1)
					break;

				//printf("origem=%d dest=%d\n",origem,destino);

				if(destino == origem-1){
					entradas[destino][0] = origem;
					saidas[origem][2] = destino;
				}else if(destino == origem-TAM){
					entradas[destino][1] = origem; 
					saidas[origem][3] = destino; 
				}else if(destino == origem+1){
					entradas[destino][2] = origem; 
					saidas[origem][0] = destino; 
				}else if(destino == origem+TAM){
					entradas[destino][3] = origem;
					saidas[origem][1] = destino;  
				}else{
					printf("DEU RUIM\n");
					FLAG = 1;
					//exit(1);
					break;
				}

					if(destino == B){
						//printf("dest e B \n");
						if(ALUREG[destino] == 1){
							printf("DEU RUIM B\n");
							FLAG = 1;
							break;
						}else
							ALU[destino] = 1;
					}else if(BYPASS[destino] == 0){
						BYPASS[destino] = 1;
					}else if(ALUREG[destino] == 0 && ALU[destino] == 0){
						ALUREG[destino] = 1;
					}
					else{
						printf("DEU RUIM bypassXalureg\n");
						FLAG = 1;
						break;
					}
				//}
					

				//aumenta peso das arestas que levam a esse mesmo destino
				for(int aux=0; aux<V;aux++)
					if(m[aux][destino] != 0)
						m[aux][destino]++;				 
				//remove aresta usada
				m[origem][destino] = 0;

				j++;		
			}

			if(FLAG == 1)
				break;
		}

	}


}




