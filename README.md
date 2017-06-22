
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

### Fixed: 
- The \tagclass command was broken. Now it works.
- Scopes didn't nest properly, now they do.
- Fixed a big performance issue with nested scopes and shifts. 
