
// %skeleton "lalr1.cc" /* -*- C++ -*- */
%language "c++"
%require "3.0"

%define api.value.type variant
%define api.token.constructor
%define api.namespace { sqf::sqc::bison }
%code top {
    #include "tokenizer.h"
    #include <string>
    #include <vector>
}

%code requires
{
     namespace sqf::sqc::bison
     {
          enum class astkind
          {
               NA = 0,
               RETURN,
               THROW,
               ASSIGNMENT,
               DECLARATION,
               FORWARD_DECLARATION,
               FUNCTION_DECLARATION,
               FUNCTION,
               ARGLIST,
               CODEBLOCK,
               IF,
               IFELSE,
               FOR,
               FORSTEP,
               FOREACH,
               WHILE,
               DOWHILE,
               TRYCATCH,
               SWITCH,
               CASE,
               CASE_DEFAULT,
               OP_TERNARY,
               OP_OR,
               OP_AND,
               OP_EQUALEXACT,
               OP_EQUAL,
               OP_NOTEQUALEXACT,
               OP_NOTEQUAL,
               OP_LESSTHAN,
               OP_GREATERTHAN,
               OP_LESSTHANEQUAL,
               OP_GREATERTHANEQUAL,
               OP_PLUS,
               OP_MINUS,
               OP_MULTIPLY,
               OP_DIVIDE,
               OP_REMAINDER,
               OP_NOT,
               OP_BINARY,
               OP_UNARY,
               VAL_STRING,
               VAL_ARRAY,
               VAL_NUMBER,
               VAL_TRUE,
               VAL_FALSE,
               VAL_NIL,
               GET_VARIABLE
          };
          struct astnode
          {
               sqf::sqc::tokenizer::token token;
               astkind kind;
               std::vector<astnode> children;

               astnode() : token(), kind(astkind::NA) {}
               astnode(astkind kind) : token(), kind(kind) {}
               astnode(sqf::sqc::tokenizer::token t) : token(t), kind(astkind::NA) {}
               astnode(astkind kind, sqf::sqc::tokenizer::token t) : token(t), kind(kind) {}

               void append(astnode node) { children.push_back(node); }
               void append_children(const astnode& other) { for (auto node : other.children) { append(node); } }
          };
     }
}
%code
{
     namespace sqf::sqc::bison
     {
          // Return the next token.
          parser::symbol_type yylex (sqf::sqc::tokenizer&);
     }
}

%lex-param { sqf::sqc::tokenizer &tokenizer }
%parse-param { sqf::sqc::tokenizer &tokenizer }
%parse-param { sqf::sqc::bison::astnode result }
%locations
%define parse.trace
%define parse.error verbose

%define api.token.prefix {}


/* Tokens */

%token NA 0
%token RETURN                    "return"
%token THROW                     "throw"
%token LET                       "let"
%token BE                        "be"
%token FUNCTION                  "function"
%token IF                        "if"
%token ELSE                      "else"
%token FROM                      "from"
%token TO                        "to"
%token STEP                      "step"
%token WHILE                     "while"
%token DO                        "do"
%token TRY                       "try"
%token CATCH                     "catch"
%token SWITCH                    "switch"
%token CASE                      "case"
%token DEFAULT                   "default"
%token NIL                       "nil"
%token TRUE                      "true"
%token FALSE                     "false"
%token FOR                       "for"
%token PRIVATE                   "private"
%token COLON                     ":"
%token CURLYO                    "{"
%token CURLYC                    "}"
%token ROUNDO                    "("
%token ROUNDC                    ")"
%token SQUAREO                   "["
%token SQUAREC                   "]"
%token SEMICOLON                 ";"
%token COMMA                     ","
%token PLUS                      "+"
%token MINUS                     "-"
%token LTEQUAL                   "<="
%token LT                        "<"
%token GTEQUAL                   ">="
%token GT                        ">"
%token EQUALEQUALEQUAL           "==="
%token EQUALEQUAL                "=="
%token EXCLAMATIONMARKEQUALEQUAL "!=="
%token EXCLAMATIONMARKEQUAL      "!="
%token EXCLAMATIONMARK           "!"
%token EQUAL                     "="
%token ANDAND                    "&&"
%token SLASH                     "/"
%token STAR                      "*"
%token PERCENT                   "%"
%token QUESTIONMARK              "?"
%token VLINEVLINE                "||"
%token DOT                       "."

