\name{Aggregate}
\alias{Aggregate}
\title{
Aggregate with multiple basic summary statistics at once
}
\description{
Given a factor to separate directly or a numeric vector to break up, returns summary measures for each column of each partition of the data. Added support for "by"s with NAs and options for categorical/factors and binary data.
}
\usage{
Aggregate = function(data,
                     by = NULL,
                     quantiles = NULL,
                     breaks.num = NULL,
                     measures = "core"
)
}

\arguments{
  \item{data}{
Pretty self explanatory. Unless you call "by" by name, exclude the vector from here. If it's named, exact matches for the column name will be automatically removed.
}
  \item{by}{
Vector to separate the data with. Factors/character vectors don't require anything else, numeric ones do. Can have NAs, these will simply form a separate subset.
}
  \item{quantiles}{
Quantiles used to separate a numeric by. Defaults to quartiles.
Not to confuse with getting summary quantiles, that's in measures.
}
  \item{breaks.num}{
Same rationale, just giving it specific numbers.
}
  \item{measures}{
What summary statistics should be given.

\cr

\bold{Numeric columns:}

"core" computes the mean, quartiles, and, when present a tally of the column's NAs;

"mean" and "median" can be given separately;

"iqr" gives you the interquantile range;

"na" forces every initial column to return a tally of their NAs(The rationale stays for character/factor columns);

"relev_na" only prints NAs when the column actually has them;

Quantiles can be specified, just keep it consistent from 0-1 or 0-100(if there's any value over 1, it will divide them all by 100)

\cr

\bold{Binary/string columns:}

"cat_k" specifies a k number of a string variable's most common elements to be outputted(can be 0). Defaults to 3. "cat.all" prints every element of every column.

Mode is on by default for non binary categorical variables. For now anything with an isolated "mode" deactivates it, so use "mode.off" if its more intuitive(yes "." pass through "\\\b" checks, don't ask me why when "_" doesn't). For binary variables, it's off by default. "bin_mode" activates it if you need it for some reason.

\cr

\bold{Example:}

measures = c("core", 0.1, 0.9, "na", "cat.5", "bin_mode") would give you the mean, 10,25,50,75 and 90\% quantiles for every numeric column. Binary columns would present the percentage of the most common option and the mode for each subset of the data. Factors/categorical variables would be limited to their 5 most common values along with their mode. NAs would be returned for every column

}
}

\examples{

data("iris")
iris$Sepal.Length[c(49, 101, 113, 57)] = NA
iris$Species[c(1,2,54)] = NA

summary(iris)

# By a factor
Aggregate(iris, by = iris$Species, measures = "core")

# Naming by and specifying measures
Aggregate(iris, by = "Species", measures = c("median", 5, 25, 75, 95, "iqr"))

# Default numeric by
Aggregate(iris[,-1], by = iris$Sepal.Length, measures = c("median", "iqr", "relev_na"))

# Messing with by's quantiles
Aggregate(iris[,-2], by = iris$Sepal.Width, quantiles = c(.35,.65))

# By a specific break + specific case of core + na forcing every column vs only when relevant
hist(iris$Petal.Length)
Aggregate(iris[,-3], by = iris$Petal.Length, breaks.num = c(2), measures = c("core", "na"))

# Messing with the categorical/binary commands

set.seed(1)
iris$bin = sample(c(0,1), prob = c(0.7, 0.3), size = 150, replace = T)
# Preferable to set any binaries as character/factor
# (as a workaround, anything with only two values is interpreted as binary, numeric or not)

hist(iris$Petal.Width)

## Minimum activated by default
Aggregate(iris[,-4], by = iris$Petal.Width, breaks.num = c(0.75), measures = "")

## Absolute minimum extractable
Aggregate(iris[,-4], by = iris$Petal.Width, breaks.num = c(0.75), measures = c("mode.off", "cat.0"))

## Forcing mode for binary variables + setting cat_k
Aggregate(iris[,-4], by = iris$Petal.Width, breaks.num = c(0.75), measures = c("bin_mode", "cat.50"))
# cat_k can only be set to one number. This acts as a maximum
# (Any more than the available options for any column will simply be cut)

### Exemple with multiple categories with different lengths

set.seed(2)
iris$cat1 = sample(c("test_1","test_2","test_3","test_4","test_5"), size = 150, replace = T)

set.seed(3)
iris$cat2 = sample(c("test_1","test_2","test_3","test_4","test_5","test_6", "test_7"),
                   size = 150, replace = T)

Aggregate(iris[,-4], by = iris$Petal.Width, breaks.num = c(0.75),
          measures = c("bin_mode", "cat.5"))
# Also a solid example of how they get cut
# cat2 loses test 3 and 6

table(iris$cat2)[order(table(iris$cat2))]
# As you can see these are the least common globally
}