# Basics of the command line

This section is designed to give you a "very" brief introduction to the command line.

We will explain the commands, flags and special characters you need to be aware of in order to run a **Nextflow** pipeline.

This is not meant to be exhaustive, and requires additional reading/practicing to truly understand all the following content.

# Commands:

These are some basic unix commands that you need to familiarize yourself with:

`man`	Print the manual of a command

`ls`	Show all the files in the current directory

`pwd`	Tell me which directory I am in right now

`tree`  Print the directory structure

`cd`	Change directories<br>
(use as `cd ./directory` ,  change to a folder called directory in my current dir)<br>
(or `cd ..` , go up one directory)
(or `cd -` , back to previous directory)
(or `cd` , takes you to home directory)

`cp`	Move a file/folder (keep original; -r for recursively [also to copy a directory])

`mv`	Move a file/folder (and delete original)

`rm`	Remove/Delete a file (-r for recursively [also to remove a directory])

`mkdir`	Make a new directory

`chmod`	Change the users rights (mode) of a file 
(u:users a:all g:group o:other)
(+-)
(r:read w:write x:execute)
(e.g. chmod a+r file , make all users read file)

`nano`	Open the nano command line text editor<br>
(`nano file_name`, then exit/save by typing control X, checking the name is correct and entering `y`)

`wc` 	Word Count (with flag –l prints the # of lines in a file)

`grep`	Search for a string/word inside a file and print lines

`echo`	Prints statement to terminal or prints the contents of a variable ($)

`history`	Check out all my previous commands

`cat`	Print all lines or concatenate files

`head`	Print the top lines of a file (-n number of lines)

`tail`	Print the bottom lines of a file (-n number of lines)

`uniq`	Print unique lines

`wget`	Copy the contents of a webpage to the current directory

`which`  Tell me the path to the script/program (e.g. `which perl`)


# Extra commands you should know (but not needed in this course)

`ssh`	Access a remote server/cluster

`export`	Usually setting an environmental variable

`open`	Try to open a file type in expected way, e.g. PDF 


# Flags (for the command `ls`):

`-l`	long format

`-r`	reverse order

`-a`	show hidden files

`-h`	human readable (size)

`-t`	sort by time changed

`-G`  colour the output

`-S`  sort by size

To know the flags of other commands use `man command_name`


# Special Characters:

`$`	A variable (or a prompt)

`>`	Save and delete original. **If this file already exists, it will delete the original file**

`>>`  Append/Create a file. **If this file already exists, it will add to the original file**

`.`	Current directory

`..`	Directory one level up

`/`	Folder

`-`	Flag symbol

`~`	Home directory

`|`	Pipe (send output to another command)

`*`	Wildcard

`#`	Ignore line

Example:

`cat file | sort | uniq > sorted_uniq_file`
We read a file, then sort the output, and find the uniq lines, and save to a new file.

# Programming languages

`bash`  A unix command language interpretter

`perl`  A versatile programming language

`python`  A modern versatile programming language

`R`  A statistical programming language

# In Practice
<br>

**Step 0. Change directory and create new directories:**

You can make new directories using the VS code environment by going to the explorer on the left hand side and clicking the new folder button... But we will do this all using the command line.

First, check the location you are in the command line using `pwd`, which prints the working directory. Where you are right now. 

You can see we are in:<br> `/workspace/gitpod/eco-flow-training`.

Use the `ls` command to check what current file and folders we already have in this directory.

Now create a new directory using `mkdir` and name it "rnaseq_experiment", as we will use this during the day to run the RNA-Seq experiment. Then `cd` into this directory.

<details>
<summary>Cheat sheet</summary>
<br>
mkdir rnaseq_experiment

cd rnaseq_experiment
</details>

<br>

**Step 1. Create a new text files**

Now make a file called `list.sh` with the following text inside "ls -la" using `nano` or another command line text editor.
<br>
<details>
<summary>Cheat sheet</summary>
<br>
nano list.sh

<write some text>

quit nano using Control X

and type y (to agree to exit)

then press enter

</details>
</br>

**Step 2.Create and run a bash script**

Now try to run the bash script you just wrote in the previous exercise.

You execute a script by simply typing its name into the terminal.

It should say "bash: list.sh: command not found". This is because the command line doesn't know where list.sh is even though its in our current directory. 

To execute the script as a command we need to point to the file

`bash ./list.sh`

Again this should fail, because scripts need to be executable. The command line needs to know what to do with this file. 

Thats where the `chmod` command comes in. Change the mode of the file so it is executable.

`chmod u+x ./list.sh`

Now we have change the users rights to allow it to be executable (a script). 

Now if you run the command, it should run:

`bash ./list.sh`
<br>
<br>


**Step 3. Download a program**
<br><br>
In this step, you will download and get the `nextflow` command in your terminal.

`nextflow` is already pre-downloaded, but try to download nextflow it as per the instructions here:



**Step 4. Learn to use aliases**
<br><br>
In unix you can often have to use the same commands again and again, and this is where aliases come in handy.
<br>
<br>
`alias` is used by assigning another command or set of commands to a single word.

These commands are saved in a file called the `.bash_profile` which is normally in your home directory. On gitpod, it is in `/workspace/gitpod/.bash_profile`

These are a couple of examples, that reside in your `.bash_profile` already:

```
alias lss='ls -al'      
# Now lss will list the files in the directory in long form and with hidden files.
alias h1='head -n 1'    
# Now h1 will head the top 1 line of a file
```

Now make your own command to print the last 5 commands you used from `history`

<details>
<summary>Cheat sheet</summary>
<br>
Save the following line in :<br>
/workspace/gitpod/.bash_profile:<br>

`alias hist5='history | tail -n 5`<br>
Then source the `/workspace/gitpod/.bash_profile` file:<br>

`source /workspace/gitpod/.bash_profile file`

"hist5" was the name I used, but you can call it whatever command you wish, as long as it doesn't already exist.
</details>
