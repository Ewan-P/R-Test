### Experimental Scripts from the internet
# https://www.r-bloggers.com/how-to-make-a-simple-heatmap-in-ggplot2/
library(ggplot2)

#------------------
# CREATE DATA FRAME
#------------------
df.team_data <- expand.grid(teams = c("Team A", "Team B", "Team C", "Team D")
                            ,metrics = c("Metric 1", "Metric 2", "Metric 3", "Metric 4", "Metric 5")
)

# add variable: performance
set.seed(41)
df.team_data$performance <- rnorm(nrow(df.team_data))

#inspect
head(df.team_data)



#---------------------------
# PLOT: heatmap
# - here, we use geom_tile()
#---------------------------

ggplot(data = df.team_data, aes(x = metrics, y = teams)) +
  geom_tile(aes(fill = performance))