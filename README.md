
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
- \parsecoordinate and \parsedifferential
- \IfInBoundsTF, \IfOutOfBoundsTF
- New loop constructs \Do, \DoUntilOutOfBounds, \DoUntilOutOfBoundsThenNMore
- \kill which kills a class without having to put a differential
- \lastclass as default arguments for \replaceclass, \classoptions, \d/\doptions, \structline/\structlineoptions
- Pin key for labels
- Families 
- Insert key for new classes allows control over relative class placement without reordering commands

### Changed:
- Ticks are now placed at values congruent to tick offset mod tick step, tick offset defaults to 0
- What was called "x axis style" is now called "x axis type".

### Fixed: 
- The \tagclass command works now.
- Scopes now nest properly.
- Fixed a big performance issue with nested scopes and shifts. 
- Adobe reader grid color is now correct (or more correct)
- Fixed the grid drawing so that grids are handled correctly when the range includes negative numbers
- The package now works with xparse after 2017/02/08 when changes were made that broke my original code
- Fixed a bug where if you used a structline in two sseqpage environments with the same name, it would give an error. 
- Now if you say \structline(0,0)(0,1) \structlineoptions(0,1)(0,0) it will work correctly.
- Big ranges like 0 - 600 now work, provided that you provide an appropriate scale
- Big range like 600 - 700 no longer will cause an overflow
- Labels now are rectangle nodes so they don't shift down if they are very wide
- Fixed a bug with ranges in sseqpage environment
