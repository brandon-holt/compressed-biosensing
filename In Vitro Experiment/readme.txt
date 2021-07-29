Compressive Biosensing - Holt et. al.

This code processes in vitro protease activity data to (1) generate a heat map of all protease-substrate pairs and (2) analyze data from a classification experiment where libraries of 2 substrates are used distinguish between two similar but distinct mixtures of 11 proteases.

(1) Open generate_heatmap.m and click run to process the raw data and generate a heat map of each protease substrate pair. This script will also test all compatible substrate pairs and find the best and worst libraries according to the CompressionScore.

(2) Open process_data.m and click run to process the raw classification data and generate the AUROC curves when using the library with high compression score (good), the low compression score (bad), and the raw protease values (ctrl).