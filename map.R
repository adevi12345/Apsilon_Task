
# UI module Starts....
module_ui <- function (id) {
  ns <- NS(id)
  semanticPage(card(div(
    class = "Project_object",
    div(class = "header", "Title: Example Shiny App"),
    div(class = "github", "GitHubLink: *********"),
    div(class = "author", "Author:Anjana")
    
  )),
  
  card(div(
    class = "vesseltype_class",
    tags$h4("Please select Ship Type:"),
    uiOutput(ns("vesseltype_uidropdown"))
  )),
  card(div(
    class = "vesselname_class",
    tags$h4("Please seletct Shiny Name:"),
    
    uiOutput(ns("vesselname_uidropdon"))
  )),
 div(
   class="ui_titleclass",
   uiOutput(ns("title_ui"))
 ),
  
  div(class="map_class",
      uiOutput(ns("map_ui"))
  
  ),
 card(div(
   class="log_lal_class",
   uiOutput(ns("log_class_ui"))
 ))
  )
  
  
}
# UI Modules Ends..
#
# Server Modules Starts...

module_server <- function(input, output, session) {
  ns <- session$ns
  values <- reactiveValues()  # Creating Reactive variable.
  path <-
    "./final.feather"
  observe({
    values$ship_inputdataset <- read_feather(path)  # Converted csv into feather dataset for data speed purpose.
    
    values$shinytype_choices <-
      factor(values$ship_inputdataset$ship_type)
    
    values$levels_shinytype <- levels(values$shinytype_choices)
  })
  
  output$vesseltype_uidropdown <- renderUI({
    dropdown_input(ns("select_shiptype"), choices = values$levels_shinytype)
    
  })
  output$vesselname_uidropdon <- renderUI({
    values$groupby_dataset <-
      dplyr::group_by(values$ship_inputdataset, ship_type)
    
    values$shiptype_dateset <-
      dplyr::filter(values$groupby_dataset,
                    ship_type == input$select_shiptype)
    
    
    values$vessel_names <- unique(values$shiptype_dateset$SHIPNAME)
    
    dropdown_input(ns("select_vesselname"), choices = values$vessel_names)
  })
  output$map_ui<-renderUI({
    values$title<-paste0("Showing Longest Distance of the ",input$select_vesselname)
   
    box(width=5,title = values$title,
        withLoader(
         leafletOutput(ns("map")),type = "html", loader = "dnaspin"))
  })
  output$map <- renderLeaflet({
    df <-
      dplyr::filter(values$shiptype_dateset,
                    SHIPNAME == input$select_vesselname)

    df$distance[2:nrow(df)] <- sapply(2:nrow(df), 
                                      function(x) distm(df[x-1,c('LON', 'LAT')], df[x,c('LON', 'LAT')], fun = distHaversine))
    
    
    
    df$min_date<-min(df$DATETIME)
    df$max_date<-max(df$DATETIME)
    
    gh<-df %>% 
      group_by(SHIPNAME) %>% 
      slice_max(distance)
    
    
    gh_latest<-gh%>% 
      group_by(SHIPNAME) %>% 
      slice_max(DATETIME)
    
    #to make dynamic
    
    row_number<-which(grepl(gh_latest$distance[1], df$distance))
    n<-row_number
    n1<-n-1
    values$final_dataset<-df %>% filter(row_number() %in% n1:n)
    
    leaflet(values$final_dataset) %>% addTiles() %>%
      addPolylines(
        data = values$final_dataset,
        lng = ~ LON,
        lat = ~ LAT,
        weight = 3,
        color = "#03F",
        opacity = 3
      ) %>%
      addCircles(
        data = values$final_dataset,
        lng = ~ LON,
        lat = ~ LAT,
        weight = 9,
        radius = 3,
        color = "#15354a",
        opacity = 3
      )%>%
      addLegend("bottomright", 
                colors ="#03F",
                labels= values$final_dataset$distance[2],
                title= "Longest Distacne in meters",
                opacity = 1)
  
  })
  output$title_ui<-renderUI({
               tags$h2("Displaying Longest Distance of the Selected Vessel","[",input$select_vesselname,"]")
  })
output$log_class_ui<-renderUI({
  textOutput(ns("log_lal_values"))
})
output$log_lal_values<-renderText({
  paste0("Long:",values$final_dataset$LON,"","Lat",values$final_dataset$LAT)
})
}

# End of the Server Module....
