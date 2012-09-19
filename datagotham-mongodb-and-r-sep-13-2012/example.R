#!/usr/bin/Rscript --vanilla --slave  --no-save --no-restore

library( "RMongo" )
library( "rjson" )

# http://ww2.coastal.edu/kingw/statistics/R-tutorials/logistic.html
# http://manuals.bioinformatics.ucr.edu/home/programming-in-r

# ------------------------------------------------------------------------------

# Open the connection to MongoDB
mongo <- mongoDbConnect( "dataGotham", "localhost", 27017 )

# ------------------------------------------------------------------------------

# Load the raw CSV
read.csv('gorilla.csv') -> gorilla

# ------------------------------------------------------------------------------

# Process the data
gorillaOut <- glm( seen ~ W * C * CW, family=binomial( logit ), data=gorilla )


# ------------------------------------------------------------------------------

# Delete the old doc (if in the collection)
dbRemoveQuery( mongo, "gorillaDataResults",  toJSON( list( '_id'='testid' ) ) )

# ------------------------------------------------------------------------------

# Create the new doc
gorillaResultDoc <- list( '_id'='testid' )
gorillaResultDoc[['iter']] <-  gorillaOut$iter
gorillaResultDoc[['dfResidual']] <- gorillaOut$df.residual
gorillaResultDoc[['converged']] <- gorillaOut$converged
gorillaResultDoc[['method']] <- gorillaOut$method
gorillaResultDoc[['residuals']] <- list( gorillaOut$residuals )
gorillaResultDoc[['aic']] <- gorillaOut$aic
gorillaResultDoc[['weights']] <- gorillaOut$weights
gorillaResultDoc[['boundary']] <- gorillaOut$boundary
gorillaResultDoc[['offset']] <- gorillaOut$offset
gorillaResultDoc[['fittedValues']] <- gorillaOut$fitted.values
gorillaResultDoc[['rank']] <- gorillaOut$rank
gorillaResultDoc[['linearPredictors']] <- gorillaOut$linear.predictors
gorillaResultDoc[['nullDeviance']] <- gorillaOut$null.deviance
gorillaResultDoc[['priorWeights']] <- gorillaOut$prior.weights
gorillaResultDoc[['y']] <- gorillaOut$y
gorillaResultDoc[['deviance']] <- gorillaOut$deviance

# Insert the new document into the database
dbInsertDocument(mongo, "gorillaDataResults", toJSON(gorillaResultDoc))

# ------------------------------------------------------------------------------

# Create the chart

png( "gorilla.png" )
plot( gorillaOut$fitted )
abline( v=30.5,col="red" )
abline( h=.3,col="green" )
abline( h=.5,col="green" )
text( 15,.9,"seen = 0" )
text( 40,.9,"seen = 1" )
dev.off()

# ------------------------------------------------------------------------------

# Load the example doc from the database.

resultDoc <- dbGetQuery(mongo, 'gorillaDataResults', toJSON( list( '_id'='testid' ) ) )

linearPredictors = fromJSON( resultDoc$linearPredictors )

attributes(linearPredictors)

for ( linearPredictor in linearPredictors ) {
    cat(linearPredictor)
    cat('\n')
}

# ------------------------------------------------------------------------------

# Close the MongoDB connection
dbDisconnect( mongo )

# ------------------------------------------------------------------------------
