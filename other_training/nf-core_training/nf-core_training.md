# nf-core training
 
Pre-requisites:
- Conda (miniconda)
- nf-core tools >= 3.5.1
- GitHub account
 
Install conda and nf-core tools if not yet installed
 
If conda not installed yet, download and install from [here](https://www.anaconda.com/download). Once conda is installed, install nf-core tools with the next command:
 
```
conda create -n nf-core -c bioconda nf-core=3.5.1
```

This will create a new conda environment with the latest nf-core tools version.
 
If people do not manage to install conda or nf-core, don’t worry! We will it create in situ and have a template ready on the Eco-Flow GitHub site that they can edit later using Codespaces. For now, it’s not strictly necessary that they follow along.

## nf-core Pipelines

### Create an nf-core Pipeline

Create pipeline using nf-core tools
 
```
nf-core pipelines create
```
Follow the visual prompt instructions:

<img src="./Screenshot 2026-02-23 at 11.50.20.png"/>

Choose "nf-core" as "pipeline type", even if you are not sure it's going to become an official nf-core pipeline:

<img src="./Screenshot 2026-02-23 at 11.50.46.png"/>

Choose a name for the pipeline, add a brief description and the athor/s name:

<img src="./Screenshot 2026-02-23 at 11.51.54.png"/>

Don't worry about not being able to change the "nf-core" GitHub organisation. You will still be able to push the pipeline to your GitHub account or your own organisation's.

Select components and modules according to what you think are and will be your pipeline necessities. We recommend to keep at least nf-core schema and multiqc for every pipeline:

<img src="./Screenshot 2026-02-23 at 11.52.04.png"/>

Select the local directory where the pipeline will be created:

<img src="./Screenshot 2026-02-23 at 11.52.58.png"/>

The pipeline contents will be store inside a folder called `nf-core-<your_pipeline_name>`. Press **continue**:

<img src="./Screenshot 2026-02-23 at 11.53.16.png"/>

Finally, select "Finish without creating a repo":

<img src="Screenshot 2026-02-23 at 11.53.25.png"/>

If the pipeline has been proposed and accepted as an nf-core pipeline in slack, the nf-core team will set up the pipeline repository. For more information, refer to the [nf-core page]().

If the pipeline has not been proposed or accepted yet, or you are unsure it'll become an official nf-core pipeline, you can create a new repository in your GitHub personal page or organisation, and push the pipeline there:


 
Follow GitHub’s instructions:
 


Then, in the command line where our pipeline is located locally do:
 
```
git remote add origin https://github.com/Eco-Flow/training_remove.git
git branch -M main
git push -u origin main
```

Go back to the GitHub repository, it should be filled with the nf-core template and a README.md.

Instead of continuing with the repository we just created, we are going to fork an existing repository in the Eco-Flow GitHub page. The purpose of this is to show attendees the procedure for contributing to an already existing pipeline, which is what most of them will do during the hackathon.

### The nf-core template

Open Codespaces in the fork and explain the workings of the pipeline starting from the `main.nf` file:



This what the Codespace should look like:


The main.nf file:
- Runs a validation subworkflow: Input validation using the input schema (prepare input channel)
- Runs the main workflow
- Runs a competition subworkflow (competition hooks)
 
The first workflow (the one before the main workflow) is not really necessary, we could remove it to show that the pipeline still works without it (as it might be better to explain what main.nf does), and then we could explain that this should not be removed as it’s probably there for some reason (honestly, I don’t know why).
 
Create a new branch

Either use Codespaces or the command line. I find it easier from the command line:

```
git branch switch -c new_branch
```
 
 Go to workflow/training.nf:
 
Explain the logic behind the main workflow (import modules, call modules, multiqc and version channels preparation…)
 
Install example module:
 
```
nf-core modules install fastp
```
 
Call module inside workflow/training.nf:
 
- Import module
- Call module
 
 Do the same thing but with subworkflows:
 
- Quality control subworkflow
- Processing subworkflow
 
 Explain --input and how validation is done using:
 
- Input_schema.json
- Validation plugin inside subworkflows
 
Push changes:

In the directory where the main.nf is:
```
git add changed_files
git commit -m ‘New changes’
git push origin branch_name
```

Open Pull Request in github:



Create pipeline using nf-core tools
 
```
nf-core modules create
```





Structure of the nf-core template

Files worth mentioning (the rest can be disregarded):

nextflow.config: Here is where our parameters will be defined (e.g., input/output directory, and other pipeline specific argument options).

nextflow_schema.json: Contains information regarding every parameter in the nextflow.config (e.g. whether it is an integer or a string and a brief description). This should be updated every time a new parameter is defined. The information here will appear when we use the “--help” argument. We can disregard it for now.

modules.json: This contains information (metadata) about every installed nf-core module. This is automatically updated every time an nf-core module is installed, no need to manually edit it.

README.md: No need to explain.

main.nf:



This is a script that will “kick-start” the pipeline. It has three components (exported as workflows above, in the “include” statements):

The main workflow, which we are going to see later and is usually the file where we call and connect the different modules (each module is a process) in a single workflow
The pipeline initialisation subworkflow. This is a plugin that does some checks before pipeline starts, such as parsing and validating the samplesheet to make sure it follows the correct format. Depending on the structure of our samplesheet, we might have to edit and adapt the plugin. Luckily for us the plugin works as it is with the type of samplesheet we are going to use (I think).
The pipeline completion subworkflow. A plugin that vontains pipeline completion hooks. We can completely ignore this plugin, and let it do its thing.

Main workflow is called inside a new workflow definition:


This workflow re-definition inside the main.nf can actually be skipped and the imported workflow can be called directly in the workflow below. But it is probably there for a reason.


The workflow that the main.nf runs, where each the new defined workflow and the nf-core plugins are called.

workflows/workflow.nf:

This file defines our most important workflow (which is then called by the main.nf), as here  is usually where modules are called and chained together.


We can see the two modules are imported, apart from some plugins related mainly to properly collecting information that will be displayed in the multiqc output (such as the software version of the tools inside the modules). We can ignore this, as we are not supposed to edit them, and work right as they are.

The other two modules are FASTQC and MULTIQC, that can be run already. But to show how it works, I’ll take the chance to install a couple of modules that we are going to need for the pre-processing workflow using the nf-core modules install tool:

```
nf-core modules install fastp
nf-core modules install falco
```

And now, I’m going to import these modules into workflows/worflow.nf:

```
include { FALCO                  } from '../modules/nf-core/falco/main'
include { FASTP                  } from '../modules/nf-core/fastp/main'
```
Prepare the input channel to run both FALCO and FASTP. For this, we will need to check the input inside the modules where these processes are called.

FASTP:
   input:
   tuple val(meta), path(reads)

FALCO:
   input:
   tuple val(meta), path(reads), path(adapter_fasta)
   val  discard_trimmed_pass
   val  save_trimmed_fail
   val  save_merged

We can see that FALCO requires a tuple (the equivalent to a python list) with the meta and reads. Usually input channels follow this structure, therefore we can use our input just as it is.

FASTP requires a tuple with the meta, reads and another element, the adapter file. If we check the script, we can see that only the meta and reads are mandatory, but we are still going to need a tuple with three elements, but we can leave the last one empty (or include the adapter file if we have one).

Now, call the modules inside the workflow:
   //
   // MODULE: Run FASTP
   //
   ch_fastp = ch_samplesheet.map { meta, reads -> tuple(meta, reads, []) }


   FASTP (
       ch_fastp,
       [],
       [],
       []
   )


   //
   // MODULE: Run FALCO
   //
   FALCO (
       FASTP.out.reads
   )





And run the workflow.

But, as we discuss, we want two workflows: one for the preprocessing and another for the assembly. For this, we are going to use subworkflows instead. We can create a workflow manually inside subworkflows/local/ or we can use nf-core tools instead:

```
nf-core subworkflows create preprocessing
```

We can see in our subworfklow/local/preprocessing a test folder and a meta.yml. We can ignore these for now, as these are only mandatory if we are going to release this subworkflow as an nf-core subworkflow.

Let’s focus on the main.nf. Import the modules and call them inside the subworkflow just like we did before:

include { FASTQC                 } from '../../../modules/nf-core/fastqc/main'
include { FALCO                  } from '../../../modules/nf-core/falco/main'
include { FASTP                  } from '../../../modules/nf-core/fastp/main'


workflow PREPROCESSING {


   take:
   // TODO nf-core: edit input (take) channels
   ch_samplesheet // channel: [ val(meta), [ bam ] ]


   main:
   // TODO nf-core: substitute modules here for the modules of your subworkflow


   //
   // MODULE: Run FASTP
   //
   ch_fastp = ch_samplesheet.map { meta, reads -> tuple(meta, reads, []) }


   FASTP (
       ch_fastp,
       [],
       [],
       []
   )


   //
   // MODULE: Run FALCO
   //
   FALCO (
       FASTP.out.reads
   )


   //
   // MODULE: Run FastQC
   //


   FASTQC (
       ch_samplesheet
   )


   emit:
   // TODO nf-core: edit emitted channels
   fastqc = FASTQC.out.zip
   //bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
   //bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
   //csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]
}



Run the pipeline again. Done!

## nf-core Modules

### Installing an nf-core Module

If working on your own pipeline, or if there is an existing nf-core pipeline that you think will benefit from an available nf-core module, you can add an said module to said pipeline. The easiest way to do this is using nf-core tools, more precisely the `nf-core modules install` command.

First, as usual, fork the pipeline's repository in your personal GitHub account or organisation:

Open your fork using **Codespaces**, or clone it:

If you are cloning the repo locally, make sure to have nf-core tools installed. Please refer to the [pre-requisites section]().

Create a new branch:

```
git branch switch -c new_branch
```

Will will use the nf-core `FASTP` module as an example. In the base directory of the pipeline, run:

```
nf-core modules install fastp
```

Import the module and call it inside a workflow/subworkflow:

```
include { FASTP                  } from '../../../modules/nf-core/fastp/main'
```

Use git to add, commit and push your changes.

We will explain the logic behind nf-core modules in the next section.

### Creating an nf-core Module

If there's a tool that you think other nf-core pipelines might benefit from and that is not yet part of the nf-core modules set, you can create an nf-core module with said tool and publish it as an official nf-core module. This is probably the most common way to collaborate to nf-core.

To create a new nf-core module, you first need to be part of the nf-core organisation. For more information about being part of nf-core, please refer to [this page]().

There's an [nf-core/modules repository]() where all modules are stored. To contribute with a new nf-core module, first, we will fork this repository as usual:

Open the fork using Codespaces or clone the repository:


Again, if the repository is cloned locally, make sure to have nf-core tools installed.

Create a new branch:

```
git switch -c new_branch
```

Use nf-core tools to create the new module:

```
nf-core modules new_tool
```

This will launch a prompt to fill some basic information. We will use **kmergenie** as an example. Add your GitHub user name:

```


                                          ,--./,-.
          ___     __   __   __   ___     /,-._.--~\
    |\ | |__  __ /  ` /  \ |__) |__         }  {
    | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                          `._,._,'

    nf-core/tools version 3.5.1 - https://nf-co.re
    There is a new version of nf-core/tools available! (3.5.2)


INFO     Repository type: modules
INFO     Press enter to use default values (shown in brackets) or type your own responses. ctrl+click underlined text to
         open links.
INFO     Using Bioconda package: 'bioconda::kmergenie=1.7051'
INFO     Using Docker container: 'biocontainers/kmergenie:1.7051--py39r44h746d604_9'
INFO     Using Singularity container: 'https://depot.galaxyproject.org/singularity/kmergenie:1.7051--py39r44h746d604_9'
INFO     Found bio.tools information for 'kmergenie'
INFO     Found bio.tools ID: 'biotools:kmergenie'
GitHub Username: (@author):
```

Select a label (see [The main.nf](#the-mainnf) section):

```
? Process resource label: process_
                                  process_single
                                  process_low
                                  process_medium
                                  process_high
                                  process_long
                                  process_high_memory
```

Modules usually require module 'meta' information. Select yes in the next step:

```
INFO     Where applicable all sample-specific information e.g. 'id', 'single_end', 'read_group' MUST be provided as an input
         via a Groovy Map called 'meta'. This information may not be required in some instances, for example indexing
         reference genome files.
Will the module require a meta map of sample information? [y/n] (y): y
```

This command will create all the necessary templates to start working on our module. You will see a new directory called `/modules/nf-core/<new_tool>`. This directory contains all the files an nf-core modules is comprised of:

- `/modules/nf-core/<new_tool>/environment.yml`: The file that will be used to create conda environment if the pipeline is run using the conda profile. nf-core tools will search for the `new_tool` string inside the bioconda and conda channels, and if a conda recipie matches, it update this file automatically. If not match has been found, the package will have to be added manually.
- `/modules/nf-core/<new_tool>/meta.yml`: The file information about the the module. This is the information that is displayed in the nf-core website. This information is partially filled if the tool added as module is in bio.tools. Otherwise, the information must be added manually.
- `/modules/nf-core/<new_tool>/tests/main.nf.test`: The test file for unit testing. We will go into more detail later.
- `/modules/nf-core/<new_tool>/main.nf`: The main module script, where the process is contained.

Make sure the `evironment.yml` and `meta.yml` have the proper information. Once that is sorted, move to the main script and unit testing.

#### The `main.nf`

This is what the `main.nf` looks like:

```groovy
// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.

process KMERGENIE {
    tag "$meta.id"
    label 'process_single'

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kmergenie:1.7051--py39r44h746d604_9':
        'biocontainers/kmergenie:1.7051--py39r44h746d604_9' }"

    input:// TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    tuple val(meta), path(bam)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("*.bam"), emit: bam
    // TODO nf-core: List additional required output channels/values here
    // TODO nf-core: Update the command here to obtain the version number of the software used in this module
    // TODO nf-core: If multiple software packages are used in this module, all MUST be added here
    //               by copying the line below and replacing the current tool with the extra tool(s)
    tuple val("${task.process}"), val('kmergenie'), eval("kmergenie --version"), topic: versions, emit: versions_kmergenie

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """
    kmergenie \\
        $args \\
        -@ $task.cpus \\
        -o ${prefix}.bam \\
        $bam
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    // TODO nf-core: If the module doesn't use arguments ($args), you SHOULD remove:
    //               - The definition of args `def args = task.ext.args ?: ''` above.
    //               - The use of the variable in the script `echo $args ` below.
    """
    echo $args
    
    touch ${prefix}.bam
    """
}
```

Follow the `TODO` statements, and remove them once the module is ready.

The module is made of several bocks, we will go over the most relevant:

- `label`. This points to a resource preset contained in every `modules.config` file inside most nf-core pipelines. Choose between `process_single`, `process_low`, `process_middle`, `process_high`, `process_long`, or `process_high_memory`, depeding on the resources estimation. This the [AAA pipeine]() as a example of these presets. For this example we are going to use `process_single`:

```groovy
    label 'process_single'
```

- `conda`. This points to the conda `envoronment.yml`. Usually does not need to be modified:

```groovy
    conda "${moduleDir}/environment.yml"
```

- `container`. nf-core tools will search for docker containers in biocontainers, and singularity images in https://depot.galaxyproject.org/singularity/. The conditional statement will pull the container or the image depending on which container engine is used. If no container/image is found, the you will have to add a container manually. You can use [seqera containers](https://seqera.io/containers/) to build containers on the fly if no containers for the tool exists. For our example, it seems that nf-core was able to find a docker container and a singularity image:

```groovy
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kmergenie:1.7051--py39r44h746d604_9':
        'biocontainers/kmergenie:1.7051--py39r44h746d604_9' }"
```

- `input`. Input declaration. Usually, in nf-core pipelines, input channels follow the Groovy list structure: `[meta, files]`. The first element, the `meta`, is a so called `meta map` that stores regarding the input file, e.g. the sample id associated to that file, in the case of FASTQs, whether they are paired-end or single-end, etc. The `files` element contains the location of the file or files. For our example, we can follow this structure for our input files channel:

```groovy
    input:
    tuple val(meta), path(reads)
    val k-size
```

k-size's value for kmergenie is mandatory, so we will add it as an input. Since it's just a value, it doesn't need to have a `meta map`, so we can declare it as just a value.

- `output`. Output declaration. We would usually define the outputs that we would expect from the process. If they are file, they should include a `meta map`, which is just the same `meta map` as the input. In our example, the output files are already know, but you'll have to fingure this out by reading the tool's documentation or running the tool standalone:

```groovy
    output:
    tuple val(meta), path("*-contigs.fa"),   emit: contigs
    tuple val(meta), path("*-scaffolds.fa"), emit: scaffolds
    tuple val(meta), path("*-stats.tab"),    emit: stats
    tuple val(meta), path("log"),            emit: log 
    tuple val("${task.process}"), val('abyss'), eval("abyss-pe version | grep abyss | cut -d\" \" -f3"), topic: versions, emit: versions_abys
```

We use `emit` here so that output channels are easily accessible and can be consumed by other process. You should always use emit on your output channels.

Every module should output a versions channel with the version of the tool. Simply change `eval("abyss-pe version | grep abyss | cut -d\" \" -f3")` from the versions channel into a bash command that will give you the version of your tool, and leave the rest as it is.

- `script`. Main script with the tool command execution. Before the command execution block definition, you can define some Nextflow variables that you can access later in the command execution block. By default, non-mandatory arguments from the tool should not be included in command execution block. But, to let pipeline developers and general user add command arguments for said tool, we will include the `args` variable that is placed by default when we create a module:

```groovy
    script:
    def args = task.ext.args ?: ''
```

You will also see the `prefix` variable also set by default. This is usually used as the output prefix (folder or file, depending on the tool), and is based on the information contained by the `meta map`, more specifically, the `meta.id`:

```groovy
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def memory = (task.memory.toGiga()*0.8).toInteger()
```

Note that we defined a new `memory` variable, which was not there when the template was created. We are going to need this variable for abyss specfically, which requires a little bit less memory than what is allocated by the process, and it needs to be explicitly set. For this, to access the allocated memory set by the `label` block, we use the `task.memory` Nextflow variable, and then some extra **Nextflow** magic (`.toGiga()` and `.toInteger()` functions) to get only 80% of the allocated memory.

To access the input variables and other defined variables in the command execution block, the `$` symbol must be used to interpolate them. For example, to pass the reads to the tool, we would use `$reads`, which references the input variable declared in the `input:` block.
 
Another thing to note is that the number of threads in the command block of every tool should be explicitly set whenever possible. This should match the number of threads set by the `label` block. We can access the number of threads using the `$task.cpus` Nextflow variable. Check your tool arguments to see if there's an option to set the number of threads. For abyss is `j=`.

This is what the script block looks like taking into account all the above:

```groovy
    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def memory = (task.memory.toGiga()*0.8).toInteger()

    """
    abyss-pe \\
        $args \\
        j=$task.cpus \\
        B=${memory}G \\
        k=$kmersize \\
        in='${reads.join(" ")}' \\
        name=$prefix > log
    """
```

Note the `'${reads.join(" ")}'` in the command block instead of `$reads`, as both reads (forward and reverse) would be separated by commas, but abyss requires them to be separated by " ".

- `stub`. Stub process. This is used in dry runs. It will simply create empty files that match the name of the output files:

```
    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}-contigs.fa
    touch ${prefix}-scaffolds.fa
    touch ${prefix}-stats.tab
    touch log
    """
```

#### Unit testing



### Creating an nf-core local Module

If you want to add a module to your pipeline that runs a tool that is not available in the [nf-core modules page]().