%token <tokenizer::token> NUMBER 
%token <tokenizer::token> IDENT  
%token <tokenizer::token> STRING 

%type <sqf::sqc::bison::astnode> statements statement assignment vardecl funcdecl function
%type <sqf::sqc::bison::astnode> funchead arglist codeblock if for while trycatch switch
%type <sqf::sqc::bison::astnode> caselist case exp01 exp02 exp03 exp04 exp05 exp06 exp07
%type <sqf::sqc::bison::astnode> exp08 exp09 expp value array explist

%start start

%%

/*** BEGIN - Change the grammar rules below ***/
/*** BEGIN - Change the grammar rules below ***/
/*** BEGIN - Change the grammar rules below ***/
start: %empty     
     | statements                                 { result = $1; }
     ;

statements: statement                             { $$ = {}; $$.append($1); }
          | statement statements                  { $$ = {}; $$.append($1); $$.append_children($2); }
          ;

statement: "return" exp01 ";"                     { $$ = { astkind::RETURN }; $$.append($2); }
         | "return" ";"                           { $$ = { astkind::RETURN }; }
         | "throw" exp01 ";"                      { $$ = { astkind::THROW }; $$.append($2); }
         | vardecl ";"                            { $$ = $1; }
         | funcdecl                               { $$ = $1; }
         | if                                     { $$ = $1; }
         | for                                    { $$ = $1; }
         | while                                  { $$ = $1; }
         | trycatch                               { $$ = $1; }
         | switch                                 { $$ = $1; }
         | assignment                             { $$ = $1; }
         | exp01 ";"                              { $$ = $1; }
         | ";"                                    { $$ = {}; }
         | error                                  { $$ = {}; }
         ;

assignment: IDENT "=" exp01                       { $$ = { astkind::ASSIGNMENT }; $$.append($1); $$.append($3); }
          ;

vardecl: "let" IDENT "=" exp01                    { $$ = { astkind::DECLARATION }; $$.append($2); $$.append($4); }
       | "let" IDENT "be" exp01                   { $$ = { astkind::DECLARATION }; $$.append($2); $$.append($4); }
       | "let" IDENT ";"                          { $$ = { astkind::FORWARD_DECLARATION }; $$.append($2); }
       | "private" IDENT "=" exp01                { $$ = { astkind::DECLARATION }; $$.append($2); $$.append($4); }
       | "private" IDENT "be" exp01               { $$ = { astkind::DECLARATION }; $$.append($2); $$.append($4); }
       | "private" IDENT ";"                      { $$ = { astkind::FORWARD_DECLARATION }; $$.append($2); }
       ;

funcdecl: "function" IDENT funchead codeblock     { $$ = { astkind::FUNCTION_DECLARATION }; $$.append($2); $$.append($3); $$.append($4); }
        ;

function: "function" funchead codeblock           { $$ = { astkind::FUNCTION }; $$.append($2); $$.append($3); }
        ;

funchead: "(" ")"                                 { $$ = { astkind::ARGLIST }; }
        | "(" arglist ")"                         { $$ = { astkind::ARGLIST }; $$.append_children($2); }
        ;

arglist: IDENT                                    { $$ = {}; $$.append($1); }
       | IDENT ","                                { $$ = {}; $$.append($1); }
       | IDENT "," arglist                        { $$ = {}; $$.append($1); $$.append_children($3); }
       ;

