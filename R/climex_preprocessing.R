### Mostly functions associated with preprocessing the individual time
### series. Most of those steps can be controlled via the General tab

##' @title Extracting extreme events in the Climex app
##' @description Extract the extreme events from a given time series.
##' @details Provides the \code{\link[shinydashboard]{menuItemOutput}}
##'   for \code{\link{generalExtremeExtraction}}. See the later one
##'   for details. 
##'
##' @importFrom shinydashboard menuItemOutput
##'
##' @family preprocessing
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
generalExtremeExtractionInput <- function(){
  menuItemOutput( "generalExtremeExtraction" )
}

##' @title Extracting extreme events in the Climex app
##' @description Extract the extreme events from a given time series.
##' @details Provides a slider input to determine either the block length
##' (in case of the GEV distribution) or the height of the threshold (GP)
##' 
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' @param deseasonalize.interactive Function used to remove seasonality
##' from a given time series. \code{\link{deseasonalize.interactive}}
##' @param selectDeseasonalize Character (select) input determining which
##' deseasonalization method should be used to remove the short-range
##' correlations from the provided time series.
##' \code{\link{deseasonalizeSelectionInput}}
##' @param buttonMinMax Character (radio) input determining whether
##' the GEV/GP distribution shall be fitted to the smallest or biggest
##' vales. Choices: c( "Max", "Min ), default = "Max".
##' @param reactive.selection Reactive value contains the xts type time
##' series of the individual station/input chosen via the sidebar or the
##' leaflet map. \code{\link{data.selection}}
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
##' @family preprocessing
##'
##' @return renderMenu
##' @author Philipp Mueller
generalExtremeExtraction <- function( radioEvdStatistics,
                                     deseasonalize.interactive,
                                     selectDeseasonalize,
                                     buttonMinMax, reactive.selection,
                                     selectDataBase ){
  renderMenu( {
    x.xts <- reactive.selection()
    if ( !is.null( radioEvdStatistics() ) &&
         radioEvdStatistics() == "GEV" ){
      isolate( {
        ## I do not want the blocklength to be reset when changing
        ## the deseasonalization method.
        x.deseasonalized <- deseasonalize.interactive(
            x.xts, selectDeseasonalize, selectDataBase )
      } )
    } else {
      x.deseasonalized <- deseasonalize.interactive(
          x.xts, selectDeseasonalize, selectDataBase )
    }
    if ( is.null( x.deseasonalized ) ){
      ## if the initialization has not finished yet just wait a
      ## little longer
      return( NULL )
    }
    if ( selectDataBase() == "Artificial data" ){
      ## Since the artificial data will be sampled directly from a
      ## GEV/GP distribution, there is no point for blocking or
      ## thresholding
      return( div( id = "aux-placeholder", style = "height: 0px;" ) )
    }
    if ( radioEvdStatistics() == "GEV" ){
      sliderInput( "sliderBlockLength", "Box length in days", 1,
                  365*3, 365 )
    } else {
      ## Set the threshold in such a way remaining.fraction of the
      ## data are still available for the fit
      remaining.fraction <- 0.01
      threshold.default <- sort( as.numeric( x.deseasonalized ),
                        decreasing = TRUE )[
          round( length( x.deseasonalized )* remaining.fraction ) ] 
      sliderInput( "sliderThreshold", "Threshold:",
                  round( min( x.deseasonalized, na.rm = TRUE ) ),
                  round( max( x.deseasonalized, na.rm = TRUE ) ),
                  round( threshold.default ),
                  step = 0.1 )
    }
  } )
}

