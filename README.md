# compressed-biosensing
Supporting code for simulations found in manuscript, "Embracing enzyme promiscuity with activity-based compressed biosensing"
 
## Purpose
The purpose of the [SLICE method](SLICE/SLICE.m) is to aid in the substrate design process for measuring complex protease activity while using promiscuous substrates. Given the appropriate cleavage kinetics data for all protease-substrate pairs, this method will select the optimal substrate library (of a specified size) for sensing target proteases of interest.

## Abstract
Genome-scale activity-based profiling of proteases requires identifying substrates that are specific to each individual protease. However, this process becomes increasingly difficult as the number of target proteases increases because most substrates are promiscuously cleaved by multiple proteases. We introduce a method – Substrate Libraries for Compressed sensing of Enzymes (SLICE) – for selecting complementary sets of promiscuous substrates to compile libraries that classify complex protease samples (1) without requiring deconvolution of the compressed signals and (2) without the use of highly specific substrates. SLICE ranks substrate libraries according to two features: substrate orthogonality and proteases coverage. To quantify these features, we design a compression score that was predictive of classification accuracy across 140 in silico libraries (Pearson r = 0.71) and 55 in vitro libraries (Pearson r = 0.55) of protease substrates. Further, we demonstrate that a library comprising only two protease substrates selected with SLICE can accurately classify twenty complex mixtures of 11 enzymes with perfect accuracy. We envision that SLICE may be used to improve imaging activity-based probes and point-of-care diagnostics by enabling the selection of substrate libraries that capture information from hundreds of enzymes while using fewer activity-sensors.

<p align = "center">
<img src="https://github.com/brandon-holt/compressed-biosensing/blob/main/Example/ReadMe/concept.png" width="500">
 </p>

## How to Use
1. Download the entire repository.
2. Obtain a 2D array of cleavage kinetics for all protease-substrate combinations. This can include metrics such as (k<sub>cat</sub>, k<sub>cat</sub>/K<sub>m</sub>, V<sub>max</sub>, etc.). Make sure to include all target proteases in your system, as well as every candidate substrate you want to consider adding to your final library. Proteases are in the rows, substrates are in the columns
3. Call the [SLICE method](SLICE/SLICE.m) with the appropriate inputs.
```matlab
function [substrates, compression_score] = SLICE(activity_matrix, library_size, activity_thresh, must_test_subs)
```
**Inputs**
+ ```activity_matrix``` = **2D array** of cleavage kinetics for all protease-substrate combinations (rows = proteases, columns = substrates)
+ ```library_size``` = **int** specifying the number of unique substrates in the output library.
+ ```activity_thresh``` = **float** specifying the threshold cleavage kinetics value in ```activity_matrix``` that qualifies a substrate to sense a protease.
+ ```must_test_subs``` = **2D array** of substrate combinations that must be tested in case of hardware memory limitations (rows = combinations, cols = substrates)

**Outputs**
+ ```substrates``` = **1D array** of substrate indicies in final library.
+ ```compression_score``` = **float** between 0 and 1 representing the relative strength of the library, with 1 being the best and 0 the worst.

## Example Demo
To see an example of how to use the SLICE method on a matrix of protease-substrate cleavage kinetics and generate heatmaps similar to those seen in the figure above, download the repository and run [this file](Example/run_this.m). The results should look similar to the image below:

<p align = "center">
<img src="https://github.com/brandon-holt/compressed-biosensing/blob/main/Example/ReadMe/heatmaps.png" width="400">
 </p>
