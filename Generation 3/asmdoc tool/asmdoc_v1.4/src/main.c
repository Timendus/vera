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

#include "main.h"
#include "vera_cs.c"
//#define VERBOSE
//#define WINDOWS
//#define YOUR_ROTTEN_COLORS_FUCK_UP_MY_TERMINAL_GET_EM_OFF

#ifdef WINDOWS
	#include <windows.h>
#endif

/**
 * Main function where program execution starts
 */

int main( int argc, char * argv[] )
{
	printf("\nASMDOC tool v1.4 - Reference implementation for Vera coding standards\n");
	printf("Copyright (C) 2007 The Vera Development Team\n\n");
	
	printf("This program comes with ABSOLUTELY NO WARRANTY.\n");
	printf("This is free software, and you are welcome to redistribute it\n");
	printf("under certain conditions; see the GNU GPLv3 for details.\n\n");
	
	if (argc == 3 || argc == 4) {

		if ( is_dir(argv[1]) ) {
		
			// Go into directory mode
			if ( !is_dir(argv[2]) ) {
				printf("Error: %s is not a directory\n\n",argv[2]);
				return -1;
			}
			
			// Test input directory not necessary (is_dir already did that)
			
			// Remove optional trailing slashes
			fix_slashes(argv[1]);
			fix_slashes(argv[2]);
			
			// Store source dir for later
			strcpy(docsdir,argv[2]);
			
			// Has a lay-out directory been specified?
			char *layout = NULL;
			if ( argc == 4 ) {
				// Find lay-out dir
				fix_slashes(argv[3]);
				layout = argv[3];
				if ( layout != NULL ) {
					// Copy "root" files to destination dir
#ifdef WINDOWS
					fixedprint("Copying layout files from %s\\root to %s",layout,argv[2]);
#else
					fixedprint("Copying layout files from %s/root to %s",layout,argv[2]);
#endif

					char laydir[ BUFSIZ ];
					char *laydirptr = laydir;
					strcpy(laydir,layout);
					laydirptr += strlen(layout);
#ifdef WINDOWS
					strcpy(laydirptr,"\\root");
#else
					strcpy(laydirptr,"/root");
#endif
					if ( copy_files(laydir,argv[2]) )
						printOk();
					else
						printFail();
				}
			}
			
			// Start building the tree XML file
			char treefile[ BUFSIZ ];
			char *treefileptr = treefile;
			strcpy(treefileptr,argv[2]);
			treefileptr += strlen(argv[2]);
#ifdef WINDOWS
			strcpy(treefileptr,"\\tree.xml");
#else
			strcpy(treefileptr,"/tree.xml");
#endif
			tree = fopen(treefile,"w");
			if ( tree == NULL ) {
				perror(treefile);
				printf("\n");
				return -1;
			}
			fprintf(tree,"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n");
			fprintf(tree,"<?xml-stylesheet type=\"text/xsl\" href=\"veradoc.xsl\"?>\n\n");
			fprintf(tree,"<tree>\n");
			
			// Parse files in directory
			parse_dir(argv[1],argv[2],layout);
			
			// Close tree XML file
			fprintf(tree,"</tree>\n");
			fclose(tree);
			
		} else {
		
			// Go into file mode
			if ( is_dir(argv[2]) ) {
				printf("Error: %s is not a file\n\n",argv[2]);
				return -1;
			}
			
			// Test input file
			FILE *infile = fopen(argv[1], "r");
			if ( infile == NULL ) {
				perror(argv[1]);
				printf("\n");
				return -1;
			}
			fclose(infile);
			
			// Parse the file
			parse_file(argv[1],argv[2]);
			
		}
		
	} else {
#ifdef WINDOWS
		printf("Usage:\n");
		printf("   > %s file.asm file.xml\n",argv[0]);
		printf("or\n");
		printf("   > %s sourcedir docsdir [layoutdir]\n\n",argv[0]);
#else
		printf("Usage:\n");
		printf("   $ %s file.asm file.xml\n",argv[0]);
		printf("or\n");
		printf("   $ %s sourcedir docsdir [layoutdir]\n\n",argv[0]);
#endif
	}
	
	printf("Done!\n\n");
	
	return 0;
	
}

/**
 * Test if a filename points to a directory
 */

int is_dir( char *filename ) {
	DIR *test = opendir(filename);
	if ( test != NULL ) {
		closedir(test);
		return 1;
	}
	return 0;
}

/**
 * Remove trailing slashes from directory name
 */

