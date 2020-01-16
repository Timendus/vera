%{

/**
 * ASMDOC tool v1.0 - Reference implementation for Vera coding standards
 * Copyright (C) 2007 The Vera Development Team
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

/**
 * Lex grammar definition
 */
%}

%START NAME DESCR AUTHORS PRE POST SEEALSO WARNING EXAMPLE FILEDESCR

Numbers						[0-9]
Characters					[a-zA-Z]
WhiteSpace					[ \t]
SpecialChars					[,.;:_='"(){}<>@$%^&*+\\\|/?!`~-]
NewLine						(\n|\r\n)

PrefixOnly					;;\ *
DocPrefix					{NewLine}{PrefixOnly}
ValidLabel					({Characters}|{Numbers}|[._])+
OneLine						({Characters}|{Numbers}|{WhiteSpace}|{SpecialChars})+

%%

{DocPrefix}=+\ ?				stop_previous(); BEGIN NAME;
{DocPrefix}Authors:				stop_previous(); BEGIN AUTHORS;
{DocPrefix}Pre:					stop_previous(); BEGIN PRE;
{DocPrefix}Post:				stop_previous(); BEGIN POST;
{DocPrefix}SeeAlso:				stop_previous(); BEGIN SEEALSO;
{DocPrefix}Warning:				stop_previous(); start_warning(); BEGIN WARNING;
{DocPrefix}Example:				stop_previous(); start_example(); BEGIN EXAMPLE;
{PrefixOnly}					stop_previous(); BEGIN FILEDESCR;

<FILEDESCR>{DocPrefix}{NewLine}			close_filedescr(); yyless(yyleng-1);
<FILEDESCR>{DocPrefix}				;
<FILEDESCR>{OneLine}				add_filedescr_line(yytext);
<FILEDESCR>{NewLine};?{WhiteSpace}*{NewLine}	stop_previous(); BEGIN 0;

<NAME>{ValidLabel}				register_routine(yytext);
<NAME>\ ?=+					start_description(); BEGIN DESCR;
<NAME>{NewLine}{WhiteSpace}*{NewLine}		stop_previous(); BEGIN 0;

<DESCR>{DocPrefix}{NewLine}			close_description(); yyless(yyleng-1);
<DESCR>{DocPrefix}				;
<DESCR>{OneLine}				add_description_line(yytext);
<DESCR>{NewLine}{WhiteSpace}*{NewLine}		stop_previous(); BEGIN 0;

<AUTHORS>{DocPrefix}				;
<AUTHORS>{OneLine}				add_author(yytext);
<AUTHORS>{NewLine}{WhiteSpace}*{NewLine}	stop_previous(); BEGIN 0;

<PRE>{DocPrefix}				;
<PRE>{OneLine}					add_precondition(yytext);
<PRE>{NewLine}{WhiteSpace}*{NewLine}		stop_previous(); BEGIN 0;

<POST>{DocPrefix}				;
<POST>{OneLine}					add_postcondition(yytext);
<POST>{NewLine}{WhiteSpace}*{NewLine}		stop_previous(); BEGIN 0;

<SEEALSO>{DocPrefix}				;
<SEEALSO>{ValidLabel}				add_see_also(yytext);
<SEEALSO>{NewLine}{WhiteSpace}*{NewLine}	stop_previous(); BEGIN 0;

<WARNING>{DocPrefix}{NewLine}			close_warning(); yyless(yyleng-1);
<WARNING>{DocPrefix}				;
<WARNING>{OneLine}				add_warning_line(yytext);
<WARNING>{NewLine}{WhiteSpace}*{NewLine}	stop_previous(); BEGIN 0;

<EXAMPLE>{DocPrefix}				;
<EXAMPLE>{OneLine}				add_example_line(yytext);
<EXAMPLE>{NewLine}{WhiteSpace}*{NewLine}	stop_previous(); BEGIN 0;

.						;
{NewLine}					;


