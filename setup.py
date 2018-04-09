#!/usr/bin/env python
# -*- coding: utf-8 -*-
from distutils import dir_util
from setuptools import setup, Command, find_packages
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
            call([npm, 'install', '--prefix=citkat/static'])
        else:
            print(
                "Error: npm executable not found.")
            exit(1)


class SpriteGeneration(Command):
    description = 'Generate sprites, must be called after NpmInstall'

    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        svgstore_path = 'citkat/static/node_modules/svgstore-cli/bin/svgstore'
        call([
            svgstore_path,
            '-o=citkat/static/node_modules/octicons/build/sprite.octicons.svg',
            'citkat/static/node_modules/octicons/build/svg/*.svg'
        ])


class develop(_develop):
    def run(self):
        self.run_command('NpmInstall')
        self.run_command('SpriteGeneration')
        _develop.run(self)


class clean(_clean):
    def run(self):
        if os.path.exists('citkat/static/node_modules/'):
            dir_util.remove_tree('citkat/static/node_modules/', dry_run=self.dry_run)
        _clean.run(self)


class build(_build):
    sub_commands = _build.sub_commands + [('NpmInstall', None)] + [('SpriteGeneration', None)]


setup(
    name='citkat',
    long_description=__doc__,
    packages=find_packages(exclude=('tests',)),
    include_package_data=True,
    zip_safe=False,
    author='Martin Wiechmann',
    author_email='mwiechmann@techfak.uni-bielefeld.de',
    url='https://opensource.cit-ec.de/projects/citk/repository/citkat',
    install_requires=[
        'flask>=0.12.2',
        'flask_restful>=0.3.6',
        'lxml>=4.1.1',
        'markdown>=2.6.10'
    ],
    cmdclass={
        'build': build,
        'develop': develop,
        'clean': clean,
        'bdist_egg': bdist_egg,
        'NpmInstall': NpmInstall,
        'SpriteGeneration': SpriteGeneration,
    },
    entry_points={
        'console_scripts': [
            'citkat = citkat.__init__:develop',
        ],
    },
    license='GPL',
)
