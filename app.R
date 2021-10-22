
#
# R Shiny Application is to 
# 1. Show the Longest Distance Between two consecutive Observations.
# 2. Generate outputs(Leaflet Map)
# 3. Click on the RunApp to view the Shiny Application.
# 4. Deployed in the Shinyapps.io Server.
# 5. Click Here to view the Deployed Shiny Application.
# Author: Anjana
# Date: October 22th, 2021

# List of Packages to be use
packages <- c("shiny","shiny.semantic","semantic.dashboard","geosphere",
              "leaflet","feather","dplyr","shinycustomloader")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Loading Source File.
source("./map.R")
# UI Starts....
ui <- semanticPage(tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "main.css")
),
module_ui("module_label"))  # Calling the UI Module from the map.R file
# End of the UI.

# Server Function Starts..
server <- function(input, output, session) {
  callModule(module_server, "module_label")  # Calling the Server Module from the map.R file
}
# End of the Server Function.

# Calling the Shiny App with UI,Server.
shinyApp(ui, server)
