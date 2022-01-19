

# map.R Source file is located at R folder...

# Start of the User Interface Module-2

map_ui <- function(id) {
  ns <- shiny::NS(id) # Namespace for Unique id's
  shiny::tagList(
    br(),
    # Create a box to show the leaflet map
    box(
      title = "Selected Species Observations on the map",
      width = 11,
      solidHeader = TRUE,
      status = "primary",
      uiOutput(ns("ui_text_map")),  # uioutput for the infobox and leaflet map
      # uiOutput(ns("ui_download"))  # UIoutput for the download button
    )  # End of the box
    
  )
}
# End of the User Interface Module-2

# Start of the Server Module-2

# create a function with arguments to load the data from other modules.

map_server <- function(id, search_value, input_datasetvalue) {
  
  # Start of the Module server.
  
  moduleServer(id, function(input, output, session) {  
    ns <- shiny::NS(id) # Namespace for Unique id's
    
    values <- reactiveValues()  # User reactive values for global use
    
    # Render output to check serchbar is null or not  
    
    output$ui_text_map <- renderUI({
      if (search_value()=="") { # used reactive function argument from servermodule-1
        
        infoBoxOutput(ns("user_info"))  # if it is NULL show the info box
      } else{
        
        leafletOutput(ns("species_map"), height = "380px") # Not null show the map 
        
      }
    })  # End of the output
    
    # Render the output of infobox
    
    output$user_info <- renderInfoBox({
      infoBox(
        "Please Select Scientific Name",
        paste0("Enter your search to view the Observations on the Map "),
        icon = icon("map-marker"),
        color = "purple",
        fill = TRUE
      )
    })  # End of the info box
    
    # Observe event to trigger the search bar input...
    
    observeEvent(search_value(), {
      
      # Render the output of download button
      # output$ui_download <- renderUI({
      #   downloadButton(ns("download_map"))  # Download button
      #   
      # })
      # Load the reactive function argument into the new reactive variable.
      
      values$checkbox_values <- search_value()  
      
      # Filter the Scientific name column from the reactive function argument table by giving search input data
      
      values$checkbox_species <-
        
        filter(input_datasetvalue(),scientificName==values$checkbox_values | vernacularName==values$checkbox_values)
      
      
      # Render the output to get the Map with selected observations of the species.
      output$species_map <- renderLeaflet({
        
        values$m <- leaflet(values$checkbox_species) %>%
          addTiles() %>%
          addCircleMarkers(
            lng = ~ longitudeDecimal,
            lat = ~ latitudeDecimal,
            label = ~ htmlEscape(scientificName),
            labelOptions = labelOptions(
              noHide = T,
              direction = "bottom",
              style = list(
                "color" = "black",
                "font-family" = "serif",
                "font-style" = "italic",
                "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
                "font-size" = "12px",
                "border-color" = "rgba(0,0,0,0.5)"
              )
            )
          )
        
        
        values$m %>% addMiniMap(tiles = providers$Esri.WorldStreetMap,
                                toggleDisplay = TRUE)
      })  # End of the render output 
      # 
      # # Render the download handler to download the png 
      # output$download_map <- downloadHandler(
      #   filename = "map.png",
      #   
      #   
      #   content = function(file) {
      #     shiny::withProgress(
      #       message = paste0("Downloading", input$dataset, " Data"),
      #       value = 0,
      #       {
      #         shiny::incProgress(1/5)
      #        
      #         mapshot(values$m, file = file)      
      #         }
      #     )
      #   }
      #   
      #  
      # )  # End of the Download Render
    })  # End of the Observe Event
    
  })  # End of the Module Server Function
}
# End of the Server Module-2
