# docker-tensorflow
A Tensorflow Docker image that supports both GPU and CPU in the same image.

This image assumes that nvidia-docker (preferablly 2.0) is installed on the host OS.

The TensorFlow documentation states: 

> You must choose one of the following types of TensorFlow to install: **TensorFlow with CPU support only**, **TensorFlow with GPU Support**

With a TensorFlow docker image, it is desireable to target a host with CPU only as well as a host
with GPU. This repo supports this use case allowing a single Docker image that runs on either.

It does so by installing the base TensorFlow requirements into the system site-packages, creating 
virtual environments for CPU and GPU with visibiilty of the system site-package, and 
then installing the TensorFlow type into the corresponding virtual environment.

When running the image, an automatic determination of the desired
environment is made and a shell is started with that virtual environment
activated. 

