DSulfatePlotlySingleStationUI <- function(id){
  ns <- NS(id)
  tagList(
    wellPanel(
      h4(strong('Single Station Data Visualization')),
      uiOutput(ns('DSulfate_oneStationSelectionUI')),
      selectInput(ns('sulfateType'),'Select Total or Dissolved Sulfate', choices = c('Total Sulfate', 'Dissolved Sulfate'),
                  width = '30%'),
      plotlyOutput(ns('DSulfateplotly'))  )
  )
}


DSulfatePlotlySingleStation <- function(input,output,session, AUdata, stationSelectedAbove){
  ns <- session$ns
  
  # Select One station for individual review
  output$DSulfate_oneStationSelectionUI <- renderUI({
    req(stationSelectedAbove)
    selectInput(ns('DSulfate_oneStationSelection'),strong('Select Station to Review'),choices= sort(unique(c(stationSelectedAbove(),AUdata()$FDT_STA_ID))),#unique(AUdata())$FDT_STA_ID,
                width='300px', selected = stationSelectedAbove())})# "2-JMS279.41" )})
  
  
  DSulfate_oneStation <- reactive({
    req(ns(input$DSulfate_oneStationSelection))
    filter(AUdata(),FDT_STA_ID %in% input$DSulfate_oneStationSelection)})
  
  
  output$DSulfateplotly <- renderPlotly({
    req(input$DSulfate_oneStationSelection, DSulfate_oneStation(), input$sulfateType)
    if(input$sulfateType == 'Dissolved Sulfate'){
      dat <- DSulfate_oneStation()
      dat$SampleDate <- as.POSIXct(dat$FDT_DATE_TIME2, format="%m/%d/%y")
      
      maxheight <- ifelse(max(dat$SULFATE_DISS, na.rm=T) < 75, 100, max(dat$SULFATE_DISS, na.rm=T)* 1.2)
      box1 <- data.frame(SampleDate = c(min(dat$SampleDate), min(dat$SampleDate), max(dat$SampleDate),max(dat$SampleDate)), y = c(75, maxheight, maxheight, 75))
      box2 <- data.frame(x = c(min(dat$SampleDate), min(dat$SampleDate), max(dat$SampleDate),max(dat$SampleDate)), y = c(25, 75, 75, 25))
      box3 <- data.frame(x = c(min(dat$SampleDate), min(dat$SampleDate), max(dat$SampleDate),max(dat$SampleDate)), y = c(10, 25, 25, 10))
      box4 <- data.frame(x = c(min(dat$SampleDate), min(dat$SampleDate), max(dat$SampleDate),max(dat$SampleDate)), y = c(0, 10, 10, 0))
      
      
      plot_ly(data=dat)%>%
        add_polygons(x = ~SampleDate, y = ~y, data = box1, fillcolor = "firebrick",opacity=0.6, line = list(width = 0),
                     hoverinfo="text", name =paste('High Probability of Stress to Aquatic Life')) %>%
        add_polygons(data = box2, x = ~x, y = ~y, fillcolor = "#F0E442",opacity=0.6, line = list(width = 0),
                     hoverinfo="text", name =paste('Medium Probability of Stress to Aquatic Life')) %>%
        add_polygons(data = box3, x = ~x, y = ~y, fillcolor = "#009E73",opacity=0.6, line = list(width = 0),
                     hoverinfo="text", name =paste('Low Probability of Stress to Aquatic Life')) %>%
        add_polygons(data = box4, x = ~x, y = ~y, fillcolor = "#0072B2",opacity=0.6, line = list(width = 0),
                     hoverinfo="text", name =paste('No Probability of Stress to Aquatic Life')) %>%
        add_markers(data=dat, x= ~SampleDate, y= ~SULFATE_DISS,mode = 'scatter', name="Dissolved Sulfate (mg/L)",marker = list(color= '#535559'),
                    hoverinfo="text",text=~paste(sep="<br>",
                                                 paste("Date: ",SampleDate),
                                                 paste("Depth: ",FDT_DEPTH, "m"),
                                                 paste("Dissolved Sulfate: ",SULFATE_DISS,"mg/L")))%>%
        layout(showlegend=FALSE,
               yaxis=list(title="Dissolved Sulfate (mg/L)"),
               xaxis=list(title="Sample Date",tickfont = list(size = 10)))
    }else{
      dat <- mutate(DSulfate_oneStation(), top = 250)
      dat$SampleDate <- as.POSIXct(dat$FDT_DATE_TIME2, format="%m/%d/%y")
      
      plot_ly(data=dat)%>%
        add_lines(data=dat, x=~SampleDate,y=~top, mode='line', line = list(color = 'black'),
                  hoverinfo = "none", name="Sulfate PWS Criteria (250 mg/L)") %>%
        add_markers(data=dat, x= ~SampleDate, y= ~SULFATE_TOTAL,mode = 'scatter', name="Total Sulfate (mg/L)", marker = list(color= '#535559'),
                    hoverinfo="text",text=~paste(sep="<br>",
                                                 paste("Date: ",SampleDate),
                                                 paste("Depth: ",FDT_DEPTH, "m"),
                                                 paste("Total Sulfate: ",SULFATE_TOTAL," (mg/L)")))%>%
        layout(showlegend=FALSE,
               yaxis=list(title="Total Sulfate (mg/L)"),
               xaxis=list(title="Sample Date",tickfont = list(size = 10)))
    }
    
  })
  
}

