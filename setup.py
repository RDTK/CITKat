#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from setuptools import setup
from setuptools.command.install import install
from subprocess import call
import os


class BowerInstall(install):
    @staticmethod
    def which(program):
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if os.path.isfile(exe_file) and os.access(exe_file, os.X_OK):
                return exe_file
        return None

    def run(self):
        yarn = self.which("yarn")
        if yarn:
            os.chdir('citkat/static')
            call([yarn, 'install'])
            os.chdir('../../')
            install.run(self)
        else:
            print(
                "Error: yarn executable not found. \n"
                "Try 'npm install --global yarn' or have a look at https://yarnpkg.com/en/docs/install")
            exit(1)


setup(
    name='citkat',
    version='0.1.0',
    long_description=__doc__,
    packages=['citkat'],
    include_package_data=True,
    zip_safe=False,
    author='Martin Wiechmann',
    author_email='mwiechmann@techfak.uni-bielefeld.de',
    url='https://opensource.cit-ec.de/projects/citk/repository/citkat',
    install_requires=[
        'flask>=0.12.2, <0.13',
        'flask_restful>=0.3.5, <0.4',
        'flask_bower>=1.3.0',
        # 'flask-bootstrap>=4, <5'  # Waiting for release...
    ],
    cmdclass={
        'install': BowerInstall,
    }
)
