# fair-osg-template

This template repository provides scaffolding and support for [Docker](https://docs.docker.com),
[Singularity](https://sylabs.io/singularity/), and the [Open Science Grid (OSG)](https://opensciencegrid.org/). A
Makefile is included to be customized with basic `build | deploy | clean` targets to build container images in Docker
and Singularity and copy the generated Singularity image and model files to the OSG login node.

# TODO LIST

## FAIR4RS Principles

More details at https://doi.org/10.15497/RDA00068 and [this template repository's wiki](https://github.com/comses-education/fair-osg-template/wiki/FAIR-Principles-for-Research-Software)

- [ ] Findable: create a persistent identifier for each released / published version of the software
- [ ] Accessible: make your software open source (good start, using this!), ensure that it is well documented with descriptive metadata and narrative documentation, and make sure that this metadata remains accessible even if the software is not
- [ ] Interoperable: your software should read, write, and exchange data using domain-relevant *open* community standards (e.g., netCDF, HDF, CSVs, etc.)
- [ ] Reusable: Software can be executed and understood, modified, built upon, or incorporated into other software - a clear and accessible license, detailed provenance metadata, qualified persistent references to other software dependencies, domain-relevant community standards

## Documentation

- [ ] add narrative documentation in durable text formats (e.g., PDF with no special extensions, .odt OpenOffice Document file, Markdown / plaintext) about your computational model ideally with visual diagrams, flowcharts, etc., that describe expected inputs, outputs, assumptions, and consider adhering to a structured, domain-specific protocols like the [ODD Protocol for Describing Agent-Based and other Simulation Models](https://www.jasss.org/23/2/7.html) 
- [ ] include a README.md with a quick start for new users that addresses the following basic concerns:
- [ ] What assumptions if any are embedded in the model?
- [ ] Is it possible to change or extend the model?

## Containerization and Scripts

- [ ] specify pinned software and system dependencies to be installed in Docker and Singularity
- [ ] identify an appropriate base image. You can use base images prefixed with `osg-` for common platforms
  like NetLogo, Julia, Python, and R at https://hub.docker.com/u/comses or create your own based on an OSG blessed
  image (e.g., https://github.com/opensciencegrid/osgvo-ubuntu-20.04
- [ ] customize job-wrapper.sh

## How to run this model

- [ ] What does this model do?
- [ ] How do I run it?
- [ ] What are some example inputs? What are the expected outputs for those example inputs? Where do they live?
- [ ] How do I analyze or understand the outputs?

## Running on the Open Science Grid

### Set up your user account on the Open Science Grid 

https://osg-htc.org/research-facilitation/accounts-and-projects/general/index.html

You must have already gone through the OSG facilitation process with access to an Open Science Grid login node before
`% make deploy` will work and you should create an alias in your `.ssh/config` that assigns the name `osg` to your OSG
login node.

For example,

```
Host osg
    HostName login02.osgconnect.net
    User <your-assigned-osg-username>
    IdentityFile ~/.ssh/a-private-ssh-key that you generated and added to your OSG profile
```

For more information on connecting to OSG and generating SSH keys, please see
https://support.opensciencegrid.org/support/solutions/articles/12000027675-generate-ssh-keys-and-activate-your-osg-login

### Customize entry point scripts and model metadata

```
# user to connect to OSG as
OSG_USERNAME := ${USER}
# name of this computational model, used as the namespace (for singularity, Docker, and as a folder to keep things
# organized on the OSG filesystem login node). recommend that you use all lowercase alphanumeric with - or _ to
# separate words, e.g., chime-abm or spatial-rust-model
MODEL_NAME := ${OSG_MODEL_NAME}
# the directory (in the container) where the computational model source
# code or executable can be called, e.g., main.py | netlogo-headless.sh
MODEL_CODE_DIRECTORY := /code
# entrypoint script to be called by job-wrapper.sh
ENTRYPOINT_SCRIPT := /srv/run.sh
# entrypoint script language
ENTRYPOINT_SCRIPT_EXECUTABLE := bash
# the OSG output file to be transferred
OSG_OUTPUT_FILES := output,results
# the submit file to be executed on OSG via `condor_submit ${OSG_SUBMIT_FILE}`
OSG_SUBMIT_FILENAME := ${OSG_MODEL_NAME}.submit
# the initial entrypoint for the OSG job, calls ENTRYPOINT_SCRIPT
OSG_JOB_SCRIPT := job-wrapper.sh
```

(TODO: set data via cookiecutter and cookiecutter.json in cookiecutter project + document further)

These can be customized in the make command.

Then run

`make OSG_USERNAME=<your-username> build`

to build Docker + Singularity images with the model + dependencies embedded or

`make OSG_USERNAME=<your-username> clean deploy`

to build and then copy the images to your OSG login node and public directory.

## Input and Output Files

OSG defaults transfer all generated output files. If your model generates all files in a given directory, say `output` and/or `results`, something like

`transfer_output_files = output,results`

should work, e.g., a comma separated list of 

For more information, see https://htcondor.readthedocs.io/en/latest/users-manual/file-transfer.html#specifying-what-files-to-transfer




