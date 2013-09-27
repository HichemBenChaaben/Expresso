#!/bin/bash

#shell script to compile javascript files and minfy them 
#created by Hichem benchaaben

basename="Expresso"
CMD="/"
minfolder='min'
COUNTER=0
combinedfolder='combined'
log='expresso-log.txt'

# colors used on the output 
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"


#functions 
compileCloser(){
    #command to compile and minify javascript files
    java -jar compiler.jar --js  $filename --js_output_file $NEWNAME  --language_in=ECMASCRIPT5_STRICT --use_types_for_optimization --compilation_level=ADVANCED_OPTIMIZATIONS
}

folderExists(){
    #if the folder do not exist then the shell script will create it for you
    if [ -d "`pwd`/$1" ]; then 
      echo ">>>>> Your output folder is `pwd`/$1"
    else
      echo ">>>>> $basename is creating $1 folder `pwd`/$1"
      mkdir -p "`pwd`/$1"
    fi
}
validfilerror(){
    #error message given on a not valid javascript file
     echo -e "$COL_RED $1 is not a file! please choose a valid javascipt file $COL_RESET"
     ls  *.js
}
extensionerror(){
    #error message given  on extension erro
    echo -e "$COL_RED The file $i is not a javascript file $basename only operate javascript files"
}
#function to go threw all the files and compile them 
compile(){
    #clear the screen
    clear
    #display about
    About="expresso"
    cat $About
    echo ">>>>> $basename is compiling javascript files and it will exit."
    echo ">>>>> Flushing the output folder for a fresh compilation."
    #check if the min folder is there is not then create it
    folderExists $minfolder
    #remove all the .min.js files on the min folder
    rm -f $minfolder"/"*.min.js
    #remove all the min files on the current directory
    rm -f *.min.js
    while true; do
        for filename in *.js; do
            echo ">>> Compiling and minification of $filename on $(date)"
            #write this event on a log file
            echo -e "$(date) Compiling and minification of $filename" >> $log
            if
                #give the minfied files a name and create them with that name 
                x=$filename
                NEWNAME=${x%.*}.min.js
                # will compile the javascript files
                compileCloser 

                if [ -s "$NEWNAME" ]
                    then
                    # check if /min folder exists otherwise create it
                       mv -f $NEWNAME $minfolder
                       echo -e "$COL_GREEN>>> Created $NEWNAME $COL_RESET"
                       COUNTER=`expr $COUNTER + 1`
                    else
                        rm -f $NEWNAME
                        echo -e "$COL_RED FILES WITH ERRORS WILL NOT BE MINIFIED! $COL_RESET"
                fi
            then
                #echo -e "$COL_GREEN $filename.......................................done $COL_RESET"
                echo -e "$COL_RESET"
            else
                echo -e "$COL_RED Please get back to $filename and fix the javascript errors $COL_RESET"
            fi
        done
        break
    done
    #count all the javascript files 
    count=$(ls *.js | wc --l)
    #display message based on the count of compiled files
    if [[ $count != $COUNTER ]]; then
        #statements
        echo ">>>>> Compilation complete with some errors, please go back and fix all errors"
        echo ">>>>> $COUNTER/$count javascipt files compiled"
        
        #write to a log file at the beggining
        echo -e "$(date) Compilation complete $COUNTER/$count javascipt files compiled">>$log
    else
        echo ">>>>> Compilation completed successfully"
        echo ">>>>> $COUNTER/$count javascript files compiled"
        
        #write to a log file at the beginning
        echo -e "$(date) Compilation successfully complete, $COUNTER/$count javascipt files compiled, All files COMPILED">>$log
        echo "----------------------------------------------------------------------------------------------------------">>$log
    fi
    #sort the log file 
    sort -o -r $log
}

