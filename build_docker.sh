#!/bin/bash
DOCKER_BUILDKIT=1 docker build --ssh default -t mcr_py_email_builder_service .