codeblock: statement ";"                          { $$ = { astkind::CODEBLOCK }; $$.append($1); }
         | "{" "}"                                { $$ = { astkind::CODEBLOCK }; }
         | "{" statements "}"                     { $$ = { astkind::CODEBLOCK }; $$.append_children($2); }
         ;

if: "if" "(" exp01 ")" codeblock                  { $$ = { astkind::IF }; $$.append($3); $$.append($5); }
  | "if" "(" exp01 ")" codeblock "else" codeblock { $$ = { astkind::IFELSE }; $$.append($3); $$.append($5); $$.append($7); }
  ;

for: "for" IDENT "from" exp01 "to" exp01 codeblock                { $$ = { astkind::FOR }; $$.append($2); $$.append($4); $$.append($6); $$.append($7); }
   | "for" IDENT "from" exp01 "to" exp01 "step" exp01 codeblock   { $$ = { astkind::FORSTEP }; $$.append($2); $$.append($4); $$.append($6); $$.append($8); $$.append($9); }
   | "for" "(" IDENT ":" exp01 ")" codeblock                      { $$ = { astkind::FOREACH }; $$.append($3); $$.append($5); $$.append($7); }
   ;

while: "while" "(" exp01 ")" codeblock                    { $$ = { astkind::WHILE }; $$.append($3); $$.append($5); }
     | "do" codeblock "while" "(" exp01 ")"               { $$ = { astkind::DOWHILE }; $$.append($2); $$.append($5); }
     ;

trycatch: "try" codeblock "catch" "(" IDENT ")" codeblock { $$ = { astkind::TRYCATCH }; $$.append($2); $$.append($5); $$.append($7); }
        ;

switch: "switch" "(" exp01 ")" "{" caselist "}"           { $$ = { astkind::SWITCH }; $$.append($3); $$.append_children($6); }
      ;

caselist: case                        { $$ = {}; $$.append($1); }
        | case caselist               { $$ = {}; $$.append($1); $$.append_children($2); }
        ;

case: "case" exp01 ":" codeblock      { $$ = { astkind::CASE }; $$.append($2); $$.append($4); }
    | "case" exp01 ":"                { $$ = { astkind::CASE }; $$.append($2); }
    | "default" ":" codeblock         { $$ = { astkind::CASE_DEFAULT }; $$.append($3); }
    ;

exp01: exp02                          { $$ = $1; }
     | exp02 "?" exp01 ":" exp01      { $$ = { astkind::OP_TERNARY }; $$.append($1); $$.append($3); $$.append($5); }
     ;
exp02: exp03                          { $$ = $1; }
     | exp03 "||" exp01               { $$ = { astkind::OP_OR }; $$.append($1); $$.append($3); }
     ;
exp03: exp04                          { $$ = $1; }
     | exp04 "&&" exp01               { $$ = { astkind::OP_AND }; $$.append($1); $$.append($3); }
     ;
exp04: exp05                          { $$ = $1; }
     | exp05 "===" exp01              { $$ = { astkind::OP_EQUALEXACT }; $$.append($1); $$.append($3); }
     | exp05 "!==" exp01              { $$ = { astkind::OP_NOTEQUALEXACT }; $$.append($1); $$.append($3); }
     | exp05 "==" exp01               { $$ = { astkind::OP_EQUAL }; $$.append($1); $$.append($3); }
     | exp05 "!=" exp01               { $$ = { astkind::OP_NOTEQUAL }; $$.append($1); $$.append($3); }
     ;
exp05: exp06                          { $$ = $1; }
     | exp06 "<"  exp01               { $$ = { astkind::OP_LESSTHAN }; $$.append($1); $$.append($3); }
     | exp06 "<=" exp01               { $$ = { astkind::OP_LESSTHANEQUAL }; $$.append($1); $$.append($3); }
     | exp06 ">"  exp01               { $$ = { astkind::OP_GREATERTHAN }; $$.append($1); $$.append($3); }
     | exp06 ">=" exp01               { $$ = { astkind::OP_GREATERTHANEQUAL }; $$.append($1); $$.append($3); }
     ;
