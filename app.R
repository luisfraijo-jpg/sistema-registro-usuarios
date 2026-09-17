library(shiny)
library(DT)
library(dplyr)

archivo_datos <- "usuarios.csv"

if (!file.exists(archivo_datos)) {
  write.csv(data.frame(Nombre = character(), Correo = character(), Fecha = character(), stringsAsFactors = FALSE), 
            archivo_datos, row.names = FALSE)
}
#usuarios
ui <- fluidPage(
  titlePanel("Sistema de Registro y Gestión de Usuarios"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Registrar nuevo usuario"),
      textInput("nombre", "Nombre completo:"),
      textInput("correo", "Correo electrónico:"),
      actionButton("guardar", "Registrar Usuario", class = "btn-primary")
    ),
    
    mainPanel(
      h4("Lista de usuarios registrados"),
      DTOutput("tabla_usuarios")
    )
  )
)

#Server
server <- function(input, output, session) {
  
  datos <- reactiveVal(read.csv(archivo_datos, stringsAsFactors = FALSE))
  
  observeEvent(input$guardar, {
    req(input$nombre, input$correo)
    
    nuevo_usuario <- data.frame(
      Nombre = input$nombre,
      Correo = input$correo,
      Fecha = as.character(Sys.Date()),
      stringsAsFactors = FALSE
    )
    
    # Guardar en el CSV
    write.table(nuevo_usuario, archivo_datos, sep = ",", append = TRUE, 
                row.names = FALSE, col.names = FALSE)
    
    # Actualizaciooon
    datos(read.csv(archivo_datos, stringsAsFactors = FALSE))
    
    updateTextInput(session, "nombre", value = "")
    updateTextInput(session, "correo", value = "")
    
    showNotification("Usuario registrado con éxito", type = "message")
  })
  
  output$tabla_usuarios <- renderDT({
    datatable(datos(), options = list(pageLength = 5))
  })
}

shinyApp(ui = ui, server = server)