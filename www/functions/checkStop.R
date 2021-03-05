checkStop <- function(){
  
  #Return TRUE if test should stop, FALSE otherwise
  itemsAnsweredNr <- length(na.omit(CATdesign$person$items_answered))
  if (itemsAnsweredNr < maxItemNr) return(FALSE)
  return(TRUE)
  
}