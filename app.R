# R Shiny Application is for Visualize the observations on the map.
# 1. Enter the Scientific name and Vernacular name at searchbar.
# 2. Map with selected observations willbe shown.
# 3. Click Run App button to see the application.
# 4. Deployed app in and link

# Author: Anjana
# Date: January 17th, 2022


# List of Packages to be used in the below format to deploy into the shiny apps.io server

library("shiny")
library("shinydashboard")
library("dplyr")
library("leaflet")
library("htmltools")
library("shinyjs")
library("mapview")  

# Below lines are used to run in local env.
# # Install packages not yet installed
# installed_packages <- packages %in% rownames(installed.packages())
# 
# if (any(installed_packages == FALSE)) {
#   install.packages(packages[!installed_packages])
# }
# 
# # Packages loading
#invisible(lapply(packages, library, character.only = TRUE))

# Arrange icon at title position

title <- tags$img(src = "icon.png",
                  height = '50',
                  width = '150')

# Start of the  User Interface

ui <- dashboardPage(
  dashboardHeader(title = title), 
  dashboardSidebar(width = 400,
                   searchbar_ui("search_label")),  # Module-1(UI) from searchbar.R source file
  
  dashboardBody(includeCSS("www/main.css"),  # Including the css file
                useShinyjs(),  # Use shinyjs
                  map_ui("species_maplabel"))  # Module-2(UI) from map.R source file

  )  # End of the User Interface

# Start of the Server Logic

server <- function(input, output, session) {
  # Assiging the Server Module-1 to the new variable
  search_text_value <- searchbar_server("search_label")  
  
  # passing the function arguments inside the Server Module -2 using Server Module-1. 
  
  map_server(
    "species_maplabel",
    search_value = search_text_value$input_search,  # getting the input_search value from the Server Module-1
    input_datasetvalue = search_text_value$input_dataset  # Loading the dataset from the Server Module-1
  )
  
} 
# End of the Server Logic
shinyApp(ui, server)  # Load the ui,server functions for shinyapp.
# End of the Shiny Application
