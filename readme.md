Expresso a tiny shell script that compress javascript files
and watches for changes

Minify and compile javascript files on the background
All compiled and minified files goes under min folder
Dependencies 
	https://github.com/rvoicilas/inotify-tools/wiki

	sudo apt-get install inotify-tools
	java vrm
	compiler.jar              
Usage: 
	sh expresso.sh


options : -c | --compile  compile the files on current directory  
          -b | --compilefiles [file1.js, file2.js, file3.js ...]  
          -w | --watch    watch the current directory for file changes and compile   
          -h | --help     display Usage and exit "     
          -l | --log      display $basename logs "       
	          -a | --combine  [file1,file2,file3,file4 .... ]      
                                compile and combine output files       

Author : Hichem ben chaabene
