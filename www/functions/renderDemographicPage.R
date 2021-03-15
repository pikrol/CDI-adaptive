renderDemographicPage <- function(input, output, session){
  
  #Main panel
  output$main <- renderUI({
    
    list(
      
      dateInput(
        "birth",
        txt[txt$text_type == "birthQuestion", "text"]
      ),
      
      radioButtons(
        "gender",
        label = txt[txt$text_type == "genderQuestion", "text"],
        selected = character(0),
        choiceNames = strsplit(txt[txt$text_type == "genders", "text"], ",")[[1]],
        choiceValues = c("female", "male", "other")
      ),
      
      div(id = "btnDiv", actionButton("btn", label = txt[txt$text_type == "btn", "text"], class = "btn-primary"))
      #actionButton("btn", label = txt[txt$text_type == "btn", "text"], class = "btn-primary")
      
    )
    
  })
  
  #Sidebar
  output$sidebar <- renderUI({
    list(
      h3(txt[txt$text_type == "sidebarBigTextH3", "text"]),
      div(class = "help-block", txt[txt$text_type == "sidebarInstr", "text"])
    )
  })
  
  #Awaiting answer
  observeEvent(input$btn, {
    
    if (is.null(input$gender)){
      output$warning <- renderText({txt[txt$text_type == "noGender", "text"]})
    } else {
      output$warning <- renderText({})
      subjects[subjects$id == idx, "birth"] <<- paste(input$birth)
      subjects[subjects$id == idx, "gender"] <<- input$gender
      currSubject <<- subjects[subjects$id == idx, ]
      startTest(input, output, session)
    }
    
  })
  
}