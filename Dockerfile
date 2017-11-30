FROM python:3.6.3 as builder

# add the various flavors of requirement files
ADD requirements.txt /requirements.txt
ADD requirements-gpu.txt /requirements-gpu.txt
ADD requirements-cpu.txt /requirements-cpu.txt
ADD setup-venv.py /setup-venv.py

# install the base requirements file into the global environment
RUN pip install -r /requirements.txt

# setup two virtual environments, one for CPU, one for GPU and install the env specific modules
RUN /setup-venv.py
RUN /bin/bash -c "source /cpu-env; pip install -r requirements-cpu.txt"
RUN /bin/bash -c "source /gpu-env; pip install -r requirements-gpu.txt"

# copy the module installations into the nvidia docker container (with python added)
FROM nvidia/cuda:8.0-cudnn6-runtime-ubuntu16.04

# setup the python environment and copy Python into this image
ENV PYTHON_VERSION 3.6.3
ENV PYTHON_PIP_VERSION 9.0.1
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib

# make some useful symlinks that are expected to exist
RUN ldconfig \
    && cd /usr/local/bin \
    && rm idle pydoc python python-config \
	&& ln -Fs idle3 idle \
	&& ln -Fs pydoc3 pydoc \
	&& ln -Fs python3 python \
	&& ln -Fs python3-config python-config

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		tcl \
		tk \
		libffi-dev \
	&& rm -rf /var/lib/apt/lists/*

# copy both the CPU and GPU virtual environments
COPY --from=builder /.cpu-env /.cpu-env
COPY --from=builder /.gpu-env /.gpu-env

# setup some useful symlinks
RUN ln -s /.cpu-env/bin/activate /cpu-env \
    && ln -s /.gpu-env/bin/activate /gpu-env

# add detection and venv activation to .bashrc
ADD .bashrc.additions /.bashrc.additions
RUN cat /.bashrc.additions >>/root/.bashrc \
    && rm /.bashrc.additions

ENTRYPOINT ["/bin/bash"]