void fix_slashes( char *dirname ) {
	dirname += strlen(dirname)-1;
#ifdef WINDOWS
	if ( !strncmp("\\",dirname,1) )
#else
	if ( !strncmp("/",dirname,1) )
#endif
		dirname[0] = '\0';
}

/**
 * Return a pointer to just the file/dir name in this path
 */

char *name_only( char *filename ) {
#ifdef WINDOWS
	while ( strstr(filename,"\\") != NULL ) {
		filename = strstr(filename,"\\")+1;
	}
#else
	while ( strstr(filename,"/") != NULL ) {
		filename = strstr(filename,"/")+1;
	}
#endif
	return filename;
}

/**
 * Return a pointer to the file/dir path, relative to destination dir
 */

char *rel_to_dest_dir( char *filename ) {
	filename += strlen(docsdir)+1;
	return filename;
}

/**
 * Copy a file from A to B
 */

int copy_file( char *fromfile, char *tofile ) {

#ifdef WINDOWS
	return CopyFile(fromfile,tofile,0);

#else
	char buf[ BUFSIZ ];
	FILE *inF = fopen(fromfile,"r");
	FILE *ouF = fopen(tofile,"w");
	int len;
	
	// Handle errors
	if ( inF == NULL || ouF == NULL ) {
		if ( inF == NULL )
			perror(fromfile);
		else
			perror(tofile);
		return 0;
	}
	
	while((len = fread(buf,1,sizeof(buf),inF)) > 0) {
		fwrite(buf,1,len,ouF);
		/*if ( fwrite(buf,1,len,ouF) ) {
			perror(tofile);
			return 0;
		}*/
	}
	if (!feof(inF)) {
		perror(fromfile);
		return 0;
	}
	
	fclose(inF);
	fclose(ouF);
	return 1;
#endif

}

/**
 * Copy all files from directory A to directory B
 */

int copy_files( char *fromdir, char *todir ) {
	DIR *indirptr = opendir(fromdir);
	struct dirent *file;
	char fromfile[ BUFSIZ ];
	char tofile[ BUFSIZ ];
	
	while ((file = readdir(indirptr)) != NULL) {
		if ( strncmp(".",file->d_name,1) ) {
			// Find from file location
			char *fromfileptr = fromfile;
			strcpy(fromfileptr,fromdir);
			fromfileptr += strlen(fromdir);
#ifdef WINDOWS
			fromfileptr[0] = '\\';
#else
			fromfileptr[0] = '/';
#endif
			strcpy(fromfileptr+1,file->d_name);
			// Find to file location
			char *tofileptr = tofile;
			strcpy(tofileptr,todir);
			tofileptr += strlen(todir);
#ifdef WINDOWS
			tofileptr[0] = '\\';
#else
			tofileptr[0] = '/';
#endif
			strcpy(tofileptr+1,file->d_name);
			// Do the copying
			if ( !copy_file(fromfile,tofile) )
				return 0;
		}
	}
	
	return 1;
}

/**
 * Copy lay-out files to another directory
 */

void copy_layout( char *destdir, char *layoutdir ) {
	if ( layoutdir != NULL ) {
		// Copy "all" files to destination dir
#ifdef WINDOWS
		fixedprint("Copying layout files from %s\\all to %s",layoutdir,destdir);
#else
		fixedprint("Copying layout files from %s/all to %s",layoutdir,destdir);
#endif

		char laydir[ BUFSIZ ];
		char *laydirptr = laydir;
		strcpy(laydir,layoutdir);
		laydirptr += strlen(layoutdir);
#ifdef WINDOWS
		strcpy(laydirptr,"\\all");
#else
		strcpy(laydirptr,"/all");
#endif
		if ( copy_files(laydir,destdir) )
			printOk();
		else
			printFail();
	}
}

/**
 * Parse all files in a directory
 */

