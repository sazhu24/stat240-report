### A Clustering and Network Analysis of Academic Deparments at Amherst College
Sara Zhu | STAT 240 | Fall 2022    

#### Introduction

Over the past few years, Amherst College has become well-known for its efforts to diversify its studentbody. However, there is little information reported about the diversity (or lack thereof) of students withinclassrooms and academic majors on campus. In the first portion of this report, I explore the demographicmake-up of different majors at Amherst College to examine the degree to which different demographicgroups (race, sex, etc.) may be clustering in certain majors. The data set from the IPEDS database includesinformation on 2150 degrees conferred to Amherst College students who graduated in 2018, 2019, 2020,and 2021 (IPEDS). The clustering analysis is performed on the following six variables: male, non-resident(international), asian, hispanic/latino, black, and white. After comparing two different clustering methods,k-means clustering and agglomerative hierarchichal clustering, we plot the observations in PC space tovisualize the final clustering solution. The second portion of this report uses a network model to explorethe relationship between majors that have cross-listed courses in the 22-23 Amherst Course Catalog. Aftermining and processing the data from Amherst’s public course catalog, we construct a network based on 38majors and 369 cross-listings extracted from 754 courses. To detect clusters of majors based on cross-listings,we compare two greedy community detection algorithms - a modulation optimization algorithm and an edgebetweenness algorithm. The overall goal of this report is to identify clusters of majors based on demographicand curricular information



