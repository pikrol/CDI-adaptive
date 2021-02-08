createProgressBar <- function(fraction){
  
  return(
    
    renderUI({
      
      div(
        
        class = "progress",
        
        div(
          
          class = "progress-bar",
          style = paste0("width: ", ceiling(100*fraction), "%;"),
          paste0(ceiling(100*fraction), "%")
          
        )
        
      )
      
    })
    
  )
  
}