void parse_dir( char *indir, char *outdir, char *layoutdir ) {
#ifdef VERBOSE
	printf("Entering directory %s\n",indir);
#endif
	
	// Add this dir to the XML tree
	fprintf(tree,"\t<dir>\n");
	fprintf(tree,"\t\t<name>%s</name>\n",name_only(indir));
	
	// Copy lay-out files to destination dir
	copy_layout(outdir,layoutdir);
	
	DIR *indirptr = opendir(indir);
	struct dirent *file;
	char newinfile[ BUFSIZ ];
	char newoutfile[ BUFSIZ ];
	
	while ((file = readdir(indirptr)) != NULL) {
		// For each file in the directory (excluding files starting with a period)
		if ( strncmp(".",file->d_name,1) ) {
			
			// Find in file name
			char *newinfileptr = newinfile;
			strcpy(newinfileptr,indir);
			newinfileptr += strlen(indir);
#ifdef WINDOWS
			newinfileptr[0] = '\\';
#else
			newinfileptr[0] = '/';
#endif
			strcpy(newinfileptr+1,file->d_name);
			
			// Find out file name
			char *newoutfileptr = newoutfile;
			strcpy(newoutfileptr,outdir);
			newoutfileptr += strlen(outdir);
#ifdef WINDOWS
			newoutfileptr[0] = '\\';
#else
			newoutfileptr[0] = '/';
#endif
			strcpy(newoutfileptr+1,file->d_name);
			
			if ( is_dir(newinfile) ) {
				// It's a dir; does it exist yet in the target dir?
				if ( !is_dir(newoutfile) )
#ifdef WINDOWS
					mkdir(newoutfile);
#else
					mkdir(newoutfile,0755);
#endif
				// do a recursive parse_dir call
				parse_dir(newinfile,newoutfile,layoutdir);
			} else {
				// It's a file; is it a .asm or .inc file?
				char *extension = strstr(newoutfile,".asm");
				if ( extension == NULL )
					extension = strstr(newoutfile,".inc");
				if ( extension != NULL ) {
					// It's a good file, change the extension
					strcpy(extension,".xml");
					// Add it to the XML tree
					fprintf(tree,"\t\t<treefile>\n");
					fprintf(tree,"\t\t\t<name>%s</name>\n",name_only(newinfile));
					fprintf(tree,"\t\t\t<file>%s</file>\n",rel_to_dest_dir(newoutfile));
					fprintf(tree,"\t\t</treefile>\n");
					// And parse it
					parse_file(newinfile,newoutfile);
				}
			}
		}
	}
	
	closedir(indirptr);

	// Close this dir in the XML tree
	fprintf(tree,"\t</dir>\n");
	
#ifdef VERBOSE
	printf("Leaving directory %s\n",indir);
#endif
}

/**
 * Parse one file into an XML file
 */

void parse_file( char *infile, char *outfile ) {
	fixedprint("Parsing file %s to %s",infile,outfile);
	yyin = fopen(infile,"r");
#ifdef VERBOSE
	output = stdout;
#else
	output = fopen(outfile,"w");
#endif
	if ( yyin == NULL ) {
		perror(infile);
		printFail();
		return;
	}
	if ( output == NULL ) {
		perror(outfile);
		printFail();
		return;
	}
	fprintf(output,"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n");
	fprintf(output,"<?xml-stylesheet type=\"text/xsl\" href=\"veradoc.xsl\"?>\n\n");
	fprintf(output,"<file>\n\t<name>%s</name>\n",infile);
	
	pass = 1;
	start_filedescr();
	yylex();
	stop_filedescr();
	fclose(yyin);
	
	yyin = fopen(infile,"r");
	pass = 2;
	yylex();
	if ( routineOpen ) close_routine();
	fprintf(output,"</file>\n");
	fclose(yyin);
	fclose(output);
	
	printOk();
}

/**
 * Output function to fix columns
 */

int fixedprint(const char *fmt, ...) {
	va_list args;
	int rv;
	char temp[ BUFSIZ ];

	va_start(args, fmt);
	rv = vsprintf(temp,fmt, args);
	va_end(args);
	
	printf("%-74s",temp);
	return rv;
}

/**
 * Output [OK] in green
 */

void printOk() {
#ifdef YOUR_ROTTEN_COLORS_FUCK_UP_MY_TERMINAL_GET_EM_OFF
	printf(" [OK]\n");
#else
#ifdef WINDOWS
	HANDLE  hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleTextAttribute(hConsole, 10);
	printf(" [OK]\n");
	SetConsoleTextAttribute(hConsole, 7);
#else
	printf(" \033[22;32m[OK]\033[22;30m\n");
#endif
#endif
}

/**
 * Output [FAIL] in red
 */

void printFail() {
#ifdef YOUR_ROTTEN_COLORS_FUCK_UP_MY_TERMINAL_GET_EM_OFF
	printf("[FAIL]\n");
#else
#ifdef WINDOWS
	HANDLE  hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleTextAttribute(hConsole, 12);
	printf("[FAIL]\n");
	SetConsoleTextAttribute(hConsole, 7);
#else
	printf("\033[22;31m[FAIL]\033[22;30m\n");
#endif
#endif
}