exp06: exp07                          { $$ = $1; }
     | exp07 "+" exp01                { $$ = { astkind::OP_PLUS }; $$.append($1); $$.append($3); }
     | exp07 "-" exp01                { $$ = { astkind::OP_MINUS }; $$.append($1); $$.append($3); }
     ;
exp07: exp08                          { $$ = $1; }
     | exp08 "*" exp01                { $$ = { astkind::OP_MULTIPLY }; $$.append($1); $$.append($3); }
     | exp08 "/" exp01                { $$ = { astkind::OP_DIVIDE }; $$.append($1); $$.append($3); }
     | exp08 "%" exp01                { $$ = { astkind::OP_REMAINDER }; $$.append($1); $$.append($3); }
     ;
exp08: exp09                          { $$ = $1; }
     | "!" exp09                      { $$ = { astkind::OP_NOT }; $$.append($2);  }
     ;
exp09: expp                           { $$ = $1; }
     | expp "." IDENT "(" explist ")" { $$ = { astkind::OP_BINARY }; $$.append($1); $$.append($3); $$.append($5); }
     ;

expp: "(" exp01 ")"                   { $$ = $2; }
    | IDENT "(" explist ")"           { $$ = { astkind::OP_UNARY }; $$.append($1); $$.append($3); }
    | value                           { $$ = $1; }
    ;
value: function                       { $$ = $1; }
     | STRING                         { $$ = { astkind::VAL_STRING, $1 }; }
     | array                          { $$ = $1; }
     | NUMBER                         { $$ = { astkind::VAL_NUMBER, $1 }; }
     | "true"                         { $$ = { astkind::VAL_TRUE }; }
     | "false"                        { $$ = { astkind::VAL_FALSE }; }
     | "nil"                          { $$ = { astkind::VAL_NIL }; }
     | IDENT                          { $$ = { astkind::GET_VARIABLE, $1 }; }
     ;
array: "[" "]"                        { $$ = { astkind::VAL_ARRAY }; }
     | "[" explist "]"                { $$ = { astkind::VAL_ARRAY }; $$.append_children($2); }
     ;
explist: exp01                        { $$ = {}; $$.append($1); }
       | exp01 ","                    { $$ = {}; $$.append($1); }
       | exp01 "," explist            { $$ = {}; $$.append($1); $$.append_children($3); }
       ;

%%

