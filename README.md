CMake Modules [![Build Status](https://travis-ci.com/BoostCMake/cmake_modules.svg?branch=master)](https://travis-ci.com/BoostCMake/cmake_modules)
===

Motivation
----------

This provides cmake modules suitable for in-project and in-repository dependencies management. It provides modules to reduce the boilerplate for installing, versioning, setting up package config, and creating tests.

Usage
-----

The modules can be installed using standard cmake install:

    mkdir build
    cd build
    cmake ..
    cmake --build . --target install

Once installed, the modules can be used by using `find_package` and then including the appropriate module:

    find_package(CM)
    include(CMPackage)

Documentation
-------------

http://bcm.readthedocs.io

