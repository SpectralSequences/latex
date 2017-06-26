
spectralsequences v1.0.0-dev
========================
Author: Hood Chatham  
Email: hood@mit.edu  
Date: 2017-06-21  
License: All files have the Latex Project Public License.  
Description: Print spectral sequence diagrams using pgf/tikz.  


See the file manual/spectralsequencesmanual.pdf for a manual. See the examples directory for a large number of example files.
Email me at hood@mit.edu to submit bug reports, request new features, etc. The current development copy is hosted at https://github.com/hoodmane/spectralsequences. 

Changelog:
==========
    
## [Unreleased] 

### Added:
- \sseqparseint
- \IfInBoundsTF, \IfOutOfBoundsTF
- \Do, \DoUntilOutOfBounds, \DoUntilOutOfBoundsThenNMore
- Defaults for \structline: a single missing coordinate is replaced with \lastclass, if both are missing, same as \structline(\lastclass1)(\lastclass)

### Fixed: 
- The \tagclass command was broken. Now it works.
- Scopes didn't nest properly, now they do.
- Fixed a big performance issue with nested scopes and shifts. 
- Adobe reader grid color is now correct
- The package now works with xparse after 2017/02/08 when changes were made that broke my original code
- Fixed a bug where if you used a structline in two sseqpage environments with the same name, it would give an error. 
- Now if you say \structline(0,0)(0,1) \structlineoptions(0,1)(0,0) it will work correctly.
