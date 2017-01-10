# post-processing

## Usage

**negotiationChart** - This matlab function is meant to be used after determininig two parties' criterion rankings through the Analytic Hierarchy Process. It accepts two parameters, a structure "s" and a boolean flag controlling whether the final negotiaion chart is displayed.

The structure **S** has the following format:

* struct.bids: Nx2 array with player 1 & 2 bids
* struct.crits: Nx2 array with player 1 & 2 criterion ranking
* struct.wtn: Nx2 array with player 1 & 2 Will To Negotiate (1-10 per criterion)
* struct.critNames: Nx1 cell array of criterion names (strings)
