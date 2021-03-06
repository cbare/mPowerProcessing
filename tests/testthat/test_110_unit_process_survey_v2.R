# Test for process_survey_v2
# 
# Author: bhoff
###############################################################################

library(testthat)
library(synapseClient)

context("test_unit_process_survey_v2")

testDataFolder<-system.file("testdata", package="mPowerProcessing")
v2DataExpectedFile<-file.path(testDataFolder, "v2SurveyInput.RData")

# This is run once, to create the data used in the test
createV2Expected<-function() {
	id<-"syn4961480"
	schema<-synGet(id)
	query<-synTableQuery(paste0("SELECT * FROM ", id, " WHERE appVersion NOT LIKE '%YML%'"))
	vals <- query@values
	vals <- permuteMe(vals)
	vals <- prependHealthCodes(vals, "test-")
	query@values <- vals[1:min(nrow(vals), 100), ]
	save(schema, query, file=v2DataExpectedFile, ascii=TRUE)
}

if (createTestData()) createV2Expected()

# Mock the schema and table content
expect_true(file.exists(v2DataExpectedFile))
load(v2DataExpectedFile)

with_mock(
		synGet=function(id) {schema},
		synTableQuery=function(sql) {query},
		{
			uDat<-process_survey_v2("syn101")
			uDatFilePath<-file.path(testDataFolder, "uDatExpected.RData")
			# Here's how we created the 'expected' data frame:
			if (createTestData()) {
				expected<-uDat
				save(expected, file=uDatFilePath, ascii=TRUE)
			}
			load(uDatFilePath) # creates 'expected'
			expect_equal(uDat, expected)
		}
)

load(v2DataExpectedFile)
# now add a duplicate row (repeat the last row)
dfRef<-query@values
query@values<-dfRef[c(1:nrow(dfRef),nrow(dfRef)),]
row.names(query@values)<-c(row.names(dfRef), sprintf("%s_0", nrow(dfRef)))

with_mock(
		synGet=function(id) {schema},
		synTableQuery=function(sql) {query},
		{
			uDat<-process_survey_v2("syn101")
			uDatFilePath<-file.path(testDataFolder, "uDatExpected.RData")
			load(uDatFilePath) # creates 'expected'
			expect_equal(uDat, expected)
		}
)

# check the case that there are no rows

load(v2DataExpectedFile)

lastMaxRowVersion<-5

with_mock(
		synGet=function(id) {schema},
		synTableQuery=function(sql) {
			truncatedQuery<-query
			truncatedQuery@values<-truncatedQuery@values[NULL,]
			truncatedQuery
		},
		{
			uDat<-process_survey_v2("syn101", lastMaxRowVersion)
			expect_equal(nrow(uDat$uDat), 0)
			expect_equal(uDat$maxRowVersion, lastMaxRowVersion)
		}
)




