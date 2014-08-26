###############################################################################
Copyright (C) 2014 Y. Billeh, M. Schaub

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

###############################################################################

-------------------------------------------------------------------------------
Revealing cell assemblies at multiple levels of granularity
-------------------------------------------------------------------------------

The code implements the cell assembly detection method as introduced in 

"Revealing cell assemblies at multiple levels of granularity"
Billeh, Y. N.; Schaub, M. T.; Anastassiou, C. A.; Barahona, M. & Koch, C.
Journal of Neuroscience Methods (2014), in press 

The code consists of two parts. (i) A method to compute a functional 
connectivity matrix (FCM) from given spike train data. (ii) The clustering of
this FCM with the help of the Markov Stability framework for community 
detection. More details on the latter can be found in

[1] "Stability of graph communities across time scales" 
Delvenne, J.-C.; Yaliraki, S. N. & Barahona, M. 
Proceedings of the National Academy of Sciences, 2010, 107, 12755-12760;

[2] J.-C. Delvenne, M. T. Schaub, S. N. Yaliraki, and M. Barahona, 
"The stability of a graph partition: A dynamics-based framework for community 
detection" in Time Varying Dynamical Networks (N. Ganguly, A. Mukherjee, 
M. Choudhury, F. Peruani, and B. Mitra, eds.), Birkhauser, Springer,
2012.



The script "Example.m" contains the code to analyse two example datasets, taken
from the paper, to demonstrate the main functionality of the method.

(i)  Figure4.mat : Data for Figure 4  
(ii) Figure6.mat : Data for Figure 6

Further example data sets are available on request. 

***If you make use of any part of this code, please cite the 
respective articles.***

For detailed instructions on how to use the code in MATLAB see below.
If you find a bug or have further comments, please send an email and if 
necessary the input file and the parameters that caused the error.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Authors   : Y.Billeh and M. Schaub  
Email     : ybilleh@caltech.edu, michael.schaub09@imperial.ac.uk  
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

###############################################################################

-------------------------------------------------------------------------------
How to use this code
-------------------------------------------------------------------------------


1. Make sure you have properly installed the stability graph clustering package
  * The most up-to-date version may always be found at: 
    http://michaelschaub.github.io/PartitionStability/ 
  * For convenience, a version of the Markov Stability package is included in 
    this software package and can be found in the /ext folder -- the 
    installation instructions for this package, and further information and 
    examples can be found there, too

2. Open Matlab

3. Make sure the folder Cell assembly folder is stored in your path variable.

4. To create a FCM from spike train data, load the data into memory  
Example:  
 ```
     % within the folder demo    
     load('Figure4.mat')    
     FCM = createFCM(spksExc)    
```
5. Run the stability analysis to find patterns in the spike train data.  
Example (continued):

 ```
     % within the folder demo  
     time = 10.^[-2:0.05:2];  
     stability(FCM,time,'full','plot','directed','v','p')  
```

For further details see also the Example.m script, as well as the manuscript.
For further options of stability, type "help stability".

NOTES: 

* The spike train data should be in a two column format where the first column 
  corresponds to the unit id and the second column corresponds to the spike 
  times



