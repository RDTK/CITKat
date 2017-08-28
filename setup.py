#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from setuptools import setup, Command
from setuptools.command.install import install
from setuptools.command.develop import develop
from subprocess import call
import os
from distutils.command.build import build as _build
from setuptools.command.bdist_egg import bdist_egg as _bdist_egg


def which(program):
    for path in os.environ["PATH"].split(os.pathsep):
        path = path.strip('"')
        exe_file = os.path.join(path, program)
        if os.path.isfile(exe_file) and os.access(exe_file, os.X_OK):
            return exe_file
    return None


class bdist_egg(_bdist_egg):
    def run(self):
        self.run_command('NpmInstall')
        _bdist_egg.run(self)


class NpmInstall(Command):
    description = 'NPM install'

    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        npm = which("npm")
        if npm:
            os.chdir('citkat/static')
            call([npm, 'install'])
            os.chdir('../../')
        else:
            print(
                "Error: npm executable not found.")
            exit(1)


class build(_build):
    sub_commands = _build.sub_commands + [('NpmInstall', None)]


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
        'Flask-AutoIndex',
        'lxml'
        # 'flask-bootstrap>=4, <5'  # Waiting for release...
    ],
    cmdclass={
        'build': build,
        'bdist_egg': bdist_egg,
        'NpmInstall': NpmInstall,
    },
    entry_points={
        'console_scripts': [
            'citkat = citkat.citkat:main',
        ],
    },
    license='GPL',
)