##' @title Cleaning data in the Climex app
##' @description Function to get rid of artifacts within the Climex app
##' @details The app does two things: First it replaces all -999 and NaN
##' in the time series by NaN (the former is the default indicator in
##' the data of the German weather service for missing values).
##' Second it removes all incomplete years (GEV) or cluster (GP) when
##' the corresponding checkbox is checked.
##'
##' @param x.xts Time series of class 'xts' which has to be cleaned.
##' @param checkboxIncompleteYears Logical (checkbox) input determining
##' whether to remove all incomplete years of a time series. This box
##' will be only available if input$radioEvdStatistics == "GEV" and else
##' will be NULL.
##' @param checkboxDecluster Logical (checkbox) input determining
##' whether to remove all clusters in a time series and replace them by
##' their maximal value. This box will be only available if
##' input$radioEvdStatistics == "GP" and else will be NULL.
##' @param sliderThreshold Numerical (slider) input determining the
##' threshold used within the GP fit and the extraction of the extreme
##' events. Boundaries: minimal and maximal value of the deseasonalized
##' time series (rounded). Default: 0.8* the upper end point. This one
##' is only used in declustering the time series.
##'
##' @family preprocessing
##'
##' @return Time series of class 'xts'.
##' @author Philipp Mueller 
cleaning.interactive <- function( x.xts, checkboxIncompleteYears,
                                 checkboxDecluster, sliderThreshold ){
    x.xts[ which( is.na( x.xts ) ) ] <- NaN
    x.xts[ which( x.xts == -999 ) ] <- NaN
    if ( !is.null( checkboxIncompleteYears() ) &&
         checkboxIncompleteYears() ){
        ## Remove all incomplete years from time series
      x.xts <- climex::remove.incomplete.years( x.xts )
    }
    if ( !is.null( checkboxDecluster() ) &&
         checkboxDecluster() ){
      x.xts <- climex::decluster( x.xts, sliderThreshold() )
    }
    if ( any( is.nan( x.xts ) ) )
      print( "The current time series contains missing values. Please be sure to check 'Remove incomplete years' in the sidebar to avoid wrong results!" )
    return( x.xts )
}

##' @title Minimum or maximum extremes in the Climex app
##' @description Whether to determine the minimal or maximal extremes.
##' @details Not a real shiny module, since I have to use this select
##' input outside its namespace. Provides the
##' \code{\link[shinydashboard]{menuItemOutput}} for
##'   \code{\link{generalButtonMinMaxInput}}
##'  
##' @importFrom shinydashboard menuItemOutput
##'
##' @family preprocessing
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
generalButtonMinMaxInput <- function(){
  uiOutput( "generalButtonMinMax" )
}
##' @title Minimum or maximum extremes in the Climex app
##' @description Whether to determine the minimal or maximal extremes.
##' @details Not a real shiny module, since I have to use this select
##' input outside its namespace. Only when input$radioEvdStatistics
##' is set of "GEV" the minimal extremes scan be used.
##' 
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' @param selectDataType Character (select) input to determine which set
##' measurements should be used for the selected station. In case of the
##' default import of the DWD data, there are three options:
##' c( "Daily max. temp", "Daily min. temp", "Daily precipitation" ).
##' Determined by menuSelectDataType.
##' 
##' @importFrom shinydashboard menuItemOutput
##'
##' @family preprocessing
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
generalButtonMinMax <- function( radioEvdStatistics, selectDataType ){
  renderUI({
    ## The minimal extremes are only available when using the GEV
    ## distribution
    if ( is.null( radioEvdStatistics() ) ||
         radioEvdStatistics() == "GEV" ){
      if ( is.null( selectDataType() ) ||
           selectDataType() != "Daily precipitation" ){
        radioButtons( inputId = "buttonMinMax", "Type of extreme",
                     inline = TRUE, choices = c( "Max", "Min" ),
                     selected = "Max" )
      } else {
        ## For the precipitation it does not make any sense at all
        ## to calculate the minimal extremes.
      radioButtons( inputId = "buttonMinMax", "Type of extreme",
                   inline = TRUE, choices = "Max" )
      }
    } else {
      radioButtons( inputId = "buttonMinMax", "Type of extreme",
                   inline = TRUE, choices = "Max" )
    }
  } )
}

##' @title Removing the seasonality in the Climex app
##' @description Removing the seasonality.
##' @details Not a real shiny module, since I have to use this select
##' input outside its namespace. Provides the
##' \code{\link[shinydashboard]{menuItemOutput}} for
##'   \code{\link{deseasonalizeSelection}} 
##' 
##' @importFrom shinydashboard menuItemOutput
##'
##' @family preprocessing
##'
##' @return menuItemOutput
##' @author Philipp Mueller 
deseasonalizeSelectionInput <- function(){
  menuItemOutput( "deseasonalizeSelection" )
}

##' @title Removing the seasonality in the Climex app
##' @description Removing the seasonality.
##' @details Not a real shiny module, since I have to use this select
##' input outside its namespace.
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
##' @family preprocessing
##'
##' @return selectInput
##' @author Philipp Mueller 
deseasonalizeSelection <- function( selectDataBase ){
  renderMenu({
    if ( selectDataBase() == "Artificial data" ){
      ## Since the artificial data will be sampled directly from a
      ## GEV/GP distribution, there is no point for blocking or
      ## thresholding
      return( div( id = "aux-placeholder", style = "height: 0px;" ) )
    }
    selectInput( "selectDeseasonalize", "Deseasonalization method",
                choices = c( "Anomalies", "stl", "decompose",
                            "deseasonalize::ds", "none" ),
                selected = "Anomalies" )
  })
}

