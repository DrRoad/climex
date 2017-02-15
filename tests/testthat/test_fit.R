library( climex )
context( "Testing the fitting procedure" )
x.block <- climex::block( climex::anomalies( temp.potsdam ) )
x.thresh <- climex::threshold( temp.potsdam, threshold = 29,
                              decluster = TRUE )
x.block.fit <- climex::fit.gev( x.block )
x.thresh.fit <- climex::fit.gpd( x.thresh,
                                total.length = length( temp.potsdam )  )

test_that( "fit.gev has the correct output format", {
  expect_equal( class( x.block.fit ),
               c( "list", "climex.fit.gev" ) )
  expect_equal( names( x.block.fit ),
               c( "par", "value", "counts", "convergence",
                 "message", "updates", "return.level", "x" ) )
  expect_equal( class( x.block.fit$par ), "numeric" )
  expect_equal( length( x.block.fit$par ), 3 )
  expect_equal( names( x.block.fit$par ),
               c( "location", "scale", "shape" ) )
  expect_true( all( x.block == x.block.fit$x ) )
  expect_equal( class( x.block.fit$return.level ), "numeric" )
  expect_equal( length( x.block.fit$return.level ), 1 )
})
test_that( "fit.gev's rerun works", {
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            rerun = FALSE )$par ),
               c( 11.7268760, 1.4292729, -0.2607535 ) )
  expect_equal( as.numeric( climex::fit.gev( x.block, rerun = TRUE )$par
                           ),
               c( 11.7269647, 1.4291553, -0.2607239 ) )
})
test_that( "fit.gev's actual fitting works for all methods", {
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            method = "Nelder-Mead" )$par
                           ),
               c( 11.7269647, 1.4291553, -0.2607239 ) )
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            method = "BFGS" )$par ),
               c( 11.7269972, 1.4292086, -0.2607638 ) )
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            method = "CG" )$par ),
               c( 11.7269971, 1.4292080, -0.2607637 ) )
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            method = "SANN" )$par ),
               c( 11.7269970, 1.4292080, -0.2607637 ), tolerance = 1E-5 )
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            method = "nmk" )$par ),
               c( 11.7270472, 1.4292892, -0.2607769 ) )
})
test_that( "the handing over of initial parameters works", {
  expect_equal( as.numeric(
      climex::fit.gev( x.block,
                      initial = climex::likelihood.initials( x.block )
                      )$par ),
               c( 11.7269647, 1.4291553, -0.2607239 ) )
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            initial = c( 12, 1.8, -.2 )
                                            )$par ),
               c( 11.7270960, 1.4293212, -0.2608456 ) )
})
test_that( "fit.gev's error estimation works", {
  expect_equal( names( climex::fit.gev( x.block,
                                       error.estimation = "MLE" )$se ),
               c( "location", "scale", "shape", "100.rlevel" ) )
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            error.estimation = "MLE" )$se
                           ),
               c( 0.1389792, 0.09613785, 0.04381064, 0.06443386 ),
               tolerance = 1E-6 )
  expect_equal( as.numeric( climex::fit.gev( x.block,
                                            error.estimation = "MC",
                                            monte.carlo.sample.size = 100
                                            )$se
                           ),
               c( 0.13479560, 0.09901418, 0.05845571, 0.30624937 ),
               tolerance = 4E-2 )
})


