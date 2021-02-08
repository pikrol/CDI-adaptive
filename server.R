server <- function(input, output, session) {
  
  observe({
    
    #Read parameters values from URL
    id <- readFromURL("id", session)
    form <- readFromURL("form", session)
    lang <- readFromURL("lang", session)

    #Render UI if all needed URL parameters are given
    if (!is.null(id) & !is.null(form) & !is.null(lang)){
      
      #Load items and translations
      setwd(paste0(dataPath, "/", lang ))
      items <- read.csv(paste0("items-", form, ".csv"), encoding = "UTF-8", strip.white = T)
      txt <- read.csv("translations.csv", encoding = "UTF-8", sep = ";", strip.white = T)
      txt <<- txt[(txt$form == form | txt$form == ""), ]
      setwd(initPath)
      
      #Render CDI name
      output$cdiNamePrefix <- renderText({txt[txt$text_type == "cdiNamePrefix", "text"]})
      output$cdiNameSufix <- renderText({txt[txt$text_type == "cdiNameSufix", "text"]})
      
      #Generate mirt object from items parameters
      params <- items[, c("a1", "d")]
      mirt_object <- generate.mirt_object(params, '2PL')
      
      #Get items names
      itemsNames <<- items$item
      
      #TODO: Set number of items to be administered
      maxItemsNr <<- 5
      
      #TODO: Set initial theta
      thetaStart <<- 0
      
      #Get design file for current params
      designFile <- paste0("designs/", lang, "-", form, "-", id, ".rds")
      
      if (!file.exists(designFile)){
        
        ### FIRST TIME ###
        
        #Render intro
        output$main <- renderUI({txt[txt$text_type == "intro", "text"]})
        
        #Render sidebar
        output$sidebar <- renderUI({
          actionButton("nextButton", label = txt[txt$text_type == "nextButton", "text"])
        })
        
        #CAT will be initialized when next button clicked
        initCAT <<- TRUE
        
      } else {
        
        ### LOAD TERMINATED CAT ###
        
        #No need to initialize CAT for given person
        initCAT <<- FALSE
        
        #Load existing design
        CATdesign <<- readRDS(designFile)
        
        #Get number of items already answered
        itemsAnsweredNr <- length(na.omit(CATdesign$person$items_answered))
        
        if (itemsAnsweredNr < maxItemsNr){
          
          #Render sidebar with next button
          output$sidebar <- renderUI({
            actionButton("nextButton", label = txt[txt$text_type == "nextButton", "text"])
          })
          
          #Render first item in current session
          renderFirstSessionItem(output, itemsAnsweredNr)
          
        } else {
          
          #Render message about done inventory
          output$main <- renderText({txt[txt$text_type == "done", "text"]})
          
        }
        
      }
      
      #Add next button actions
      observeEvent(input$nextButton, {
        
        if (initCAT){
          
          ### INITIALIZE CAT ###
          
          #Create design
          CATdesign <<- mirtCAT(mo = mirt_object, method = 'ML', criteria = "MI", start_item = "MI", design_elements = TRUE, design = list(thetas.start = thetaStart))
          
          #CAT has been initialized already for given person
          initCAT <<- FALSE
          
          #Render first item in current session
          renderFirstSessionItem(output)
          
        } else {
          
          ### NEXT STEP ###
          
          if (!is.null(input$question)){
            
            #Save response
            CATdesign <- updateDesign(CATdesign, new_item = nextItem, new_response = input$question)
            
            #Get number of items already answered
            itemsAnsweredNr <- length(na.omit(CATdesign$person$items_answered)) 
            
            #Render progress bar
            output$progressBar <- createProgressBar(itemsAnsweredNr / maxItemsNr)
            
            if (itemsAnsweredNr < maxItemsNr){
              
              #Render next item
              nextItem <<- findNextItem(CATdesign)
              updateRadioButtons(session, "question", label = paste0(txt[txt$text_type == "question", "text"], ' "', itemsNames[nextItem], '"?'), selected = character(0))
              output$warning <- renderText({})
              
            } else {
              
              #Thanks message - End of test
              output$sidebar <- renderUI({})
              output$main <- renderText({txt[txt$text_type == "thanks", "text"]})
              output$warning <- renderText({})
              #print(CATdesign$person)
              
            }
            
          } else {
            
            #Warning message - No answer given
            output$warning <- renderText({txt[txt$text_type == "warning", "text"]})
            
          }

        } 

      })
      
      #Save CAT design to file when session ended
      session$onSessionEnded(function() {
        if (exists("CATdesign")) saveRDS(CATdesign, designFile)
      })
      
    } else {
      
      #Update URL
      updateQueryString(paste0("?id=", "test", "&form=", "WS", "&lang=", "Polish"))
      
      #Reload session
      session$reload()
      
    }
    
  })
  
}