##' @title Removing seasonality in the Climex app
##' @description Function for removing the seasonality of a given time
##'   series within the Climex app.
##'
##' @param x.xts Time series of class 'xts' which has to be cleaned.
##' @param selectDeseasonalize Character (select) input determining which
##' deseasonalization method should be used to remove the short-range
##' correlations from the provided time series.
##' \code{\link{deseasonalizeSelectionInput}}. If NULL \code{\link{anomalies}}
##'   will be used.
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##'
##' @family preprocessing
##'
##' @return Time series of class 'xts'.
##' @author Philipp Mueller 
deseasonalize.interactive <- function( x.xts, selectDeseasonalize,
                                      selectDataBase ){
    if ( is.null( x.xts ) ||
         is.null( selectDataBase() ) ){
      ## if the initialization has not finished yet just wait a little
      ## longer
      return( NULL )
    }
    if ( selectDataBase() == "Artificial data" ){
      ## For the artificial data there is no need for deseasonalization.
      return( x.xts )
    }
    ## Removing all NaN or most algorithms won't work. But anyway. Just
    ## removing the values won't make then run correctly. But the user
    ## is warned to remove the incomplete years.
    if ( any( is.na( x.xts ) ) ){
      x.no.nan <- stats::na.omit( x.xts )
    } else {
      x.no.nan <- x.xts
    }
    ## Since the selectDeseasonalize input will be now powered by the
    ## server side, it will have the value NULL until the user reaches
    ## the General tab. In this case use the "Anomalies" method as
    ## default.
    if ( is.null( selectDeseasonalize() ) ){
      selected.method <- "Anomalies"
    } else {
      selected.method <- selectDeseasonalize()
    }
    x.deseasonalized <- switch(
        selected.method,
        "Anomalies" = climex::anomalies( x.xts ),
        "decompose" = {
          x.decomposed <-
            stats::decompose(
                       stats::ts( as.numeric( x.no.nan ),
                                 frequency = 365.25 ) )
          if ( any( is.nan( x.xts ) ) ){
            ## Adjusting the length of the results by adding the NaN
            ## again
            x.aux <- rep( NaN, length( x.xts ) )
            x.aux[ which( x.xts %in% x.no.nan ) ] <-
              as.numeric( x.decomposed$seasonal )
          } else {
            x.aux <- as.numeric( x.decomposed$seasonal )
          }
          x.xts - x.aux
        },
        "stl" = {
          x.decomposed <- stats::stl(
                                     stats::ts( as.numeric( x.no.nan ),
                                               frequency = 365.25 ),
                                     30 )
          if ( any( is.nan( x.xts ) ) ){
            ## Adjusting the length of the results by adding
            ## the NaN again
            x.aux <- rep( NaN, length( x.xts ) )
            x.aux[ which( x.xts %in% x.no.nan ) ] <- as.numeric(
                x.decomposed$time.series[ , 1 ] )
          } else
            x.aux <- as.numeric( x.decomposed$time.series[ , 1 ] )
            x.xts - x.aux }, 
        "deseasonalize::ds" = {
          x.ds <- deseasonalize::ds( x.no.nan )$z
          if ( any( is.nan( x.xts ) ) ){
            ## Adjusting the length of the results by adding
            ## the NaN again
            x.aux <- rep( NaN, length( x.xts ) )
            x.aux[ which( x.xts %in% x.no.nan ) ] <-
              as.numeric( x.ds )
          } else {
            x.aux <- as.numeric( x.ds )
          }
          xts( x.aux, order.by = index( x.xts ) ) 
        },
        "none" = x.xts )
    if ( is.na( max( x.deseasonalized ) ) ){
      ## I don't wanna any NaN in my time series. In some cases the
      ## deseasonalization methods themselves produce them. It's a
      ## dirty solution, but just omitting them and informing the user
      ## will work for now.
      x.deseasonalized <- stats::na.omit( x.deseasonalized )
      print( "NaNs produced during the deseasonalization." )
    }
    return( x.deseasonalized )
}

