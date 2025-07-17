# Bash-Parallization
Simple shell script to run multiple instances of same code with different argument values.
One can specify the number of "threads" or instances to run simulataneously. 
The code then waits till the one or more of them are finished and starts the new runs.
It is helpful for runs which are completely independent, and for someone who doesn't want to implement mpi.

## Usage
There are two versions of the code available.
1. The code `parallel.sh` calls `test.sh` for every line in `names.txt` and passes that as an argument.
2. The `parallel_with_logger.sh` file, where the user can edit it to specify the commands they want to run in `files = ( # put your commands here )`.
   And specify a log file to log the resource utilization during running these files.  





