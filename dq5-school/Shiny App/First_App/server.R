#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
function(input, output) {
  
  output$main_plot <- renderPlot({
    
    hist(t$grad,
         probability = TRUE,
         breaks = as.numeric(input$n_breaks),
         xlab = "Graduation Percentage",
         main = "Graduation Rate Histogram")
    
    
  })
}