##' @title Extracting extreme events in the Climex app
##' @description Function to extract the extreme event from a time
##'   series. 
##' @details If the input$radioEvdStatistics is set to "GEV" the time
##' series will be block. If it's on the other hand set to "GP", all
##' values above a certain threshold will be extracted.
##' 
##' @param x.xts Time series of class 'xts' which has to be cleaned.
##' @param buttonMinMax Character (radio) input determining whether
##' the GEV/GP distribution shall be fitted to the smallest or biggest
##' vales. Choices: c( "Max", "Min ), default = "Max".
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' @param sliderBlockLength Numerical (slider) input determining the
##' block length used in the GEV flavor of extreme value theory. On
##' default it is set to one year.
##' @param sliderThreshold Numerical (slider) input determining the
##' threshold used within the GP fit and the extraction of the extreme
##' events. Boundaries: minimal and maximal value of the deseasonalized
##' time series (rounded). Default: 0.8* the upper end point.
##' @param checkboxDecluster Logical (checkbox) input determining
##' whether to remove all clusters in a time series and replace them by
##' their maximal value. This box will be only available if
##' input$radioEvdStatistics == "GP" and else will be NULL.
##'
##' @family preprocessing
##'
##' @return Time series of class 'xts'.
##' @author Philipp Mueller 
extremes.interactive <- function( x.xts, buttonMinMax,
                                 radioEvdStatistics, sliderBlockLength,
                                 sliderThreshold, checkboxDecluster ){
  if ( is.null( buttonMinMax() ) &&
       ( !is.null( sliderBlockLength() ) ||
         !is.null( sliderThreshold() ) ) ){
    ## Those amigos are in the same windows and should be initialized
    ## together
    return( NULL )
  }    
  ## Toggle if maxima of minima are going to be used
  if ( is.null( buttonMinMax() ) || buttonMinMax() == "Max" ){
    block.mode <- "max"
  } else
    block.mode <- "min"
  if ( is.null( radioEvdStatistics() ) ||
       ( radioEvdStatistics() == "GEV" &&
         is.null( sliderBlockLength() ) ) ){
    ## While initialization input$radioEvdStatistics and
    ## input$sliderBoxLength are NULL. Therefore this is the
    ## fallback default x.extreme
    x.extreme <- climex::block( x.xts, separation.mode = "years",
                             block.mode = block.mode )
  } else if ( radioEvdStatistics() == "GEV" ){
    x.extreme <- climex::block( x.xts, block.length = sliderBlockLength(),
                             block.mode = block.mode )
  } else if ( radioEvdStatistics() == "GP" ){
    ## Since the GP can only be set in the General tab, the
    ## input$sliderThreshold has to be initialized eventually. Just have
    ## some more patience and throw a NULL
    if ( is.null( sliderThreshold() ) ){
      return( NULL )
    }
    ## Check if at least two data points are above the threshold
    if ( sum( as.numeric( x.xts ) > sliderThreshold() ) < 2 ){
      shinytoastr::toastr_error(
                       "Threshold is set way to high!",
                       preventDuplicates = TRUE )
      return( NULL )
    }
    x.extreme <- climex::threshold( x.xts,
                                 threshold = sliderThreshold(),
                                 decluster = checkboxDecluster(),
                                 na.rm = TRUE )
    return( x.extreme )
  }
}

