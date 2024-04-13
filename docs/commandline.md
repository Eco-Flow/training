# Basics of the command line

This section is designed to give you a "very" brief introduction to the command line, and explain the commands, flags and special characters you need to be aware of in order to run a Nextflow pipeline.

This is not meant to be exhaustive, and requires additional reading/practicing to truly understand all the following content.

# Commands:

These are some basic unix commands that you need to familiarize yourself with:

<img width="571" alt="image" src="https://github.com/Eco-Flow/training/assets/9978862/bba2e4e6-11e3-4d0f-942f-7945d21ebcce">

# Flags (for the command `ls`):

<img width="266" alt="image" src="https://github.com/Eco-Flow/training/assets/9978862/fd1bd0d8-00a4-4c38-87a1-11330f53cfea">

# Special Characters:

<img width="404" alt="image" src="https://github.com/Eco-Flow/training/assets/9978862/2fbaa2b1-78e4-42a0-b0a8-690c2b7191bb">

# In Practise
<br>
1. Make a new working directory, change into this directory and create a new text file called `list.sh` with the following text inside `ls -la` using nano. Don't include the ` symbols.
<br>
<br>
<details>
<summary>Cheat sheet</summary>
<br>

mkdir my_directory

cd my_directory

nano my_file

<write some text>

quit nano using Control X

and type y (to agree to exit)

then press enter

</details>

<br>
2. Now try to run the bash script you just wrote in the previous exercise.

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