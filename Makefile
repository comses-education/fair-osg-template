# customize by creating a custom config.mk file or `% make build OSG_USERNAME=<your-osg-username>` e.g., `% make build OSG_USERNAME=alee`
include config.mk

# user to connect to OSG as
OSG_USERNAME := ${USER}
# name of this computational model
OSG_MODEL_NAME := ${OSG_MODEL_NAME}
# the directory (in the container) where the computational model source
# code or executable can be called, e.g., main.py | netlogo-headless.sh
MODEL_CODE_DIRECTORY := /srv/code
# entrypoint script to be called by job-wrapper.sh
ENTRYPOINT_SCRIPT := run.sh
# entrypoint script language
ENTRYPOINT_SCRIPT_EXECUTABLE := bash
# the OSG output file to be transferred
OSG_OUTPUT_FILES := results.tar.xz
# the submit file to be executed on OSG via `condor_submit ${OSG_SUBMIT_FILE}`
OSG_SUBMIT_FILENAME := ${OSG_MODEL_NAME}.submit
# the initial entrypoint for the OSG job, calls ENTRYPOINT_SCRIPT
OSG_JOB_SCRIPT := job-wrapper.sh

SINGULARITY_DEF := Singularity.def
CURRENT_VERSION := v1
SINGULARITY_IMAGE_NAME = ${OSG_MODEL_NAME}-${CURRENT_VERSION}.sif

all: build

$(SINGULARITY_IMAGE_NAME):
	singularity build --fakeroot ${SINGULARITY_IMAGE_NAME} ${SINGULARITY_DEF}

$(OSG_SUBMIT_FILENAME): submit.template
	echo "OSG USERNAME: ${SINGULARITY_USERNAME}"
	echo "SINGULARITY_IMAGE_NAME: ${SINGULARITY_IMAGE_NAME}"
	SINGULARITY_IMAGE_NAME=${SINGULARITY_IMAGE_NAME} \
	OSG_USERNAME=${OSG_USERNAME} \
	MODEL_CODE_DIRECTORY=${MODEL_CODE_DIRECTORY} \
	ENTRYPOINT_SCRIPT=${ENTRYPOINT_SCRIPT} \
	ENTRYPOINT_SCRIPT_EXECUTABLE=${ENTRYPOINT_SCRIPT_EXECUTABLE} \
	OUTPUT_FILES=${OSG_OUTPUT_FILES} \
	envsubst < submit.template > ${OSG_SUBMIT_FILENAME}

build: $(SINGULARITY_DEF) $(SINGULARITY_IMAGE_NAME) $(OSG_SUBMIT_FILENAME)
	docker build -t comses/${OSG_MODEL_NAME}:${CURRENT_VERSION} .

.PHONY: clean deploy

clean:
	rm -f ${SINGULARITY_IMAGE_NAME} ${OSG_SUBMIT_FILENAME} *~

deploy: build
	echo "IMPORTANT: This command assumes you have created an ssh alias in your ~/.ssh/config named 'osg' that connects to your OSG connect node"
	echo "Copying singularity image ${SINGULARITY_IMAGE_NAME} to osg:/public/${OSG_USERNAME}"
	rsync -avzP ${SINGULARITY_IMAGE_NAME} osg:/public/${OSG_USERNAME}
	echo "Creating ${OSG_MODEL_NAME} folder in /home/${OSG_USERNAME}"
	ssh ${OSG_USERNAME}@osg "mkdir -p ${OSG_MODEL_NAME}"
	echo "Copying submit filename, job script, and julia entrypoint scripts to /home/${OSG_USERNAME}/${OSG_MODEL_NAME}"
	rsync -avzP ${OSG_SUBMIT_FILENAME} ${OSG_JOB_SCRIPT} osg:${OSG_MODEL_NAME}/
	rsync -avzP scripts/ osg:${OSG_MODEL_NAME}/