##' @title Extracting extremes in the Climex app
##' @description Reactive value extracting the extreme event of a time
##'   series and all input.
##' @details First this reactive value will use reactive.selection to
##' obtain the time series it shall be working on. Afterwards it applies
##' both deseasonalize.interactive and extremes.interactive to this time
##' series. Finally it return the resulting extreme events as well as the
##' deseasonalized and pure time series.
##'
##' @param reactive.selection Reactive value providing a time series of
##' class 'xts'. \code{\link{data.selection}}
##' @param radioEvdStatistics Character (radio) input determining whether
##' the GEV or GP distribution shall be fitted to the data. Choices:
##' c( "GEV", "GP" ), default = "GEV".
##' @param sliderBlockLength Numerical (slider) input determining the
##' block length used in the GEV flavor of extreme value theory. On
##' default it is set to one year.
##' @param sliderThreshold Numerical (slider) input determining the
##' threshold used within the GP fit and the extraction of the extreme
##' events. Boundaries: minimal and maximal value of the deseasonalized
##' time series (rounded). Default: 0.8* the upper end point.
##' @param checkboxDecluster Logical (checkbox) input determining
##' whether to remove all clusters in a time series and replace them by
##' their maximal value. This box will be only available if
##' input$radioEvdStatistics == "GP" and else will be NULL.
##' @param deseasonalize.interactive Function used to remove seasonality
##' from a given time series. \code{\link{deseasonalize.interactive}}
##' @param selectDeseasonalize Character (select) input determining which
##' deseasonalization method should be used to remove the short-range
##' correlations from the provided time series.
##' \code{\link{deseasonalizeSelectionInput}}
##' @param selectDataBase Character (select) input to determine the data
##' source. In the default installation there are three options:
##' c( "Input", "DWD", "Artificial data" ). The first one uses the data
##' provided as an argument to the call of the \code{\link{climex}}
##' function. The second one uses the database of the German weather
##' service (see \code{\link{download.data.dwd}}). The third one allows
##' the user to produce random numbers distributed according to the GEV
##' or GP distribution. Determined by menuSelectDataBase.
##' Default = "DWD".
##' @param buttonMinMax Character (radio) input determining whether
##' the GEV/GP distribution shall be fitted to the smallest or biggest
##' vales. Choices: c( "Max", "Min ), default = "Max".
##' @param extremes.interactive Function used to split a time series into
##' blocks of equal lengths and to just extract the maximal values from
##' then or to extract all data points above a certain threshold value.
##' Which option is chosen depends of the radioEvdStatistic.
##' \code{\link{extremes.interactive}}
##' @param cleaning.interactive Function used to remove incomplete years
##' from blocked time series or to remove clusters from data above a
##' certain threshold.
##' @param checkboxIncompleteYears Logical (checkbox) input determining
##' whether to remove all incomplete years of a time series. This box
##' will be only available if input$radioEvdStatistics == "GEV" and else
##' will be NULL.
##'
##' @family preprocessing
##' 
##' @return Reactive value containing a names list of the extracted
##' extreme events, the deseasonalized and pure time series. All three
##' are of class 'xts'.
##' @author Philipp Mueller 
data.extremes <- function( reactive.selection, radioEvdStatistics,
                          sliderBlockLength, sliderThreshold,
                          checkboxDecluster, deseasonalize.interactive,
                          selectDeseasonalize, selectDataBase,
                          buttonMinMax, extremes.interactive,
                          cleaning.interactive,
                          checkboxIncompleteYears ){
  reactive( {
    if ( is.null( reactive.selection() ) ||
         is.null( radioEvdStatistics() ) ){
      ## if the initialization has not finished yet just wait a
      ## little longer
      return( NULL )
    }
    if ( ( radioEvdStatistics() == "GEV" &&
           !is.null( sliderThreshold() ) &&
           is.null( sliderBlockLength() ) ) ||
         ( radioEvdStatistics() == "GP" &&
           !is.null( sliderBlockLength() ) &&
           is.null( sliderThreshold ) ) ||
         ( radioEvdStatistics() == "GP" &&
           buttonMinMax() == "Min" ) ){
      ## Let's wait till the transition is completed
      return( NULL )
    }
    x.xts <- reactive.selection()
    ## When using artificial data there is not point in doing
    ## cleaning, deseasonalization, or blocking. Instead, just
    ## return the same time series three times.
    if ( selectDataBase() == "Artificial data" ){
      return( list( blocked.data = x.xts,
                   deseasonalized.data = x.xts, pure.data = x.xts ) )
    }
    if ( ( is.null( radioEvdStatistics() ) ||
           radioEvdStatistics() == "GEV" ) &&
         ( is.null( checkboxIncompleteYears() ) ||
           checkboxIncompleteYears() ) ) {
      ## Remove all incomplete years. Since the check boxes need some time
      ## too for updating, it can happen that after switching to "GEV"
      ## the checkboxDecluster is still equal TRUE and the time series
      ## is getting torn to pieces.
        x.clean <- cleaning.interactive( x.xts,
                                       function(){ return( TRUE ) },
                                       function(){ return( NULL ) },
                                       sliderThreshold )
    } else {
      ## In case of GP fitting, do not decluster yet. This will be done
      ## while extracting the extreme events later on.
      x.clean <- cleaning.interactive( x.xts, 
                                      function(){ return( FALSE ) },
                                      function(){ return( NULL ) },
                                      sliderThreshold )
    }
    x.deseasonalized <- deseasonalize.interactive(
        x.clean, selectDeseasonalize, selectDataBase )
    
    if ( !is.null( radioEvdStatistics() ) &&
         !is.null( sliderThreshold() ) && radioEvdStatistics() == "GP" &&
         max( x.deseasonalized ) < sliderThreshold() ){
      ## This can happen when switching time series. A lot of things
      ## are marked dirty and the input$sliderThreshold will be only
      ## updated after this reactive is called
      return( NULL )
    }
    x.extreme <- extremes.interactive(
        x.deseasonalized, buttonMinMax, radioEvdStatistics,
        sliderBlockLength, sliderThreshold, checkboxDecluster )
    if ( !is.null( x.extreme ) && length( x.extreme ) < 30 ){
      shinytoastr::toastr_error( "Too few data points! Please check your threshold or block size",
                                preventDuplicates = TRUE )
      return( NULL )
    }
    return( list( blocked.data = x.extreme,
                 deseasonalized.data = x.deseasonalized,
                 pure.data = x.xts ) )
  } )
}