namespace sqf::sqc::bison
{
     inline parser::symbol_type yylex (sqf::sqc::bison::tokenizer& tokenizer)
     {
         auto token = tokenizer.next();
         parser::location_type loc;
         loc.begin.line = token.line;
         loc.begin.column = token.column;
         loc.end.line = token.line;
         loc.end.column = token.column + token.contents.length();

         switch (token.type)
         {
         case tokenizer::etoken::eof: return parser::make_NA(loc);
         case tokenizer::etoken::invalid: return yylex(tokenizer);
         case tokenizer::etoken::i_comment_line: return yylex(tokenizer);
         case tokenizer::etoken::i_comment_block: return yylex(tokenizer);
         case tokenizer::etoken::i_whitespace: return yylex(tokenizer);

         case tokenizer::etoken::t_return: return parser::make_RETURN(loc);
         case tokenizer::etoken::t_throw: return parser::make_THROW(loc);
         case tokenizer::etoken::t_let: return parser::make_LET(loc);
         case tokenizer::etoken::t_be: return parser::make_BE(loc);
         case tokenizer::etoken::t_function: return parser::make_FUNCTION(loc);
         case tokenizer::etoken::t_if: return parser::make_IF(loc);
         case tokenizer::etoken::t_else: return parser::make_ELSE(loc);
         case tokenizer::etoken::t_from: return parser::make_FROM(loc);
         case tokenizer::etoken::t_to: return parser::make_TO(loc);
         case tokenizer::etoken::t_step: return parser::make_STEP(loc);
         case tokenizer::etoken::t_while: return parser::make_WHILE(loc);
         case tokenizer::etoken::t_do: return parser::make_DO(loc);
         case tokenizer::etoken::t_try: return parser::make_TRY(loc);
         case tokenizer::etoken::t_catch: return parser::make_CATCH(loc);
         case tokenizer::etoken::t_switch: return parser::make_SWITCH(loc);
         case tokenizer::etoken::t_case: return parser::make_CASE(loc);
         case tokenizer::etoken::t_default: return parser::make_DEFAULT(loc);
         case tokenizer::etoken::t_nil: return parser::make_NIL(loc);
         case tokenizer::etoken::t_true: return parser::make_TRUE(loc);
         case tokenizer::etoken::t_false: return parser::make_FALSE(loc);
         case tokenizer::etoken::t_for: return parser::make_FOR(loc);
         case tokenizer::etoken::t_private: return parser::make_PRIVATE(loc);

         case tokenizer::etoken::s_curlyo: return parser::make_CURLYO(loc);
         case tokenizer::etoken::s_curlyc: return parser::make_CURLYC(loc);
         case tokenizer::etoken::s_roundo: return parser::make_ROUNDO(loc);
         case tokenizer::etoken::s_roundc: return parser::make_ROUNDC(loc);
         case tokenizer::etoken::s_edgeo: return parser::make_SQUAREO(loc);
         case tokenizer::etoken::s_edgec: return parser::make_SQUAREC(loc);
         case tokenizer::etoken::s_equalequalequal: return parser::make_EQUALEQUALEQUAL(loc);
         case tokenizer::etoken::s_equalequal: return parser::make_EQUALEQUAL(loc);
         case tokenizer::etoken::s_equal: return parser::make_EQUAL(loc);
         case tokenizer::etoken::s_greaterthenequal: return parser::make_GTEQUAL(loc);
         case tokenizer::etoken::s_greaterthen: return parser::make_GT(loc);
         case tokenizer::etoken::s_lessthenequal: return parser::make_LTEQUAL(loc);
         case tokenizer::etoken::s_lessthen: return parser::make_LT(loc);
         case tokenizer::etoken::s_plus: return parser::make_PLUS(loc);
         case tokenizer::etoken::s_minus: return parser::make_MINUS(loc);
         case tokenizer::etoken::s_notequalequal: return parser::make_EXCLAMATIONMARKEQUALEQUAL(loc);
         case tokenizer::etoken::s_notequal: return parser::make_EXCLAMATIONMARKEQUAL(loc);
         case tokenizer::etoken::s_exclamationmark: return parser::make_EXCLAMATIONMARK(loc);
         case tokenizer::etoken::s_percent: return parser::make_PERCENT(loc);
         case tokenizer::etoken::s_star: return parser::make_STAR(loc);
         case tokenizer::etoken::s_slash: return parser::make_SLASH(loc);
         case tokenizer::etoken::s_andand: return parser::make_ANDAND(loc);
         case tokenizer::etoken::s_oror: return parser::make_VLINEVLINE(loc);
         case tokenizer::etoken::s_questionmark: return parser::make_QUESTIONMARK(loc);
         case tokenizer::etoken::s_colon: return parser::make_COLON(loc);
         case tokenizer::etoken::s_semicolon: return parser::make_SEMICOLON(loc);
         case tokenizer::etoken::s_comma: return parser::make_COMMA(loc);
         case tokenizer::etoken::s_dot: return parser::make_DOT(loc);

         case tokenizer::etoken::t_string: return parser::make_STRING(token, loc);
         case tokenizer::etoken::t_ident: return parser::make_IDENT(token, loc);
         case tokenizer::etoken::t_number: return parser::make_NUMBER(token, loc);
         default:
             return parser::make_NA(loc);
         }
     }
}