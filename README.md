
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
```

Install the things I know I need 
```
apt-get update && apt-get install -y git \
	&& pip install --no-cache-dir pandas
```

Move to opt directory & clone the RepeatMasker repo (which housed the RM2Bedb.py script)
```
cd /opt/

git clone https://github.com/rmhubley/RepeatMasker.git
```

Pin the git repo to a specific commit
```
cd RepeatMasker
git reset --hard a58f3130a4fedb7784171a539052277d2cccc690
```

Copy to /opt and make the script executable
```
cd ..
cp RepeatMasker/util/RM2Bed.py .
chmod +x RM2Bed.py \
```

We only need the RM2Bed.py script, so get rid of everything else
```
rm -rf RepeatMasker
```

Add cwd to PATH
```
export PATH=/opt:$PATH
```

Test running the script
```
cd /working/
RM2Bed.py test_data/inputs/test_repeat_masked.fa.out
```
Looks good. We are read to turn the bash commands from above into a Dockerfile


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

RM2Bed.py \
    test_data/inputs/test_repeat_masked.fa.out \
    --out_prefix "test"

## looks good
rm test_rm.bed
```

