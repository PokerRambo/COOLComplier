# COOL-Complier
This repo is used to record my progress in Stanford CS143 compiler.

2018-11-07 Lexer finished! Full Score(63/63).

Attention: Before making your lexer, delete c-syntax block comment in rules section, or it will prompt "Unrecognized rule ..." ERROR, and do not leave blank lines which will cause some trouble locating errors.

Advice: Test-driven development is strongly recommended for this assignment!

2018-11-11 Parser finished! Full Score(70/70).

Attention: Use pseudo-token 'error' and macro 'yyerrok' carefully, the former may introduce a lot of reduce-reduce conflicts, and the latter may lead to wrong error message!

 Here is something still confused me: when I define a non terminator named **optional_assign** 

```c
let         : OBJECTID ':' TYPEID optional_assign IN expression
                     {  $$ = let($1, $3, $4, $6); }
            | OBJECTID ':' TYPEID optional_assign  ',' let
                     {  $$ = let($1, $3, $4, $6); }    
            | error ',' 
		       { yyerrok; }

optional_assign  :  /* empty  */
                         { $$ = no_expr(); }
                     | ASSIGN expression
		                {  $$ = $2; }
                     ;
```

and use it in **let** statement, the parser just can't catch the meaningful line number.

But if I rewrite the code in an explicit way, the specifications just work fine.

```c
let         : OBJECTID ':' TYPEID IN expression
                     {  $$ = let($1, $3, no_expr(), $5); }
                | OBJECTID ':' TYPEID ASSIGN expression IN expression
		            { $$ = let($1, $3, $5, $7); }
                | OBJECTID ':' TYPEID  ',' let
                     {  $$ = let($1, $3, no_expr(), $5); }
                | OBJECTID ':' TYPEID ASSIGN expression ',' let
		             {  $$ = let($1, $3, $5, $7); }
                | error ',' 
		       { yyerrok; }
                ;
```

