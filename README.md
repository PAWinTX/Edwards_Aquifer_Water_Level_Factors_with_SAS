# Edwards_Aquifer_Water_Level_Factors_with_SAS

Analysis of statistically significant correlations between the Edwards Aquifer J17 well levels and various factors.

SAS University Edition 3.8

This analysis is from a research course and is shared here in the hope that it may assist others with their analytic and SAS learning journey. Please reference the Edwards_Water_Level_Summary.pdf document for more info about the analysis process and outcomes. The intended audience is other professionals with a firm understanding of statistical findings.

Research Question: Central Texas is blessed with an abundance of high-quality ground water from the Edwards Aquifer, but its sustained availability is often questioned due to ever-increasing pressure from growth. This analysis attempts to answer the question of whether any of the major factors believed to effect water availability are statistically significant at an aggregated annualized level. More than six decades of data exists concerning Recharge (from rainfall and runoff) and Discharge through both natural spring flow and various types of pumping. This analysis also examines census data because there is an assumption among experts that population growth increases pumping and reduces water availability.

This SAS analysis uses EckCombJ17Pop.csv, which is an annualized data set of 62 observations and 13 variables (1954 to 2015). I created it by combining aquifer data sets with population data sets. I used Excel’s Get & Transform Data features to script web extraction and produce the final analysis data set. 

Part of the analysis challenge was working with such a small number of observations. Fortunately, SAS makes it easy to perform honest assessment by employing leave-one-out k-fold cross-validation eliminating the need to split the data into separate training and validation sets. Feel free to ask any questions or provide feedback – there’s always a better way!
