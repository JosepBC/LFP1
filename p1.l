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
{tag_apertura_atributo}     {printf("Tag apertura atributo\n");}
{texto}                     {printf("Texto\n");}
{apertura_simple}           {printf("Apertura simple\n");}
{cierre}                    {printf("Cierre\n");}
{atributo}                  {printf("Atributo\n");}
{espacio}+                  {printf("Espacio, tab, enter\n");}

%%

int main(int argc, char **argv) {
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
    }
    yylex();
}
