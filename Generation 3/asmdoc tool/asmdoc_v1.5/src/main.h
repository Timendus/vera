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

#include <stdio.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdarg.h> /* va_list, va_start(), va_arg(), va_end() */

/**
 * Variables
 */
int pass = 0;
int routineOpen = 0;
int paragraphOpen = 0;
FILE *output;
FILE *tree;
FILE *routines;
void (*closeTag)();
char docsdir[ BUFSIZ ];
char *currentFile;

/**
 * Routine headers
 */
int is_dir( char *filename );
void fix_slashes( char *dirname );
char *name_only( char *filename );
char *rel_to_dest_dir( char *filename );
void copy_layout( char *destdir, char *layoutdir );
int copy_file( char *fromfile, char *tofile );
void parse_dir( char *indir, char *outdir, char *layoutdir );
void parse_file( char *infile, char *outfile );
int fixedprint(const char *format, ...);
void printOk();
void printFail();

void start_filedescr();
void add_filedescr_line( char *descrline );
void close_filedescr();
void stop_filedescr();

void stop_previous();
void register_routine( char *name );
void close_routine();

void start_description();
void add_description_line( char *descrline );
void close_description();
void stop_description();

void add_author( char *author );
void add_precondition( char *precond );
void add_postcondition( char *postcond );
void add_see_also( char *routine );

void start_warning();
void add_warning_line( char *warnline );
void close_warning();
void stop_warning();

void start_example();
void add_example_line( char *exampleline );
void stop_example();

