ui <- fluidPage(
  
  #Load ready UI theme
  theme = shinytheme("flatly"),
  
  #Load css file with custom apperance settings
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="style.css"),
    tags$link(rel="preconnect", href="https://fonts.gstatic.com"),
    tags$link(href="https://fonts.googleapis.com/css2?family=Lato:wght@300;700&display=swap", rel="stylesheet")
  ),
  
  h1(textOutput("cdiNamePrefix")),
  h2(textOutput("cdiNameSufix")),

  sidebarLayout(
    
    sidebarPanel(
      
      uiOutput("sidebar")
      
    ),
    
    mainPanel(
      
      uiOutput("progressBar"),
      uiOutput("main"),
      textOutput("warning")
      
    )
    
  )
    
)