%option noyywrap

%{
  #include <stdlib.h>
  #include <stdio.h>
  
  int n_tags_open = 0;
  int n_tags_close = 0;
  int n_elem_simple = 0;
  int n_elem_empty = 0;
  int n_elem_attributs = 0;
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
    n_elem_attributs++; 
    n_tags_open++; 
    n_tags_close++; 
    printf("Elem con atributo\n");
}

{apertura_simple}{texto}{cierre} {
    n_elem_simple++; 
    n_tags_open++; 
    n_tags_close++; 
    printf("Elem simple\n");
}

{tag_apertura_atributo}{cierre} {
    n_elem_attributs++; 
    n_elem_empty++;
    n_tags_open++; 
    n_tags_close++;
    printf("Elem con atributo y vacio\n");
 }

{apertura_simple}{cierre} {
    n_elem_empty++;
    n_tags_open++; 
    n_tags_close++; 
    printf("Elem vacio\n");
}

{tag_apertura_atributo}               {n_tags_open++; printf("Tag apertura atributo\n");}
{espacio}+                            {printf("Espacio, tab, enter\n");}
{texto}                               {printf("Texto\n");}
{apertura_simple}                     {n_tags_open++; printf("Apertura simple\n");}

{cierre} {
    n_tags_close++; 
    printf("Cierre\n");
}

{atributo}                  {printf("Atributo\n");}

%%

int main(int argc, char **argv) {
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
    }
    yylex();
    printf("Numero de tags de apertura %i\n", n_tags_open);
    printf("Numero de tags de cierre %i\n", n_tags_close);
    printf("Numero de elementos simples %i\n", n_elem_simple);
    printf("Numero de elementos vacios %i\n", n_elem_empty);
    printf("Numero de elementos con atributos %i\n", n_elem_attributs);
}
