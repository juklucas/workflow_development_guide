
This repo provides instructions on how to create a Dockerfile and WDL on your local machine.

# Create Docker Container (Dockerfile)

## Test Commands To Create Dockerfile
Start out by selecting which Docker container I want to build off of. 
Once I know that, we can start to install tools while in the container. The bash commands
that we use will be what makes it into our Dockerfile.

Lauch the base container:
```
docker run \
    -i \
    -t \
    -v ${PWD}:/working \
    python:3.8-slim \
    /bin/bash

## Install the things I know I need 
apt-get update && apt-get install -y git \
	&& pip install --no-cache-dir pandas

## Move to opt directory & clone the RepeatMasker repo (which has the RM2Bedb.py script)
cd /opt/

git clone https://github.com/rmhubley/RepeatMasker.git

## Pin the git repo to a specific commit
cd RepeatMasker
git reset --hard a58f3130a4fedb7784171a539052277d2cccc690

## Copy to /opt and make the script executable
cd ..
cp RepeatMasker/util/RM2Bed.py .
chmod +x RM2Bed.py \

## We only need the RM2Bed.py script, so get rid of everything else
rm -rf RepeatMasker

## Add cwd to PATH
export PATH=/opt:$PATH

## Test running the script
cd /working/
RM2Bed.py test_data/inputs/test_repeat_masked.fa.out

## Looks good. We are read to turn the bash commands from above into a Dockerfile
exit 
```


## Create Dockerfile

Dockerfile looks like this 
```
FROM python:3.8-slim

MAINTAINER Julian Lucas, juklucas@ucsc.edu

RUN apt-get update && apt-get install -y git \
    && pip install --no-cache-dir pandas

## Install rm2bed.py
WORKDIR /opt/

RUN git clone https://github.com/rmhubley/RepeatMasker.git \
    && cd RepeatMasker \
    && git reset --hard a58f3130a4fedb7784171a539052277d2cccc690 \
    && cd .. \
    && cp RepeatMasker/util/RM2Bed.py . \
    && chmod +x RM2Bed.py \
    && rm -rf RepeatMasker

ENV PATH=/opt:$PATH

WORKDIR /data
```

Build the container
```
docker build -t juklucas/rm2bed:latest docker/.
```

Test running it
```
## Launch container
docker run \
    -i \
    -t \
    -v ${PWD}:/working \
    juklucas/rm2bed:latest \
    /bin/bash

cd /working/

RM2Bed.py test_data/inputs/test_repeat_masked.fa.out

## looks good

rm test_rm.bed
exit
```

# Write WDL

After writing first draft of WDL, check with womtool
```
womtool \
    validate \
    rm2bed.wdl
```

If it works, we can create a json file to test/run WDL
```
womtool \
    inputs \
    rm2bed.wdl \
    > rm2bed.inputs.json
```

Inputs json looks like this
```
{
  "rm2bed_workflow.rm2bed.output_file_tag": "String",
  "rm2bed_workflow.rm2bed.dockerImage": "String (optional, default = \"juklucas/rm2bed:latest\")",
  "rm2bed_workflow.rm2bed.rm_out_file": "File",
  "rm2bed_workflow.rm2bed.diskSizeGB": "Int (optional, default = 64)",
  "rm2bed_workflow.rm2bed.sample_name": "String",
  "rm2bed_workflow.rm2bed.memSizeGB": "Int (optional, default = 4)"
}
```
Open text editor, enter values, and get rid of optional parameters
```
{
  "rm2bed_workflow.rm2bed.output_file_tag": "out_tag",
  "rm2bed_workflow.rm2bed.rm_out_file": "test_data/inputs/test_repeat_masked.fa.out",
  "rm2bed_workflow.rm2bed.sample_name": "test"
}
```

Run WDL
```
cromwell \
    run \
    rm2bed.wdl \
    --inputs rm2bed.inputs.json
```

## Update on GitHub

```
git add -A
git commit -m "initial commit"

git push
```