test_that( "fit.gpd has the correct output format", {
  expect_equal( class( x.thresh.fit ), c( "list", "climex.fit.gpd" ) )
  expect_equal( names( x.thresh.fit ),
               c( "par", "value", "counts", "convergence",
                 "message", "x", "updates", "return.level" ) )
  expect_equal( class( x.thresh.fit$par ), "numeric" )
  expect_equal( length( x.thresh.fit$par ), 2 )
  expect_equal( names( x.thresh.fit$par ),
               c( "scale", "shape" ) )
  expect_true( all( x.thresh == x.thresh.fit$x ) )
  expect_equal( class( x.thresh.fit$return.level ), "numeric" )
  expect_equal( length( x.thresh.fit$return.level ), 1 )
})
test_that( "fit.gpd's rerun works", {
  ## here the results are truly identical
  expect_equal( as.numeric( climex::fit.gpd( x.thresh, rerun = FALSE,
                                            total.length = length(
                                                temp.potsdam )  )$par ),
               c( 2.7247064, -0.2494487 ), tolerance = 1e-3 )
  expect_equal( as.numeric( climex::fit.gpd( x.thresh, rerun = TRUE,
                                            total.length = length(
                                                temp.potsdam )  )$par ),
               c( 2.7247064, -0.2494487 ), tolerance = 1e-3 )
})
test_that( "fit.gpd's actual fitting works for all methods", {
  ## I picked such a big tolerance since the initial parameters are
  ## somewhat drawn randomly (using the type = 'best' argument) and
  ## the fitting results are quite sensitive in their respect
  expect_equal( as.numeric( climex::fit.gpd( x.thresh,
                                            method = "Nelder-Mead",
                                            total.length = length(
                                                temp.potsdam )  )$par ),
               c( 2.7248551, -0.2493577 ), tolerance = 8E-4 )
  expect_equal( as.numeric( climex::fit.gpd( x.thresh, method = "BFGS",
                                            total.length = length(
                                                temp.potsdam )  )$par ),
               c( 2.7247329, -0.2494032 ), tolerance = 6E-4 )
  expect_equal( as.numeric( climex::fit.gpd( x.thresh, method = "CG",
                                            total.length = length(
                                                temp.potsdam )  )$par ),
               c( 2.724670, -0.249398 ), tolerance = 6E-4 )
  expect_equal( as.numeric( climex::fit.gpd( x.thresh, method = "SANN",
                                            total.length = length(
                                                temp.potsdam )  )$par ),
               c( 2.7248020, -0.2494208 ), tolerance = 1E-3 )
  ## does not work yet
  ## expect_equal( as.numeric( climex::fit.gpd( x.thresh, method = "nmk" )$par ),
  ##              c( 11.7270472, 1.4292892, -0.2607769 ) )
})
test_that( "the handing over of initial parameters works", {
  expect_equal( as.numeric(
      climex::fit.gpd( x.thresh,
                      initial = climex::likelihood.initials(
                                            x.thresh, model = "gpd" ),
                      total.length = length( temp.potsdam )  )$par ),
      c( 2.7248551, -0.2493577 ), tolerance = 5e-4 )
  expect_equal( as.numeric(
      climex::fit.gpd( x.thresh, initial = c( 3, -.3 ),
                      total.length = length( temp.potsdam )  )$par ),
      c( 2.7, -1.110223e-17 ) )
})
test_that( "fit.gpd's error estimation works", {
  expect_equal( names(
      climex::fit.gpd( x.thresh, error.estimation = "MLE",
                      total.length = length( temp.potsdam ) )$se ),
      c( "scale", "shape", "100.rlevel" ) )
  expect_equal( as.numeric(
      climex::fit.gpd( x.thresh, error.estimation = "MLE",
                      total.length = length( temp.potsdam )  )$se ),
      c( 0.08357711, 0.01735246, 0.01506445 ), tolerance = 1E-4 )
  expect_equal( as.numeric(
      climex::fit.gpd( x.thresh, error.estimation = "MC",
                      total.length = length( temp.potsdam ),
                      monte.carlo.sample.size = 100 )$se ),
      c( 0.08790637, 0.02103193, 0.29344569 ),
      tolerance = 2E-2 )
})
test_that( "fit.gpd throws a warning if total.length is not supplied", {
  expect_warning( climex::fit.gpd( x.thresh ) )
})
test_that( "fit.gpd's threshold argument affect the result the way it is supposed to", {
  expect_equal( as.numeric(
      climex::fit.gpd( x.thresh, threshold = 29,
                      total.length = length( temp.potsdam )
                      )$return.level ), 38.0531, tolerance = 1e-4 )
})