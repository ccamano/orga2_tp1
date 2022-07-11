#include "lib.h"

funcCmp_t* getCompareFunction(type_t t) {
    switch (t) {
        case TypeInt:      return (funcCmp_t*)&intCmp; break;
        case TypeString:   return (funcCmp_t*)&strCmp; break;
        case TypeCard:     return (funcCmp_t*)&cardCmp; break;
        default: break;
    }
    return 0;
}
funcClone_t* getCloneFunction(type_t t) {
    switch (t) {
        case TypeInt:      return (funcClone_t*)&intClone; break;
        case TypeString:   return (funcClone_t*)&strClone; break;
        case TypeCard:     return (funcClone_t*)&cardClone; break;
        default: break;
    }
    return 0;
}
funcDelete_t* getDeleteFunction(type_t t) {
    switch (t) {
        case TypeInt:      return (funcDelete_t*)&intDelete; break;
        case TypeString:   return (funcDelete_t*)&strDelete; break;
        case TypeCard:     return (funcDelete_t*)&cardDelete; break;
        default: break;
    }
    return 0;
}
funcPrint_t* getPrintFunction(type_t t) {
    switch (t) {
        case TypeInt:      return (funcPrint_t*)&intPrint; break;
        case TypeString:   return (funcPrint_t*)&strPrint; break;
        case TypeCard:     return (funcPrint_t*)&cardPrint; break;
        default: break;
    }
    return 0;
}


/** Array **/

void  arrayPrint(array_t* a, FILE* pFile) {

    type_t t = a->type;
    uint8_t n = a->size;
    funcPrint_t* print_t = getPrintFunction(t);
    fprintf(pFile, "[");  
    for (int i = 0; i < n; i++){
        void* dato = arrayGet(a,i);
        print_t(dato, pFile);
        if (i !=n-1){
            fprintf(pFile, ",");
        }
    }
    fprintf(pFile, "]");
}

/** Lista **/

void listAddLast(list_t* l, void* data){
    type_t t = l->type;
    uint8_t n = l->size;
    funcClone_t* datoClonado = getCloneFunction(t);
    struct s_listElem* p = malloc(sizeof(struct s_listElem));
    p->data = (void*)(datoClonado(data));
    p->next = 0;
    if(n==0){
        p->prev = 0;
        l->first = p;
        l->last = p;
        l->size++;
        return;
    }
    struct s_listElem* actual = l->first;
    for(int i = 0; i < n-1; i++){ //quiero llegar al ultimo elem
        actual = actual->next; //paso al sig
    }
    p->prev = actual;
    actual->next = p;
    l->size++;
    return;
}   

void listPrint(list_t* l, FILE* pFile) {
    type_t t = l->type;                              //obtengo el type
    uint8_t n = l->size;                             //obtengo la cantidad de elems de la lista
    struct s_listElem* actual = l->first;            //obtengo el primer nodo
    funcPrint_t* print_t = getPrintFunction(t);      //obtengo el print del tipo

    fprintf(pFile, "[");     //file ya está abierto
    for(int i = 0; i < n; i++){
        void* dato = actual->data;  //obtengo el dato que tiene el elem
        print_t(dato, pFile);       //aca uso el fprint del int,string,card
        actual = actual->next;      //avanzo al siguiente
        if (i != n-1){
            fprintf(pFile, ",");
        }
    }
    fprintf(pFile, "]");      //usuario en main debe cerrar el file
    
}


/** Game **/

game_t* gameNew(void* cardDeck, funcGet_t* funcGet, funcRemove_t* funcRemove, funcSize_t* funcSize, funcPrint_t* funcPrint, funcDelete_t* funcDelete) {
    game_t* game = (game_t*)malloc(sizeof(game_t));
    game->cardDeck = cardDeck;
    game->funcGet = funcGet;
    game->funcRemove = funcRemove;
    game->funcSize = funcSize;
    game->funcPrint = funcPrint;
    game->funcDelete = funcDelete;
    return game;
}
int gamePlayStep(game_t* g) {
    int applied = 0;
    uint8_t i = 0;
    while(applied == 0 && i+2 < g->funcSize(g->cardDeck)) {
        card_t* a = g->funcGet(g->cardDeck,i);
        card_t* b = g->funcGet(g->cardDeck,i+1);
        card_t* c = g->funcGet(g->cardDeck,i+2);
        if( strCmp(cardGetSuit(a), cardGetSuit(c)) == 0 || intCmp(cardGetNumber(a), cardGetNumber(c)) == 0 ) {
            card_t* removed = g->funcRemove(g->cardDeck,i);
            cardAddStacked(b,removed);
            cardDelete(removed);
            applied = 1;
        }
        i++;
    }
    return applied;
}
uint8_t gameGetCardDeckSize(game_t* g) {
    return g->funcSize(g->cardDeck);
}
void gameDelete(game_t* g) {
    g->funcDelete(g->cardDeck);
    free(g);
}
void gamePrint(game_t* g, FILE* pFile) {
    g->funcPrint(g->cardDeck, pFile);
}
