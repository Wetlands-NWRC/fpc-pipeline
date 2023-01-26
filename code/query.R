
query.landcover <- function(DF.input = NULL, land.covers = NULL) {
   if(is.null(land.covers)) {return(DF.input)}

   return(DF.input[DF.input$land_cover %in% land.covers, ])
}

query.year <- function(DF.input = NULL, year = NULL){
   if (is.null(year)) {return(DF.input)}


}