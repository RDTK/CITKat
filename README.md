# CITKat - A Web Catalog for CITK

## Installation
```shell
$ ./setup.py install --prefix=$HOME/.local
``` 
will install CITKat into your home folder and adds `citkat` to your `$PATH` environment.

### Dependencies
Besides the pip-dependencies (which will be resolved automatically for you) you'll have to install `npm`. 
The best way is to use your distribution's package manager to install `npm` 

## Usage
TODO

## CITKat XML Schema Documentation
You may generate the schema documentation by using the following command:
```shell
$ git submodule init && git submodule update  # get xs3p from submodule
$ xsltproc -o schema/CITKat.xsd.html xs3p/xs3p.xsl schema/CITKat.xsd
```