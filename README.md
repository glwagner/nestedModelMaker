# Overview

"nestedModelMaker" is a MATLAB code that generates grids, initial conditions, 
and open boundary conditions for MITgcm models that are nested within larger 
and coarser-resolution simulations and state estimates.

## News

*This code is under rapid and chaotic development. 
Anything is subject to change without warning.*

We are currently planning a major refactor of the code, so this may be bad time 
to start using it, and it is not a good time to start contributing. We are very
interested in contributors in the future! 

There are no examples at this time. Someday, hopefully, there will be.

## Ultimate goal

Ultimately the goal is to get as close to 'one-click' model generation' as possible, 
in the sense that all the user should have to do is to specify a 
latitude/longitude box, press enter, and let the code do the rest. 

The user will still have to do some work to compile and run the MITgcm simulation
itself, but will be relieved the tedious work of generating open boundary 
conditions, initial conditions, and the maddening task of aligning child
and parent boundaries whenever such alignment is required and possible.

# Installation

All that is required is to clone the git repository. The user does not have 
to add the code to their MATLAB path (nor is such recommended, necessarily, 
at least at this time). 

# Usage

The user's work flow proceeds as follows:

1. Create a new directory in the ``/models`` directory. 
Example: in a terminal navigated to the main repo directory, 
type ``mkdir ./models/newTestModel``.

2. Copy everything from ``/models/template`` into the new model directory.
Example: in a terminal navigated to the main repo directory, type 
``cp -r ./models/template/* ./models/newTestModel``

3. Edit the two scripts ``specifyChildProperties.m`` and ``specifyParentProperties.m`` 
in the model directory; for example in ``/models/newTestModel``. Many things may be
potentially specified at this time and there is no documentation except in the 
scripts themselves. The user must specify, for example:
    * Information about the parent model including the location of the data, 
the duration and time-stamps of the data, the horizontal and vertical grids, 
the coordinates, the resolution, and the bathymetry. We hope to simplify this aspect
of the work flow soon.
    * The location of the child model within the parent model.
    * Files that contain the vertical and horizontal grid information about the 
child model.
    * The nature of the boundaries of the child model.
    * Bathymetry files at child-grid resolution. 
    * Parameters imporant to MITgcm's numerical set-up.

Note that it should become simpler to specify the properties of the parent model
once a standard NetCDF format is decided upon in which the parent model data
must be supplied.

4. Open the script ``nestedModelMaker.m`` and rename ``child.name`` to the name 
of your new directory in ``/models``. For example, if the new model directory you 
created is ``/models/newTestModel``, then ensure that ``nestedModelMaker.m 
contains the line ``child.name = 'newTestModel';``.

5. Open MATLAB and run the script ``nestedModelMaker.m``. Brace yourself. 

# Developers

The project's main developers are [@glwagner][] and [@joernc][].


[@glwagner]: https://github.com/glwagner/
[@joernc]: https://github.com/joernc
