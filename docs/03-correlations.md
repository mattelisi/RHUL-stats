# Correlations {#correlation}

Readers of this page will likely already familiar with the Pearson correlation coefficient and its significance test. The Pearson correlation coefficient measures the strength of association between two variables, denoted as $x$ and $y$, and is essentially a normalized measure of their covariance. It is calculated by dividing the covariance of $x$ and $y$ by the product of their standard deviations:

$$
r_{x,y} = \frac{\text{cov}(x,y)}{\sigma_x \sigma_y}
$$

The normalization is achieved by dividing the covariance by the maximum possible covariance that can be attained when the variables are perfectly correlated, represented by the product of their standard deviations. This normalization constrains the Pearson correlation coefficient to a range between -1 and 1.

In R, simple correlation analyses can be run using the function `cor.test`.

In this chapter we will consider some more complex examples and issues that may occur when doing correlation analyses.

---

## Comparing correlations

Often, we have to compare a correlation value between two conditions (or groups or whatever). One simple approach to do this - if we have access to the raw data - is to run a regression model (with interaction term) with the condition as categorical predictor, and test whether the slope differs between the two conditions. (Note that if all the variables are standardized - i.e. transformed in Z-scores - the regression slope is identical to the Pearson correlation coefficient.)

If we don't have the raw data available, we can still compare the correlations using [Fisher's Z transform](https://en.wikipedia.org/wiki/Fisher_transformation). This requires first transforming all correlation values, e.g.  $r_1, r_2$, into Z scores using the following:

$$
Z=\frac{\log(1+r)−\log(1−r)}{2}
$$

We can then take the differences in these transformed correlation coefficients, and divide by $\sqrt{\frac{1}{N_1 - 3} + \frac{1}{N_2 - 3}}$, where $N_1$ and $N_2$ are the sample size of the two conditions/groups that are compared. We obtain the statistics 

$$
\Delta_Z = \frac{|Z_1 - Z_2|}{\sqrt{\frac{1}{N_1 - 3} + \frac{1}{N_2 - 3}}}
$$

Under the null hypothesis that the two correlations are not different ($H_0: r_1 =r_2$) the statistics is normally distributed with mean 0 and variance 1, $\Delta_Z \sim \mathcal{N}(0,1)$. Thus we can get a p value by using the cumulative distribution function of the normal distribution. For example, in R if the statistic is saved in the variable `Delta_Z` we can calculate the p-value using `p_value <- 2*(1-pnorm(Delta_Z))`.

To verify the correctness of this approach, we can perform a simple simulation in R. The code below simulates multiple pairs of datasets, each consisting of two variables, from a population with a given correlation. In this simulation, the 'true' correlation value remains constant, representing the case where the null hypothesis is true. We then use the aforementioned approach to determine whether the difference is statistically significant. Finally, we calculate the proportion of significant tests (i.e., false positives) and verify that it is approximately equal to the desired false positive rate (alpha), conventionally set at 0.05.


``` r
# function to simulate correlated normal variables
sim_data <- function(N=100, r=0.3){
  d <- MASS::mvrnorm(N, 
               mu = c(0,0), 
               Sigma=matrix(c(1,r,r,1), nrow=2, ncol=2))
  return(data.frame(d))
}

# function that calculate F transform and statistics
Fisher_Z_test <- function(r1, r2, N1, N2){
  Z1 <- (log(1+r1) - log(1-r1))/2
  Z2 <- (log(1+r2) - log(1-r2))/2
  denomin <- sqrt(1/(N1-3) + 1/(N2-3))
  Delta_Z <- abs(Z1 - Z2)/denomin
  p_value <- 2*(1-pnorm(Delta_Z))
  return(list(statistic=Delta_Z, p=p_value))
}

# run simulations
set.seed(1)
N_sim <- 1e4
p_vals <- rep(NA, N_sim)
for(i in 1:N_sim){
  d1 <- sim_data()
  d2 <- sim_data()
  r1 <- cor(d1$X1, d1$X2)
  r2 <- cor(d2$X1, d2$X2)
  test.results <- Fisher_Z_test(r1, r2, 100, 100)
  p_vals[i] <- test.results$p
}

# false positive rate
# should be approximately equal to desired alpha
# (here alpha=0.05)
mean(p_vals<0.05)
#> [1] 0.0505
```


## Polychoric and polyserial correlations

Polychoric and polyserial correlations are methods used to estimate correlations between ordinal variables or between ordinal and continuous variables. These methods assume that the ordinal variables can be considered as divisions of underlying latent variables that follow a normal distribution (similar to ordinal models discussed in a later chapter). In R, calculating polychoric correlations is straightforward with the help of the [`polycor` package](https://cran.r-project.org/web/packages/polycor/index.html). You can use the `polychor` function to estimate correlations between two variables or the `hetcor` function to compute a correlation matrix for multiple variables simultaneously.


## Partial correlations

Partial correlation is a statistical measure that quantifies the relationship between two variables while controlling for the effects of other variables. It assesses the strength and direction of the linear association between two variables after removing the influence of the remaining variables in the analysis.

Partial correlations are useful in situations where there are multiple variables that may be interconnected, and we want to understand the relationship between two variables while accounting for the effects of other variables. By calculating partial correlations, we can examine the direct association between two variables while holding constant the influence of other variables, thereby revealing the unique relationship between them.

Here are a few scenarios where partial correlations can be useful:

- **Confounding Control**: In observational studies, there may be confounding variables that affect both the dependent and independent variables. By computing partial correlations, we can determine the relationship between the variables of interest while controlling for potential confounders.

- **Multivariate Analysis**: When examining the relationships between multiple variables simultaneously, partial correlations can help identify direct associations between pairs of variables, accounting for the shared influence of other variables in the analysis.

- **Network Analysis**: Partial correlations are commonly employed in network analysis to uncover the underlying structure and connections between variables, such as in gene regulatory networks, social networks, or financial networks.

In R, and for simple Pearson's correlation coefficients, we can use the packages [`ppcor`](https://cran.r-project.org/web/packages/ppcor/index.html) to calculate a matrix of partial correlation coefficients. 



### Partial correlations using Schur complement

Occasionally, we may need to calculate partial polychoric correlations (e.g. partial correlations between ordinal variables). To the best of my knowledge there isn't a simple package that allows to compute these. However, we can use an approach known as [Schur complement](https://en.wikipedia.org/wiki/Schur_complement).

The approach works as follow. Say we have computed a matrix of partial polychoric correlations using the `polycor` package; in particular $\Sigma$ is the correlation matrix between the variables of interests. We further have also a set of variables we want to account for (let's call these 'confounders'), and we calculate the matrix of the correlations between them, let's call this $C$. Finally, we also have a matrix of correlations between the variables of interest and the confounders, here notated as $B$.

The partial correlation matrix can be computed as the Schur complement of $C$ in the block matrix $M$, defined as $M = \begin{bmatrix} \Sigma & B \\ B^T & C \end{bmatrix}$. Note that the matrix $M$ simply corresponds to the 'full' correlation matrix - the the matrix including correlations between _all_ variables (variables of interest and confounders).

In practice, the Schur complement (partial correlation matrix) is computed as 

$$\text{Partial Correlation Matrix} = \Sigma - BC^{-1}B^T.$$ 

Here is a simple function in R that can calculate the partial correlation matrix when some or all the variables are ordinal:


``` r
partial_polychoric <- function(dX, dC, useML = TRUE) {
  # dX is a dataframe containing variables of interest
  # dC is a dataframe containing confounding variables that needs to be partialled out
  # ML estimation is recommended, but may be slow with very large datasets
  combined_data <- cbind(dX, dC)
  combined_polychoric_matrix <- hetcor(combined_data, 
                                       parallel=TRUE,
                                       ML=useML,
                                       use="pairwise.complete.obs")$correlations
  cor_dX <- combined_polychoric_matrix[1:ncol(dX), 1:ncol(dX)]
  cor_dC <- combined_polychoric_matrix[1:ncol(dX), (ncol(dX) + 1):ncol(combined_data)]
  cor_yy <- combined_polychoric_matrix[(ncol(dX) + 1):ncol(combined_data), (ncol(dX) + 1):ncol(combined_data)]
  inv_cor_yy <- solve(cor_yy)
  cor_dX - cor_dC %*% inv_cor_yy %*% t(cor_dC)
}
```


To estimate the p-values of partial correlation coefficients, we can use a permutation test: essentially we shuffle the order of columns in our dataset independently, then re-calculate the correlation matrix, and keep track of how often a correlation higher than the observed ones occur by chance. 

The code below is an example of how such a test can be implemented in R


``` r
# first, compute the observed matrix of partial correlation
sigma_polychoric <- partial_polychoric(dX, dC)

# custom function to shuffle independently the columns 
# of a data.frame containing ordinal variables
shuffle_df <- function(A) {
  A_shuffle <-  as.data.frame(lapply(A, function(x) {
    if (is.ordered(x)) {
      levels <- levels(x)
      x <- as.numeric(x)
      x <- sample(x)
      x <- ordered(x, labels = levels)
    } else {
      x <- sample(x)
    }
    return(x)
  }))
  return(A_shuffle)
}

# Use replicate() to compute 1000 matrix from permutations of the datasets
n_permutations <- 1000
permuted_partial_polychoric <- replicate(n_permutations, {
  permuted_dX <- shuffle_df(dX)
  permuted_dC <- shuffle_df(dC)
  partial_polychoric(permuted_dX, permuted_dC)
})

# Compute p-values by counting how often we observe correlations 
# as high as that in the observed matrix from the permuted datasets.
# The output is a mtrix of p-values
p_values <- matrix(0, ncol(dX), ncol(dX))
tot_it <- ncol(dX)*ncol(dX)
for (i in 1:ncol(dX)) {
  for (j in 1:ncol(dX)) {
    p_values[i, j] <- mean(abs(permuted_partial_polychoric[i, j, ]) >= abs(observed_partial_polychoric[i, j]))
  }
}

```

