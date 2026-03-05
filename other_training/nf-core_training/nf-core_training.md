# nf-core training
 
Pre-requisites:
- Conda (miniconda)
- nf-core tools >= 3.5.1
- GitHub account
 
Install **conda** and **nf-core tools** if not yet installed
 
If conda not installed yet, download and install from [here](https://www.anaconda.com/download). Once conda is installed, install nf-core tools with the next command:
 
```
conda create -n nf-core -c bioconda nf-core=3.5.1
```

This will create a new conda environment with the latest nf-core tools version.

## nf-core Pipelines

### Create an nf-core Pipeline

Create pipeline using nf-core tools:
 
```
nf-core pipelines create
```

Follow the visual prompt instructions:

<img src="./Screenshot 2026-02-23 at 11.50.20.png"/>

Choose **"nf-core"** as **"pipeline type"**, even if it's not certain it'll become an official nf-core pipeline:

<img src="./Screenshot 2026-02-23 at 11.50.46.png"/>

The main difference between chosing **"nf-core"** and **"Custom"** are the CI checks when pushing changes to GitHub and opening a PR the **"nf-cre"** option includes, which makes later migrating the pipleine to the **official nf-core repo** easier.

Choose a name for the pipeline, add a brief description and the athor/s name:

<img src="./Screenshot 2026-02-23 at 11.51.54.png"/>

Don't worry about not being able to change the "nf-core" GitHub organisation. You will still be able to push the pipeline to your or your organisation GitHub account.

Select components and modules your pipeline might need. We recommend to keep at least the **nf-core schema** and **multiqc** components for every pipeline:

<img src="./Screenshot 2026-02-23 at 11.52.04.png"/>

Select the local directory where the pipeline will be created:

<img src="./Screenshot 2026-02-23 at 11.52.58.png"/>

The pipeline contents will be store inside a folder called `nf-core-<your_pipeline_name>`. Press **continue**:

<img src="./Screenshot 2026-02-23 at 11.53.16.png"/>

Finally, select **"Finish without creating a repo"**:

<img src="Screenshot 2026-02-23 at 11.53.25.png"/>

If the pipeline has been proposed and accepted as an nf-core pipeline in slack, the nf-core team will set up the pipeline repository. For more information, refer to the [nf-core page](https://nf-co.re/docs/tutorials/adding_a_pipeline/creating_a_pipeline).

If the pipeline has not been proposed or accepted yet, or you are unsure it'll become an official nf-core pipeline, you can create a new repository in your **GitHub personal page or organisation**, and push the pipeline there:

<img src="Screenshot 2026-03-04 at 13.32.32.png"/>

Change only the **General** fields. Use the pipeline's name as the repository name, and add a brief description, and choose whether you want the repo to be 'public' or 'private'. **Don't change the other fileds**:

<img src="Screenshot 2026-03-04 at 13.35.51.png"/>

Then, back in the command line, where our pipeline is located, do:
 
```
git remote add origin https://github.com/your_github/your_repo.git
git branch -M main
git push --all origin # Push all changes
```

Go back to the GitHub repository and refresh the page. It should be filled with the nf-core template and a `README.md`.

Instead of continuing with the repository we just created, we are going to fork an existing repository in the Eco-Flow GitHub page. Forking repositories is the stadard way to edit and make contributions to pipeline in collaborative environments:

<img src="Screenshot 2026-03-04 at 19.33.15.png"/>

Fork into your own GitHub or your organisation's account:

<img src="Screenshot 2026-03-04 at 19.33.15.png"/>

Fork all branches.

### The nf-core pipeline

Once we forged the repo, we can open it in a cloud development environment called **Codespaces**. Every nf-core pipeline comes with a `.devcontainer` folder that has the necessary configuration to run **nextflow**, **docker**, **nf-core tools**:

Before continuing, change the docker API version typing this in the command line: `export DOCKER_API_VERSION=1.43`.

We don't want to work on our `dev` branch, even if we are on our own fork. So create a new branch:

```
git switch -c new_branch
```

Now we can start making changes to our pipeline. Here, we are going to focus on the skeleton of our pipeline, which is our **main workflow**. But first let's inspect the `main.nf` file:

- **Runs a validation subworkflow**: Input validation using the input schema (prepares the input channel).
- **Runs the main workflow**.
- **Runs a completition subworkflow** (completition hooks).

```groovy
#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/training
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/training
    Website: https://nf-co.re/training
    Slack  : https://nfcore.slack.com/channels/training
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { TRAINING  } from './workflows/training'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_training_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_training_pipeline'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_TRAINING {

    take:
    samplesheet // channel: samplesheet read in from --input

    main:

    //
    // WORKFLOW: Run pipeline
    //
    TRAINING (
        samplesheet
    )
    emit:
    multiqc_report = TRAINING.out.multiqc_report // channel: /path/to/multiqc_report.html
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input,
        params.help,
        params.help_full,
        params.show_hidden
    )

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_TRAINING (
        PIPELINE_INITIALISATION.out.samplesheet
    )
    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        NFCORE_TRAINING.out.multiqc_report
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
```

Note the first workflow `NFCORE_TRAINING` definition is not actually necessary, we could remove it the pipeline will still work. You should not change edit the `main.nf`, as it is written using nf-core standards and only serves a as pipeline switch.
 
#### The `workflow/training.nf`:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_training_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow TRAINING {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    main:

    ch_versions = channel.empty()
    ch_multiqc_files = channel.empty()

    //
    // Collate and save software versions
    //
    def topic_versions = Channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'training_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        channel.fromPath(params.multiqc_config, checkIfExists: true) :
        channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        []
    )

    emit:
    multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
```

You can see that some modules and components are imported by default. Again, these are plugins that serve the purpose of collecting the versions of modules, run summaries, etc. We can dismiss them as they work straight away.

We see a workflow defition as usual, with the input definiton (`take:`), the `main:` where modules are other workflows are coalled, and the output definition (`emit:`), that helps us access the modules/subworklow outputs.

The `ch_samplesheet` channel comes from the **input samplesheet**. To see an example of how the input samplesheet looks like, check the `assets/samplesheet.csv` file. This samplesheet is parsed by the **input validation plugin** -localted inside `subworkflows/local/utils_nfcore_training_pipeline/main.nf` in every nf-core pipepline-, using the `input_schema.json`, and tranformed into a channel. This is where this happens:

```groovy
    channel
        .fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_input.json"))
        .map {
            meta, fastq_1, fastq_2 ->
                if (!fastq_2) {
                    return [ meta.id, meta + [ single_end:true ], [ fastq_1 ] ]
                } else {
                    return [ meta.id, meta + [ single_end:false ], [ fastq_1, fastq_2 ] ]
                }
        }
        .groupTuple()
        .map { samplesheet ->
            validateInputSamplesheet(samplesheet)
        }
        .map {
            meta, fastqs ->
                return [ meta, fastqs.flatten() ]
        }
        .set { ch_samplesheet }
```

In this case a function is also applied to the channel to set the channels as **single-end** or **paired-end** depending on whether both FASTQs are input or just one.

Once the samplesheet is parsed, we get an input channel with a struture (the tuple `[ meta, reads ]`) that is usable as the input for most modules that have FASTQs as inputs. In other words, **this is the standard channel structure** for nf-core modules that process read data.

Now, let's intall the `FASTP` module for read filtering using nf-core tools:
 
```
nf-core modules install fastp
```
 
Let's install the `FASTQ` module to check the quality of the processed reads:

```
nf-core modules install fastqc
```

Once both modules have been installed, import the modules inside `workflows/training.nf`:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FASTP } from '../modules/nf-core/fastp/main'
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_training_pipeline'
```

Now we are going to call the modules in the `main:` block. Like it was mentioned before, the tuple `[ meta, reads ]` is the standard channel structure for most nf-core modules, and our channel already follows this structure, so we can probably use `ch_samplesheet` channel straight away without any modifications:

```groovy
    FASTP(
        ch_samplesheet
    )
```

Run the pipeline using the `test` profile:

```
nextflow run main.nf -profile test,docker --outdir results -resume -bg > log
```

We get an error:

```
Process `NFCORE_TRAINING:TRAINING:FASTP` declares 4 inputs but was called with 1 argument
```

Let's inspect the `input:` block of the module. Looks like we will have to change the channel structure a it requires a tuple with three elements (from `[ meta, reads, adapter ]` -> `[ meta, reads, adapter ]`), and there are also other 3 aditional inputs besides the reads input channel. The `adapter` and the 3 aditional inputs are optional (I know becuase I looked into the module before), but, because of how Nextflow is built, these values need to be **explicitly set** and can't just be ignore. So instead, we are going to input them as empty values. Let's change the structure using the `.map` operator and input the empty values:

```groovy
    //
    // MODULE: Run FASTP
    //

    ch_samplesheet = ch_samplesheet.map { meta, reads -> [ meta, reads, [] ] }

    FASTP(
        ch_samplesheet,
        [],
        [],
        []
    )
```

Now we can run the pipeline successfully.

The next step is to chain modules, which is the basis of a nextflow/nf-core pipeline. We are going to use the output of `FASTP` as the input of `FASTQC`. For this, we will have to inspect the `output:` block of `FASTP`:

```groovy
    output:
    tuple val(meta), path('*.fastp.fastq.gz') , optional:true, emit: reads
    tuple val(meta), path('*.json')           , emit: json
    tuple val(meta), path('*.html')           , emit: html
    tuple val(meta), path('*.log')            , emit: log
    tuple val(meta), path('*.fail.fastq.gz')  , optional:true, emit: reads_fail
    tuple val(meta), path('*.merged.fastq.gz'), optional:true, emit: reads_merged
    tuple val("${task.process}"), val('fastp'), eval('fastp --version 2>&1 | sed -e "s/fastp //g"'), emit: versions_fastp, topic: versions
```

We only cared about the process reads, which is the first output channel, emited as `reads`. The `emit:` option allow us to easily access the outputs of modules.

We can see the the output channel follows the convention `[ meta, reads ]`, which means we can porbably use it as the input of `FASTQ`:

```groovy
    //
    // MODULE: Run FASTP
    //

    ch_samplesheet = ch_samplesheet.map { meta, reads -> [ meta, reads, [] ] }

    FASTP(
        ch_samplesheet,
        [],
        [],
        []
    )

    //
    // MODULE: Run FastQC
    //
    FASTQC (
        FASTP.out.reads
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
```

And run the pipeline again using the `test` profile. We can see the pipeline is working as expected, and the output of the processed reads are used as the input of `FASTQC`.

#### Open Pull Request

Once changes have been made to the pipeline, is time to push our changes to our fork, and open a Pull Reques. You can use the command line to push your changes:

```
# First remove the log file as we don't want to push it
rm log
# Add all files using the "*" wildcard
git add *
# Commit changes
git commit -m "Added read processing"
# Push changes
git push origin new_branch
```

Now go to your fork and open a Pull Request:

<img src="Screenshot 2026-03-05 at 00.44.11.png"/>

<!--

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



Run the pipeline again. Done! -->

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

Note the `'${reads.join(" ")}'` in the command block instead of `$reads`. By default, the forward and reverse reads are comma-separated in the input tuple, but ABySS requires them to be separated by spaces (`" "`).

- `stub`. Stub process. This is used in dry runs. It will simply create empty files that match the name of the output files:

```groovy
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

### Unit testing

Let's inspect the `main.nf.test` created by default, which will contain the code for **unit testing**:

```groovy
// TODO nf-core: Once you have added the required tests, please run the following command to build this file:
// nf-core modules test kmergenie
nextflow_process {

    name "Test Process KMERGENIE"
    script "../main.nf"
    process "KMERGENIE"

    tag "modules"
    tag "modules_nfcore"
    tag "kmergenie"

    // TODO nf-core: Change the test name preferably indicating the test-data and file-format used
    test("sarscov2 - bam") {

        // TODO nf-core: If you are created a test for a chained module
        // (the module requires running more than one process to generate the required output)
        // add the 'setup' method here.
        // You can find more information about how to use a 'setup' method in the docs (https://nf-co.re/docs/contributing/modules#steps-for-creating-nf-test-for-chained-modules).

        when {
            process {
                """
                // TODO nf-core: define inputs of the process here. Example:
                
                input[0] = [
                    [ id:'test' ],
                    file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/bam/test.paired_end.sorted.bam', checkIfExists: true),
                ]
                """
            }
        }

        then {
            assert process.success
            assertAll(
                { assert snapshot(
                    process.out,
                    path(process.out.versions[0]).yaml
                ).match() }
                //TODO nf-core: Add all required assertions to verify the test output.
                // See https://nf-co.re/docs/contributing/tutorials/nf-test_assertions for more information and examples.
            )
        }

    }

    // TODO nf-core: Change the test name preferably indicating the test-data and file-format used but keep the " - stub" suffix.
    test("sarscov2 - bam - stub") {

        options "-stub"

        when {
            process {
                """
                // TODO nf-core: define inputs of the process here. Example:
                
                input[0] = [
                    [ id:'test' ],
                    file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/bam/test.paired_end.sorted.bam', checkIfExists: true),
                ]
                """
            }
        }

        then {
            assert process.success
            assertAll(
                { assert snapshot(
                    process.out,
                    path(process.out.versions[0]).yaml
                ).match() }
            )
        }

    }

}

```

The first section of the script is the process declaration:

```groovy
nextflow_process {

    name "Test Process KMERGENIE"
    script "../main.nf"
    process "KMERGENIE"
```

Where the script defines the process (`"Test Process KMERGENIE"`), points to the `main.nf` of the module, and specifies the process name to test `"KMERGENIE"`. We can leave it as it is.

Next are the tags:

```groovy
    tag "modules"
    tag "modules_nfcore"
    tag "kmergenie"
```

Their purpose is to organize tests into categories for selective running. More tags can be added if whished.

Next, we have the test definition:

```groovy
    test("sarscov2 - bam") {

        // TODO nf-core: If you are created a test for a chained module
        // (the module requires running more than one process to generate the required output)
        // add the 'setup' method here.
        // You can find more information about how to use a 'setup' method in the docs (https://nf-co.re/docs/contributing/modules#steps-for-creating-nf-test-for-chained-modules).

        when {
            process {
                """
                // TODO nf-core: define inputs of the process here. Example:
                
                input[0] = [
                    [ id:'test' ],
                    file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/bam/test.paired_end.sorted.bam', checkIfExists: true),
                ]
                """
            }
        }

        then {
            assert process.success
            assertAll(
                { assert snapshot(
                    process.out,
                    path(process.out.versions[0]).yaml
                ).match() }
                //TODO nf-core: Add all required assertions to verify the test output.
                // See https://nf-co.re/docs/contributing/tutorials/nf-test_assertions for more information and examples.
            )
        }

    }
```

If possible, name the test indicating where the nature test-data (humna, bacterial, viral...), as well as the format.

Now we are going to edit the blocks inside the test definition. The first block is the `when` block, where the input test data is set:

```groovy
    test("sarscov2 - fatq") {

        when {
            process {
                """
                input[0] = [
                    [ id:'test', single_end:false ], // meta map
                    [
                        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true),
                        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_2.fastq.gz', checkIfExists: true)
                    ]
                ]
                input[1] = 50
                """
            }
        }
```

Our module inputs paired-end reads, this we need paired end data. To make things easier, we can check a module that uses paired-end data, and use the same input test data. Here, the [`BWA_MEM` module](https://github.com/nf-core/modules/blob/master/modules/nf-core/bwa/mem/tests/main.nf.test) was used to get the input test data, for example. We also had another input, the kamersize, which we randomly set to `50`. Note that to define the inputs we use and index system, instead of the tuple definition used in the module.

The next block is the assertion block. This is where we are going to assert the test outputs, which are the same as the process outputs. The way to accesss and asset the outputs is using `process.out`:

```groovy
        then {
            assert process.success // T
            assertAll(
                { assert snapshot(
                    process.out.contigs,
                    process.out.scaffolds,
                    process.out.stats,
                    process.out.log
                ).match() }
            )
        }
```

This will create a snapshot the first time the module is test. Everytime the test is run, the assertions will compare the output files against this snapshot.

Repeat the process for the `-stub` test:

```groovy
    test("sarscov2 - fastq - stub") {

        options "-stub"

        when {
            process {
                """
                input[0] = [
                    [ id:'test', single_end:false ], // meta map
                    [
                        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_1.fastq.gz', checkIfExists: true),
                        file(params.modules_testdata_base_path + 'genomics/sarscov2/illumina/fastq/test_2.fastq.gz', checkIfExists: true)
                    ]
                ]
                input[1] = 50
                """
            }
        }

        then {
            assert process.success
            assertAll(
                { assert snapshot(
                    process.out.contigs,
                    process.out.scaffolds,
                    process.out.stats,
                    process.out.log
                ).match() }
            )
        }

    }
```

<!--

### Creating an nf-core local Module

If you want to add a module to your pipeline that runs a tool that is not available in the [nf-core modules page]().

-->