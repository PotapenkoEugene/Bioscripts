#!/bin/bash
FILE=$1

jupyter nbconvert --to pdf --allow-chromium-download --TemplateExporter.exclude_input=True $FILE
