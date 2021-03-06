### Contains all modules associated with the sidebar of the climex app.

##' @title Selecting the database in the Climex app
##' @description Selecting the database.
##' @details Provides the \code{\link[shinydashboard]{menuItemOutput}}
##'   for \code{\link{sidebarDataBase}}. See the later one for
##'   details. 
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @family sidebar
##' 
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarDataBaseInput <- function(){
  menuItemOutput( "sidebarDataBase" )
}

##' @title Selecting the database in the Climex app
##' @description Selecting the database.
##' @details For now there are three different data sources you can
##' choose:the input provided when calling \code{\link{climex}}() on
##'   localhost or a file loaded via the sidebar, the station data of
##'   the German weather service (DWD) and artificial data sampled
##'   from a GEV distribution. When the climex app is used with the
##'   shiny-server, the input option will be disabled. Beware: it's
##'   not a true module! Using the namespaces does not really make
##'   sense because it has to be accessed from outside of this
##'   context. 
##'
##' @param session Namespace session. For details check out
##' \url{http://shiny.rstudio.com/articles/modules.html}
##' 
##' @import shiny
##'
##' @family sidebar
##'
##' @return renderMenu
##' @author Philipp Mueller 
sidebarDataBase <- function( session ){
  ## Disable the input option for the shiny server
  renderMenu( {
    if ( session$clientData$url_hostname == "localhost" ||
         session$clientData$url_hostname == "127.0.0.1" ){
      selectInput( "selectDataBase", "Data base",
                  choices = c( "Input", "DWD", "Artificial data" ),
                  selected = "DWD" )
    } else {
      selectInput( "selectDataBase", "Data base",
                  choices = c( "DWD", "Artificial data" ),
                  selected = "DWD" )
    }
  } )
}

##' @title Sidebar menu selection in the Climex app
##' @description Sidebar menu selection.
##' @details Provides the \code{\link[shinydashboard]{menuItemOutput}}
##'   for \code{\link{sidebarDataSource}}. See the later one for
##'   details.
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @family sidebar
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarDataSourceInput <- function(){
  menuItemOutput( "sidebarDataSource" )
}

