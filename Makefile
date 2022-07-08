# customize on the command-line e.g.
# `% make OSG_USERNAME=<your-osg-username> MODEL_NAME=<your-model-name> clean deploy`

# user to connect to OSG as
OSG_USERNAME := ${USER}
# name of this computational model
MODEL_NAME := ${MODEL_NAME}
# the directory (in the container) where the computational model source
# code or executable can be called, e.g., main.py | netlogo-headless.sh
MODEL_CODE_DIRECTORY := /code
# entrypoint script to be called by job-wrapper.sh
ENTRYPOINT_SCRIPT := run.sh
# entrypoint script language
ENTRYPOINT_SCRIPT_EXECUTABLE := bash
# the OSG output file to be transferred
OUTPUT_FILES := results.zip
# OSG submit template
OSG_SUBMIT_TEMPLATE := scripts/submit.template
# the submit file to be executed on OSG via `condor_submit ${OSG_SUBMIT_FILE}`
OSG_SUBMIT_FILENAME := scripts/${MODEL_NAME}.submit
# the initial entrypoint for the OSG job, calls ENTRYPOINT_SCRIPT
OSG_JOB_SCRIPT := job-wrapper.sh

SINGULARITY_DEF := Singularity.def
CURRENT_VERSION := v1
SINGULARITY_IMAGE_NAME = ${MODEL_NAME}-${CURRENT_VERSION}.sif

.PHONY: clean deploy docker-build docker-run singularity-build singularity-run

all: build

$(SINGULARITY_IMAGE_NAME):
	singularity build --fakeroot ${SINGULARITY_IMAGE_NAME} ${SINGULARITY_DEF}

$(OSG_SUBMIT_FILENAME): $(OSG_SUBMIT_TEMPLATE)
	SINGULARITY_IMAGE_NAME=${SINGULARITY_IMAGE_NAME} \
	OSG_USERNAME=${OSG_USERNAME} \
	MODEL_CODE_DIRECTORY=${MODEL_CODE_DIRECTORY} \
	ENTRYPOINT_SCRIPT=${ENTRYPOINT_SCRIPT} \
	ENTRYPOINT_SCRIPT_EXECUTABLE=${ENTRYPOINT_SCRIPT_EXECUTABLE} \
	OUTPUT_FILES=${OUTPUT_FILES} \
	envsubst < ${OSG_SUBMIT_TEMPLATE} > ${OSG_SUBMIT_FILENAME}

docker-build: $(OSG_SUBMIT_FILENAME)
	docker build -t comses/${MODEL_NAME}:${CURRENT_VERSION} .

singularity-build: $(SINGULARITY_DEF) $(SINGULARITY_IMAGE_NAME)

build: docker-build singularity-build

clean:
	rm -f ${SINGULARITY_IMAGE_NAME} ${OSG_SUBMIT_FILENAME} *~

deploy: build
	echo "IMPORTANT: This command assumes you have created an ssh alias in your ~/.ssh/config named 'osg' that connects to your OSG connect node"
	echo "Copying singularity image ${SINGULARITY_IMAGE_NAME} to osg:/public/${OSG_USERNAME}"
	rsync -avzP ${SINGULARITY_IMAGE_NAME} osg:/public/${OSG_USERNAME}
	echo "Creating ${MODEL_NAME} folder in /home/${OSG_USERNAME}"
	ssh ${OSG_USERNAME}@osg "mkdir -p ${MODEL_NAME}"
	echo "Copying submit filename, job script, and entrypoint scripts to /home/${OSG_USERNAME}/${MODEL_NAME}"
	rsync -avzP scripts/ osg:${MODEL_NAME}/

docker-run: docker-build
	docker run --rm -it comses/${MODEL_NAME}:${CURRENT_VERSION} bash /code/scripts/run.sh

singularity-run: singularity-build
	singularity exec --bind ./singularity-data:/srv --pwd /code ${SINGULARITY_IMAGE_NAME} bash /code/scripts/run.sh
