# Sciview Python 

## Environment Setup

### Setup Python 2.7 on your computer
We are using Python 2.7 because that's what is supported by TempoDB, plus there are lots of other very popular libraries that are not supported in 3.x yet.

This is a useful guide for setting up Python on a Mac: 
http://hackercodex.com/guide/python-development-environment-on-mac-osx/

### Setup a virtualenv for sciview-python with all of the necessary 3rd party libraries:
    # Make the python_app your working directory
    $ cd python_app
    
    # Create a spot to put all Python virtual environments (ideally outside of the python_app working directory)
    $ mkdir ~/virtualenvs
    
    # Create a virtual environment for this project
    $ virtualenv ~/virtualenvs/sciview-python
    
    # Activate this virtual environment
    $ source ~/virtualenvs/sciview-python/bin/activate
    
    # Install all of the required libraries for this project
    $ pip install -r requirements.txt

### Validate your environment works by running a simple TDMS viewer 
    $ python tdms-snippets.py

### Import a .tdms file to TempoDB 
Note: importing the EXAMPLE.tdms file could take a long time since there are millions of points in it

    $ python import-tdms.py ../data/EXAMPLE.tdms

## Useful Links

### Background info on Diadem and TDMS file format
https://docs.google.com/a/cleverpoint.co/document/d/1Z3bFPtesJgOk-gikw1GhwSMRLGher3IS0C23YBnWo1g/