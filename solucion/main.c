#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"


int main (void){   


  printf("Se imprime todo en main_test.txt.\n");

	int32_t valor1 = 1;
    int32_t *uno = &valor1;
    int32_t valor2 = 2;
    int32_t *dos = &valor2;
    int32_t valor3 = 3;
    int32_t *tres = &valor3;
	int32_t valor4 = 4;
    int32_t *cuatro = &valor4;
    int32_t valor5 = 5;
    int32_t *cinco = &valor5;
	
	
	
    card_t* poke1 = cardNew("pichu",uno);
    card_t* poke2 = cardNew("pikachu",dos);
    card_t* poke3 = cardNew("torchic", tres);
	card_t* poke4 = cardNew("togepi", cuatro);
	card_t* poke5 = cardNew("charizard", cinco);
	card_t* poke6 = cardNew("ditto", cuatro);
	card_t* poke7 = cardNew("mew", dos);


	FILE *fp;
    fp = fopen("main_test.txt","w");

	//test lista



  fprintf(fp, "Tests de Lista: \n");

	list_t* lista1 = listNew(TypeCard);
	listAddFirst(lista1,poke1);
	listAddFirst(lista1,poke2);
	listAddFirst(lista1,poke3);
	listAddFirst(lista1,poke4);
	listAddFirst(lista1,poke5);

	listPrint(lista1,fp);
	fprintf(fp, "<- Lista de 5 cartas.\n");

	card_t* carta_get = listGet(lista1, 1);

	cardPrint(carta_get,fp); 
	fprintf(fp, "<- Carta a la que le agregare un stack. \n");
	card_t* carta_removed = listRemove(lista1, 3);
	cardPrint(carta_removed,fp);
	fprintf(fp, "<- Esta carta remuevo. \n" );
	cardAddStacked(carta_get,carta_removed);
	listPrint(lista1,fp);
	fprintf(fp, "<- Lista con carta apilada. \n");



	cardDelete(carta_removed);
	listDelete(lista1);



	//test array

	fprintf(fp, "\n" );
	fprintf(fp, "\n" );
	
	fprintf(fp, "Tests de Array: \n");

	array_t* array1 = arrayNew(TypeCard,5);
	arrayAddLast(array1,poke1);
	arrayAddLast(array1,poke4);
	arrayAddLast(array1,poke5);
	arrayAddLast(array1,poke3);
	arrayAddLast(array1,poke2);
	arrayAddLast(array1,poke6);
	arrayPrint(array1,fp);
	fprintf(fp, "<-Array de 5 cartas.\n");

	card_t* carta2 = arrayGet(array1, 2);
	cardPrint(carta2,fp);
	fprintf(fp, "<- Carta a la que le agregare un stack. \n");
	card_t* carta3 = arrayRemove(array1,3);
	cardPrint(carta3,fp);
	fprintf(fp, "<- Esta carta remuevo. \n" );
	
	cardAddStacked(carta2,carta3);
	arrayPrint(array1,fp);
	fprintf(fp, "<- Array con carta apilada. \n");
	arrayDelete(array1);
	cardDelete(carta3);

	//delete cartas

	cardDelete(poke1);
	cardDelete(poke2);
	cardDelete(poke3);
	cardDelete(poke4);
	cardDelete(poke5);
	cardDelete(poke6);
	cardDelete(poke7);


	fclose(fp);

}


