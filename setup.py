#!/usr/bin/env python2
# -*- coding: utf-8 -*-
from distutils import dir_util
from setuptools import setup, Command
from subprocess import call
import os
from distutils.command.build import build as _build
from setuptools.command.bdist_egg import bdist_egg as _bdist_egg
from setuptools.command.develop import develop as _develop
from distutils.command.clean import clean as _clean


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


class develop(_develop):
    def run(self):
        self.run_command('NpmInstall')
        _develop.run(self)


class clean(_clean):
    def run(self):
        if os.path.exists('citkat/static/node_modules/'):
            dir_util.remove_tree('citkat/static/node_modules/', dry_run=self.dry_run)
        _clean.run(self)


class build(_build):
    sub_commands = _build.sub_commands + [('NpmInstall', None)]


setup(
    name='citkat',
    version='0.1.2',
    long_description=__doc__,
    packages=['citkat'],
    include_package_data=True,
    zip_safe=False,
    author='Martin Wiechmann',
    author_email='mwiechmann@techfak.uni-bielefeld.de',
    url='https://opensource.cit-ec.de/projects/citk/repository/citkat',
    install_requires=[
        'flask>=0.12.2',
        'flask_restful>=0.3.5',
        'Flask-AutoIndex',
        'lxml>=4.0'
        # 'flask-bootstrap>=4, <5'  # Waiting for release...
    ],
    cmdclass={
        'build': build,
        'develop': develop,
        'clean': clean,
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
