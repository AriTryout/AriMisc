Summary = function(data,
                   measures = "core")
{
  frame = data[0, 1:ncol(data)]

  names = colnames(data)

  measures = tolower(measures)

  cat.type = "rawquant"
  cat.i = 3

  if (sum(grepl("\\bcat", measures)) > 1) {
    stop(
      "Include only one mention of the number of columns/types of processing for categorical variables"
    )
  } else if (sum(grepl("\\bcat", measures)) == 1) {
    cat.index = grep("\\bcat", measures)

    if (grepl("all", measures[cat.index])) {
      cat.i = "all"
    } else if (gsub("\\D", "", measures[cat.index]) != "") {
      cat.i = as.numeric(gsub("\\D", "", measures[cat.index]))
    }

    if (length(strsplit(measures[cat.index], "_")[[1]]) == 2) {
      cat.type = strsplit(measures[cat.index], "_")[[1]][2]
    } else if (length(strsplit(measures[cat.index], "_")[[1]]) > 2) {
      stop("Checi the structure of you 'cat_' call")
    }

    measures = measures[-cat.index]

  }

  m.quantiles = as.numeric(measures[grep("[0-9]", measures)])

  if (length(m.quantiles) == 0) {
    m.quantiles = NULL
  } else if (sum(m.quantiles < 0) > 0 |
             sum(m.quantiles > 100) > 0) {
    stop("Detected a number under 0 or over 100 in the measures - Unable to convert to quantiles")
  } else if (sum(m.quantiles >= 1) > 0) {
    m.quantiles = m.quantiles / 100
  }

  # Restructure


  for (i in 1:ncol(data)) {
    # Numeric

    if (is.numeric(data[, i]) & length(table(data[, i])) > 2) {
      if (sum(grepl("core", measures)) > 0) {
        if (sum(is.na(data[, i])) > 0 &
            (sum(grepl("\\bna\\b", measures)) == 0 |
             sum(grepl("relev_na", measures)) == 1)) {
          frame["NA", i] = round(sum(is.na(data[, i])), 2)
        }

        frame["Mean", i] = round(mean(data[, i], na.rm = T), 2)
        frame["Median", i] = round(median(data[, i], na.rm = T), 2)
        frame["25Q", i] = round(quantile(data[, i], 0.25, na.rm = T), 2)
        frame[".75Q", i] = round(quantile(data[, i], 0.75, na.rm = T), 2)
      }

      if (sum(grepl("mean", measures)) > 0) {
        frame["Mean", i] = round(mean(data[, i], na.rm = T), 2)
      }
      if (sum(grepl("median", measures)) > 0) {
        frame["Median", i] = round(median(data[, i], na.rm = T), 2)
      }
      if (length(m.quantiles) > 0) {
        for (m in 1:length(m.quantiles)) {
          frame[as.character(m.quantiles[m]), i] = round(quantile(data[, i], m.quantiles[m], na.rm = T), 2)
        }
      }
      if (sum(grepl("iqr", measures)) > 0) {
        frame["IQR", i] = round(quantile(data[, i], 0.75, na.rm = T), 2) - round(quantile(data[, i], 0.25, na.rm = T), 2)
      }

      if (sum(is.na(data[, i])) > 0) {
        frame["NA", i] = sum(is.na(data[, i]))
      } else if (sum(grepl("\\bna\\b", measures)) > 0) {
        frame["NA", i] = sum(is.na(data[, i]))
      }


    } else if (length(table(data[, i])) == 2) {
      # Binary

      frame[, i] = as.character(frame[,i])

      tag = names(table(data[, i])[order(table(data[, i]), decreasing = T)][1])

      frame[paste("Bin" , sep = ".%"), i] = paste(tag , round(sum((data[, i] == as.character(tag)) /
                                                                    dim(data)[1]
      ) * 100, 1), sep = ", ")

      if (sum(is.na(data[, i])) > 0) {
        frame["NA", i] = sum(is.na(data[, i]))
      } else if (sum(grepl("\\bna\\b", measures)) > 0) {
        frame["NA", i] = sum(is.na(data[, i]))
      }

    } else{
      #Categorical/factors

      frame[, i] = as.character(frame[,i])

      if (is.numeric(cat.i)) {
        if (cat.i == 0) {

        } else{
          tag = names(table(data[, i], useNA = "no")[order(table(data[, i], useNA = "no"), decreasing = T)][1:cat.i])
          tag = tag[!is.na(tag)]

          for (m in 1:length(tag)) {


            if (cat.type == "rawquant") {
              frame[paste("Cat", m, sep = ""), i] = paste(as.character(tag[m]), sum(data[, i] == as.character(tag[m]), na.rm = T), sep = ", ")

            }
            if (cat.type == "fromtotal") {
              frame[paste(paste("Cat", m, sep = ""), "%", sep = "_"), i] = paste(as.character(tag[m]), round((sum(
                data[, i] == as.character(tag[m]), na.rm = T
              ) /
                dim(data)[1]) * 100, 1), sep = ", ")
            }
          }

        }
      } else if (cat.i == "all") {
        tag = names(table(data[, i], useNA = "no")[order(table(data[, i], useNA = "no"), decreasing = T)])

        for (m in 1:length(tag)) {
          if (cat.type == "rawquant") {
            frame[paste("Cat", m, sep = ""), i] = paste(as.character(tag[m]), sum(data[, i] == as.character(tag[m]), na.rm = T), sep = ", ")
          }
          if (cat.type == "fromtotal") {
            frame[paste(paste("Cat", m, sep = ""), "%", sep = "_"), i] = paste(as.character(tag[m]) ,round((sum(
              data[, i] == as.character(tag[m]), na.rm = T
            ) /
              dim(data)[1]) * 100, 1), sep = ", ")
          }


        }
      }


      if (sum(is.na(data[, i])) > 0) {
        frame["NA", i] = sum(is.na(data[, i]))
      } else if (sum(grepl("\\bna\\b", measures)) > 0) {
        frame["NA", i] = sum(is.na(data[, i]))
      }

    }

  }
  return(frame)
}