##' @title Sidebar menu selection in the Climex app
##' @description Sidebar menu selection.
##' @details Provides the second selection menu in the sidebar.
##' If input$selectDataBase, provided by \code{\link{sidebarDataBase}},
##' was set to "Artificial data", the menu will be a numerical input
##' slider to provide the location parameter for the GEV or scale
##' parameter for the GP distribution. Else it will be a drop down menu
##' listing the names of all available stations (see
##'   \code{\link{data.chosen}}) 
##'
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{\link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' @param reactive.chosen Reactive value containing a list of the list
##' of all provided stations and a data.frame containing the meta data.
##' @param selected.station Reactive value provided by the
##'   \code{\link{leafletClimex}} function. It contains the name of
##'   the station selected by the user by clicking on the leaflet
##'   map. It's provided as a character and NULL if no click occurred
##'   so far.  
##'
##' @import shiny
##'
##' @family sidebar
##'
##' @return renderMenu
##' @author Philipp Mueller 
sidebarDataSource <- function( selectDataBase, radioEvdStatistics,
                               reactive.chosen, selected.station ){
  renderMenu( {
    ## If artificial data was choosen as the input source, display
    ## a slider for the location parameter of the parent GEV
    ## distribution
    if ( !is.null( selectDataBase() ) &&
         selectDataBase() == "Artificial data" ){
      if ( is.null( radioEvdStatistics() ) ||
           radioEvdStatistics() == "GEV" ){
        ## For GEV data
        sliderInput( "sliderArtificialDataLocation",
                    "Location", -30, 30, 1, round = 0 )
      } else {
        ## For GP data just skip the slider for the location parameter
        sliderInput( "sliderArtificialDataScale",
                    "Scale", 0, 4, .8, round = 0, step = .1 )
      }
    } else {
      ## In case of the DWD data, just show the stations which amount of
      ## years is larger than the specified number (slider)
      ## list(stations.selected, position.selected). This already does
      ## the look-up in file.loading(), input$selectDataBase and
      ## input$selectDataType so no need to repeat these steps.
      data.selected <- reactive.chosen()
      ## Since this is not a crucial element and the other elements have
      ## a fallback to the Potsdam time series we can just wait until
      ## input$selectDataBase and input$sliderYears( used in data.chosen )
      ## are initialized 
      if ( is.null( selectDataBase() ) ||
           is.null( data.selected ) ){
        return( NULL )
      }
      ## Use the leaflet map to choose a individual station
      if ( !is.null( selected.station() ) ){
        station.name <- selected.station()
      } else {
        ## If not just use the Potsdam station for the DWD data
        ## or the first station in the list for every other source
        if ( selectDataBase() == "DWD" ){
          station.name <- "Potsdam"
        } else
          station.name <- as.character(
              data.selected[[ 2 ]]$name[ 1 ] )
      }
      ## export drop-down menu
      selectInput( "selectDataSource", "Station",
                  choices = as.character(  data.selected[[ 2 ]]$name ),
                  selected = as.character( station.name ) )
    }
  } )
}

##' @title Sidebar menu selection in the Climex app
##' @description Sidebar menu selection.
##' @details Provides the \code{\link[shinydashboard]{menuItemOutput}}
##'   for \code{\link{sidebarDataType}}. See the later one for
##'   details. 
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @family sidebar
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarDataTypeInput <- function(){
  menuItemOutput( "sidebarDataType" )
}

##' @title Sidebar menu selection in the Climex app
##' @description Sidebar menu selection.
##' @details Provides the third selection menu in the sidebar.
##' If input$selectDataBase, provided by \code{\link{sidebarDataBase}},
##' was set to "Artificial data", the menu will be a numerical input
##' slider to provide the scale parameter for the GEV or shape
##' parameter for the GP distribution. Else it will be a drop down menu
##' listing the different types of data available at the chosen station.
##'
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{\link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' 
##' @import shiny
##'
##' @family sidebar
##'
##' @return renderMenu
##' @author Philipp Mueller
sidebarDataType <- function( selectDataBase, radioEvdStatistics ){
  renderMenu( {
    if ( !is.null( selectDataBase() ) ){
      if ( selectDataBase() == "DWD" ){
        selectInput( "selectDataType", "Measured variable",
                    choices = c( "Daily max. temp.", "Daily min. temp.",
                                "Daily precipitation" ),
                    selected = "Daily max. temp" )
      } else if ( selectDataBase() == "Artificial data" ){
        if ( is.null( radioEvdStatistics() ) ||
             radioEvdStatistics() == "GEV" ){
          sliderInput( "sliderArtificialDataScale", "Scale", 0, 4,
                      0.8, round = 0, step = .1 )
        } else {
          ## For GP distributed data
          sliderInput( "sliderArtificialDataShape", "Shape", -.7, .7,
                      -.25, round = -2, step = .1 )
        }
      } else if ( selectDataBase() == "Input" ){
        div( id = "aux-placeholder", style = "height: 0px;" )
      }
    } else
      NULL } )
}

##' @title Sidebar menu selection in the Climex app
##' @description Sidebar menu selection.
##' @details Provides the \code{\link[shinydashboard]{menuItemOutput}}
##'   for \code{\link{sidebarLoading}}. See the later one for
##'   details. 
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @family sidebar
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarLoadingInput <- function(){
  menuItemOutput( "sidebarLoading" )
}

##' @title Sidebar menu selection in the Climex app
##' @description Sidebar menu selection.
##' @details Provides the fourth selection menu in the sidebar.
##' If input$selectDataBase, provided by \code{\link{sidebarDataBase}},
##' was set to "Artificial data", the menu will be a numerical input
##' slider to provide the shape parameter for the GEV or NULL for the GP
##' distribution. Else it will be a file input for the user to load
##' additional station data.
##'
##' @param session Namespace session. For details check out
##' \url{ http://shiny.rstudio.com/articles/modules.html}
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{\link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' 
##' @import shiny
##'
##' @family sidebar
##'
##' @return renderMenu
##' @author Philipp Mueller
sidebarLoading <- function( session, selectDataBase,
                           radioEvdStatistics ){
  renderMenu( {
    if ( is.null( selectDataBase() ) )
      return( NULL )
    if ( selectDataBase() == "Artificial data" &&
         ( is.null( radioEvdStatistics() ) ||
           radioEvdStatistics() == "GEV" ) ){
      sliderInput( "sliderArtificialDataShape", "Shape", -.7, .7,
                  -0.25, round = -2, step = .1 )
    } else if ( selectDataBase() == "Input" && (
      session$clientData$url_hostname == "localhost" ||
      session$clientData$url_hostname == "127.0.0.1"  ) ){
      ## due to security concerns only allow the file selection on
      ## localhost
      fileInput( "fileInputSelection", "Choose a .RData file" )
    } else
      return( div( id = "aux-placeholder", style = "height: 0px;" ) )
  } )
}

##' @title Data cleaning in the Climex app
##' @description Toggling the cleaning of the time series.
##' @details Provides the \code{\link[shinydashboard]{menuItemOutput}}
##'   for \code{\link{sidebarCleaning}}. See the later one for
##'   details. 
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @family sidebar
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarCleaningInput <- function(){
  uiOutput( "sidebarCleaning" )
}

##' @title Data cleaning in the Climex app
##' @description Toggling the cleaning of the time series
##' @details A checkbox input. If toggled and the GEV distribution was
##' chosen via input$radioEvdStatistics, all incomplete years will be
##' removed from the time series. If on the other hand the GP
##' distribution was picked, all cluster will be removed and only their
##' highest point will remain.
##' 
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{\link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##' 
##' @import shiny
##'
##' @family sidebar
##'
##' @return renderMenu
##' @author Philipp Mueller
sidebarCleaning <- function( radioEvdStatistics, selectDataBase ){
  renderUI({
    ## When applying the blocking method incomplete years distort
    ## the time series and have to be excluded. When using the
    ## threshold method on the other hand clusters are most likely
    ## to occure due to short range correlations. This has to be
    ## avoided by using declustering algorithms (which mainly picks
    ## the maximum of a specific cluster)
    if ( is.null( selectDataBase() ) ||
         selectDataBase() != "Artificial data" ){
      if ( is.null( radioEvdStatistics() ) ||
           radioEvdStatistics() == "GEV" ){
        checkboxInput( "checkboxIncompleteYears",
                      "Remove incomplete years", TRUE )
      } else {
        checkboxInput( "checkboxDecluster",
                      "Declustering of the data", TRUE )
      }
    } else {
      ## When working with artificial data cleaning does not make
      ## sense. Instead we need to resample the time series.
      div( actionButton( "buttonDrawTS", "Draw" ),
          style = "padding: 12px 15px 0px 12px;" )
    }
  })
}

##' @title Series length in the Climex app
##' @description Slider to determine the length of an artificial time series
##' @details Provides the \code{\link[shinydashboard]{menuItemOutput}}
##'   for \code{\link{sidebarSeriesLength}}. See the later one for
##'   details.
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @family sidebar
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarSeriesLengthInput <- function(){
  menuItemOutput( "sidebarSeriesLength" )
}

##' @title Series length in the Climex app
##' @description Slider to determine the length of an artificial time series
##' @details Numerical slider which will only be displayed when
##' "Artificial data" is selected in input$selectDataBase
##' 
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{\link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##' 
##' @import shiny
##'
##' @family sidebar
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarSeriesLength <- function( selectDataBase ){
  renderMenu({
    if ( !is.null( selectDataBase() ) &&
         selectDataBase() == "Artificial data" ){
      ## In order to display the return levels on a
      ## logarithmic scale, the exponent will be
      ## chosen via the slider and its transformation
      ## to 10^x is done in the script and inside a
      ## JavaScript function 
      sliderInput( "sliderSeriesLength", "Length", 1.477121, 3,
                  2, round = 1, step = .1 )
    } else {
      div( id = "aux-placeholder", style = "height: 0px" )
    }
  })
}

##' @title Data selection in the Climex app
##' @description Reactive value selecting an individual time series.
##' @details According to the choice in input$selectDataBase an
##' artificial time series will be sampled or one from a database will be
##' selected. For the latter one the reactive value
##' \code{\link{data.chosen}} will be constulted. The length of
##' the generated time series is determined by the
##' input$sliderSeriesLength.
##'
##' @param reactive.chosen Reactive value containing a list of the list
##' of all provided stations and a data.frame containing the meta data.
##' @param selectDataSource Menu output in the sidebar. Since this
##' function should only be triggered when selectDataBase equals "DWD",
##' this input will be a character string describing the selected
##' station's name.
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{\link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##' @param sliderThreshold Numerical (slider) input determining the
##' threshold used within the GP fit and the extraction of the extreme
##' events. Boundaries: minimal and maximal value of the deseasonalized
##' time series (rounded). Default: 0.8* the upper end point.
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' @param sliderArtificialDataLocation Numerical (slider) input
##' providing the location parameter to generate an artificial time
##' series. For input$radioEvdStatistics == "GP" or input$selectDataBase
##' != "Artificial data" this argument will be NULL.
##' @param sliderArtificialDataScale Numerical (slider) input
##' providing the scale parameter to generate an artificial time
##' series. For input$selectDataBase
##' != "Artificial data" this argument will be NULL.
##' @param sliderArtificialDataShape Numerical (slider) input
##' providing the shape parameter to generate an artificial time
##' series. For input$selectDataBase
##' != "Artificial data" this argument will be NULL.
##' @param buttonDrawTS Action button used to draw a time series when
##' 'artificial data' is chosen in selectDataBase(). If not chosen,
##' this button will not be defined.
##' @param sliderSeriesLength Numerical slider determining the length
##' of an artificial time series. This one will only be present when
##' selectDataBase is set to "Artificial data"
##'
##' @family sidebar
##'
##' @importFrom xts xts
##' @import shiny
##'
##' @return Reactive value containing a 'xts' class time series.
##' @author Philipp Mueller 
data.selection <- function( reactive.chosen, selectDataSource,
                           selectDataBase, sliderThreshold,
                           radioEvdStatistics,
                           sliderArtificialDataLocation,
                           sliderArtificialDataScale,
                           sliderArtificialDataShape, buttonDrawTS,
                           sliderSeriesLength ){
  reactive( {
    ## Selecting the data out of a pool of different possibilities
    ## or generate them artificially
    data.selected <- reactive.chosen()
    if ( is.null( data.selected ) ||
         is.null( selectDataSource() ) ||
         is.null( selectDataBase() ) ||
         ( selectDataBase() == "GP" && is.null( sliderThreshold() ) ) ){
      return( NULL )
    }
    if( selectDataBase() == "Artificial data" ){
      ## Wait for the sidebar to initials the sliders of the GEV
      ## parameters.
      if ( is.null( sliderArtificialDataLocation() ) ||
           is.null( sliderArtificialDataScale() ) ||
           is.null( sliderArtificialDataShape() ) ){
        return( NULL )
      }
      ## Redraw the time series using a button in the sidebar
      if( !is.null( buttonDrawTS() ) ){
        buttonDrawTS()
      }
      ## To transform the artificial time series today's time
      ## stamp will be used and moved to 1900. All following
      ## points will be future years from this point on. This
      ## keeps the idea of annual block maxima
      ## Since the slider just determines the exponent to the
      ## base of 10 in order to display it in a logarithmic awy
      ## I have to transform the input
      series.length <- 10^sliderSeriesLength()
      dates <- rep( lubridate::now(), series.length )
      lubridate::year( dates ) <- 1900 +
        seq( 1, series.length )
      ## Whether to use GEV or GPD data
      if ( is.null( radioEvdStatistics() ) ||
           radioEvdStatistics() == "GEV" ){
        model <- "gev"
      } else {
        model <- "gpd"
      }
      x.xts <- xts(
          revd( n = series.length,
               location = sliderArtificialDataLocation(),
               scale = sliderArtificialDataScale(),
               shape = sliderArtificialDataShape(),
               model = model, silent = TRUE,
               threshold = 0 ),
          order.by = dates )
    } else {
      ## In all other cases the possible choices are contained in
      ## the data.selected object and are agnostic of the data base
      ## /input chosen
      if ( any( class( data.selected[[ 1 ]] ) == "xts" ) ){
        x.xts <- data.selected[[ 1 ]]
      } else {
        ## There is a bug when switching from one data base into
        ## another: since the input$selectDataSource needs a
        ## little bit longer to update it tries to access a value
        ## in here which is might not present in the newly
        ## selected one. If this happens, just select the first
        ## element instead
        if ( !any(  names( data.selected[[ 1 ]] ) ==
                    selectDataSource() ) ){
          x.xts <- data.selected[[ 1 ]][[ 1 ]]
          print( "New data source selected." )
        } else
          x.xts <- data.selected[[ 1 ]][[
                     which( names( data.selected[[ 1 ]] ) ==
                            selectDataSource() ) ]] } }
    return( x.xts )
  } )
}

##' @title File loading in the Climex app
##' @description Reactive value listening for a file input via the
##'   sidebar. 
##' @details To use this function input$selectDataBase has to be set to
##' "Input".
##'
##' @param fileInputSelection File input through a shiny base selection
##' window.
##'
##' @import shiny
##'
##' @family sidebar
##'
##' @return Reactive value containing either an xts class time series,
##' a list of those time series or a list of those lists and an
##' additional data.frame containing meta information about all of the
##' named stations in those list.
##' @author Philipp Mueller 
file.loading <- function( fileInputSelection ){
  reactive( {
    ## If no file is chosen, don't do anything
    if ( is.null( fileInputSelection()$datapath ) )
      return( NULL )
      ## load selected file
      load( fileInputSelection()$datapath,
           file.load.env <- new.env() )
      if ( length( ls( file.load.env ) ) == 1 ){
        ## Just one object is contained in the .RData file
        file.input <- get( ls( file.load.env ), envir = file.load.env )
        if ( any( class( file.input ) ) == "xts" ){
          x.input <- file.input
          return( x.input )
        } else if ( class( file.input ) == "list" ){
          if ( all( class( x.input ) == "xts" ) || (
            length( x.input ) == 2 &&
            "list" %in% Reduce( c, lapply( x.input, class ) ) &&
            "data.frame" %in% Reduce( c, lapply( x.input, class ) ) ) ){
            x.input <- file.input
            return( x.input )
          }
        }
      }
      shinytoastr::toastr_error( "Sorry but this feature is implemented for the format in which the argument x.input is accepted in climex::climex only! Please do the conversion and formatting in R beforehand and just save a .RData containing a single object" )
      return( NULL )
  } )
}

##' @title Gif in the Climex app
##' @description Showing a Gif in the sidebar while the app is
##'   processing/on hold 
##' @details Rendering of \code{\link{sidebarLoadingGif}}.
##'
##' @param id Namespace prefix
##'
##' @family sidebar
##'
##' @import shiny
##'
##' @return div
##' @author Philipp Mueller 
sidebarLoadingGifOutput <- function( id ){
  # Create a namespace function using the provided id
  ns <- NS( id )
  div( uiOutput( ns( "loadingScript" ) ),
      uiOutput( ns( "loadingImage" ) ),
      id = "loadingWrapper" )
} 

##' @title Gif in the Climex app
##' @description Showing a Gif in the sidebar while the app is
##'   processing/on hold 
##' @details This module will display a loading gif. Most of the code of
##' this function is already written in a JavaScript script installed
##' alongside the climex package. It just determines if the app is run on
##' either a localhost (direct interaction) or on a server waiting for
##' client interaction. Accordingly it looks up both the JavaScript script
##' and the corresponding gif file.
##'
##' @param input Namespace input. For more details check out
##' \url{http://shiny.rstudio.com/articles/modules.html}
##' @param output Namespace output.
##' @param session Namespace session.
##'
##' @family sidebar
##'
##' @import shiny
##' 
##' @return div
##' @author Philipp Mueller 
sidebarLoadingGif <- function( input, output, session ){
  output$loadingImage <- renderUI({
    if ( session$clientData$url_hostname != "localhost" &&
         session$clientData$url_hostname != "127.0.0.1" ){
      folder <- "/assets/"
    } else
      folder <- ""
    return( img( src = paste0( folder, "loading.gif" ),
                id = session$ns( "loadingGif" ) ) ) } )
  output$loadingScript <- renderUI({
    if ( session$clientData$url_hostname != "localhost" &&
         session$clientData$url_hostname != "127.0.0.1" ){
      folder <- "/assets/"
    } else
      folder <- ""
    return( div( singleton(
        tags$script( src = paste0( folder, "loadingGif.js" )
                    ) ) ) )
  } )
}

##' @title Imprint of the Climex app
##' @description Linking the imprint of the climex application
##' @details Whenever the web app is run using shiny-server a link to
##' an arbitrary HTML page (preferably an imprint) will be rendered.
##' Else just an empty div will be added.
##' Rendering of \code{\link{sidebarImprint}}.
##'
##' @family sidebar
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
sidebarImprintInput <- function(){
  menuItemOutput( "sidebarImprint" )
}

##' @title Imprint of the Climex app
##' @description Linking the imprint of the climex application
##' @details Whenever the web app is run using shiny-server a link to
##' an arbitrary HTML page (preferably an imprint) will be rendered.
##' Else just an empty div will be added.
##'
##' @param session Namespace session. For details check out
##' \url{http://shiny.rstudio.com/articles/modules.html}
##'
##' @family sidebar
##'
##' @import shiny
##'
##' @return div
##' @author Philipp Mueller 
sidebarImprint <- function( session ){
  renderMenu({
    ## Only display the imprint in the shiny-server and not on
    ## localhost
    if ( session$clientData$url_hostname == "localhost" ||
         session$clientData$url_hostname == "127.0.0.1" ){
      div( id = "aux-placeholder", style = "height: 0px;" )
    } else {
      div( a( "Imprint", href = "/imprint.html",
             id = "climexImprint" ) )
    }
  })
} 
