# Test for process_memory_activity
# 
# Author: bhoff
###############################################################################

library(testthat)
library(synapseClient)

context("test_unit_process_memory_activity")

testDataFolder<-system.file("testdata", package="mPowerProcessing")
mDataExpectedFile<-file.path(testDataFolder, "memTaskInput.RData")

# This is run once, to create the data used in the test
createmExpected<-function() {
	id<-"syn4961459"
	schema<-synGet(id)
	query<-synTableQuery(paste0("SELECT * FROM ", id, " WHERE appVersion NOT LIKE '%YML%'"))
	vals <- query@values
	vals <- permuteMe(vals)
	vals <- prependHealthCodes(vals, "test-")
	query@values <- vals[1:min(nrow(vals), 100), ]
	save(schema, query, file=mDataExpectedFile, ascii=TRUE)
}

if (createTestData()) createmExpected()

# Mock the schema and table content
expect_true(file.exists(mDataExpectedFile))
load(mDataExpectedFile)


with_mock(
		synGet=function(id) {schema},
		synTableQuery=function(sql) {query},
		{
			mResults<-process_memory_activity("syn101")
			mDatFilePath<-file.path(testDataFolder, "mDatExpected.RData")
			# Here's how we created the 'expected' data frame:
			if (createTestData()) {
				expected<-mResults
				save(expected, file=mDatFilePath, ascii=TRUE)
			}
			load(mDatFilePath) # creates 'expected'
			expect_equal(mResults, expected)
		}
)

load(mDataExpectedFile)
# now add a duplicate row (repeat the last row)
dfRef<-query@values
query@values<-dfRef[c(1:nrow(dfRef),nrow(dfRef)),]
row.names(query@values)<-c(row.names(dfRef), sprintf("%s_0", nrow(dfRef)))

with_mock(
		synGet=function(id) {schema},
		synTableQuery=function(sql) {query},
		{
			mResults<-process_memory_activity("syn101")
			mDatFilePath<-file.path(testDataFolder, "mDatExpected.RData")
			load(mDatFilePath) # creates 'expected'
			expect_equal(mResults, expected)
		}
)


# test the case that there's no new data:

load(mDataExpectedFile)

lastMaxRowVersion<-5

with_mock(
		synGet=function(id) {schema},
		synTableQuery=function(sql) {
			truncatedQuery<-query
			truncatedQuery@values<-truncatedQuery@values[NULL,]
			truncatedQuery
		},
		{
			mResults<-process_memory_activity("syn101", lastMaxRowVersion)
			expect_equal(nrow(mResults$mDat), 0)
			expect_equal(mResults$maxRowVersion, lastMaxRowVersion)
		}
)


