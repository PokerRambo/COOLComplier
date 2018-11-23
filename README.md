# COOL-Complier
This repo is used to record my progress in Stanford CS143 compiler.

#### 2018-11-07 Lexer finished! Full Score(63/63).

Attention: Before making your lexer, delete c-syntax block comment in rules section, or it will prompt "Unrecognized rule ..." ERROR, and do not leave blank lines which will cause some trouble locating errors.

Advice: Test-driven development is strongly recommended for this assignment!

#### 2018-11-11 Parser finished! Full Score(70/70).

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

#### 2018-11-15 Semantic Analyzer finished! Full Score(74/74).

Hints: 

Type Environment propagates downward from root in AST, while Type check upward from leaf.

Carefully deal with SELF_TYPE and self, the semantic return type can be SELF_TYPE, if and only if the body-expression's semantic analysis result is SELF_TYPE. 

Use symbol table to manage object environment. Remember the methods name can be same with attributes, so it's better build another data structure as method environment. Actually I didn't construct an independent structure to store methods, instead, I simply add a function to search in every class whenever needed.

I have edited 4 files: 

+ cool-tree.h: add attr_symbols_ to Class_ phylum, it is used to store attributes in each class.(Because attributes in different class can have the same name, one symbol table is not enough)
+ cool-tree.handcode.h: add some attributes and methods  as macro to help semantic analysis. What an ugly style the support code is！
+ semant.h: the most important data structure, ClassTable.
+ semant.cc: actual semantic analysis implementation.

To get more information, please refer to COOL handbook.

 #### 2018-11-23 Code Generation finished. All tests passed.

Because of hardcoding relative path in spim executable file, the grading script does not work. I've checking all the cases' output by hand and comfirm that  the  cgen passed all tests. 

The error message :

```
5c5
< Loaded: /usr/class/cs143/cool/lib/trap.handler
---
> Loaded: ../lib/trap.handler
```

PA5 reference: https://github.com/skyzluo/CS143-Compilers-Stanford/tree/master/PA5