
spectralsequences v1.1.1
========================
Author: Hood Chatham  
Email: hood@mit.edu  
Date: 2017-11-10  
License: All files have the Latex Project Public License.  
Description: Print spectral sequence diagrams using pgf/tikz.  


See the file manual/spectralsequencesmanual.pdf for a manual. See the examples directory for a large number of example files.
Email me at hood@mit.edu to submit bug reports, request new features, etc. The current development copy is hosted at https://github.com/hoodmane/spectralsequences. 

Changelog:
==========
## [Unreleased]
### Added:
- Added copypage
- Added name handler
- Added "show names"

### Changed:
-

### Fixed:
- A bug that made "y axis gap" adjust both axes and "x axis gap" do nothing (thanks Achim).
- A bug where a random definition of \\ was leaked into global scope.
    
## [1.1.1]

### Fixed:
- Groups defined with \SseqNewGroup now correctly handle arithmetic in their arguments.
- Labels inside a node now replace each other if two are given so you can make the label change on a given page with \classoptions (reported by Steve Wilson). 
- \kill had a bug in it that sometimes caused it to act on the wrong page (reported by Steve Wilson).


## [1.1.0] 

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
- Draw differentials from a range of pages.
- Frame axis type, tick marks.

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
- Fixed a bug with ranges and the sseqpage environment where classes lying outside the printed range would enlarge the range even if an explicit range was specified.
- The chess grid works correctly now

