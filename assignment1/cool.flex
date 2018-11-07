/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
int str_const_len = 0;
int comment_level = 0;


%}
%x LINE_COMMENT BLOCK_COMMENT STRING STRERROR
/*
 * Define names for regular expressions here.
 */
DARROW          =>
ASSIGN          <-
LE              <=
%%
\n             { curr_lineno++;}
[ \f\r\t\v]+   {}
"--"            { BEGIN  LINE_COMMENT; }
"(*"            { BEGIN BLOCK_COMMENT; }
"*)"            {
        cool_yylval.error_msg = "Umatched *)";
        return (ERROR);
}
<LINE_COMMENT>\n     {curr_lineno++; BEGIN 0;}
<BLOCK_COMMENT>\n    {curr_lineno++;}
<BLOCK_COMMENT>"(*"  { comment_level++;}
<BLOCK_COMMENT>"*)"  {
    if(comment_level == 0){
         BEGIN 0;
    }
    else{
        comment_level--;
    }
}
<BLOCK_COMMENT><<EOF>> {
        cool_yylval.error_msg = "EOF in comment";
        BEGIN 0;
        return (ERROR);
}
<LINE_COMMENT>.     {}
<BLOCK_COMMENT>.    {}
{DARROW}		{ return (DARROW); }
{ASSIGN}                { return (ASSIGN); }
{LE}                    { return (LE); }
"{"        { return '{';}
"}"        { return '}';}
"("        { return '(';}
")"        { return ')';}
"~"        { return '~';}
","        { return ',';}
";"        { return ';';}
":"        { return ':';}
"+"        { return '+';}
"-"        { return '-';}
"*"        { return '*';}
"/"        { return '/';}
"."        { return '.';}
"<"        { return '<';}
"="        { return '=';}
"@"        { return '@';}
(?i:class)        { return (CLASS);}
(?i:else)         { return (ELSE);}
(?i:fi)           { return (FI);}
(?i:if)           { return (IF);}
(?i:in)           { return (IN);}
(?i:inherits)     { return (INHERITS);}
(?i:isvoid)       { return (ISVOID);}
(?i:let)          { return (LET);}
(?i:loop)         { return (LOOP);}
(?i:pool)         { return (POOL);}
(?i:then)         { return (THEN);}
(?i:while)        { return (WHILE);}
(?i:case)         { return (CASE);}
(?i:esac)         { return (ESAC);}
(?i:new)          { return (NEW);}
(?i:of)           { return (OF);}
(?i:not)          { return (NOT);}
t[rR][uU][eE] {
    cool_yylval.boolean = 1;
    return (BOOL_CONST);
}
f[aA][lL][sS][eE]   {
    cool_yylval.boolean = 0;
    return (BOOL_CONST);
}
\"       { 
    memset(string_buf, 0, sizeof(string_buf));
    str_const_len = 0;
    BEGIN STRING;
}
<STRING><<EOF>> {
    cool_yylval.error_msg = "EOF in string constant";
    BEGIN 0;
    return (ERROR);
}
<STRING>\0   {
       BEGIN STRERROR;
       cool_yylval.error_msg = "String contains null character";
       return (ERROR);
}
<STRING>\\\0   {
       BEGIN STRERROR;
       cool_yylval.error_msg = "String contains escaped null character";
       return (ERROR);
}
<STRING>\\\n {
    curr_lineno++;
    if( str_const_len >= MAX_STR_CONST-1){
        cool_yylval.error_msg = "String constant too long";
        BEGIN 0;
        BEGIN STRERROR;
        return (ERROR);
    }
    string_buf[str_const_len++] = '\n';
}
<STRING>\n   {
    curr_lineno++;
    cool_yylval.error_msg = "Unterminated string constant";
    BEGIN 0;
    return (ERROR);
}
<STRING>\\.   {
    if ( str_const_len >= MAX_STR_CONST-1) {
         cool_yylval.error_msg = "String constant too long";
         BEGIN 0; 
         BEGIN STRERROR;
         return (ERROR);
    }
    switch(yytext[1]) {
        case '\"': string_buf[str_const_len++] = '\"'; break;
        case '\\': string_buf[str_const_len++] = '\\'; break;
        case 'b' : string_buf[str_const_len++] = '\b'; break;
        case 't' : string_buf[str_const_len++] = '\t'; break;
        case 'n' : string_buf[str_const_len++] = '\n'; break;
        case 'f' : string_buf[str_const_len++] = '\f'; break;
        case '0' : string_buf[str_const_len++] = '0';  break;
        default  : string_buf[str_const_len++] = yytext[1];
    }
}
<STRING>\"   {

   cool_yylval.symbol = stringtable.add_string(string_buf);
   memset(string_buf, 0, sizeof(string_buf));
   str_const_len = 0;
   BEGIN 0;
   return (STR_CONST);
}
<STRING>.    {
    if(str_const_len >= MAX_STR_CONST-1) {
        cool_yylval.error_msg = "String constant too long";
        BEGIN 0;
        BEGIN STRERROR;
        return (ERROR);
    }
    string_buf[str_const_len++] = yytext[0];
}
<STRERROR>\" { BEGIN 0;}
<STRERROR>\n { BEGIN 0;}
<STRERROR>.  {}
[0-9]+    {
    cool_yylval.symbol = inttable.add_string(yytext);
    return (INT_CONST);
}
[A-Z][A-Za-z0-9_]*  {
    cool_yylval.symbol = idtable.add_string(yytext);
    return (TYPEID);
}
[a-z][A-Za-z0-9_]*  {
    cool_yylval.symbol = idtable.add_string(yytext);
    return (OBJECTID);
}
.   {
   cool_yylval.error_msg = yytext;
   return (ERROR);
}
%%