watch(){
    # wathing filechange and compile it
    echo ">>>>> Expresso is watching for changes, Press Cntrl-C to Break"

    while file=$(inotifywait --exclude /combined --exclude .sh -e access -e modify  -e delete -e delete_self -e moved_to -e move -e create  / --format "%w%f" ./); do
        
        #record file extensions
        EXT=${file##*.}

        #set a new variable
        filename=file

        #handle only javascript files
        if [ $EXT = "js" ]
            then

            #choose another name for the file basically .min.js           
            NEWNAME=${file%.*}.min.js
            
            #original file name
            ORIGINALFILENAME=${file/"./"} 
            
            #original new name
            ORIGINALNEWNAME=${NEWNAME/"./"} 

            #if file exists
            if [ -f $file ]

            then
                echo -e "$COL_YELLOW>>> Change detected on $ORIGINALFILENAME on $(date) $COL_RESET"
                #now we have the original file name we will check if it not have been deleted

                #if its deleted  we will delete the minification file as well 
                
                #COMPILE THE FILE            
                echo -e "$COL_YELLOW"
                
                #use google closer to compile the files 
                java -jar compiler.jar --js $file --js_output_file $NEWNAME  --language_in=ECMASCRIPT5_STRICT --use_types_for_optimization --compilation_level=ADVANCED_OPTIMIZATIONS

                echo -e "$COL_RESET"            

                #the file is compiled and everything is fine then move the file to another directory
                if 
                    [ -s "$NEWNAME" ]
                    #The compiled file file is not empty 
                then
                    #move the compressed file to compressed directory
                    mv -f $NEWNAME $minfolder
                    echo -e "$COL_GREEN>>> Created $ORIGINALNEWNAME  on $(date) $COL_RESET"
                else
                    #remove the compressed file
                    rm -f $NEWNAME
                    echo -e "$COL_RED $ORIGINALFILENAME CANNOT BE MINIFIED, PLEASE FIX JAVASCRIPT ERRORS FIRST! $COL_RESET"
                fi
                #reset the screen color to white
                echo -e "$COL_RESET"

            else
                # if the file was deleted which this inotify can't detect exatctly which one
                # i'm removing the compressed file name 
                rm -f "$minfolder/$NEWNAME"
                # i'm removing the 
                rm -f $filename
                echo -e "$COL_RED>>> You deleted $ORIGINALFILENAME on $(date) $COL_RESET"

            fi
        fi
    done
}

usage(){

    # wathing filechang
    about
    echo "***********************************************************"
    echo "Minify and compile javascript files on the background      "
    echo "All compiled and minified files goes under /min            "
    echo "Inspired from compass ~ watch                              "

    echo "Dependencies :" 
    echo "https://github.com/rvoicilas/inotify-tools/wiki            "
    echo "sudo apt-get install inotify-tools                         " 
    echo "java vrm"
    echo "compiler.jar and $basename on the same folder               "
    echo "***********************************************************"
    echo "                                                             "
    echo "options : -c | --compile  compile the files on current directory "
    echo "          -b | --compilefiles [file1, file2, file3...]
                                    compile the selected files"
    echo "          -w | --watch    watch the current directory for file changes and compile .js files"
    echo "          -h | --help     display Usage and exit "
    echo "          -l | --log      display $basename logs "
    echo "          -a | --combine  [file1,file2,file3,file4 .... ]
                                    compile and combine output files   "
    echo "                                                             "
    echo "Exit, please choose an argument                              "

}
log(){
    cat $log
    exit
}
about(){
    About="expresso"
    cat $About
    echo -e "\n"
}
#this will compile partially the javascript files
compilefiles(){
    clear
    about
    echo ">>> Job started $count files to compile"
    #validate the files
    for i in $files; do
        if [ ! -f $i ]
        then 
            validfilerror $i
            exit
        fi
    done
    # Extension control
    for i in $files; do
        if [ ! "${i##*.}" = "js" ]
        then 
            extensionerror
            exit
        fi
    done
    # condition for javascript compilation
    while [ $count -lt 1 ]
    do
        echo " $COL_RED>>>> Please add at least a file to compile $COL_RESET"
        exit 1
    done
   #compilation will start here
   #compilation
   for i in $files; do
       #new name for the compiled file
       NEWNAME=${i%.*}.min.js
    
       #original file name
       ORIGINALFILENAME=${i/"./"} 
    
       #original new name
       ORIGINALNEWNAME=${NEWNAME/"./"}
    
       #compile this file
       echo -e "$COL_YELLOW>>> $basename is compiling $i $COL_RESET"
    
       #use google closer to compile the files 
       echo -e "$COL_YELLOW `java -jar compiler.jar --js $i --js_output_file $NEWNAME --language_in=ECMASCRIPT5_STRICT --use_types_for_optimization --compilation_level=ADVANCED_OPTIMIZATIONS` $COL_RESET "
    
       if 
           [ -s "$NEWNAME" ]
           #The compiled file file is not empty 
        then
           #move the compressed file to compressed directory
           mv -f $NEWNAME $minfolder
           echo -e "$COL_GREEN>>> Created $ORIGINALNEWNAME  on $(date) $COL_RESET"
       else
           #remove the compressed file
           rm -f $NEWNAME
           echo -e "$COL_RED $ORIGINALFILENAME CANNOT BE MINIFIED, PLEASE FIX JAVASCRIPT ERRORS FIRST! $COL_RESET"
           echo -e "$COL_RED $basename cannot combine javascript with errors, combined stopped $COL_RESET"
           exit
       fi     
   done
   echo ">>> Compilation ended, exit from $basename"
   #exit from the shell script once the compilation is fully done
   exit
}
messageverifyCompilation(){
    echo ">>> $basename verify if all the files compiles correctly"
}
combine(){
    #clear the screen 
    clear
    
    #display the script ascii text
    about
    
    #create a combined folder if it doesn't exit 
    folderExists $combinedfolder
    
    #create a min folder if it doesn't exit 
    folderExists $minfolder

    #output verify messages on the screen
    messageverifyCompilation

    # generate a random an unique file
    output="$RANDOM$RANDOM$RANDOM$RANDOM.js"
    
    # if its less than 2 arguments then display error
    if [ $count -lt 2 ]
        # condition for javascript combination 
        then 
        echo " $COL_RED>>>> $basename need at least two javascipt files $COL_RESET"
        exit 1
    fi
    #file error
    for i in $files; do
        if [ ! -f $i ]
        then 
            validfilerror $i
            exit
        fi
    done
    # Extension control
    for i in $files; do
        if [ ! "${i##*.}" = "js" ]
        then 
            extensionerror
            exit
        fi
    done
    #compilation
    for i in $files; do
        #new name for the compiled file
        NEWNAME=${i%.*}.min.js
        #original file name
        ORIGINALFILENAME=${i/"./"} 
        #original new name
        ORIGINALNEWNAME=${NEWNAME/"./"}
        #compile this file
        echo -e "$COL_YELLOW>>> $basename is recompiling $i $COL_RESET"
        #use google closer to compile the files 
        echo -e "$COL_YELLOW `java -jar compiler.jar --js $i --js_output_file $NEWNAME --language_in=ECMASCRIPT5_STRICT --use_types_for_optimization` $COL_RESET "
        if 
            [ -s "$NEWNAME" ]
            #The compiled file file is not empty 
         then
            #move the compressed file to compressed directory
            mv -f $NEWNAME $minfolder
            echo -e "$COL_GREEN>>> Created $ORIGINALNEWNAME  on $(date) $COL_RESET"
        else
            #remove the compressed file
            rm -f $NEWNAME
            echo -e "$COL_RED $ORIGINALFILENAME CANNOT BE MINIFIED, PLEASE FIX JAVASCRIPT ERRORS FIRST! $COL_RESET"
            echo -e "$COL_RED $basename cannot combine javascript with errors, combined stopped $COL_RESET"
            exit
        fi     
        #concat the minified files and create a single output
        minfile=${i%.*}.min.js
        minpath=$minfolder/$minfile
        cat $minpath >> $output
        whaticombine="    $i $whaticombine"
    done
    mv -f $output $combinedfolder
    #goes to the log file
    echo -e "$(date) Created combined javascript $output" >> $log
    echo "$whaticombine" >> $log
    echo "-----------------------------------------------------------------">>$log
    echo ">>>> $output created under $combinedfolder with: $whaticombine"
}
createcommit(){
    #this should be the last step after a compilation or combination
    git add min/*.js combined/*.js
    git commit -m "Added minified and combined javascript files"
    exit
}
#handle exmpty parameters
    if 
      [ "$1" = "" ]
      then
      #display how to use the shell script if there is no arguments passed
        usage
        exit 1
    fi
#Main Shell entry  
while [ "$1" != "" ]; do
    #handle non empty parameters
    case $1 in
        -c | --compile )        compile
                                ;;
        -b | --compilefiles )    
                                shift
                                files="$@"
                                all="$*"
                                count="$#"
                                compilefiles
                                ;;
        -a | --combine )        shift
                                files="$@"
                                all="$*"
                                count="$#"
                                combine
                                exit
                                ;;
        -o | --output )         output=$1
                                ;;
        -w | --watch )          watch
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        -l | --log )            log
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done
