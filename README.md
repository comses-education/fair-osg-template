# fair-osg-template

This template repository provides scaffolding and support for [Docker](https://docs.docker.com),
[Singularity](https://sylabs.io/singularity/), and the [Open Science Grid (OSG)](https://opensciencegrid.org/). A
Makefile is included to be customized with basic `build | deploy | clean` targets to build container images in Docker
and Singularity and copy the generated Singularity image and model files to the OSG login node.

You must have already gone through the OSG facilitation process with access to an Open Science Grid login node before
`% make deploy` will work and you should create an alias in your `.ssh/config` that assigns the name `osg` to your OSG
login node. E.g.,

```
Host osg
    HostName login02.osgconnect.net
    User <your-assigned-osg-username>
    IdentityFile ~/.ssh/a-private-ssh-key that you generated and added to your OSG profile on 
```

For more information on connecting to OSG and generating SSH keys, please see
https://support.opensciencegrid.org/support/solutions/articles/12000027675-generate-ssh-keys-and-activate-your-osg-login

## TODO LIST

### Documentation

- [ ] add narrative documentation in durable text formats (e.g., PDF with no special extensions, .odt OpenOffice Document file, Markdown / plaintext) about your computational model ideally with visual diagrams, flowcharts, etc., that describe expected inputs, outputs, assumptions, and consider adhering to a structured, domain-specific protocols like the [ODD Protocol for Describing Agent-Based and other Simulation Models](https://www.jasss.org/23/2/7.html) 
- [ ] include a README.md with a quick start for new users that addresses the following basic concerns:
- [ ] What does this model do?
- [ ] How do I run it?
- [ ] What are some example inputs? What are the expected outputs for those example inputs? Where do they live?
- [ ] How do I analyze or understand the outputs?
- [ ] What assumptions if any are embedded in the model?
- [ ] Is it possible to change or extend the model? (optional)

### Containerization and Scripts

- [ ] specify pinned software and system dependencies to be installed in Docker and Singularity
- [ ] identify an appropriate base image. You can use base images prefixed with `osg-` for common platforms
  like NetLogo, Julia, Python, and R at https://hub.docker.com/u/comses or create your own based on an OSG blessed
  image (e.g., https://github.com/opensciencegrid/osgvo-ubuntu-20.04
- [ ] customize job-wrapper.sh

### Running the model

There are two script files available. You can run a single simulation using a fixed parameter set using `scripts/OneRun.jl` as follows:

```bash
$ julia scripts/OneRun.jl
```

Results from this single run will be saved in a `results` folder as `singlerun.csv`.

The second option, `scripts/ParameterRuns.jl`, lets you run a parameter exploration experiment. The default setup of this experiment will run 2700 simulations. To modify the parameter values to be evaluated or the replicates for each combination, open `scripts/ParameterRuns.jl` and edit lines 11 to 14. Like the first option, you can run the script from bash:

```bash
$ julia scripts/ParameterRuns.jl
```

Results from this experiment will be saved in a `results` folder as `parameterexp.csv`. Both scripts take care of creating the `results` folder if it has not been created yet.

### Running on Open Science Grid
1. Establish an account on Open Science Grid
   https://osg-htc.org/research-facilitation/accounts-and-projects/general/index.html
2. Build a singularity image from this file via `./build.sh <your-osg-username>`
3. Copy the singularity image e.g., `spatialrust-v1.sif` to your OSG `/public/<username>` directory
