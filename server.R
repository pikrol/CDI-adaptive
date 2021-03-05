server <- function(input, output, session) {
  
  observe({
    
    #Read params from URL
    idx <<- readFromURL("id", session)
    form <<- readFromURL("form", session)
    lang <<- readFromURL("lang", session)

    if (!is.null(idx) & !is.null(form) & !is.null(lang)){
      
      #Load translations
      langDataPath <<- paste0(dataPath, "/", lang)
      setwd(langDataPath)
      txt <<- read.csv("translations.csv", encoding = "UTF-8", sep = ";", strip.white = T)
      setwd(initPath)
      
      #Render CDI name
      output$cdiNamePrefix <- renderText({txt[txt$text_type == "cdiNamePrefix", "text"]})
      output$cdiNameSufix <- renderText({txt[txt$text_type == "cdiNameSufix", "text"]})
      
      #Add or select subject
      if (!is.element(idx, subjects$id)) subjects <<- subjects %>% add_row(id = idx)
      currSubject <<- subjects[subjects$id == idx, ]
      
      #Render proper UI
      if (is.na(currSubject$birth) | is.na(currSubject$gender)){
        renderDemographicPage(input, output, session)
      } else {
        if (!is.na(currSubject$test) & currSubject$test == "end"){
          output$sidebar <- renderUI({ div(class = "help-block", txt[txt$text_type == "thanks", "text"]) })
        } else {
          startTest(input, output, session)
        }
      }
      
      #Save data
      session$onSessionEnded(function() {
        if (exists("CATdesign")) saveRDS(CATdesign, designFile)
        write.csv(subjects, subjectsFile, row.names = F)
      })
      
    } else {
      
      #Update URL
      updateQueryString(paste0("?id=", "test1", "&form=", "ws", "&lang=", "pl"))
      session$reload()
      
    }
    
  })
  
}