![Degree Distribution (Annual Average)](https://github.com/sazhu24/stat240-report/blob/main/plots/degrees-plot.png)


#### Methods

*Clustering*

The first section of this report applies a clustering analysis to detect clusters of demographically majors. To select which variables to use in our data analysis, we removed all variables that comprised 5% or less of the sample population, leaving 6 remaining features. To determine which observations are most similar or different from each other in terms of the 6 features, we compare solutions for two different clustering algorithms, k-means clustering and agglomerative hierarchical clustering with Ward's method. Since neither of the methods are scale-invariant, we scaled each variable before clustering.

Broadly speaking, K-means is an iterative algorithm that partitions data into a specified number of clusters (k). Both k-means and Ward's method try to make the points in each cluster as similar as possible by minimizing some criteria in each consecutive iteration of the algorithm. In the case of k-means, we define this criteria as the Within Groups Sum of Squares (WGSS). Unlike the k-means algorithms, hierarchical clustering algorithms do not require a specified number of clusters. Our analysis will use an agglomerative hierarchical clustering procedure known as Ward's method, which starts with n clusters in the first iteration then iteratively merges the pair of clusters that minimizes the increase in within-cluster variance for the entire data set. 

Both k-means and hierarchical clustering require the analyst to choose the optimal number of clusters based on solutions for multiple cluster sizes. For k-means, we make this selection by plotting the WGSS against the number of clusters and looking for the 'elbow'. For hierarchical clustering, we can examine the sizes of the changes in height in the dendrogram. Once we have obtained our clustering solutions from both methods, we can assess the validity of each solution by computing their silhouette coefficients. After we have selected the strongest of the two solutions, we will use a PCA to visualize the final cluster solution.


*Network*

There are many useful tools in the field of network analysis that we can use to analyze the relationships between cross-listed majors. Formally, we define a graph G = (V, E) as a mathematical structure that consists of a set V of *vertices* (also called nodes) and a set E of *edges*. Our network will model majors as nodes and the cross-listings between majors as edges. Since there is often more than just one cross-listed course between two majors, our network is *weighted*. The network is also an *undirected* graph (where edges represent unordered pairs of distinct vertices) because cross-listings assign equal weight to all participating majors. After plotting the network, we will can use descriptive statistics to assess a few basic properties, including the *diameter*, *average path length*, and *transitivity* coefficient. We will also evaluate the degree centrality distribution to determine the most central (most often cross-listed) majors. Following the descriptive analysis, we will implement two different community detection algorithms: a modularity optimization algorithm and a Girvan-Newman edge-betweenness algorithm. Both algorithms take a greedy approach to searching the space of all possible partitions by iteratively modifying successive candidate partitions. In each iteration, the least costly merge of two previously existing partition elements is executed.

*Modularity* is a measure of the structure of a graph. Graphs with a high modularity score have many connections within a community and relatively few that are close to other communities. In each iteration of the modularity optimization algorithm, the merge that maximizes *modularity* is executed. 

*Edge betweeenness* measures how often an edge lies on the shortest path between all possible pairs of nodes in the graph. This means edges that connect isolated communities have high edge betweenness because all other shortest paths must go through them. In our network, edge betweenness is also inversely related to edge weight. In each iteration of the Girvan-Newman algorithm, edges with the largest *edge betweenness* are removed. 

After running the two algorithms, we will describe the detected clusters and compare their respective modularity values to determine the optimal partitioning solution.


#### Results 

View results in the [full report](https://github.com/sazhu24/stat240-report/blob/main/final_report.pdf)

<!-- ![Degree Distribution (Annual Average)](https://github.com/sazhu24/stat240-report/blob/main/plots/degrees-plot.png)
![Clustering Solution - PCA](https://github.com/sazhu24/stat240-report/blob/main/plots/clustering-pca.png)
![Network](https://github.com/sazhu24/stat240-report/blob/main/plots/network.png) -->

#### Conclusion 

The first part of this report used a clustering method to identify groups of majors at Amherst College that are demographically similar. The clustering analysis was run on the 6 quantitative variables, male, non-resident (international student), asian, hispanic/latino, black, and white. After comparing k-means and hierarchical clustering techniques, the 3-group k-means solution produced the strongest solution. Although the structure of the clusters were relatively weak overall (silhouette coefficient = 0.25), the solution still grouped all STEM majors in a single cluster (silhouette coefficient = 0.26). The majors at the center of the STEM-dominated cluster were characterized by high asian, non-resident (international) and male representation, as well as low hispanic/latino and black representation. When interpreting this result, it is important to consider that all majors were assigned equal weight in the clustering analysis despite significant variation in major size. This means that the degree of separation exhibited by the clustering solution is based on the *average major*, not the *average student*. 

The second portion of this report used a network model to explore the relationship between majors that had cross-listed courses in the 22-23 Amherst Course Catalog. HIST, BLST, SWAG, ARHA, ENGL, FAMS were the most frequently cross-listed majors and COSC was cross-listed zero times, despite being one of the most popular majors at Amherst. After plotting the network, we identified a negative correlation between majors that were highly cross-listed and majors that were highly represented by men. Finally, a community detection algorithm based on modularity optimization detected five clusters with moderately strong structure overall. The largest two clusters contained almost all of the humanities majors. Another cluster contained most of the biological and physical science majors (BIOL, BCBP, CHEM, NEUR, PSYC, ASTR, PHYS), and the final cluster singled out COSC. 

Though we successfully identified all STEM majors in one cluster based on the demographics of students at Amherst College, the structure exhibited in the clustering solution was fairly weak. The sample size of the data is another important limitation to consider. Although we did not identify any glaring inconsistencies across the 4 years, the relatively small sample constrains the accuracy of our data. The variance in major size (total number of degrees conferred) is also a major limitation. As we demonstrated in the preliminary analysis, majors ranged from an average of 3 degrees to 62 degrees conferred per year. This led us to consolidate several of the smallest majors which exposes the data to bias. It is also important to note that over 10% of observations in the original data set were excluded from the analysis because the observations belonged to demographic groups that each made up less than 5% of the sample population. The data for the network analysis, which only contained the 754 courses offered during Amherst's 22-23 school year, was also limited by its sample size. We also note several major limitations to using demographic data from the clustering analysis to decorate the network: 1. the data sets did not represent the same class years 2. EDST and EUST were not included in the IPEDS data base. 

Given that the IPEDS database and the Amherst Course Catalog both have at least two decades worth of data, it would be interesting to extend this analysis to a wider time frame in the future. The IPEDS database also has the same information for most other colleges and universities, so future analyses could also examine how Amherst compares to its peers (especially other liberal arts colleges). It would also be worthwhile to perform a clustering analysis on course-level data (demographic make up of students in each course).


#### References 

* [U.S. Department of Education, National Center for Education Statistics, Integrated Postsecondary EducationData System (IPEDS), 2017-2021, Amherst College: Completions](https://nces.ed.gov/ipeds/datacenter/FacsimileView.aspx?surveyNumber=3&unitId=164465&year=2020)

* [Amherst College Course Catalog:  2022-2023](https://www.amherst.edu/academiclife/college-catalog/2223)
