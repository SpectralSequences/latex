
spectralsequences v1.3.3
========================
Author: Hood Chatham  
Email: hood@mit.edu  
Date: 2023-01-28
License: All files have the Latex Project Public License.  
Description: Print spectral sequence diagrams using pgf/tikz.  


See the file manual/spectralsequencesmanual.pdf for a manual. See the examples
directory for a large number of example files. The current development copy is
hosted at https://github.com/SpectralSequences/latex. Open an issue on the
github issue tracker https://github.com/SpectralSequences/latex/issues/new to
submit bug reports, request new features, etc.

Changelog:
==========
## [1.3.3] (2023-01-28)

### Fixed:
- Fixed compatibility with pgf/tikz 3.1.0
- The manual was improperly truncated in v1.3.2, this has been fixed.

## [1.3.2] (2022-02-19)

### Fixed:
- Bent edges now enter the shapes at their endpoints at the correct angle.
- Fixed an incompatibility with versions of latex3 starting with 2022-01-12

## [1.3.1] (2022-01-04)

### Fixed:
- Extensions now should have all of the same features as structlines. Before, a
  bunch of things were missing or broken.
- Various issues with range checks for rotated figures are fixed.
- The `u` argument works again in `\DeclareSseqCommand` in versions of TeXLive
  prior to 2021.

## [1.3.0] (2021-07-18)
### Added:
- Added more control over page indicator in title and "print page as" key.
- Added `page=\infty`.
- Added `\extension` and `\extensionoptions`
- Added `\replacestructlines`
- Added `range check off`, `range check on`, and `range check sideways` global
  keys to control range checks. The `sideways` environment from `rotating`
  environment automatically uses `range check sideways` (issue #11). 

### Fixed:
- Removed `\replaceclass` in `{sseqpage}` without `keep changes` error (suggested by Junhou Fung).
- Fixed `\doptions` and `\structlineoptions` so that they can be used to add an edge label -- `needs tikz` wasn't handled correctly (reported by idlaviV)
- Fixed title positioning when the `xrange` that doesn't start at 0 (reported by Robert Burklund)
- Fixed relative tikz coordinates (reported by Dexter Chua).
- Fixed foreach loops nested inside of plain tikz commands (e.g., `\draw (0,0) foreach \x in {1,2,3} {--(\x,\x)};`)
- Fixed `this page structlines` (reported by Irina Bobkova)
- Fixed `fit classes` to accomodate new version of `\tikz@calc@anchor` in tikz version 3.1.5
- Fixed various other incompatiblities with latex3 with various versions of expl3.

### Changed:
- \replaceclass now pushes the class replaced onto the stack.

## [1.2.2] (2019-02-18)
### Fixed:
- expl3 defined \exp_after:NNNf recently, so I changed \cs_new:Npn \exp_after:NNNf to \cs_set:Npn \exp_after:NNNf and copied the definition given by
  expl3.
- expl3 changed the definition of \peek_meaning_ignore_spaces to be in terms of \peek_meaning so \letting \peek_meaning to \peek_meaning_ignore_spaces 
  caused an infite regress. 
- expl3 changed \c__xparse_no_value_tl to \c__novalue_tl, so now I try to use each of them in sequence.
- Fixed U argument type.
- \sseqnewfamily was broken by an update to tikz that added a \scantokens call to the .ecode key handler, causing issues with @.
- If \d was called without a source or target argument and was followed by a macro, \d would eat the first token of the expansion of that macro
  causing an error. 
- Draft mode works a lot better now, though it's probably still buggy.

## [1.2.1] (2018-10-08)
### Fixed:
- Tick style didn't work, now it does.
- Orphan edges are consistently oriented correctly now (reported by Eric Peterson).
- Fixed name class in copypage
- Fixed incompatibility with new expl3 version (reported by Eric Peterson). The fix amounts to replacing a \cs_new:Npn with a \cs_gset:Npn.

### Added:
- \sseqlastlabel

## [1.2.0] (2017-12-10)
### Added:
- \replacesource and \replacetarget
- \copypage
- "name handler" option
- \SseqAHSSNameHandler
- \SseqNormalizeMonomialSetVariables
- "show name" option
- predicates \IfExistsTF, \IfAliveTF, \IfValidDifferentialTF, and \DrawIfValidDifferentialTF
- "quiet" environment

### Changed:
- class label handlers now must output result into \result
- renamed \sseqnormalizemonomial to \SseqNormalizeMonomial, and now outputs into \result
- renamed \sseqifempty to \SseqIfEmptyTF 
- renamed \sseqerrortowarning to \SseqErrorToWarning
- tooltips now disabled unless you use the package option "tooltips" to prevent extraneous auxiliary files.

### Fixed:
- A bug that made "y axis gap" adjust both axes and "x axis gap" do nothing (reported by Achim Krause).
- A bug where a random definition of \\ was leaked into global scope (reported by Achim Krause).
- Now a \structline defined with option page=n will not be deleted by a shorter differential.
- A parser error that caused infinite recurse under certain conditions
- Class names now work with commands in their name (particularly, greek letters)
- \sseq@ifintexpr no longer breaks if the expression ends in \empty
- Using \sseqset to give default scaling values for xscale and yscale now works as expected.

    
## [1.1.1] (2017-09-18)

### Fixed:
- Groups defined with \SseqNewGroup now correctly handle arithmetic in their arguments.
- Labels inside a node now replace each other if two are given so you can make the label change on a given page with \classoptions (reported by Steve Wilson). 
- \kill had a bug in it that sometimes caused it to act on the wrong page (reported by Steve Wilson).


## [1.1.0] (2017-08-06)

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

## [1.0.0] (2017-06-21)
