# Sciview Python 

## Environment Setup

### Setup Python 2.7 on your computer
We are using Python 2.7 because that's what is supported by TempoDB, plus there are lots of other very popular libraries that are not supported in 3.x yet.

This is a useful guide for setting up Python on a Mac: 
http://hackercodex.com/guide/python-development-environment-on-mac-osx/

### Setup a virtualenv for sciview-python with all of the necessary 3rd party libraries:
$ cd python_app
$ mkdir ~/virtualenvs
$ virtualenv ~/virtualenvs/sciview-python
$ pip install -r requirements.txt

### Validate your environment works by running a simple TDMS viewer 
$ python tdms-snippets.py

## Useful Links

### Background info on Diadem and TDMS file format
https://docs.google.com/a/cleverpoint.co/document/d/1Z3bFPtesJgOk-gikw1GhwSMRLGher3IS0C23YBnWo1g/