/*******************************
 * From here on down functions are used by the grammar, not the main function
 */

#ifdef WINDOWS
int yywrap() {
	return(1);
}
#endif

/**
 * Close whichever field is open
 */

void stop_previous() {
	if ( closeTag != NULL ) {
		closeTag();
		closeTag = NULL;
	}
}

/**
 * Start, add and stop file description
 */

void start_filedescr() {
	if ( pass == 1 ) {
		fprintf(output,"\t<description>\n");
		closeTag = &close_filedescr;
	}
}

void add_filedescr_line( char *descrline ) {
	if ( pass == 1 ) {
		if ( paragraphOpen )
			fprintf(output,"%s ",descrline);
		else {
			fprintf(output,"\t\t<p>%s ",descrline);
			paragraphOpen = 1;
		}
	}
}

void close_filedescr() {
	if ( pass == 1 && paragraphOpen ) {
		fprintf(output,"</p>\n");
		paragraphOpen = 0;
	}
}

void stop_filedescr() {
	if ( pass == 1 ) {
		close_filedescr();
		fprintf(output,"\t</description>\n\n");
	}
}

/**
 * Start and stop routine header
 */

void register_routine( char *name ) {
	if ( pass == 2 ) {
		if ( routineOpen ) close_routine();
		fprintf(output,"\t<routine>\n\t\t<name>%s</name>\n",name);
		routineOpen = 1;
	}
}

void close_routine() {
	if ( pass == 2 ) {
		fprintf(output,"\t</routine>\n\n");
	}
}

/**
 * Start, add and stop description field
 */

void start_description() {
	if ( pass == 2 ) {
		fprintf(output,"\t\t<description>\n");
		closeTag = &stop_description;
	}
}

void add_description_line( char *descrline ) {
	if ( pass == 2 ) {
		if ( paragraphOpen )
			fprintf(output,"%s ",descrline);
		else {
			fprintf(output,"\t\t\t<p>%s ",descrline);
			paragraphOpen = 1;
		}
	}
}

void close_description() {
	if ( pass == 2 ) {
		if ( paragraphOpen ) {
			fprintf(output,"</p>\n");
			paragraphOpen = 0;
		}
	}
}

void stop_description() {
	if ( pass == 2 ) {
		close_description();
		fprintf(output,"\t\t</description>\n");
	}
}

/**
 * Add author fiels
 */

void add_author( char *author ) {
	if ( pass == 2 ) {
		fprintf(output,"\t\t<author>%s</author>\n",author);
	}
}

/**
 * Add precondition field
 */

void add_precondition( char *precond ) {
	if ( pass == 2 ) {
		fprintf(output,"\t\t<precondition>%s</precondition>\n",precond);
	}
}

/**
 * Add postcondition field
 */

void add_postcondition( char *postcond ) {
	if ( pass == 2 ) {
		fprintf(output,"\t\t<postcondition>%s</postcondition>\n",postcond);
	}
}

/**
 * Add see also field
 */

void add_see_also( char *routine ) {
	if ( pass == 2 ) {
		fprintf(output,"\t\t<seealso>%s</seealso>\n",routine);
	}
}

/**
 * Start, add and stop warning field
 */

void start_warning() {
	if ( pass == 2 ) {
		fprintf(output,"\t\t<warning>\n");
		closeTag = &stop_warning;
	}
}

void add_warning_line( char *warnline ) {
	if ( pass == 2 ) {
		if ( paragraphOpen )
			fprintf(output,"%s ",warnline);
		else {
			fprintf(output,"\t\t\t<p>%s ",warnline);
			paragraphOpen = 1;
		}
	}
}

void close_warning() {
	if ( pass == 2 ) {
		if ( paragraphOpen ) {
			fprintf(output,"</p>\n");
			paragraphOpen = 0;
		}
	}
}

void stop_warning() {
	if ( pass == 2 ) {
		close_warning();
		fprintf(output,"\t\t</warning>\n");
	}
}

/**
 * Start, add and stop example field
 */

void start_example() {
	if ( pass == 2 ) {
		fprintf(output,"\t\t<example>\n");
		closeTag = &stop_example;
	}
}

void add_example_line( char *exampleline ) {
	if ( pass == 2 ) {
		fprintf(output,"\t\t\t<line>%s</line>\n",exampleline);
	}
}

void stop_example() {
	if ( pass == 2 ) {
		fprintf(output,"\t\t</example>\n");
	}
}


