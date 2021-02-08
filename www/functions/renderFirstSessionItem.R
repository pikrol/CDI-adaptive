renderFirstSessionItem <- function(output, itemsAnsweredNr = 0){
  
  #Select first session item
  nextItem <<- findNextItem(CATdesign)
  
  #Render first session question
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
  output$progressBar <- createProgressBar(itemsAnsweredNr / maxItemsNr)
  
}