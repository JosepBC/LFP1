%option noyywrap

%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  
  int n_tags_open = 0;
  int n_tags_close = 0;
  int n_elem_simple = 0;
  int n_elem_empty = 0;
  int n_elem_attributs = 0;

  char tags_iguales(char *yytext) {
    char *yytext_copy = (char*)calloc(sizeof(yytext), sizeof(char));
    strcpy(yytext_copy, yytext);
    char *t = strtok(yytext, "<"); //Eliminem <
    char *open_name = strtok(t, " >"); //Ens quedem amb el que hi havia entre < i > o el primer espai, per si hi ha atributs

    char *close = strtok(yytext_copy, "</");
    close = strtok(NULL, "</"); //Agafem el tag que tanca tag>
    char *close_name = strtok(close, ">"); //Eliminem el > i ens quedem amb nomes el tag
    int cmp = strcmp(open_name, close_name);
    free(yytext_copy);
    return cmp == 0; //Si son iguals strcmp retorna 0
  }
%}

nombre_tag              [a-zA-Z0-9_]
espacio                 [" "\t\n]
apertura_simple         <{nombre_tag}+>
cierre                  <\/{nombre_tag}+>
texto                   [^<>'"&]+
valor_atributo          [^<>'"&\n]
atributo                {nombre_tag}+{espacio}*={espacio}*(\"{valor_atributo}*\"|'{valor_atributo}*')
tag_apertura_atributo   <{nombre_tag}+({espacio}+{atributo})+{espacio}*> 
tag_apertura            ({tag_apertura_atributo}|{apertura_simple})

%%
{tag_apertura_atributo}{texto}{cierre} {
    n_tags_open++; 
    n_tags_close++; 
    //printf("Elem con atributo: %s\n", yytext);

    if(tags_iguales(yytext)) n_elem_attributs++; 
}

{apertura_simple}{texto}{cierre} {
    n_tags_open++; 
    n_tags_close++; 

    //printf("Elem simple: %s\n", yytext);
    if(tags_iguales(yytext)) n_elem_simple++; 
}

{tag_apertura_atributo}{cierre} {
    n_tags_open++; 
    n_tags_close++;
    
    //printf("Elem con atributo y vacio: %s\n", yytext);
    if(tags_iguales(yytext)) {
        n_elem_attributs++; 
        n_elem_empty++;
    }
 }

{apertura_simple}{cierre} {
    n_tags_open++; 
    n_tags_close++; 
    
    //printf("Elem vacio: %s\n", yytext);
    if(tags_iguales(yytext)) n_elem_empty++;
}

{tag_apertura} {
    n_tags_open++;
    //printf("Tag abertura: %s\n", yytext);
}

{cierre} {
    n_tags_close++; 
    //printf("Cierre\n");
}

{espacio}+ {}

. {}

%%

int main(int argc, char **argv) {
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
    }
    yylex();
    printf("Numero de tags de apertura: %i\n", n_tags_open);
    printf("Numero de tags de cierre: %i\n", n_tags_close);
    printf("Numero de elementos simples: %i\n", n_elem_simple);
    printf("Numero de elementos vacios: %i\n", n_elem_empty);
    printf("Numero de elementos con atributos: %i\n", n_elem_attributs);
}
