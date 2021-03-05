startTest <- function(input, output, session){
  
  #Select current test
  if (is.na(currSubject$test)){
  
    #Select test by age
    subjectAge <- interval(currSubject$birth, Sys.Date()) %/% months(1)
    
    #TODO
    if (subjectAge == 0) test <<- "ws" #TODO
    subjects[subjects$id == idx, "test"] <<- test
    currSubject <<- subjects[subjects$id == idx, ]

  } else {
    test <<- currSubject$test
  }
  
  #TODO
  maxItemNr <<- 5
  
  #Load items and prepare path for design file
  setwd(langDataPath)
  items <<- read.csv(paste0("items-", test, ".csv"), encoding = "UTF-8", strip.white = T)
  setwd(initPath)
  itemsNames <<- items$item
  designFile <<- paste0("designs/", lang, "-", test, "-", idx, ".rds")
  
  #Prepare CAT design
  if (file.exists(designFile)){
    CATdesign <<- readRDS(designFile)
  } else {
    
    #Prepare start theta
    if (is.na(currSubject$prevTheta)){
      startTheta <<- 0 #TODO
    } else {
      startTheta <<- subjects[subjects$id == idx, "prevTheta"]
    }
    
    #Create CAT design
    params <- items[, c("a1", "d")]
    mirt_object <- generate.mirt_object(params, '2PL')
    CATdesign <<- mirtCAT(mo = mirt_object, method = 'ML', criteria = "MI", start_item = "MI", design_elements = TRUE, design = list(thetas.start = startTheta))
    
  }
  
  #Render sidebar instruction
  output$sidebar <- renderUI({
    div(class = "help-block", txt[txt$text_type == "testInstr", "text"])
  })
  
  #Render first question
  nextItem <<- findNextItem(CATdesign)
  output$main <- renderUI({
    radioButtons(
      "question",
      label = paste0(txt[txt$text_type == "question", "text"], ' "', itemsNames[nextItem], '"?'),
      selected = character(0),
      choiceNames = strsplit(txt[txt$text_type == "choiceNames", "text"], ",")[[1]],
      choiceValues = c(0,1)
    )
  })
  
  #Render progress bar
  itemsAnsweredNr <<- length(na.omit(CATdesign$person$items_answered))
  createProgressBar(output)
  
  #Awaiting response
  observeEvent(input$question, {
    
    #Update design
    if (!is.null(input$question)) CATdesign <<- updateDesign(CATdesign, new_item = nextItem, new_response = input$question)
    
    #Update progress bar
    itemsAnsweredNr <<- length(na.omit(CATdesign$person$items_answered))
    createProgressBar(output)
    
    if (checkStop()){
      
      #Test end
      subjects[subjects$id == idx, "test"] <<- "end"
      output$sidebar <- renderUI({ div(class = "help-block", txt[txt$text_type == "thanks", "text"]) })
      output$main <- renderUI({})
      
    } else {
      
      #Render next item
      nextItem <<- findNextItem(CATdesign)
      updateRadioButtons(session, "question", label = paste0(txt[txt$text_type == "question", "text"], ' "', itemsNames[nextItem], '"?'), selected = character(0))
      
    }
    
  })
  
}